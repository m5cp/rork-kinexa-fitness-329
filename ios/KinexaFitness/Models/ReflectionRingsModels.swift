import Foundation
import SwiftUI

nonisolated enum RingType: String, Codable, CaseIterable, Sendable, Identifiable {
    case fitness
    case meals
    case mood
    case water

    var id: String { rawValue }

    var title: String {
        switch self {
        case .fitness: return "Fitness"
        case .meals: return "Meals"
        case .mood: return "Mood"
        case .water: return "Water"
        }
    }

    var icon: String {
        switch self {
        case .fitness: return "figure.run"
        case .meals: return "fork.knife"
        case .mood: return "face.smiling.fill"
        case .water: return "drop.fill"
        }
    }

    var hex: String {
        switch self {
        case .fitness: return "#FF3B30"
        case .meals: return "#FF9500"
        case .mood: return "#AF52DE"
        case .water: return "#0A84FF"
        }
    }

    var color: Color { Color(hex: hex) }

    var subtitle: String {
        switch self {
        case .fitness: return "Log a workout"
        case .meals: return "Log at least one meal"
        case .mood: return "Check in with yourself"
        case .water: return "Hit your water goal"
        }
    }

    static let pointsPerRing: Int = 25
    static let allRingsBonus: Int = 50
}

nonisolated enum MoodLevel: Int, Codable, CaseIterable, Sendable, Identifiable {
    case rough = 1
    case meh = 2
    case okay = 3
    case good = 4
    case great = 5

    var id: Int { rawValue }

    var emoji: String {
        switch self {
        case .rough: return "😣"
        case .meh: return "😕"
        case .okay: return "😐"
        case .good: return "🙂"
        case .great: return "🤩"
        }
    }

    var label: String {
        switch self {
        case .rough: return "Rough"
        case .meh: return "Meh"
        case .okay: return "Okay"
        case .good: return "Good"
        case .great: return "Great"
        }
    }

    var color: Color {
        switch self {
        case .rough: return Color(hex: "#EF4444")
        case .meh: return Color(hex: "#F97316")
        case .okay: return Color(hex: "#EAB308")
        case .good: return Color(hex: "#22C55E")
        case .great: return Color(hex: "#AF52DE")
        }
    }
}

nonisolated struct MoodEntry: Codable, Identifiable, Sendable {
    let id: UUID
    let date: Date
    let level: MoodLevel
    var note: String

    init(id: UUID = UUID(), date: Date = .now, level: MoodLevel, note: String = "") {
        self.id = id
        self.date = date
        self.level = level
        self.note = note
    }
}

nonisolated struct DailyRingsSnapshot: Codable, Identifiable, Sendable {
    let id: UUID
    let date: Date
    let closedRings: Set<RingType>
    let points: Int

    init(id: UUID = UUID(), date: Date, closedRings: Set<RingType>, points: Int) {
        self.id = id
        self.date = date
        self.closedRings = closedRings
        self.points = points
    }

    var allClosed: Bool { closedRings.count == RingType.allCases.count }
}

nonisolated struct Friend: Codable, Identifiable, Sendable, Hashable {
    let id: UUID
    var username: String
    var shareCode: String
    var points: Int
    var streak: Int
    var avatarEmoji: String

    init(id: UUID = UUID(), username: String, shareCode: String, points: Int, streak: Int, avatarEmoji: String) {
        self.id = id
        self.username = username
        self.shareCode = shareCode
        self.points = points
        self.streak = streak
        self.avatarEmoji = avatarEmoji
    }
}
