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
        case .fitness: return "Move"
        case .meals: return "Nourish"
        case .mood: return "Rest"
        case .water: return "Hydrate"
        }
    }

    var icon: String {
        switch self {
        case .fitness: return "figure.run"
        case .meals: return "fork.knife"
        case .mood: return "moon.fill"
        case .water: return "drop.fill"
        }
    }

    var hex: String {
        switch self {
        case .fitness: return "#FF3B30"
        case .meals: return "#FF9500"
        case .mood: return "#5856D6"
        case .water: return "#0A84FF"
        }
    }

    var color: Color { Color(hex: hex) }

    var subtitle: String {
        switch self {
        case .fitness: return "A little movement today"
        case .meals: return "Fuel yourself well"
        case .mood: return "Log your sleep"
        case .water: return "Stay hydrated"
        }
    }

    static let pointsPerRing: Int = 25
    static let allRingsBonus: Int = 50
}

nonisolated struct SleepEntry: Codable, Identifiable, Sendable {
    let id: UUID
    let date: Date
    var hours: Int

    init(id: UUID = UUID(), date: Date = .now, hours: Int) {
        self.id = id
        self.date = date
        self.hours = hours
    }

    var displayLabel: String {
        hours >= 8 ? "8+ hrs" : "\(hours) hr\(hours == 1 ? "" : "s")"
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
