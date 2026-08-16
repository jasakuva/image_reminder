import Foundation

struct PendingReminder: Codable {
  let id: String
  let title: String?
  let note: String?
  let imagePath: String
  let scheduledAt: String
  let createdAt: String
  let updatedAt: String
  let completedAt: String?
  let status: String
  let snoozeCount: Int
  let notificationId: Int
  let soundMode: String
  let lastSnoozedAt: String?
  let notificationScheduled: Bool
  let source: String

  var asDictionary: [String: Any] {
    [
      "id": id,
      "title": title as Any,
      "note": note as Any,
      "imagePath": imagePath,
      "scheduledAt": scheduledAt,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "completedAt": completedAt as Any,
      "status": status,
      "snoozeCount": snoozeCount,
      "notificationId": notificationId,
      "soundMode": soundMode,
      "lastSnoozedAt": lastSnoozedAt as Any,
      "notificationScheduled": notificationScheduled,
      "source": source,
    ]
  }
}