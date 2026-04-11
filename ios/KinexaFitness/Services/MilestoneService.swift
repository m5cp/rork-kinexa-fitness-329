import SwiftUI

nonisolated struct Milestone: Identifiable, Sendable {
    let id: UUID = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let shareText: String
}

enum MilestoneService {
    private static let lastStreakMilestoneKey = "lastStreakMilestone"
    private static let lastWorkoutMilestoneKey = "lastWorkoutMilestone"

    static func checkStreakMilestone(_ streak: Int) -> Milestone? {
        let milestones: [(Int, String, String)] = [
            (7, "1 Week Strong", "Seven days of consistent training"),
            (14, "Two Week Warrior", "14 consecutive days of training"),
            (21, "Habit Formed", "21 days — this is who you are now"),
            (30, "30-Day Machine", "A full month of relentless training"),
            (60, "60-Day Veteran", "Two months of discipline and dedication"),
            (90, "90-Day Legend", "Quarter-year of pure commitment"),
            (100, "Century Mark", "100 days of showing up"),
            (180, "Half-Year Hero", "180 days without breaking the chain"),
            (365, "365-Day Immortal", "One full year. Unstoppable.")
        ]

        let lastRecorded = UserDefaults.standard.integer(forKey: lastStreakMilestoneKey)
        guard streak > lastRecorded else { return nil }

        guard let match = milestones.first(where: { $0.0 == streak }) else { return nil }

        UserDefaults.standard.set(streak, forKey: lastStreakMilestoneKey)

        return Milestone(
            title: match.1,
            subtitle: match.2,
            icon: "flame.fill",
            color: Color(hex: "#F59E0B"),
            shareText: "\(match.1) — \(streak)-day training streak on Kinexa Fitness #KinexaFitness"
        )
    }

    static func checkWorkoutMilestone(_ totalWorkouts: Int) -> Milestone? {
        let milestones: [(Int, String, String)] = [
            (5, "First Five", "Your first five workouts are in the books"),
            (10, "Double Digits", "10 workouts completed — building momentum"),
            (25, "Quarter Century", "25 workouts — you're locked in"),
            (50, "Half Hundred", "50 workouts of pure effort"),
            (100, "Triple Digits", "100 workouts — elite consistency"),
            (200, "Two Hundred Club", "200 workouts — this is a lifestyle"),
            (500, "Five Hundred Strong", "500 workouts — you are the mission"),
            (1000, "Thousandaire", "1,000 workouts — legendary status")
        ]

        let lastRecorded = UserDefaults.standard.integer(forKey: lastWorkoutMilestoneKey)
        guard totalWorkouts > lastRecorded else { return nil }

        guard let match = milestones.first(where: { $0.0 == totalWorkouts }) else { return nil }

        UserDefaults.standard.set(totalWorkouts, forKey: lastWorkoutMilestoneKey)

        return Milestone(
            title: match.1,
            subtitle: match.2,
            icon: "star.fill",
            color: Color(hex: "#22C55E"),
            shareText: "\(match.1) — \(totalWorkouts) workouts on Kinexa Fitness #KinexaFitness"
        )
    }

    static func resetTracking() {
        UserDefaults.standard.removeObject(forKey: lastStreakMilestoneKey)
        UserDefaults.standard.removeObject(forKey: lastWorkoutMilestoneKey)
    }
}
