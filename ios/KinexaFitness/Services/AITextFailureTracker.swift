import Foundation
import Observation

@Observable
final class AITextFailureTracker {
    static let shared = AITextFailureTracker()

    static let maxFailures: Int = 10
    static let lockoutDuration: TimeInterval = 24 * 60 * 60

    private let failureCountKey = "aiText_failureCount"
    private let lockoutStartKey = "aiText_lockoutStart"

    private(set) var failureCount: Int = 0
    private(set) var lockoutStart: Date?

    private init() {
        failureCount = UserDefaults.standard.integer(forKey: failureCountKey)
        let ts = UserDefaults.standard.double(forKey: lockoutStartKey)
        if ts > 0 { lockoutStart = Date(timeIntervalSince1970: ts) }
        refreshLockout()
    }

    var isLocked: Bool {
        refreshLockout()
        return lockoutStart != nil
    }

    var remainingFailuresBeforeLockout: Int {
        max(0, Self.maxFailures - failureCount)
    }

    var hoursRemaining: Int {
        guard let start = lockoutStart else { return 0 }
        let elapsed = Date().timeIntervalSince(start)
        let remaining = max(0, Self.lockoutDuration - elapsed)
        return max(1, Int(ceil(remaining / 3600)))
    }

    func recordFailure() {
        refreshLockout()
        failureCount += 1
        UserDefaults.standard.set(failureCount, forKey: failureCountKey)
        if failureCount >= Self.maxFailures {
            let now = Date()
            lockoutStart = now
            UserDefaults.standard.set(now.timeIntervalSince1970, forKey: lockoutStartKey)
        }
    }

    func recordSuccess() {
        failureCount = 0
        lockoutStart = nil
        UserDefaults.standard.set(0, forKey: failureCountKey)
        UserDefaults.standard.removeObject(forKey: lockoutStartKey)
    }

    private func refreshLockout() {
        guard let start = lockoutStart else { return }
        if Date().timeIntervalSince(start) >= Self.lockoutDuration {
            lockoutStart = nil
            failureCount = 0
            UserDefaults.standard.set(0, forKey: failureCountKey)
            UserDefaults.standard.removeObject(forKey: lockoutStartKey)
        }
    }
}
