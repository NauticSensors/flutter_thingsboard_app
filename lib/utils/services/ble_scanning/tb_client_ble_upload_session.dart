import 'package:thingsboard_app/thingsboard_client.dart';
import 'package:thingsboard_app/utils/services/ble_scanning/ble_upload_session.dart';
import 'package:thingsboard_app/utils/services/tb_client_service/i_tb_client_service.dart';

/// [BleUploadSession] on top of the app's ThingsBoard client.
class TbClientBleUploadSession implements BleUploadSession {
  const TbClientBleUploadSession(this._clientService);

  final ITbClientService _clientService;

  @override
  Future<BleUploadIdentity> currentIdentity() async {
    // Always ask the service: the client is replaced when the endpoint changes.
    final client = _clientService.client;

    String? email;
    try {
      // Loading the user goes through the client's interceptor, which also
      // refreshes an expired access token. Errors stay silent: an upload in
      // the background must not raise notifications.
      final user = await client.getUserService().getUser(
        requestConfig: RequestConfig(ignoreErrors: true, ignoreLoading: true),
      );
      email = user.email;
    } catch (_) {
      // Offline or signed out: fall back to the subject of the stored token,
      // which is the email address of the user.
      email = client.getAuthUser()?.sub;
    }

    return BleUploadIdentity(
      email: email,
      accessToken: client.isJwtTokenValid() ? client.getJwtToken() : null,
    );
  }
}
