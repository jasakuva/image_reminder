import Flutter
import UIKit

private enum RunnerAppGroupConstants {
  static let identifier = "group.com.jasapart.ireminder"
  static let pendingRemindersDirectoryName = "PendingReminders"
  static let premiumKey = "isPremium"
  static let activeReminderCountKey = "activeReminderCount"
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

    if let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
      print("[Runner] App Group container: \(containerURL.path)")
    }
    print("[Runner] Reading PendingReminders from: \(directoryURL.path)")
    print("[Runner] PendingReminders directory: \(directoryURL.path)")

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
      let data: Data
      do {
        data = try Data(contentsOf: fileURL)
      } catch {
        print("[Runner] Failed to read pending reminder file: \(fileURL.lastPathComponent) error=\(error)")
        return nil
      }

      let reminder: RunnerPendingReminder
      do {
        reminder = try JSONDecoder().decode(RunnerPendingReminder.self, from: data)
      } catch {
        print("[Runner] Failed to decode pending reminder file: \(fileURL.lastPathComponent) error=\(error)")
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
  private let sharedImagePluginKey = "ImageReminderSharedImages"
  private var sharedImageChannel: FlutterMethodChannel?
  private let pendingReminderStore = RunnerPendingReminderStore()
  private var sharedImageRegistrar: FlutterPluginRegistrar?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let didFinishLaunching = super.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )
    return didFinishLaunching
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    sharedImageRegistrar = engineBridge.pluginRegistry.registrar(
      forPlugin: sharedImagePluginKey
    )
    configureSharedImageChannel()
  }

  private func configureSharedImageChannel() {
    guard sharedImageChannel == nil, let registrar = sharedImageRegistrar else {
      return
    }

    sharedImageChannel = FlutterMethodChannel(
      name: sharedImageChannelName,
      binaryMessenger: registrar.messenger()
    )
    print("[Runner] shared_images MethodChannel registered")
    sharedImageChannel?.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(nil)
        return
      }

      switch call.method {
      case "fetchPendingReminderImports":
        print("[Runner] fetchPendingReminderImports called")
        result(self.pendingReminderStore.fetchAll())
      case "markPendingReminderImported":
        let arguments = call.arguments as? [String: Any]
        self.pendingReminderStore.removeReminderFile(named: arguments?["fileName"] as? String)
        result(nil)
      case "syncPremiumAccessState":
        let arguments = call.arguments as? [String: Any]
        let defaults = UserDefaults(suiteName: RunnerAppGroupConstants.identifier)
        defaults?.set(arguments?["isPremium"] as? Bool ?? false, forKey: RunnerAppGroupConstants.premiumKey)
        defaults?.set(arguments?["activeReminderCount"] as? Int ?? 0, forKey: RunnerAppGroupConstants.activeReminderCountKey)
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
