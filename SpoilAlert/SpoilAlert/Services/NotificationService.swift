import UserNotifications
import Foundation

final class NotificationService {

    static let shared = NotificationService()

    private init() {}

    func requestAuthorization() async throws -> Bool {
        try await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound])
    }

    func scheduleExpiryReminders(for product: SkincareProduct) async {
        removeReminders(for: product)

        let reminders: [(id: String, date: Date, title: String, body: String)] = [
            ("7day",
             Calendar.current.date(byAdding: .day, value: -7, to: product.expirationDate) ?? product.expirationDate,
             "\(product.name) expires in 7 days",
             "Your \(product.brand) \(product.name) will expire next week."),
            ("3day",
             Calendar.current.date(byAdding: .day, value: -3, to: product.expirationDate) ?? product.expirationDate,
             "\(product.name) expires in 3 days",
             "Hurry! Your \(product.brand) \(product.name) is about to expire."),
            ("1day",
             Calendar.current.date(byAdding: .day, value: -1, to: product.expirationDate) ?? product.expirationDate,
             "\(product.name) expires TOMORROW",
             "Last chance to use your \(product.brand) \(product.name) before it expires!"),
            ("today",
             product.expirationDate,
             "\(product.name) has EXPIRED",
             "Your \(product.brand) \(product.name) has expired. Using it may cause skin irritation.")
        ]

        for reminder in reminders {
            guard reminder.date > Date() else { continue }

            let content = UNMutableNotificationContent()
            content.title = reminder.title
            content.body = reminder.body
            content.sound = .default
            content.categoryIdentifier = "EXPIRY_REMINDER"
            content.userInfo = ["productID": product.id.uuidString]

            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: "\(product.id.uuidString)_\(reminder.id)", content: content, trigger: trigger)

            try? await UNUserNotificationCenter.current().add(request)
        }
    }

    func removeReminders(for product: SkincareProduct) {
        let identifiers = ["7day", "3day", "1day", "today"].map { "\(product.id.uuidString)_\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func updateBadge(expiredCount: Int) {
        UNUserNotificationCenter.current().setBadgeCount(expiredCount)
    }
}
