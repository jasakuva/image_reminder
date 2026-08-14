# Picture Reminder — Backlog

## Priority Legend

- P0: Required for MVP.
- P1: Important soon after MVP.
- P2: Nice to have.
- P3: Future/advanced.

## P0 — MVP

### Project Setup

- [ ] Create Flutter project in repository.
- [ ] Enable Android support.
- [ ] Enable iOS support.
- [ ] Enable Windows support.
- [ ] Add linting rules.
- [ ] Create initial folder structure.

### Local Data

- [ ] Choose local database.
- [ ] Create reminder model.
- [ ] Create reminder status enum.
- [ ] Create local reminder repository.
- [ ] Save reminder.
- [ ] Load active reminders.
- [ ] Update reminder.
- [ ] Delete reminder.

### Image Storage

- [ ] Pick image from gallery/files.
- [ ] Copy selected image to app storage.
- [ ] Compress image.
- [ ] Generate thumbnail.
- [ ] Delete stored image when reminder is deleted.
- [ ] Handle missing/corrupt image file.

### Reminder UI

- [ ] Create home/reminder list screen.
- [ ] Create empty state.
- [ ] Create new reminder screen.
- [ ] Add image preview.
- [ ] Add date/time picker.
- [ ] Add quick time buttons.
- [ ] Add reminder detail screen.
- [ ] Add delete action.
- [ ] Add mark done action.

### Notifications

- [x] Add local notifications package.
- [x] Initialize notification service.
- [x] Request notification permission.
- [x] Schedule notification for reminder.
- [x] Cancel notification when reminder is deleted.
- [x] Cancel notification when reminder is completed.
- [x] Handle notification tap payload.
- [x] Navigate to reminder detail from notification.

### Snooze

- [ ] Add snooze UI on detail screen.
- [ ] Add fixed snooze options.
- [ ] Add custom snooze time.
- [ ] Reschedule notification after snooze.
- [ ] Track snooze count.

## P1 — Phone Integration Improvements

- [ ] Add camera capture on Android.
- [ ] Add camera capture on iOS.
- [ ] Improve Android notification permission UX.
- [ ] Improve iOS notification permission UX.
- [ ] Add Android exact alarm investigation.
- [ ] Add Android battery optimization information screen if needed.
- [ ] Add notification image preview on Android if supported.
- [ ] Add notification image attachment on iOS if supported.

## P1 — App Polish

- [ ] Add app icon.
- [ ] Add light/dark theme.
- [ ] Add better reminder cards.
- [ ] Add reminder sorting.
- [ ] Add completed reminders/history screen.
- [ ] Add confirmation dialog before delete.
- [ ] Add onboarding or permission explanation screen.

## P2 — Windows Improvements

- [ ] Add Windows file picker polish.
- [ ] Add Windows toast notification support.
- [ ] Investigate scheduled notifications while app is closed.
- [ ] Improve desktop layout.
- [ ] Add drag-and-drop image import if practical.

## P2 — Reminder Features

- [ ] Add recurring reminders.
- [ ] Add tags/categories.
- [ ] Add search.
- [ ] Add filter by status.
- [ ] Add archive instead of permanent delete.
- [ ] Add duplicate reminder.

## P3 — Advanced Integrations

- [ ] Android share target.
- [ ] iOS share extension.
- [ ] Windows file association/open with.
- [ ] Export/backup reminders.
- [ ] Optional encrypted local storage.
- [ ] Optional cloud sync.

## First Recommended Sprint

Focus only on:

- Flutter project setup.
- Static UI.
- Local reminder model.
- Image import.
- Local image storage.
- Create/list/detail reminder flow without notifications.

## Second Recommended Sprint

Focus on:

- Local notifications.
- Notification tap routing.
- Snooze.
- Mark done/delete notification cancellation.

## Third Recommended Sprint

Focus on:

- Camera support.
- Android/iOS permissions.
- Windows behavior.
- Polish and testing.
