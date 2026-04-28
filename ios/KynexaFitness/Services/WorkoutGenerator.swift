import Foundation

enum WorkoutGenerator {

    struct WorkoutTemplate {
        let title: String
        let exercises: [WorkoutExercise]
        let tag: String
        let tags: [String]
    }

    static func generateWeeklyPlan(
        focus: TrainingFocus,
        level: FitnessLevel,
        equipment: EquipmentOption,
        daysPerWeek: Int,
        minutesPerWorkout: Int,
        ptMode: PTMode,
        dutyType: DutyType,
        ptGoal: PTGoal? = nil,
        totalWeeks: Int = 1,
        currentWeek: Int = 1
    ) -> WeeklyPlan {
        let calendar = Calendar.current
        let weekOffset = currentWeek - 1
        let today = calendar.date(byAdding: .day, value: weekOffset * 7, to: calendar.startOfDay(for: .now)) ?? calendar.startOfDay(for: .now)

        let armyMode = ArmyGenerator.mapArmyMode(ptMode: ptMode, dutyType: dutyType)
        let armyEquipment = ArmyGenerator.mapArmyEquipment(equipment)
        let baseFocuses: [ArmyFocus] = ptGoal?.armyFocuses ?? ArmyGenerator.mapArmyFocuses(focus)
        let armyFocuses: [ArmyFocus] = (level == .beginner)
            ? beginnerFriendlyFocuses(from: baseFocuses)
            : baseFocuses

        let progressionFocuses = applyWeeklyProgression(
            baseFocuses: armyFocuses,
            currentWeek: currentWeek,
            totalWeeks: totalWeeks,
            goal: ptGoal
        )

        let armyTemplates = ArmyGenerator.weeklyPlan(
            mode: armyMode,
            focuses: progressionFocuses,
            equipment: armyEquipment,
            days: daysPerWeek
        )

        let selectedDays = distributeDays(count: daysPerWeek)
        let modeTags = buildModeTags(ptMode: ptMode, dutyType: dutyType, focus: focus)

        var days: [WorkoutDay] = []
        var templateIndex = 0

        for dayOffset in 0..<7 {
            let date = calendar.date(byAdding: .day, value: dayOffset, to: today) ?? today
            let isWorkoutDay = selectedDays.contains(dayOffset)

            if isWorkoutDay && templateIndex < armyTemplates.count {
                let armyTemplate = armyTemplates[templateIndex]
                var exercises = ArmyGenerator.convertToWorkoutExercises(armyTemplate)
                if level == .beginner {
                    exercises = softenForBeginner(exercises)
                }
                let templateTags = [armyTemplate.focus.rawValue, armyTemplate.mode.rawValue]

                days.append(WorkoutDay(
                    dayIndex: dayOffset,
                    date: date,
                    title: armyTemplate.title,
                    exercises: exercises,
                    isRestDay: false,
                    templateTag: armyTemplate.title,
                    tags: modeTags + templateTags
                ))
                templateIndex += 1
            } else {
                let recoveryTitle = recoveryDayTitle(for: dayOffset)
                days.append(WorkoutDay(
                    dayIndex: dayOffset,
                    date: date,
                    title: recoveryTitle,
                    exercises: [],
                    isRestDay: true,
                    templateTag: "recovery"
                ))
            }
        }

        return WeeklyPlan(
            weekStartDate: today,
            goal: focus.rawValue,
            level: level.rawValue,
            equipment: equipment.rawValue,
            minutesPerWorkout: minutesPerWorkout,
            days: days,
            totalWeeks: totalWeeks,
            currentWeek: currentWeek,
            ptGoal: ptGoal?.rawValue ?? ""
        )
    }

    static func applyWeeklyProgression(
        baseFocuses: [ArmyFocus],
        currentWeek: Int,
        totalWeeks: Int,
        goal: PTGoal?
    ) -> [ArmyFocus] {
        guard let goal, totalWeeks > 1 else { return baseFocuses }

        let progress = Double(currentWeek - 1) / Double(max(totalWeeks - 1, 1))

        switch goal {
        case .generalFitness:
            if progress < 0.33 {
                return [.lowerStrength, .upperEndurance, .endurance, .coreRun, .workCapacity, .recovery]
            } else if progress < 0.66 {
                return [.aftPrep, .workCapacity, .lowerStrength, .endurance, .upperEndurance, .coreRun]
            } else {
                return [.aftPrep, .aftPrep, .workCapacity, .endurance, .coreRun, .recovery]
            }
        case .endurance:
            if progress < 0.5 {
                return [.endurance, .coreRun, .endurance, .recovery, .workCapacity, .endurance]
            } else {
                return [.endurance, .endurance, .coreRun, .endurance, .workCapacity, .recovery]
            }
        case .power:
            if progress < 0.5 {
                return [.lowerStrength, .upperEndurance, .lowerStrength, .recovery, .workCapacity, .coreRun]
            } else {
                return [.lowerStrength, .lowerStrength, .workCapacity, .upperEndurance, .lowerStrength, .recovery]
            }
        case .speed:
            if progress < 0.5 {
                return [.workCapacity, .endurance, .tactical, .coreRun, .workCapacity, .recovery]
            } else {
                return [.workCapacity, .tactical, .workCapacity, .endurance, .tactical, .recovery]
            }
        case .cardio:
            if progress < 0.5 {
                return [.endurance, .coreRun, .endurance, .recovery, .coreRun, .endurance]
            } else {
                return [.endurance, .endurance, .coreRun, .endurance, .coreRun, .recovery]
            }
        }
    }

    static func generateWorkoutOfDay(
        focus: TrainingFocus,
        level: FitnessLevel,
        equipment: EquipmentOption,
        minutes: Int,
        lastWorkoutTag: String,
        ptMode: PTMode,
        dutyType: DutyType
    ) -> WorkoutDay {
        let armyEquipment = ArmyGenerator.mapArmyEquipment(equipment)
        let armyFocuses = ArmyGenerator.mapArmyFocuses(focus)
        let randomFocus = armyFocuses.randomElement() ?? .aftPrep

        let template = ArmyGenerator.nextTemplate(
            mode: .workoutOfDay,
            focus: randomFocus,
            equipment: armyEquipment,
            excluding: lastWorkoutTag
        ) ?? ArmyGenerator.nextTemplate(
            mode: .onDutyIndividual,
            focus: randomFocus,
            equipment: armyEquipment,
            excluding: lastWorkoutTag
        )

        guard let chosen = template else {
            return fallbackWorkoutDay(focus: focus, ptMode: ptMode, dutyType: dutyType)
        }

        let exercises = ArmyGenerator.convertToWorkoutExercises(chosen)
        let modeTags = buildModeTags(ptMode: ptMode, dutyType: dutyType, focus: focus)

        return WorkoutDay(
            dayIndex: 0,
            date: Calendar.current.startOfDay(for: .now),
            title: chosen.title,
            exercises: exercises,
            templateTag: chosen.title,
            tags: modeTags + [chosen.focus.rawValue, "FunctionFitness"]
        )
    }

    static func generateRandomWorkout(
        focus: TrainingFocus,
        level: FitnessLevel,
        equipment: EquipmentOption,
        minutes: Int,
        lastWorkoutTag: String,
        ptMode: PTMode,
        dutyType: DutyType
    ) -> WorkoutDay {
        let armyEquipment = ArmyGenerator.mapArmyEquipment(equipment)
        let armyFocuses = ArmyGenerator.mapArmyFocuses(focus)
        let randomFocus = armyFocuses.randomElement() ?? .tactical

        let template = ArmyGenerator.nextTemplate(
            mode: .randomSession,
            focus: randomFocus,
            equipment: armyEquipment,
            excluding: lastWorkoutTag
        ) ?? ArmyGenerator.nextTemplate(
            mode: .offDutyIndividual,
            focus: randomFocus,
            equipment: armyEquipment,
            excluding: lastWorkoutTag
        )

        guard let chosen = template else {
            return fallbackWorkoutDay(focus: focus, ptMode: ptMode, dutyType: dutyType)
        }

        let exercises = ArmyGenerator.convertToWorkoutExercises(chosen)
        let modeTags = buildModeTags(ptMode: ptMode, dutyType: dutyType, focus: focus)

        return WorkoutDay(
            dayIndex: 0,
            date: Calendar.current.startOfDay(for: .now),
            title: chosen.title,
            exercises: exercises,
            templateTag: chosen.title,
            tags: modeTags + [chosen.focus.rawValue, "Random"]
        )
    }





    // MARK: - Beginner Softening

    static func beginnerFriendlyFocuses(from base: [ArmyFocus]) -> [ArmyFocus] {
        // Favor endurance (walk-paced), core, and upper endurance (bodyweight).
        // Replace strength / tactical / work capacity with gentler alternatives.
        return base.map { focus -> ArmyFocus in
            switch focus {
            case .lowerStrength, .tactical, .workCapacity, .aftPrep:
                return .upperEndurance
            case .endurance, .coreRun, .upperEndurance, .recovery:
                return focus
            }
        }
    }

    static func softenForBeginner(_ exercises: [WorkoutExercise]) -> [WorkoutExercise] {
        exercises.map { ex -> WorkoutExercise in
            var updated = ex
            let lower = ex.name.lowercased()

            // Convert runs to walks for beginners.
            if ex.category == .cardio {
                if lower.contains("run") || lower.contains("jog") || lower.contains("sprint") {
                    let newName: String
                    if lower.contains("mile") {
                        newName = "Easy Walk"
                    } else {
                        newName = ex.name
                            .replacingOccurrences(of: "Run", with: "Walk")
                            .replacingOccurrences(of: "Jog", with: "Walk")
                            .replacingOccurrences(of: "Sprint", with: "Walk")
                    }
                    updated.name = newName
                    updated.cardioType = .walk
                    if updated.notes.isEmpty {
                        updated.notes = "Comfortable walking pace."
                    }
                }
            }

            // Reduce set counts for strength / bodyweight work.
            if ex.category == .strength || ex.category == .bodyweight {
                updated.sets = max(1, min(ex.sets, 3))
                if ex.reps > 0 {
                    updated.reps = max(5, min(ex.reps, 12))
                }
            }

            return updated
        }
    }

    // MARK: - Private

    static func buildModeTags(ptMode: PTMode, dutyType: DutyType, focus: TrainingFocus) -> [String] {
        var tags: [String] = []
        switch ptMode {
        case .individual: tags.append("Individual")
        case .unit: tags.append("Unit")
        case .both: tags.append("Individual")
        }
        switch dutyType {
        case .onDuty: tags.append("On-Duty")
        case .offDuty: tags.append("Off-Duty")
        case .both: tags.append("On-Duty")
        }
        if focus == .aftPrep { tags.append("Conditioning") }
        return tags
    }

    private static func distributeDays(count: Int) -> Set<Int> {
        switch count {
        case 1: return [0]
        case 2: return [0, 3]
        case 3: return [0, 2, 4]
        case 4: return [0, 1, 3, 5]
        case 5: return [0, 1, 2, 4, 5]
        case 6: return [0, 1, 2, 3, 4, 5]
        case 7: return [0, 1, 2, 3, 4, 5, 6]
        default: return [0, 2, 4]
        }
    }

    private static func recoveryDayTitle(for dayOffset: Int) -> String {
        let titles = ["Recovery & Mobility", "Active Recovery", "Easy Movement", "Maintenance Session", "Light Mobility"]
        return titles[dayOffset % titles.count]
    }

    private static func fallbackWorkoutDay(focus: TrainingFocus, ptMode: PTMode, dutyType: DutyType) -> WorkoutDay {
        let modeTags = buildModeTags(ptMode: ptMode, dutyType: dutyType, focus: focus)
        return WorkoutDay(
            dayIndex: 0,
            date: Calendar.current.startOfDay(for: .now),
            title: "General Fitness",
            exercises: [
                WorkoutExercise(name: "Dynamic Warm-Up", sets: 1, durationSeconds: 300, notes: "Light cardio and joint mobility.", category: .timed),
                WorkoutExercise(name: "Push-Up", sets: 4, reps: 15, category: .bodyweight),
                WorkoutExercise(name: "Air Squat", sets: 4, reps: 20, category: .bodyweight),
                WorkoutExercise(name: "Plank Hold", sets: 3, durationSeconds: 60, category: .timed),
                WorkoutExercise(name: "400 m Run", sets: 3, durationSeconds: 120, notes: "Moderate pace", category: .cardio, cardioType: .run),
                WorkoutExercise(name: "Cool Down & Stretch", sets: 1, durationSeconds: 240, notes: "Light walk and full-body static stretching.", category: .timed)
            ],
            templateTag: "fallback_general",
            tags: modeTags + ["General"]
        )
    }

}
