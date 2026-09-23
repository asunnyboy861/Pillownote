import Foundation
import UserNotifications

enum NotificationService {
    static func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    static func scheduleDailyReminder(hour: Int = 20) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["daily-reminder"])
        var components = DateComponents()
        components.hour = hour
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let content = UNMutableNotificationContent()
        content.title = "Tonight's question is waiting 💌"
        content.body = "30 seconds, one question, then see what they wrote."
        content.sound = .default
        let request = UNNotificationRequest(identifier: "daily-reminder", content: content, trigger: trigger)
        center.add(request)
    }

    static func scheduleTrialReminder(daysBeforeEnd: Int = 3) {
        let center = UNUserNotificationCenter.current()
        guard let fireDate = Calendar.current.date(byAdding: .day, value: daysBeforeEnd, to: Date()) else { return }
        let components = Calendar.current.dateComponents([.year, .month, .day], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = "Your free trial ends soon"
        content.body = "You can keep every memory either way. Manage your subscription anytime in Settings."
        content.sound = .default
        let request = UNNotificationRequest(identifier: "trial-reminder", content: content, trigger: trigger)
        center.add(request)
    }

    static func scheduleNoteArrival(noteID: UUID, at date: Date, senderName: String) {
        guard date > Date() else { return }
        let content = UNMutableNotificationContent()
        content.title = "A pillow note arrived 💌"
        content.body = "You have a sealed note waiting under your pillow."
        content.sound = .default
        content.userInfo = ["noteID": noteID.uuidString]
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date), repeats: false)
        let request = UNNotificationRequest(identifier: "note-\(noteID.uuidString)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    static func cancelNoteArrival(noteID: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["note-\(noteID.uuidString)"])
    }

    static func unlockAtForPartner(partnerTZ: String, from date: Date = Date()) -> Date {
        let tz = TimeZone(identifier: partnerTZ) ?? .current
        var calendar = Calendar.current
        calendar.timeZone = tz
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: date) ?? date.addingTimeInterval(86400)
        var components = calendar.dateComponents([.year, .month, .day], from: tomorrow)
        components.hour = 7
        return calendar.date(from: components) ?? tomorrow
    }
}
