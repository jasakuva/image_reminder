import Foundation

final class SharedImportStore {
  private let defaults: UserDefaults?
  private let pendingImportKey = "pendingSharedImport"

  init(appGroupIdentifier: String) {
    defaults = UserDefaults(suiteName: appGroupIdentifier)
  }

  func save(_ sharedImport: SharedImport) throws {
    let data = try JSONEncoder().encode(sharedImport)
    defaults?.set(data, forKey: pendingImportKey)
  }

  func pendingImport() -> SharedImport? {
    guard
      let data = defaults?.data(forKey: pendingImportKey),
      let sharedImport = try? JSONDecoder().decode(SharedImport.self, from: data)
    else {
      return nil
    }

    return sharedImport
  }

  func pendingImport(id: String?) -> SharedImport? {
    guard let sharedImport = pendingImport() else {
      return nil
    }

    guard let id else {
      return sharedImport
    }

    return sharedImport.id == id ? sharedImport : nil
  }

  func clearPendingImport() {
    defaults?.removeObject(forKey: pendingImportKey)
  }
}