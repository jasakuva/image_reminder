# Picture Reminder App — Specification

## 1. Overview

Picture Reminder is a Flutter application for Android, iOS, and Windows that lets users create reminders connected to locally stored pictures or screenshots.

The core idea is simple:

1. User takes, imports, or saves a picture.
2. User chooses when they want to be reminded.
3. The app schedules a local reminder.
4. When the reminder fires, the user is notified and can open the related picture.
5. The user can mark the reminder as done or snooze it for later.

All user data should be stored locally on the device. Cloud sync is not part of the initial scope.

## 2. Target Platforms

The app should support:

- Android
- iOS
- Windows desktop

Flutter will be used as the main application framework.

## 3. Primary Goals

- Let users create multiple picture-based reminders.
- Support taking pictures with the camera on mobile devices.
- Support importing images from gallery/files.
- Store images locally in app-managed storage.
- Compress/resize images because high resolution is not required.
- Schedule reminders for exact date/time.
- Support quick reminder options, such as:
  - after 10 minutes
  - after 1 hour
  - later today
  - tomorrow
- Allow snoozing/re-reminding after a selected period.
- Work offline.
- Keep all user data local.
- Provide good integration with phone notification systems where possible.

## 4. Non-Goals for Initial Version

The following are not required for the first version:

- Cloud sync
- User accounts
- Web app support
- Sharing reminders between users
- AI image recognition
- Calendar sync
- Recurring reminders beyond simple snooze/reschedule
- Guaranteed alarm-level exactness on every platform/device

## 5. Core User Flows

### 5.1 Create Reminder from Camera

1. User taps `New Reminder`.
2. User chooses `Take Photo`.
3. App requests camera permission if needed.
4. User takes a photo.
5. App compresses/resizes the image.
6. App stores the image locally.
7. User selects reminder time.
8. User optionally adds title/notes.
9. App saves reminder metadata locally.
10. App schedules a local notification.

### 5.2 Create Reminder from Existing Image

1. User taps `New Reminder`.
2. User chooses `Pick Image` or `Choose File`.
3. App requests gallery/file permission if needed.
4. User selects an image.
5. App copies, compresses, and stores the image locally.
6. User selects reminder time.
7. App saves reminder and schedules notification.

### 5.3 Reminder Fires

1. Operating system shows a local notification.
2. Notification contains reminder title/text.
3. Where supported, notification may show an image preview.
4. User taps notification.
5. App opens directly to the reminder detail screen showing the picture.
6. User can:
   - mark as done
   - snooze
   - edit reminder time
   - delete reminder

### 5.4 Snooze Reminder

1. User opens a reminder from notification or reminder list.
2. User selects `Snooze`.
3. User chooses duration, for example:
   - 5 minutes
   - 10 minutes
   - 1 hour
   - tomorrow
   - custom time
4. App updates the reminder scheduled time.
5. App schedules a new local notification.

## 6. Functional Requirements

### 6.1 Reminder Management

The app must allow users to:

- Create reminders.
- View active reminders.
- View completed reminders, if history is enabled.
- Edit reminder title/notes/time.
- Delete reminders.
- Mark reminders as done.
- Snooze reminders.

### 6.2 Picture Management

The app must allow users to:

- Take a photo on supported devices.
- Import an image from gallery or file system.
- Store a local copy of each reminder image.
- Compress or resize images before storage.
- Display image previews in reminder lists and detail pages.
- Delete image files when associated reminders are permanently deleted.

### 6.3 Scheduling

The app must support:

- Exact date/time selection.
- Relative time selection, such as `after 1 hour`.
- Updating scheduled notification when reminder time changes.
- Cancelling scheduled notification when reminder is deleted or completed.

### 6.4 Notifications

The app should use local notifications.

Notification behavior:

- Basic notification should work on Android and iOS when app is closed.
- Windows notification support should be implemented if practical with available Flutter plugins.
- Notification tap should open the related reminder detail page.
- Snooze actions directly in notifications are desirable but not required for MVP.
- Image previews inside notifications are desirable but platform-dependent.

### 6.5 Local-Only Storage

All app data must be stored locally:

- Reminder metadata in local database.
- Images in app documents/application support directory.
- Notification IDs stored with reminders.

No backend server is required.

## 7. Data Model

### 7.1 Reminder

Suggested fields:

```text
id: string
title: string?
note: string?
imagePath: string
thumbnailPath: string?
scheduledAt: DateTime
createdAt: DateTime
updatedAt: DateTime
completedAt: DateTime?
status: active | completed | cancelled
notificationId: int
snoozeCount: int
lastSnoozedAt: DateTime?
```

### 7.2 Reminder Status

```text
active
completed
cancelled
```

### 7.3 Local File Structure

Recommended structure inside app documents/application support directory:

```text
pic_reminder/
  images/
    reminder_<id>.jpg
  thumbnails/
    reminder_<id>_thumb.jpg
  database/
    app.db
```

## 8. Recommended Flutter Packages

Final package selection should be confirmed during implementation, but likely packages include:

### Core

```yaml
flutter_local_notifications
timezone
path_provider
permission_handler
uuid
```

### Image Input

```yaml
image_picker
file_picker
camera
```

### Image Processing

```yaml
flutter_image_compress
```

### Local Database

Choose one main local database solution:

Option A — SQLite/Drift:

```yaml
drift
sqlite3_flutter_libs
path
```

Option B — Isar:

```yaml
isar
isar_flutter_libs
```

For this app, SQLite/Drift is a strong choice because reminder data is structured and should remain reliable over time.

## 9. Platform Considerations

### 9.1 Android

Android supports local notifications well, but modern Android versions require attention to permissions and exact alarm behavior.

Considerations:

- Android 13+ requires notification permission.
- Exact alarms may require additional permission or settings.
- Battery optimization may delay notifications on some devices.
- Big picture style notifications may be possible.
- Notification action buttons may support snooze/done actions.

### 9.2 iOS

iOS supports local notifications but has stricter background limitations.

Considerations:

- Notification permission is required.
- App cannot freely run background code when notification fires.
- Pending local notifications may be limited by the OS.
- Notification attachments may allow image previews, but require platform-specific setup.
- Snooze actions may be possible through notification categories, but MVP can handle snooze inside the app.

### 9.3 Windows

Windows support is feasible for local storage and in-app reminders.

Considerations:

- Toast notification support depends on Flutter/plugin capabilities.
- Reliable scheduled notifications while the app is fully closed may require extra Windows-specific work.
- For MVP, Windows may initially support reminders best while app is running, with later improvement for native toast integration.

## 10. MVP Scope

The minimum useful version should include:

- Create reminder with imported image.
- Create reminder with camera image on mobile.
- Compress/store image locally.
- Select exact reminder date/time.
- Quick options: after 10 minutes, after 1 hour, tomorrow.
- Store reminder metadata locally.
- Schedule local notification.
- Open reminder detail from notification tap.
- Mark reminder as done.
- Snooze from inside app.
- Delete reminder and image.

## 11. Future Enhancements

- Image preview directly in notifications.
- Notification action buttons:
  - snooze 10 minutes
  - mark done
- Recurring picture reminders.
- Reminder history/archive.
- Search reminders.
- Tags/categories.
- Optional backup/export.
- Better Windows scheduled notification integration.
- Share-to-app integration, allowing users to create reminders from other apps.
- Screenshot/share extension support where practical.

## 12. Risks and Limitations

- Notification timing may not be exact on every Android device due to battery optimization.
- iOS limits background processing and pending scheduled notifications.
- Windows notification behavior may require platform-specific implementation.
- Showing images directly inside notifications is not guaranteed equally on all platforms.
- Camera support differs between mobile and desktop.

## 13. Success Criteria

The app is successful when a user can reliably:

1. Save or take a picture.
2. Attach it to a reminder.
3. Receive a notification at the selected time.
4. Tap the notification and see the picture.
5. Snooze, complete, edit, or delete the reminder.
