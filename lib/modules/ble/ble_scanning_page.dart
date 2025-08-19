import 'package:flutter/material.dart';
import 'package:thingsboard_app/core/context/tb_context_widget.dart';
import 'package:thingsboard_app/generated/l10n.dart';
import 'package:thingsboard_app/widgets/tb_app_bar.dart';
import 'package:thingsboard_app/utils/services/ble_scanning/ble_scanning_service.dart';

class BleScanningPage extends TbContextWidget {
  BleScanningPage(super.tbContext, {super.key});

  @override
  State<StatefulWidget> createState() => _BleScanningPageState();
}

class _BleScanningPageState extends TbContextState<BleScanningPage> {
  final List<String> _scanLogs = [];
  late final BleScanningService _bleScanningService;
  int _scannedDevicesCount = 0;
  int _uploadedDevicesCount = 0;
  DateTime? _scanStartTime;
  bool _logsExpanded = false;

  void _addLog(String message) {
    setState(() {
      _scanLogs.add(
        '${DateTime.now().toLocal().toString().substring(11, 19)}: $message',
      );
    });
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
          if (_scanStartTime != null) {
            _addFinalReport();
          }
          break;
        case BleScanningState.scanning:
          if (_scanStartTime == null) {
            _scanStartTime = DateTime.now();
            _addLog('🔍 Started sensor scanning...');
          }
          if (_bleScanningService.discoveredDevicesCount !=
              _scannedDevicesCount) {
            _scannedDevicesCount = _bleScanningService.discoveredDevicesCount;
            _addLog('📱 Found new sensor (Total: $_scannedDevicesCount)');
          }
          break;
        case BleScanningState.uploading:
          _addLog('📤 Uploading scan results to endpoint...');
          break;
        case BleScanningState.success:
          _uploadedDevicesCount++;
          _addLog('✅ Successfully uploaded device data');
          break;
        case BleScanningState.error:
          _addLog('❌ Error occurred during scanning or upload');
          break;
      }
    });
  }

  void _addFinalReport() {
    if (_scanStartTime != null) {
      final duration = DateTime.now().difference(_scanStartTime!);
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;

      _addLog('⏱️ Scan duration: ${minutes}m ${seconds}s');
      _addLog('📱 Sensors found: $_scannedDevicesCount');
      _addLog('✅ Successfully uploaded: $_uploadedDevicesCount');
    }
  }

  void _startScanning() {
    _bleScanningService.startScanning();
  }

  void _stopScanning() {
    _bleScanningService.stopScanning();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TbAppBar(tbContext, title: Text(S.of(context).sensorScanner), elevation: 1),
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
                        Icon(_getStatusIcon(), color: _getStatusColor()),
                        const SizedBox(width: 8),
                        Text(
                          _getStatusText(),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (_bleScanningService.state ==
                            BleScanningState.scanning)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              '($_scannedDevicesCount found)',
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
                    if (_bleScanningService.state ==
                            BleScanningState.scanning ||
                        _bleScanningService.state == BleScanningState.uploading)
                      LinearProgressIndicator(
                        color:
                            _bleScanningService.state ==
                                    BleScanningState.uploading
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
                        _bleScanningService.state == BleScanningState.idle
                            ? _startScanning
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
                        _bleScanningService.state == BleScanningState.scanning
                            ? _stopScanning
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
                          _scanLogs.isEmpty
                              ? Center(
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
                              : ListView.builder(
                                padding: const EdgeInsets.all(8.0),
                                itemCount: _scanLogs.length,
                                itemBuilder: (context, index) {
                                  final log = _scanLogs[_scanLogs.length - 1 - index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 16,
                                          margin: const EdgeInsets.only(right: 8, top: 2),
                                          decoration: BoxDecoration(
                                            color: _getLogColor(log),
                                            borderRadius: BorderRadius.circular(2),
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

  IconData _getStatusIcon() {
    switch (_bleScanningService.state) {
      case BleScanningState.idle:
        return Icons.radar;
      case BleScanningState.scanning:
        return Icons.search;
      case BleScanningState.uploading:
        return Icons.cloud_upload;
      case BleScanningState.success:
        return Icons.check_circle;
      case BleScanningState.error:
        return Icons.error;
    }
  }

  Color _getStatusColor() {
    switch (_bleScanningService.state) {
      case BleScanningState.idle:
        return Colors.grey;
      case BleScanningState.scanning:
        return Colors.blue;
      case BleScanningState.uploading:
        return Colors.orange;
      case BleScanningState.success:
        return Colors.green;
      case BleScanningState.error:
        return Colors.red;
    }
  }

  String _getStatusText() {
    switch (_bleScanningService.state) {
      case BleScanningState.idle:
        return 'Sensor Scanner Ready';
      case BleScanningState.scanning:
        return 'Scanning for sensors...';
      case BleScanningState.uploading:
        return 'Uploading scan results...';
      case BleScanningState.success:
        return 'Upload completed successfully';
      case BleScanningState.error:
        return 'Error occurred during scanning';
    }
  }

  @override
  void initState() {
    super.initState();
    _bleScanningService = BleScanningService();
    _bleScanningService.setContext(tbContext);
    _bleScanningService.addListener(_onScanningStateChanged);
    _bleScanningService.setLogCallback(_addLog);
    _addLog('Sensor Scanner initialized');
  }

  @override
  void dispose() {
    _bleScanningService.removeListener(_onScanningStateChanged);
    _bleScanningService.setLogCallback(null);
    super.dispose();
  }
}
