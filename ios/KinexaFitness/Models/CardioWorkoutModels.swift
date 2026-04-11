import Foundation

nonisolated enum CardioCategory: String, CaseIterable, Identifiable, Codable, Sendable {
    case running = "Running"
    case cycling = "Cycling"
    case classWorkouts = "Class Workouts"
    case lowImpact = "Low Impact"
    case hiit = "HIIT & Intervals"
    case outdoor = "Outdoor"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .running: return "figure.run"
        case .cycling: return "figure.indoor.cycle"
        case .classWorkouts: return "figure.dance"
        case .lowImpact: return "figure.mind.and.body"
        case .hiit: return "bolt.heart.fill"
        case .outdoor: return "leaf.fill"
        }
    }

    var gradientHex: (String, String) {
        switch self {
        case .running: return ("#2563EB", "#1D4ED8")
        case .cycling: return ("#059669", "#047857")
        case .classWorkouts: return ("#D946EF", "#A855F7")
        case .lowImpact: return ("#0EA5E9", "#0284C7")
        case .hiit: return ("#F59E0B", "#D97706")
        case .outdoor: return ("#16A34A", "#15803D")
        }
    }
}

nonisolated struct CardioWorkoutDefinition: Identifiable, Hashable, Sendable {
    let id: UUID
    let name: String
    let category: CardioCategory
    let icon: String
    let description: String
    let estimatedCaloriesPerMinute: Int
    let difficultyLevel: String
    let isTimeBased: Bool
    let isDistanceBased: Bool
    let usesGPS: Bool

    init(
        name: String,
        category: CardioCategory,
        icon: String,
        description: String,
        estimatedCaloriesPerMinute: Int = 8,
        difficultyLevel: String = "Moderate",
        isTimeBased: Bool = true,
        isDistanceBased: Bool = false,
        usesGPS: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.icon = icon
        self.description = description
        self.estimatedCaloriesPerMinute = estimatedCaloriesPerMinute
        self.difficultyLevel = difficultyLevel
        self.isTimeBased = isTimeBased
        self.isDistanceBased = isDistanceBased
        self.usesGPS = usesGPS
    }
}

nonisolated struct CardioSession: Codable, Identifiable, Sendable {
    let id: UUID
    let workoutName: String
    let category: String
    let date: Date
    let durationMinutes: Int
    let caloriesBurned: Int?
    let distanceMiles: Double?
    let notes: String

    init(
        workoutName: String,
        category: String,
        date: Date = .now,
        durationMinutes: Int,
        caloriesBurned: Int? = nil,
        distanceMiles: Double? = nil,
        notes: String = ""
    ) {
        self.id = UUID()
        self.workoutName = workoutName
        self.category = category
        self.date = date
        self.durationMinutes = durationMinutes
        self.caloriesBurned = caloriesBurned
        self.distanceMiles = distanceMiles
        self.notes = notes
    }
}
