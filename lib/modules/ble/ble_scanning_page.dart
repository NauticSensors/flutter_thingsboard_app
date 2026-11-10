import 'package:flutter/material.dart';
import 'package:thingsboard_app/generated/l10n.dart';
import 'package:thingsboard_app/locator.dart';
import 'package:thingsboard_app/utils/services/ble_scanning/ble_scanning_service.dart';
import 'package:thingsboard_app/widgets/tb_app_bar.dart';

/// The sensor scanner: collects data straight from nearby sensors and uploads
/// it, for boats where a bridge is absent or has no connection.
///
/// The mobile center of the server adds this page to the navigation as a
/// custom page with the path `/ble-scanner`.
class BleScanningPage extends StatefulWidget {
  const BleScanningPage({super.key});

  @override
  State<StatefulWidget> createState() => _BleScanningPageState();
}

class _BleScanningPageState extends State<BleScanningPage> {
  final BleScanningService _bleScanningService = getIt();
  final List<String> _scanLogs = [];
  int _scannedDevicesCount = 0;
  int _uploadedDevicesCount = 0;
  DateTime? _scanStartTime;
  bool _logsExpanded = false;

  @override
  void initState() {
    super.initState();
    // The service outlives the page: pick up a scan that is already running.
    _scannedDevicesCount = _bleScanningService.discoveredDevicesCount;
    if (_bleScanningService.state == BleScanningState.scanning) {
      _scanStartTime = _bleScanningService.scanStartedAt;
    }
    _bleScanningService.addListener(_onScanningStateChanged);
    _bleScanningService.addLogListener(_onServiceLog);
    _addLog('Sensor Scanner initialized');
  }

  @override
  void dispose() {
    _bleScanningService.removeListener(_onScanningStateChanged);
    _bleScanningService.removeLogListener(_onServiceLog);
    super.dispose();
  }

  void _addLog(String message) {
    _scanLogs.add(
      '${DateTime.now().toLocal().toString().substring(11, 19)}: $message',
    );
  }

  void _onServiceLog(String message) {
    if (!mounted) return;
    setState(() => _addLog(message));
  }

  void _clearLogs() {
    setState(() {
      _scanLogs.clear();
      _scannedDevicesCount = 0;
      _uploadedDevicesCount = 0;
      _scanStartTime = null;
    });
  }

  void _onScanningStateChanged() {
    if (!mounted) return;

    setState(() {
      switch (_bleScanningService.state) {
        case BleScanningState.idle:
          _addFinalReport();
        case BleScanningState.scanning:
          if (_scanStartTime == null) {
            _scanStartTime = _bleScanningService.scanStartedAt;
            _addLog('🔍 Started sensor scanning...');
          }
          if (_bleScanningService.discoveredDevicesCount !=
              _scannedDevicesCount) {
            _scannedDevicesCount = _bleScanningService.discoveredDevicesCount;
            _addLog('📱 Found new sensor (Total: $_scannedDevicesCount)');
          }
        case BleScanningState.uploading:
          _addLog('📤 Uploading scan results to endpoint...');
        case BleScanningState.success:
          _uploadedDevicesCount++;
          _addLog('✅ Successfully uploaded device data');
        case BleScanningState.uploadFailed:
          _addLog('❌ Failed to upload the scan results');
        case BleScanningState.error:
          _addLog('❌ Error occurred during scanning or upload');
      }
    });
  }

  /// Closes a scan in the log and resets the counters for the next one.
  void _addFinalReport() {
    final scanStartTime = _scanStartTime;
    if (scanStartTime == null) {
      return;
    }
    final duration = DateTime.now().difference(scanStartTime);

    _addLog(
      '⏱️ Scan duration: ${duration.inMinutes}m ${duration.inSeconds % 60}s',
    );
    _addLog('📱 Sensors found: $_scannedDevicesCount');
    _addLog('✅ Successfully uploaded: $_uploadedDevicesCount');

    _scanStartTime = null;
    _scannedDevicesCount = 0;
    _uploadedDevicesCount = 0;
  }

  @override
  Widget build(BuildContext context) {
    final state = _bleScanningService.state;

    return Scaffold(
      appBar: TbAppBar(title: Text(S.of(context).sensorScanner), elevation: 1),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getStatusIcon(state),
                          color: _getStatusColor(state),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _getStatusText(context, state),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        if (state == BleScanningState.scanning)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              '(${S.of(context).sensorsFound(_bleScanningService.discoveredDevicesCount)})',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (state == BleScanningState.scanning ||
                        state == BleScanningState.uploading)
                      LinearProgressIndicator(
                        color:
                            state == BleScanningState.uploading
                                ? Colors.orange
                                : Colors.blue,
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Description Text
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                S.of(context).sensorScannerDescription,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
                textAlign: TextAlign.left,
              ),
            ),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        state == BleScanningState.idle
                            ? _bleScanningService.startScanning
                            : null,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        state == BleScanningState.scanning
                            ? _bleScanningService.stopScanning
                            : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Collapsible Logs Section
            Flexible(
              child: Card(
                child: ExpansionTile(
                  initiallyExpanded: _logsExpanded,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _logsExpanded = expanded;
                    });
                  },
                  title: Text(
                    S.of(context).scanLogs,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    S.of(context).scanLogsEntries(_scanLogs.length),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.3,
                        minHeight: 200,
                      ),
                      child: Stack(
                        children: [
                          if (_scanLogs.isEmpty)
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.list_alt,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    S.of(context).noScanLogsYet,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    S.of(context).startScanningToSeeLogs,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ListView.builder(
                              padding: const EdgeInsets.all(8.0),
                              itemCount: _scanLogs.length,
                              itemBuilder: (context, index) {
                                // Newest first.
                                final log =
                                    _scanLogs[_scanLogs.length - 1 - index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2.0,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 4,
                                        height: 16,
                                        margin: const EdgeInsets.only(
                                          right: 8,
                                          top: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getLogColor(log),
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          log,
                                          style: const TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          // Clear Logs Button
                          if (_scanLogs.isNotEmpty)
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: FloatingActionButton.small(
                                onPressed: _clearLogs,
                                backgroundColor: Colors.grey.shade100,
                                foregroundColor: Colors.grey.shade700,
                                elevation: 2,
                                tooltip: S.of(context).clearLogs,
                                child: const Icon(Icons.delete_outline),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLogColor(String log) {
    if (log.contains('Error') || log.contains('Failed')) {
      return Colors.red;
    } else if (log.contains('Success') || log.contains('Connected')) {
      return Colors.green;
    } else if (log.contains('Scanning') || log.contains('Found')) {
      return Colors.blue;
    } else if (log.contains('Upload') || log.contains('Sending')) {
      return Colors.orange;
    }
    return Colors.grey;
  }

  IconData _getStatusIcon(BleScanningState state) {
    switch (state) {
      case BleScanningState.idle:
        return Icons.radar;
      case BleScanningState.scanning:
        return Icons.search;
      case BleScanningState.uploading:
        return Icons.cloud_upload;
      case BleScanningState.success:
        return Icons.check_circle;
      case BleScanningState.uploadFailed:
        return Icons.cloud_off;
      case BleScanningState.error:
        return Icons.error;
    }
  }

  Color _getStatusColor(BleScanningState state) {
    switch (state) {
      case BleScanningState.idle:
        return Colors.grey;
      case BleScanningState.scanning:
        return Colors.blue;
      case BleScanningState.uploading:
        return Colors.orange;
      case BleScanningState.success:
        return Colors.green;
      case BleScanningState.uploadFailed:
      case BleScanningState.error:
        return Colors.red;
    }
  }

  String _getStatusText(BuildContext context, BleScanningState state) {
    switch (state) {
      case BleScanningState.idle:
        return S.of(context).sensorScannerReady;
      case BleScanningState.scanning:
        return S.of(context).scanningForSensors;
      case BleScanningState.uploading:
        return S.of(context).uploadingScanResults;
      case BleScanningState.success:
        return S.of(context).uploadCompletedSuccessfully;
      case BleScanningState.uploadFailed:
        return S.of(context).uploadFailed;
      case BleScanningState.error:
        return S.of(context).errorOccurredDuringScanning;
    }
  }
}
