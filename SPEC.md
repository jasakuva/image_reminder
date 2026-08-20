# Picture Reminder App — Specification

## 1. Overview

Picture Reminder is a Flutter application for Android, iOS, and Windows that lets users create reminders connected to locally stored pictures or screenshots.

Core behavior:

1. User imports or captures an image.
2. User selects reminder text, sound mode, and time.
3. App stores the reminder locally.
4. App schedules a local notification.
5. Tapping the notification opens the related reminder detail.
6. User can mark the reminder done, snooze it, or delete it.

The app is local-first. Cloud sync is out of scope.

## 2. Current Supported Platforms

- Android
- iOS
- Windows

Flutter is the main framework.

## 3. Implemented Functional Scope

### 3.1 Reminder Management

The app currently supports:

- Create reminder
- View reminder list
- View reminder detail
- Mark reminder as done
- Snooze reminder
- Delete reminder

### 3.2 Image Handling

The app currently supports:

- Pick an image from local source
- Take a photo on supported mobile devices
- Store a local copy for each reminder
- Display image preview in list/detail/create flows
- Delete stored image when reminder is deleted

### 3.3 Notification Handling

The app currently supports:

- Schedule local notifications
- Cancel scheduled notifications when reminder is completed or deleted
- Open reminder detail from notification tap

### 3.4 Settings

The app currently supports:

- Settings & info screen
- Language selection
- Version/build information display
- Premium/free status display

### 3.5 Localization

Supported UI languages:

- English
- Finnish
- Swedish
- Japanese
- German

### 3.6 Premium / Free Access

Current premium behavior:

- Free plan allows up to 2 active reminders
- Premium allows unlimited active reminders
- In-app purchase groundwork exists
- Add-code simulation exists for premium testing
- Paid version has been simulated/tested on iOS, not Android yet

### 3.7 iOS Shared Image Import Groundwork

Current iOS share-related support includes:

- Shared image receiver infrastructure
- Pending reminder import handling for iOS
- Premium state sync hook for iOS shared import flow

## 4. Current Non-Goals / Not Yet Implemented

Not currently implemented or not fully complete:

- Cloud sync
- User accounts
- Full recurring reminders
- Reminder edit flow after creation
- Completed history screen
- Android premium purchase validation parity with iOS simulation
- Rich notification action buttons
- Fully polished Windows notification behavior

## 5. Core User Flows

### 5.1 Create Reminder

1. User taps `New reminder`.
2. User chooses picture or takes a photo.
3. User enters reminder text.
4. User selects sound mode.
5. User selects time.
6. App saves reminder locally.
7. App schedules local notification.

### 5.2 Reminder Fires

1. OS shows local notification.
2. User taps notification.
3. App opens reminder detail screen.
4. User can mark done, snooze, or delete.

### 5.3 Snooze Reminder

Current snooze choices:

- 5 minutes
- 10 minutes
- 1 hour
- tomorrow

Flow:

1. User opens reminder detail.
2. User selects snooze.
3. User chooses one of the fixed durations.
4. App updates `scheduledAt`.
5. App reschedules notification.

### 5.4 Free Limit / Premium Upgrade

1. User tries to create more than 2 active reminders on free plan.
2. App shows premium upgrade dialog.
3. User can:
   - upgrade/buy (groundwork)
   - add test code
   - cancel

## 6. Current Data Model

Reminder fields currently in use:

```text
id: string
title: string?
note: string?
imagePath: string
scheduledAt: DateTime
createdAt: DateTime
updatedAt: DateTime
completedAt: DateTime?
status: active | completed
snoozeCount: int
notificationId: int
soundMode: notification | alarm
lastSnoozedAt: DateTime?
```

## 7. Current Storage Model

Current persistence approach:

- Reminder metadata stored in `SharedPreferences` as JSON
- Image files stored locally on disk
- Premium flag stored in `SharedPreferences`
- Selected locale stored in `SharedPreferences`

## 8. Current Technical Choices

- Flutter UI
- `ChangeNotifier` / `ValueNotifier` state updates
- `flutter_local_notifications` for notifications
- `timezone` and `flutter_timezone` for local scheduling
- `image_picker` for photo/image selection
- Flutter gen-l10n for localization

## 9. Future Enhancements

Planned or possible future improvements:

- Android premium purchase verification and testing
- Reminder editing
- Completed reminder history
- Better Windows support and validation
- Rich notification actions
- Recurring reminders
- Better import/share flows across platforms