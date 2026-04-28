import Foundation

nonisolated enum RoutineSplitType: String, Codable, CaseIterable, Identifiable, Sendable {
    case fullBody = "Full Body"
    case upperLower = "Upper/Lower"
    case pushPullLegs = "Push/Pull/Legs"
    case bodyPart = "Body Part Split"
    case upperBody = "Upper Body"
    case lowerBody = "Lower Body"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .fullBody: return "figure.mixed.cardio"
        case .upperLower: return "arrow.up.arrow.down"
        case .pushPullLegs: return "arrow.left.arrow.right"
        case .bodyPart: return "figure.strengthtraining.traditional"
        case .upperBody: return "figure.arms.open"
        case .lowerBody: return "figure.walk"
        }
    }
}

nonisolated enum RoutineLevel: String, Codable, CaseIterable, Identifiable, Sendable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case allLevels = "All Levels"

    var id: String { rawValue }
}

nonisolated enum RoutineGoal: String, Codable, CaseIterable, Identifiable, Sendable {
    case muscleBuilding = "Muscle Building"
    case strength = "Strength"
    case hypertrophy = "Hypertrophy"
    case strengthHypertrophy = "Strength & Hypertrophy"

    var id: String { rawValue }
}

nonisolated struct PreMadeRoutineExercise: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let name: String
    let sets: Int
    let reps: String
    let notes: String

    init(name: String, sets: Int, reps: String, notes: String = "") {
        self.id = UUID()
        self.name = name
        self.sets = sets
        self.reps = reps
        self.notes = notes
    }
}

nonisolated struct PreMadeRoutineDay: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let dayName: String
    let focus: String
    let exercises: [PreMadeRoutineExercise]

    init(dayName: String, focus: String, exercises: [PreMadeRoutineExercise]) {
        self.id = UUID()
        self.dayName = dayName
        self.focus = focus
        self.exercises = exercises
    }
}

nonisolated struct PreMadeRoutine: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let name: String
    let routineDescription: String
    let splitType: RoutineSplitType
    let level: RoutineLevel
    let goal: RoutineGoal
    let daysPerWeek: Int
    let durationWeeks: Int
    let equipment: String
    let days: [PreMadeRoutineDay]

    init(
        name: String,
        routineDescription: String,
        splitType: RoutineSplitType,
        level: RoutineLevel,
        goal: RoutineGoal,
        daysPerWeek: Int,
        durationWeeks: Int,
        equipment: String = "Full Gym",
        days: [PreMadeRoutineDay]
    ) {
        self.id = UUID()
        self.name = name
        self.routineDescription = routineDescription
        self.splitType = splitType
        self.level = level
        self.goal = goal
        self.daysPerWeek = daysPerWeek
        self.durationWeeks = durationWeeks
        self.equipment = equipment
        self.days = days
    }
}
