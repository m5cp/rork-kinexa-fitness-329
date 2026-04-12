import Foundation

nonisolated struct Recipe: Codable, Identifiable, Sendable {
    let id: UUID
    var title: String
    var summary: String
    var prepTime: String
    var cookTime: String
    var servings: Int
    var difficulty: RecipeDifficulty
    var tags: [String]
    var ingredients: [RecipeIngredient]
    var instructions: [String]
    var nutrition: RecipeNutrition
    var createdAt: Date
    var isFavorite: Bool

    init(id: UUID = UUID(), title: String, summary: String, prepTime: String, cookTime: String, servings: Int, difficulty: RecipeDifficulty, tags: [String], ingredients: [RecipeIngredient], instructions: [String], nutrition: RecipeNutrition, createdAt: Date = .now, isFavorite: Bool = false) {
        self.id = id
        self.title = title
        self.summary = summary
        self.prepTime = prepTime
        self.cookTime = cookTime
        self.servings = servings
        self.difficulty = difficulty
        self.tags = tags
        self.ingredients = ingredients
        self.instructions = instructions
        self.nutrition = nutrition
        self.createdAt = createdAt
        self.isFavorite = isFavorite
    }
}

nonisolated enum RecipeDifficulty: String, Codable, CaseIterable, Sendable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"

    var icon: String {
        switch self {
        case .easy: return "leaf.fill"
        case .medium: return "flame.fill"
        case .hard: return "star.fill"
        }
    }

    var color: String {
        switch self {
        case .easy: return "#22C55E"
        case .medium: return "#F59E0B"
        case .hard: return "#EF4444"
        }
    }
}

nonisolated struct RecipeIngredient: Codable, Identifiable, Sendable {
    let id: UUID
    var name: String
    var amount: String

    init(id: UUID = UUID(), name: String, amount: String) {
        self.id = id
        self.name = name
        self.amount = amount
    }
}

nonisolated struct RecipeNutrition: Codable, Sendable {
    var calories: Int
    var protein: Double
    var carbs: Double
    var fat: Double
    var fiber: Double
}

nonisolated enum RecipeCategory: String, CaseIterable, Sendable {
    case all = "All"
    case highProtein = "High Protein"
    case lowCarb = "Low Carb"
    case quickMeals = "Quick Meals"
    case mealPrep = "Meal Prep"
    case postWorkout = "Post-Workout"
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snacks = "Snacks"

    var icon: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .highProtein: return "bolt.fill"
        case .lowCarb: return "leaf.fill"
        case .quickMeals: return "clock.fill"
        case .mealPrep: return "takeoutbag.and.cup.and.straw.fill"
        case .postWorkout: return "figure.run"
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.stars.fill"
        case .snacks: return "carrot.fill"
        }
    }
}

nonisolated struct GroqRecipeResponse: Codable, Sendable {
    let recipes: [GroqRecipeItem]
}

nonisolated struct GroqRecipeItem: Codable, Sendable {
    let title: String
    let summary: String
    let prepTime: String
    let cookTime: String
    let servings: Int
    let difficulty: String
    let tags: [String]
    let ingredients: [GroqIngredientItem]
    let instructions: [String]
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double
}

nonisolated struct GroqIngredientItem: Codable, Sendable {
    let name: String
    let amount: String
}
