import Foundation

nonisolated struct GroqMessage: Codable, Sendable {
    let role: String
    let content: String
}

nonisolated struct GroqResponseFormat: Codable, Sendable {
    let type: String
}

nonisolated struct GroqRequest: Codable, Sendable {
    let model: String
    let messages: [GroqMessage]
    let temperature: Double?
    let maxTokens: Int?
    let responseFormat: GroqResponseFormat?

    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
        case responseFormat = "response_format"
    }
}

nonisolated struct GroqChoice: Codable, Sendable {
    let message: GroqMessage
}

nonisolated struct GroqResponse: Codable, Sendable {
    let choices: [GroqChoice]
}

nonisolated enum GroqModel {
    static let candidates: [String] = [
        "llama-3.3-70b-versatile",
        "llama-3.1-8b-instant"
    ]
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

    private func performRequest(messages: [GroqMessage], temperature: Double, maxTokens: Int, jsonMode: Bool) async throws -> String {
        guard !apiKey.isEmpty else { throw GeminiError.missingAPIKey }

        var lastError: GeminiError = .noContent
        for model in GroqModel.candidates {
            let body = GroqRequest(
                model: model,
                messages: messages,
                temperature: temperature,
                maxTokens: maxTokens,
                responseFormat: jsonMode ? GroqResponseFormat(type: "json_object") : nil
            )
            let encoded: Data
            do { encoded = try JSONEncoder().encode(body) } catch {
                throw GeminiError.decodingError(error.localizedDescription)
            }

            guard let url = URL(string: "https://api.groq.com/openai/v1/chat/completions") else {
                throw GeminiError.invalidURL
            }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.httpBody = encoded
            request.timeoutInterval = 30

            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse else {
                    lastError = .networkError("Invalid response")
                    continue
                }
                if (200...299).contains(httpResponse.statusCode) {
                    let decoded = try JSONDecoder().decode(GroqResponse.self, from: data)
                    guard let text = decoded.choices.first?.message.content, !text.isEmpty else {
                        throw GeminiError.noContent
                    }
                    return text
                }
                let bodyText = String(data: data, encoding: .utf8) ?? ""
                let shortMessage = Self.extractErrorMessage(from: bodyText) ?? bodyText
                lastError = .httpError(status: httpResponse.statusCode, message: shortMessage)
                if httpResponse.statusCode == 400 || httpResponse.statusCode == 404 {
                    continue
                }
                throw lastError
            } catch let error as GeminiError {
                throw error
            } catch {
                lastError = .networkError(error.localizedDescription)
                continue
            }
        }
        throw lastError
    }

    private static func extractErrorMessage(from body: String) -> String? {
        guard let data = body.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let err = obj["error"] as? [String: Any],
              let msg = err["message"] as? String else { return nil }
        return msg
    }

    func generateText(prompt: String, systemPrompt: String? = nil, temperature: Double = 0.7, maxTokens: Int = 1024) async throws -> String {
        var messages: [GroqMessage] = []
        if let systemPrompt { messages.append(GroqMessage(role: "system", content: systemPrompt)) }
        messages.append(GroqMessage(role: "user", content: prompt))
        return try await performRequest(messages: messages, temperature: temperature, maxTokens: maxTokens, jsonMode: false)
    }

    func generateJSON<T: Decodable & Sendable>(prompt: String, systemPrompt: String? = nil, type: T.Type) async throws -> T {
        var messages: [GroqMessage] = []
        if let systemPrompt {
            messages.append(GroqMessage(role: "system", content: systemPrompt + "\n\nReturn ONLY valid JSON matching the requested schema."))
        } else {
            messages.append(GroqMessage(role: "system", content: "Return ONLY valid JSON matching the requested schema."))
        }
        messages.append(GroqMessage(role: "user", content: prompt))

        let jsonText = try await performRequest(messages: messages, temperature: 0.3, maxTokens: 2048, jsonMode: true)

        do {
            return try GeminiJSONParser.decode(T.self, from: jsonText)
        } catch {
            throw GeminiError.decodingError("Could not parse AI response")
        }
    }
}
