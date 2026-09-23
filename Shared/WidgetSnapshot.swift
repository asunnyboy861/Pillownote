import Foundation

struct WidgetSnapshot: Codable {
    var daysTogether: Int = 0
    var reunionDays: Int?
    var todayQuestion: String = ""
    var partnerMood: String?
    var partnerName: String = "My Love"
    var asOf: Date = Date()
}

enum WidgetSharedStore {
    static let appGroupId = "group.com.zzoutuo.Pillownote"

    static func save(_ snapshot: WidgetSnapshot) {
        guard let defaults = UserDefaults(suiteName: appGroupId) else { return }
        if let data = try? JSONEncoder().encode(snapshot) {
            defaults.set(data, forKey: "widgetSnapshot")
        }
    }

    static func load() -> WidgetSnapshot? {
        guard let defaults = UserDefaults(suiteName: appGroupId),
              let data = defaults.data(forKey: "widgetSnapshot") else { return nil }
        return try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    }
}
