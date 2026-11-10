import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thingsboard_app/locator.dart';
import 'package:thingsboard_app/thingsboard_client.dart';
import 'package:thingsboard_app/utils/services/device_info/i_device_info_service.dart';
import 'package:thingsboard_app/utils/services/tb_client_service/i_tb_client_service.dart';

part 'oauth_provider.g.dart';

/// The OAuth2 clients the server offers this app. BlueStar signs in through
/// OAuth2 only, so upstream's QR code pseudo-client is not added to the list.
@riverpod
Future<LoginMobileInfo> oauth(Ref ref) async {
  final tbClient = getIt<ITbClientService>().client;
  final deviceInfoService = getIt<IDeviceInfoService>();
  try {
    final loginInfo = await tbClient.getMobileService().getLoginMobileInfo(
      MobileInfoQuery(
        packageName: deviceInfoService.getApplicationId(),
        platformType: deviceInfoService.getPlatformType(),
      ),
    );

    if (loginInfo != null) {
      return loginInfo;
    }
  } catch (_) {}
  return const LoginMobileInfo(
    oAuth2Clients: [],
    storeInfo: null,
    versionInfo: null,
  );
}
