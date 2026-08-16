# iOS Share Debug Code Dump
## ShareViewController.swift
Path: `ios/ShareExtension/ShareViewController.swift`
```
import UniformTypeIdentifiers
import UIKit
import UserNotifications

private enum AppGroupConstants {
  static let identifier = "group.com.jasapart.ireminder"
  static let sharedImagesDirectoryName = "SharedImages"
  static let pendingRemindersDirectoryName = "PendingReminders"
  static let notificationSoundFile = "reminder_alarm.wav"
}

private struct PendingReminder: Codable {
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
}

private final class PendingReminderStore {
  private let fileManager: FileManager
  private let appGroupIdentifier: String

  init(
    appGroupIdentifier: String = AppGroupConstants.identifier,
    fileManager: FileManager = .default
  ) {
    self.appGroupIdentifier = appGroupIdentifier
    self.fileManager = fileManager
  }

  func sharedContainerURL() -> URL? {
    fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)
  }

  func sharedImagesDirectoryURL() throws -> URL {
    guard let containerURL = sharedContainerURL() else {
      throw NSError(domain: "ImageReminder.ShareExtension", code: 1001)
    }

    let directoryURL = containerURL.appendingPathComponent(
      AppGroupConstants.sharedImagesDirectoryName,
      isDirectory: true
    )
    try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    return directoryURL
  }

  func pendingRemindersDirectoryURL() throws -> URL {
    guard let containerURL = sharedContainerURL() else {
      throw NSError(domain: "ImageReminder.ShareExtension", code: 1002)
    }

    let directoryURL = containerURL.appendingPathComponent(
      AppGroupConstants.pendingRemindersDirectoryName,
      isDirectory: true
    )
    try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    return directoryURL
  }

  func save(_ reminder: PendingReminder) throws {
    let fileURL = try pendingRemindersDirectoryURL().appendingPathComponent(
      "\(reminder.id).json",
      isDirectory: false
    )
    let data = try JSONEncoder().encode(reminder)
    try data.write(to: fileURL, options: .atomic)
    print("[ShareExtension] Saved pending reminder file at: \(fileURL.path)")
  }
}

private final class ExtensionNotificationScheduler {
  private let center: UNUserNotificationCenter

  init(center: UNUserNotificationCenter = .current()) {
    self.center = center
  }

  func scheduleIfAuthorized(reminder: PendingReminder, completion: @escaping (Bool) -> Void) {
    center.getNotificationSettings { [weak self] settings in
      guard let self else {
        completion(false)
        return
      }

      guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
        print("[ShareExtension] Notification scheduling skipped: authorization status = \(settings.authorizationStatus.rawValue)")
        completion(false)
        return
      }

      guard let scheduledDate = ISO8601DateFormatter().date(from: reminder.scheduledAt), scheduledDate > Date() else {
        print("[ShareExtension] Notification scheduling skipped: invalid or past scheduled date = \(reminder.scheduledAt)")
        completion(false)
        return
      }

      let content = UNMutableNotificationContent()
      content.title = "Picture reminder"
      content.body = "Tap to view your saved picture."
      content.sound = .default
      content.userInfo = [
        "type": "reminder",
        "reminderId": reminder.id,
      ]

      let calendar = Calendar.current
      let components = calendar.dateComponents(
        [.year, .month, .day, .hour, .minute, .second],
        from: scheduledDate
      )
      let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
      let request = UNNotificationRequest(
        identifier: String(reminder.notificationId),
        content: content,
        trigger: trigger
      )

      self.center.add(request) { error in
        if let error {
          print("[ShareExtension] Notification scheduling failed: \(error.localizedDescription)")
          completion(false)
          return
        }

        self.center.getPendingNotificationRequests { requests in
          let identifiers = requests.map(\.identifier)
          print("[ShareExtension] Pending notification identifiers: \(identifiers)")
          let wasStored = identifiers.contains(String(reminder.notificationId))
          print("[ShareExtension] Notification stored for identifier \(reminder.notificationId): \(wasStored)")
          completion(wasStored)
        }
      }
    }
  }
}

final class ShareViewController: UIViewController {
  private enum ReminderPreset {
    case fifteenMinutes
    case oneHour
    case tomorrow
    case custom
  }

  private let reminderStore = PendingReminderStore()
  private let notificationScheduler = ExtensionNotificationScheduler()
  private let dateFormatter = ISO8601DateFormatter()

  private var didStartHandlingShare = false
  private var importedImageURL: URL?
  private var selectedReminderDate = Date().addingTimeInterval(15 * 60)

  private let titleLabel = UILabel()
  private let imageView = UIImageView()
  private let statusLabel = UILabel()
  private let remindLabel = UILabel()
  private let fifteenMinuteButton = UIButton(type: .system)
  private let oneHourButton = UIButton(type: .system)
  private let tomorrowButton = UIButton(type: .system)
  private let chooseDateButton = UIButton(type: .system)
  private let selectedDateLabel = UILabel()
  private let noteField = UITextField()
  private let saveButton = UIButton(type: .system)
  private let cancelButton = UIButton(type: .system)
  private let activityIndicator = UIActivityIndicatorView(style: .large)
  private let buttonStack = UIStackView()
  private let secondaryButtonStack = UIStackView()
  private let rootStack = UIStackView()

  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    guard !didStartHandlingShare else {
      return
    }

    didStartHandlingShare = true
    handleSharedImage()
  }

  private func configureUI() {
    view.backgroundColor = .systemBackground

    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.text = "ImageReminder"
    titleLabel.font = .systemFont(ofSize: 28, weight: .semibold)
    titleLabel.textAlignment = .center

    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    imageView.layer.cornerRadius = 16
    imageView.clipsToBounds = true
    imageView.backgroundColor = .secondarySystemBackground
    imageView.heightAnchor.constraint(equalToConstant: 220).isActive = true

    statusLabel.translatesAutoresizingMaskIntoConstraints = false
    statusLabel.font = .systemFont(ofSize: 15)
    statusLabel.textColor = .secondaryLabel
    statusLabel.textAlignment = .center
    statusLabel.numberOfLines = 0
    statusLabel.text = "Loading image…"

    remindLabel.translatesAutoresizingMaskIntoConstraints = false
    remindLabel.text = "Remind me:"
    remindLabel.font = .systemFont(ofSize: 17, weight: .semibold)

    configurePresetButton(fifteenMinuteButton, title: "15 min", action: #selector(selectFifteenMinutes))
    configurePresetButton(oneHourButton, title: "1 hour", action: #selector(selectOneHour))
    configurePresetButton(tomorrowButton, title: "Tomorrow", action: #selector(selectTomorrow))
    configurePresetButton(chooseDateButton, title: "Choose date & time", action: #selector(selectCustomDate))

    buttonStack.translatesAutoresizingMaskIntoConstraints = false
    buttonStack.axis = .horizontal
    buttonStack.spacing = 12
    buttonStack.distribution = .fillEqually
    buttonStack.addArrangedSubview(fifteenMinuteButton)
    buttonStack.addArrangedSubview(oneHourButton)

    secondaryButtonStack.translatesAutoresizingMaskIntoConstraints = false
    secondaryButtonStack.axis = .horizontal
    secondaryButtonStack.spacing = 12
    secondaryButtonStack.distribution = .fillEqually
    secondaryButtonStack.addArrangedSubview(tomorrowButton)
    secondaryButtonStack.addArrangedSubview(chooseDateButton)

    selectedDateLabel.translatesAutoresizingMaskIntoConstraints = false
    selectedDateLabel.font = .systemFont(ofSize: 15, weight: .medium)
    selectedDateLabel.textColor = .label
    selectedDateLabel.numberOfLines = 0

    noteField.translatesAutoresizingMaskIntoConstraints = false
    noteField.borderStyle = .roundedRect
    noteField.placeholder = "Optional reminder note"
    noteField.clearButtonMode = .whileEditing

    saveButton.translatesAutoresizingMaskIntoConstraints = false
    saveButton.configuration = .filled()
    saveButton.setTitle("Save", for: .normal)
    saveButton.addTarget(self, action: #selector(saveReminder), for: .touchUpInside)
    saveButton.isEnabled = false

    cancelButton.translatesAutoresizingMaskIntoConstraints = false
    cancelButton.configuration = .bordered()
    cancelButton.setTitle("Cancel", for: .normal)
    cancelButton.addTarget(self, action: #selector(cancelShare), for: .touchUpInside)

    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    activityIndicator.startAnimating()

    let footerStack = UIStackView(arrangedSubviews: [cancelButton, saveButton])
    footerStack.translatesAutoresizingMaskIntoConstraints = false
    footerStack.axis = .horizontal
    footerStack.spacing = 12
    footerStack.distribution = .fillEqually

    rootStack.translatesAutoresizingMaskIntoConstraints = false
    rootStack.axis = .vertical
    rootStack.spacing = 16
    rootStack.addArrangedSubview(titleLabel)
    rootStack.addArrangedSubview(imageView)
    rootStack.addArrangedSubview(statusLabel)
    rootStack.addArrangedSubview(remindLabel)
    rootStack.addArrangedSubview(buttonStack)
    rootStack.addArrangedSubview(secondaryButtonStack)
    rootStack.addArrangedSubview(selectedDateLabel)
    rootStack.addArrangedSubview(noteField)
    rootStack.addArrangedSubview(footerStack)

    view.addSubview(rootStack)
    view.addSubview(activityIndicator)

    NSLayoutConstraint.activate([
      rootStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      rootStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      rootStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
      rootStack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),

      activityIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
      activityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
    ])

    updateSelectedDateLabel()
    setSelectedPreset(.fifteenMinutes)
  }

  private func configurePresetButton(_ button: UIButton, title: String, action: Selector) {
    button.configuration = .bordered()
    button.setTitle(title, for: .normal)
    button.addTarget(self, action: action, for: .touchUpInside)
  }

  private func handleSharedImage() {
    guard
      let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
      let attachments = extensionItem.attachments
    else {
      showError(message: "Could not read the shared image.")
      return
    }

    let provider = attachments.first { itemProvider in
      itemProvider.hasItemConformingToTypeIdentifier(UTType.png.identifier) ||
      itemProvider.hasItemConformingToTypeIdentifier(UTType.jpeg.identifier) ||
      itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier)
    }

    guard let provider else {
      showError(message: "Only images are supported right now.")
      return
    }

    loadImage(from: provider)
  }

  private func loadImage(from provider: NSItemProvider) {
    let preferredType: String
    if provider.hasItemConformingToTypeIdentifier(UTType.png.identifier) {
      preferredType = UTType.png.identifier
    } else if provider.hasItemConformingToTypeIdentifier(UTType.jpeg.identifier) {
      preferredType = UTType.jpeg.identifier
    } else {
      preferredType = UTType.image.identifier
    }

    provider.loadItem(forTypeIdentifier: preferredType, options: nil) { [weak self] item, _ in
      guard let self else { return }

      let importedURL = self.copySharedImageToAppGroup(item: item, preferredType: preferredType)

      DispatchQueue.main.async {
        self.activityIndicator.stopAnimating()

        guard let importedURL else {
          self.showError(message: "Could not save this image. Please try again.")
          return
        }

        self.importedImageURL = importedURL
        self.imageView.image = UIImage(contentsOfFile: importedURL.path)
        self.statusLabel.text = "Choose when you want to be reminded."
        self.saveButton.isEnabled = true
      }
    }
  }

  private func copySharedImageToAppGroup(item: NSSecureCoding?, preferredType: String) -> URL? {
    do {
      let sharedImagesDirectoryURL = try reminderStore.sharedImagesDirectoryURL()
      let imageID = UUID().uuidString
      let fileExtension = fileExtensionFor(item: item, preferredType: preferredType)
      let destinationURL = sharedImagesDirectoryURL.appendingPathComponent(
        "\(imageID).\(fileExtension)",
        isDirectory: false
      )

      if let fileURL = item as? URL {
        try fileManagerSafeCopy(sourceURL: fileURL, destinationURL: destinationURL)
        return destinationURL
      }

      if let image = item as? UIImage {
        if fileExtension == "png", let data = image.pngData() {
          try data.write(to: destinationURL, options: .atomic)
          return destinationURL
        }

        if let data = image.jpegData(compressionQuality: 0.92) {
          try data.write(to: destinationURL, options: .atomic)
          return destinationURL
        }
      }

      if let data = item as? Data {
        try data.write(to: destinationURL, options: .atomic)
        return destinationURL
      }
    } catch {
      return nil
    }

    return nil
  }

  private func fileManagerSafeCopy(sourceURL: URL, destinationURL: URL) throws {
    try? FileManager.default.removeItem(at: destinationURL)
    try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
  }

  private func fileExtensionFor(item: NSSecureCoding?, preferredType: String) -> String {
    if preferredType == UTType.png.identifier {
      return "png"
    }

    if preferredType == UTType.jpeg.identifier {
      return "jpg"
    }

    if let fileURL = item as? URL, !fileURL.pathExtension.isEmpty {
      return fileURL.pathExtension.lowercased()
    }

    return "jpg"
  }

  private func setSelectedPreset(_ preset: ReminderPreset) {
    let buttons: [(UIButton, ReminderPreset)] = [
      (fifteenMinuteButton, .fifteenMinutes),
      (oneHourButton, .oneHour),
      (tomorrowButton, .tomorrow),
      (chooseDateButton, .custom),
    ]

    for (button, currentPreset) in buttons {
      var configuration = button.configuration ?? .bordered()
      configuration.baseBackgroundColor = currentPreset == preset ? .systemBlue : .clear
      configuration.baseForegroundColor = currentPreset == preset ? .white : .systemBlue
      button.configuration = configuration
    }
  }

  private func updateSelectedDateLabel() {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    selectedDateLabel.text = "Selected time: \(formatter.string(from: selectedReminderDate))"
  }

  @objc private func selectFifteenMinutes() {
    selectedReminderDate = Date().addingTimeInterval(15 * 60)
    setSelectedPreset(.fifteenMinutes)
    updateSelectedDateLabel()
  }

  @objc private func selectOneHour() {
    selectedReminderDate = Date().addingTimeInterval(60 * 60)
    setSelectedPreset(.oneHour)
    updateSelectedDateLabel()
  }

  @objc private func selectTomorrow() {
    let calendar = Calendar.current
    let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date().addingTimeInterval(24 * 60 * 60)
    selectedReminderDate = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: tomorrow) ?? tomorrow
    setSelectedPreset(.tomorrow)
    updateSelectedDateLabel()
  }

  @objc private func selectCustomDate() {
    let alertController = UIAlertController(title: "Choose date & time", message: "\n\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)

    let picker = UIDatePicker(frame: CGRect(x: 0, y: 24, width: 270, height: 180))
    picker.datePickerMode = .dateAndTime
    picker.preferredDatePickerStyle = .wheels
    picker.minimumDate = Date().addingTimeInterval(60)
    picker.date = max(selectedReminderDate, picker.minimumDate ?? Date())
    alertController.view.addSubview(picker)

    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    alertController.addAction(UIAlertAction(title: "Set", style: .default) { [weak self] _ in
      guard let self else { return }
      self.selectedReminderDate = picker.date
      self.setSelectedPreset(.custom)
      self.updateSelectedDateLabel()
    })

    if let popover = alertController.popoverPresentationController {
      popover.sourceView = chooseDateButton
      popover.sourceRect = chooseDateButton.bounds
    }

    present(alertController, animated: true)
  }

  @objc private func saveReminder() {
    guard let imageURL = importedImageURL else {
      showError(message: "Could not save this image. Please try again.")
      return
    }

    guard selectedReminderDate > Date() else {
      showError(message: "Please choose a time in the future.")
      return
    }

    saveButton.isEnabled = false
    cancelButton.isEnabled = false
    statusLabel.text = "Saving reminder…"

    let reminderID = UUID().uuidString
    let createdAt = Date()
    let note = noteField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
    let normalizedNote = note?.isEmpty == true ? nil : note
    let pendingReminder = PendingReminder(
      id: reminderID,
      title: nil,
      note: normalizedNote,
      imagePath: imageURL.path,
      scheduledAt: dateFormatter.string(from: selectedReminderDate),
      createdAt: dateFormatter.string(from: createdAt),
      updatedAt: dateFormatter.string(from: createdAt),
      completedAt: nil,
      status: "active",
      snoozeCount: 0,
      notificationId: notificationID(for: reminderID),
      soundMode: "notification",
      lastSnoozedAt: nil,
      notificationScheduled: false,
      source: "share_extension"
    )

    notificationScheduler.scheduleIfAuthorized(reminder: pendingReminder) { [weak self] scheduled in
      guard let self else { return }
      let finalizedReminder = PendingReminder(
        id: pendingReminder.id,
        title: pendingReminder.title,
        note: pendingReminder.note,
        imagePath: pendingReminder.imagePath,
        scheduledAt: pendingReminder.scheduledAt,
        createdAt: pendingReminder.createdAt,
        updatedAt: pendingReminder.updatedAt,
        completedAt: pendingReminder.completedAt,
        status: pendingReminder.status,
        snoozeCount: pendingReminder.snoozeCount,
        notificationId: pendingReminder.notificationId,
        soundMode: pendingReminder.soundMode,
        lastSnoozedAt: pendingReminder.lastSnoozedAt,
        notificationScheduled: scheduled,
        source: pendingReminder.source
      )

      do {
        try self.reminderStore.save(finalizedReminder)
        DispatchQueue.main.async {
          let message = scheduled
            ? "Reminder saved and notification scheduled."
            : "Reminder saved, but notification was not scheduled. Check notification permission in the main app."
          self.showSaveSuccess(message: message)
        }
      } catch {
        DispatchQueue.main.async {
          self.saveButton.isEnabled = true
          self.cancelButton.isEnabled = true
          self.showError(message: "Could not save the reminder. Please try again.")
        }
      }
    }
  }

  @objc private func cancelShare() {
    cleanupImportedImageIfNeeded()
    extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
  }

  private func cleanupImportedImageIfNeeded() {
    guard let importedImageURL else {
      return
    }

    try? FileManager.default.removeItem(at: importedImageURL)
    self.importedImageURL = nil
  }

  private func showError(message: String) {
    statusLabel.text = message
    let alert = UIAlertController(title: "ImageReminder", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Close", style: .default) { [weak self] _ in
      self?.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    })
    present(alert, animated: true)
  }

  private func showSaveSuccess(message: String) {
    statusLabel.text = message
    let alert = UIAlertController(title: "ImageReminder", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
      self?.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    })
    present(alert, animated: true)
  }

  private func notificationID(for reminderID: String) -> Int {
    abs(reminderID.hashValue) % 2147483647
  }
}
```

## AppDelegate.swift
Path: `ios/Runner/AppDelegate.swift`
```
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
```

## reminder_store.dart
Path: `lib/features/reminders/data/reminder_store.dart`
```
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../notifications/data/local_notification_service.dart';
import '../../share/data/shared_image_receiver.dart';
import '../domain/reminder_sound_mode.dart';
import '../domain/picture_reminder.dart';
import '../domain/reminder_status.dart';

class ReminderStore extends ChangeNotifier {
  ReminderStore({LocalNotificationService? notificationService})
    : _notificationService = notificationService ?? LocalNotificationService();

  static const _storageKey = 'picture_reminders';

  final LocalNotificationService _notificationService;
  final List<PictureReminder> _reminders = [];
  final SharedImageReceiver _sharedImageReceiver = SharedImageReceiver();

  LocalNotificationService get notificationService => _notificationService;

  List<PictureReminder> get reminders {
    final sorted = [..._reminders]
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return List.unmodifiable(sorted);
  }

  Future<void> load() async {
    await _notificationService.initialize();

    final preferences = await SharedPreferences.getInstance();
    final rawJson = preferences.getString(_storageKey);
    if (rawJson != null && rawJson.isNotEmpty) {
      final decoded = jsonDecode(rawJson) as List<dynamic>;
      _reminders
        ..clear()
        ..addAll(
          decoded.cast<Map<String, Object?>>().map(PictureReminder.fromJson),
        );
    }

    await importPendingReminders();
  }

  Future<void> importPendingReminders() async {
    await _importPendingReminders();
  }

  PictureReminder? findById(String id) {
    for (final reminder in _reminders) {
      if (reminder.id == id) {
        return reminder;
      }
    }
    return null;
  }

  Future<void> add(PictureReminder reminder) async {
    _reminders.add(reminder);
    await _notificationService.scheduleReminder(reminder);
    await _saveAndNotify();
  }

  Future<void> _importPendingReminders() async {
    if (kIsWeb || !Platform.isIOS) {
      return;
    }

    await _sharedImageReceiver.loadInitialSharedImage();
    final pendingImports = _sharedImageReceiver.pendingReminderImports.value;
    debugPrint('[ReminderStore] Pending iOS reminder imports: ${pendingImports.length}');
    if (pendingImports.isEmpty) {
      return;
    }

    var didChange = false;
    for (final pendingImport in pendingImports) {
      debugPrint('[ReminderStore] Importing pending reminder id=${pendingImport.id} file=${pendingImport.fileName}');
      if (findById(pendingImport.id) != null) {
        debugPrint('[ReminderStore] Reminder already exists, marking imported: ${pendingImport.id}');
        await _sharedImageReceiver.markPendingReminderImported(pendingImport.fileName);
        continue;
      }

      final reminder = PictureReminder(
        id: pendingImport.id,
        title: pendingImport.title,
        note: pendingImport.note,
        imagePath: pendingImport.imagePath,
        scheduledAt: pendingImport.scheduledAt,
        createdAt: pendingImport.createdAt,
        updatedAt: pendingImport.updatedAt,
        completedAt: pendingImport.completedAt,
        status: ReminderStatus.fromName(pendingImport.status),
        snoozeCount: pendingImport.snoozeCount,
        notificationId: pendingImport.notificationId,
        soundMode: ReminderSoundMode.fromName(pendingImport.soundMode),
        lastSnoozedAt: pendingImport.lastSnoozedAt,
      );

      _reminders.add(reminder);
      if (!pendingImport.notificationScheduled) {
        debugPrint('[ReminderStore] Scheduling imported reminder in Flutter: ${pendingImport.id}');
        await _notificationService.scheduleReminder(reminder);
      } else {
        debugPrint('[ReminderStore] Native notification already scheduled for: ${pendingImport.id}');
      }
      await _sharedImageReceiver.markPendingReminderImported(pendingImport.fileName);
      didChange = true;
    }

    if (didChange) {
      await _saveAndNotify();
    }
  }

  Future<void> markCompleted(String id) async {
    final index = _reminders.indexWhere((reminder) => reminder.id == id);
    if (index == -1) {
      return;
    }

    final now = DateTime.now();
    final reminder = _reminders[index];
    await _notificationService.cancelReminder(reminder);

    _reminders[index] = reminder.copyWith(
      status: ReminderStatus.completed,
      completedAt: now,
      updatedAt: now,
    );
    await _saveAndNotify();
  }

  Future<void> snooze(String id, Duration duration) async {
    final index = _reminders.indexWhere((reminder) => reminder.id == id);
    if (index == -1) {
      return;
    }

    final now = DateTime.now();
    final reminder = _reminders[index];
    await _notificationService.cancelReminder(reminder);

    final snoozedReminder = reminder.copyWith(
      scheduledAt: now.add(duration),
      updatedAt: now,
      status: ReminderStatus.active,
      snoozeCount: reminder.snoozeCount + 1,
      lastSnoozedAt: now,
    );
    _reminders[index] = snoozedReminder;
    await _notificationService.scheduleReminder(snoozedReminder);
    await _saveAndNotify();
  }

  Future<void> delete(String id) async {
    final index = _reminders.indexWhere((reminder) => reminder.id == id);
    if (index == -1) {
      return;
    }

    final reminder = _reminders.removeAt(index);
    await _notificationService.cancelReminder(reminder);
    final imageFile = File(reminder.imagePath);
    if (await imageFile.exists()) {
      await imageFile.delete();
    }
    await _saveAndNotify();
  }

  Future<void> _saveAndNotify() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      _reminders.map((reminder) => reminder.toJson()).toList(),
    );
    await preferences.setString(_storageKey, encoded);
    notifyListeners();
  }
}
```

## shared_image_receiver.dart
Path: `lib/features/share/data/shared_image_receiver.dart`
```
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PendingReminderImport {
  PendingReminderImport({
    required this.fileName,
    required this.id,
    required this.imagePath,
    required this.scheduledAt,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.snoozeCount,
    required this.notificationId,
    required this.soundMode,
    required this.notificationScheduled,
    required this.source,
    this.title,
    this.note,
    this.completedAt,
    this.lastSnoozedAt,
  });

  final String fileName;
  final String id;
  final String? title;
  final String? note;
  final String imagePath;
  final DateTime scheduledAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final String status;
  final int snoozeCount;
  final int notificationId;
  final String soundMode;
  final DateTime? lastSnoozedAt;
  final bool notificationScheduled;
  final String source;

  factory PendingReminderImport.fromMap(Map<Object?, Object?> map) {
    DateTime? parseOptionalDate(Object? value) {
      if (value is! String || value.isEmpty) {
        return null;
      }
      return DateTime.parse(value);
    }

    return PendingReminderImport(
      fileName: map['fileName'] as String,
      id: map['id'] as String,
      title: map['title'] as String?,
      note: map['note'] as String?,
      imagePath: map['imagePath'] as String,
      scheduledAt: DateTime.parse(map['scheduledAt'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      completedAt: parseOptionalDate(map['completedAt']),
      status: map['status'] as String? ?? 'active',
      snoozeCount: (map['snoozeCount'] as num?)?.toInt() ?? 0,
      notificationId: (map['notificationId'] as num?)?.toInt() ?? 0,
      soundMode: map['soundMode'] as String? ?? 'notification',
      lastSnoozedAt: parseOptionalDate(map['lastSnoozedAt']),
      notificationScheduled: map['notificationScheduled'] as bool? ?? false,
      source: map['source'] as String? ?? 'unknown',
    );
  }
}

class SharedImageReceiver {
  SharedImageReceiver() {
    _platformChannel.setMethodCallHandler(_handleMethodCall);
  }

  static const _androidChannel = MethodChannel(
    'com.example.pic_reminder/shared_images',
  );
  static const _iosChannel = MethodChannel(
    'com.jasapart.ireminder/shared_images',
  );

  final ValueNotifier<String?> sharedImagePath = ValueNotifier(null);
  final ValueNotifier<List<PendingReminderImport>> pendingReminderImports =
      ValueNotifier<List<PendingReminderImport>>(<PendingReminderImport>[]);

  Future<void> loadInitialSharedImage() async {
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    final String? imagePath;
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final maps = await _platformChannel.invokeMethod<List<Object?>>(
          'fetchPendingReminderImports',
        );
        if (maps == null || maps.isEmpty) {
          return;
        }

        pendingReminderImports.value = maps
            .whereType<Map<Object?, Object?>>()
            .map(PendingReminderImport.fromMap)
            .toList(growable: false);
        return;
      }

      imagePath = await _platformChannel.invokeMethod<String?>(
        'getInitialSharedImage',
      );
    } on MissingPluginException {
      return;
    }

    if (imagePath == null || imagePath.isEmpty) {
      return;
    }

    sharedImagePath.value = imagePath;
  }

  void clearSharedImage() {
    sharedImagePath.value = null;
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'sharedImageReceived') {
      final imagePath = call.arguments as String?;
      if (imagePath == null || imagePath.isEmpty) {
        return;
      }

      sharedImagePath.value = imagePath;
    }
  }

  Future<void> markPendingReminderImported(String fileName) async {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    await _platformChannel.invokeMethod<void>('markPendingReminderImported', {
      'fileName': fileName,
    });
  }

  MethodChannel get _platformChannel {
    return defaultTargetPlatform == TargetPlatform.iOS
        ? _iosChannel
        : _androidChannel;
  }
}
```

