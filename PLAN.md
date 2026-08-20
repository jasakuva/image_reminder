# Picture Reminder App — Current Plan

This file reflects the current project state and next implementation steps.

## 1. Completed Foundations

The following are already in place:

- Flutter project setup for Android, iOS, and Windows
- Feature-oriented app structure
- Main app theme and navigation entry flow
- Reminder create/list/detail UI
- Local reminder persistence
- Local image storage flow
- Local notifications and notification tap handling
- Snooze, complete, and delete flows
- Premium/free reminder gating
- Localization system and language selection UI
- iOS share/import groundwork

## 2. Current Architecture State

Implemented feature areas:

- `billing`
- `images`
- `notifications`
- `reminders`
- `settings`
- `share`
- `l10n`

The app currently uses simple notifier-based state and local persistence.

## 3. Current Priorities

### Priority A — Stabilization

- Improve widget tests to match current app behavior
- Add more focused unit/widget test coverage for reminder flows
- Verify notification and premium flows across more devices
- Improve handling of edge cases around missing image files and imports

### Priority B — Premium / Billing Validation

- Validate paid purchase flow on Android
- Re-validate iOS premium purchase behavior beyond simulation if needed
- Review plugin warnings and upstream dependency changes over time

### Priority C — UX / Feature Polish

- Improve reminder sorting/filtering if needed
- Add completed reminder history view
- Add stronger confirmation and status messaging where helpful
- Continue localization review for missed strings/regressions

### Priority D — Platform Completion

- Improve Android-specific permission and notification UX
- Continue iOS share/import integration hardening
- Validate Windows behavior more thoroughly

## 4. Near-Term Next Tasks

Recommended next implementation steps:

1. Fix/refresh widget tests for current navigation and settings behavior.
2. Validate premium purchase behavior on Android.
3. Add completed reminder history or archived reminder view.
4. Improve documentation and manual test checklist.
5. Continue cross-platform manual testing.

## 5. Manual Test Focus

Important current manual checks:

- Create reminder with imported image
- Create reminder with camera image on mobile
- Confirm reminder survives restart
- Confirm notification fires and opens correct reminder
- Confirm snooze reschedules correctly
- Confirm mark done cancels notification
- Confirm delete removes stored image
- Confirm language switch updates visible UI
- Confirm free limit triggers premium prompt
- Confirm iOS premium simulation flow works

## 6. Medium-Term Improvements

- Reminder editing after creation
- Richer notification actions
- Better desktop-specific UX
- More robust import/share flows
- Possible storage refactor if SharedPreferences becomes limiting for reminder metadata

## 7. Long-Term Ideas

- Recurring reminders
- Search/filtering
- Export/backup
- Optional encrypted storage
- Optional cloud sync