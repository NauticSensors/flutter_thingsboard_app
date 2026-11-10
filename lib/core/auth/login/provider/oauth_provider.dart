import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:thingsboard_app/core/auth/login/provider/oauth_clients_cache.dart';
import 'package:thingsboard_app/locator.dart';
import 'package:thingsboard_app/thingsboard_client.dart';
import 'package:thingsboard_app/utils/services/device_info/i_device_info_service.dart';
import 'package:thingsboard_app/utils/services/tb_client_service/i_tb_client_service.dart';

part 'oauth_provider.g.dart';

/// The OAuth2 clients the server offers this app, or the cached clients of the
/// last successful response when the server cannot be reached. BlueStar signs
/// in through OAuth2 only, so upstream's QR code pseudo-client is not added to
/// the list.
@riverpod
Future<LoginMobileInfo> oauth(Ref ref) async {
  final tbClient = getIt<ITbClientService>().client;
  final deviceInfoService = getIt<IDeviceInfoService>();
  final cache = OAuthClientsCache(getIt<TbStorage>());
  try {
    final loginInfo = await tbClient.getMobileService().getLoginMobileInfo(
      MobileInfoQuery(
        packageName: deviceInfoService.getApplicationId(),
        platformType: deviceInfoService.getPlatformType(),
      ),
    );

    if (loginInfo != null) {
      await cache.save(loginInfo.oAuth2Clients);
      return loginInfo;
    }
  } catch (_) {}
  // The server gave no answer: offer the clients of the last successful
  // response, so the login button does not disappear on a flaky connection.
  return LoginMobileInfo(
    oAuth2Clients: await cache.load(),
    storeInfo: null,
    versionInfo: null,
  );
}
