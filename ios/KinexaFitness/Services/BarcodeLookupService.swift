import Foundation

nonisolated struct OpenFoodFactsProduct: Codable, Sendable {
    let product: OpenFoodFactsItem?
    let status: Int
}

nonisolated struct OpenFoodFactsItem: Codable, Sendable {
    let product_name: String?
    let brands: String?
    let serving_size: String?
    let nutriments: OpenFoodFactsNutriments?
}

nonisolated struct OpenFoodFactsNutriments: Codable, Sendable {
    let energy_kcal_100g: Double?
    let proteins_100g: Double?
    let carbohydrates_100g: Double?
    let fat_100g: Double?
    let fiber_100g: Double?
    let sugars_100g: Double?
    let alcohol_100g: Double?

    enum CodingKeys: String, CodingKey {
        case energy_kcal_100g = "energy-kcal_100g"
        case proteins_100g = "proteins_100g"
        case carbohydrates_100g = "carbohydrates_100g"
        case fat_100g = "fat_100g"
        case fiber_100g = "fiber_100g"
        case sugars_100g = "sugars_100g"
        case alcohol_100g = "alcohol_100g"
    }
}

nonisolated enum BarcodeLookupError: Error, Sendable {
    case productNotFound
    case networkError(String)
}

nonisolated class BarcodeLookupService: Sendable {
    func lookup(barcode: String) async throws -> BarcodeProduct {
        let urlString = "https://world.openfoodfacts.org/api/v2/product/\(barcode).json?fields=product_name,brands,serving_size,nutriments"
        guard let url = URL(string: urlString) else {
            throw BarcodeLookupError.networkError("Invalid URL")
        }

        var request = URLRequest(url: url)
        request.setValue("KinexaFitness/1.0", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw BarcodeLookupError.networkError("Server error")
        }

        let result = try JSONDecoder().decode(OpenFoodFactsProduct.self, from: data)

        guard let item = result.product, result.status == 1 else {
            throw BarcodeLookupError.productNotFound
        }

        let n = item.nutriments
        return BarcodeProduct(
            name: item.product_name ?? "Unknown Product",
            brand: item.brands,
            servingSize: item.serving_size ?? "100g",
            calories: Int(n?.energy_kcal_100g ?? 0),
            protein: n?.proteins_100g ?? 0,
            carbs: n?.carbohydrates_100g ?? 0,
            fat: n?.fat_100g ?? 0,
            fiber: n?.fiber_100g ?? 0,
            sugar: n?.sugars_100g ?? 0,
            alcohol: n?.alcohol_100g
        )
    }
}
