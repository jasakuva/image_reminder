import UniformTypeIdentifiers
import UIKit

final class ShareViewController: UIViewController {
  private let appGroupIdentifier = "group.com.jasapart.ireminder"
  private var didStartHandlingShare = false
  private lazy var sharedImportStore = SharedImportStore(appGroupIdentifier: appGroupIdentifier)
  private let activityIndicator = UIActivityIndicatorView(style: .large)
  private let titleLabel = UILabel()
  private let messageLabel = UILabel()
  private let previewImageView = UIImageView()
  private let openAppButton = UIButton(type: .system)
  private let doneButton = UIButton(type: .system)
  private var latestSavedImagePath: String?

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

  private func handleSharedImage() {
    setLoadingState()

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
      if let savedPath, let sharedImport = self.createSharedImport(imagePath: savedPath) {
        try? self.sharedImportStore.save(sharedImport)
      }

      DispatchQueue.main.async {
        if savedPath != nil {
          self.latestSavedImagePath = savedPath
          self.showImportReadyState(imagePath: savedPath!)
          return
        }

        self.messageLabel.text = "Could not import the shared image."
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
    guard let sharedImport = sharedImportStore.pendingImport() else {
      completeRequest()
      return
    }

    let appOpenUrl = URL(string: "imagereminder://import?id=\(sharedImport.id)")!
    extensionContext?.open(appOpenUrl) { [weak self] success in
      if !success {
        self?.openMainAppViaResponderChain(appOpenUrl)
      }
    }
  }

  private func openMainAppViaResponderChain(_ appOpenUrl: URL) {
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

  private func createSharedImport(imagePath: String) -> SharedImport? {
    SharedImport(
      id: UUID().uuidString,
      imagePath: imagePath,
      createdAt: Date().timeIntervalSince1970,
      source: "share_extension"
    )
  }

  private func configureUI() {
    view.backgroundColor = .systemBackground

    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    activityIndicator.startAnimating()

    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.font = .systemFont(ofSize: 26, weight: .semibold)
    titleLabel.textAlignment = .center
    titleLabel.text = "ImageReminder"

    messageLabel.translatesAutoresizingMaskIntoConstraints = false
    messageLabel.font = .systemFont(ofSize: 16)
    messageLabel.textColor = .secondaryLabel
    messageLabel.numberOfLines = 0
    messageLabel.textAlignment = .center

    previewImageView.translatesAutoresizingMaskIntoConstraints = false
    previewImageView.contentMode = .scaleAspectFit
    previewImageView.layer.cornerRadius = 16
    previewImageView.clipsToBounds = true
    previewImageView.backgroundColor = .secondarySystemBackground
    previewImageView.isHidden = true

    openAppButton.translatesAutoresizingMaskIntoConstraints = false
    openAppButton.configuration = .filled()
    openAppButton.setTitle("Open App", for: .normal)
    openAppButton.addTarget(self, action: #selector(openAppTapped), for: .touchUpInside)
    openAppButton.isHidden = true

    doneButton.translatesAutoresizingMaskIntoConstraints = false
    doneButton.configuration = .bordered()
    doneButton.setTitle("Done", for: .normal)
    doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
    doneButton.isHidden = true

    [
      activityIndicator,
      titleLabel,
      messageLabel,
      previewImageView,
      openAppButton,
      doneButton,
    ].forEach(view.addSubview)

    NSLayoutConstraint.activate([
      activityIndicator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
      activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),

      titleLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 24),
      titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
      titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

      messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
      messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
      messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

      previewImageView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 24),
      previewImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
      previewImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
      previewImageView.heightAnchor.constraint(equalTo: previewImageView.widthAnchor, multiplier: 0.75),

      openAppButton.topAnchor.constraint(equalTo: previewImageView.bottomAnchor, constant: 24),
      openAppButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
      openAppButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

      doneButton.topAnchor.constraint(equalTo: openAppButton.bottomAnchor, constant: 12),
      doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
      doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
    ])
  }

  private func setLoadingState() {
    activityIndicator.startAnimating()
    activityIndicator.isHidden = false
    titleLabel.text = "ImageReminder"
    messageLabel.text = "Importing shared screenshot…"
    previewImageView.isHidden = true
    openAppButton.isHidden = true
    doneButton.isHidden = true
  }

  private func showImportReadyState(imagePath: String) {
    activityIndicator.stopAnimating()
    activityIndicator.isHidden = true
    titleLabel.text = "Import Ready"
    messageLabel.text = "Your screenshot was imported into ImageReminder. You can open the app now or finish here."
    previewImageView.image = UIImage(contentsOfFile: imagePath)
    previewImageView.isHidden = false
    openAppButton.isHidden = false
    doneButton.isHidden = false
  }

  @objc private func openAppTapped() {
    openMainApp()
  }

  @objc private func doneTapped() {
    completeRequest()
  }
}
