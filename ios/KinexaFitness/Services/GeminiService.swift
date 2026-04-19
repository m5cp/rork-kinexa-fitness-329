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
    let inlineData: GeminiInlineData?

    init(text: String) {
        self.text = text
        self.inlineData = nil
    }

    init(mimeType: String, data: String) {
        self.text = nil
        self.inlineData = GeminiInlineData(mimeType: mimeType, data: data)
    }

    enum CodingKeys: String, CodingKey {
        case text
        case inlineData = "inline_data"
    }
}

nonisolated struct GeminiInlineData: Codable, Sendable {
    let mimeType: String
    let data: String

    enum CodingKeys: String, CodingKey {
        case mimeType = "mime_type"
        case data
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
    case emptyResult
}

nonisolated enum GeminiJSONParser {
    static func decode<T: Decodable>(_ type: T.Type, from text: String) throws -> T {
        let decoder = JSONDecoder()

        if let data = text.data(using: .utf8),
           let result = try? decoder.decode(T.self, from: data) {
            return result
        }

        let stripped = stripCodeFences(text).trimmingCharacters(in: .whitespacesAndNewlines)
        if let data = stripped.data(using: .utf8),
           let result = try? decoder.decode(T.self, from: data) {
            return result
        }

        if let extracted = extractFirstJSONObject(from: stripped),
           let data = extracted.data(using: .utf8),
           let result = try? decoder.decode(T.self, from: data) {
            return result
        }

        // Last try — throw the real decoder error for diagnostics
        let data = (stripped.data(using: .utf8)) ?? Data()
        return try decoder.decode(T.self, from: data)
    }

    private static func stripCodeFences(_ text: String) -> String {
        var s = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("```") {
            if let firstNewline = s.firstIndex(of: "\n") {
                s = String(s[s.index(after: firstNewline)...])
            } else {
                s = String(s.dropFirst(3))
            }
        }
        if s.hasSuffix("```") {
            s = String(s.dropLast(3))
        }
        return s.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func extractFirstJSONObject(from text: String) -> String? {
        guard let start = text.firstIndex(where: { $0 == "{" || $0 == "[" }) else { return nil }
        let openChar = text[start]
        let closeChar: Character = openChar == "{" ? "}" : "]"

        var depth = 0
        var inString = false
        var escape = false
        var i = start
        while i < text.endIndex {
            let c = text[i]
            if escape {
                escape = false
            } else if c == "\\" && inString {
                escape = true
            } else if c == "\"" {
                inString.toggle()
            } else if !inString {
                if c == openChar {
                    depth += 1
                } else if c == closeChar {
                    depth -= 1
                    if depth == 0 {
                        return String(text[start...i])
                    }
                }
            }
            i = text.index(after: i)
        }
        return nil
    }
}

nonisolated enum ImageMIMEDetector {
    static func detect(_ data: Data) -> String {
        guard data.count >= 12 else { return "image/jpeg" }
        let bytes = [UInt8](data.prefix(12))

        // PNG: 89 50 4E 47 0D 0A 1A 0A
        if bytes[0] == 0x89, bytes[1] == 0x50, bytes[2] == 0x4E, bytes[3] == 0x47 {
            return "image/png"
        }
        // JPEG: FF D8 FF
        if bytes[0] == 0xFF, bytes[1] == 0xD8, bytes[2] == 0xFF {
            return "image/jpeg"
        }
        // GIF
        if bytes[0] == 0x47, bytes[1] == 0x49, bytes[2] == 0x46 {
            return "image/gif"
        }
        // WebP: RIFF....WEBP
        if bytes[0] == 0x52, bytes[1] == 0x49, bytes[2] == 0x46, bytes[3] == 0x46,
           bytes[8] == 0x57, bytes[9] == 0x45, bytes[10] == 0x42, bytes[11] == 0x50 {
            return "image/webp"
        }
        // HEIC/HEIF: bytes 4..7 = "ftyp", bytes 8..11 brand
        if bytes[4] == 0x66, bytes[5] == 0x74, bytes[6] == 0x79, bytes[7] == 0x70 {
            let brand = String(bytes: bytes[8..<12], encoding: .ascii) ?? ""
            if brand.hasPrefix("heic") || brand.hasPrefix("heix") || brand.hasPrefix("hevc") ||
               brand.hasPrefix("mif1") || brand.hasPrefix("msf1") || brand.hasPrefix("heim") || brand.hasPrefix("heis") {
                return "image/heic"
            }
        }
        return "image/jpeg"
    }
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

    func generateJSONWithImage<T: Decodable & Sendable>(prompt: String, imageData: Data, mimeType: String? = nil, systemPrompt: String? = nil, type: T.Type) async throws -> T {
        guard !apiKey.isEmpty else { throw GeminiError.missingAPIKey }

        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else { throw GeminiError.invalidURL }

        let detectedMime = mimeType ?? ImageMIMEDetector.detect(imageData)
        let base64Image = imageData.base64EncodedString()
        let contents = [GeminiContent(parts: [
            GeminiPart(mimeType: detectedMime, data: base64Image),
            GeminiPart(text: prompt)
        ], role: "user")]
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

        let jsonText = (geminiResponse.candidates?.first?.content?.parts ?? [])
            .compactMap { $0.text }
            .joined()

        guard !jsonText.isEmpty else {
            throw GeminiError.noContent
        }

        do {
            return try GeminiJSONParser.decode(T.self, from: jsonText)
        } catch {
            throw GeminiError.decodingError("Could not parse AI response")
        }
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

        let jsonText = (geminiResponse.candidates?.first?.content?.parts ?? [])
            .compactMap { $0.text }
            .joined()

        guard !jsonText.isEmpty else {
            throw GeminiError.noContent
        }

        do {
            return try GeminiJSONParser.decode(T.self, from: jsonText)
        } catch {
            throw GeminiError.decodingError("Could not parse AI response")
        }
    }
}
