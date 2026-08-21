import UniformTypeIdentifiers
import UIKit
import UserNotifications

private extension String {
  var shareLocalized: String {
    NSLocalizedString(self, tableName: "ShareExtension", comment: "")
  }
}

private enum AppGroupConstants {
  static let identifier = "group.com.jasapart.ireminder"
  static let sharedImagesDirectoryName = "SharedImages"
  static let pendingRemindersDirectoryName = "PendingReminders"
  static let notificationSoundFile = "reminder_alarm.wav"
  static let premiumKey = "isPremium"
  static let activeReminderCountKey = "activeReminderCount"
}

private enum ShareSoundMode: String {
  case notification
  case alarm
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
    if let containerURL = sharedContainerURL() {
      print("[ShareExtension] App Group container: \(containerURL.path)")
    }
    print("[ShareExtension] Pending reminder: \(String(data: try JSONEncoder().encode(reminder), encoding: .utf8) ?? "<invalid json>")")

    let fileURL = try pendingRemindersDirectoryURL().appendingPathComponent(
      "\(reminder.id).json",
      isDirectory: false
    )
    let data = try JSONEncoder().encode(reminder)
    try data.write(to: fileURL, options: .atomic)
    print("[ShareExtension] Saved pending reminder file at: \(fileURL.path)")
    let fileExists = FileManager.default.fileExists(atPath: fileURL.path)
    let readBackData = try? Data(contentsOf: fileURL)
    let readBackMatches = readBackData == data
    print("[ShareExtension] JSON write verified: \(fileExists && readBackMatches)")
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
      content.title = "share.notification.title".shareLocalized
      content.body = "share.notificationBody".shareLocalized
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

final class ShareViewController: UIViewController, UITextFieldDelegate {
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
  private var selectedSoundMode: ShareSoundMode = .notification

  private let titleLabel = UILabel()
  private let imageView = UIImageView()
  private let statusLabel = UILabel()
  private let remindLabel = UILabel()
  private let soundLabel = UILabel()
  private let soundControl = UISegmentedControl()
  private let fifteenMinuteButton = UIButton(type: .system)
  private let oneHourButton = UIButton(type: .system)
  private let tomorrowButton = UIButton(type: .system)
  private let chooseDateButton = UIButton(type: .system)
  private let selectedDateLabel = UILabel()
  private let notificationTextField = UITextField()
  private let noteField = UITextField()
  private let saveButton = UIButton(type: .system)
  private let cancelButton = UIButton(type: .system)
  private let activityIndicator = UIActivityIndicatorView(style: .large)
  private let buttonStack = UIStackView()
  private let secondaryButtonStack = UIStackView()
  private let rootStack = UIStackView()
  private let scrollView = UIScrollView()

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
    titleLabel.text = "share.title".shareLocalized
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
    statusLabel.text = "share.loadingImage".shareLocalized

    remindLabel.translatesAutoresizingMaskIntoConstraints = false
    remindLabel.text = "share.remindMe".shareLocalized
    remindLabel.font = .systemFont(ofSize: 17, weight: .semibold)

    soundLabel.translatesAutoresizingMaskIntoConstraints = false
    soundLabel.text = "share.notificationType".shareLocalized
    soundLabel.font = .systemFont(ofSize: 17, weight: .semibold)

    soundControl.translatesAutoresizingMaskIntoConstraints = false
    soundControl.insertSegment(withTitle: "share.notification".shareLocalized, at: 0, animated: false)
    soundControl.insertSegment(withTitle: "share.alarm".shareLocalized, at: 1, animated: false)
    soundControl.selectedSegmentIndex = 0
    soundControl.addTarget(self, action: #selector(soundModeChanged), for: .valueChanged)

    configurePresetButton(fifteenMinuteButton, title: "share.fifteenMinutes".shareLocalized, action: #selector(selectFifteenMinutes))
    configurePresetButton(oneHourButton, title: "share.oneHour".shareLocalized, action: #selector(selectOneHour))
    configurePresetButton(tomorrowButton, title: "share.tomorrow".shareLocalized, action: #selector(selectTomorrow))
    configurePresetButton(chooseDateButton, title: "share.chooseDateTime".shareLocalized, action: #selector(selectCustomDate))

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

    notificationTextField.translatesAutoresizingMaskIntoConstraints = false
    notificationTextField.borderStyle = .roundedRect
    notificationTextField.placeholder = "share.notificationText".shareLocalized
    notificationTextField.clearButtonMode = .whileEditing
    notificationTextField.returnKeyType = .done
    configureTextFieldKeyboard(notificationTextField)

    noteField.translatesAutoresizingMaskIntoConstraints = false
    noteField.borderStyle = .roundedRect
    noteField.placeholder = "share.optionalNote".shareLocalized
    noteField.clearButtonMode = .whileEditing
    noteField.returnKeyType = .done
    configureTextFieldKeyboard(noteField)

    saveButton.translatesAutoresizingMaskIntoConstraints = false
    saveButton.configuration = .filled()
    saveButton.setTitle("share.save".shareLocalized, for: .normal)
    saveButton.addTarget(self, action: #selector(saveReminder), for: .touchUpInside)
    saveButton.isEnabled = false

    cancelButton.translatesAutoresizingMaskIntoConstraints = false
    cancelButton.configuration = .bordered()
    cancelButton.setTitle("share.cancel".shareLocalized, for: .normal)
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
    rootStack.addArrangedSubview(soundLabel)
    rootStack.addArrangedSubview(soundControl)
    rootStack.addArrangedSubview(notificationTextField)
    rootStack.addArrangedSubview(noteField)
    rootStack.addArrangedSubview(footerStack)

    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.alwaysBounceVertical = true
    scrollView.keyboardDismissMode = .interactive
    let dismissTap = UITapGestureRecognizer(
      target: self,
      action: #selector(dismissKeyboard)
    )
    dismissTap.cancelsTouchesInView = false
    scrollView.addGestureRecognizer(dismissTap)
    view.addSubview(scrollView)
    scrollView.addSubview(rootStack)
    view.addSubview(activityIndicator)

    NSLayoutConstraint.activate([
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      rootStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
      rootStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
      rootStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 12),
      rootStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
      rootStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40),

      activityIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
      activityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
    ])

    updateSelectedDateLabel()
    setSelectedPreset(.fifteenMinutes)
  }

  private func configureTextFieldKeyboard(_ textField: UITextField) {
    textField.delegate = self

    let toolbar = UIToolbar()
    toolbar.sizeToFit()
    toolbar.items = [
      UIBarButtonItem(
        barButtonSystemItem: .flexibleSpace,
        target: nil,
        action: nil
      ),
      UIBarButtonItem(
        title: "share.done".shareLocalized,
        style: .done,
        target: self,
        action: #selector(dismissKeyboard)
      ),
    ]
    textField.inputAccessoryView = toolbar
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    dismissKeyboard()
    return true
  }

  @objc private func dismissKeyboard() {
    view.endEditing(true)
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
    super.touchesBegan(touches, with: event)
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
      showError(message: "share.error.couldNotReadImage".shareLocalized)
      return
    }

    let provider = attachments.first { itemProvider in
      itemProvider.hasItemConformingToTypeIdentifier(UTType.png.identifier) ||
      itemProvider.hasItemConformingToTypeIdentifier(UTType.jpeg.identifier) ||
      itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier)
    }

    guard let provider else {
      showError(message: "share.error.onlyImagesSupported".shareLocalized)
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
          self.showError(message: "share.error.couldNotSaveImage".shareLocalized)
          return
        }

        self.importedImageURL = importedURL
        self.imageView.image = UIImage(contentsOfFile: importedURL.path)
        self.statusLabel.text = "share.chooseReminderTime".shareLocalized
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
    selectedDateLabel.text = String(
      format: "share.selectedTime".shareLocalized,
      formatter.string(from: selectedReminderDate)
    )
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
    let alertController = UIAlertController(title: "share.chooseDateTime".shareLocalized, message: "\n\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)

    let picker = UIDatePicker(frame: CGRect(x: 0, y: 24, width: 270, height: 180))
    picker.datePickerMode = .dateAndTime
    picker.preferredDatePickerStyle = .wheels
    picker.minimumDate = Date().addingTimeInterval(60)
    picker.date = max(selectedReminderDate, picker.minimumDate ?? Date())
    alertController.view.addSubview(picker)

    alertController.addAction(UIAlertAction(title: "share.cancel".shareLocalized, style: .cancel))
    alertController.addAction(UIAlertAction(title: "share.set".shareLocalized, style: .default) { [weak self] _ in
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

  @objc private func soundModeChanged() {
    selectedSoundMode = soundControl.selectedSegmentIndex == 1 ? .alarm : .notification
  }

  @objc private func saveReminder() {
    let defaults = UserDefaults(suiteName: AppGroupConstants.identifier)
    let isPremium = defaults?.bool(forKey: AppGroupConstants.premiumKey) ?? false
    let activeReminderCount = defaults?.integer(forKey: AppGroupConstants.activeReminderCountKey) ?? 0
    if !isPremium && activeReminderCount >= 2 {
      showError(
        message: "share.error.freeLimitReached".shareLocalized,
      )
      return
    }

    guard let imageURL = importedImageURL else {
      showError(message: "share.error.couldNotSaveImage".shareLocalized)
      return
    }

    guard selectedReminderDate > Date() else {
      showError(message: "share.error.chooseFutureTime".shareLocalized)
      return
    }

    saveButton.isEnabled = false
    cancelButton.isEnabled = false
    statusLabel.text = "share.savingReminder".shareLocalized

    let reminderID = UUID().uuidString
    let createdAt = Date()
    let notificationText = notificationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
    let note = noteField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
    let normalizedTitle = notificationText?.isEmpty == true ? nil : notificationText
    let normalizedNote = note?.isEmpty == true ? nil : note
    let pendingReminder = PendingReminder(
      id: reminderID,
      title: normalizedTitle,
      note: normalizedNote,
      imagePath: imageURL.path,
      scheduledAt: dateFormatter.string(from: selectedReminderDate),
      createdAt: dateFormatter.string(from: createdAt),
      updatedAt: dateFormatter.string(from: createdAt),
      completedAt: nil,
      status: "active",
      snoozeCount: 0,
      notificationId: notificationID(for: reminderID),
      soundMode: selectedSoundMode.rawValue,
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
            ? "share.success.savedAndScheduled".shareLocalized
            : "share.success.savedOnly".shareLocalized
          self.showSaveSuccess(message: message)
        }
      } catch {
        DispatchQueue.main.async {
          self.saveButton.isEnabled = true
          self.cancelButton.isEnabled = true
          self.showError(message: "share.error.couldNotSaveReminder".shareLocalized)
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
    let alert = UIAlertController(title: "share.title".shareLocalized, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "share.close".shareLocalized, style: .default) { [weak self] _ in
      self?.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    })
    present(alert, animated: true)
  }

  private func showSaveSuccess(message: String) {
    statusLabel.text = message
    let alert = UIAlertController(title: "share.title".shareLocalized, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "share.done".shareLocalized, style: .default) { [weak self] _ in
      self?.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    })
    present(alert, animated: true)
  }

  private func notificationID(for reminderID: String) -> Int {
    abs(reminderID.hashValue) % 2147483647
  }
}