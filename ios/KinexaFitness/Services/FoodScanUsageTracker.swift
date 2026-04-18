import Foundation
import Observation

@Observable
final class FoodScanUsageTracker {
    static let shared = FoodScanUsageTracker()

    static let defaultFreeDailyLimit: Int = 5
    static let defaultPremiumDailyLimit: Int = 5

    private let storageKey = "food_scan_usage_tracker_v1"

    private(set) var scansUsedToday: Int = 0
    private var lastResetDate: String = ""

    var isPremium: Bool = false

    var dailyLimit: Int {
        isPremium ? Self.defaultPremiumDailyLimit : Self.defaultFreeDailyLimit
    }

    var remainingToday: Int {
        refreshIfNewDay()
        return max(0, dailyLimit - scansUsedToday)
    }

    var hasReachedLimit: Bool {
        refreshIfNewDay()
        return scansUsedToday >= dailyLimit
    }

    private init() {
        load()
    }

    func recordScan() {
        refreshIfNewDay()
        scansUsedToday += 1
        save()
    }

    private func refreshIfNewDay() {
        let today = Self.todayString()
        if lastResetDate != today {
            lastResetDate = today
            scansUsedToday = 0
            save()
        }
    }

    private static func todayString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter.string(from: .now)
    }

    private func save() {
        let payload: [String: Any] = [
            "date": lastResetDate,
            "count": scansUsedToday
        ]
        UserDefaults.standard.set(payload, forKey: storageKey)
    }

    private func load() {
        guard let data = UserDefaults.standard.dictionary(forKey: storageKey) else {
            lastResetDate = Self.todayString()
            scansUsedToday = 0
            return
        }
        let date = (data["date"] as? String) ?? Self.todayString()
        let count = (data["count"] as? Int) ?? 0
        lastResetDate = date
        scansUsedToday = max(0, count)
        refreshIfNewDay()
    }
}
