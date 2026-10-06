# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BoboBidou is a Flutter health-tracking app that helps users correlate meals (with ingredient tracking) and pain episodes. Key features: meal/pain logging, AI-powered food recognition via camera, ingredient correlation analysis, timeline visualization, Google OAuth authentication, and English/French localization.

## Common Commands

```bash
# Run the app
flutter run

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Lint / static analysis
flutter analyze

# Regenerate app icons (after changing assets/icon/logo.jpg)
flutter pub run flutter_launcher_icons:main

# Regenerate splash screen (after changing flutter_native_splash.yaml)
flutter pub run flutter_native_splash:create

# Get dependencies
flutter pub get

# Build the Play Store bundle (needs android/key.properties, see below)
flutter build appbundle --release
```

### Release signing

Release builds are signed with the upload keystore described in `android/key.properties` (git-ignored, like `*.jks`). Without this file the release build falls back to the debug keys, which Google Play refuses.

```bash
# One-time: create the upload keystore (keep it and its passwords safe, outside the repo)
keytool -genkey -v -keystore ~/bobobidou-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

```properties
# android/key.properties
storePassword=<keystore password>
keyPassword=<key password>
keyAlias=upload
storeFile=/absolute/path/to/bobobidou-upload.jks
```

## Architecture

**State management:** Provider (`ChangeNotifier` + `MultiProvider`). All providers are registered in `lib/main.dart`. Business logic lives in providers; pages consume them via `context.watch<>()` / `context.read<>()`.

**Data layer:** SQLite via `sqflite`. Single singleton `DatabaseHelper.instance` in `lib/services/db_helper.dart`. Current schema version is 2 (v1→v2 migration splits comma-separated ingredients into a relational `meal_ingredients` junction table).

**Navigation:** Vanilla `Navigator.push()` — no routing library. `HomePage` is the root with two tabs (Meals, Pain Events). Other screens push on top of it.

**Backend:** `https://kellyroussel-backend.onrender.com` — Google OAuth flow and AI ingredient recognition from images. The URL is hardcoded in `auth_service.dart`, `food_recognition_service.dart`, and the warmup call in `main.dart`.

## Key Directories

| Path | Purpose |
|------|---------|
| `lib/models/` | Data models (`Meal`, `PainEvent`, `Ingredient`, `User`) with `fromMap()`/`toMap()` |
| `lib/services/` | `db_helper.dart` (SQLite), `auth_service.dart` (Google OAuth), `food_recognition_service.dart` (image → ingredients) |
| `lib/providers/` | All `ChangeNotifier` providers: meals, pain, analysis, auth, theme, locale |
| `lib/pages/` | UI pages; `home_page/` is tab-based, `analysis_page/` contains graphs |
| `lib/l10n/` | `AppLocalizations` — loads `assets/lang/en.json` or `fr.json` at runtime |
| `assets/lang/` | Translation JSON files (keys use `snake_case`) |

## Important Patterns

**Localization:** Access via `AppLocalizations.of(context).translate('key')`. All UI strings must be added to both `assets/lang/en.json` and `assets/lang/fr.json`.

**Database datetime:** Store as ISO8601 strings (`dateTime.toIso8601String()`). Parse with `DateTime.parse(map['dateTime'])`. Recent fixes (see commits `f9c0bfe`, `4d2653d`) addressed a bug where datetimes weren't defaulting to now.

**Analysis algorithm** (`lib/providers/analysis_provider.dart`): For each pain event, looks 48 hours back, counts ingredient occurrences across all meals in that window → `Map<String, int>` of ingredient involvement scores. Temporal data is filtered to last 14 days.

**Theme:** 4 built-in themes (Purple, Green, Blue, LogoInspired). Theme state is in-memory only — not persisted across restarts.

**Authentication flow:** User triggers camera → `AuthProvider.isAuthenticated` check → if false, OAuth dance via backend → `FlutterWebAuth2` → token stored in `SharedPreferences` → proceed with image upload.
