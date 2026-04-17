import Foundation

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
