import Foundation
import Observation

@Observable
final class AIUsageTracker {
    static let shared = AIUsageTracker()

    static let freeDailyLimit: Int = 5
    static let premiumDailyLimit: Int = 15

    private let storageKey = "ai_usage_tracker_v2"
    private let tokenStorageKey = "ai_bonus_tokens"

    private var usageDate: String = ""
    private(set) var dailyUsageCount: Int = 0
    private(set) var bonusTokens: Int = 0

    var isPremium: Bool = false

    var dailyLimit: Int {
        isPremium ? Self.premiumDailyLimit : Self.freeDailyLimit
    }

    var remainingToday: Int {
        refreshIfNewDay()
        return max(0, dailyLimit - dailyUsageCount)
    }

    var totalRemaining: Int {
        remainingToday + bonusTokens
    }

    var hasReachedLimit: Bool {
        refreshIfNewDay()
        return dailyUsageCount >= dailyLimit && bonusTokens <= 0
    }

    var isDailyLimitReached: Bool {
        refreshIfNewDay()
        return dailyUsageCount >= dailyLimit
    }

    var isUsingBonusTokens: Bool {
        isDailyLimitReached && bonusTokens > 0
    }

    var hasFreeTrialRemaining: Bool { !isPremium && remainingToday > 0 }
    var freeTrialUsed: Bool { !isPremium && remainingToday <= 0 }

    var canUseAI: Bool { !hasReachedLimit }

    var limitReachedTitle: String {
        isPremium ? "Daily AI scans used" : "AI scans used up"
    }

    var limitReachedMessage: String {
        if isPremium {
            return "You've used today's \(Self.premiumDailyLimit) AI scans. Buy a token pack to keep going, or come back tomorrow."
        } else {
            return "You've used all your free AI scans. Subscribe for \(Self.premiumDailyLimit)/day, or buy a token pack."
        }
    }

    private init() {
        loadDailyUsage()
        loadTokens()
    }

    func recordUsage() {
        refreshIfNewDay()
        if dailyUsageCount < dailyLimit {
            dailyUsageCount += 1
            saveDailyUsage()
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
        case "kinexa_tokens_10": return 10
        case "kinexa_tokens_30": return 30
        case "kinexa_tokens_100": return 100
        default: return 0
        }
    }

    private func refreshIfNewDay() {
        let today = todayString()
        if usageDate != today {
            usageDate = today
            dailyUsageCount = 0
            saveDailyUsage()
        }
    }

    private func todayString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter.string(from: .now)
    }

    private func saveDailyUsage() {
        let data: [String: Any] = ["date": usageDate, "count": dailyUsageCount]
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func loadDailyUsage() {
        guard let data = UserDefaults.standard.dictionary(forKey: storageKey),
              let date = data["date"] as? String,
              let count = data["count"] as? Int else {
            usageDate = todayString()
            dailyUsageCount = 0
            return
        }
        usageDate = date
        dailyUsageCount = max(0, count)
        refreshIfNewDay()
    }

    private func saveTokens() {
        UserDefaults.standard.set(bonusTokens, forKey: tokenStorageKey)
    }

    private func loadTokens() {
        bonusTokens = UserDefaults.standard.integer(forKey: tokenStorageKey)
    }
}
