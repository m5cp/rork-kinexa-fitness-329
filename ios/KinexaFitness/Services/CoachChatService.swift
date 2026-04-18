import Foundation
import Observation

nonisolated struct CoachMessage: Identifiable, Sendable, Equatable {
    let id: UUID
    let role: Role
    var text: String
    let timestamp: Date

    enum Role: String, Sendable { case user, assistant }

    init(id: UUID = UUID(), role: Role, text: String, timestamp: Date = .now) {
        self.id = id
        self.role = role
        self.text = text
        self.timestamp = timestamp
    }
}

@Observable
final class CoachChatService {
    static let shared = CoachChatService()

    static let freeDailyLimit: Int = 5
    static let premiumDailyLimit: Int = 50

    private let usageKey = "coach_chat_usage_v1"
    private let messagesKey = "coach_chat_messages_v1"

    private(set) var messages: [CoachMessage] = []
    private(set) var dailyUsageCount: Int = 0
    private var usageDate: String = ""

    var isSending: Bool = false
    var isPremium: Bool = false
    var lastError: String?

    private let gemini = GeminiService()

    var dailyLimit: Int {
        isPremium ? Self.premiumDailyLimit : Self.freeDailyLimit
    }

    var remainingToday: Int {
        refreshIfNewDay()
        return max(0, dailyLimit - dailyUsageCount)
    }

    var hasReachedLimit: Bool {
        refreshIfNewDay()
        return dailyUsageCount >= dailyLimit
    }

    private init() {
        loadUsage()
        loadMessages()
        if messages.isEmpty {
            messages = [welcomeMessage()]
        }
    }

    func sendMessage(_ text: String) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        refreshIfNewDay()
        if hasReachedLimit {
            lastError = "Daily limit reached"
            return
        }

        let userMsg = CoachMessage(role: .user, text: trimmed)
        messages.append(userMsg)
        saveMessages()

        isSending = true
        lastError = nil

        let history = buildHistory()
        let systemPrompt = Self.systemPrompt

        do {
            let reply = try await gemini.generateText(
                prompt: history,
                systemPrompt: systemPrompt,
                temperature: 0.7,
                maxTokens: 1024
            )
            let clean = reply.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !clean.isEmpty else {
                throw CoachChatError.emptyReply
            }
            messages.append(CoachMessage(role: .assistant, text: clean))
            saveMessages()
            dailyUsageCount += 1
            saveUsage()
        } catch {
            let fallback = "That one didn't go through — it's on us, not your daily limit. Try again in a moment."
            messages.append(CoachMessage(role: .assistant, text: fallback))
            saveMessages()
            lastError = error.localizedDescription
        }

        isSending = false
    }

    func clearConversation() {
        messages = [welcomeMessage()]
        saveMessages()
    }

    private func buildHistory() -> String {
        let recent = messages.suffix(12)
        var lines: [String] = []
        for m in recent {
            let prefix = m.role == .user ? "User" : "Coach"
            lines.append("\(prefix): \(m.text)")
        }
        lines.append("Coach:")
        return lines.joined(separator: "\n\n")
    }

    private func welcomeMessage() -> CoachMessage {
        CoachMessage(
            role: .assistant,
            text: "Hey — I'm your Kinexa coach. Ask me anything about workouts, form, routines, or how to use the app. What's on your mind today?"
        )
    }

    private static let systemPrompt: String = """
    You are the Kinexa Coach, a calm, motivating, knowledgeable fitness assistant inside the Kinexa Fitness iOS app.

    Your job:
    - Help with exercises: suggest combinations, explain proper form, recommend alternatives based on available equipment.
    - Recommend routines for goals like strength, cardio, mobility, functional fitness, or fat loss.
    - Answer questions about how to use the Kinexa app. The app has tabs: Home, Workouts, Nutrition, Progress, Profile. Users can build manual routines, use pre-made routines, generate AI workouts, log meals, scan food, and track progress rings.
    - Be encouraging but never pushy or aggressive. Keep tone warm, calm, and grounded.

    Rules:
    - Keep responses concise (usually under 180 words). Use short paragraphs or a compact bulleted list when listing exercises.
    - Never give medical advice. If the user describes pain or injury, gently suggest consulting a medical professional.
    - Don't recommend specific supplements or medications.
    - Don't make up app features. If unsure about an app feature, say so honestly and point toward the relevant tab.
    - Use plain text. No markdown headers or emoji unless it genuinely adds warmth (sparingly).
    """

    // MARK: - Persistence

    private func refreshIfNewDay() {
        let today = Self.todayString()
        if usageDate != today {
            usageDate = today
            dailyUsageCount = 0
            saveUsage()
        }
    }

    private static func todayString() -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = .current
        return f.string(from: .now)
    }

    private func saveUsage() {
        let data: [String: Any] = ["date": usageDate, "count": dailyUsageCount]
        UserDefaults.standard.set(data, forKey: usageKey)
    }

    private func loadUsage() {
        guard let data = UserDefaults.standard.dictionary(forKey: usageKey),
              let date = data["date"] as? String,
              let count = data["count"] as? Int else {
            usageDate = Self.todayString()
            dailyUsageCount = 0
            return
        }
        usageDate = date
        dailyUsageCount = max(0, count)
        refreshIfNewDay()
    }

    private func saveMessages() {
        let encodable = messages.map { StoredMessage(id: $0.id, role: $0.role.rawValue, text: $0.text, timestamp: $0.timestamp) }
        if let data = try? JSONEncoder().encode(encodable) {
            UserDefaults.standard.set(data, forKey: messagesKey)
        }
    }

    private func loadMessages() {
        guard let data = UserDefaults.standard.data(forKey: messagesKey),
              let stored = try? JSONDecoder().decode([StoredMessage].self, from: data) else {
            return
        }
        messages = stored.compactMap { s in
            guard let role = CoachMessage.Role(rawValue: s.role) else { return nil }
            return CoachMessage(id: s.id, role: role, text: s.text, timestamp: s.timestamp)
        }
    }
}

nonisolated enum CoachChatError: Error, Sendable {
    case emptyReply
}

nonisolated private struct StoredMessage: Codable, Sendable {
    let id: UUID
    let role: String
    let text: String
    let timestamp: Date
}
