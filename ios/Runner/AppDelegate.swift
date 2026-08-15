import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let sharedImageChannelName = "com.jasapart.ireminder/shared_images"
  private let appGroupIdentifier = "group.com.jasapart.ireminder"
  private let sharedImagePathKey = "sharedImagePath"
  private var sharedImageChannel: FlutterMethodChannel?

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
        result(self.takeSharedImagePath())
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func notifyFlutterAboutSharedImage() {
    configureSharedImageChannel()

    guard sharedImageChannel != nil else {
      return
    }

    guard let sharedImagePath = takeSharedImagePath() else {
      return
    }

    sharedImageChannel?.invokeMethod("sharedImageReceived", arguments: sharedImagePath)
  }

  func notifyFlutterAboutSharedImageWhenReady() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
      self?.notifyFlutterAboutSharedImage()
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

  private func takeSharedImagePath() -> String? {
    let defaults = UserDefaults(suiteName: appGroupIdentifier)
    let sharedImagePath = defaults?.string(forKey: sharedImagePathKey)
    defaults?.removeObject(forKey: sharedImagePathKey)
    return sharedImagePath
  }
}
