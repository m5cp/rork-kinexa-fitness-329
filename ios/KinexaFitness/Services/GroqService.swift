import Foundation

nonisolated struct GroqChatMessage: Codable, Sendable {
    let role: String
    let content: String
}

nonisolated struct GroqChatRequest: Codable, Sendable {
    let model: String
    let messages: [GroqChatMessage]
    let temperature: Double
    let max_tokens: Int
    let response_format: GroqResponseFormat?

    init(model: String = "llama-3.3-70b-versatile", messages: [GroqChatMessage], temperature: Double = 0.7, maxTokens: Int = 4096, jsonMode: Bool = false) {
        self.model = model
        self.messages = messages
        self.temperature = temperature
        self.max_tokens = maxTokens
        self.response_format = jsonMode ? GroqResponseFormat(type: "json_object") : nil
    }
}

nonisolated struct GroqResponseFormat: Codable, Sendable {
    let type: String
}

nonisolated struct GroqChatResponse: Codable, Sendable {
    let choices: [GroqChoice]?
}

nonisolated struct GroqChoice: Codable, Sendable {
    let message: GroqChatMessage?
}

nonisolated enum GroqError: Error, Sendable {
    case missingAPIKey
    case invalidURL
    case networkError(String)
    case decodingError(String)
    case noContent
}

@Observable
final class GroqService {
    var isLoading: Bool = false

    private var apiKey: String {
        Config.EXPO_PUBLIC_GROQ_API_KEY
    }

    var isConfigured: Bool {
        !apiKey.isEmpty
    }

    func generateJSON<T: Decodable & Sendable>(prompt: String, systemPrompt: String? = nil, temperature: Double = 0.7, maxTokens: Int = 4096, type: T.Type) async throws -> T {
        guard !apiKey.isEmpty else { throw GroqError.missingAPIKey }

        guard let url = URL(string: "https://api.groq.com/openai/v1/chat/completions") else {
            throw GroqError.invalidURL
        }

        var messages: [GroqChatMessage] = []
        if let sys = systemPrompt {
            messages.append(GroqChatMessage(role: "system", content: sys))
        }
        messages.append(GroqChatMessage(role: "user", content: prompt))

        let requestBody = GroqChatRequest(
            messages: messages,
            temperature: temperature,
            maxTokens: maxTokens,
            jsonMode: true
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            let body = String(data: data, encoding: .utf8) ?? ""
            throw GroqError.networkError("Status \(statusCode): \(body)")
        }

        let groqResponse = try JSONDecoder().decode(GroqChatResponse.self, from: data)

        guard let text = groqResponse.choices?.first?.message?.content else {
            throw GroqError.noContent
        }

        guard let jsonData = text.data(using: .utf8) else {
            throw GroqError.decodingError("Could not convert response to data")
        }

        return try JSONDecoder().decode(T.self, from: jsonData)
    }

    func generateText(prompt: String, systemPrompt: String? = nil, temperature: Double = 0.7, maxTokens: Int = 2048) async throws -> String {
        guard !apiKey.isEmpty else { throw GroqError.missingAPIKey }

        guard let url = URL(string: "https://api.groq.com/openai/v1/chat/completions") else {
            throw GroqError.invalidURL
        }

        var messages: [GroqChatMessage] = []
        if let sys = systemPrompt {
            messages.append(GroqChatMessage(role: "system", content: sys))
        }
        messages.append(GroqChatMessage(role: "user", content: prompt))

        let requestBody = GroqChatRequest(
            messages: messages,
            temperature: temperature,
            maxTokens: maxTokens,
            jsonMode: false
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            let body = String(data: data, encoding: .utf8) ?? ""
            throw GroqError.networkError("Status \(statusCode): \(body)")
        }

        let groqResponse = try JSONDecoder().decode(GroqChatResponse.self, from: data)

        guard let text = groqResponse.choices?.first?.message?.content else {
            throw GroqError.noContent
        }

        return text
    }
}
