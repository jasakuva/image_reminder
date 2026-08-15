import UIKit

final class ImportLaunchViewController: UIViewController {
  private let activityIndicator = UIActivityIndicatorView(style: .large)
  private let titleLabel = UILabel()
  private let subtitleLabel = UILabel()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground

    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.text = "ImageReminder"
    titleLabel.font = .systemFont(ofSize: 28, weight: .semibold)
    titleLabel.textAlignment = .center

    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    subtitleLabel.text = "Opening shared import…"
    subtitleLabel.font = .systemFont(ofSize: 16, weight: .regular)
    subtitleLabel.textAlignment = .center
    subtitleLabel.textColor = .secondaryLabel
    subtitleLabel.numberOfLines = 0

    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    activityIndicator.startAnimating()

    view.addSubview(titleLabel)
    view.addSubview(subtitleLabel)
    view.addSubview(activityIndicator)

    NSLayoutConstraint.activate([
      activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),

      titleLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 24),
      titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
      titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

      subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
      subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
      subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
    ])
  }
}