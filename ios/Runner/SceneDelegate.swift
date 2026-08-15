import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func sceneDidBecomeActive(_ scene: UIScene) {
    super.sceneDidBecomeActive(scene)
    (UIApplication.shared.delegate as? AppDelegate)?.notifyFlutterAboutSharedImageWhenReady()
  }

  override func scene(
    _ scene: UIScene,
    openURLContexts URLContexts: Set<UIOpenURLContext>
  ) {
    super.scene(scene, openURLContexts: URLContexts)

    guard URLContexts.contains(where: { $0.url.scheme == "imagereminder" }) else {
      return
    }

    (UIApplication.shared.delegate as? AppDelegate)?.notifyFlutterAboutSharedImageWhenReady()
  }
}
