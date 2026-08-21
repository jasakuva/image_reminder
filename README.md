# Picture Reminder

Picture Reminder is a Flutter app for Android, iOS, and Windows that lets users create reminders from pictures and screenshots stored locally on the device.

When a reminder fires, the app shows a local notification. Tapping the notification opens the related reminder inside the app.

## Current Status

The app is implemented and actively evolving.

Current implemented areas include:

- Reminder list, detail, create, snooze, complete, and delete flows
- Local image import and camera/photo picking flow
- Local notifications with tap-to-open reminder behavior
- Reminder sound mode selection (`Notification` / `Alarm`)
- Free vs premium reminder gating
- Simulated premium unlock and in-app purchase groundwork
- Settings and info screen
- App localization
- iOS shared image / pending reminder import groundwork

## Current Features

- Create a reminder from an imported image or photo
- Store reminder data locally on device
- Store image files locally in app-managed storage
- View reminders in a sorted list
- Open reminder detail screen with full image
- Mark reminders as done
- Snooze reminders for:
  - 5 minutes
  - 10 minutes
  - 1 hour
  - tomorrow
- Delete reminders and associated local image files
- Open reminder detail from notification tap
- Choose app language from settings
- Premium/free gating for active reminder count

## Supported Languages

- English
- Finnish (`Suomi`)
- Swedish (`Svenska`)
- Japanese (`日本語`)
- German (`Deutsch`)

## Premium Status

The app currently includes premium access groundwork and simulated unlock support.

- Free plan allows up to 2 active reminders
- Premium removes the active reminder limit
- Premium can currently be simulated/tested in app
- Paid version was simulated and tested on iOS, not on Android yet

## Target Platforms

- Android
- iOS
- Windows

## Current Technical Approach

- Flutter app with feature-oriented structure
- Local-first storage
- Reminder persistence currently uses `SharedPreferences` with JSON serialization
- Images stored as files in local app storage
- Local notifications via `flutter_local_notifications`
- Localization via Flutter gen-l10n
- Simple app state with `ChangeNotifier` / `ValueNotifier`

## Build Information

The Settings & Info screen displays build metadata from compile-time Dart defines:

- `APP_VERSION`
- `BUILD_NUMBER`
- `BUILD_DATE`
- `GIT_COMMIT`

For a release build, inject the actual build date and commit explicitly:

```bash
flutter build ios \
  --dart-define=APP_VERSION=1.0.0 \
  --dart-define=BUILD_NUMBER=1 \
  --dart-define=BUILD_DATE="$(date -u +%Y-%m-%d)" \
  --dart-define=GIT_COMMIT="$(git rev-parse --short HEAD)"
```

The source fallback is `2026-08-21`, so development builds no longer display
`Local development build`.

## Main Dependencies In Use

Key current dependencies from `pubspec.yaml`:

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  image_picker: ^1.2.3
  path_provider: ^2.1.6
  shared_preferences: ^2.5.5
  in_app_purchase: ^3.3.0
  uuid: ^4.6.0
  intl: ^0.20.3
  flutter_local_notifications: ^22.3.0
  timezone: ^0.11.1
  flutter_timezone: ^5.1.0
```

## Project Structure

Main app areas:

```text
lib/
  app.dart
  main.dart
  l10n/
  core/
  features/
    billing/
    images/
    notifications/
    reminders/
    settings/
    share/
```

## Documentation

- [SPEC.md](SPEC.md) — current product/feature specification
- [PLAN.md](PLAN.md) — implemented work and next steps
- [ARCHITECTURE.md](ARCHITECTURE.md) — current technical structure
- [BACKLOG.md](BACKLOG.md) — remaining prioritized work
- [DECISIONS.md](DECISIONS.md) — current implementation decisions

## Platform Notes

### Android

- Local notifications are implemented
- Premium purchase flow has groundwork, but paid version has not yet been fully validated on Android

### iOS

- Local notifications are implemented
- Premium simulation has been tested
- Shared image / pending reminder import support has groundwork in place

### Windows

- Project exists and builds as a target platform
- Mobile-specific image and notification behavior still needs more platform-specific validation

## Privacy

The app is local-first.

- No user accounts
- No cloud sync
- No backend required
- Reminder data and images stay on the user's device