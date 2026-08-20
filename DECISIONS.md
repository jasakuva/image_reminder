# Picture Reminder — Decisions

This file records current implementation decisions and open follow-up topics.

## Decision Status

- Proposed: likely choice, may still change
- Accepted: in use now
- Rejected: considered but not used
- Open: still needs decision

## Accepted Decisions

### D001 — Use Flutter

Status: Accepted

Decision:

Use Flutter for Android, iOS, and Windows.

Reason:

- Single codebase
- Good plugin support for notifications, image picking, billing, and localization
- Practical for mobile-first app with desktop target present

### D002 — Local-First Storage

Status: Accepted

Decision:

Keep user data local on device.

Reason:

- Matches app goals
- Keeps implementation simple
- Better privacy
- No backend required

### D003 — Store Images as Files

Status: Accepted

Decision:

Store reminder images as files and keep only paths in reminder metadata.

Reason:

- Better performance for image display
- Easy cleanup on delete
- Keeps metadata smaller

### D004 — Use Simple Notifier-Based State

Status: Accepted

Decision:

Use `ChangeNotifier`, `ValueNotifier`, and `ListenableBuilder` for current app state.

Reason:

- Sufficient for current scope
- Lower complexity than introducing larger state framework now

### D005 — Notification Tap Opens Reminder Detail

Status: Accepted

Decision:

Notification taps route to the related reminder detail screen.

Reason:

- Simple and reliable behavior
- Matches app’s main user expectation

### D006 — Snooze Inside App First

Status: Accepted

Decision:

Implement snooze from reminder detail screen before adding rich notification actions.

Reason:

- Lower cross-platform complexity
- Current feature set already satisfies main postponing need

### D007 — Use Flutter gen-l10n for Localization

Status: Accepted

Decision:

Use generated Flutter localization with ARB files under `lib/l10n`.

Reason:

- Standard Flutter approach
- Easy to maintain multiple languages
- Strong typed string access in UI

### D008 — Use SharedPreferences for Current Reminder Persistence

Status: Accepted

Decision:

Persist reminders as JSON in `SharedPreferences` for the current version.

Reason:

- Fast to implement
- Good enough for current reminder volume and app maturity
- Can be migrated later if needed

### D009 — Premium Access Uses Free Limit + Simulated Unlock

Status: Accepted

Decision:

Use a free active reminder limit of 2 and support simulated premium unlock while billing integration matures.

Reason:

- Enables premium UX testing now
- Keeps product flow moving while purchase validation is still ongoing

## Proposed Decisions

### D010 — Migrate Reminder Metadata to Structured Local Database Later

Status: Proposed

Decision:

Consider migrating reminder metadata from `SharedPreferences` JSON to a structured local database if the app grows.

Reason:

- Better long-term scalability
- Cleaner filtering/history/edit support

## Open Questions

### Q001 — Should Completed Reminders Get Their Own History Screen?

Current recommendation:

- Yes, likely as a next UX improvement.

### Q002 — How Far Should Android Billing Be Validated Before Release?

Current recommendation:

- Finish Android purchase validation before calling premium fully production-ready.

### Q003 — Should Windows Stay Fully Supported for Reminder Notifications?

Current recommendation:

- Keep Windows in project scope, but prioritize mobile behavior first.

## Rejected Decisions

No explicit rejected decisions recorded yet.

## Decision Log

| ID | Decision | Status |
| --- | --- | --- |
| D001 | Use Flutter | Accepted |
| D002 | Local-first storage | Accepted |
| D003 | Store images as files | Accepted |
| D004 | Simple notifier-based state | Accepted |
| D005 | Notification tap opens reminder detail | Accepted |
| D006 | Snooze inside app first | Accepted |
| D007 | Flutter gen-l10n localization | Accepted |
| D008 | SharedPreferences JSON persistence for now | Accepted |
| D009 | Free limit + simulated premium unlock | Accepted |
| D010 | Consider structured DB later | Proposed |