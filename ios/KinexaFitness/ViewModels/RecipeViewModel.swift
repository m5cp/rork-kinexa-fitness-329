import Foundation
import Observation

@Observable
final class RecipeViewModel {
    var recipes: [Recipe] = []
    var isGenerating: Bool = false
    var selectedCategory: RecipeCategory = .all
    var errorMessage: String?

    private let groq = GroqService()

    var isGroqConfigured: Bool { groq.isConfigured }

    init() {
        loadRecipes()
    }

    var filteredRecipes: [Recipe] {
        guard selectedCategory != .all else {
            return recipes.sorted { $0.createdAt > $1.createdAt }
        }
        let tag = selectedCategory.rawValue.lowercased()
        return recipes.filter { recipe in
            recipe.tags.contains { $0.lowercased().contains(tag) }
        }.sorted { $0.createdAt > $1.createdAt }
    }

    var favoriteRecipes: [Recipe] {
        recipes.filter(\.isFavorite).sorted { $0.createdAt > $1.createdAt }
    }

    func generateRecipes(profile: NutritionProfile, currentNutrition: NutritionInfo, goal: DailyNutritionGoal, category: RecipeCategory = .all, customRequest: String? = nil) async {
        guard isGroqConfigured else {
            errorMessage = "Groq API key not configured"
            return
        }

        isGenerating = true
        errorMessage = nil
        defer { isGenerating = false }

        let remainingCal = max(0, goal.calories - currentNutrition.calories)
        let remainingP = max(0, goal.protein - currentNutrition.protein)
        let remainingC = max(0, goal.carbs - currentNutrition.carbs)
        let remainingF = max(0, goal.fat - currentNutrition.fat)

        let categoryHint = category == .all ? "" : "Focus on \(category.rawValue) recipes."
        let customHint = customRequest.map { "User request: \($0)." } ?? ""

        let prompt = """
        Generate 3 unique, delicious recipes that fit these nutritional targets. Return a JSON object with a "recipes" array.

        User profile:
        - Goal: \(profile.goalType.rawValue) (\(profile.goalType.subtitle))
        - Activity: \(profile.activityLevel.rawValue)
        - Daily target: \(goal.calories) cal, \(String(format: "%.0f", goal.protein))g protein, \(String(format: "%.0f", goal.carbs))g carbs, \(String(format: "%.0f", goal.fat))g fat

        Remaining macros for today:
        - Calories: \(remainingCal) cal
        - Protein: \(String(format: "%.0f", remainingP))g
        - Carbs: \(String(format: "%.0f", remainingC))g
        - Fat: \(String(format: "%.0f", remainingF))g

        \(categoryHint)
        \(customHint)

        Each recipe must have: title (string), summary (string, 1-2 sentences), prepTime (string like "10 min"), cookTime (string like "20 min"), servings (int), difficulty (string: "Easy", "Medium", or "Hard"), tags (array of strings like ["High Protein", "Quick Meals", "Lunch"]), ingredients (array of objects with "name" and "amount"), instructions (array of step strings), calories (int per serving), protein (double per serving), carbs (double per serving), fat (double per serving), fiber (double per serving).

        Make recipes practical, with common grocery store ingredients. Vary the complexity and meal types.
        """

        let systemPrompt = "You are a professional chef and sports nutritionist. Create delicious, macro-friendly recipes that taste great and support athletic performance goals. Use common ingredients. Return valid JSON only."

        do {
            let response = try await groq.generateJSON(
                prompt: prompt,
                systemPrompt: systemPrompt,
                temperature: 0.8,
                maxTokens: 4096,
                type: GroqRecipeResponse.self
            )

            let newRecipes = response.recipes.map { item in
                Recipe(
                    title: item.title,
                    summary: item.summary,
                    prepTime: item.prepTime,
                    cookTime: item.cookTime,
                    servings: item.servings,
                    difficulty: RecipeDifficulty(rawValue: item.difficulty) ?? .medium,
                    tags: item.tags,
                    ingredients: item.ingredients.map { RecipeIngredient(name: $0.name, amount: $0.amount) },
                    instructions: item.instructions,
                    nutrition: RecipeNutrition(
                        calories: item.calories,
                        protein: item.protein,
                        carbs: item.carbs,
                        fat: item.fat,
                        fiber: item.fiber
                    )
                )
            }

            recipes.append(contentsOf: newRecipes)
            persistRecipes()
        } catch {
            errorMessage = "Failed to generate recipes. Please try again."
        }
    }

    func toggleFavorite(id: UUID) {
        guard let idx = recipes.firstIndex(where: { $0.id == id }) else { return }
        recipes[idx].isFavorite.toggle()
        persistRecipes()
    }

    func deleteRecipe(id: UUID) {
        recipes.removeAll { $0.id == id }
        persistRecipes()
    }

    func clearAll() {
        recipes.removeAll()
        persistRecipes()
    }

    private func persistRecipes() {
        LocalStore.save(recipes, forKey: "groqRecipes")
    }

    private func loadRecipes() {
        recipes = LocalStore.load([Recipe].self, forKey: "groqRecipes", fallback: [])
    }
}
