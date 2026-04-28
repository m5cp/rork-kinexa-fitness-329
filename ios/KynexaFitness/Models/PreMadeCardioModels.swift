import Foundation

nonisolated enum CardioProgramType: String, Codable, CaseIterable, Identifiable, Sendable {
    case treadmill = "Treadmill"
    case machine = "Machine"
    case running = "Running"
    case sprinting = "Sprinting"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .treadmill: return "figure.run.treadmill"
        case .machine: return "figure.elliptical"
        case .running: return "figure.run"
        case .sprinting: return "figure.run"
        }
    }

    var gradientHex: (String, String) {
        switch self {
        case .treadmill: return ("#2563EB", "#1D4ED8")
        case .machine: return ("#0EA5E9", "#0284C7")
        case .running: return ("#EC4899", "#BE185D")
        case .sprinting: return ("#EF4444", "#DC2626")
        }
    }
}

nonisolated enum CardioProgramLevel: String, Codable, CaseIterable, Identifiable, Sendable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case allLevels = "All Levels"

    var id: String { rawValue }
}

nonisolated enum CardioProgramGoal: String, Codable, CaseIterable, Identifiable, Sendable {
    case fatLoss = "Fat Loss"
    case endurance = "Endurance"
    case conditioning = "Conditioning"
    case speed = "Speed & Power"
    case generalFitness = "General Fitness"

    var id: String { rawValue }
}

nonisolated struct CardioSessionStep: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let name: String
    let duration: String
    let intensity: String
    let notes: String

    init(name: String, duration: String, intensity: String = "", notes: String = "") {
        self.id = UUID()
        self.name = name
        self.duration = duration
        self.intensity = intensity
        self.notes = notes
    }
}

nonisolated struct CardioProgramDay: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let dayName: String
    let focus: String
    let steps: [CardioSessionStep]

    init(dayName: String, focus: String, steps: [CardioSessionStep]) {
        self.id = UUID()
        self.dayName = dayName
        self.focus = focus
        self.steps = steps
    }
}

nonisolated struct PreMadeCardioProgram: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let name: String
    let programDescription: String
    let programType: CardioProgramType
    let level: CardioProgramLevel
    let goal: CardioProgramGoal
    let daysPerWeek: Int
    let durationWeeks: Int
    let equipment: String
    let days: [CardioProgramDay]

    init(
        name: String,
        programDescription: String,
        programType: CardioProgramType,
        level: CardioProgramLevel,
        goal: CardioProgramGoal,
        daysPerWeek: Int,
        durationWeeks: Int,
        equipment: String = "None",
        days: [CardioProgramDay]
    ) {
        self.id = UUID()
        self.name = name
        self.programDescription = programDescription
        self.programType = programType
        self.level = level
        self.goal = goal
        self.daysPerWeek = daysPerWeek
        self.durationWeeks = durationWeeks
        self.equipment = equipment
        self.days = days
    }
}
