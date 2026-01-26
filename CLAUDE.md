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
