import 'package:go_router/go_router.dart';
import 'package:thingsboard_app/modules/referral/presentation/view/referral_page.dart';

class ReferralRoutes {
  /// Path of the custom page in the mobile center of the server. Changing it
  /// here means changing it there.
  static const referral = '/referral';
}

// BlueStar referral page routes
final referralRoutes = [
  GoRoute(
    path: ReferralRoutes.referral,
    builder: (context, state) => const ReferralPage(),
  ),
];
