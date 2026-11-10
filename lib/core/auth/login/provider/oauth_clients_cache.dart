import 'dart:convert';

import 'package:thingsboard_app/thingsboard_client.dart';

/// Remembers the OAuth2 clients of the last successful server response, so
/// the login screen can still offer them when the server cannot be reached.
///
/// There is deliberately no hard-coded fallback client: the authorization URL
/// contains the id of the client registration on the server, so a fixed URL
/// goes stale as soon as that registration changes.
class OAuthClientsCache {
  const OAuthClientsCache(this._storage);

  final TbStorage _storage;

  static const _storageKey = 'cached_oauth_clients';

  Future<void> save(List<OAuth2ClientInfo> clients) async {
    try {
      final json =
          clients
              .map((c) => {'name': c.name, 'url': c.url, 'icon': c.icon})
              .toList();
      await _storage.setItem(_storageKey, jsonEncode(json));
    } catch (_) {
      // The cache is a convenience: never let it break the login flow.
    }
  }

  Future<List<OAuth2ClientInfo>> load() async {
    try {
      final cached = await _storage.getItem(_storageKey);
      if (cached is String) {
        return (jsonDecode(cached) as List)
            .map((c) => OAuth2ClientInfo.fromJson(c as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // An unreadable cache is the same as no cache.
    }
    return [];
  }
}
