# Picture Reminder — Backlog

## Priority Legend

- P0: Current critical follow-up
- P1: Important next improvements
- P2: Useful polish / expansion
- P3: Longer-term ideas

## P0 — Stabilization and Validation

- [ ] Refresh widget tests to match current UI/navigation behavior
- [ ] Add targeted tests for reminder create/snooze/complete/delete flows
- [ ] Validate premium purchase flow on Android
- [ ] Re-check localization coverage after recent UI changes
- [ ] Continue manual iOS shared import testing

## P1 — Core Product Improvements

- [ ] Add completed reminder history screen
- [ ] Add reminder editing after creation
- [ ] Improve sort/filter options in reminder list
- [ ] Improve missing/corrupt image recovery UX
- [ ] Improve premium and billing status/error UX

## P1 — Mobile Platform Improvements

- [ ] Improve Android notification permission UX
- [ ] Investigate Android exact alarm behavior if needed
- [ ] Validate premium purchase flow end-to-end on Android devices
- [ ] Continue hardening iOS share/pending reminder import flow

## P2 — Desktop / Windows Improvements

- [ ] Validate Windows reminder flow more thoroughly
- [ ] Improve Windows-specific image import UX
- [ ] Investigate Windows notification behavior when app is closed
- [ ] Improve desktop layout/polish

## P2 — Notification Enhancements

- [ ] Add richer notification body/content
- [ ] Explore notification action buttons
- [ ] Investigate image preview/attachment support by platform
- [ ] Add better alarm/reminder sound customization if needed

## P2 — Product Polish

- [ ] Add app icon polish
- [ ] Improve onboarding/help text if needed
- [ ] Improve settings/info presentation
- [ ] Expand manual test checklist documentation

## P3 — Advanced Features

- [ ] Recurring reminders
- [ ] Search/filter by more criteria
- [ ] Tags/categories
- [ ] Export/backup reminders
- [ ] Optional encrypted storage
- [ ] Optional cloud sync

## Already Implemented

These major items are already done in current codebase:

- [x] Flutter project setup
- [x] Android/iOS/Windows targets
- [x] Reminder model and persistence
- [x] Reminder create/list/detail UI
- [x] Image import / photo selection flow
- [x] Local image storage
- [x] Local notifications
- [x] Notification tap opens reminder
- [x] Snooze with fixed options
- [x] Mark reminder done
- [x] Delete reminder and local image
- [x] Settings & info screen
- [x] Language selection
- [x] Localization system
- [x] Free vs premium gating groundwork
- [x] Simulated premium unlock flow
- [x] iOS share/import groundwork