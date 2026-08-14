# Picture Reminder

Picture Reminder is a planned Flutter app for Android, iOS, and Windows.

The app lets users save or take a picture and create a reminder connected to that picture. When the reminder time arrives, the app shows a local notification. Tapping the notification opens the related picture inside the app.

## Main Features

- Take a photo and attach it to a reminder.
- Import an existing image or screenshot.
- Store all data locally on the device.
- Create multiple picture reminders.
- Schedule reminders for exact date/time.
- Use quick reminder options such as `after 1 hour` or `tomorrow`.
- Snooze reminders and be reminded again later.
- Mark reminders as done.
- Delete reminders and their stored images.

## Target Platforms

- Android
- iOS
- Windows

## Current Status

This repository currently contains planning and specification documents.

The Flutter application has not been generated yet.

## Documentation

- [SPEC.md](SPEC.md) — product and technical specification.
- [PLAN.md](PLAN.md) — implementation roadmap.
- [ARCHITECTURE.md](ARCHITECTURE.md) — proposed technical architecture.
- [BACKLOG.md](BACKLOG.md) — prioritized feature backlog.
- [DECISIONS.md](DECISIONS.md) — technical decisions and open questions.

## Recommended MVP

The first version should focus on Android first, then expand to iOS and Windows.

MVP features:

1. Import image.
2. Save image locally.
3. Create reminder with date/time.
4. Store reminder locally.
5. Schedule local notification.
6. Open reminder detail from notification tap.
7. Snooze reminder from inside app.
8. Mark reminder as done.
9. Delete reminder and image.

## Future Flutter Setup

When implementation starts, create the Flutter app in this folder:

```bash
flutter create --platforms=android,ios,windows .
```

Then verify available devices:

```bash
flutter devices
```

Run on Windows:

```bash
flutter run -d windows
```

Run on Android:

```bash
flutter run -d android
```

## Suggested Initial Dependencies

Exact versions should be selected during implementation.

Likely packages:

```yaml
dependencies:
  flutter_local_notifications: any
  timezone: any
  path_provider: any
  permission_handler: any
  image_picker: any
  file_picker: any
  flutter_image_compress: any
  uuid: any
```

Recommended database option:

```yaml
dependencies:
  drift: any
  sqlite3_flutter_libs: any
  path: any

dev_dependencies:
  drift_dev: any
  build_runner: any
```

Do not keep `any` versions permanently. Pin versions once packages are added.

## Important Platform Notes

### Android

- Android 13+ requires notification permission.
- Exact reminder timing may require exact alarm permission.
- Battery optimization can delay reminders on some devices.

### iOS

- Local notification permission is required.
- iOS limits background processing.
- Complex snooze actions from notifications may need native notification categories.

### Windows

- Local storage is straightforward.
- Notifications while app is fully closed may need extra Windows-specific work.

## Privacy

The app should be local-first.

- No user accounts for MVP.
- No cloud storage for MVP.
- No analytics for MVP unless explicitly added later.
- Pictures remain on the user's device.
