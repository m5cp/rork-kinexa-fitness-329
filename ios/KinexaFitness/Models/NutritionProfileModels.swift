import Foundation

nonisolated enum BiologicalSex: String, Codable, CaseIterable, Identifiable, Sendable {
    case male = "Male"
    case female = "Female"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .male: return "figure.stand"
        case .female: return "figure.stand.dress"
        }
    }
}

nonisolated enum ActivityLevel: String, Codable, CaseIterable, Sendable {
    case sedentary = "Sedentary"
    case lightlyActive = "Lightly Active"
    case moderatelyActive = "Moderately Active"
    case veryActive = "Very Active"
    case extraActive = "Extra Active"

    var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .lightlyActive: return 1.375
        case .moderatelyActive: return 1.55
        case .veryActive: return 1.725
        case .extraActive: return 1.9
        }
    }

    var subtitle: String {
        switch self {
        case .sedentary: return "Little to no exercise"
        case .lightlyActive: return "Light exercise 1-3 days/week"
        case .moderatelyActive: return "Moderate exercise 3-5 days/week"
        case .veryActive: return "Hard exercise 6-7 days/week"
        case .extraActive: return "Very hard exercise + physical job"
        }
    }

    var icon: String {
        switch self {
        case .sedentary: return "figure.stand"
        case .lightlyActive: return "figure.walk"
        case .moderatelyActive: return "figure.run"
        case .veryActive: return "figure.highintensity.intervaltraining"
        case .extraActive: return "flame.fill"
        }
    }
}

nonisolated enum NutritionGoalType: String, Codable, CaseIterable, Sendable {
    case cut = "Cut"
    case maintain = "Maintain"
    case bulk = "Bulk"

    var calorieAdjustment: Int {
        switch self {
        case .cut: return -500
        case .maintain: return 0
        case .bulk: return 300
        }
    }

    var subtitle: String {
        switch self {
        case .cut: return "Lose fat, preserve muscle"
        case .maintain: return "Stay at current weight"
        case .bulk: return "Build muscle, gain strength"
        }
    }

    var icon: String {
        switch self {
        case .cut: return "arrow.down.circle.fill"
        case .maintain: return "equal.circle.fill"
        case .bulk: return "arrow.up.circle.fill"
        }
    }

    var color: String {
        switch self {
        case .cut: return "#EF4444"
        case .maintain: return "#3B82F6"
        case .bulk: return "#22C55E"
        }
    }

    var proteinRatio: Double {
        switch self {
        case .cut: return 0.40
        case .maintain: return 0.30
        case .bulk: return 0.30
        }
    }

    var carbsRatio: Double {
        switch self {
        case .cut: return 0.30
        case .maintain: return 0.40
        case .bulk: return 0.45
        }
    }

    var fatRatio: Double {
        switch self {
        case .cut: return 0.30
        case .maintain: return 0.30
        case .bulk: return 0.25
        }
    }
}

nonisolated enum HeightUnit: String, Codable, CaseIterable, Sendable {
    case imperial = "ft/in"
    case metric = "cm"
}

nonisolated enum WeightUnit: String, Codable, CaseIterable, Sendable {
    case lbs = "lbs"
    case kg = "kg"
}

nonisolated struct NutritionProfile: Codable, Sendable {
    var age: Int
    var sex: BiologicalSex
    var heightCm: Double
    var weightKg: Double
    var activityLevel: ActivityLevel
    var goalType: NutritionGoalType
    var heightUnit: HeightUnit
    var weightUnit: WeightUnit
    var isConfigured: Bool

    static let `default` = NutritionProfile(
        age: 30,
        sex: .male,
        heightCm: 175,
        weightKg: 80,
        activityLevel: .moderatelyActive,
        goalType: .maintain,
        heightUnit: .imperial,
        weightUnit: .lbs,
        isConfigured: false
    )

    var bmr: Double {
        switch sex {
        case .male:
            return 10 * weightKg + 6.25 * heightCm - 5 * Double(age) + 5
        case .female:
            return 10 * weightKg + 6.25 * heightCm - 5 * Double(age) - 161
        }
    }

    var tdee: Double {
        bmr * activityLevel.multiplier
    }

    var calorieTarget: Int {
        max(1200, Int(tdee) + goalType.calorieAdjustment)
    }

    var proteinGrams: Double {
        (Double(calorieTarget) * goalType.proteinRatio) / 4.0
    }

    var carbsGrams: Double {
        (Double(calorieTarget) * goalType.carbsRatio) / 4.0
    }

    var fatGrams: Double {
        (Double(calorieTarget) * goalType.fatRatio) / 9.0
    }

    var calculatedGoal: DailyNutritionGoal {
        DailyNutritionGoal(
            calories: calorieTarget,
            protein: proteinGrams,
            carbs: carbsGrams,
            fat: fatGrams
        )
    }

    var heightFeet: Int {
        Int(heightCm / 2.54) / 12
    }

    var heightInches: Int {
        Int(heightCm / 2.54) % 12
    }

    var weightLbs: Double {
        weightKg * 2.20462
    }
}

nonisolated struct WaterEntry: Codable, Identifiable, Sendable {
    let id: UUID
    var amount: Double
    var date: Date

    init(id: UUID = UUID(), amount: Double, date: Date = .now) {
        self.id = id
        self.amount = amount
        self.date = date
    }
}

nonisolated struct WaterGoal: Codable, Sendable {
    var dailyOunces: Double

    static let `default` = WaterGoal(dailyOunces: 48)
}

nonisolated struct FavoriteFoodItem: Codable, Identifiable, Sendable {
    let id: UUID
    var name: String
    var quantity: String
    var nutrition: NutritionInfo
    var usageCount: Int
    var lastUsed: Date

    init(id: UUID = UUID(), name: String, quantity: String, nutrition: NutritionInfo, usageCount: Int = 1, lastUsed: Date = .now) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.nutrition = nutrition
        self.usageCount = usageCount
        self.lastUsed = lastUsed
    }

    func toFoodItem(source: FoodSource = .manual) -> FoodItem {
        FoodItem(name: name, quantity: quantity, nutrition: nutrition, source: source)
    }
}
