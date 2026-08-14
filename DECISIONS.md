# Picture Reminder — Decisions

This file records technical decisions and open questions for the project.

## Decision Status

- Proposed: likely choice, not final.
- Accepted: chosen and should be followed.
- Rejected: considered but not chosen.
- Open: still needs decision.

## Accepted Decisions

No final implementation decisions have been made yet.

## Proposed Decisions

### D001 — Use Flutter

Status: Proposed

Decision:

Use Flutter for Android, iOS, and Windows.

Reason:

- Single main codebase.
- Good support for mobile UI.
- Windows desktop support is available.
- Plugin ecosystem supports camera, files, local storage, and notifications.

### D002 — Store All Data Locally

Status: Proposed

Decision:

Store reminder metadata and image files locally on the device.

Reason:

- Matches app requirement.
- Keeps MVP simple.
- Avoids backend/server cost.
- Better privacy.

### D003 — Use Drift/SQLite for Reminder Metadata

Status: Proposed

Decision:

Use Drift with SQLite for structured reminder data.

Reason:

- Reliable local database.
- Good for structured queries.
- Easier long-term migrations than simple key-value storage.

Alternatives:

- Hive
- Isar
- sqflite

### D004 — Store Images as Files, Not Database Blobs

Status: Proposed

Decision:

Store images in local app storage and store only image paths in the database.

Reason:

- Better performance.
- Easier image display.
- Database stays smaller.
- Easier deletion and cleanup.

### D005 — Notification Opens App to Picture

Status: Proposed

Decision:

For MVP, notification tap opens the app directly to the reminder detail screen.

Reason:

- Reliable across Android and iOS.
- Avoids relying on image-rich notification behavior for MVP.
- User still sees the picture quickly.

### D006 — Snooze Inside App for MVP

Status: Proposed

Decision:

Implement snooze from inside the app first, not directly from notification action buttons.

Reason:

- Simpler cross-platform implementation.
- Notification action buttons differ by platform.
- Can add notification actions later.

## Open Questions

### Q001 — Should Completed Reminders Be Kept?

Options:

1. Keep completed reminders in history.
2. Delete completed reminders automatically.
3. Ask user each time.

Recommended:

Keep completed reminders in history at first, with manual delete.

### Q002 — How Exact Must Reminder Timing Be?

Options:

1. Best-effort local notification timing.
2. Exact alarm behavior where platform allows it.
3. Alarm-clock-level reliability.

Recommended:

Start with best-effort local notifications. Investigate exact alarms later if needed.

### Q003 — Should Windows Reminders Work When App Is Closed?

Options:

1. Required for MVP.
2. Nice to have after mobile MVP.
3. Not required.

Recommended:

Nice to have after mobile MVP.

### Q004 — Which State Management Should Be Used?

Options:

1. Built-in `ChangeNotifier` / `ValueNotifier`.
2. Riverpod.
3. Bloc.

Recommended:

Start simple. Use Riverpod if app state becomes complex.

### Q005 — Should Images Be Encrypted?

Options:

1. No encryption for MVP.
2. Optional encryption later.
3. Required encryption from start.

Recommended:

No encryption for MVP. Consider optional encryption later.

## Rejected Decisions

No rejected decisions yet.

## Decision Log

| ID | Decision | Status | Date |
| --- | --- | --- | --- |
| D001 | Use Flutter | Proposed | 2026-08-14 |
| D002 | Store all data locally | Proposed | 2026-08-14 |
| D003 | Use Drift/SQLite | Proposed | 2026-08-14 |
| D004 | Store images as files | Proposed | 2026-08-14 |
| D005 | Notification opens app to picture | Proposed | 2026-08-14 |
| D006 | Snooze inside app for MVP | Proposed | 2026-08-14 |
