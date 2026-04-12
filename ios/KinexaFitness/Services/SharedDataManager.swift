import Foundation
import WidgetKit

nonisolated enum SharedDataManager: Sendable {
    static let appGroupID = "group.app.rork.sf0lrvsw5r0bpccfi1669"

    static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    static func writeWidgetData(
        todayWorkoutTitle: String?,
        todayWorkoutExerciseCount: Int,
        streak: Int,
        stepsToday: Int,
        completedToday: Bool,
        planWeek: Int,
        planTotalWeeks: Int
    ) {
        guard let defaults = sharedDefaults else { return }

        defaults.set(todayWorkoutTitle, forKey: "widget_todayWorkoutTitle")
        defaults.set(todayWorkoutExerciseCount, forKey: "widget_todayExerciseCount")
        defaults.set(streak, forKey: "widget_streak")
        defaults.set(stepsToday, forKey: "widget_stepsToday")
        defaults.set(completedToday, forKey: "widget_completedToday")
        defaults.set(planWeek, forKey: "widget_planWeek")
        defaults.set(planTotalWeeks, forKey: "widget_planTotalWeeks")
        defaults.set(Date().timeIntervalSince1970, forKey: "widget_lastUpdate")

        WidgetCenter.shared.reloadAllTimelines()
    }

    static func readWidgetData() -> WidgetData {
        guard let defaults = sharedDefaults else { return WidgetData() }

        return WidgetData(
            todayWorkoutTitle: defaults.string(forKey: "widget_todayWorkoutTitle"),
            todayExerciseCount: defaults.integer(forKey: "widget_todayExerciseCount"),
            streak: defaults.integer(forKey: "widget_streak"),
            stepsToday: defaults.integer(forKey: "widget_stepsToday"),
            completedToday: defaults.bool(forKey: "widget_completedToday"),
            planWeek: defaults.integer(forKey: "widget_planWeek"),
            planTotalWeeks: defaults.integer(forKey: "widget_planTotalWeeks")
        )
    }
}

nonisolated struct WidgetData: Sendable {
    var todayWorkoutTitle: String? = nil
    var todayExerciseCount: Int = 0
    var streak: Int = 0
    var stepsToday: Int = 0
    var completedToday: Bool = false
    var planWeek: Int = 0
    var planTotalWeeks: Int = 0
}
