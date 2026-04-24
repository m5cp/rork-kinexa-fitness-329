import Foundation

nonisolated struct RingGoals: Codable, Sendable, Equatable {
    var moveSteps: Int
    var meals: Int
    var sleepHours: Int

    static let defaultMoveSteps: Int = 10000
    static let defaultMeals: Int = 2
    static let defaultWaterOunces: Double = 48
    static let defaultSleepHours: Int = 7

    static let moveRange: ClosedRange<Int> = 1000...30000
    static let moveStep: Int = 500
    static let mealsRange: ClosedRange<Int> = 1...6
    static let waterRange: ClosedRange<Double> = 16...200
    static let waterStep: Double = 8
    static let sleepRange: ClosedRange<Int> = 5...10

    static let `default` = RingGoals(
        moveSteps: defaultMoveSteps,
        meals: defaultMeals,
        sleepHours: defaultSleepHours
    )

    init(moveSteps: Int, meals: Int, sleepHours: Int = 7) {
        self.moveSteps = moveSteps
        self.meals = meals
        self.sleepHours = sleepHours
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        moveSteps = try c.decodeIfPresent(Int.self, forKey: .moveSteps) ?? RingGoals.defaultMoveSteps
        meals = try c.decodeIfPresent(Int.self, forKey: .meals) ?? RingGoals.defaultMeals
        sleepHours = try c.decodeIfPresent(Int.self, forKey: .sleepHours) ?? RingGoals.defaultSleepHours
    }
}
