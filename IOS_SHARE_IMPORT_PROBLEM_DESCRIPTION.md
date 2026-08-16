# iOS Share Extension Reminder Import Problem Description

## Goal

The intended iOS flow is:

```text
Screenshot
→ Share
→ ImageReminder
→ native Share Extension UI
→ choose reminder time
→ Save
→ reminder is stored
→ notification is scheduled if permission exists
→ later, when main app is opened or resumed, reminder appears in app list
```

## Current status

The Share Extension UI works correctly:

- user can open ImageReminder from iOS share sheet
- shared image preview appears
- user can choose reminder time
- user can tap Save

The extension also reports success, for example:

- image saved
- notification scheduled

## Problem

Even though the Share Extension save flow appears successful:

- the created reminder does **not appear in the main app’s reminder list**

## Important facts

- App Group is the same in both targets
- app was deleted and reinstalled
- Share Extension and Runner both use:
  - `group.com.jasapart.ireminder`
- Host app bundle ID:
  - `com.jasapart.ireminder`
- Share Extension bundle ID:
  - `com.jasapart.ireminder.ShareExtension`

## Current architecture

The current design is:

1. Share Extension receives image
2. Image is copied into App Group container
3. Share Extension creates pending reminder JSON file in App Group
4. Share Extension may schedule native iOS local notification if permission exists
5. Main Flutter app later reads pending reminder files from App Group and imports them into normal app reminder storage

## What seems to work

- Share Extension UI
- image save flow
- likely native notification scheduling

## What does not work

- main app does not import/show the saved reminder

## Likely issue area

The likely problem is in the handoff between:

- Share Extension writing pending reminder files
and
- main app reading/importing those files

This could be:

- App Group runtime file visibility issue
- pending reminder JSON not being decoded/imported correctly
- Flutter import path not being triggered or not receiving records correctly

## What has already been tried

- removed old attempt to foreground the main app
- implemented native reminder-creation UI inside Share Extension
- added pending reminder file storage in App Group
- added Flutter import on app startup
- added Flutter import on app resume
- verified App Group matches in app + extension
- deleted and reinstalled app
- still same issue

## Files involved

### iOS Share Extension

- `ios/ShareExtension/ShareViewController.swift`
- `ios/ShareExtension/Info.plist`
- `ios/ShareExtension/ShareExtension.entitlements`

### iOS Runner

- `ios/Runner/AppDelegate.swift`
- `ios/Runner/SceneDelegate.swift`

### Flutter

- `lib/features/reminders/data/reminder_store.dart`
- `lib/features/share/data/shared_image_receiver.dart`
- `lib/app.dart`

## Summary

The Share Extension can create the reminder UI and save flow, but the main app does not display the created reminder afterward. Need help diagnosing why the App Group pending reminder data is not reaching the Flutter app’s normal reminder list.

## Short version

We have an iOS Share Extension for a Flutter app. The Share Extension UI works, the image can be shared, and the extension reports that save/notification scheduling succeeded. However, the created reminder never appears in the main app’s reminder list afterward. App Group is correctly set to `group.com.jasapart.ireminder` in both Runner and ShareExtension, and the app has been deleted/reinstalled. Need diagnosis of why the pending reminder written by the Share Extension is not being imported into the main app.