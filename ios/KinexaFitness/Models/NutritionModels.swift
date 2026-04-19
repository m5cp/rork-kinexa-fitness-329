import Foundation

nonisolated enum MealType: String, Codable, CaseIterable, Sendable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"

    var icon: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.stars.fill"
        case .snack: return "leaf.fill"
        }
    }

    var color: String {
        switch self {
        case .breakfast: return "#F59E0B"
        case .lunch: return "#22C55E"
        case .dinner: return "#6366F1"
        case .snack: return "#EC4899"
        }
    }
}

nonisolated struct NutritionInfo: Codable, Sendable {
    var calories: Int
    var protein: Double
    var carbs: Double
    var fat: Double
    var fiber: Double
    var sugar: Double
    var alcohol: Double

    static let zero = NutritionInfo(calories: 0, protein: 0, carbs: 0, fat: 0, fiber: 0, sugar: 0, alcohol: 0)

    init(calories: Int, protein: Double, carbs: Double, fat: Double, fiber: Double, sugar: Double, alcohol: Double = 0) {
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.fiber = fiber
        self.sugar = sugar
        self.alcohol = alcohol
    }
}

nonisolated struct FoodItem: Codable, Identifiable, Sendable {
    let id: UUID
    var name: String
    var quantity: String
    var nutrition: NutritionInfo
    var barcode: String?
    var source: FoodSource

    init(id: UUID = UUID(), name: String, quantity: String, nutrition: NutritionInfo, barcode: String? = nil, source: FoodSource = .manual) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.nutrition = nutrition
        self.barcode = barcode
        self.source = source
    }
}

nonisolated enum FoodSource: String, Codable, Sendable {
    case manual
    case aiText
    case aiPhoto
    case barcode
}

nonisolated struct MealEntry: Codable, Identifiable, Sendable {
    let id: UUID
    var date: Date
    var mealType: MealType
    var foods: [FoodItem]
    var notes: String
    var photoData: Data?

    init(id: UUID = UUID(), date: Date = .now, mealType: MealType, foods: [FoodItem], notes: String = "", photoData: Data? = nil) {
        self.id = id
        self.date = date
        self.mealType = mealType
        self.foods = foods
        self.notes = notes
        self.photoData = photoData
    }

    var totalNutrition: NutritionInfo {
        NutritionInfo(
            calories: foods.map(\.nutrition.calories).reduce(0, +),
            protein: foods.map(\.nutrition.protein).reduce(0, +),
            carbs: foods.map(\.nutrition.carbs).reduce(0, +),
            fat: foods.map(\.nutrition.fat).reduce(0, +),
            fiber: foods.map(\.nutrition.fiber).reduce(0, +),
            sugar: foods.map(\.nutrition.sugar).reduce(0, +),
            alcohol: foods.map(\.nutrition.alcohol).reduce(0, +)
        )
    }
}

nonisolated struct DailyNutritionGoal: Codable, Sendable {
    var calories: Int
    var protein: Double
    var carbs: Double
    var fat: Double

    static let `default` = DailyNutritionGoal(calories: 2200, protein: 150, carbs: 250, fat: 75)
}

nonisolated struct GeminiFoodEstimate: Codable, Sendable {
    let foods: [GeminiFoodItem]
}

nonisolated struct GeminiFoodItem: Codable, Sendable {
    let name: String
    let quantity: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double
    let sugar: Double
    let alcohol: Double?

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.name = (try? c.decode(String.self, forKey: .name)) ?? "Unknown food"
        self.quantity = (try? c.decode(String.self, forKey: .quantity)) ?? "1 serving"
        if let i = try? c.decode(Int.self, forKey: .calories) {
            self.calories = i
        } else if let d = try? c.decode(Double.self, forKey: .calories) {
            self.calories = Int(d.rounded())
        } else {
            self.calories = 0
        }
        self.protein = (try? c.decode(Double.self, forKey: .protein)) ?? 0
        self.carbs = (try? c.decode(Double.self, forKey: .carbs)) ?? 0
        self.fat = (try? c.decode(Double.self, forKey: .fat)) ?? 0
        self.fiber = (try? c.decode(Double.self, forKey: .fiber)) ?? 0
        self.sugar = (try? c.decode(Double.self, forKey: .sugar)) ?? 0
        self.alcohol = try? c.decode(Double.self, forKey: .alcohol)
    }

    enum CodingKeys: String, CodingKey {
        case name, quantity, calories, protein, carbs, fat, fiber, sugar, alcohol
    }
}

nonisolated struct BarcodeProduct: Codable, Sendable {
    let name: String
    let brand: String?
    let servingSize: String?
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double
    let sugar: Double
    let alcohol: Double?
}

nonisolated struct GeminiMealInsight: Codable, Sendable {
    let summary: String
    let strengths: [String]
    let improvements: [String]
    let tip: String
}

nonisolated struct GeminiDailyInsight: Codable, Sendable {
    let overview: String
    let macroBalance: String
    let recommendations: [String]
    let mealTimingTip: String
}
