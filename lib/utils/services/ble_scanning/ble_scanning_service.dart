import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:thingsboard_app/core/context/tb_context.dart';

enum BleScanningState {
  idle,
  scanning,
  uploading,
  error,
}

class BleScanningService extends ChangeNotifier {
  static final BleScanningService _instance = BleScanningService._internal();
  factory BleScanningService() => _instance;
  BleScanningService._internal();

  TbContext? _tbContext;

  BleScanningState _state = BleScanningState.idle;
  BleScanningState get state => _state;

  Timer? _scanTimer;
  Timer? _uploadTimer;
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  final Map<String, DateTime> _lastUploadTimes = {};
  final List<Map<String, dynamic>> _pendingUploads = [];

  static const String _apiEndpoint =
      'https://api.nauticsensors.com/api/v1/webhooks/bluestar-app/ingress';
  // static const String _apiEndpoint =
  //     'http://192.168.178.2:3000/bluestar-app/ingress';
  static const String _apiKey = 'f7b572f4-71d1-42b9-a3e3-3a5b798c3d78';
  static const Duration _scanTimeout = Duration(minutes: 2);
  static const Duration _uploadInterval = Duration(seconds: 10);
  static const Duration _throttleDuration = Duration(seconds: 10);

  void _setState(BleScanningState newState) {
    if (_state != newState) {
      if (kDebugMode) {
        print('🔄 BLE State change: ${_state.name} -> ${newState.name}');
      }
      _state = newState;
      notifyListeners();
    }
  }

  Future<bool> _checkPermissions() async {
    if (kDebugMode) {
      print(
          '🔐 Checking BLE permissions for platform: ${Platform.operatingSystem}');
    }

    if (Platform.isAndroid) {
      final permissions = [
        Permission.bluetoothScan,
      ];

      for (final permission in permissions) {
        final status = await permission.status;
        if (kDebugMode) {
          print(
              '🔐 Permission ${permission.toString().split('.').last}: ${status.name}');
        }
        if (!status.isGranted) {
          if (kDebugMode) {
            print(
                '🔐 Requesting permission: ${permission.toString().split('.').last}');
          }
          final result = await permission.request();
          if (kDebugMode) {
            print('🔐 Permission request result: ${result.name}');
          }
          if (!result.isGranted) {
            if (kDebugMode) {
              print(
                  '❌ Permission denied: ${permission.toString().split('.').last}');
            }
            return false;
          }
        }
      }
    } else if (Platform.isIOS) {
      final status = await Permission.bluetooth.status;
      if (kDebugMode) {
        print('🔐 iOS Bluetooth permission: ${status.name}');
      }
      if (!status.isGranted) {
        if (kDebugMode) {
          print('🔐 Requesting iOS Bluetooth permission');
        }
        final result = await Permission.bluetooth.request();
        if (kDebugMode) {
          print('🔐 iOS Bluetooth permission result: ${result.name}');
        }
        if (!result.isGranted) {
          if (kDebugMode) {
            print('❌ iOS Bluetooth permission denied');
          }
          return false;
        }
      }
    }

    if (kDebugMode) {
      print('✅ All BLE permissions granted');
    }
    return true;
  }

  void setContext(TbContext tbContext) {
    _tbContext = tbContext;
  }

  Future<void> startScanning() async {
    if (kDebugMode) {
      print('🚀 Starting BLE scanning process...');
    }

    if (_state == BleScanningState.scanning) {
      if (kDebugMode) {
        print('⚠️ Already scanning, stopping current scan first');
      }
      stopScanning();
      return;
    }

    try {
      final hasPermissions = await _checkPermissions();
      if (!hasPermissions) {
        if (kDebugMode) {
          print('❌ BLE scanning failed: Permissions not granted');
        }
        _setState(BleScanningState.error);
        return;
      }

      final isSupported = await FlutterBluePlus.isSupported;
      if (kDebugMode) {
        print('📱 Bluetooth support check: $isSupported');
      }
      if (!isSupported) {
        if (kDebugMode) {
          print('❌ BLE scanning failed: Bluetooth not supported');
        }
        _setState(BleScanningState.error);
        return;
      }

      // Wait for adapter to be in 'on' state, with timeout
      BluetoothAdapterState adapterState;
      final adapterTimeout = DateTime.now().add(const Duration(seconds: 5));
      
      do {
        adapterState = await FlutterBluePlus.adapterState.first;
        if (kDebugMode) {
          print('📡 Bluetooth adapter state: ${adapterState.name}');
        }
        
        if (adapterState == BluetoothAdapterState.on) {
          break;
        }
        
        if (DateTime.now().isAfter(adapterTimeout)) {
          if (kDebugMode) {
            print('❌ BLE scanning failed: Bluetooth adapter state timeout');
          }
          _setState(BleScanningState.error);
          return;
        }
        
        // Wait a bit before checking again
        await Future.delayed(const Duration(milliseconds: 200));
      } while (adapterState != BluetoothAdapterState.on);
      
      if (kDebugMode) {
        print('✅ Bluetooth adapter is ready');
      }

      _setState(BleScanningState.scanning);
      _pendingUploads.clear();
      if (kDebugMode) {
        print('🧺 Cleared pending uploads, starting fresh scan');
      }

      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        _processScanResults(results);
      });

      await FlutterBluePlus.startScan();
      if (kDebugMode) {
        print('🔍 BLE scan started successfully');
        print('⏱️ Scan timeout set to ${_scanTimeout.inMinutes} minute(s)');
        print('📤 Upload interval set to ${_uploadInterval.inSeconds} seconds');
      }

      // Start periodic upload timer
      _uploadTimer = Timer.periodic(_uploadInterval, (timer) {
        if (_pendingUploads.isNotEmpty) {
          if (kDebugMode) {
            print(
                '⏰ Periodic upload triggered (${_pendingUploads.length} devices queued)');
          }
          _uploadPendingDataDuringScanning();
        } else if (kDebugMode) {
          print('⏰ Periodic upload check - no data to upload');
        }
      });

      _scanTimer = Timer(_scanTimeout, () {
        if (kDebugMode) {
          print('⏰ Scan timeout reached, stopping scan');
        }
        stopScanning();
      });
    } catch (e) {
      _setState(BleScanningState.error);
      if (kDebugMode) {
        print('❌ BLE Scanning error: $e');
      }
    }
  }

  void stopScanning() {
    if (kDebugMode) {
      print('🛑 Stopping BLE scan...');
    }

    _scanTimer?.cancel();
    _scanTimer = null;
    if (kDebugMode) {
      print('⏱️ Scan timer cancelled');
    }

    _uploadTimer?.cancel();
    _uploadTimer = null;
    if (kDebugMode) {
      print('📤 Upload timer cancelled');
    }

    _scanSubscription?.cancel();
    _scanSubscription = null;
    if (kDebugMode) {
      print('📶 Scan subscription cancelled');
    }

    FlutterBluePlus.stopScan();
    if (kDebugMode) {
      print('🛑 Flutter Blue Plus scan stopped');
    }

    if (_pendingUploads.isNotEmpty) {
      if (kDebugMode) {
        print(
            '📤 ${_pendingUploads.length} pending uploads found, starting final upload');
      }
      _uploadPendingData();
    } else {
      if (kDebugMode) {
        print('💭 No pending uploads, returning to idle state');
      }
      _setState(BleScanningState.idle);
    }
  }

  bool _isValidSensorData(Map<int, List<int>> manufacturerData) {
    // Check if there's any manufacturer data
    if (manufacturerData.isEmpty) {
      return false;
    }

    // Check each manufacturer data entry for our sensor pattern
    for (final entry in manufacturerData.entries) {
      final bytes = entry.value;

      // Check if data has minimum length (at least 2 bytes for 83bc check)
      if (bytes.length < 2) {
        continue;
      }

      // Check if manufacturer data starts with 83bc
      if (bytes[0] == 0x83 && bytes[1] == 0xbc) {
        return true;
      }
    }

    return false;
  }

  String? _extractMacAddressFromServiceData(Map<Guid, List<int>> serviceData) {
    // Look for service data with UUID 0x2ac3
    for (final entry in serviceData.entries) {
      final uuid = entry.key.toString().toLowerCase();
      final bytes = entry.value;

      // Check if this is our MAC address service data (UUID 0x2ac3)
      if ((uuid.contains('2ac3') || uuid.contains('c32a')) &&
          bytes.length >= 6) {
        // MAC address is the last 6 bytes, in reverse order
        final macBytes = bytes.sublist(bytes.length - 6).reversed.toList();
        final macAddress = macBytes
            .map((b) => b.toRadixString(16).padLeft(2, '0'))
            .join(':')
            .toLowerCase();
        return macAddress;
      }
    }
    return null;
  }

  void _processScanResults(List<ScanResult> results) {
    final now = DateTime.now();

    if (kDebugMode && results.isNotEmpty) {
      print('📶 Processing ${results.length} scan result(s)');
    }

    for (final result in results) {
      // Try to extract MAC address from service data first, fallback to remoteId
      final extractedMac = _extractMacAddressFromServiceData(
          result.advertisementData.serviceData);
      final macAddress = extractedMac ?? result.device.remoteId.toString();
      final lastUpload = _lastUploadTimes[macAddress];

      // Get manufacturer data
      final manufacturerData = result.advertisementData.manufacturerData;

      // Filter: Only process devices with valid sensor data
      if (!_isValidSensorData(manufacturerData)) {
        // if (kDebugMode) {
        //   print('📱 Device: $macAddress | RSSI: ${result.rssi} dBm | 🚫 Filtered out: No manufacturer data starting with 83bc');
        // }
        continue;
      }

      if (kDebugMode) {
        final sourceInfo =
            extractedMac != null ? 'MAC from service data' : 'using remoteId';
        print(
            '📱 Device: $macAddress ($sourceInfo) | RSSI: ${result.rssi} dBm | ✅ Valid sensor');

        // Print advertisement details only for valid sensors
        final advData = result.advertisementData;
        print('📡 Advertisement Details:');

        // Advertisement name
        final advName = advData.localName.isEmpty ? 'N/A' : advData.localName;
        print('  - Name: $advName');

        // TX Power Level
        final txPower = advData.txPowerLevel?.toString() ?? 'N/A';
        print('  - TX Power: $txPower dBm');

        // Connectable
        final connectable = advData.connectable?.toString() ?? 'N/A';
        print('  - Connectable: $connectable');

        // Manufacturing Data as raw bytes
        if (advData.manufacturerData.isNotEmpty) {
          print('  - Manufacturing Data:');
          advData.manufacturerData.forEach((companyId, bytes) {
            final hexBytes =
                bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
            final isValidSensor =
                bytes.length >= 2 && bytes[0] == 0x83 && bytes[1] == 0xbc;
            print(
                '    Company ID $companyId: [$hexBytes] ${isValidSensor ? '✅ Valid sensor' : ''}');
          });
        } else {
          print('  - Manufacturing Data: (empty)');
        }

        // Service Data as raw bytes
        if (advData.serviceData.isNotEmpty) {
          print('  - Service Data:');
          advData.serviceData.forEach((uuid, bytes) {
            final hexBytes =
                bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
            print('    $uuid: [$hexBytes]');
          });
        } else {
          print('  - Service Data: (empty)');
        }
      }

      // Get the valid manufacturer data bytes for our sensors
      List<int> validSensorBytes = [];
      int validCompanyId = 0;
      for (final entry in manufacturerData.entries) {
        final bytes = entry.value;
        if (bytes.length >= 2 && bytes[0] == 0x83 && bytes[1] == 0xbc) {
          validSensorBytes = bytes;
          validCompanyId = entry.key;
          break;
        }
      }

      final rawHex = validSensorBytes
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join('');

      if (kDebugMode) {
        if (lastUpload != null) {
          final timeSinceLastUpload = now.difference(lastUpload);
          print(
              '⏱️ Time since last upload: ${timeSinceLastUpload.inSeconds}s (throttle: ${_throttleDuration.inSeconds}s)');
        } else {
          print('🆕 First time seeing this sensor');
        }
      }

      if (lastUpload == null ||
          now.difference(lastUpload) >= _throttleDuration) {
        final deviceData = {
          'macAddress': macAddress,
          'rssi': result.rssi,
          'timestamp': now.millisecondsSinceEpoch,
          'companyId': validCompanyId,
          'rawData': rawHex, // Only the manufacturer data raw bytes
        };

        _pendingUploads.add(deviceData);
        _lastUploadTimes[macAddress] = now;

        if (kDebugMode) {
          print(
              '➕ Added to upload queue: $macAddress (Total pending: ${_pendingUploads.length})');
        }
      } else if (kDebugMode) {
        print('⏸️ Throttled: $macAddress (skipped due to recent upload)');
      }
    }
  }

  Map<String, dynamic> _extractAdvertisementData(ScanResult result) {
    final data = <String, dynamic>{};

    if (result.advertisementData.connectable != null) {
      data['connectable'] = result.advertisementData.connectable;
    }

    if (result.advertisementData.localName.isNotEmpty) {
      data['localName'] = result.advertisementData.localName;
    }

    if (result.advertisementData.txPowerLevel != null) {
      data['txPowerLevel'] = result.advertisementData.txPowerLevel;
    }

    if (result.advertisementData.serviceUuids.isNotEmpty) {
      data['serviceUuids'] = result.advertisementData.serviceUuids
          .map((uuid) => uuid.toString())
          .toList();
    }

    if (result.advertisementData.serviceData.isNotEmpty) {
      data['serviceData'] = result.advertisementData.serviceData.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }

    if (result.advertisementData.manufacturerData.isNotEmpty) {
      data['manufacturerData'] = result.advertisementData.manufacturerData.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }

    return data;
  }

  List<Map<String, dynamic>> _deduplicateDevices(
      List<Map<String, dynamic>> devices) {
    final Map<String, Map<String, dynamic>> latestDevices = {};

    // Group by MAC address and keep the latest timestamp
    for (final device in devices) {
      final macAddress = device['macAddress'] as String;
      final timestamp = device['timestamp'] as int;

      if (!latestDevices.containsKey(macAddress) ||
          timestamp > (latestDevices[macAddress]!['timestamp'] as int)) {
        latestDevices[macAddress] = device;
      }
    }

    if (kDebugMode && latestDevices.length != devices.length) {
      print(
          '🔄 Deduplicated ${devices.length} -> ${latestDevices.length} devices');
    }

    return latestDevices.values.toList();
  }

  Future<void> _uploadPendingDataDuringScanning() async {
    if (_pendingUploads.isEmpty) {
      if (kDebugMode) {
        print('📭 No pending uploads during scanning check');
      }
      return;
    }

    // Deduplicate devices before upload
    final deduplicatedDevices = _deduplicateDevices(_pendingUploads);

    if (kDebugMode) {
      print(
          '📤 Uploading ${deduplicatedDevices.length} device(s) during scanning (${_pendingUploads.length} before deduplication)');
      for (int i = 0; i < deduplicatedDevices.length; i++) {
        final device = deduplicatedDevices[i];
        print(
            '  ${i + 1}. ${device['macAddress']} | RSSI: ${device['rssi']} dBm | Latest timestamp: ${device['timestamp']}');
      }
    }

    try {
      String userEmail = 'unknown';
      try {
        final user = await _tbContext?.tbClient.getUserService().getUser();
        userEmail = user?.email ?? 'unknown';
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Could not get user email: $e');
        }
        userEmail = _tbContext?.userDetails?.email ?? 'unknown';
      }

      final payload = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'devices': deduplicatedDevices,
        'source': 'flutter_app',
        'userEmail': userEmail,
      };

      final jsonPayload = jsonEncode(payload);
      if (kDebugMode) {
        print('🌐 HTTP POST to: $_apiEndpoint (during scanning)');
        print('📊 Payload size: ${jsonPayload.length} bytes');
        print('📄 JSON Payload: $jsonPayload');
      }

      final response = await http
          .post(
            Uri.parse(_apiEndpoint),
            headers: {
              'Content-Type': 'application/json',
              'User-Agent': 'BluestarApp/1.6.0',
              'api-key': _apiKey
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print(
            '📨 HTTP Response: ${response.statusCode} ${response.reasonPhrase} (during scanning)');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (kDebugMode) {
          print(
              '✅ Periodic upload successful! Clearing ${_pendingUploads.length} pending upload(s)');
        }
        _pendingUploads.clear();
      } else {
        if (kDebugMode) {
          print('❌ Periodic upload failed with status ${response.statusCode}');
          print('❌ Response: ${response.body}');
        }
        // Don't change state during scanning, just log the error
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Periodic upload exception: $e');
      }
      // Don't change state during scanning, just log the error
    }
  }

  Future<void> _uploadPendingData() async {
    if (_pendingUploads.isEmpty) {
      if (kDebugMode) {
        print('💭 No pending uploads to process, returning to idle');
      }
      _setState(BleScanningState.idle);
      return;
    }

    // Deduplicate devices before upload
    final deduplicatedDevices = _deduplicateDevices(_pendingUploads);

    if (kDebugMode) {
      print(
          '📤 Starting upload process with ${deduplicatedDevices.length} device(s) (${_pendingUploads.length} before deduplication)');
      for (int i = 0; i < deduplicatedDevices.length; i++) {
        final device = deduplicatedDevices[i];
        print(
            '  ${i + 1}. ${device['macAddress']} | RSSI: ${device['rssi']} dBm | Latest timestamp: ${device['timestamp']}');
      }
    }

    _setState(BleScanningState.uploading);

    try {
      String userEmail = 'unknown';
      try {
        final user = await _tbContext?.tbClient.getUserService().getUser();
        userEmail = user?.email ?? 'unknown';
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Could not get user email: $e');
        }
        userEmail = _tbContext?.userDetails?.email ?? 'unknown';
      }

      final payload = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'devices': deduplicatedDevices,
        'source': 'flutter_app',
        'userEmail': userEmail,
      };

      final jsonPayload = jsonEncode(payload);
      if (kDebugMode) {
        print('🌐 HTTP POST to: $_apiEndpoint');
        print('📊 Payload size: ${jsonPayload.length} bytes');
        print('📄 JSON Payload: $jsonPayload');
        print('🕰️ Timeout: 30 seconds');
      }

      final response = await http
          .post(
            Uri.parse(_apiEndpoint),
            headers: {
              'Content-Type': 'application/json',
              'User-Agent': 'BluestarApp/1.6.0',
              'api-key': _apiKey
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print(
            '📨 HTTP Response: ${response.statusCode} ${response.reasonPhrase}');
        print('📄 Response headers: ${response.headers}');
        if (response.body.isNotEmpty) {
          print('📄 Response body: ${response.body}');
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (kDebugMode) {
          print(
              '✅ Upload successful! Clearing ${_pendingUploads.length} pending upload(s)');
        }
        _pendingUploads.clear();
        _setState(BleScanningState.idle);
      } else {
        if (kDebugMode) {
          print('❌ Upload failed with status ${response.statusCode}');
          print('❌ Response: ${response.body}');
        }
        _setState(BleScanningState.error);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Upload exception: $e');
        if (e.toString().contains('TimeoutException')) {
          print('⏰ Upload timed out after 30 seconds');
        }
      }
      _setState(BleScanningState.error);
    }
  }

  void clearError() {
    if (_state == BleScanningState.error) {
      if (kDebugMode) {
        print('🔄 Clearing error state, returning to idle');
      }
      _setState(BleScanningState.idle);
    } else if (kDebugMode) {
      print(
          'ℹ️ clearError() called but current state is not error (current: ${_state.name})');
    }
  }

  @override
  void dispose() {
    if (kDebugMode) {
      print('🗑️ Disposing BLE scanning service');
    }
    stopScanning();
    super.dispose();
  }
}
