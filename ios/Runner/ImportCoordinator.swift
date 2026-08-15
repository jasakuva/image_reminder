import Flutter
import Foundation
import UIKit

final class ImportCoordinator {
  private let sharedImportStore: SharedImportStore
  private var sharedImportChannel: FlutterMethodChannel?
  private var pendingDeliveryWorkItem: DispatchWorkItem?
  private let maxDeliveryAttempts = 10
  private var requestedImportID: String?
  private var flutterReadyForSharedImport = false
  private weak var importLaunchViewController: ImportLaunchViewController?

  init(appGroupIdentifier: String) {
    sharedImportStore = SharedImportStore(appGroupIdentifier: appGroupIdentifier)
  }

  func handleAppLaunch() {
    notifyFlutterAboutSharedImportWhenReady()
  }

  func handleOpenURL(_ url: URL) {
    requestedImportID = URLComponents(url: url, resolvingAgainstBaseURL: false)?
      .queryItems?
      .first(where: { $0.name == "id" })?
      .value
    presentImportLaunchViewIfNeeded()
    notifyFlutterAboutSharedImportWhenReady()
  }

  func handleSceneDidBecomeActive() {
    notifyFlutterAboutSharedImportWhenReady()
  }

  func attachFlutterChannel(_ channel: FlutterMethodChannel) {
    sharedImportChannel = channel
  }

  func markFlutterReadyForSharedImport() {
    flutterReadyForSharedImport = true
    notifyFlutterAboutSharedImportWhenReady()
  }

  func fetchInitialPendingImport() -> [String: Any]? {
    let sharedImport = sharedImportStore.pendingImport(id: requestedImportID)
    if sharedImport != nil {
      requestedImportID = nil
    }
    return sharedImport?.asDictionary
  }

  func markImportConsumed(id: String?) {
    guard let pendingImport = sharedImportStore.pendingImport() else {
      return
    }

    if id == nil || pendingImport.id == id {
      sharedImportStore.clearPendingImport()
      requestedImportID = nil
    }
  }

  @discardableResult
  func notifyFlutterAboutSharedImport() -> Bool {
    guard flutterReadyForSharedImport, let sharedImportChannel else {
      return false
    }

    guard let sharedImport = sharedImportStore.pendingImport(id: requestedImportID) else {
      return false
    }

    sharedImportChannel.invokeMethod("sharedImportReceived", arguments: sharedImport.asDictionary)
    requestedImportID = nil
    dismissImportLaunchViewIfNeeded()
    return true
  }

  func notifyFlutterAboutSharedImportWhenReady() {
    schedulePendingImportDelivery(attempt: 0)
  }

  private func schedulePendingImportDelivery(attempt: Int) {
    pendingDeliveryWorkItem?.cancel()

    guard sharedImportStore.pendingImport(id: requestedImportID) != nil else {
      return
    }

    let workItem = DispatchWorkItem { [weak self] in
      guard let self else {
        return
      }

      if self.notifyFlutterAboutSharedImport() {
        self.pendingDeliveryWorkItem = nil
        return
      }

      guard attempt + 1 < self.maxDeliveryAttempts else {
        self.pendingDeliveryWorkItem = nil
        return
      }

      self.schedulePendingImportDelivery(attempt: attempt + 1)
    }

    pendingDeliveryWorkItem = workItem
    let delay = 0.2 + (Double(attempt) * 0.15)
    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
  }

  private func presentImportLaunchViewIfNeeded() {
    guard importLaunchViewController == nil else {
      return
    }

    guard let presenter = topViewController() else {
      return
    }

    let importLaunchViewController = ImportLaunchViewController()
    importLaunchViewController.modalPresentationStyle = .fullScreen
    self.importLaunchViewController = importLaunchViewController

    if presenter.presentedViewController == nil {
      presenter.present(importLaunchViewController, animated: false)
    }
  }

  private func dismissImportLaunchViewIfNeeded() {
    guard let importLaunchViewController else {
      return
    }

    importLaunchViewController.dismiss(animated: false)
    self.importLaunchViewController = nil
  }

  private func topViewController() -> UIViewController? {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let windows = scenes.flatMap(\.windows)
    var controller = windows.first(where: \ .isKeyWindow)?.rootViewController

    while let presentedViewController = controller?.presentedViewController {
      controller = presentedViewController
    }

    return controller
  }
}