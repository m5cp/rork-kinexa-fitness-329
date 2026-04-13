import Foundation
import Observation

@Observable
final class AIUsageTracker {
    static let shared = AIUsageTracker()

    private let dailyLimit = 15
    private let storageKey = "ai_usage_tracker"

    private var usageDate: String = ""
    private var usageCount: Int = 0

    var remainingToday: Int {
        refreshIfNewDay()
        return max(0, dailyLimit - usageCount)
    }

    var hasReachedLimit: Bool {
        refreshIfNewDay()
        return usageCount >= dailyLimit
    }

    private init() {
        loadUsage()
    }

    func recordUsage() {
        refreshIfNewDay()
        usageCount += 1
        saveUsage()
    }

    private func refreshIfNewDay() {
        let today = todayString()
        if usageDate != today {
            usageDate = today
            usageCount = 0
            saveUsage()
        }
    }

    private func todayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: .now)
    }

    private func saveUsage() {
        let data: [String: Any] = ["date": usageDate, "count": usageCount]
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func loadUsage() {
        guard let data = UserDefaults.standard.dictionary(forKey: storageKey),
              let date = data["date"] as? String,
              let count = data["count"] as? Int else { return }
        usageDate = date
        usageCount = count
        refreshIfNewDay()
    }
}
