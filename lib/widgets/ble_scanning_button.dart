import 'package:flutter/material.dart';
import 'package:thingsboard_app/core/context/tb_context.dart';
import 'package:thingsboard_app/utils/services/ble_scanning/ble_scanning_service.dart';

class BleScanningButton extends StatefulWidget {
  final TbContext tbContext;
  
  const BleScanningButton({
    Key? key,
    required this.tbContext,
  }) : super(key: key);

  @override
  State<BleScanningButton> createState() => _BleScanningButtonState();
}

class _BleScanningButtonState extends State<BleScanningButton> 
    with SingleTickerProviderStateMixin {
  
  late final BleScanningService _bleScanningService;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _bleScanningService = BleScanningService();
    _bleScanningService.setContext(widget.tbContext);
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _bleScanningService.addListener(_onScanningStateChanged);
  }

  @override
  void dispose() {
    _bleScanningService.removeListener(_onScanningStateChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onScanningStateChanged() {
    if (mounted) {
      setState(() {
        if (_bleScanningService.state == BleScanningState.scanning) {
          _animationController.repeat();
        } else {
          _animationController.stop();
        }
      });
    }
  }

  void _onButtonPressed() {
    switch (_bleScanningService.state) {
      case BleScanningState.idle:
        _bleScanningService.startScanning();
        break;
      case BleScanningState.scanning:
        _bleScanningService.stopScanning();
        break;
      case BleScanningState.uploading:
        break;
      case BleScanningState.error:
        _bleScanningService.clearError();
        break;
    }
  }

  Widget _buildIcon() {
    switch (_bleScanningService.state) {
      case BleScanningState.idle:
        return Icon(
          Icons.radar,
          size: 20,
          color: _getBorderColor(),
        );
      case BleScanningState.scanning:
        return RotationTransition(
          turns: _animationController,
          child: Icon(
            Icons.radar,
            size: 20,
            color: _getBorderColor(),
          ),
        );
      case BleScanningState.uploading:
        return SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(_getBorderColor()),
          ),
        );
      case BleScanningState.error:
        return Icon(
          Icons.sensors_off,
          size: 20,
          color: _getBorderColor(),
        );
    }
  }

  Color _getBorderColor() {
    switch (_bleScanningService.state) {
      case BleScanningState.idle:
        return Theme.of(context).colorScheme.primary;
      case BleScanningState.scanning:
        return Colors.orange;
      case BleScanningState.uploading:
        return Colors.blue;
      case BleScanningState.error:
        return Colors.red;
    }
  }

  String _getTooltip() {
    switch (_bleScanningService.state) {
      case BleScanningState.idle:
        return 'Scan for Sensors';
      case BleScanningState.scanning:
        return 'Stop Sensor Scanning';
      case BleScanningState.uploading:
        return 'Uploading Sensor Data';
      case BleScanningState.error:
        return 'Sensor Scanning Error - Tap to retry';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Tooltip(
        message: _getTooltip(),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _onButtonPressed,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: _getBorderColor(),
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _getBorderColor().withOpacity(0.2),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Center(
                child: _buildIcon(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}