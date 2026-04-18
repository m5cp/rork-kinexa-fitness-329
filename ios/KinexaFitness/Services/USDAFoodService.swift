import Foundation

actor USDASearchCache {
    static let shared = USDASearchCache()
    private var cache: [String: USDAFood?] = [:]

    func get(_ key: String) -> USDAFood?? { cache[key] }
    func set(_ key: String, value: USDAFood?) { cache[key] = value }
}

nonisolated struct USDASearchResponse: Codable, Sendable {
    let foods: [USDAFood]?
    let totalHits: Int?
}

nonisolated struct USDAFood: Codable, Identifiable, Sendable {
    let fdcId: Int
    let description: String
    let brandOwner: String?
    let brandName: String?
    let servingSize: Double?
    let servingSizeUnit: String?
    let householdServingFullText: String?
    let dataType: String?
    let foodNutrients: [USDANutrient]?

    var id: Int { fdcId }

    var displayName: String {
        let brand = [brandName, brandOwner].compactMap { $0 }.first { !$0.isEmpty }
        if let brand, !brand.isEmpty {
            return "\(description) — \(brand.capitalized)"
        }
        return description.capitalized
    }

    var displayServing: String {
        if let text = householdServingFullText, !text.isEmpty { return text }
        if let size = servingSize, let unit = servingSizeUnit {
            return "\(Int(size))\(unit)"
        }
        return "100g"
    }

    func nutrientValue(ids: [Int], names: [String]) -> Double {
        guard let nutrients = foodNutrients else { return 0 }
        for n in nutrients {
            if let nid = n.nutrientId, ids.contains(nid), let v = n.value { return v }
            if let name = n.nutrientName, names.contains(where: { name.localizedCaseInsensitiveContains($0) }), let v = n.value { return v }
        }
        return 0
    }

    var calories: Int { Int(nutrientValue(ids: [1008], names: ["Energy"])) }
    var protein: Double { nutrientValue(ids: [1003], names: ["Protein"]) }
    var carbs: Double { nutrientValue(ids: [1005], names: ["Carbohydrate"]) }
    var fat: Double { nutrientValue(ids: [1004], names: ["Total lipid", "Total fat"]) }
    var fiber: Double { nutrientValue(ids: [1079], names: ["Fiber"]) }
    var sugar: Double { nutrientValue(ids: [2000, 1063], names: ["Sugars"]) }
}

nonisolated struct USDANutrient: Codable, Sendable {
    let nutrientId: Int?
    let nutrientName: String?
    let nutrientNumber: String?
    let unitName: String?
    let value: Double?
}

nonisolated enum USDAError: Error, Sendable {
    case missingAPIKey
    case invalidURL
    case networkError(String)
    case noResults
}

nonisolated final class USDAFoodService: Sendable {
    static let shared = USDAFoodService()

    var isConfigured: Bool {
        !Config.EXPO_PUBLIC_USDA_API_KEY.isEmpty
    }

    func search(query: String, pageSize: Int = 25) async throws -> [USDAFood] {
        let apiKey = Config.EXPO_PUBLIC_USDA_API_KEY
        guard !apiKey.isEmpty else { throw USDAError.missingAPIKey }

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        var components = URLComponents(string: "https://api.nal.usda.gov/fdc/v1/foods/search")
        components?.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "query", value: trimmed),
            URLQueryItem(name: "pageSize", value: "\(pageSize)"),
            URLQueryItem(name: "dataType", value: "Branded,SR Legacy,Survey (FNDDS),Foundation")
        ]

        guard let url = components?.url else { throw USDAError.invalidURL }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 20

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw USDAError.networkError("Invalid response")
        }
        guard (200...299).contains(http.statusCode) else {
            throw USDAError.networkError("Server error \(http.statusCode)")
        }

        let decoded = try JSONDecoder().decode(USDASearchResponse.self, from: data)
        return decoded.foods ?? []
    }

    // MARK: - Silent verification for AI logs

    func verifyFoods(_ foods: [FoodItem], timeoutSeconds: Double = 2.0) async -> [FoodItem] {
        guard isConfigured, !foods.isEmpty else { return foods }
        return await withTaskGroup(of: (Int, FoodItem).self) { group in
            for (idx, food) in foods.enumerated() {
                group.addTask {
                    let verified = await Self.verifyOne(food, timeoutSeconds: timeoutSeconds)
                    return (idx, verified)
                }
            }
            var results = Array(foods.enumerated()).map { $0.element }
            for await (idx, item) in group {
                results[idx] = item
            }
            return results
        }
    }

    private static func verifyOne(_ food: FoodItem, timeoutSeconds: Double) async -> FoodItem {
        let key = normalize(food.name)
        guard !key.isEmpty else { return food }

        if let cached = await USDASearchCache.shared.get(key) {
            return apply(cached, to: food) ?? food
        }

        let match: USDAFood? = await withTaskGroup(of: USDAFood?.self) { group in
            group.addTask {
                try? await Self.fetchBest(query: key)
            }
            group.addTask {
                try? await Task.sleep(for: .seconds(timeoutSeconds))
                return nil
            }
            let first = await group.next() ?? nil
            group.cancelAll()
            return first.flatMap { $0 }
        }

        await USDASearchCache.shared.set(key, value: match)
        return apply(match, to: food) ?? food
    }

    private static func fetchBest(query: String) async throws -> USDAFood? {
        let apiKey = Config.EXPO_PUBLIC_USDA_API_KEY
        guard !apiKey.isEmpty else { return nil }

        var components = URLComponents(string: "https://api.nal.usda.gov/fdc/v1/foods/search")
        components?.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "pageSize", value: "5"),
            URLQueryItem(name: "dataType", value: "Foundation,SR Legacy,Survey (FNDDS)")
        ]
        guard let url = components?.url else { return nil }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 5

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else { return nil }
        let decoded = try JSONDecoder().decode(USDASearchResponse.self, from: data)
        let foods = decoded.foods ?? []
        let tokens = query.split(separator: " ").map(String.init).filter { $0.count > 2 }
        return foods.first { food in
            let desc = food.description.lowercased()
            return tokens.allSatisfy { desc.contains($0) } && food.calories > 0
        } ?? foods.first { $0.calories > 0 }
    }

    private static func apply(_ usda: USDAFood?, to food: FoodItem) -> FoodItem? {
        guard let usda, usda.calories > 0 else { return nil }
        let grams = parseGrams(from: food.quantity)
        let scale: Double
        if let g = grams {
            scale = g / 100.0
        } else if food.nutrition.calories > 0 {
            scale = Double(food.nutrition.calories) / Double(usda.calories)
        } else {
            scale = 1.0
        }
        let scaledCalories = Int((Double(usda.calories) * scale).rounded())
        let aiCals = max(food.nutrition.calories, 1)
        let ratio = Double(scaledCalories) / Double(aiCals)
        if grams == nil, food.nutrition.calories > 0, (ratio < 0.33 || ratio > 3.0) {
            return nil
        }
        var updated = food
        updated.nutrition = NutritionInfo(
            calories: scaledCalories,
            protein: usda.protein * scale,
            carbs: usda.carbs * scale,
            fat: usda.fat * scale,
            fiber: usda.fiber * scale,
            sugar: usda.sugar * scale,
            alcohol: food.nutrition.alcohol
        )
        return updated
    }

    private static func normalize(_ name: String) -> String {
        let stop: Set<String> = ["grilled", "fresh", "cooked", "raw", "baked", "fried", "steamed", "roasted", "with", "and", "the", "a", "an", "of", "served", "sliced", "chopped", "diced", "medium", "large", "small", "organic", "plain"]
        let lower = name.lowercased()
        let cleaned = lower.unicodeScalars.map { CharacterSet.letters.contains($0) || $0 == " " ? Character($0) : " " }
        let tokens = String(cleaned).split(separator: " ").map(String.init).filter { !stop.contains($0) && $0.count > 1 }
        return tokens.joined(separator: " ")
    }

    private static func parseGrams(from quantity: String) -> Double? {
        let lower = quantity.lowercased()
        let pattern = #"([0-9]+(?:\.[0-9]+)?)\s*(g|gram|grams|oz|ounce|ounces|ml|milliliter|milliliters|kg)"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(lower.startIndex..., in: lower)
        guard let match = regex.firstMatch(in: lower, range: range),
              let numRange = Range(match.range(at: 1), in: lower),
              let unitRange = Range(match.range(at: 2), in: lower),
              let value = Double(lower[numRange]) else { return nil }
        let unit = String(lower[unitRange])
        switch unit {
        case "g", "gram", "grams", "ml", "milliliter", "milliliters": return value
        case "kg": return value * 1000
        case "oz", "ounce", "ounces": return value * 28.3495
        default: return nil
        }
    }

    func toFoodItem(_ food: USDAFood) -> FoodItem {
        FoodItem(
            name: food.displayName,
            quantity: food.displayServing,
            nutrition: NutritionInfo(
                calories: food.calories,
                protein: food.protein,
                carbs: food.carbs,
                fat: food.fat,
                fiber: food.fiber,
                sugar: food.sugar,
                alcohol: 0
            ),
            source: .manual
        )
    }
}
