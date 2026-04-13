import Foundation
import Observation

@Observable
final class AIUsageTracker {
    static let shared = AIUsageTracker()

    private let dailyLimit = 15
    private let storageKey = "ai_usage_tracker"
    private let tokenStorageKey = "ai_bonus_tokens"

    private var usageDate: String = ""
    private var usageCount: Int = 0
    private(set) var bonusTokens: Int = 0

    var remainingToday: Int {
        refreshIfNewDay()
        return max(0, dailyLimit - usageCount)
    }

    var totalRemaining: Int {
        remainingToday + bonusTokens
    }

    var hasReachedLimit: Bool {
        refreshIfNewDay()
        return usageCount >= dailyLimit && bonusTokens <= 0
    }

    var isDailyLimitReached: Bool {
        refreshIfNewDay()
        return usageCount >= dailyLimit
    }

    var isUsingBonusTokens: Bool {
        isDailyLimitReached && bonusTokens > 0
    }

    private init() {
        loadUsage()
        loadTokens()
    }

    func recordUsage() {
        refreshIfNewDay()
        if usageCount < dailyLimit {
            usageCount += 1
            saveUsage()
        } else if bonusTokens > 0 {
            bonusTokens -= 1
            saveTokens()
        }
    }

    func addBonusTokens(_ count: Int) {
        bonusTokens += count
        saveTokens()
    }

    func tokenCountForProduct(_ identifier: String) -> Int {
        switch identifier {
        case "kinexa_tokens_50": return 50
        case "kinexa_tokens_150": return 150
        case "kinexa_tokens_500": return 500
        default: return 0
        }
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

    private func saveTokens() {
        UserDefaults.standard.set(bonusTokens, forKey: tokenStorageKey)
    }

    private func loadTokens() {
        bonusTokens = UserDefaults.standard.integer(forKey: tokenStorageKey)
    }
}
