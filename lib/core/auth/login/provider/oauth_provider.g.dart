// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oauth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$oauthHash() => r'09cf929ff3855144ce0557994060d3e5f1a7e790';

/// The OAuth2 clients the server offers this app, or the cached clients of the
/// last successful response when the server cannot be reached. BlueStar signs
/// in through OAuth2 only, so upstream's QR code pseudo-client is not added to
/// the list.
///
/// Copied from [oauth].
@ProviderFor(oauth)
final oauthProvider = AutoDisposeFutureProvider<LoginMobileInfo>.internal(
  oauth,
  name: r'oauthProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$oauthHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OauthRef = AutoDisposeFutureProviderRef<LoginMobileInfo>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
