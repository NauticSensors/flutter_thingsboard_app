/// BlueStar specific configuration. Build-time values come from the same
/// `--dart-define-from-file` JSON as `ThingsboardAppConstants`
/// (see `configs.sample.json`).
abstract final class BlueStarConstants {
  /// NauticSensors backend endpoint that takes the results of the sensor
  /// scanner.
  static const bleUploadUrl =
      'https://api.nauticsensors.com/api/v1/webhooks/bluestar-app/ingress';

  /// API key for [bleUploadUrl], `bleUploadApiKey` in the configuration file.
  /// Empty when not configured: the upload then identifies itself with the
  /// access token of the signed-in user only.
  static const bleUploadApiKey = String.fromEnvironment('bleUploadApiKey');
}
