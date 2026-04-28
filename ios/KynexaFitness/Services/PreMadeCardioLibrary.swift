import Foundation

enum PreMadeCardioLibrary {

    static let allPrograms: [PreMadeCardioProgram] = treadmillPrograms + machinePrograms + runningPrograms + sprintingPrograms

    static func programs(for type: CardioProgramType) -> [PreMadeCardioProgram] {
        allPrograms.filter { $0.programType == type }
    }

    static var beginnerPrograms: [PreMadeCardioProgram] {
        allPrograms.filter { $0.level == .beginner || $0.level == .allLevels }
    }

    static var intermediatePrograms: [PreMadeCardioProgram] {
        allPrograms.filter { $0.level == .intermediate }
    }

    static var advancedPrograms: [PreMadeCardioProgram] {
        allPrograms.filter { $0.level == .advanced }
    }

    static func programs(for level: CardioProgramLevel) -> [PreMadeCardioProgram] {
        switch level {
        case .beginner: return beginnerPrograms
        case .intermediate: return intermediatePrograms
        case .advanced: return advancedPrograms
        case .allLevels: return allPrograms
        }
    }

    static func search(_ query: String) -> [PreMadeCardioProgram] {
        allPrograms.filter {
            $0.name.localizedStandardContains(query) ||
            $0.programDescription.localizedStandardContains(query) ||
            $0.programType.rawValue.localizedStandardContains(query)
        }
    }

    // MARK: - Treadmill Programs

    static let treadmillPrograms: [PreMadeCardioProgram] = [
        PreMadeCardioProgram(
            name: "Treadmill Workout",
            programDescription: "Three-day treadmill program with incline walks, sprints, and tempo runs.",
            programType: .treadmill,
            level: .intermediate,
            goal: .fatLoss,
            daysPerWeek: 3,
            durationWeeks: 6,
            equipment: "Treadmill",
            days: [
                CardioProgramDay(dayName: "Day 1", focus: "Incline Power Walk", steps: [
                    CardioSessionStep(name: "Warm-Up Walk", duration: "5 min", intensity: "3.5 mph / 0% incline"),
                    CardioSessionStep(name: "Incline Walk", duration: "3 min", intensity: "3.8 mph / 10% incline"),
                    CardioSessionStep(name: "Flat Recovery", duration: "1 min", intensity: "3.5 mph / 0% incline"),
                    CardioSessionStep(name: "Steep Incline Walk", duration: "3 min", intensity: "3.5 mph / 15% incline"),
                    CardioSessionStep(name: "Flat Recovery", duration: "1 min", intensity: "3.5 mph / 0% incline"),
                    CardioSessionStep(name: "Repeat 3x", duration: "", intensity: "", notes: "Total ~25 min"),
                    CardioSessionStep(name: "Cool Down", duration: "5 min", intensity: "3.0 mph / 0%"),
                ]),
                CardioProgramDay(dayName: "Day 2", focus: "Sprint Intervals", steps: [
                    CardioSessionStep(name: "Warm-Up Jog", duration: "5 min", intensity: "5.5 mph"),
                    CardioSessionStep(name: "Sprint", duration: "30 sec", intensity: "9-10 mph"),
                    CardioSessionStep(name: "Walk Recovery", duration: "90 sec", intensity: "3.5 mph"),
                    CardioSessionStep(name: "Repeat 8-10x", duration: "", intensity: "", notes: "~20 min of intervals"),
                    CardioSessionStep(name: "Cool Down", duration: "5 min", intensity: "3.0 mph"),
                ]),
                CardioProgramDay(dayName: "Day 3", focus: "Tempo Run", steps: [
                    CardioSessionStep(name: "Warm-Up Jog", duration: "5 min", intensity: "5.5 mph"),
                    CardioSessionStep(name: "Tempo Pace", duration: "15 min", intensity: "7.0-8.0 mph"),
                    CardioSessionStep(name: "Recovery Jog", duration: "3 min", intensity: "5.0 mph"),
                    CardioSessionStep(name: "Tempo Pace", duration: "5 min", intensity: "7.5-8.5 mph"),
                    CardioSessionStep(name: "Cool Down Walk", duration: "5 min", intensity: "3.0 mph"),
                ]),
            ]
        ),

        PreMadeCardioProgram(
            name: "Advanced Treadmill Program",
            programDescription: "Three-day advanced treadmill program with pyramid sprints, incline intervals, and endurance runs.",
            programType: .treadmill,
            level: .advanced,
            goal: .fatLoss,
            daysPerWeek: 3,
            durationWeeks: 8,
            equipment: "Treadmill",
            days: [
                CardioProgramDay(dayName: "Day 1", focus: "Pyramid Sprints", steps: [
                    CardioSessionStep(name: "Warm-Up", duration: "5 min", intensity: "5.0 mph"),
                    CardioSessionStep(name: "Sprint 30 sec → Walk 30 sec", duration: "", intensity: "9 mph"),
                    CardioSessionStep(name: "Sprint 45 sec → Walk 45 sec", duration: "", intensity: "9 mph"),
                    CardioSessionStep(name: "Sprint 60 sec → Walk 60 sec", duration: "", intensity: "8.5 mph"),
                    CardioSessionStep(name: "Sprint 45 sec → Walk 45 sec", duration: "", intensity: "9 mph"),
                    CardioSessionStep(name: "Sprint 30 sec → Walk 30 sec", duration: "", intensity: "9.5 mph"),
                    CardioSessionStep(name: "Repeat pyramid 2-3x", duration: "", intensity: ""),
                    CardioSessionStep(name: "Cool Down", duration: "5 min", intensity: "3.0 mph"),
                ]),
                CardioProgramDay(dayName: "Day 2", focus: "Incline Intervals", steps: [
                    CardioSessionStep(name: "Warm-Up", duration: "5 min", intensity: "3.5 mph / 0%"),
                    CardioSessionStep(name: "6.0 mph / 6% incline", duration: "2 min", intensity: "Hard"),
                    CardioSessionStep(name: "3.5 mph / 0% incline", duration: "1 min", intensity: "Recovery"),
                    CardioSessionStep(name: "6.0 mph / 8% incline", duration: "2 min", intensity: "Hard"),
                    CardioSessionStep(name: "3.5 mph / 0% incline", duration: "1 min", intensity: "Recovery"),
                    CardioSessionStep(name: "6.0 mph / 10% incline", duration: "2 min", intensity: "Very Hard"),
                    CardioSessionStep(name: "Repeat 3x", duration: "", intensity: ""),
                    CardioSessionStep(name: "Cool Down", duration: "5 min", intensity: "3.0 mph"),
                ]),
                CardioProgramDay(dayName: "Day 3", focus: "Steady-State Endurance", steps: [
                    CardioSessionStep(name: "Warm-Up", duration: "5 min", intensity: "5.0 mph"),
                    CardioSessionStep(name: "Sustained Run", duration: "25 min", intensity: "6.5-7.0 mph", notes: "Keep heart rate 70-80% max"),
                    CardioSessionStep(name: "Cool Down", duration: "5 min", intensity: "3.5 mph"),
                ]),
            ]
        ),
    ]

    // MARK: - Machine Programs

    static let machinePrograms: [PreMadeCardioProgram] = [
        PreMadeCardioProgram(
            name: "Multi-Machine Cardio Workout",
            programDescription: "Four different cardio machine workouts rotating between treadmill, bike, elliptical, and rower.",
            programType: .machine,
            level: .intermediate,
            goal: .fatLoss,
            daysPerWeek: 2,
            durationWeeks: 8,
            equipment: "Cardio Machines",
            days: [
                CardioProgramDay(dayName: "Workout A", focus: "Treadmill Intervals", steps: [
                    CardioSessionStep(name: "Warm-Up Walk", duration: "5 min", intensity: "3.5 mph"),
                    CardioSessionStep(name: "Run", duration: "2 min", intensity: "7.0 mph"),
                    CardioSessionStep(name: "Walk", duration: "1 min", intensity: "3.5 mph"),
                    CardioSessionStep(name: "Repeat 6-8x", duration: "", intensity: ""),
                    CardioSessionStep(name: "Cool Down", duration: "5 min", intensity: "3.0 mph"),
                ]),
                CardioProgramDay(dayName: "Workout B", focus: "Bike Intervals", steps: [
                    CardioSessionStep(name: "Easy Pedal", duration: "5 min", intensity: "Low resistance"),
                    CardioSessionStep(name: "Sprint Pedal", duration: "30 sec", intensity: "High resistance"),
                    CardioSessionStep(name: "Easy Pedal", duration: "90 sec", intensity: "Low resistance"),
                    CardioSessionStep(name: "Repeat 10x", duration: "", intensity: ""),
                    CardioSessionStep(name: "Cool Down", duration: "5 min", intensity: "Low"),
                ]),
                CardioProgramDay(dayName: "Workout C", focus: "Elliptical Steady State", steps: [
                    CardioSessionStep(name: "Warm-Up", duration: "5 min", intensity: "Easy"),
                    CardioSessionStep(name: "Moderate Pace", duration: "20 min", intensity: "RPE 6-7", notes: "Keep heart rate 65-75% max"),
                    CardioSessionStep(name: "Cool Down", duration: "5 min", intensity: "Easy"),
                ]),
                CardioProgramDay(dayName: "Workout D", focus: "Rowing Intervals", steps: [
                    CardioSessionStep(name: "Easy Row", duration: "5 min", intensity: "18-20 strokes/min"),
                    CardioSessionStep(name: "Power Row", duration: "250m", intensity: "Max effort"),
                    CardioSessionStep(name: "Easy Row", duration: "250m", intensity: "Recovery"),
                    CardioSessionStep(name: "Repeat 6-8x", duration: "", intensity: ""),
                    CardioSessionStep(name: "Cool Down", duration: "5 min", intensity: "Easy"),
                ]),
            ]
        ),

        PreMadeCardioProgram(
            name: "Post-Workout Cardio Finisher",
            programDescription: "Short cardio finishers to add after weight training sessions.",
            programType: .machine,
            level: .allLevels,
            goal: .fatLoss,
            daysPerWeek: 3,
            durationWeeks: 6,
            equipment: "Cardio Machines",
            days: [
                CardioProgramDay(dayName: "Day 1", focus: "15-Min Rower", steps: [
                    CardioSessionStep(name: "Easy Row", duration: "3 min", intensity: "Warm-Up"),
                    CardioSessionStep(name: "500m Sprint Row", duration: "~2 min", intensity: "Max"),
                    CardioSessionStep(name: "Easy Row", duration: "1 min", intensity: "Recovery"),
                    CardioSessionStep(name: "Repeat 3x", duration: "", intensity: ""),
                    CardioSessionStep(name: "Cool Down", duration: "3 min", intensity: "Easy"),
                ]),
                CardioProgramDay(dayName: "Day 2", focus: "10-Min Bike", steps: [
                    CardioSessionStep(name: "Easy Pedal", duration: "2 min", intensity: "Warm-Up"),
                    CardioSessionStep(name: "Max Effort Sprint", duration: "20 sec", intensity: "Max"),
                    CardioSessionStep(name: "Easy Pedal", duration: "40 sec", intensity: "Recovery"),
                    CardioSessionStep(name: "Repeat 8x", duration: "", intensity: ""),
                    CardioSessionStep(name: "Cool Down", duration: "2 min", intensity: "Easy"),
                ]),
                CardioProgramDay(dayName: "Day 3", focus: "15-Min Incline Walk", steps: [
                    CardioSessionStep(name: "Flat Walk", duration: "3 min", intensity: "3.5 mph / 0%"),
                    CardioSessionStep(name: "Incline Walk", duration: "2 min", intensity: "3.5 mph / 12%"),
                    CardioSessionStep(name: "Flat Walk", duration: "1 min", intensity: "3.5 mph / 0%"),
                    CardioSessionStep(name: "Repeat 3x", duration: "", intensity: ""),
                    CardioSessionStep(name: "Cool Down", duration: "3 min", intensity: "Easy"),
                ]),
            ]
        ),
    ]

    // MARK: - Running Programs

    static let runningPrograms: [PreMadeCardioProgram] = [
        PreMadeCardioProgram(
            name: "Beginner 5K Running Plan",
            programDescription: "Eight-week plan progressing from walk/run intervals to continuous running.",
            programType: .running,
            level: .beginner,
            goal: .endurance,
            daysPerWeek: 3,
            durationWeeks: 8,
            equipment: "Running Shoes",
            days: [
                CardioProgramDay(dayName: "Week 1-2", focus: "Walk/Run Intervals", steps: [
                    CardioSessionStep(name: "Warm-Up Walk", duration: "5 min", intensity: "Easy"),
                    CardioSessionStep(name: "Run", duration: "60 sec", intensity: "Easy jog"),
                    CardioSessionStep(name: "Walk", duration: "90 sec", intensity: "Brisk walk"),
                    CardioSessionStep(name: "Repeat 8x", duration: "~25 min total", intensity: ""),
                    CardioSessionStep(name: "Cool Down Walk", duration: "5 min", intensity: "Easy"),
                ]),
                CardioProgramDay(dayName: "Week 3-4", focus: "Extended Run Intervals", steps: [
                    CardioSessionStep(name: "Warm-Up Walk", duration: "5 min", intensity: "Easy"),
                    CardioSessionStep(name: "Run", duration: "3 min", intensity: "Easy jog"),
                    CardioSessionStep(name: "Walk", duration: "90 sec", intensity: "Brisk walk"),
                    CardioSessionStep(name: "Run", duration: "5 min", intensity: "Easy jog"),
                    CardioSessionStep(name: "Walk", duration: "2.5 min", intensity: "Brisk walk"),
                    CardioSessionStep(name: "Repeat pattern", duration: "~28 min total", intensity: ""),
                    CardioSessionStep(name: "Cool Down Walk", duration: "5 min", intensity: "Easy"),
                ]),
                CardioProgramDay(dayName: "Week 5-8", focus: "Continuous Running", steps: [
                    CardioSessionStep(name: "Warm-Up Walk", duration: "5 min", intensity: "Easy"),
                    CardioSessionStep(name: "Continuous Run", duration: "20-30 min", intensity: "Conversational pace", notes: "Add 2-3 min each week"),
                    CardioSessionStep(name: "Cool Down Walk", duration: "5 min", intensity: "Easy"),
                ]),
            ]
        ),

        PreMadeCardioProgram(
            name: "10K Training Plan",
            programDescription: "Ten-week plan with easy runs, tempo work, intervals, and long runs.",
            programType: .running,
            level: .intermediate,
            goal: .endurance,
            daysPerWeek: 4,
            durationWeeks: 10,
            equipment: "Running Shoes",
            days: [
                CardioProgramDay(dayName: "Day 1", focus: "Easy Run", steps: [
                    CardioSessionStep(name: "Easy Pace Run", duration: "30-40 min", intensity: "Conversational pace"),
                    CardioSessionStep(name: "Cool Down Walk", duration: "5 min", intensity: "Easy"),
                ]),
                CardioProgramDay(dayName: "Day 2", focus: "Tempo Run", steps: [
                    CardioSessionStep(name: "Warm-Up Jog", duration: "10 min", intensity: "Easy"),
                    CardioSessionStep(name: "Tempo Pace", duration: "20 min", intensity: "Comfortably hard"),
                    CardioSessionStep(name: "Cool Down Jog", duration: "10 min", intensity: "Easy"),
                ]),
                CardioProgramDay(dayName: "Day 3", focus: "Interval Training", steps: [
                    CardioSessionStep(name: "Warm-Up Jog", duration: "10 min", intensity: "Easy"),
                    CardioSessionStep(name: "800m at 5K pace", duration: "~4 min", intensity: "Hard"),
                    CardioSessionStep(name: "400m Recovery Jog", duration: "~2 min", intensity: "Easy"),
                    CardioSessionStep(name: "Repeat 4-6x", duration: "", intensity: ""),
                    CardioSessionStep(name: "Cool Down Jog", duration: "10 min", intensity: "Easy"),
                ]),
                CardioProgramDay(dayName: "Day 4", focus: "Long Run", steps: [
                    CardioSessionStep(name: "Long Slow Run", duration: "45-70 min", intensity: "Easy pace", notes: "Add 5-10 min each week"),
                ]),
            ]
        ),

        PreMadeCardioProgram(
            name: "2-Mile Run Plan",
            programDescription: "Eight-week plan for improving 2-mile run time with speed work and endurance.",
            programType: .running,
            level: .intermediate,
            goal: .speed,
            daysPerWeek: 4,
            durationWeeks: 8,
            equipment: "Running Shoes / Track",
            days: [
                CardioProgramDay(dayName: "Day 1", focus: "Speed Repeats", steps: [
                    CardioSessionStep(name: "Warm-Up Jog", duration: "10 min", intensity: "Easy"),
                    CardioSessionStep(name: "400m at goal pace", duration: "", intensity: "Hard"),
                    CardioSessionStep(name: "200m Recovery Jog", duration: "", intensity: "Easy"),
                    CardioSessionStep(name: "Repeat 6-8x", duration: "", intensity: ""),
                    CardioSessionStep(name: "Cool Down Jog", duration: "10 min", intensity: "Easy"),
                ]),
                CardioProgramDay(dayName: "Day 2", focus: "Easy Recovery Run", steps: [
                    CardioSessionStep(name: "Easy Jog", duration: "25-30 min", intensity: "Conversational"),
                ]),
                CardioProgramDay(dayName: "Day 3", focus: "Tempo Run", steps: [
                    CardioSessionStep(name: "Warm-Up", duration: "10 min", intensity: "Easy"),
                    CardioSessionStep(name: "Tempo (slightly slower than goal pace)", duration: "15-20 min", intensity: "Comfortably hard"),
                    CardioSessionStep(name: "Cool Down", duration: "10 min", intensity: "Easy"),
                ]),
                CardioProgramDay(dayName: "Day 4", focus: "Long Run", steps: [
                    CardioSessionStep(name: "Easy Long Run", duration: "35-45 min", intensity: "Easy", notes: "Build aerobic base"),
                ]),
            ]
        ),
    ]

    // MARK: - Sprint Programs

    static let sprintingPrograms: [PreMadeCardioProgram] = [
        PreMadeCardioProgram(
            name: "Hill Sprint Program",
            programDescription: "Eight-week progressive hill sprint program for speed and power.",
            programType: .sprinting,
            level: .beginner,
            goal: .speed,
            daysPerWeek: 2,
            durationWeeks: 8,
            equipment: "Hill / Incline",
            days: [
                CardioProgramDay(dayName: "Day 1", focus: "Hill Sprints A", steps: [
                    CardioSessionStep(name: "Warm-Up Jog", duration: "10 min", intensity: "Easy"),
                    CardioSessionStep(name: "Hill Sprint (30-40m)", duration: "~10 sec", intensity: "85-90%"),
                    CardioSessionStep(name: "Walk Down Recovery", duration: "~60 sec", intensity: "Easy"),
                    CardioSessionStep(name: "Wks 1-2: 4 sprints, Wks 3-4: 6, Wks 5-6: 8, Wks 7-8: 10", duration: "", intensity: ""),
                    CardioSessionStep(name: "Cool Down Jog", duration: "10 min", intensity: "Easy"),
                ]),
                CardioProgramDay(dayName: "Day 2", focus: "Hill Sprints B", steps: [
                    CardioSessionStep(name: "Warm-Up Jog", duration: "10 min", intensity: "Easy"),
                    CardioSessionStep(name: "Hill Sprint (50-60m)", duration: "~15 sec", intensity: "80%"),
                    CardioSessionStep(name: "Walk Down Recovery", duration: "~90 sec", intensity: "Easy"),
                    CardioSessionStep(name: "Same progression as Day 1", duration: "", intensity: ""),
                    CardioSessionStep(name: "Cool Down Jog", duration: "10 min", intensity: "Easy"),
                ]),
            ]
        ),

        PreMadeCardioProgram(
            name: "Track Sprint Program",
            programDescription: "Six-week structured sprint program with short sprints, speed endurance, and tempo work.",
            programType: .sprinting,
            level: .advanced,
            goal: .speed,
            daysPerWeek: 3,
            durationWeeks: 6,
            equipment: "Track / Flat Surface",
            days: [
                CardioProgramDay(dayName: "Day 1", focus: "Short Sprints (Acceleration)", steps: [
                    CardioSessionStep(name: "Dynamic Warm-Up", duration: "15 min", intensity: "Progressive"),
                    CardioSessionStep(name: "40m Sprint from standing", duration: "6x", intensity: "95-100%"),
                    CardioSessionStep(name: "Walk-back Recovery", duration: "2-3 min between", intensity: "Full recovery"),
                    CardioSessionStep(name: "60m Sprint", duration: "4x", intensity: "95%"),
                    CardioSessionStep(name: "Full Recovery between reps", duration: "3 min", intensity: ""),
                    CardioSessionStep(name: "Cool Down Jog + Stretch", duration: "10 min", intensity: "Easy"),
                ]),
                CardioProgramDay(dayName: "Day 2", focus: "Speed Endurance", steps: [
                    CardioSessionStep(name: "Dynamic Warm-Up", duration: "15 min", intensity: "Progressive"),
                    CardioSessionStep(name: "200m Sprint", duration: "4x", intensity: "90%"),
                    CardioSessionStep(name: "Rest", duration: "3 min between", intensity: ""),
                    CardioSessionStep(name: "300m Sprint", duration: "2x", intensity: "85%"),
                    CardioSessionStep(name: "Rest", duration: "5 min between", intensity: ""),
                    CardioSessionStep(name: "Cool Down Jog + Stretch", duration: "10 min", intensity: "Easy"),
                ]),
                CardioProgramDay(dayName: "Day 3", focus: "Flying Sprints & Tempo", steps: [
                    CardioSessionStep(name: "Dynamic Warm-Up", duration: "15 min", intensity: "Progressive"),
                    CardioSessionStep(name: "Flying 30m (build-up + 30m max)", duration: "4x", intensity: "100%"),
                    CardioSessionStep(name: "Full Recovery", duration: "3 min", intensity: ""),
                    CardioSessionStep(name: "Tempo 200m", duration: "6x", intensity: "70-75%", notes: "Smooth and relaxed"),
                    CardioSessionStep(name: "200m Walk Recovery between", duration: "", intensity: ""),
                    CardioSessionStep(name: "Cool Down Jog + Stretch", duration: "10 min", intensity: "Easy"),
                ]),
            ]
        ),
    ]
}
