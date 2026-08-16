import Foundation
import UserNotifications

final class ExtensionNotificationScheduler {
  private let center: UNUserNotificationCenter

  init(center: UNUserNotificationCenter = .current()) {
    self.center = center
  }

  func scheduleIfAuthorized(reminder: PendingReminder, completion: @escaping (Bool) -> Void) {
    center.getNotificationSettings { [weak self] settings in
      guard let self else {
        completion(false)
        return
      }

      guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
        completion(false)
        return
      }

      guard let scheduledDate = ISO8601DateFormatter().date(from: reminder.scheduledAt), scheduledDate > Date() else {
        completion(false)
        return
      }

      let content = UNMutableNotificationContent()
      content.title = (reminder.title?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
        ? reminder.title!
        : "Picture reminder"
      content.body = "Tap to view your saved picture."
      content.sound = reminder.soundMode == "alarm"
        ? UNNotificationSound(named: UNNotificationSoundName(AppGroupConstants.notificationSoundFile))
        : .default
      content.userInfo = [
        "type": "reminder",
        "reminderId": reminder.id,
      ]

      let calendar = Calendar.current
      let components = calendar.dateComponents(
        [.year, .month, .day, .hour, .minute, .second],
        from: scheduledDate
      )
      let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
      let request = UNNotificationRequest(
        identifier: String(reminder.notificationId),
        content: content,
        trigger: trigger
      )

      self.center.add(request) { error in
        completion(error == nil)
      }
    }
  }
}