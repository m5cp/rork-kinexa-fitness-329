import StoreKit
import SwiftUI

enum AppReviewService {
    private static let lastReviewRequestKey = "lastReviewRequestDate"
    private static let reviewRequestCountKey = "reviewRequestCount"
    private static let minimumDaysBetweenRequests = 45

    static func requestReviewIfAppropriate() {
        let now = Date()
        let lastRequest = UserDefaults.standard.double(forKey: lastReviewRequestKey)
        let count = UserDefaults.standard.integer(forKey: reviewRequestCountKey)

        if count >= 3 { return }

        if lastRequest > 0 {
            let lastDate = Date(timeIntervalSince1970: lastRequest)
            let daysSince = Calendar.current.dateComponents([.day], from: lastDate, to: now).day ?? 0
            if daysSince < minimumDaysBetweenRequests { return }
        }

        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }

        SKStoreReviewController.requestReview(in: scene)
        UserDefaults.standard.set(now.timeIntervalSince1970, forKey: lastReviewRequestKey)
        UserDefaults.standard.set(count + 1, forKey: reviewRequestCountKey)
    }

    static func shouldRequestReview(streak: Int, totalWorkouts: Int) -> Bool {
        let streakMilestones = [7, 14, 30, 60, 90]
        let workoutMilestones = [10, 25, 50, 100]

        let isStreakMilestone = streakMilestones.contains(streak)
        let isWorkoutMilestone = workoutMilestones.contains(totalWorkouts)

        return isStreakMilestone || isWorkoutMilestone
    }
}
