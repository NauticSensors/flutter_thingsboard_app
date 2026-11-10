/// The signed-in user on whose behalf scan results are uploaded.
class BleUploadIdentity {
  const BleUploadIdentity({this.email, this.accessToken});

  /// Email address of the user, or null when unknown.
  final String? email;

  /// A currently valid ThingsBoard access token (JWT) of the user, or null
  /// when there is none.
  final String? accessToken;
}

/// The only thing the sensor scanner needs from the rest of the app: who is
/// signed in right now.
///
/// `BleScanningService` depends on this interface instead of on the
/// ThingsBoard client, so the scanner does not change when the app changes
/// the way it holds its session.
abstract interface class BleUploadSession {
  Future<BleUploadIdentity> currentIdentity();
}
