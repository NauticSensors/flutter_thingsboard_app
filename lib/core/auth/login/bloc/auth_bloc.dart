import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thingsboard_app/config/routes/router.dart';
import 'package:thingsboard_app/core/auth/login/bloc/bloc.dart';
import 'package:thingsboard_app/locator.dart';
import 'package:thingsboard_app/modules/version/route/version_route.dart';
import 'package:thingsboard_app/modules/version/route/version_route_arguments.dart';
import 'package:thingsboard_app/thingsboard_client.dart';
import 'package:thingsboard_app/utils/services/device_info/i_device_info_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this.tbClient,
    required this.deviceService,
  }) : super(const AuthLoadingState()) {
    on(_onEvent);
  }
  final IDeviceInfoService deviceService;
  final ThingsboardClient tbClient;
  final ThingsboardAppRouter router = getIt();
  
  static const String _oauthClientsStorageKey = 'cached_oauth_clients';
  Future<void> _onEvent(AuthEvent event, Emitter<AuthState> emit) async {
    switch (event) {
      case AuthFetchEvent():
        try {
          final loginInfo =
              await tbClient.getMobileService().getLoginMobileInfo(
                    MobileInfoQuery(
                      packageName: event.packageName,
                      platformType: event.platformType,
                    ),
                  );

          if (loginInfo != null) {
            final versionInfo = loginInfo.versionInfo;
            if (versionInfo != null) {
              if (deviceService.getAppVersion().versionInt() <
                  (versionInfo.minVersion?.versionInt() ?? 0)) {
                router.navigateTo(
                  VersionRoutes.updateRequiredRoutePath,
                  clearStack: true,
                  replace: true,
                  routeSettings: RouteSettings(
                    arguments: VersionRouteArguments(
                      versionInfo: versionInfo,
                      storeInfo: loginInfo.storeInfo,
                    ),
                  ),
                );
                return;
              }
            }

            // Cache the OAuth clients for offline use
            await _cacheOAuthClients(loginInfo.oAuth2Clients);
            emit(AuthDataState(oAuthClients: loginInfo.oAuth2Clients));
          } else {
            // Try to load from cache if server response is null
            final cachedClients = await _loadCachedOAuthClients();
            emit(AuthDataState(oAuthClients: cachedClients));
          }
        } catch (_) {
          // If server fetch fails, try to load from cache or use fallback
          final cachedClients = await _loadCachedOAuthClients();
          final fallbackClients = cachedClients.isEmpty ? _getFallbackOAuthClients() : cachedClients;
          emit(AuthDataState(oAuthClients: fallbackClients));
        }

    }
  }

  Future<void> _cacheOAuthClients(List<OAuth2ClientInfo> clients) async {
    try {
      final storage = getIt<TbStorage>();
      final clientsJson = clients.map((client) => {
        'name': client.name,
        'url': client.url,
        'icon': client.icon,
      }).toList();
      
      await storage.setItem(_oauthClientsStorageKey, jsonEncode(clientsJson));
    } catch (e) {
      // Ignore caching errors to avoid breaking the login flow
    }
  }

  Future<List<OAuth2ClientInfo>> _loadCachedOAuthClients() async {
    try {
      final storage = getIt<TbStorage>();
      final cachedData = await storage.getItem(_oauthClientsStorageKey);
      
      if (cachedData != null && cachedData is String) {
        final clientsJson = jsonDecode(cachedData) as List;
        return clientsJson.map((clientMap) {
          final clientData = clientMap as Map<String, dynamic>;
          return OAuth2ClientInfo.fromJson({
            'name': clientData['name'] as String,
            'url': clientData['url'] as String,
            'icon': clientData['icon'] as String?,
          });
        }).toList();
      }
    } catch (e) {
      // Ignore cache loading errors
    }
    
    return [];
  }

  List<OAuth2ClientInfo> _getFallbackOAuthClients() {
    // Return hardcoded NauticSensors ID client as fallback
    return [
      OAuth2ClientInfo.fromJson({
        'name': 'NauticSensors ID',
        'url': '/oauth2/authorization/nautic-sensors',
        'icon': null,
      }),
    ];
  }
}
