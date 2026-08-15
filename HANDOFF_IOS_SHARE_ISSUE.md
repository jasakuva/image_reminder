# iOS Share Extension Handoff Note

## Goal

From iOS share sheet / screenshot share flow:

1. User selects **ImageReminder**.
2. Image is handed into app.
3. **Host app comes to foreground automatically**.
4. Flutter UI opens on create-reminder screen with shared image loaded.

## Current status

### Works

- Android version works.
- iOS Share Extension exists and can save shared image into App Group container.
- Flutter app can read pending shared image and open create-reminder screen.
- App Group entitlements are present on both app and extension.
- URL scheme exists in host app.

### Fails

- On iOS, host app does **not reliably come to foreground**.
- `Open App` flow was looping before; loop has been fixed.
- Current behavior still does not achieve required UX of automatic foregrounding.

## Current architecture

### Host app

- Flutter app
- Bundle ID: `com.jasapart.ireminder`

### Share extension

- Bundle ID: `com.jasapart.ireminder.ShareExtension`

### Shared storage

- App Group: `group.com.jasapart.ireminder`

### Host app URL scheme

- `imagereminder://shared-image`

## Relevant files

### iOS host app

- `/Users/m1/Desktop/IR-01/image_reminder/ios/Runner/AppDelegate.swift`
- `/Users/m1/Desktop/IR-01/image_reminder/ios/Runner/SceneDelegate.swift`
- `/Users/m1/Desktop/IR-01/image_reminder/ios/Runner/Info.plist`
- `/Users/m1/Desktop/IR-01/image_reminder/ios/Runner/Runner.entitlements`

### iOS share extension

- `/Users/m1/Desktop/IR-01/image_reminder/ios/ShareExtension/ShareViewController.swift`
- `/Users/m1/Desktop/IR-01/image_reminder/ios/ShareExtension/Info.plist`
- `/Users/m1/Desktop/IR-01/image_reminder/ios/ShareExtension/ShareExtension.entitlements`

### Flutter side

- `/Users/m1/Desktop/IR-01/image_reminder/lib/features/share/data/shared_image_receiver.dart`
- `/Users/m1/Desktop/IR-01/image_reminder/lib/app.dart`

## Current data flow

### Share extension

`ShareViewController.swift`

- Receives image from `NSExtensionItem`.
- Saves image into App Group container under `SharedImages/`.
- Stores saved path in `UserDefaults(suiteName: "group.com.jasapart.ireminder")` with key `sharedImagePath`.

### Host app

`AppDelegate.swift` + `SceneDelegate.swift`

- Listens for app activation / URL open.
- Reads pending shared image path from same App Group defaults.
- Sends it to Flutter via method channel: `com.jasapart.ireminder/shared_images`.

### Flutter

`shared_image_receiver.dart`

- Calls `getInitialSharedImage`.
- Listens for `sharedImageReceived`.
- Then `app.dart` pushes `CreateReminderScreen(initialImagePath: imagePath)`.

## Current host-app launch attempt

In `/Users/m1/Desktop/IR-01/image_reminder/ios/ShareExtension/ShareViewController.swift`

Current strategy:

- Call `extensionContext?.open(appOpenUrl)`.
- Fallback to responder-chain `openURL:`.
- If blocked, show alert / complete request.

This approach is not achieving reliable foregrounding.

## Likely problem area

Need expert review of:

- Whether Share Extension → host app foregrounding is being attempted in the right supported way.
- Whether custom URL scheme from share extension is acceptable/reliable for this UX.
- Whether a different extension/transfer pattern is needed.
- Whether current `extensionContext.open(...)` usage is valid for the target scenario.
- Whether SceneDelegate/AppDelegate integration can be improved for container app activation.

## What has already been fixed

During current debugging:

- Cleaned up extension completion behavior.
- Removed recursive alert/open loop.
- Improved share extension activation plist.
- Ensured App Group entitlements files exist.
- Validated plists and Flutter analyzer.
- Confirmed Flutter side receives shared path correctly once app is active.

## What still needs solving

### Main requirement

**Bring host app to foreground automatically after share selection on iOS**, without user manually opening app.

### Secondary requirement

When app is foregrounded, it must land directly in:

- create reminder UI
- with shared image already populated

Secondary requirement is already mostly solved.

## Recommended native iOS investigation

Please review:

1. Is **Share Extension** the right extension type for this UX?
2. Is **foregrounding host app** from this extension type supported/reliable?
3. Is there a better Apple-approved mechanism than:
   - custom URL scheme
   - `NSExtensionContext.open`
   - responder-chain `openURL:`
4. Are there native patterns used by production apps for this exact flow that should replace current approach?

## Quick project facts

- Flutter app itself should remain unless native engineer determines product needs much deeper iOS-native integration.
- Android implementation is already fine.
- This is primarily an iOS-native integration problem, not a Flutter UI problem.

## Validation already run

- `flutter analyze` → clean
- plist lint → clean
- ShareExtension build settings inspected and appear mostly correct

## Short summary for native developer

“Flutter app already handles inbound shared image correctly once app is active. iOS Share Extension can save image to App Group, but host app does not reliably come to foreground. Please redesign/review the iOS handoff mechanism so selecting the app in share sheet opens the app directly into the Flutter create-reminder UI.”