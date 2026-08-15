import UniformTypeIdentifiers
import UIKit

final class ShareViewController: UIViewController {
  private let appGroupIdentifier = "group.com.jasapart.ireminder"
  private let sharedImagePathKey = "sharedImagePath"
  private let appOpenUrl = URL(string: "imagereminder://shared-image")!
  private var didStartHandlingShare = false
  private var didAttemptToOpenMainApp = false
  private var isShowingImportSavedAlert = false

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    guard !didStartHandlingShare else {
      return
    }

    didStartHandlingShare = true
    handleSharedImage()
  }

  private func handleSharedImage() {
    guard
      let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
      let attachments = extensionItem.attachments
    else {
      completeRequest()
      return
    }

    let imageTypeIdentifier = UTType.image.identifier
    guard let imageProvider = attachments.first(where: {
      $0.hasItemConformingToTypeIdentifier(imageTypeIdentifier)
    }) else {
      completeRequest()
      return
    }

    imageProvider.loadItem(forTypeIdentifier: imageTypeIdentifier, options: nil) { [weak self] item, _ in
      guard let self else { return }

      let savedPath = self.saveSharedImage(item)
      if let savedPath {
        UserDefaults(suiteName: self.appGroupIdentifier)?.set(savedPath, forKey: self.sharedImagePathKey)
      }

      DispatchQueue.main.async {
        if savedPath != nil {
          self.openMainApp()
          return
        }

        self.completeRequest()
      }
    }
  }

  private func saveSharedImage(_ item: NSSecureCoding?) -> String? {
    guard
      let containerUrl = FileManager.default.containerURL(
        forSecurityApplicationGroupIdentifier: appGroupIdentifier
      )
    else {
      return nil
    }

    let sharedImagesUrl = containerUrl.appendingPathComponent("SharedImages", isDirectory: true)
    do {
      try FileManager.default.createDirectory(
        at: sharedImagesUrl,
        withIntermediateDirectories: true
      )

      if let fileUrl = item as? URL {
        let fileExtension = fileUrl.pathExtension.isEmpty ? "jpg" : fileUrl.pathExtension
        let destinationUrl = sharedImagesUrl.appendingPathComponent(
          "shared_image_\(Int(Date().timeIntervalSince1970 * 1000)).\(fileExtension)"
        )
        try? FileManager.default.removeItem(at: destinationUrl)
        try FileManager.default.copyItem(at: fileUrl, to: destinationUrl)
        return destinationUrl.path
      }

      if let image = item as? UIImage, let data = image.jpegData(compressionQuality: 0.92) {
        let destinationUrl = sharedImagesUrl.appendingPathComponent(
          "shared_image_\(Int(Date().timeIntervalSince1970 * 1000)).jpg"
        )
        try data.write(to: destinationUrl, options: .atomic)
        return destinationUrl.path
      }

      if let data = item as? Data {
        let destinationUrl = sharedImagesUrl.appendingPathComponent(
          "shared_image_\(Int(Date().timeIntervalSince1970 * 1000)).jpg"
        )
        try data.write(to: destinationUrl, options: .atomic)
        return destinationUrl.path
      }
    } catch {
      return nil
    }

    return nil
  }

  private func openMainApp() {
    guard !didAttemptToOpenMainApp else {
      if !isShowingImportSavedAlert {
        presentImportSavedAlert()
      }
      return
    }

    didAttemptToOpenMainApp = true

    extensionContext?.open(appOpenUrl) { [weak self] success in
      guard let self else { return }

      if !success {
        self.openMainAppViaResponderChain()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
          if !self.isShowingImportSavedAlert {
            self.presentImportSavedAlert()
          }
        }
        return
      }

      self.completeRequest()
    }
  }

  private func openMainAppViaResponderChain() {
    let openUrlSelector = NSSelectorFromString("openURL:")
    var responder: UIResponder? = self

    while let currentResponder = responder {
      if currentResponder.responds(to: openUrlSelector) {
        currentResponder.perform(openUrlSelector, with: appOpenUrl)
        return
      }

      responder = currentResponder.next
    }
  }

  private func completeRequest() {
    extensionContext?.completeRequest(returningItems: nil)
  }

  private func presentImportSavedAlert() {
    guard !isShowingImportSavedAlert else {
      return
    }

    isShowingImportSavedAlert = true

    let alert = UIAlertController(
      title: "Saved to ImageReminder",
      message: "The image was saved. If the app did not open automatically, close this sheet and open ImageReminder manually.",
      preferredStyle: .alert
    )

    alert.addAction(
      UIAlertAction(title: "Open App", style: .default) { [weak self] _ in
        self?.isShowingImportSavedAlert = false
        self?.completeRequest()
      }
    )
    alert.addAction(
      UIAlertAction(title: "Done", style: .cancel) { [weak self] _ in
        self?.isShowingImportSavedAlert = false
        self?.completeRequest()
      }
    )

    present(alert, animated: true)
  }
}
