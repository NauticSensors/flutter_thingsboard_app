import 'package:fluro/fluro.dart';
import 'package:thingsboard_app/config/routes/tb_routes.dart';
import 'package:thingsboard_app/modules/referral/presentation/view/referral_page.dart';

class ReferralRoutes extends TbRoutes {
  ReferralRoutes(super.tbContext);

  static const referralRoute = '/referral';

  late final referralHandler = Handler(
    handlerFunc: (context, params) {
      return ReferralPage(tbContext);
    },
  );

  @override
  void doRegisterRoutes(FluroRouter router) {
    router.define(referralRoute, handler: referralHandler);
  }
}
