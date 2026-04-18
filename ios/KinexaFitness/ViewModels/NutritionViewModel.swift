import Foundation
import Observation

@Observable
final class NutritionViewModel {
    var meals: [MealEntry] = []
    var dailyGoal: DailyNutritionGoal = .default
    var selectedDate: Date = Calendar.current.startOfDay(for: .now)
    var isAnalyzing: Bool = false
    var dailyInsight: GeminiDailyInsight?
    var mealInsights: [UUID: GeminiMealInsight] = [:]
    var profile: NutritionProfile = .default
    var waterEntries: [WaterEntry] = []
    var waterGoal: WaterGoal = .default
    var favorites: [FavoriteFoodItem] = []
    var mealTemplates: [MealTemplate] = []
    var loggingStreak: Int = 0

    private let gemini = GeminiService()
    private let barcodeService = BarcodeLookupService()

    var isGeminiConfigured: Bool { gemini.isConfigured }
    var isProfileConfigured: Bool { profile.isConfigured }

    init() {
        loadData()
        calculateStreak()
    }

    var mealsForSelectedDate: [MealEntry] {
        let calendar = Calendar.current
        return meals.filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
            .sorted { $0.date < $1.date }
    }

    var todayNutrition: NutritionInfo {
        let dayMeals = mealsForSelectedDate
        return NutritionInfo(
            calories: dayMeals.map(\.totalNutrition.calories).reduce(0, +),
            protein: dayMeals.map(\.totalNutrition.protein).reduce(0, +),
            carbs: dayMeals.map(\.totalNutrition.carbs).reduce(0, +),
            fat: dayMeals.map(\.totalNutrition.fat).reduce(0, +),
            fiber: dayMeals.map(\.totalNutrition.fiber).reduce(0, +),
            sugar: dayMeals.map(\.totalNutrition.sugar).reduce(0, +),
            alcohol: dayMeals.map(\.totalNutrition.alcohol).reduce(0, +)
        )
    }

    var calorieProgress: Double {
        guard dailyGoal.calories > 0 else { return 0 }
        return min(Double(todayNutrition.calories) / Double(dailyGoal.calories), 1.0)
    }

    var proteinProgress: Double {
        guard dailyGoal.protein > 0 else { return 0 }
        return min(todayNutrition.protein / dailyGoal.protein, 1.0)
    }

    var carbsProgress: Double {
        guard dailyGoal.carbs > 0 else { return 0 }
        return min(todayNutrition.carbs / dailyGoal.carbs, 1.0)
    }

    var fatProgress: Double {
        guard dailyGoal.fat > 0 else { return 0 }
        return min(todayNutrition.fat / dailyGoal.fat, 1.0)
    }

    // MARK: - Water Tracking

    var waterForSelectedDate: [WaterEntry] {
        let calendar = Calendar.current
        return waterEntries.filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
    }

    var todayWaterOunces: Double {
        waterForSelectedDate.map(\.amount).reduce(0, +)
    }

    var waterProgress: Double {
        guard waterGoal.dailyOunces > 0 else { return 0 }
        return min(todayWaterOunces / waterGoal.dailyOunces, 1.0)
    }

    func addWater(_ ounces: Double) {
        let entry = WaterEntry(amount: ounces, date: selectedDate == Calendar.current.startOfDay(for: .now) ? .now : selectedDate)
        waterEntries.append(entry)
        persistData()
    }

    func removeLastWater() {
        guard let lastIndex = waterForSelectedDate.indices.last else { return }
        let lastEntry = waterForSelectedDate[lastIndex]
        waterEntries.removeAll { $0.id == lastEntry.id }
        persistData()
    }

    func updateWaterGoal(_ goal: WaterGoal) {
        waterGoal = goal
        persistData()
    }

    // MARK: - Favorites

    var recentFoods: [FavoriteFoodItem] {
        Array(favorites.sorted { $0.lastUsed > $1.lastUsed }.prefix(10))
    }

    var topFavorites: [FavoriteFoodItem] {
        Array(favorites.sorted { $0.usageCount > $1.usageCount }.prefix(10))
    }

    func addToFavorites(_ food: FoodItem) {
        if let idx = favorites.firstIndex(where: { $0.name.lowercased() == food.name.lowercased() }) {
            favorites[idx].usageCount += 1
            favorites[idx].lastUsed = .now
        } else {
            let fav = FavoriteFoodItem(
                name: food.name,
                quantity: food.quantity,
                nutrition: food.nutrition
            )
            favorites.append(fav)
        }
        persistData()
    }

    func removeFavorite(id: UUID) {
        favorites.removeAll { $0.id == id }
        persistData()
    }

    func isFavorite(_ name: String) -> Bool {
        favorites.contains { $0.name.lowercased() == name.lowercased() }
    }

    func toggleFavorite(_ food: FoodItem) {
        if let idx = favorites.firstIndex(where: { $0.name.lowercased() == food.name.lowercased() }) {
            favorites.remove(at: idx)
        } else {
            let fav = FavoriteFoodItem(
                name: food.name,
                quantity: food.quantity,
                nutrition: food.nutrition
            )
            favorites.append(fav)
        }
        persistData()
    }

    func quickLogFavorite(_ fav: FavoriteFoodItem, mealType: MealType) {
        let food = fav.toFoodItem()
        let meal = MealEntry(mealType: mealType, foods: [food])
        addMeal(meal)
    }

    func addFoodsToFavorites(_ foods: [FoodItem]) {
        for food in foods {
            addToFavorites(food)
        }
    }

    // MARK: - Profile

    func updateProfile(_ newProfile: NutritionProfile) {
        profile = newProfile
        persistData()
    }

    // MARK: - Meals

    func mealsForDate(_ date: Date) -> [MealEntry] {
        let calendar = Calendar.current
        return meals.filter { calendar.isDate($0.date, inSameDayAs: date) }
            .sorted { $0.date < $1.date }
    }

    func nutritionForDate(_ date: Date) -> NutritionInfo {
        let dayMeals = mealsForDate(date)
        return NutritionInfo(
            calories: dayMeals.map(\.totalNutrition.calories).reduce(0, +),
            protein: dayMeals.map(\.totalNutrition.protein).reduce(0, +),
            carbs: dayMeals.map(\.totalNutrition.carbs).reduce(0, +),
            fat: dayMeals.map(\.totalNutrition.fat).reduce(0, +),
            fiber: dayMeals.map(\.totalNutrition.fiber).reduce(0, +),
            sugar: dayMeals.map(\.totalNutrition.sugar).reduce(0, +),
            alcohol: dayMeals.map(\.totalNutrition.alcohol).reduce(0, +)
        )
    }

    func waterForDate(_ date: Date) -> Double {
        let calendar = Calendar.current
        return waterEntries.filter { calendar.isDate($0.date, inSameDayAs: date) }
            .map(\.amount).reduce(0, +)
    }

    func addMeal(_ meal: MealEntry) {
        meals.insert(meal, at: 0)
        addFoodsToFavorites(meal.foods)
        persistData()
        calculateStreak()
    }

    // MARK: - Repeat Meals & Templates

    var yesterdaysMeals: [MealEntry] {
        let calendar = Calendar.current
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: .now)) else { return [] }
        return meals.filter { calendar.isDate($0.date, inSameDayAs: yesterday) }
            .sorted { $0.date < $1.date }
    }

    func repeatMeal(_ meal: MealEntry, on date: Date? = nil, multiplier: Double = 1.0) {
        let targetDate = date ?? (Calendar.current.isDateInToday(selectedDate) ? .now : selectedDate)
        let scaledFoods: [FoodItem] = meal.foods.map { multiplier == 1.0 ? FoodItem(name: $0.name, quantity: $0.quantity, nutrition: $0.nutrition, barcode: $0.barcode, source: $0.source) : $0.scaled(by: multiplier) }
        let copy = MealEntry(
            date: targetDate,
            mealType: meal.mealType,
            foods: scaledFoods,
            notes: meal.notes
        )
        addMeal(copy)
    }

    func repeatYesterday() {
        let y = yesterdaysMeals
        guard !y.isEmpty else { return }
        let now = Date()
        for meal in y {
            repeatMeal(meal, on: now)
        }
    }

    func saveMealAsTemplate(_ meal: MealEntry, title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let template = MealTemplate(
            title: trimmed,
            mealType: meal.mealType,
            foods: meal.foods.map { FoodItem(name: $0.name, quantity: $0.quantity, nutrition: $0.nutrition, barcode: $0.barcode, source: $0.source) }
        )
        mealTemplates.insert(template, at: 0)
        persistData()
    }

    func applyTemplate(_ template: MealTemplate, mealType: MealType? = nil, multiplier: Double = 1.0) {
        let foods: [FoodItem] = template.foods.map { multiplier == 1.0 ? FoodItem(name: $0.name, quantity: $0.quantity, nutrition: $0.nutrition, barcode: $0.barcode, source: $0.source) : $0.scaled(by: multiplier) }
        let meal = MealEntry(
            date: Calendar.current.isDateInToday(selectedDate) ? .now : selectedDate,
            mealType: mealType ?? template.mealType,
            foods: foods
        )
        addMeal(meal)

        if let idx = mealTemplates.firstIndex(where: { $0.id == template.id }) {
            mealTemplates[idx].lastUsed = .now
            mealTemplates[idx].timesUsed += 1
            persistData()
        }
    }

    func deleteTemplate(id: UUID) {
        mealTemplates.removeAll { $0.id == id }
        persistData()
    }

    func deleteMeal(id: UUID) {
        meals.removeAll { $0.id == id }
        mealInsights.removeValue(forKey: id)
        persistData()
        calculateStreak()
    }

    func updateGoal(_ goal: DailyNutritionGoal) {
        dailyGoal = goal
        persistData()
    }

    // MARK: - Streak

    private func calculateStreak() {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: .now)

        while true {
            let dayMeals = meals.filter { calendar.isDate($0.date, inSameDayAs: checkDate) }
            if dayMeals.isEmpty { break }
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = prev
        }
        loggingStreak = streak
    }

    // MARK: - Weekly Stats

    func weeklyCalories() -> [(date: Date, calories: Int)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        return (0..<7).reversed().compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let nutrition = nutritionForDate(date)
            return (date: date, calories: nutrition.calories)
        }
    }

    func weeklyMacros() -> [(date: Date, protein: Double, carbs: Double, fat: Double)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        return (0..<7).reversed().compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let n = nutritionForDate(date)
            return (date: date, protein: n.protein, carbs: n.carbs, fat: n.fat)
        }
    }

    // MARK: - AI

    func estimateFoodFromText(_ description: String) async throws -> [FoodItem] {
        let prompt = """
        Estimate the nutritional information for the following food description. Return a JSON object with a "foods" array. Each food item should have: name (string), quantity (string like "1 cup", "200g"), calories (int), protein (double), carbs (double), fat (double), fiber (double), sugar (double), alcohol (double, grams of alcohol - use 0 for non-alcoholic items, estimate for alcoholic beverages). Be realistic with portion sizes and nutritional values.

        Food description: \(description)
        """

        let systemPrompt = "You are a nutrition expert. Provide accurate nutritional estimates based on USDA data. Always return valid JSON matching the requested format. All nutritional values should be realistic. For alcoholic drinks, estimate alcohol content in grams."

        let result = try await gemini.generateJSON(prompt: prompt, systemPrompt: systemPrompt, type: GeminiFoodEstimate.self)

        return result.foods.map { item in
            FoodItem(
                name: item.name,
                quantity: item.quantity,
                nutrition: NutritionInfo(
                    calories: item.calories,
                    protein: item.protein,
                    carbs: item.carbs,
                    fat: item.fat,
                    fiber: item.fiber,
                    sugar: item.sugar,
                    alcohol: item.alcohol ?? 0
                ),
                source: .aiText
            )
        }
    }

    func estimateFoodFromImage(_ imageData: Data) async throws -> [FoodItem] {
        let prompt = """
        Analyze this food photo and estimate the nutritional information for each visible food item. Return a JSON object with a "foods" array. Each food item should have: name (string), quantity (string like "1 cup", "200g"), calories (int), protein (double), carbs (double), fat (double), fiber (double), sugar (double), alcohol (double, grams of alcohol - use 0 for non-alcoholic items). Be realistic with portion sizes based on what you see in the image.
        """

        let systemPrompt = "You are an expert food recognition and nutrition AI. Analyze food photos to identify each item and provide accurate USDA-based nutritional estimates. Estimate portion sizes visually. Always return valid JSON. For drinks that appear alcoholic, estimate alcohol content in grams."

        let result = try await gemini.generateJSONWithImage(
            prompt: prompt,
            imageData: imageData,
            systemPrompt: systemPrompt,
            type: GeminiFoodEstimate.self
        )

        return result.foods.map { item in
            FoodItem(
                name: item.name,
                quantity: item.quantity,
                nutrition: NutritionInfo(
                    calories: item.calories,
                    protein: item.protein,
                    carbs: item.carbs,
                    fat: item.fat,
                    fiber: item.fiber,
                    sugar: item.sugar,
                    alcohol: item.alcohol ?? 0
                ),
                source: .aiPhoto
            )
        }
    }

    func lookupBarcode(_ code: String) async throws -> FoodItem {
        let product = try await barcodeService.lookup(barcode: code)
        let displayName = [product.brand, product.name]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " — ")

        return FoodItem(
            name: displayName.isEmpty ? product.name : displayName,
            quantity: product.servingSize ?? "100g",
            nutrition: NutritionInfo(
                calories: product.calories,
                protein: product.protein,
                carbs: product.carbs,
                fat: product.fat,
                fiber: product.fiber,
                sugar: product.sugar,
                alcohol: product.alcohol ?? 0
            ),
            barcode: code,
            source: .barcode
        )
    }

    func analyzeMeal(_ meal: MealEntry) async {
        guard !meal.foods.isEmpty else { return }
        isAnalyzing = true
        defer { isAnalyzing = false }

        let foodList = meal.foods.map { "\($0.name) (\($0.quantity)) - \($0.nutrition.calories) cal, \($0.nutrition.protein)g protein, \($0.nutrition.carbs)g carbs, \($0.nutrition.fat)g fat" }.joined(separator: "\n")

        let prompt = """
        Analyze this \(meal.mealType.rawValue.lowercased()) meal and provide insights. Return JSON with: summary (string, 1-2 sentences), strengths (array of strings, 2-3 items), improvements (array of strings, 2-3 items), tip (string, one actionable tip).

        Meal foods:
        \(foodList)

        Total: \(meal.totalNutrition.calories) cal, \(String(format: "%.1f", meal.totalNutrition.protein))g protein, \(String(format: "%.1f", meal.totalNutrition.carbs))g carbs, \(String(format: "%.1f", meal.totalNutrition.fat))g fat
        """

        let systemPrompt = "You are a sports nutrition coach for active individuals. Provide practical, encouraging advice focused on athletic performance and recovery. Return valid JSON only."

        do {
            let insight = try await gemini.generateJSON(prompt: prompt, systemPrompt: systemPrompt, type: GeminiMealInsight.self)
            mealInsights[meal.id] = insight
        } catch {}
    }

    func generateDailyInsight() async {
        let dayMeals = mealsForSelectedDate
        guard !dayMeals.isEmpty else { return }
        isAnalyzing = true
        defer { isAnalyzing = false }

        let mealSummaries = dayMeals.map { meal in
            "\(meal.mealType.rawValue): \(meal.foods.map(\.name).joined(separator: ", ")) — \(meal.totalNutrition.calories) cal"
        }.joined(separator: "\n")

        let total = todayNutrition

        let prompt = """
        Analyze this full day of nutrition for an active person and provide insights. Return JSON with: overview (string, 2-3 sentences), macroBalance (string, assessment of macro ratios), recommendations (array of 2-3 strings), mealTimingTip (string, one tip about meal timing).

        Daily Goal: \(dailyGoal.calories) cal, \(String(format: "%.0f", dailyGoal.protein))g protein, \(String(format: "%.0f", dailyGoal.carbs))g carbs, \(String(format: "%.0f", dailyGoal.fat))g fat

        Meals logged:
        \(mealSummaries)

        Total intake: \(total.calories) cal, \(String(format: "%.1f", total.protein))g protein, \(String(format: "%.1f", total.carbs))g carbs, \(String(format: "%.1f", total.fat))g fat, \(String(format: "%.1f", total.fiber))g fiber
        """

        let systemPrompt = "You are a sports nutrition coach. Analyze the day's nutrition relative to goals and provide practical, encouraging advice for athletic performance. Return valid JSON only."

        do {
            let insight = try await gemini.generateJSON(prompt: prompt, systemPrompt: systemPrompt, type: GeminiDailyInsight.self)
            dailyInsight = insight
        } catch {}
    }

    func generateMealSuggestion() async -> String? {
        guard isGeminiConfigured else { return nil }
        let remaining = dailyGoal.calories - todayNutrition.calories
        let remainingP = dailyGoal.protein - todayNutrition.protein
        let remainingC = dailyGoal.carbs - todayNutrition.carbs
        let remainingF = dailyGoal.fat - todayNutrition.fat

        guard remaining > 100 else { return nil }

        let prompt = """
        Suggest a single meal or snack to help hit remaining macros. Keep it simple and practical. Return just the suggestion as plain text (2-3 sentences max).

        Remaining targets:
        - Calories: \(remaining) cal
        - Protein: \(String(format: "%.0f", remainingP))g
        - Carbs: \(String(format: "%.0f", remainingC))g
        - Fat: \(String(format: "%.0f", remainingF))g

        Already eaten today: \(mealsForSelectedDate.flatMap(\.foods).map(\.name).joined(separator: ", "))
        """

        let systemPrompt = "You are a practical sports nutrition advisor. Suggest real, easily available foods. Be specific with portions. Keep it brief."

        return try? await gemini.generateText(prompt: prompt, systemPrompt: systemPrompt, maxTokens: 256)
    }

    // MARK: - Persistence

    private func persistData() {
        LocalStore.save(meals, forKey: "nutritionMeals")
        LocalStore.save(dailyGoal, forKey: "nutritionGoal")
        LocalStore.save(profile, forKey: "nutritionProfile")
        LocalStore.save(waterEntries, forKey: "nutritionWater")
        LocalStore.save(waterGoal, forKey: "nutritionWaterGoal")
        LocalStore.save(favorites, forKey: "nutritionFavorites")
        LocalStore.save(mealTemplates, forKey: "nutritionMealTemplates")
    }

    private func loadData() {
        meals = LocalStore.load([MealEntry].self, forKey: "nutritionMeals", fallback: [])
        dailyGoal = LocalStore.load(DailyNutritionGoal.self, forKey: "nutritionGoal", fallback: .default)
        profile = LocalStore.load(NutritionProfile.self, forKey: "nutritionProfile", fallback: .default)
        waterEntries = LocalStore.load([WaterEntry].self, forKey: "nutritionWater", fallback: [])
        waterGoal = LocalStore.load(WaterGoal.self, forKey: "nutritionWaterGoal", fallback: .default)
        favorites = LocalStore.load([FavoriteFoodItem].self, forKey: "nutritionFavorites", fallback: [])
        mealTemplates = LocalStore.load([MealTemplate].self, forKey: "nutritionMealTemplates", fallback: [])
    }
}
