import Flutter
import UIKit

private enum RunnerAppGroupConstants {
  static let identifier = "group.com.jasapart.ireminder"
  static let pendingRemindersDirectoryName = "PendingReminders"
}

private struct RunnerPendingReminder: Codable {
  let id: String
  let title: String?
  let note: String?
  let imagePath: String
  let scheduledAt: String
  let createdAt: String
  let updatedAt: String
  let completedAt: String?
  let status: String
  let snoozeCount: Int
  let notificationId: Int
  let soundMode: String
  let lastSnoozedAt: String?
  let notificationScheduled: Bool
  let source: String

  var asDictionary: [String: Any] {
    [
      "id": id,
      "title": title as Any,
      "note": note as Any,
      "imagePath": imagePath,
      "scheduledAt": scheduledAt,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "completedAt": completedAt as Any,
      "status": status,
      "snoozeCount": snoozeCount,
      "notificationId": notificationId,
      "soundMode": soundMode,
      "lastSnoozedAt": lastSnoozedAt as Any,
      "notificationScheduled": notificationScheduled,
      "source": source,
    ]
  }
}

private final class RunnerPendingReminderStore {
  private let fileManager: FileManager
  private let appGroupIdentifier: String

  init(
    appGroupIdentifier: String = RunnerAppGroupConstants.identifier,
    fileManager: FileManager = .default
  ) {
    self.appGroupIdentifier = appGroupIdentifier
    self.fileManager = fileManager
  }

  private func pendingRemindersDirectoryURL() throws -> URL {
    guard let containerURL = fileManager.containerURL(
      forSecurityApplicationGroupIdentifier: appGroupIdentifier
    ) else {
      throw NSError(domain: "ImageReminder.Runner", code: 2001)
    }

    let directoryURL = containerURL.appendingPathComponent(
      RunnerAppGroupConstants.pendingRemindersDirectoryName,
      isDirectory: true
    )
    try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    return directoryURL
  }

  func fetchAll() -> [[String: Any]] {
    guard let directoryURL = try? pendingRemindersDirectoryURL() else {
      print("[Runner] Could not access PendingReminders directory in app group")
      return []
    }

    print("[Runner] Reading PendingReminders from: \(directoryURL.path)")

    guard let fileURLs = try? fileManager.contentsOfDirectory(
      at: directoryURL,
      includingPropertiesForKeys: nil,
      options: [.skipsHiddenFiles]
    ) else {
      print("[Runner] Could not list PendingReminders directory")
      return []
    }

    print("[Runner] Found \(fileURLs.count) pending reminder file(s)")

    return fileURLs.compactMap { fileURL in
      guard
        let data = try? Data(contentsOf: fileURL),
        let reminder = try? JSONDecoder().decode(RunnerPendingReminder.self, from: data)
      else {
        print("[Runner] Failed to decode pending reminder file: \(fileURL.lastPathComponent)")
        return nil
      }

      var dictionary = reminder.asDictionary
      dictionary["fileName"] = fileURL.lastPathComponent
      print("[Runner] Loaded pending reminder id=\(reminder.id) file=\(fileURL.lastPathComponent)")
      return dictionary
    }
  }

  func removeReminderFile(named fileName: String?) {
    guard let fileName, !fileName.isEmpty, let directoryURL = try? pendingRemindersDirectoryURL() else {
      print("[Runner] Could not remove pending reminder file: invalid filename or directory unavailable")
      return
    }

    let fileURL = directoryURL.appendingPathComponent(fileName, isDirectory: false)
    try? fileManager.removeItem(at: fileURL)
    print("[Runner] Removed pending reminder file: \(fileURL.lastPathComponent)")
  }
}

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let sharedImageChannelName = "com.jasapart.ireminder/shared_images"
  private var sharedImageChannel: FlutterMethodChannel?
  private let pendingReminderStore = RunnerPendingReminderStore()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let didFinishLaunching = super.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )
    configureSharedImageChannel()
    return didFinishLaunching
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    configureSharedImageChannel()
  }

  private func configureSharedImageChannel() {
    guard
      sharedImageChannel == nil,
      let controller = findFlutterViewController()
    else {
      return
    }

    sharedImageChannel = FlutterMethodChannel(
      name: sharedImageChannelName,
      binaryMessenger: controller.binaryMessenger
    )
    sharedImageChannel?.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(nil)
        return
      }

      switch call.method {
      case "fetchPendingReminderImports":
        result(self.pendingReminderStore.fetchAll())
      case "markPendingReminderImported":
        let arguments = call.arguments as? [String: Any]
        self.pendingReminderStore.removeReminderFile(named: arguments?["fileName"] as? String)
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func findFlutterViewController() -> FlutterViewController? {
    if let controller = window?.rootViewController as? FlutterViewController {
      return controller
    }

    for scene in UIApplication.shared.connectedScenes {
      guard let windowScene = scene as? UIWindowScene else {
        continue
      }

      for window in windowScene.windows {
        if let controller = window.rootViewController as? FlutterViewController {
          return controller
        }
      }
    }

    return nil
  }
}
