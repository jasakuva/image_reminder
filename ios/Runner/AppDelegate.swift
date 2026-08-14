import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let sharedImageChannelName = "com.example.pic_reminder/shared_images"
  private let appGroupIdentifier = "group.com.example.picReminder"
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
      notifyFlutterAboutSharedImage()
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
      let controller = window?.rootViewController as? FlutterViewController
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
    guard let sharedImagePath = takeSharedImagePath() else {
      return
    }

    sharedImageChannel?.invokeMethod("sharedImageReceived", arguments: sharedImagePath)
  }

  private func takeSharedImagePath() -> String? {
    let defaults = UserDefaults(suiteName: appGroupIdentifier)
    let sharedImagePath = defaults?.string(forKey: sharedImagePathKey)
    defaults?.removeObject(forKey: sharedImagePathKey)
    return sharedImagePath
  }
}
