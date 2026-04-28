import Foundation

enum ArmyGenerator {

    private static func isDrillStyleTemplate(_ template: ArmyWorkoutTemplate) -> Bool {
        let title = template.title.lowercased()
        if title.contains("drill session") || title.contains("conditioning drill") {
            return true
        }
        return false
    }

    private static var cleanTemplates: [ArmyWorkoutTemplate] {
        ArmyTemplateLibrary.templates.filter { !isDrillStyleTemplate($0) }
    }

    static func templates(
        mode: ArmyWorkoutMode,
        focus: ArmyFocus,
        equipment: ArmyEquipment
    ) -> [ArmyWorkoutTemplate] {
        cleanTemplates.filter {
            $0.mode == mode &&
            $0.focus == focus &&
            $0.equipment.contains(equipment)
        }
    }

    static func nextTemplate(
        mode: ArmyWorkoutMode,
        focus: ArmyFocus,
        equipment: ArmyEquipment,
        excluding lastTitle: String?
    ) -> ArmyWorkoutTemplate? {
        let pool = templates(mode: mode, focus: focus, equipment: equipment)
            .filter { $0.title != lastTitle }
        if let result = pool.randomElement() { return result }
        let fallback = cleanTemplates.filter {
            $0.mode == mode && $0.equipment.contains(equipment) && $0.title != lastTitle
        }
        if let result = fallback.randomElement() { return result }
        return cleanTemplates.filter { $0.mode == mode }.randomElement()
    }

    static func weeklyPlan(
        mode: ArmyWorkoutMode,
        focuses: [ArmyFocus],
        equipment: ArmyEquipment,
        days: Int
    ) -> [ArmyWorkoutTemplate] {
        var output: [ArmyWorkoutTemplate] = []
        var lastTitle: String?

        for index in 0..<days {
            let focus = focuses[index % focuses.count]
            if let next = nextTemplate(mode: mode, focus: focus, equipment: equipment, excluding: lastTitle) {
                output.append(next)
                lastTitle = next.title
            }
        }

        return output
    }

    static func mapArmyEquipment(_ option: EquipmentOption) -> ArmyEquipment {
        switch option {
        case .bodyweight: return .bodyweight
        case .minimal: return .minimal
        case .gym: return .gym
        case .running: return .running
        case .field: return .field
        }
    }

    static func mapArmyFocuses(_ focus: TrainingFocus) -> [ArmyFocus] {
        switch focus {
        case .aftPrep:
            return [.lowerStrength, .upperEndurance, .workCapacity, .coreRun, .aftPrep, .endurance]
        case .strength:
            return [.lowerStrength, .upperEndurance, .lowerStrength, .workCapacity, .coreRun]
        case .endurance:
            return [.endurance, .coreRun, .endurance, .recovery, .endurance]
        case .tacticalConditioning:
            return [.tactical, .workCapacity, .tactical, .endurance, .coreRun]
        case .recovery:
            return [.recovery, .coreRun, .recovery, .endurance, .recovery]
        case .generalFitness:
            return [.aftPrep, .endurance, .tactical, .lowerStrength, .upperEndurance, .coreRun]
        }
    }

    static func mapArmyMode(ptMode: PTMode, dutyType: DutyType) -> ArmyWorkoutMode {
        switch ptMode {
        case .unit:
            return .unitPT
        case .individual, .both:
            switch dutyType {
            case .onDuty: return .onDutyIndividual
            case .offDuty: return .offDutyIndividual
            case .both: return .onDutyIndividual
            }
        }
    }

    static func convertToWorkoutExercises(_ template: ArmyWorkoutTemplate) -> [WorkoutExercise] {
        var exercises: [WorkoutExercise] = []

        exercises.append(WorkoutExercise(
            name: "Dynamic Warm-Up",
            sets: 1,
            durationSeconds: 300,
            notes: "Light cardio, joint mobility, and activation movements.",
            category: .timed
        ))

        for armyEx in template.mainEffort {
            if shouldSkipExercise(armyEx) { continue }
            let ex = convertArmyExercise(armyEx)
            exercises.append(ex)
        }

        exercises.append(WorkoutExercise(
            name: "Cool Down & Stretch",
            sets: 1,
            durationSeconds: 240,
            notes: "Light walk and full-body static stretching.",
            category: .timed
        ))

        return exercises
    }

    private static func shouldSkipExercise(_ ex: ArmyExercise) -> Bool {
        let name = ex.name.lowercased()
        if name.contains("drill") { return true }
        if name == "sprint" { return true }
        if name.contains("pmcs") { return true }
        return false
    }

    static func convertArmyExercise(_ armyEx: ArmyExercise) -> WorkoutExercise {
        let sets = armyEx.sets ?? 1
        var reps = 0
        var durationSeconds = 0
        var category: ExerciseCategory = .strength
        var notes = armyEx.notes ?? ""
        var cardioType: CardioType?

        if let repsStr = armyEx.reps {
            let cleaned = repsStr.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
            reps = Int(cleaned) ?? 0
            if reps == 0 {
                notes = notes.isEmpty ? repsStr : "\(repsStr). \(notes)"
                reps = 1
            }
        }

        if let durStr = armyEx.duration {
            let name = armyEx.name.lowercased()
            if name.contains("run") || name.contains("sprint") || name.contains("jog") ||
               name.contains("shuffle") || name.contains("shuttle") {
                category = .cardio
                cardioType = .run
            } else if name.contains("walk") {
                category = .cardio
                cardioType = .walk
            } else {
                category = .timed
            }

            if durStr.contains("sec") {
                let cleaned = durStr.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
                durationSeconds = Int(cleaned) ?? 30
            } else if durStr.contains("min") {
                let cleaned = durStr.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
                durationSeconds = (Int(cleaned) ?? 1) * 60
            } else if durStr.contains("m") && !durStr.contains("min") {
                notes = notes.isEmpty ? durStr : "\(durStr). \(notes)"
                durationSeconds = 30
            } else {
                notes = notes.isEmpty ? durStr : "\(durStr). \(notes)"
                durationSeconds = 30
            }

            reps = 0
        }

        if reps == 0 && durationSeconds == 0 {
            if let durStr = armyEx.duration {
                notes = notes.isEmpty ? durStr : "\(durStr). \(notes)"
            }
            durationSeconds = 30
            category = .timed
        }

        let name = armyEx.name.lowercased()
        if category == .strength {
            if name.contains("push-up") || name.contains("plank") || name.contains("burpee") ||
               name.contains("squat") && !name.contains("goblet") || name.contains("lunge") && !name.contains("walking") ||
               name.contains("body twist") || name.contains("stability") || name.contains("bridge") ||
               name.contains("raise") || name.contains("quadraplex") || name.contains("dead bug") ||
               name.contains("bird dog") || name.contains("flutter") || name.contains("hollow") {
                category = .bodyweight
            }
        }

        return WorkoutExercise(
            name: armyEx.name,
            sets: sets,
            reps: reps,
            durationSeconds: durationSeconds,
            notes: notes,
            category: category,
            cardioType: cardioType
        )
    }

    static func mapWeakEventToFocus(_ eventName: String) -> ArmyFocus {
        switch eventName {
        case "Deadlift", "3RM Deadlift", "MDL":
            return .lowerStrength
        case "Hand-Release Push-Up", "HRP":
            return .upperEndurance
        case "Sprint-Drag-Carry", "SDC":
            return .workCapacity
        case "Plank", "PLK":
            return .coreRun
        case "2-Mile Run", "2MR":
            return .endurance
        default:
            return .aftPrep
        }
    }

    static func focusLabel(for armyFocus: ArmyFocus) -> String {
        switch armyFocus {
        case .lowerStrength: return "Lower Strength"
        case .upperEndurance: return "Upper Endurance"
        case .workCapacity: return "Work Capacity"
        case .coreRun: return "Core Endurance"
        case .endurance: return "Running Endurance"
        case .aftPrep: return "Fitness Test Prep"
        case .tactical: return "Functional Conditioning"
        case .recovery: return "Recovery"
        }
    }

    static func generateFocusSession(
        weakEvents: [String],
        equipment: ArmyEquipment,
        mode: ArmyWorkoutMode,
        lastTitle: String?
    ) -> ArmyWorkoutTemplate? {
        let focuses = weakEvents.map { mapWeakEventToFocus($0) }
        let primaryFocus = focuses.first ?? .aftPrep

        if let template = nextTemplate(mode: mode, focus: primaryFocus, equipment: equipment, excluding: lastTitle) {
            return template
        }

        if let secondFocus = focuses.dropFirst().first,
           let template = nextTemplate(mode: mode, focus: secondFocus, equipment: equipment, excluding: lastTitle) {
            return template
        }

        return nextTemplate(mode: .workoutOfDay, focus: primaryFocus, equipment: equipment, excluding: lastTitle)
    }

}
