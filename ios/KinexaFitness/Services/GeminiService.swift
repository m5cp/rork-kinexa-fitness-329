import Foundation

nonisolated struct GeminiContent: Codable, Sendable {
    let parts: [GeminiPart]
    let role: String?

    init(parts: [GeminiPart], role: String? = nil) {
        self.parts = parts
        self.role = role
    }
}

nonisolated struct GeminiPart: Codable, Sendable {
    let text: String?

    init(text: String) {
        self.text = text
    }
}

nonisolated struct GeminiRequest: Codable, Sendable {
    let contents: [GeminiContent]
    let generationConfig: GeminiGenerationConfig?
    let systemInstruction: GeminiContent?

    init(contents: [GeminiContent], generationConfig: GeminiGenerationConfig? = nil, systemInstruction: GeminiContent? = nil) {
        self.contents = contents
        self.generationConfig = generationConfig
        self.systemInstruction = systemInstruction
    }
}

nonisolated struct GeminiGenerationConfig: Codable, Sendable {
    let temperature: Double?
    let maxOutputTokens: Int?
    let responseMimeType: String?

    init(temperature: Double? = nil, maxOutputTokens: Int? = nil, responseMimeType: String? = nil) {
        self.temperature = temperature
        self.maxOutputTokens = maxOutputTokens
        self.responseMimeType = responseMimeType
    }
}

nonisolated struct GeminiResponse: Codable, Sendable {
    let candidates: [GeminiCandidate]?
}

nonisolated struct GeminiCandidate: Codable, Sendable {
    let content: GeminiContent?
}

nonisolated enum GeminiError: Error, Sendable {
    case missingAPIKey
    case invalidURL
    case networkError(String)
    case decodingError(String)
    case noContent
}

@Observable
final class GeminiService {
    var isLoading: Bool = false

    private var apiKey: String {
        Config.EXPO_PUBLIC_GEMINI_API_KEY
    }

    var isConfigured: Bool {
        !apiKey.isEmpty
    }

    func generateText(prompt: String, systemPrompt: String? = nil, temperature: Double = 0.7, maxTokens: Int = 2048) async throws -> String {
        guard !apiKey.isEmpty else { throw GeminiError.missingAPIKey }

        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else { throw GeminiError.invalidURL }

        let contents = [GeminiContent(parts: [GeminiPart(text: prompt)], role: "user")]
        let config = GeminiGenerationConfig(temperature: temperature, maxOutputTokens: maxTokens)
        let systemInstruction = systemPrompt.map { GeminiContent(parts: [GeminiPart(text: $0)]) }

        let requestBody = GeminiRequest(contents: contents, generationConfig: config, systemInstruction: systemInstruction)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            let body = String(data: data, encoding: .utf8) ?? ""
            throw GeminiError.networkError("Status \(statusCode): \(body)")
        }

        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)

        guard let text = geminiResponse.candidates?.first?.content?.parts.first?.text else {
            throw GeminiError.noContent
        }

        return text
    }

    func generateJSON<T: Decodable & Sendable>(prompt: String, systemPrompt: String? = nil, type: T.Type) async throws -> T {
        guard !apiKey.isEmpty else { throw GeminiError.missingAPIKey }

        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else { throw GeminiError.invalidURL }

        let contents = [GeminiContent(parts: [GeminiPart(text: prompt)], role: "user")]
        let config = GeminiGenerationConfig(temperature: 0.4, maxOutputTokens: 4096, responseMimeType: "application/json")
        let systemInstruction = systemPrompt.map { GeminiContent(parts: [GeminiPart(text: $0)]) }

        let requestBody = GeminiRequest(contents: contents, generationConfig: config, systemInstruction: systemInstruction)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            let body = String(data: data, encoding: .utf8) ?? ""
            throw GeminiError.networkError("Status \(statusCode): \(body)")
        }

        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)

        guard let jsonText = geminiResponse.candidates?.first?.content?.parts.first?.text else {
            throw GeminiError.noContent
        }

        guard let jsonData = jsonText.data(using: String.Encoding.utf8) else {
            throw GeminiError.decodingError("Could not convert response to data")
        }

        return try JSONDecoder().decode(T.self, from: jsonData)
    }
}
