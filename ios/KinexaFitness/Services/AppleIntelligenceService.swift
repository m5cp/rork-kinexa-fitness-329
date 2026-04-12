import SwiftUI
import FoundationModels

enum AIAvailabilityStatus {
    case available
    case notEnabled
    case notReady
    case deviceNotEligible
    case unknown
    case osNotSupported
}

@available(iOS 26.0, *)
@MainActor
@Observable
final class AppleIntelligenceService {
    var isGenerating: Bool = false

    var availabilityStatus: AIAvailabilityStatus {
        switch SystemLanguageModel.default.availability {
        case .available:
            return .available
        case .unavailable(.appleIntelligenceNotEnabled):
            return .notEnabled
        case .unavailable(.modelNotReady):
            return .notReady
        case .unavailable(.deviceNotEligible):
            return .deviceNotEligible
        default:
            return .unknown
        }
    }

    var isAvailable: Bool {
        SystemLanguageModel.default.isAvailable
    }

    func generateProgressInsight(
        completedRecords: [CompletedWorkoutRecord],
        streak: Int,
        weeklyStepAverage: Int,
        currentPlan: WeeklyPlan?
    ) async -> String {
        guard isAvailable else {
            return unavailableMessage
        }

        isGenerating = true
        defer { isGenerating = false }

        let context = buildProgressContext(
            completedRecords: completedRecords,
            streak: streak,
            weeklyStepAverage: weeklyStepAverage,
            currentPlan: currentPlan
        )

        let prompt = """
        You are a concise fitness advisor. Analyze this athlete's training data and provide a brief, actionable insight in 2-3 sentences. Focus on trends, strengths, or areas to improve. Be direct and motivating.

        \(context)

        Provide your analysis:
        """

        do {
            let session = LanguageModelSession {
                "You are a fitness advisor. Keep responses under 3 sentences. Be direct, motivating, and actionable. DO NOT use markdown formatting."
            }
            let response = try await session.respond(to: prompt)
            return response.content
        } catch {
            return "Unable to generate insight right now. Keep pushing — your consistency is what counts."
        }
    }

    func generateWeeklySummary(
        completedRecords: [CompletedWorkoutRecord],
        streak: Int,
        stepsThisWeek: Int
    ) async -> String {
        guard isAvailable else {
            return unavailableMessage
        }

        isGenerating = true
        defer { isGenerating = false }

        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: .now)) ?? .now
        let weekRecords = completedRecords.filter { $0.date >= startOfWeek }

        let workoutList = weekRecords.map { "\($0.title) (\($0.exerciseCount) exercises)" }.joined(separator: ", ")

        let prompt = """
        Summarize this athlete's training week in 3-4 sentences. Be specific about what was accomplished and give one forward-looking recommendation.

        Workouts completed this week: \(weekRecords.count)
        Sessions: \(workoutList.isEmpty ? "None" : workoutList)
        Current streak: \(streak) days
        Steps this week: \(stepsThisWeek.formatted())

        Write a brief after-action summary:
        """

        do {
            let session = LanguageModelSession {
                "You are a fitness advisor writing a brief weekly training summary. Keep it under 4 sentences. Be specific and motivating. DO NOT use markdown formatting."
            }
            let response = try await session.respond(to: prompt)
            return response.content
        } catch {
            return "Unable to generate summary right now. You completed \(weekRecords.count) workout\(weekRecords.count == 1 ? "" : "s") this week."
        }
    }

    func generateAdaptiveCoachingTip(
        recentWorkouts: [CompletedWorkoutRecord],
        currentFocus: String
    ) async -> String {
        guard isAvailable else {
            return unavailableMessage
        }

        isGenerating = true
        defer { isGenerating = false }

        let recentList = recentWorkouts.prefix(5).map(\.title).joined(separator: ", ")

        let prompt = """
        Based on this athlete's recent training, give one specific, actionable tip in 1-2 sentences.

        Recent workouts: \(recentList.isEmpty ? "None yet" : recentList)
        Training focus: \(currentFocus)

        Give a short coaching tip:
        """

        do {
            let session = LanguageModelSession {
                "You are a fitness coach. Give one brief, specific training tip. Keep it under 2 sentences. DO NOT use markdown formatting."
            }
            let response = try await session.respond(to: prompt)
            return response.content
        } catch {
            return "Stay consistent with your training plan. Focus on your weakest events for the biggest score gains."
        }
    }

    private func buildProgressContext(
        completedRecords: [CompletedWorkoutRecord],
        streak: Int,
        weeklyStepAverage: Int,
        currentPlan: WeeklyPlan?
    ) -> String {
        var parts: [String] = []

        parts.append("Training streak: \(streak) days")
        parts.append("Total workouts completed: \(completedRecords.count)")
        parts.append("Weekly step average: \(weeklyStepAverage.formatted())")

        if let plan = currentPlan {
            parts.append("Current plan: Week \(plan.currentWeek) of \(plan.totalWeeks), \(plan.completedCount)/\(plan.totalWorkoutDays) sessions done")
        }

        let calendar = Calendar.current
        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: .now) ?? .now
        let recentCount = completedRecords.filter { $0.date >= twoWeeksAgo }.count
        parts.append("Workouts in last 14 days: \(recentCount)")

        return parts.joined(separator: "\n")
    }

    private var unavailableMessage: String {
        "Apple Intelligence is not available on this device. This feature requires iPhone 15 Pro or later with iOS 26 and Apple Intelligence enabled."
    }
}

enum AIFeatureCheck {
    static var isDeviceCapable: Bool {
        if #available(iOS 26.0, *) {
            return true
        }
        return false
    }

    static var requirementsDescription: String {
        "Apple Intelligence features require iPhone 15 Pro or later running iOS 26+, with Apple Intelligence enabled in Settings."
    }
}
