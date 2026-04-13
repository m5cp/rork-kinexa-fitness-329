import Foundation
import Observation

@Observable
final class AIUsageTracker {
    static let shared = AIUsageTracker()

    private let subscriberDailyLimit = 15
    private let freeLifetimeLimit = 1
    private let storageKey = "ai_usage_tracker"
    private let tokenStorageKey = "ai_bonus_tokens"
    private let lifetimeUsageKey = "ai_lifetime_usage"

    private var usageDate: String = ""
    private var dailyUsageCount: Int = 0
    private(set) var bonusTokens: Int = 0
    private(set) var lifetimeUsageCount: Int = 0

    var isPremium: Bool = false

    var dailyLimit: Int {
        isPremium ? subscriberDailyLimit : freeLifetimeLimit
    }

    var remainingToday: Int {
        if isPremium {
            refreshIfNewDay()
            return max(0, subscriberDailyLimit - dailyUsageCount)
        } else {
            return max(0, freeLifetimeLimit - lifetimeUsageCount)
        }
    }

    var totalRemaining: Int {
        remainingToday + bonusTokens
    }

    var hasReachedLimit: Bool {
        if isPremium {
            refreshIfNewDay()
            return dailyUsageCount >= subscriberDailyLimit && bonusTokens <= 0
        } else {
            return lifetimeUsageCount >= freeLifetimeLimit && bonusTokens <= 0
        }
    }

    var isDailyLimitReached: Bool {
        if isPremium {
            refreshIfNewDay()
            return dailyUsageCount >= subscriberDailyLimit
        } else {
            return lifetimeUsageCount >= freeLifetimeLimit
        }
    }

    var isUsingBonusTokens: Bool {
        isDailyLimitReached && bonusTokens > 0
    }

    var hasFreeTrialRemaining: Bool {
        !isPremium && lifetimeUsageCount < freeLifetimeLimit
    }

    var freeTrialUsed: Bool {
        !isPremium && lifetimeUsageCount >= freeLifetimeLimit
    }

    private init() {
        loadDailyUsage()
        loadTokens()
        loadLifetimeUsage()
    }

    func recordUsage() {
        if isPremium {
            refreshIfNewDay()
            if dailyUsageCount < subscriberDailyLimit {
                dailyUsageCount += 1
                saveDailyUsage()
            } else if bonusTokens > 0 {
                bonusTokens -= 1
                saveTokens()
            }
        } else {
            if lifetimeUsageCount < freeLifetimeLimit {
                lifetimeUsageCount += 1
                saveLifetimeUsage()
            } else if bonusTokens > 0 {
                bonusTokens -= 1
                saveTokens()
            }
        }
    }

    func addBonusTokens(_ count: Int) {
        bonusTokens += count
        saveTokens()
    }

    func tokenCountForProduct(_ identifier: String) -> Int {
        switch identifier {
        case "kinexa_tokens_50": return 10
        case "kinexa_tokens_150": return 30
        case "kinexa_tokens_500": return 100
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
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: .now)
    }

    private func saveDailyUsage() {
        let data: [String: Any] = ["date": usageDate, "count": dailyUsageCount]
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func loadDailyUsage() {
        guard let data = UserDefaults.standard.dictionary(forKey: storageKey),
              let date = data["date"] as? String,
              let count = data["count"] as? Int else { return }
        usageDate = date
        dailyUsageCount = count
        refreshIfNewDay()
    }

    private func saveTokens() {
        UserDefaults.standard.set(bonusTokens, forKey: tokenStorageKey)
    }

    private func loadTokens() {
        bonusTokens = UserDefaults.standard.integer(forKey: tokenStorageKey)
    }

    private func saveLifetimeUsage() {
        UserDefaults.standard.set(lifetimeUsageCount, forKey: lifetimeUsageKey)
    }

    private func loadLifetimeUsage() {
        lifetimeUsageCount = UserDefaults.standard.integer(forKey: lifetimeUsageKey)
    }
}
