import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let sharedImageChannelName = "com.jasapart.ireminder/shared_images"
  private let appGroupIdentifier = "group.com.jasapart.ireminder"
  private let sharedImagePathKey = "sharedImagePath"
  private var sharedImageChannel: FlutterMethodChannel?
  private var pendingDeliveryWorkItem: DispatchWorkItem?
  private let maxDeliveryAttempts = 10

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let didFinishLaunching = super.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )
    configureSharedImageChannel()
    notifyFlutterAboutSharedImageWhenReady()
    return didFinishLaunching
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    notifyFlutterAboutSharedImageWhenReady()
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if url.scheme == "imagereminder" {
      notifyFlutterAboutSharedImageWhenReady()
      return true
    }

    return super.application(app, open: url, options: options)
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
      case "getInitialSharedImage":
        let sharedImagePath = self.peekSharedImagePath()
        if sharedImagePath != nil {
          self.clearSharedImagePath()
        }
        result(sharedImagePath)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  @discardableResult
  func notifyFlutterAboutSharedImage() -> Bool {
    configureSharedImageChannel()

    guard sharedImageChannel != nil else {
      return false
    }

    guard let sharedImagePath = peekSharedImagePath() else {
      return false
    }

    sharedImageChannel?.invokeMethod("sharedImageReceived", arguments: sharedImagePath)
    clearSharedImagePath()
    return true
  }

  func notifyFlutterAboutSharedImageWhenReady() {
    schedulePendingSharedImageDelivery(attempt: 0)
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

  private func schedulePendingSharedImageDelivery(attempt: Int) {
    pendingDeliveryWorkItem?.cancel()

    guard peekSharedImagePath() != nil else {
      return
    }

    let workItem = DispatchWorkItem { [weak self] in
      guard let self else {
        return
      }

      if self.notifyFlutterAboutSharedImage() {
        self.pendingDeliveryWorkItem = nil
        return
      }

      guard attempt + 1 < self.maxDeliveryAttempts else {
        self.pendingDeliveryWorkItem = nil
        return
      }

      self.schedulePendingSharedImageDelivery(attempt: attempt + 1)
    }

    pendingDeliveryWorkItem = workItem
    let delay = 0.2 + (Double(attempt) * 0.15)
    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
  }

  private func peekSharedImagePath() -> String? {
    let defaults = UserDefaults(suiteName: appGroupIdentifier)
    return defaults?.string(forKey: sharedImagePathKey)
  }

  private func clearSharedImagePath() {
    let defaults = UserDefaults(suiteName: appGroupIdentifier)
    defaults?.removeObject(forKey: sharedImagePathKey)
  }
}
