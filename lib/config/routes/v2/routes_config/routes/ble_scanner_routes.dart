import 'package:go_router/go_router.dart';
import 'package:thingsboard_app/modules/ble/ble_scanning_page.dart';

class BleScannerRoutes {
  /// Path of the custom page in the mobile center of the server. Changing it
  /// here means changing it there.
  static const bleScanner = '/ble-scanner';
}

// BlueStar sensor scanner routes
final bleScannerRoutes = [
  GoRoute(
    path: BleScannerRoutes.bleScanner,
    builder: (context, state) => const BleScanningPage(),
  ),
];
