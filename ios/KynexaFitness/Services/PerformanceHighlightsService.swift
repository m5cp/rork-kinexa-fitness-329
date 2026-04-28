import Foundation

nonisolated enum HighlightType: Sendable {
    case personalBest
    case eventImprovement
    case scoreChange
    case completion
    case planProgress
    case streak
}

nonisolated struct PerformanceHighlight: Identifiable, Sendable {
    let id: UUID = UUID()
    let type: HighlightType
    let title: String
    let detail: String?
    let icon: String
    let isPositive: Bool

    init(type: HighlightType, title: String, detail: String? = nil, icon: String, isPositive: Bool = true) {
        self.type = type
        self.title = title
        self.detail = detail
        self.icon = icon
        self.isPositive = isPositive
    }
}

nonisolated struct InstantRecap: Identifiable, Sendable {
    let id: UUID = UUID()
    let title: String
    let detail: String?
    let icon: String
    let isPositive: Bool

    init(title: String, detail: String? = nil, icon: String, isPositive: Bool = true) {
        self.title = title
        self.detail = detail
        self.icon = icon
        self.isPositive = isPositive
    }
}

enum PerformanceHighlightsService {

    static func generateHighlights(
        completedRecords: [CompletedWorkoutRecord],
        currentPlan: WeeklyPlan?,
        wodPlan: WODPlan?,
        streak: Int
    ) -> [PerformanceHighlight] {
        var highlights: [PerformanceHighlight] = []

        if let pp = planProgressHighlight(currentPlan: currentPlan) {
            highlights.append(pp)
        }

        if let wpp = wodPlanProgressHighlight(wodPlan: wodPlan) {
            highlights.append(wpp)
        }

        if let sk = streakHighlight(streak: streak) {
            highlights.append(sk)
        }

        if let tc = totalCompletionsHighlight(completedRecords: completedRecords) {
            highlights.append(tc)
        }

        return Array(highlights.prefix(3))
    }

    static func workoutRecap(title: String, exerciseCount: Int) -> InstantRecap {
        InstantRecap(
            title: "Workout Complete",
            detail: "\(title) — \(exerciseCount) exercises",
            icon: "checkmark.circle.fill"
        )
    }

    static func planDayRecap(dayNumber: Int, totalDays: Int) -> InstantRecap {
        InstantRecap(
            title: "Day \(dayNumber) of \(totalDays) completed",
            detail: nil,
            icon: "checkmark.circle.fill"
        )
    }

    // MARK: - Private

    private static func planProgressHighlight(currentPlan: WeeklyPlan?) -> PerformanceHighlight? {
        guard let plan = currentPlan else { return nil }
        let completed = plan.completedCount
        let total = plan.totalWorkoutDays
        guard total > 0, completed > 0 else { return nil }

        if completed == total {
            return PerformanceHighlight(
                type: .planProgress,
                title: "Week \(plan.currentWeek) complete",
                icon: "flag.fill"
            )
        }

        return PerformanceHighlight(
            type: .planProgress,
            title: "\(completed) of \(total) workouts done",
            detail: "Week \(plan.currentWeek)",
            icon: "list.bullet.circle"
        )
    }

    private static func wodPlanProgressHighlight(wodPlan: WODPlan?) -> PerformanceHighlight? {
        guard let plan = wodPlan else { return nil }
        let completed = plan.days.filter(\.isCompleted).count
        let total = plan.days.filter { !$0.isRestDay }.count
        guard total > 0, completed > 0 else { return nil }

        if completed == total {
            return PerformanceHighlight(
                type: .planProgress,
                title: "FunctionFitness week complete",
                icon: "flag.fill"
            )
        }

        return nil
    }

    private static func streakHighlight(streak: Int) -> PerformanceHighlight? {
        let milestones = [3, 5, 7, 10, 14, 21, 30, 60, 90, 100, 365]
        guard milestones.contains(streak) else { return nil }

        return PerformanceHighlight(
            type: .streak,
            title: "\(streak)-day streak",
            icon: "flame.fill"
        )
    }

    private static func totalCompletionsHighlight(completedRecords: [CompletedWorkoutRecord]) -> PerformanceHighlight? {
        let milestones = [10, 25, 50, 75, 100, 150, 200, 250, 300, 500, 1000]
        let count = completedRecords.count
        guard let milestone = milestones.last(where: { count >= $0 }) else { return nil }
        guard count == milestone || (count - milestone) < 3 else { return nil }

        return PerformanceHighlight(
            type: .completion,
            title: "\(milestone) workouts completed",
            icon: "star.fill"
        )
    }
}
