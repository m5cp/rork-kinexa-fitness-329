import Foundation

nonisolated struct MealTemplate: Codable, Identifiable, Sendable {
    let id: UUID
    var title: String
    var mealType: MealType
    var foods: [FoodItem]
    var createdAt: Date
    var lastUsed: Date
    var timesUsed: Int

    init(
        id: UUID = UUID(),
        title: String,
        mealType: MealType,
        foods: [FoodItem],
        createdAt: Date = .now,
        lastUsed: Date = .now,
        timesUsed: Int = 0
    ) {
        self.id = id
        self.title = title
        self.mealType = mealType
        self.foods = foods
        self.createdAt = createdAt
        self.lastUsed = lastUsed
        self.timesUsed = timesUsed
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

extension FoodItem {
    func scaled(by multiplier: Double) -> FoodItem {
        let m = max(0.1, multiplier)
        let n = nutrition
        let scaledNutrition = NutritionInfo(
            calories: Int((Double(n.calories) * m).rounded()),
            protein: n.protein * m,
            carbs: n.carbs * m,
            fat: n.fat * m,
            fiber: n.fiber * m,
            sugar: n.sugar * m,
            alcohol: n.alcohol * m
        )
        return FoodItem(
            id: UUID(),
            name: name,
            quantity: quantity,
            nutrition: scaledNutrition,
            barcode: barcode,
            source: source
        )
    }
}
