# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter mobiele applicatie voor het monitoren en beheren van IoT devices via ThingsBoard.

## Development Commands

```bash
fvm flutter pub get    # Install dependencies
fvm flutter run        # Run on connected device/emulator
fvm flutter build apk  # Build Android APK
fvm flutter build ios  # Build iOS app
```

Run en build hebben `--dart-define-from-file=configs.json` nodig (`configs.json` staat niet in git, zie `configs.sample.json`): bundle-id, callback-schema en app-secret komen eruit, en zonder weigert ThingsBoard de login. De app praat met productie.

De BlueStar-versie die in de winkels staat komt van de branch `bluestar-1.7.0`, niet van `master`.

## Inloggen en registreren

De login loopt via ThingsBoard naar Keycloak; de pagina's daar komen uit het repo `keycloak-theme`. Hoe de flow loopt, hoe je hem in een simulator test en wat er nog openstaat: [docs/registratieflow.md](docs/registratieflow.md).

## Architecture

- **Framework:** Flutter (Dart SDK ^3.7.0)
- **Backend:** ThingsBoard via `thingsboard_client` SDK
- **Features:**
  - Device monitoring en control
  - Real-time telemetry
  - Push notifications (Firebase)
  - GPS locatie

## Relatie tot Andere Projecten

Verbindt met het `thingsboard` project voor backend API.
