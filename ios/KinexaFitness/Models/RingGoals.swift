import Foundation

nonisolated struct RingGoals: Codable, Sendable, Equatable {
    var moveSteps: Int
    var meals: Int

    static let defaultMoveSteps: Int = 10000
    static let defaultMeals: Int = 2
    static let defaultWaterOunces: Double = 48

    static let moveRange: ClosedRange<Int> = 1000...30000
    static let moveStep: Int = 500

    static let mealsRange: ClosedRange<Int> = 1...6

    static let waterRange: ClosedRange<Double> = 16...200
    static let waterStep: Double = 8

    static let `default` = RingGoals(
        moveSteps: defaultMoveSteps,
        meals: defaultMeals
    )
}
