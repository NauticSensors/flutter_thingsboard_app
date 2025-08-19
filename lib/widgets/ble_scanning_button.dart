import 'package:flutter/material.dart';
import 'package:thingsboard_app/generated/l10n.dart';
import 'package:thingsboard_app/core/context/tb_context.dart';
import 'package:thingsboard_app/utils/services/ble_scanning/ble_scanning_service.dart';

class BleScanningButton extends StatefulWidget {
  final TbContext tbContext;

  const BleScanningButton({Key? key, required this.tbContext})
    : super(key: key);

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
      case BleScanningState.success:
        _bleScanningService.clearSuccess();
        break;
      case BleScanningState.error:
        _bleScanningService.clearError();
        break;
    }
  }

  Widget _buildContent(BuildContext context) {
    switch (_bleScanningService.state) {
      case BleScanningState.idle:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.radar, size: 18, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              S.of(context).scan,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );

      case BleScanningState.scanning:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RotationTransition(
              turns: _animationController,
              child: const Icon(Icons.radar, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 6),
            Text(
              '${_bleScanningService.discoveredDevicesCount}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );

      case BleScanningState.uploading:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 6),
            Text(
              S.of(context).uploading,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );

      case BleScanningState.success:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 18, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              '${_bleScanningService.discoveredDevicesCount} ${S.of(context).found}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );

      case BleScanningState.error:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 18, color: Colors.white),
            SizedBox(width: 6),
            Text(
              S.of(context).error,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
    }
  }

  Color _getBackgroundColor() {
    switch (_bleScanningService.state) {
      case BleScanningState.idle:
        return Theme.of(context).colorScheme.primary;
      case BleScanningState.scanning:
        return Colors.orange;
      case BleScanningState.uploading:
        return Colors.blue;
      case BleScanningState.success:
        return Colors.green;
      case BleScanningState.error:
        return Colors.red;
    }
  }

  String _getTooltip() {
    switch (_bleScanningService.state) {
      case BleScanningState.idle:
        return S.of(context).scanButtonTooltipIdle;
      case BleScanningState.scanning:
        return S.of(context).scanButtonTooltipScanning;
      case BleScanningState.uploading:
        return S.of(context).scanButtonTooltipUploading;
      case BleScanningState.success:
        return S.of(context).scanButtonTooltipSuccess;
      case BleScanningState.error:
        return S.of(context).scanButtonTooltipError;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Tooltip(
        message: _getTooltip(),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap:
                _bleScanningService.state != BleScanningState.uploading
                    ? _onButtonPressed
                    : null,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _getBackgroundColor().withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildContent(context),
            ),
          ),
        ),
      ),
    );
  }
}
