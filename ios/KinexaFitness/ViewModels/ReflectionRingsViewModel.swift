import Foundation
import Observation
import SwiftUI

@Observable
final class ReflectionRingsViewModel {
    var moodEntries: [MoodEntry] = []
    var snapshots: [DailyRingsSnapshot] = []
    var friends: [Friend] = []
    var username: String = ""
    var shareCode: String = ""

    init() {
        loadData()
        if shareCode.isEmpty {
            shareCode = Self.generateShareCode()
            persist()
        }
        if username.isEmpty {
            username = "You"
            persist()
        }
        if friends.isEmpty {
            friends = Self.seedFriends()
            persist()
        }
    }

    // MARK: - Mood

    func moodForDate(_ date: Date) -> MoodEntry? {
        let cal = Calendar.current
        return moodEntries.first { cal.isDate($0.date, inSameDayAs: date) }
    }

    var todayMood: MoodEntry? { moodForDate(.now) }

    func logMood(_ level: MoodLevel, note: String = "") {
        let cal = Calendar.current
        moodEntries.removeAll { cal.isDate($0.date, inSameDayAs: .now) }
        moodEntries.insert(MoodEntry(level: level, note: note), at: 0)
        persist()
    }

    // MARK: - Ring Computation

    static let moveStepsGoal: Int = 6000

    func stepsForDate(_ date: Date, appVM: AppViewModel) -> Int {
        let cal = Calendar.current
        if cal.isDateInToday(date) {
            let live = appVM.pedometer.todaySteps
            let stored = appVM.stepHistory.first { cal.isDate($0.date, inSameDayAs: date) }?.steps ?? 0
            return max(live, stored)
        }
        return appVM.stepHistory.first { cal.isDate($0.date, inSameDayAs: date) }?.steps ?? 0
    }

    func closedRings(on date: Date, appVM: AppViewModel, nutritionVM: NutritionViewModel) -> Set<RingType> {
        let cal = Calendar.current
        var rings: Set<RingType> = []

        // Fitness — any completed workout / quick start / cardio on that date, OR enough steps
        let hasCompleted = appVM.completedRecords.contains { cal.isDate($0.date, inSameDayAs: date) }
        let hasQuick = appVM.quickStartRecords.contains { cal.isDate($0.startDate, inSameDayAs: date) }
        let hasCardio = appVM.cardioSessions.contains { cal.isDate($0.date, inSameDayAs: date) }
        let steps = stepsForDate(date, appVM: appVM)
        if hasCompleted || hasQuick || hasCardio || steps >= Self.moveStepsGoal {
            rings.insert(.fitness)
        }

        // Meals
        if !nutritionVM.mealsForDate(date).isEmpty {
            rings.insert(.meals)
        }

        // Mood
        if moodForDate(date) != nil {
            rings.insert(.mood)
        }

        // Water — hit daily goal
        let water = nutritionVM.waterForDate(date)
        if nutritionVM.waterGoal.dailyOunces > 0 && water >= nutritionVM.waterGoal.dailyOunces {
            rings.insert(.water)
        }

        return rings
    }

    func progress(for ring: RingType, on date: Date, appVM: AppViewModel, nutritionVM: NutritionViewModel) -> Double {
        let cal = Calendar.current
        switch ring {
        case .fitness:
            if closedRings(on: date, appVM: appVM, nutritionVM: nutritionVM).contains(.fitness) { return 1 }
            let steps = stepsForDate(date, appVM: appVM)
            return min(Double(steps) / Double(Self.moveStepsGoal), 1.0)
        case .meals:
            let count = nutritionVM.mealsForDate(date).count
            return min(Double(count) / 1.0, 1.0)
        case .mood:
            return moodForDate(date) != nil ? 1 : 0
        case .water:
            guard nutritionVM.waterGoal.dailyOunces > 0 else { return 0 }
            return min(nutritionVM.waterForDate(date) / nutritionVM.waterGoal.dailyOunces, 1.0)
        }
        _ = cal
    }

    func pointsEarned(on date: Date, appVM: AppViewModel, nutritionVM: NutritionViewModel) -> Int {
        let closed = closedRings(on: date, appVM: appVM, nutritionVM: nutritionVM)
        var pts = closed.count * RingType.pointsPerRing
        if closed.count == RingType.allCases.count {
            pts += RingType.allRingsBonus
        }
        return pts
    }

    func totalPoints(appVM: AppViewModel, nutritionVM: NutritionViewModel) -> Int {
        let cal = Calendar.current
        let earliest = cal.date(byAdding: .day, value: -90, to: cal.startOfDay(for: .now)) ?? .now
        var total = 0
        var d = earliest
        let today = cal.startOfDay(for: .now)
        while d <= today {
            total += pointsEarned(on: d, appVM: appVM, nutritionVM: nutritionVM)
            guard let next = cal.date(byAdding: .day, value: 1, to: d) else { break }
            d = next
        }
        return total
    }

    func weeklyPoints(appVM: AppViewModel, nutritionVM: NutritionViewModel) -> Int {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        var total = 0
        for offset in 0..<7 {
            if let d = cal.date(byAdding: .day, value: -offset, to: today) {
                total += pointsEarned(on: d, appVM: appVM, nutritionVM: nutritionVM)
            }
        }
        return total
    }

    func currentStreak(appVM: AppViewModel, nutritionVM: NutritionViewModel) -> Int {
        let cal = Calendar.current
        var streak = 0
        var d = cal.startOfDay(for: .now)
        while closedRings(on: d, appVM: appVM, nutritionVM: nutritionVM).count == RingType.allCases.count {
            streak += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: d) else { break }
            d = prev
        }
        return streak
    }

    func last7Days(appVM: AppViewModel, nutritionVM: NutritionViewModel) -> [(date: Date, closed: Set<RingType>, points: Int)] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        return (0..<7).reversed().compactMap { offset in
            guard let date = cal.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let closed = closedRings(on: date, appVM: appVM, nutritionVM: nutritionVM)
            let pts = pointsEarned(on: date, appVM: appVM, nutritionVM: nutritionVM)
            return (date: date, closed: closed, points: pts)
        }
    }

    // MARK: - Friends

    func addFriend(username: String, code: String) {
        let trimmedName = username.trimmingCharacters(in: .whitespaces)
        let trimmedCode = code.trimmingCharacters(in: .whitespaces).uppercased()
        guard !trimmedName.isEmpty, !trimmedCode.isEmpty else { return }
        guard !friends.contains(where: { $0.shareCode == trimmedCode }) else { return }

        // Generate plausible seeded points/streak
        var rng = SeededRandom(seed: UInt64(abs(trimmedCode.hashValue)))
        let friend = Friend(
            username: trimmedName,
            shareCode: trimmedCode,
            points: rng.next(in: 150...1800),
            streak: rng.next(in: 0...21),
            avatarEmoji: Self.randomAvatar(&rng)
        )
        friends.append(friend)
        persist()
    }

    func removeFriend(id: UUID) {
        friends.removeAll { $0.id == id }
        persist()
    }

    // MARK: - Persistence

    private func persist() {
        LocalStore.save(moodEntries, forKey: "reflectionMoodEntries")
        LocalStore.save(snapshots, forKey: "reflectionSnapshots")
        LocalStore.save(friends, forKey: "reflectionFriends")
        UserDefaults.standard.set(username, forKey: "reflectionUsername")
        UserDefaults.standard.set(shareCode, forKey: "reflectionShareCode")
    }

    private func loadData() {
        moodEntries = LocalStore.load([MoodEntry].self, forKey: "reflectionMoodEntries", fallback: [])
        snapshots = LocalStore.load([DailyRingsSnapshot].self, forKey: "reflectionSnapshots", fallback: [])
        friends = LocalStore.load([Friend].self, forKey: "reflectionFriends", fallback: [])
        username = UserDefaults.standard.string(forKey: "reflectionUsername") ?? ""
        shareCode = UserDefaults.standard.string(forKey: "reflectionShareCode") ?? ""
    }

    // MARK: - Helpers

    static func generateShareCode() -> String {
        let letters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<6).map { _ in letters.randomElement()! })
    }

    static func seedFriends() -> [Friend] {
        [
            Friend(username: "Alex", shareCode: "A1B2C3", points: 1240, streak: 12, avatarEmoji: "💪"),
            Friend(username: "Jordan", shareCode: "D4E5F6", points: 980, streak: 7, avatarEmoji: "🏃‍♀️"),
            Friend(username: "Sam", shareCode: "G7H8J9", points: 760, streak: 4, avatarEmoji: "🥗")
        ]
    }

    static func randomAvatar(_ rng: inout SeededRandom) -> String {
        let pool = ["💪", "🏃‍♀️", "🥗", "🧘", "🚴", "🏋️‍♂️", "🥑", "🔥", "⚡️", "🌊"]
        return pool[rng.next(in: 0..<pool.count)]
    }
}

nonisolated struct SeededRandom: Sendable {
    var state: UInt64
    init(seed: UInt64) { state = seed &+ 0x9E3779B97F4A7C15 }
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
    mutating func next(in range: Range<Int>) -> Int {
        let span = UInt64(range.count)
        return Int(next() % span) + range.lowerBound
    }
    mutating func next(in range: ClosedRange<Int>) -> Int {
        let span = UInt64(range.upperBound - range.lowerBound + 1)
        return Int(next() % span) + range.lowerBound
    }
}
