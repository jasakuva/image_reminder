import Foundation

struct SharedImport: Codable {
  let id: String
  let imagePath: String
  let createdAt: TimeInterval
  let source: String

  var asDictionary: [String: Any] {
    [
      "id": id,
      "imagePath": imagePath,
      "createdAt": createdAt,
      "source": source,
    ]
  }
}