import Foundation

final class PendingReminderStore {
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
    fileManager.containerURL(
      forSecurityApplicationGroupIdentifier: appGroupIdentifier
    )
  }

  func sharedImagesDirectoryURL() throws -> URL {
    guard let containerURL = sharedContainerURL() else {
      throw PendingReminderStoreError.appGroupUnavailable
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
      throw PendingReminderStoreError.appGroupUnavailable
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
  }

  func fetchAll() -> [PendingReminderEnvelope] {
    guard let directoryURL = try? pendingRemindersDirectoryURL() else {
      return []
    }

    guard let fileURLs = try? fileManager.contentsOfDirectory(
      at: directoryURL,
      includingPropertiesForKeys: nil,
      options: [.skipsHiddenFiles]
    ) else {
      return []
    }

    return fileURLs.compactMap { fileURL in
      guard
        let data = try? Data(contentsOf: fileURL),
        let reminder = try? JSONDecoder().decode(PendingReminder.self, from: data)
      else {
        return nil
      }

      return PendingReminderEnvelope(fileURL: fileURL, reminder: reminder)
    }
  }

  func removeReminderFile(named fileName: String?) {
    guard let fileName, !fileName.isEmpty, let directoryURL = try? pendingRemindersDirectoryURL() else {
      return
    }

    let fileURL = directoryURL.appendingPathComponent(fileName, isDirectory: false)
    try? fileManager.removeItem(at: fileURL)
  }
}

struct PendingReminderEnvelope {
  let fileURL: URL
  let reminder: PendingReminder

  var asDictionary: [String: Any] {
    var dictionary = reminder.asDictionary
    dictionary["fileName"] = fileURL.lastPathComponent
    return dictionary
  }
}

enum PendingReminderStoreError: Error {
  case appGroupUnavailable
}