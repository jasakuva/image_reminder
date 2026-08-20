# Picture Reminder — Architecture

## 1. Architecture Goals

The current architecture aims to keep the app simple, local-first, and practical across Android, iOS, and Windows.

Primary goals:

- Keep UI separate from data and platform integration code
- Keep implementation lightweight for current scope
- Make reminder and notification flows easy to reason about
- Support localization and settings cleanly
- Leave room for later billing and share/import expansion

## 2. Current Project Structure

```text
lib/
  main.dart
  app.dart
  l10n/
  core/
    app_info/
    theme/
    time/
  features/
    billing/
      data/
      presentation/
    images/
      data/
    notifications/
      data/
    reminders/
      data/
      domain/
      presentation/
    settings/
      data/
      presentation/
    share/
      data/
```

## 3. Current Layering

### 3.1 Presentation Layer

Contains screens and widgets such as:

- reminder list
- reminder detail
- create reminder
- settings & info
- upgrade prompt

Responsibilities:

- Render UI
- Read localized strings
- Handle user interaction
- Call stores/services

### 3.2 Domain Layer

Current reminder domain objects include:

- `PictureReminder`
- `ReminderStatus`
- `ReminderSoundMode`

Responsibilities:

- Represent reminder data
- Represent reminder status and sound mode
- Support app-level reminder behavior through model/state updates

### 3.3 Data / Service Layer

Current data-oriented classes include:

- `ReminderStore`
- `PremiumAccessStore`
- `LocaleSettingsStore`
- `LocalNotificationService`
- `LocalImageStorageService`
- `PicturePickerService`
- `SharedImageReceiver`

Responsibilities:

- Persist reminders
- Persist settings/premium status
- Schedule/cancel notifications
- Store and load image files
- Receive shared/imported images on supported platforms

## 4. State Management

Current app state is managed with:

- `ChangeNotifier`
- `ValueNotifier`
- `ListenableBuilder`

This is intentionally lightweight and matches the current project scope.

## 5. Current Data Flow

### 5.1 App Startup

```text
main()
  -> load premium state
  -> initialize billing
  -> load locale setting
  -> load reminders
  -> initialize app
```

### 5.2 Create Reminder

```text
User selects image
  -> image picker / camera flow
  -> image stored locally
  -> reminder created in ReminderStore
  -> LocalNotificationService schedules notification
  -> reminder list updates
```

### 5.3 Notification Tap

```text
Notification tapped
  -> LocalNotificationService sets selected reminder id
  -> app listener receives it
  -> reminder detail route opens
```

### 5.4 Shared Image Import

```text
Shared image received on supported platform
  -> SharedImageReceiver loads pending import/shared path
  -> app opens create reminder flow or imports pending reminders
```

### 5.5 Premium Access Sync

```text
PremiumAccessStore changes
  -> app syncs state to SharedImageReceiver on iOS path
  -> free/premium gating updates UI behavior
```

## 6. Current Persistence Model

### 6.1 Reminder Metadata

Current approach:

- `SharedPreferences`
- serialized JSON list of reminders

This is simple and sufficient for current app size, though a future migration to a stronger local database remains possible.

### 6.2 Images

Current approach:

- image files stored in local app-managed storage
- reminder model stores file path

### 6.3 App Settings

Stored locally:

- selected locale code
- premium flag

## 7. Notifications

Notification implementation details:

- `flutter_local_notifications`
- timezone-aware scheduling
- platform-specific Android/iOS details for sound mode
- JSON payload with reminder id

Payload concept:

```json
{
  "type": "reminder",
  "reminderId": "abc-123"
}
```

## 8. Localization

Localization is implemented with Flutter gen-l10n.

Current supported locales:

- `en`
- `fi`
- `sv`
- `ja`
- `de`

Files live under:

```text
lib/l10n/
```

## 9. Billing / Premium Architecture

Billing is currently split into:

- `BillingService` for store/plugin integration
- `PremiumAccessStore` for app-level premium state
- UI prompt in billing presentation

Current product state:

- Free limit enforced in reminder creation flow
- Premium simulation/testing supported
- Full Android validation still pending

## 10. Known Technical Limitations

- Reminder metadata currently uses key-value JSON storage rather than a structured database
- Purchase plugin may emit upstream iOS SDK deprecation warnings
- Windows platform behavior needs more validation
- Widget tests need alignment with current UI behavior