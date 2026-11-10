# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BlueStar is de mobiele app van NauticSensors voor Android en iOS: een fork van de ThingsBoard-app (`thingsboard/flutter_thingsboard_app`) voor het bekijken en beheren van sensoren aan boord.

Deze repository is openbaar. Commit geen secrets: geen `configs.json`, geen `android/key.properties`, geen keystores en geen sleutels in de broncode.

## Branches

`bluestar-1.8` is upstream `v.1.8.1` met daarbovenop de BlueStar-patchset, één commit per onderwerp. Houd de patchset klein: raak upstream-bestanden alleen waar het moet, zodat een volgende upstream-versie makkelijk te volgen is.

Remotes: `origin` is de fork, `upstream` is ThingsBoard.

## Development Commands

Flutter loopt via fvm (versie in `.fvmrc`).

```bash
fvm flutter pub get
fvm flutter analyze
fvm flutter run --dart-define-from-file configs.json
fvm flutter build apk --debug --dart-define-from-file configs.json
fvm flutter build appbundle --dart-define-from-file configs.json
fvm flutter build ipa --dart-define-from-file configs.json
```

Gegenereerde code staat in git. Draai de generator na een wijziging en commit het resultaat mee:

```bash
# Riverpod-providers, freezed, json_serializable
fvm dart run build_runner build --delete-conflicting-outputs

# Vertalingen (lib/l10n/*.arb -> lib/generated)
fvm dart run intl_utils:generate
```

`build_runner` herschrijft ook de hash in `login_provider.g.dart` en `noauth_provider.g.dart`, die upstream niet heeft bijgewerkt. Zet die twee terug als je ze niet hebt aangeraakt.

## Configuratie

De app leest zijn instellingen bij het bouwen uit een JSON-bestand met dart-defines. Kopieer `configs.sample.json` naar `configs.json` (staat in `.gitignore`) en vul de waarden in:

| Sleutel | Waarvoor |
|---|---|
| `thingsboardApiEndpoint` | adres van de ThingsBoard-server |
| `thingsboardAndroidAppSecret`, `thingsboardIosAppSecret` | app-secrets uit het mobile center van de server |
| `thingsboardOAuth2CallbackUrlScheme` | terugkeerschema van de OAuth-login |
| `androidApplicationId`, `androidApplicationName`, `iosApplicationId`, `iosApplicationName` | pakketnaam en naam van de app |
| `appLinksUrlHost`, `appLinksUrlScheme` | app-links |
| `bleUploadApiKey` | api-key voor de upload van de sensorscanner; zonder sleutel stuurt de upload alleen het toegangstoken van de gebruiker mee |

Android-releases worden ondertekend met de keystore uit `android/key.properties` (`storeFile`, `storePassword`, `keyAlias`, `keyPassword`). Zonder dat bestand tekent Gradle met de debug-sleutel en meldt dat in de build-uitvoer.

## Architectuur

- **Framework:** Flutter, Dart SDK ^3.7.0.
- **Backend:** ThingsBoard via het pakket `thingsboard_client`; de client komt uit `getIt<ITbClientService>().client`.
- **Routes:** go_router, per onderwerp een bestand in `lib/config/routes/v2/routes_config/routes/`.
- **State:** Riverpod-providers (`*_provider.dart` met gegenereerde `*.g.dart`), diensten in de service-locator `lib/locator.dart`.
- **Pushmeldingen:** Firebase, project `bluestar-nauticsensors`.

## BlueStar-onderdelen

| Onderdeel | Waar |
|---|---|
| Alleen-OAuth-login met de knop "NauticSensors ID" | `lib/core/auth/login/widgets/login_widget.dart`, `o_auth_buttons.dart` |
| Cache van OAuth-clients | `lib/core/auth/login/provider/oauth_clients_cache.dart`, `oauth_provider.dart` |
| Sensorscanner (`/ble-scanner`) | `lib/modules/ble/`, `lib/utils/services/ble_scanning/` |
| Doorverwijzen (`/referral`) | `lib/modules/referral/`, zie `docs/referral-page.md` |
| Eigen configuratie | `lib/constants/bluestar_constants.dart` |
| Huisstijl | `assets/branding/`, `assets/images/bluestar*.svg`, `lib/constants/assets_path.dart` |
| Eigen vertaalsleutels | onderaan `lib/l10n/intl_en.arb` en `lib/l10n/intl_nl_NL.arb` |

### Pagina's uit het mobile center

Het menu van de app komt van de server (mobile center, bundel van de app). Een pagina van het type "Custom" heeft een pad; de app moet voor dat pad een GoRoute hebben, anders opent de pagina niet. BlueStar kent twee eigen paden:

- `/ble-scanner`: de sensorscanner;
- `/referral`: doorverwijzen.

De routes staan in `ble_scanner_routes.dart` en `referral_routes.dart` en zijn opgenomen in `allMainPages` in `main_routes.dart`. Wijzig een pad alleen samen met de instelling op de server.

### Sensorscanner

`BleScanningService` scant naar BLE-sensoren en uploadt hun advertenties naar de NauticSensors-backend. De dienst kent de ThingsBoard-client niet: wie er is ingelogd komt binnen via de interface `BleUploadSession`, met `TbClientBleUploadSession` als implementatie. De upload stuurt de api-key uit de configuratie en het toegangstoken van de ingelogde gebruiker mee.

### Vertalingen

De vertalingen komen van upstream. Voeg eigen sleutels alleen toe aan `intl_en.arb` en `intl_nl_NL.arb`; andere talen vallen voor die sleutels terug op het Engels.
