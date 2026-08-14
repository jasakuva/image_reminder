# Picture Reminder — Architecture

## 1. Architecture Goals

The app architecture should be simple enough for an MVP but organized enough to support Android, iOS, and Windows.

Primary goals:

- Keep UI separate from business logic.
- Keep platform-specific code isolated.
- Make local data storage reliable.
- Make notification scheduling testable where possible.
- Avoid unnecessary complexity in the first version.

## 2. Recommended Approach

Use a feature-first Flutter structure:

```text
lib/
  main.dart
  app.dart
  core/
    constants/
    errors/
    routing/
    theme/
    time/
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

## 3. Layers

### 3.1 Presentation Layer

Contains Flutter widgets, screens, and UI state.

Responsibilities:

- Show reminder lists.
- Show reminder details.
- Show image previews.
- Handle user input.
- Display validation errors.
- Call domain/application services.

Example files:

```text
features/reminders/presentation/screens/reminder_list_screen.dart
features/reminders/presentation/screens/reminder_detail_screen.dart
features/reminders/presentation/screens/create_reminder_screen.dart
features/reminders/presentation/widgets/reminder_card.dart
```

### 3.2 Domain Layer

Contains app concepts and business rules.

Responsibilities:

- Define reminder entity/model.
- Define repository interfaces if used.
- Define reminder status.
- Define validation rules.
- Define use cases such as create reminder, snooze reminder, complete reminder.

Example files:

```text
features/reminders/domain/reminder.dart
features/reminders/domain/reminder_status.dart
features/reminders/domain/reminder_repository.dart
features/reminders/domain/create_reminder_use_case.dart
features/reminders/domain/snooze_reminder_use_case.dart
```

### 3.3 Data Layer

Contains database, file storage, and plugin integrations.

Responsibilities:

- Save reminder metadata.
- Load reminder metadata.
- Save image files.
- Compress images.
- Schedule/cancel local notifications.
- Map database rows to domain models.

Example files:

```text
features/reminders/data/local_reminder_repository.dart
features/images/data/local_image_storage_service.dart
features/notifications/data/local_notification_service.dart
```

## 4. Main Feature Modules

### 4.1 Reminders Feature

Owns:

- Reminder model.
- Reminder database table.
- Reminder create/edit/delete flows.
- Reminder list and detail UI.
- Snooze and complete behavior.

### 4.2 Images Feature

Owns:

- Camera/image/file picking logic.
- Image compression.
- Image file storage.
- Thumbnail generation.

### 4.3 Notifications Feature

Owns:

- Local notification setup.
- Permission requests.
- Notification scheduling.
- Notification cancellation.
- Notification tap routing payload.

## 5. Data Flow

### 5.1 Create Reminder

```text
User selects image
  -> Image service copies/compresses image
  -> User selects reminder time
  -> Reminder repository saves metadata
  -> Notification service schedules local notification
  -> UI returns to reminder list
```

### 5.2 Notification Tap

```text
User taps OS notification
  -> Notification payload contains reminder ID
  -> App router opens reminder detail route
  -> Reminder repository loads reminder
  -> UI displays saved picture
```

### 5.3 Snooze

```text
User selects snooze duration
  -> Old notification is cancelled
  -> Reminder scheduledAt is updated
  -> New notification is scheduled
  -> Reminder list/detail updates
```

## 6. Suggested Database Schema

Initial `reminders` table:

```text
id TEXT PRIMARY KEY
title TEXT NULL
note TEXT NULL
image_path TEXT NOT NULL
thumbnail_path TEXT NULL
scheduled_at INTEGER NOT NULL
created_at INTEGER NOT NULL
updated_at INTEGER NOT NULL
completed_at INTEGER NULL
status TEXT NOT NULL
notification_id INTEGER NOT NULL
snooze_count INTEGER NOT NULL DEFAULT 0
last_snoozed_at INTEGER NULL
```

Store dates as UTC milliseconds since epoch, then convert to local time for display/scheduling.

## 7. Notification Payload

Use a simple JSON payload:

```json
{
  "type": "reminder",
  "reminderId": "abc-123"
}
```

The notification tap handler should parse this and navigate to:

```text
/reminders/:id
```

## 8. Error Handling

The app should gracefully handle:

- Missing image file.
- Deleted reminder with pending notification.
- Permission denied.
- Notification scheduling failure.
- Database read/write failure.
- Image compression failure.

For MVP, show a user-friendly message and keep the app usable.

## 9. State Management

Do not overcomplicate the first version.

Reasonable options:

- `ChangeNotifier` / `ValueNotifier` for simple MVP.
- Riverpod if a more scalable state management package is desired.

Recommended MVP choice:

- Start simple.
- Add Riverpod only if state management becomes messy.

## 10. Testing Strategy

### Unit Tests

- Reminder date calculation.
- Snooze calculation.
- Reminder validation.
- Data mapping.

### Widget Tests

- Reminder list renders items.
- Empty state is shown.
- Create reminder form validates required fields.

### Manual Platform Tests

- Notification permission flow.
- Notification scheduling.
- Notification tap navigation.
- Camera/gallery/file import.

## 11. Platform Isolation

Platform-specific behavior should be hidden behind services:

```text
NotificationService
ImagePickerService
FileStorageService
PermissionService
```

This avoids spreading platform checks across UI widgets.
