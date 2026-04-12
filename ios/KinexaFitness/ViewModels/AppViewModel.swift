import SwiftUI
import Observation

@Observable
final class AppViewModel {
    var currentPlan: WeeklyPlan?
    var completedRecords: [CompletedWorkoutRecord] = []
    var stepHistory: [StepDay] = []
    var pedometer = PedometerManager()
    var lastWorkoutTag: String = ""
    var importedWorkouts: [WorkoutDay] = []
    var wodPlan: WODPlan?
    var todayFunctionalWOD: WODTemplate?
    var activeRecap: InstantRecap?
    var ptPlanNeedsSync: Bool = false
    var wodPlanNeedsSync: Bool = false
    var quickStartRecords: [QuickStartRecord] = []
    var cardioSessions: [CardioSession] = []

    var performanceHighlights: [PerformanceHighlight] {
        PerformanceHighlightsService.generateHighlights(
            completedRecords: completedRecords,
            currentPlan: currentPlan,
            wodPlan: wodPlan,
            streak: streak
        )
    }

    func showRecap(_ recap: InstantRecap) {
        activeRecap = recap
    }

    init() {
        loadLocalData()
        pedometer.refreshTodaySteps()
        syncTodaySteps()
    }

    func loadLocalData() {
        currentPlan = LocalStore.load(WeeklyPlan?.self, forKey: "currentPlan", fallback: nil)
        completedRecords = LocalStore.load([CompletedWorkoutRecord].self, forKey: "completedRecords", fallback: [])
        stepHistory = LocalStore.load([StepDay].self, forKey: "stepHistory", fallback: [])
        lastWorkoutTag = UserDefaults.standard.string(forKey: "lastWorkoutTag") ?? ""
        importedWorkouts = LocalStore.load([WorkoutDay].self, forKey: "importedWorkouts", fallback: [])
        wodPlan = LocalStore.load(WODPlan?.self, forKey: "wodPlan", fallback: nil)
        quickStartRecords = LocalStore.load([QuickStartRecord].self, forKey: "quickStartRecords", fallback: [])
        cardioSessions = LocalStore.load([CardioSession].self, forKey: "cardioSessions", fallback: [])
        loadTodayFunctionalWOD()
    }

    func persistAll() {
        LocalStore.save(currentPlan, forKey: "currentPlan")
        LocalStore.save(completedRecords, forKey: "completedRecords")
        LocalStore.save(stepHistory, forKey: "stepHistory")
        UserDefaults.standard.set(lastWorkoutTag, forKey: "lastWorkoutTag")
        LocalStore.save(importedWorkouts, forKey: "importedWorkouts")
        LocalStore.save(wodPlan, forKey: "wodPlan")
        LocalStore.save(quickStartRecords, forKey: "quickStartRecords")
        LocalStore.save(cardioSessions, forKey: "cardioSessions")
        syncWidgetData()
    }

    func syncWidgetData() {
        let today = Calendar.current.startOfDay(for: .now)
        let todayWork = currentPlan?.days.first { Calendar.current.isDate($0.date, inSameDayAs: today) && !$0.isRestDay }
        let completedToday = todayWork?.isCompleted ?? false

        SharedDataManager.writeWidgetData(
            todayWorkoutTitle: todayWork?.title,
            todayWorkoutExerciseCount: todayWork?.exercises.count ?? 0,
            streak: streak,
            stepsToday: pedometer.todaySteps,
            completedToday: completedToday,
            planWeek: currentPlan?.currentWeek ?? 0,
            planTotalWeeks: currentPlan?.totalWeeks ?? 0
        )
    }

    func syncTodaySteps() {
        let today = Calendar.current.startOfDay(for: .now)
        if let index = stepHistory.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            stepHistory[index].steps = pedometer.todaySteps
        } else {
            stepHistory.append(StepDay(date: today, steps: pedometer.todaySteps))
        }
        stepHistory.sort { $0.date < $1.date }
        persistAll()
    }

    // MARK: - Preferences

    var currentFocus: TrainingFocus {
        TrainingFocus(rawValue: UserDefaults.standard.string(forKey: "trainingFocus") ?? "") ?? .generalFitness
    }

    var currentLevel: FitnessLevel {
        FitnessLevel(rawValue: UserDefaults.standard.string(forKey: "fitnessLevel") ?? "") ?? .intermediate
    }

    var currentEquipment: EquipmentOption {
        EquipmentOption(rawValue: UserDefaults.standard.string(forKey: "equipment") ?? "") ?? .bodyweight
    }

    var currentMinutes: Int {
        let m = UserDefaults.standard.integer(forKey: "minutesPerWorkout")
        return m > 0 ? m : 30
    }

    var currentPTMode: PTMode {
        PTMode(rawValue: UserDefaults.standard.string(forKey: "ptMode") ?? "") ?? .both
    }

    var currentDutyType: DutyType {
        DutyType(rawValue: UserDefaults.standard.string(forKey: "dutyType") ?? "") ?? .both
    }

    var currentPTGoal: PTGoal? {
        guard let raw = UserDefaults.standard.string(forKey: "ptGoal"), !raw.isEmpty else { return nil }
        return PTGoal(rawValue: raw)
    }

    var currentPlanWeeks: Int {
        let w = UserDefaults.standard.integer(forKey: "planWeeks")
        return w > 0 ? w : 4
    }

    // MARK: - Plan Generation

    func generateWeeklyPlan() {
        let days = UserDefaults.standard.integer(forKey: "daysPerWeek")
        let daysPerWeek = days > 0 ? min(days, 7) : 3

        currentPlan = WorkoutGenerator.generateWeeklyPlan(
            focus: currentFocus,
            level: currentLevel,
            equipment: currentEquipment,
            daysPerWeek: daysPerWeek,
            minutesPerWorkout: currentMinutes,
            ptMode: currentPTMode,
            dutyType: currentDutyType,
            ptGoal: currentPTGoal,
            totalWeeks: currentPlanWeeks,
            currentWeek: currentPlan?.currentWeek ?? 1
        )
        persistAll()
    }

    func generateGoalPlan(goal: PTGoal, weeks: Int) {
        UserDefaults.standard.set(goal.rawValue, forKey: "ptGoal")
        UserDefaults.standard.set(weeks, forKey: "planWeeks")

        let days = UserDefaults.standard.integer(forKey: "daysPerWeek")
        let daysPerWeek = days > 0 ? min(days, 7) : 3

        currentPlan = WorkoutGenerator.generateWeeklyPlan(
            focus: currentFocus,
            level: currentLevel,
            equipment: currentEquipment,
            daysPerWeek: daysPerWeek,
            minutesPerWorkout: currentMinutes,
            ptMode: currentPTMode,
            dutyType: currentDutyType,
            ptGoal: goal,
            totalWeeks: weeks,
            currentWeek: 1
        )
        persistAll()
    }

    func advanceToNextWeek() {
        guard let plan = currentPlan else { return }
        let nextWeek = plan.currentWeek + 1
        guard nextWeek <= plan.totalWeeks else { return }

        let days = UserDefaults.standard.integer(forKey: "daysPerWeek")
        let daysPerWeek = days > 0 ? min(days, 7) : 3

        currentPlan = WorkoutGenerator.generateWeeklyPlan(
            focus: currentFocus,
            level: currentLevel,
            equipment: currentEquipment,
            daysPerWeek: daysPerWeek,
            minutesPerWorkout: currentMinutes,
            ptMode: currentPTMode,
            dutyType: currentDutyType,
            ptGoal: currentPTGoal,
            totalWeeks: plan.totalWeeks,
            currentWeek: nextWeek
        )
        persistAll()
    }

    func ensureTodayHasWorkout() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        if let plan = currentPlan {
            let hasTodayInPlan = plan.days.contains { calendar.isDate($0.date, inSameDayAs: today) }
            if !hasTodayInPlan {
                let completedDays = plan.days.filter(\.isCompleted)
                generateWeeklyPlan()
                if var newPlan = currentPlan {
                    for completed in completedDays {
                        if let idx = newPlan.days.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: completed.date) }) {
                            newPlan.days[idx].isCompleted = true
                        }
                    }
                    currentPlan = newPlan
                    persistAll()
                }
            }
        } else {
            generateWeeklyPlan()
        }
    }

    func generateWorkoutOfDay() -> WorkoutDay {
        WorkoutGenerator.generateWorkoutOfDay(
            focus: currentFocus, level: currentLevel, equipment: currentEquipment,
            minutes: currentMinutes, lastWorkoutTag: lastWorkoutTag,
            ptMode: currentPTMode, dutyType: currentDutyType
        )
    }

    func generateRandomWorkout() -> WorkoutDay {
        WorkoutGenerator.generateRandomWorkout(
            focus: currentFocus, level: currentLevel, equipment: currentEquipment,
            minutes: currentMinutes, lastWorkoutTag: lastWorkoutTag,
            ptMode: currentPTMode, dutyType: currentDutyType
        )
    }

    func generateRecoverySession() -> WorkoutDay {
        let recoveryTemplates = ArmyTemplateLibrary.templates.filter { $0.focus == .recovery }
        let template = recoveryTemplates.randomElement()

        if let template {
            let exercises = ArmyGenerator.convertToWorkoutExercises(template)
            return WorkoutDay(
                dayIndex: -1,
                date: Calendar.current.startOfDay(for: .now),
                title: template.title,
                exercises: exercises,
                templateTag: template.title,
                tags: ["Recovery", "Active Rest"]
            )
        }

        return WorkoutDay(
            dayIndex: -1,
            date: Calendar.current.startOfDay(for: .now),
            title: "Recovery & Mobility",
            exercises: [
                WorkoutExercise(name: "PMCS Drill", sets: 1, durationSeconds: 360, notes: "Full mobility sequence", category: .timed),
                WorkoutExercise(name: "Hip Stability Drill", sets: 1, durationSeconds: 300, notes: "Through sequence", category: .timed),
                WorkoutExercise(name: "Shoulder Stability Drill", sets: 1, durationSeconds: 300, notes: "Through sequence", category: .timed),
                WorkoutExercise(name: "Recovery Drill", sets: 1, durationSeconds: 300, notes: "Full sequence", category: .timed)
            ],
            templateTag: "recovery_fallback",
            tags: ["Recovery", "Active Rest"]
        )
    }

    func allWorkoutsForDate(_ date: Date) -> [WorkoutDay] {
        let calendar = Calendar.current
        var results: [WorkoutDay] = []

        if let plan = currentPlan {
            results += plan.days.filter { calendar.isDate($0.date, inSameDayAs: date) }
        }

        return results
    }

    // MARK: - Completion

    func markDayCompleted(dayIndex: Int) {
        guard var plan = currentPlan,
              let idx = plan.days.firstIndex(where: { $0.dayIndex == dayIndex }) else { return }
        let alreadyCompleted = plan.days[idx].isCompleted
        plan.days[idx].isCompleted = true
        lastWorkoutTag = plan.days[idx].templateTag
        currentPlan = plan

        if !alreadyCompleted {
            SmartWorkoutBrain.recordWorkoutPatterns(plan.days[idx].exercises)
            completedRecords.insert(
                CompletedWorkoutRecord(
                    title: plan.days[idx].title,
                    exerciseCount: plan.days[idx].exercises.count,
                    exercises: plan.days[idx].exercises,
                    source: plan.days[idx].source
                ), at: 0
            )

            let completed = plan.days.filter(\.isCompleted).count
            let total = plan.totalWorkoutDays
            showRecap(PerformanceHighlightsService.planDayRecap(dayNumber: completed, totalDays: total))
        }
        persistAll()
    }

    func markDayIncomplete(dayIndex: Int) {
        guard var plan = currentPlan,
              let idx = plan.days.firstIndex(where: { $0.dayIndex == dayIndex }) else { return }
        plan.days[idx].isCompleted = false
        currentPlan = plan
        persistAll()
    }

    func completeStandaloneWorkout(_ workout: WorkoutDay) {
        lastWorkoutTag = workout.templateTag
        SmartWorkoutBrain.recordWorkoutPatterns(workout.exercises)
        completedRecords.insert(
            CompletedWorkoutRecord(
                title: workout.title,
                exerciseCount: workout.exercises.count,
                exercises: workout.exercises,
                source: workout.source
            ), at: 0
        )
        showRecap(PerformanceHighlightsService.workoutRecap(title: workout.title, exerciseCount: workout.exercises.count))
        persistAll()
    }

    func reorderPTDays(from source: IndexSet, to destination: Int) {
        guard var plan = currentPlan else { return }
        plan.days.move(fromOffsets: source, toOffset: destination)
        for i in plan.days.indices {
            plan.days[i].dayIndex = i
        }
        currentPlan = plan
        ptPlanNeedsSync = true
        persistAll()
    }

    func updateDayExercises(dayIndex: Int, exercises: [WorkoutExercise]) {
        guard var plan = currentPlan,
              let idx = plan.days.firstIndex(where: { $0.dayIndex == dayIndex }) else { return }
        plan.days[idx].exercises = exercises
        currentPlan = plan
        ptPlanNeedsSync = true
        persistAll()
    }

    func updateCompletedRecord(id: UUID, exercises: [WorkoutExercise]) {
        guard let idx = completedRecords.firstIndex(where: { $0.id == id }) else { return }
        completedRecords[idx].exercises = exercises
        completedRecords[idx].exerciseCount = exercises.count
        persistAll()
    }

    func completedRecordsForDate(_ date: Date) -> [CompletedWorkoutRecord] {
        let calendar = Calendar.current
        return completedRecords.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    func replaceRestDayWithWorkout(dayIndex: Int) {
        guard var plan = currentPlan,
              let idx = plan.days.firstIndex(where: { $0.dayIndex == dayIndex && $0.isRestDay }) else { return }

        let armyMode = ArmyGenerator.mapArmyMode(ptMode: currentPTMode, dutyType: currentDutyType)
        let armyEquipment = ArmyGenerator.mapArmyEquipment(currentEquipment)
        let armyFocuses = ArmyGenerator.mapArmyFocuses(currentFocus)
        let randomFocus = armyFocuses.randomElement() ?? .aftPrep

        let template = ArmyGenerator.nextTemplate(
            mode: armyMode,
            focus: randomFocus,
            equipment: armyEquipment,
            excluding: lastWorkoutTag
        )

        let modeTags = WorkoutGenerator.buildModeTags(ptMode: currentPTMode, dutyType: currentDutyType, focus: currentFocus)

        if let template {
            let exercises = ArmyGenerator.convertToWorkoutExercises(template)
            plan.days[idx] = WorkoutDay(
                dayIndex: dayIndex,
                date: plan.days[idx].date,
                title: template.title,
                exercises: exercises,
                isRestDay: false,
                templateTag: template.title,
                tags: modeTags + [template.focus.rawValue]
            )
        } else {
            plan.days[idx] = WorkoutDay(
                dayIndex: dayIndex,
                date: plan.days[idx].date,
                title: "General Fitness PT",
                exercises: [
                    WorkoutExercise(name: "Preparation Drill", sets: 1, durationSeconds: 300, notes: "PD: 10 exercises, 5 reps each", category: .timed),
                    WorkoutExercise(name: "Push-Up", sets: 4, reps: 15, category: .bodyweight),
                    WorkoutExercise(name: "Air Squat", sets: 4, reps: 20, category: .bodyweight),
                    WorkoutExercise(name: "Plank Hold", sets: 3, durationSeconds: 60, category: .timed),
                    WorkoutExercise(name: "Recovery Drill", sets: 1, durationSeconds: 240, notes: "RD: Full sequence", category: .timed)
                ],
                isRestDay: false,
                templateTag: "fallback_general",
                tags: modeTags + ["General"]
            )
        }
        currentPlan = plan
        ptPlanNeedsSync = true
        persistAll()
    }

    func regenerateSingleDay(dayIndex: Int) {
        guard var plan = currentPlan,
              let idx = plan.days.firstIndex(where: { $0.dayIndex == dayIndex }) else { return }

        let armyMode = ArmyGenerator.mapArmyMode(ptMode: currentPTMode, dutyType: currentDutyType)
        let armyEquipment = ArmyGenerator.mapArmyEquipment(currentEquipment)
        let armyFocuses = ArmyGenerator.mapArmyFocuses(currentFocus)
        let randomFocus = armyFocuses.randomElement() ?? .aftPrep
        let currentTag = plan.days[idx].templateTag

        let template = ArmyGenerator.nextTemplate(
            mode: armyMode,
            focus: randomFocus,
            equipment: armyEquipment,
            excluding: currentTag
        )

        let modeTags = WorkoutGenerator.buildModeTags(ptMode: currentPTMode, dutyType: currentDutyType, focus: currentFocus)

        if let template {
            let exercises = ArmyGenerator.convertToWorkoutExercises(template)
            plan.days[idx] = WorkoutDay(
                dayIndex: dayIndex,
                date: plan.days[idx].date,
                title: template.title,
                exercises: exercises,
                isRestDay: false,
                templateTag: template.title,
                tags: modeTags + [template.focus.rawValue]
            )
        }
        currentPlan = plan
        ptPlanNeedsSync = true
        persistAll()
    }

    func convertDayToRecovery(dayIndex: Int) {
        guard var plan = currentPlan,
              let idx = plan.days.firstIndex(where: { $0.dayIndex == dayIndex }) else { return }
        let titles = ["Recovery & Mobility", "Active Recovery", "Easy Movement", "Maintenance Session", "Light Mobility"]
        plan.days[idx] = WorkoutDay(
            dayIndex: dayIndex,
            date: plan.days[idx].date,
            title: titles[dayIndex % titles.count],
            exercises: [],
            isRestDay: true,
            templateTag: "recovery"
        )
        currentPlan = plan
        ptPlanNeedsSync = true
        persistAll()
    }

    func saveImportedWorkout(_ workout: WorkoutDay) {
        importedWorkouts.insert(workout, at: 0)
        persistAll()
    }

    func savePlanSnapshot() {
        persistAll()
    }

    func importPlan(_ plan: WeeklyPlan) {
        currentPlan = plan
        persistAll()
    }

    var planShareText: String {
        guard let plan = currentPlan else { return "" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        let goalLabel = plan.ptGoal.isEmpty ? "General" : plan.ptGoal

        var text = "Training Plan\n"
        text += "Goal: \(goalLabel) · Week \(plan.currentWeek) of \(plan.totalWeeks)\n"
        if let first = plan.days.first, let last = plan.days.last {
            text += "\(dateFormatter.string(from: first.date)) – \(dateFormatter.string(from: last.date))\n"
        }
        text += "\n"

        for (index, day) in plan.days.enumerated() {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEE"
            let dayName = dayFormatter.string(from: day.date)

            if day.isRestDay {
                text += "Day \(index + 1) (\(dayName)): Rest & Recovery\n"
            } else {
                text += "Day \(index + 1) (\(dayName)): \(day.title)\n"
                for exercise in day.exercises {
                    text += "  • \(exercise.name) — \(exercise.displayDetail)\n"
                }
            }
            text += "\n"
        }

        text += "#KinexaFitness"
        return text
    }

    // MARK: - Computed

    var todayWorkout: WorkoutDay? {
        guard let plan = currentPlan else { return nil }
        let today = Calendar.current.startOfDay(for: .now)
        return plan.days.first { Calendar.current.isDate($0.date, inSameDayAs: today) && !$0.isRestDay }
    }

    var weeklyCompletedCount: Int {
        currentPlan?.completedCount ?? 0
    }

    var weeklyTotalDays: Int {
        currentPlan?.totalWorkoutDays ?? 0
    }

    var streak: Int {
        let calendar = Calendar.current
        let completedDays = Set(completedRecords.map { calendar.startOfDay(for: $0.date) })

        var streakCount = 0
        var currentDay = calendar.startOfDay(for: .now)

        while completedDays.contains(currentDay) {
            streakCount += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: currentDay) else { break }
            currentDay = previous
        }

        return streakCount
    }

    var totalWorkoutsCompleted: Int {
        completedRecords.count
    }

    var workoutsThisWeek: Int {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: .now)) ?? .now
        return completedRecords.filter { $0.date >= startOfWeek }.count
    }

    var averageSteps: Int {
        guard !stepHistory.isEmpty else { return 0 }
        return stepHistory.map(\.steps).reduce(0, +) / stepHistory.count
    }

    var weeklyStepAverage: Int {
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: .now) ?? .now
        let recentSteps = stepHistory.filter { $0.date >= sevenDaysAgo }
        guard !recentSteps.isEmpty else { return 0 }
        return recentSteps.map(\.steps).reduce(0, +) / recentSteps.count
    }

    // MARK: - WOD Plan

    func loadTodayFunctionalWOD() {
        let today = Calendar.current.startOfDay(for: .now)

        if let plan = wodPlan {
            let todayDay = plan.days.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) })
            if let todayDay {
                if todayDay.isRestDay {
                    todayFunctionalWOD = nil
                    return
                } else {
                    todayFunctionalWOD = todayDay.template
                    return
                }
            }
        }

        let lastDate = UserDefaults.standard.double(forKey: "lastFunctionalWODDate")
        if lastDate > 0, Calendar.current.isDate(Date(timeIntervalSince1970: lastDate), inSameDayAs: today) {
            if let data = UserDefaults.standard.data(forKey: "todayFunctionalWOD"),
               let template = try? JSONDecoder().decode(WODTemplate.self, from: data) {
                todayFunctionalWOD = template
                return
            }
        }
        regenerateFunctionalWOD()
    }

    func regenerateFunctionalWOD() {
        let template = WODService.generateWOD(
            equipment: currentEquipment,
            dutyType: currentDutyType
        )
        todayFunctionalWOD = template
        if let data = try? JSONEncoder().encode(template) {
            UserDefaults.standard.set(data, forKey: "todayFunctionalWOD")
        }
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "lastFunctionalWODDate")
    }

    func setFunctionalFitnessAsToday(_ template: WODTemplate) {
        todayFunctionalWOD = template
        if let data = try? JSONEncoder().encode(template) {
            UserDefaults.standard.set(data, forKey: "todayFunctionalWOD")
        }
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "lastFunctionalWODDate")
    }

    var todayPTWorkout: WorkoutDay? {
        guard let plan = currentPlan else { return nil }
        let today = Calendar.current.startOfDay(for: .now)
        return plan.days.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }

    var todayWODPlanDay: WODPlanDay? {
        guard let plan = wodPlan else { return nil }
        let today = Calendar.current.startOfDay(for: .now)
        return plan.days.first { Calendar.current.isDate($0.date, inSameDayAs: today) && !$0.isRestDay }
    }

    func generateWODPlan(goal: PTGoal, weeks: Int, heroPreference: WODHeroPreference = .regular, trainingFrequency: Int = 5, trainingGoal: TrainingGoal = .generalFitness) {
        UserDefaults.standard.set(goal.rawValue, forKey: "ptGoal")
        UserDefaults.standard.set(weeks, forKey: "planWeeks")

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) ?? today

        var days: [WODPlanDay] = []
        let daysCount = 7

        let clampedFrequency = min(max(trainingFrequency, 2), 6)
        let restDayIndices = computeRestDays(trainingDays: clampedFrequency)

        let pool = WODTemplateLibrary.poolForPreference(heroPreference)
        let workoutDayCount = daysCount - restDayIndices.count

        let wodEquipment: WODEquipment
        switch currentEquipment {
        case .gym: wodEquipment = .gym
        case .minimal, .field: wodEquipment = .minimal
        default: wodEquipment = .none
        }

        let brainSelection = SmartBrainSelection(
            goal: trainingGoal,
            duration: currentMinutes,
            equipment: wodEquipment,
            difficulty: SmartWorkoutBrain.shouldReduceIntensity() ? .moderate : .high,
            trainingFrequency: workoutDayCount,
            focusArea: .fullBody,
            workoutStyle: heroPreference == .mixed ? .freeWeight : heroPreference == .combined ? .hybrid : .functional,
            level: currentLevel
        )

        let smartSelections = SmartWorkoutBrain.selectWeekPlanWithBrain(
            pool: pool,
            selection: brainSelection,
            weekNumber: 1,
            totalWeeks: weeks
        )

        var workoutIndex = 0

        for i in 0..<daysCount {
            guard let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) else { continue }

            if restDayIndices.contains(i) {
                let restTemplate = WODTemplate(
                    title: "Rest & Recovery",
                    category: .crossfit,
                    format: .circuit,
                    durationMinutes: 0,
                    equipment: .none,
                    movements: [],
                    workoutDescription: "Active rest day"
                )
                days.append(WODPlanDay(date: date, template: restTemplate, isRestDay: true))
            } else {
                let selected: WODTemplate
                if workoutIndex < smartSelections.count {
                    selected = smartSelections[workoutIndex]
                } else {
                    selected = pool.randomElement() ?? WODTemplateLibrary.functionalWODs[0]
                }
                SmartWorkoutBrain.recordWODSplit(selected.trainingSplit)
                days.append(WODPlanDay(date: date, template: selected))
                workoutIndex += 1
            }
        }

        wodPlan = WODPlan(
            days: days,
            ptGoal: goal.rawValue,
            totalWeeks: weeks,
            currentWeek: 1,
            weekStartDate: startOfWeek,
            heroPreference: heroPreference,
            trainingFrequency: clampedFrequency,
            trainingGoal: trainingGoal.rawValue,
            workoutStyle: heroPreference.rawValue
        )
        loadTodayFunctionalWOD()
        persistAll()
    }

    private func computeRestDays(trainingDays: Int) -> Set<Int> {
        switch trainingDays {
        case 2: return [1, 2, 4, 5, 6]
        case 3: return [2, 4, 6]
        case 4: return [2, 4, 6]
        case 5: return [3, 6]
        case 6: return [6]
        default: return [3, 6]
        }
    }

    var wodPlanShareText: String {
        guard let plan = wodPlan else { return "" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        let goalLabel = plan.ptGoal.isEmpty ? "FunctionFitness Plan" : plan.ptGoal

        var text = "Functional Fitness Plan\n"
        text += "Goal: \(goalLabel) · Week \(plan.currentWeek) of \(plan.totalWeeks)\n"
        if let first = plan.days.first, let last = plan.days.last {
            text += "\(dateFormatter.string(from: first.date)) – \(dateFormatter.string(from: last.date))\n"
        }
        text += "\n"

        for (index, day) in plan.days.enumerated() {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEE"
            let dayName = dayFormatter.string(from: day.date)

            if day.isRestDay {
                text += "Day \(index + 1) (\(dayName)): Rest & Recovery\n"
            } else {
                let heroTag = ""
                text += "Day \(index + 1) (\(dayName)): \(day.template.title)\(heroTag)\n"
                text += "  \(day.template.format.rawValue) · ~\(day.template.durationMinutes) min\n"
                for movement in day.template.movements {
                    let detail = movement.reps ?? movement.duration ?? ""
                    text += "  • \(movement.name)\(detail.isEmpty ? "" : " — \(detail)")\n"
                }
            }
            text += "\n"
        }

        text += "#KinexaFitness"
        return text
    }

    func saveWODPlanSnapshot() {
        persistAll()
    }

    func refreshWODPlan() {
        guard let plan = wodPlan else { return }
        let goal = PTGoal(rawValue: plan.ptGoal) ?? .generalFitness
        let tGoal = TrainingGoal(rawValue: plan.trainingGoal) ?? .generalFitness
        generateWODPlan(goal: goal, weeks: plan.totalWeeks, heroPreference: plan.heroPreference, trainingFrequency: plan.trainingFrequency, trainingGoal: tGoal)
    }

    func convertWODDayToRest(dayId: UUID) {
        guard var plan = wodPlan,
              let idx = plan.days.firstIndex(where: { $0.id == dayId }) else { return }
        let restTemplate = WODTemplate(
            title: "Rest & Recovery",
            category: .bodyweight,
            format: .circuit,
            durationMinutes: 0,
            equipment: .none,
            movements: [],
            workoutDescription: "Active rest"
        )
        plan.days[idx] = WODPlanDay(date: plan.days[idx].date, template: restTemplate, isRestDay: true)
        wodPlan = plan
        wodPlanNeedsSync = true
        persistAll()
    }

    func convertWODRestToWorkout(dayId: UUID) {
        guard var plan = wodPlan,
              let idx = plan.days.firstIndex(where: { $0.id == dayId && $0.isRestDay }) else { return }
        let pool = WODTemplateLibrary.poolForPreference(plan.heroPreference)
        let recentSplits = SmartWorkoutBrain.recentTrainingSplits()
        let usedTitles = Set(plan.days.filter { !$0.isRestDay }.map { $0.template.title })
        if let newTemplate = SmartWorkoutBrain.selectBestTemplate(
            from: pool,
            equipment: .gym,
            recentSplits: recentSplits,
            excluding: usedTitles
        ) {
            plan.days[idx] = WODPlanDay(date: plan.days[idx].date, template: newTemplate)
            wodPlan = plan
            wodPlanNeedsSync = true
            persistAll()
        }
    }

    func reorderWODDays(from source: IndexSet, to destination: Int) {
        guard var plan = wodPlan else { return }
        plan.days.move(fromOffsets: source, toOffset: destination)
        wodPlan = plan
        wodPlanNeedsSync = true
        persistAll()
    }

    func updateWODDayMovements(dayId: UUID, movements: [WODMovement]) {
        guard var plan = wodPlan,
              let idx = plan.days.firstIndex(where: { $0.id == dayId }) else { return }
        plan.days[idx].template.movements = movements
        wodPlan = plan
        wodPlanNeedsSync = true
        persistAll()
    }

    func regenerateWODDay(dayId: UUID) {
        guard var plan = wodPlan,
              let idx = plan.days.firstIndex(where: { $0.id == dayId }) else { return }
        let currentTitle = plan.days[idx].template.title
        let pool = WODTemplateLibrary.poolForPreference(plan.heroPreference)
        let usedTitles = Set(plan.days.filter { !$0.isRestDay }.map { $0.template.title })
        let recentSplits = SmartWorkoutBrain.recentTrainingSplits()
        if let newTemplate = SmartWorkoutBrain.selectBestTemplate(
            from: pool,
            equipment: .gym,
            recentSplits: recentSplits,
            excluding: usedTitles.union([currentTitle])
        ) {
            plan.days[idx] = WODPlanDay(date: plan.days[idx].date, template: newTemplate)
            wodPlan = plan
            wodPlanNeedsSync = true
            persistAll()
        }
    }

    // MARK: - Unified Calendar Data

    nonisolated enum CalendarWorkoutStatus: Sendable {
        case planned
        case completed
        case missed
    }

    struct CalendarWorkoutEntry: Identifiable {
        let id: UUID
        let title: String
        let date: Date
        let type: String
        let duration: Int
        let status: CalendarWorkoutStatus
        let source: WorkoutSource
        let exerciseCount: Int
    }

    func allCalendarEntriesForDate(_ date: Date) -> [CalendarWorkoutEntry] {
        let cal = Calendar.current
        var entries: [CalendarWorkoutEntry] = []
        let isPast = cal.startOfDay(for: date) < cal.startOfDay(for: .now)
        let isToday = cal.isDateInToday(date)

        if let plan = currentPlan {
            for day in plan.days where cal.isDate(day.date, inSameDayAs: date) && !day.isRestDay {
                let status: CalendarWorkoutStatus
                if day.isCompleted { status = .completed }
                else if isPast && !isToday { status = .missed }
                else { status = .planned }
                entries.append(CalendarWorkoutEntry(
                    id: day.id, title: day.title, date: day.date,
                    type: "PT", duration: max(day.exercises.count * 4, 15),
                    status: status, source: day.source, exerciseCount: day.exercises.count
                ))
            }
        }

        if let wPlan = wodPlan {
            for wDay in wPlan.days where cal.isDate(wDay.date, inSameDayAs: date) && !wDay.isRestDay {
                let status: CalendarWorkoutStatus
                if wDay.isCompleted { status = .completed }
                else if isPast && !isToday { status = .missed }
                else { status = .planned }
                let typeLabel = "Functional"
                entries.append(CalendarWorkoutEntry(
                    id: wDay.id, title: wDay.template.title, date: wDay.date,
                    type: typeLabel, duration: wDay.template.durationMinutes,
                    status: status, source: .wod, exerciseCount: wDay.template.movements.count
                ))
            }
        }

        for record in completedRecords where cal.isDate(record.date, inSameDayAs: date) {
            let alreadyTracked = entries.contains { $0.title == record.title && $0.status == .completed }
            if !alreadyTracked {
                entries.append(CalendarWorkoutEntry(
                    id: record.id, title: record.title, date: record.date,
                    type: record.source.rawValue, duration: max(record.exerciseCount * 4, 15),
                    status: .completed, source: record.source, exerciseCount: record.exerciseCount
                ))
            }
        }

        return entries
    }

    func calendarDateStatus(_ date: Date) -> CalendarWorkoutStatus? {
        let entries = allCalendarEntriesForDate(date)
        if entries.isEmpty { return nil }
        if entries.allSatisfy({ $0.status == .completed }) { return .completed }
        if entries.contains(where: { $0.status == .planned }) { return .planned }
        if entries.contains(where: { $0.status == .completed }) { return .completed }
        return .missed
    }

    var todayCalendarEntryCount: Int {
        allCalendarEntriesForDate(Calendar.current.startOfDay(for: .now)).count
    }

    // MARK: - Calendar Sync Preference

    var isCalendarSyncEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "calendarSyncEnabled") }
        set {
            UserDefaults.standard.set(newValue, forKey: "calendarSyncEnabled")
        }
    }

    // MARK: - Plan Deletion

    nonisolated enum DeletablePlan: Identifiable, Sendable {
        case pt
        case functionalFitness

        var id: String {
            switch self {
            case .pt: return "pt"
            case .functionalFitness: return "wod"
            }
        }

        var label: String {
            switch self {
            case .pt: return "Training Plan"
            case .functionalFitness: return "Functional Fitness Plan"
            }
        }

        var icon: String {
            switch self {
            case .pt: return "figure.strengthtraining.traditional"
            case .functionalFitness: return "flame.fill"
            }
        }

        var calendarPrefix: String {
            switch self {
            case .pt: return "PT:"
            case .functionalFitness: return "WOD:"
            }
        }
    }

    var activePlans: [DeletablePlan] {
        var plans: [DeletablePlan] = []
        if currentPlan != nil { plans.append(.pt) }
        if wodPlan != nil { plans.append(.functionalFitness) }
        return plans
    }

    func deleteTodaysWorkout(on date: Date, calendarService: CalendarExportService) {
        let cal = Calendar.current

        if var plan = currentPlan,
           let idx = plan.days.firstIndex(where: { cal.isDate($0.date, inSameDayAs: date) && !$0.isRestDay }) {
            plan.days[idx] = WorkoutDay(
                dayIndex: plan.days[idx].dayIndex,
                date: plan.days[idx].date,
                title: "Rest Day",
                exercises: [],
                isRestDay: true,
                templateTag: "deleted"
            )
            currentPlan = plan
        }

        if var wPlan = wodPlan,
           let idx = wPlan.days.firstIndex(where: { cal.isDate($0.date, inSameDayAs: date) && !$0.isRestDay }) {
            let restTemplate = WODTemplate(
                title: "Rest & Recovery",
                category: .bodyweight,
                format: .circuit,
                durationMinutes: 0,
                equipment: .none,
                movements: [],
                workoutDescription: "Rest day"
            )
            wPlan.days[idx] = WODPlanDay(date: wPlan.days[idx].date, template: restTemplate, isRestDay: true)
            wodPlan = wPlan
        }

        calendarService.removeAllKinexaEventsOnDate(date)
        persistAll()
    }

    func deleteEntirePlan(_ plan: DeletablePlan, calendarService: CalendarExportService) {
        switch plan {
        case .pt:
            if let p = currentPlan {
                let dates = p.days.map(\.date)
                calendarService.removeAllKinexaEventsForPlan(dates: dates, prefix: plan.calendarPrefix)
            }
            currentPlan = nil

        case .functionalFitness:
            if let p = wodPlan {
                let dates = p.days.map(\.date)
                calendarService.removeAllKinexaEventsForPlan(dates: dates, prefix: plan.calendarPrefix)
            }
            wodPlan = nil
            todayFunctionalWOD = nil

        }
        persistAll()
    }

    // MARK: - Quick Start

    func saveQuickStartRecord(_ record: QuickStartRecord) {
        quickStartRecords.insert(record, at: 0)
        completedRecords.insert(
            CompletedWorkoutRecord(
                title: record.activity.rawValue,
                exerciseCount: 1,
                exercises: [],
                source: .individual
            ), at: 0
        )
        showRecap(PerformanceHighlightsService.workoutRecap(title: record.activity.rawValue, exerciseCount: 1))
        persistAll()

    }

    func exportQuickStartToCalendar(_ record: QuickStartRecord, calendarService: CalendarExportService) async -> CalendarExportService.ExportResult {
        let durationMinutes = max(record.elapsedSeconds / 60, 1)
        var notes = record.activity.rawValue
        notes += "\nDuration: \(record.formattedDuration)"
        if record.activity.usesGPS {
            notes += "\nDistance: \(record.formattedDistance)"
            notes += "\nPace: \(record.formattedPace)"
        }
        return await calendarService.resyncSingleDay(
            on: record.startDate,
            title: record.activity.rawValue,
            prefix: "Quick Start:",
            notes: notes,
            durationMinutes: durationMinutes
        )
    }

    // MARK: - Cardio Sessions

    func logCardioSession(_ session: CardioSession) {
        cardioSessions.insert(session, at: 0)
        completedRecords.insert(
            CompletedWorkoutRecord(
                title: session.workoutName,
                exerciseCount: 1,
                exercises: [],
                source: .individual
            ), at: 0
        )
        showRecap(PerformanceHighlightsService.workoutRecap(title: session.workoutName, exerciseCount: 1))
        persistAll()
    }

    var cardioSessionsThisWeek: Int {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: .now)) ?? .now
        return cardioSessions.filter { $0.date >= startOfWeek }.count
    }

    var totalCardioMinutesThisWeek: Int {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: .now)) ?? .now
        return cardioSessions.filter { $0.date >= startOfWeek }.reduce(0) { $0 + $1.durationMinutes }
    }

    func resetAllData() {
        currentPlan = nil
        completedRecords = []
        stepHistory = []
        lastWorkoutTag = ""
        importedWorkouts = []
        wodPlan = nil
        todayFunctionalWOD = nil
        cardioSessions = []
        ExerciseWeightMemory.clearAll()
        persistAll()
    }
}
