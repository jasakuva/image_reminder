# Picture Reminder App — Implementation Plan

## 1. Project Setup

### Goals

- Create Flutter project targeting Android, iOS, and Windows.
- Establish clean folder structure.
- Add linting and basic development conventions.

### Tasks

- Create Flutter app in this folder.
- Enable Android, iOS, and Windows platform support.
- Confirm the app runs on at least one target device/emulator.
- Add core dependencies.
- Create initial app structure.

### Suggested Structure

```text
lib/
  main.dart
  app.dart
  core/
    routing/
    theme/
    utils/
  features/
    reminders/
      data/
      domain/
      presentation/
    images/
      data/
      domain/
    notifications/
      data/
      domain/
```

### Deliverables

- Flutter project builds successfully.
- Basic home screen appears.
- Platform folders exist for Android, iOS, and Windows.

## 2. Data Layer

### Goals

- Store reminder metadata locally.
- Store images locally as files.
- Keep image paths connected to reminders.

### Tasks

- Choose local database technology.
- Recommended: Drift/SQLite.
- Define `Reminder` data model.
- Implement reminder repository.
- Implement image file storage service.
- Add create/read/update/delete operations.

### Deliverables

- App can save reminder records locally.
- App can list saved reminders after restart.
- App can delete reminder records.

## 3. Image Capture and Import

### Goals

- Let user attach a picture to a reminder.
- Support camera and image import.
- Compress images before storage.

### Tasks

- Add image picker flow.
- Add camera flow for mobile.
- Add file picker fallback, especially useful for Windows.
- Implement image compression/resizing.
- Generate optional thumbnails.
- Store final image in app documents/application support directory.

### Deliverables

- User can import an image.
- User can take a photo on mobile.
- Image appears in reminder creation screen.
- Image remains available after app restart.

## 4. Reminder Creation UI

### Goals

- Provide a simple UI to create picture reminders.

### Tasks

- Create `New Reminder` screen.
- Add image preview.
- Add optional title/note input.
- Add date/time picker.
- Add quick time options:
  - 10 minutes
  - 1 hour
  - tomorrow
  - custom
- Validate that image and reminder time are selected.
- Save reminder to local database.

### Deliverables

- User can create a complete picture reminder from the UI.

## 5. Reminder List and Detail UI

### Goals

- Let users see and manage reminders.

### Tasks

- Create active reminders list.
- Show thumbnail, title, and scheduled time.
- Create reminder detail screen.
- Show full image.
- Add actions:
  - mark done
  - snooze
  - edit time
  - delete

### Deliverables

- User can browse reminders.
- User can open a reminder and see the picture.
- User can complete, snooze, edit, and delete reminders.

## 6. Local Notifications

### Goals

- Notify user at selected reminder time.
- Open correct reminder when notification is tapped.

### Tasks

- Add and configure local notifications package.
- Initialize timezone handling.
- Request notification permissions on Android/iOS.
- Schedule notification when reminder is created.
- Cancel notification when reminder is deleted/completed.
- Reschedule notification when reminder time changes.
- Store notification ID with reminder.
- Handle notification tap payload and route to reminder detail.

### Deliverables

- Notification appears at selected time.
- Tapping notification opens related reminder.
- Deleted/completed reminders do not fire notifications.

## 7. Snooze / Re-Remind

### Goals

- Let users quickly postpone reminders.

### Tasks

- Add snooze button on reminder detail screen.
- Add snooze options:
  - 5 minutes
  - 10 minutes
  - 1 hour
  - tomorrow
  - custom
- Update scheduled time in local database.
- Cancel old notification.
- Schedule new notification.
- Track snooze count and last snoozed time.

### Deliverables

- User can re-remind themselves after selected period.

## 8. Permissions and Platform Setup

### Goals

- Handle platform permissions cleanly.
- Avoid app crashes when permissions are denied.

### Android Tasks

- Add notification permission for Android 13+.
- Add camera permission.
- Add image/media permissions if needed.
- Investigate exact alarm permission if exact reminders are required.

### iOS Tasks

- Add notification permission text.
- Add camera permission text.
- Add photo library permission text if required.
- Configure notification categories later if action buttons are added.

### Windows Tasks

- Confirm file picker support.
- Confirm notification plugin support.
- Decide whether Windows MVP requires notifications while app is closed.

### Deliverables

- Permissions are requested only when needed.
- User-friendly error messages are shown when permissions are denied.

## 9. MVP Testing

### Goals

- Verify core app behavior before adding advanced features.

### Test Cases

- Create reminder with imported image.
- Create reminder with camera image on Android/iOS.
- Restart app and confirm reminder still exists.
- Wait for reminder notification.
- Tap notification and confirm correct picture opens.
- Snooze reminder and confirm new notification is scheduled.
- Mark reminder done and confirm notification is cancelled.
- Delete reminder and confirm image file is removed.
- Deny permissions and confirm app handles it gracefully.

### Deliverables

- MVP works on at least Android first.
- Then validate iOS.
- Then validate Windows.

## 10. Advanced Notification Features

These should be implemented after the MVP is stable.

### Features

- Image preview in notification.
- Notification action button: `Snooze 10 min`.
- Notification action button: `Done`.
- Android big picture style.
- iOS notification attachments.
- More robust Windows toast support.

### Deliverables

- Better phone integration where each platform allows it.

## 11. Share/Screenshot Integration

This is a future feature because it may require platform-specific work.

### Possible Features

- Android share target: share image to Picture Reminder.
- iOS share extension.
- Windows `Open With` or file association support.

### Deliverables

- User can send images/screenshots from other apps into Picture Reminder.

## 12. Suggested Development Order

Recommended order:

1. Create Flutter project.
2. Build static UI prototype.
3. Implement local reminder database.
4. Implement local image storage.
5. Implement image import.
6. Implement reminder creation.
7. Implement reminder list/detail.
8. Implement local notifications.
9. Implement notification tap routing.
10. Implement snooze.
11. Add camera support.
12. Add Android permission polish.
13. Add iOS permission polish.
14. Add Windows support polish.
15. Add advanced notification features.

## 13. First MVP Milestone

The first practical milestone should be:

- Android-focused MVP.
- Import image from gallery/files.
- Create reminder with date/time.
- Save reminder locally.
- Schedule local notification.
- Open reminder from notification.
- Snooze from inside app.

After this works, expand to camera, iOS, and Windows-specific behavior.

## 14. Open Decisions

Before implementation, decide:

- Which local database to use: Drift, Isar, or Hive.
- Whether Windows notifications must work while app is fully closed in MVP.
- Whether reminder notifications must be exact alarms or approximate reminders are acceptable.
- Whether completed reminders should be archived or deleted by default.
- Whether app should use Material Design only or platform-adaptive UI.

## 15. Recommended Initial Technical Choices

Recommended starting choices:

- Flutter with Material Design.
- Drift/SQLite for reminder metadata.
- Local app documents/application support directory for images.
- `flutter_local_notifications` for notifications.
- `image_picker` for camera/gallery on mobile.
- `file_picker` for Windows/import fallback.
- `flutter_image_compress` for image resizing/compression.

These choices can be adjusted after checking current plugin support for Android, iOS, and Windows.
