import Foundation

nonisolated struct ManualRoutineExercise: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    var name: String
    var category: String
    var sets: Int
    var reps: String
    var notes: String
    var sourceType: ManualExerciseSource

    init(
        name: String,
        category: String = "",
        sets: Int = 3,
        reps: String = "10",
        notes: String = "",
        sourceType: ManualExerciseSource = .weightTraining
    ) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.sets = sets
        self.reps = reps
        self.notes = notes
        self.sourceType = sourceType
    }
}

nonisolated enum ManualExerciseSource: String, Codable, Sendable {
    case weightTraining = "Weight Training"
    case cardio = "Cardio"
    case functionalFitness = "Functional Fitness"
}

nonisolated struct ManualRoutineDay: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    var dayName: String
    var exercises: [ManualRoutineExercise]

    init(dayName: String, exercises: [ManualRoutineExercise] = []) {
        self.id = UUID()
        self.dayName = dayName
        self.exercises = exercises
    }
}

nonisolated struct ManualRoutine: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    var name: String
    var days: [ManualRoutineDay]
    var createdDate: Date

    init(name: String = "My Routine", days: [ManualRoutineDay] = [], createdDate: Date = .now) {
        self.id = UUID()
        self.name = name
        self.days = days
        self.createdDate = createdDate
    }
}

nonisolated enum WeightBodyPart: String, CaseIterable, Identifiable, Sendable {
    case chest = "Chest"
    case back = "Back"
    case shoulders = "Shoulders"
    case biceps = "Biceps"
    case triceps = "Triceps"
    case legs = "Legs"
    case glutes = "Glutes"
    case core = "Core"
    case fullBody = "Full Body"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .chest: return "figure.strengthtraining.traditional"
        case .back: return "figure.strengthtraining.traditional"
        case .shoulders: return "figure.arms.open"
        case .biceps: return "dumbbell.fill"
        case .triceps: return "figure.strengthtraining.functional"
        case .legs: return "figure.walk"
        case .glutes: return "figure.step.training"
        case .core: return "figure.core.training"
        case .fullBody: return "figure.mixed.cardio"
        }
    }
}

nonisolated struct WeightExerciseDefinition: Identifiable, Hashable, Sendable {
    let id: UUID
    let name: String
    let bodyPart: WeightBodyPart
    let equipment: String
    let defaultSets: Int
    let defaultReps: String

    init(name: String, bodyPart: WeightBodyPart, equipment: String = "Barbell", defaultSets: Int = 3, defaultReps: String = "10") {
        self.id = UUID()
        self.name = name
        self.bodyPart = bodyPart
        self.equipment = equipment
        self.defaultSets = defaultSets
        self.defaultReps = defaultReps
    }
}

enum WeightExerciseLibrary {
    static let allExercises: [WeightExerciseDefinition] = [
        WeightExerciseDefinition(name: "Barbell Bench Press", bodyPart: .chest, equipment: "Barbell", defaultSets: 4, defaultReps: "8"),
        WeightExerciseDefinition(name: "Incline Dumbbell Press", bodyPart: .chest, equipment: "Dumbbell", defaultSets: 3, defaultReps: "10"),
        WeightExerciseDefinition(name: "Dumbbell Fly", bodyPart: .chest, equipment: "Dumbbell", defaultSets: 3, defaultReps: "12"),
        WeightExerciseDefinition(name: "Cable Fly", bodyPart: .chest, equipment: "Cable", defaultSets: 3, defaultReps: "15"),
        WeightExerciseDefinition(name: "Push-Up", bodyPart: .chest, equipment: "Bodyweight", defaultSets: 3, defaultReps: "15"),
        WeightExerciseDefinition(name: "Incline Barbell Press", bodyPart: .chest, equipment: "Barbell", defaultSets: 4, defaultReps: "8"),
        WeightExerciseDefinition(name: "Decline Bench Press", bodyPart: .chest, equipment: "Barbell", defaultSets: 3, defaultReps: "10"),
        WeightExerciseDefinition(name: "Chest Dip", bodyPart: .chest, equipment: "Bodyweight", defaultSets: 3, defaultReps: "12"),
        WeightExerciseDefinition(name: "Cable Crossover", bodyPart: .chest, equipment: "Cable", defaultSets: 3, defaultReps: "12"),
        WeightExerciseDefinition(name: "Dumbbell Bench Press", bodyPart: .chest, equipment: "Dumbbell", defaultSets: 4, defaultReps: "10"),

        WeightExerciseDefinition(name: "Barbell Bent-Over Row", bodyPart: .back, equipment: "Barbell", defaultSets: 4, defaultReps: "8"),
        WeightExerciseDefinition(name: "Pull-Up", bodyPart: .back, equipment: "Bodyweight", defaultSets: 4, defaultReps: "AMRAP"),
        WeightExerciseDefinition(name: "Lat Pulldown", bodyPart: .back, equipment: "Cable", defaultSets: 3, defaultReps: "12"),
        WeightExerciseDefinition(name: "Seated Cable Row", bodyPart: .back, equipment: "Cable", defaultSets: 3, defaultReps: "10"),
        WeightExerciseDefinition(name: "Dumbbell Single-Arm Row", bodyPart: .back, equipment: "Dumbbell", defaultSets: 3, defaultReps: "10"),
        WeightExerciseDefinition(name: "T-Bar Row", bodyPart: .back, equipment: "Barbell", defaultSets: 4, defaultReps: "10"),
        WeightExerciseDefinition(name: "Chin-Up", bodyPart: .back, equipment: "Bodyweight", defaultSets: 3, defaultReps: "8"),
        WeightExerciseDefinition(name: "Straight-Arm Pulldown", bodyPart: .back, equipment: "Cable", defaultSets: 3, defaultReps: "12"),
        WeightExerciseDefinition(name: "Pendlay Row", bodyPart: .back, equipment: "Barbell", defaultSets: 4, defaultReps: "6"),
        WeightExerciseDefinition(name: "Meadows Row", bodyPart: .back, equipment: "Barbell", defaultSets: 3, defaultReps: "10"),

        WeightExerciseDefinition(name: "Overhead Press", bodyPart: .shoulders, equipment: "Barbell", defaultSets: 4, defaultReps: "8"),
        WeightExerciseDefinition(name: "Dumbbell Lateral Raise", bodyPart: .shoulders, equipment: "Dumbbell", defaultSets: 3, defaultReps: "15"),
        WeightExerciseDefinition(name: "Arnold Press", bodyPart: .shoulders, equipment: "Dumbbell", defaultSets: 3, defaultReps: "10"),
        WeightExerciseDefinition(name: "Face Pull", bodyPart: .shoulders, equipment: "Cable", defaultSets: 3, defaultReps: "15"),
        WeightExerciseDefinition(name: "Rear Delt Fly", bodyPart: .shoulders, equipment: "Dumbbell", defaultSets: 3, defaultReps: "15"),
        WeightExerciseDefinition(name: "Seated Dumbbell Press", bodyPart: .shoulders, equipment: "Dumbbell", defaultSets: 4, defaultReps: "10"),
        WeightExerciseDefinition(name: "Push Press", bodyPart: .shoulders, equipment: "Barbell", defaultSets: 3, defaultReps: "8"),
        WeightExerciseDefinition(name: "Front Raise", bodyPart: .shoulders, equipment: "Dumbbell", defaultSets: 3, defaultReps: "12"),
        WeightExerciseDefinition(name: "Cable Lateral Raise", bodyPart: .shoulders, equipment: "Cable", defaultSets: 3, defaultReps: "15"),
        WeightExerciseDefinition(name: "Upright Row", bodyPart: .shoulders, equipment: "Barbell", defaultSets: 3, defaultReps: "10"),

        WeightExerciseDefinition(name: "Barbell Curl", bodyPart: .biceps, equipment: "Barbell", defaultSets: 3, defaultReps: "10"),
        WeightExerciseDefinition(name: "Hammer Curl", bodyPart: .biceps, equipment: "Dumbbell", defaultSets: 3, defaultReps: "12"),
        WeightExerciseDefinition(name: "EZ Bar Curl", bodyPart: .biceps, equipment: "EZ Bar", defaultSets: 3, defaultReps: "10"),
        WeightExerciseDefinition(name: "Incline Dumbbell Curl", bodyPart: .biceps, equipment: "Dumbbell", defaultSets: 3, defaultReps: "12"),
        WeightExerciseDefinition(name: "Preacher Curl", bodyPart: .biceps, equipment: "EZ Bar", defaultSets: 3, defaultReps: "12"),
        WeightExerciseDefinition(name: "Concentration Curl", bodyPart: .biceps, equipment: "Dumbbell", defaultSets: 3, defaultReps: "10"),
        WeightExerciseDefinition(name: "Cable Curl", bodyPart: .biceps, equipment: "Cable", defaultSets: 3, defaultReps: "12"),
        WeightExerciseDefinition(name: "Reverse Curl", bodyPart: .biceps, equipment: "Barbell", defaultSets: 3, defaultReps: "12"),

        WeightExerciseDefinition(name: "Tricep Dip", bodyPart: .triceps, equipment: "Bodyweight", defaultSets: 3, defaultReps: "12"),
        WeightExerciseDefinition(name: "Skull Crusher", bodyPart: .triceps, equipment: "EZ Bar", defaultSets: 3, defaultReps: "10"),
        WeightExerciseDefinition(name: "Tricep Pushdown", bodyPart: .triceps, equipment: "Cable", defaultSets: 3, defaultReps: "12"),
        WeightExerciseDefinition(name: "Overhead Tricep Extension", bodyPart: .triceps, equipment: "Dumbbell", defaultSets: 3, defaultReps: "12"),
        WeightExerciseDefinition(name: "Close-Grip Bench Press", bodyPart: .triceps, equipment: "Barbell", defaultSets: 3, defaultReps: "10"),
        WeightExerciseDefinition(name: "Diamond Push-Up", bodyPart: .triceps, equipment: "Bodyweight", defaultSets: 3, defaultReps: "AMRAP"),
        WeightExerciseDefinition(name: "Rope Pushdown", bodyPart: .triceps, equipment: "Cable", defaultSets: 3, defaultReps: "15"),
        WeightExerciseDefinition(name: "Kickback", bodyPart: .triceps, equipment: "Dumbbell", defaultSets: 3, defaultReps: "12"),

        WeightExerciseDefinition(name: "Barbell Back Squat", bodyPart: .legs, equipment: "Barbell", defaultSets: 4, defaultReps: "8"),
        WeightExerciseDefinition(name: "Front Squat", bodyPart: .legs, equipment: "Barbell", defaultSets: 4, defaultReps: "6"),
        WeightExerciseDefinition(name: "Leg Press", bodyPart: .legs, equipment: "Machine", defaultSets: 3, defaultReps: "12"),
        WeightExerciseDefinition(name: "Romanian Deadlift", bodyPart: .legs, equipment: "Barbell", defaultSets: 4, defaultReps: "8"),
        WeightExerciseDefinition(name: "Walking Lunges", bodyPart: .legs, equipment: "Dumbbell", defaultSets: 3, defaultReps: "12/leg"),
        WeightExerciseDefinition(name: "Leg Extension", bodyPart: .legs, equipment: "Machine", defaultSets: 3, defaultReps: "15"),
        WeightExerciseDefinition(name: "Leg Curl", bodyPart: .legs, equipment: "Machine", defaultSets: 3, defaultReps: "12"),
        WeightExerciseDefinition(name: "Bulgarian Split Squat", bodyPart: .legs, equipment: "Dumbbell", defaultSets: 3, defaultReps: "10/leg"),
        WeightExerciseDefinition(name: "Calf Raise", bodyPart: .legs, equipment: "Machine", defaultSets: 4, defaultReps: "15"),
        WeightExerciseDefinition(name: "Goblet Squat", bodyPart: .legs, equipment: "Dumbbell", defaultSets: 3, defaultReps: "12"),
        WeightExerciseDefinition(name: "Barbell Deadlift", bodyPart: .legs, equipment: "Barbell", defaultSets: 5, defaultReps: "5"),
        WeightExerciseDefinition(name: "Trap Bar Deadlift", bodyPart: .legs, equipment: "Barbell", defaultSets: 4, defaultReps: "6"),

        WeightExerciseDefinition(name: "Hip Thrust", bodyPart: .glutes, equipment: "Barbell", defaultSets: 4, defaultReps: "10"),
        WeightExerciseDefinition(name: "Glute Bridge", bodyPart: .glutes, equipment: "Bodyweight", defaultSets: 3, defaultReps: "15"),
        WeightExerciseDefinition(name: "Cable Kickback", bodyPart: .glutes, equipment: "Cable", defaultSets: 3, defaultReps: "12"),
        WeightExerciseDefinition(name: "Step-Up", bodyPart: .glutes, equipment: "Dumbbell", defaultSets: 3, defaultReps: "10/leg"),
        WeightExerciseDefinition(name: "Sumo Deadlift", bodyPart: .glutes, equipment: "Barbell", defaultSets: 4, defaultReps: "8"),

        WeightExerciseDefinition(name: "Plank", bodyPart: .core, equipment: "Bodyweight", defaultSets: 3, defaultReps: "45 sec"),
        WeightExerciseDefinition(name: "Hanging Leg Raise", bodyPart: .core, equipment: "Bodyweight", defaultSets: 3, defaultReps: "12"),
        WeightExerciseDefinition(name: "Cable Crunch", bodyPart: .core, equipment: "Cable", defaultSets: 3, defaultReps: "15"),
        WeightExerciseDefinition(name: "Russian Twist", bodyPart: .core, equipment: "Dumbbell", defaultSets: 3, defaultReps: "20"),
        WeightExerciseDefinition(name: "Ab Wheel Rollout", bodyPart: .core, equipment: "Ab Wheel", defaultSets: 3, defaultReps: "10"),
        WeightExerciseDefinition(name: "Dead Bug", bodyPart: .core, equipment: "Bodyweight", defaultSets: 3, defaultReps: "12/side"),
        WeightExerciseDefinition(name: "Hollow Hold", bodyPart: .core, equipment: "Bodyweight", defaultSets: 3, defaultReps: "30 sec"),

        WeightExerciseDefinition(name: "Power Clean", bodyPart: .fullBody, equipment: "Barbell", defaultSets: 5, defaultReps: "3"),
        WeightExerciseDefinition(name: "Thruster", bodyPart: .fullBody, equipment: "Barbell", defaultSets: 4, defaultReps: "8"),
        WeightExerciseDefinition(name: "Kettlebell Swing", bodyPart: .fullBody, equipment: "Kettlebell", defaultSets: 4, defaultReps: "15"),
        WeightExerciseDefinition(name: "Farmer's Walk", bodyPart: .fullBody, equipment: "Dumbbell", defaultSets: 3, defaultReps: "40m"),
        WeightExerciseDefinition(name: "Turkish Get-Up", bodyPart: .fullBody, equipment: "Kettlebell", defaultSets: 3, defaultReps: "3/side"),
        WeightExerciseDefinition(name: "Burpee", bodyPart: .fullBody, equipment: "Bodyweight", defaultSets: 3, defaultReps: "10"),
        WeightExerciseDefinition(name: "Man Maker", bodyPart: .fullBody, equipment: "Dumbbell", defaultSets: 3, defaultReps: "8"),
    ]

    static func exercises(for bodyPart: WeightBodyPart) -> [WeightExerciseDefinition] {
        allExercises.filter { $0.bodyPart == bodyPart }
    }
}
