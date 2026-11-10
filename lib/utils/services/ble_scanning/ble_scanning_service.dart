import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:thingsboard_app/utils/services/ble_scanning/ble_upload_session.dart';

enum BleScanningState {
  idle,
  scanning,
  uploading,

  /// The scan is over and its last results reached the backend.
  success,

  /// The scan is over, but its last results did not reach the backend.
  uploadFailed,

  /// The scan could not start or broke off.
  error,
}

/// Scans for NauticSensors BLE sensors and uploads their advertisements to
/// the NauticSensors backend, for boats where a bridge is absent or offline.
///
/// The service does not know the ThingsBoard client: the signed-in user comes
/// in through [BleUploadSession].
class BleScanningService extends ChangeNotifier {
  BleScanningService({
    required BleUploadSession session,
    required Uri uploadUrl,
    required String apiKey,
    required String userAgent,
    http.Client? httpClient,
  }) : _session = session,
       _uploadUrl = uploadUrl,
       _apiKey = apiKey,
       _userAgent = userAgent,
       _httpClient = httpClient ?? http.Client();

  static const _scanTimeout = Duration(minutes: 2);
  static const _uploadInterval = Duration(seconds: 10);
  static const _throttleDuration = Duration(seconds: 10);
  static const _adapterTimeout = Duration(seconds: 5);
  static const _uploadTimeout = Duration(seconds: 30);
  static const _autoResetDelay = Duration(seconds: 3);

  final BleUploadSession _session;
  final Uri _uploadUrl;
  final String _apiKey;
  final String _userAgent;
  final http.Client _httpClient;

  BleScanningState _state = BleScanningState.idle;
  BleScanningState get state => _state;

  int _discoveredDevicesCount = 0;
  int get discoveredDevicesCount => _discoveredDevicesCount;

  /// When the current or the most recent scan started.
  DateTime? _scanStartedAt;
  DateTime? get scanStartedAt => _scanStartedAt;

  Timer? _scanTimer;
  Timer? _uploadTimer;
  Timer? _autoResetTimer;
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  final Map<String, DateTime> _lastQueuedAt = {};
  final List<Map<String, dynamic>> _pendingUploads = [];
  final Set<String> _discoveredDevices = {};
  final Set<void Function(String)> _logListeners = {};

  /// Log lines meant for the user, such as the result of an upload.
  void addLogListener(void Function(String) listener) {
    _logListeners.add(listener);
  }

  void removeLogListener(void Function(String) listener) {
    _logListeners.remove(listener);
  }

  void _log(String message) {
    for (final listener in _logListeners.toList()) {
      listener(message);
    }
    _debug(message);
  }

  void _debug(String message) {
    if (kDebugMode) {
      debugPrint('BleScanningService: $message');
    }
  }

  void _setState(BleScanningState newState) {
    if (_state == newState) {
      return;
    }
    _debug('state ${_state.name} -> ${newState.name}');
    _state = newState;

    // The final states fall back to idle by themselves.
    _autoResetTimer?.cancel();
    _autoResetTimer = null;
    if (newState == BleScanningState.success ||
        newState == BleScanningState.uploadFailed ||
        newState == BleScanningState.error) {
      _autoResetTimer = Timer(
        _autoResetDelay,
        () => _setState(BleScanningState.idle),
      );
    }

    notifyListeners();
  }

  Future<bool> _hasBluetoothPermission() async {
    final Permission permission;
    if (Platform.isAndroid) {
      permission = Permission.bluetoothScan;
    } else if (Platform.isIOS) {
      permission = Permission.bluetooth;
    } else {
      return true;
    }

    if (await permission.status.isGranted) {
      return true;
    }
    return permission.request().isGranted;
  }

  /// Starts a scan, or stops the scan that is running.
  Future<void> startScanning() async {
    if (_state == BleScanningState.scanning) {
      stopScanning();
      return;
    }

    try {
      if (!await _hasBluetoothPermission()) {
        _debug('bluetooth permission denied');
        _setState(BleScanningState.error);
        return;
      }

      if (!await FlutterBluePlus.isSupported) {
        _debug('bluetooth not supported');
        _setState(BleScanningState.error);
        return;
      }

      try {
        await FlutterBluePlus.adapterState
            .firstWhere((state) => state == BluetoothAdapterState.on)
            .timeout(_adapterTimeout);
      } on TimeoutException {
        _debug('bluetooth adapter is not on');
        _setState(BleScanningState.error);
        return;
      }

      _pendingUploads.clear();
      _discoveredDevices.clear();
      _discoveredDevicesCount = 0;
      _scanStartedAt = DateTime.now();
      _setState(BleScanningState.scanning);

      _scanSubscription = FlutterBluePlus.scanResults.listen(
        _processScanResults,
      );
      await FlutterBluePlus.startScan();

      _uploadTimer = Timer.periodic(_uploadInterval, (_) {
        if (_pendingUploads.isEmpty) {
          _log('⏰ Periodic upload check - no data to upload');
        } else {
          _log(
            '⏰ Periodic upload triggered '
            '(${_pendingUploads.length} devices queued)',
          );
          _uploadDuringScanning();
        }
      });
      _scanTimer = Timer(_scanTimeout, stopScanning);
    } catch (e) {
      _debug('scanning error: $e');
      _setState(BleScanningState.error);
    }
  }

  void _cancelScan() {
    _scanTimer?.cancel();
    _scanTimer = null;
    _uploadTimer?.cancel();
    _uploadTimer = null;
    _scanSubscription?.cancel();
    _scanSubscription = null;
    FlutterBluePlus.stopScan();
  }

  void stopScanning() {
    _cancelScan();

    if (_pendingUploads.isNotEmpty) {
      _uploadAfterScanning();
    } else {
      _setState(BleScanningState.idle);
    }
  }

  /// NauticSensors sensors advertise manufacturer data that starts with 83 bc.
  static bool _isSensorData(List<int> bytes) {
    return bytes.length >= 2 && bytes[0] == 0x83 && bytes[1] == 0xbc;
  }

  /// The sensor puts its MAC address in the service data with UUID 0x2ac3: the
  /// last six bytes, in reverse order. iOS hides the real address, so this is
  /// the only way to get it there.
  static String? _macAddressFromServiceData(Map<Guid, List<int>> serviceData) {
    for (final entry in serviceData.entries) {
      final uuid = entry.key.toString().toLowerCase();
      final bytes = entry.value;
      if ((uuid.contains('2ac3') || uuid.contains('c32a')) &&
          bytes.length >= 6) {
        return bytes
            .sublist(bytes.length - 6)
            .reversed
            .map((b) => b.toRadixString(16).padLeft(2, '0'))
            .join(':');
      }
    }
    return null;
  }

  void _processScanResults(List<ScanResult> results) {
    final now = DateTime.now();

    for (final result in results) {
      final advertisement = result.advertisementData;
      final sensorData =
          advertisement.manufacturerData.entries
              .where((entry) => _isSensorData(entry.value))
              .firstOrNull;
      if (sensorData == null) {
        continue;
      }

      final macAddress =
          _macAddressFromServiceData(advertisement.serviceData) ??
          result.device.remoteId.toString();

      if (_discoveredDevices.add(macAddress)) {
        _discoveredDevicesCount++;
        notifyListeners();
      }

      // Queue a sensor at most once per throttle period.
      final lastQueuedAt = _lastQueuedAt[macAddress];
      if (lastQueuedAt != null &&
          now.difference(lastQueuedAt) < _throttleDuration) {
        continue;
      }

      _pendingUploads.add({
        'macAddress': macAddress,
        'rssi': result.rssi,
        'timestamp': now.millisecondsSinceEpoch,
        'companyId': sensorData.key,
        'rawData':
            sensorData.value
                .map((b) => b.toRadixString(16).padLeft(2, '0'))
                .join(),
      });
      _lastQueuedAt[macAddress] = now;
    }
  }

  /// Keeps the most recent advertisement of every sensor.
  static List<Map<String, dynamic>> _latestPerSensor(
    List<Map<String, dynamic>> devices,
  ) {
    final latest = <String, Map<String, dynamic>>{};
    for (final device in devices) {
      final macAddress = device['macAddress'] as String;
      final current = latest[macAddress];
      if (current == null ||
          (device['timestamp'] as int) > (current['timestamp'] as int)) {
        latest[macAddress] = device;
      }
    }
    return latest.values.toList();
  }

  /// Posts [devices] to the backend and returns the HTTP status code.
  ///
  /// The request carries the API key of the app and, when a user is signed in,
  /// that user's ThingsBoard access token, so the backend can tell who sent
  /// the data.
  Future<int> _post(List<Map<String, dynamic>> devices) async {
    final identity = await _session.currentIdentity();
    final accessToken = identity.accessToken;

    final response = await _httpClient
        .post(
          _uploadUrl,
          headers: {
            'Content-Type': 'application/json',
            'User-Agent': _userAgent,
            if (_apiKey.isNotEmpty) 'api-key': _apiKey,
            if (accessToken != null) 'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'devices': devices,
            'source': 'flutter_app',
            'userEmail': identity.email ?? 'unknown',
          }),
        )
        .timeout(_uploadTimeout);
    return response.statusCode;
  }

  static bool _isAccepted(int statusCode) {
    return statusCode == 200 || statusCode == 201;
  }

  /// Uploads what is queued while the scan goes on. A failure leaves the queue
  /// and the state alone: the next round tries again.
  Future<void> _uploadDuringScanning() async {
    final batch = List.of(_pendingUploads);
    final devices = _latestPerSensor(batch);
    _log('📤 Starting periodic upload of ${devices.length} devices');

    try {
      final statusCode = await _post(devices);
      if (_isAccepted(statusCode)) {
        _log(
          '✅ Periodic upload successful! Uploaded ${devices.length} devices',
        );
        // Only drop what was sent: the scan may have queued more meanwhile.
        _pendingUploads.removeWhere(batch.contains);
      } else {
        _log('❌ Periodic upload failed with status $statusCode');
      }
    } catch (e) {
      _log('❌ Periodic upload exception: $e');
    }
  }

  /// Uploads what is left once the scan has stopped, and ends the scan in the
  /// success state or, when the backend did not accept the upload, in the
  /// upload-failed state.
  Future<void> _uploadAfterScanning() async {
    final devices = _latestPerSensor(_pendingUploads);
    _setState(BleScanningState.uploading);

    var accepted = false;
    try {
      final statusCode = await _post(devices);
      accepted = _isAccepted(statusCode);
      if (!accepted) {
        _log('❌ Final upload failed with status $statusCode');
      }
    } catch (e) {
      _log('❌ Final upload exception: $e');
    }

    // What was queued is dropped either way: the next scan starts afresh.
    _pendingUploads.clear();
    _setState(
      accepted ? BleScanningState.success : BleScanningState.uploadFailed,
    );
  }

  @override
  void dispose() {
    _cancelScan();
    _autoResetTimer?.cancel();
    _httpClient.close();
    super.dispose();
  }
}
