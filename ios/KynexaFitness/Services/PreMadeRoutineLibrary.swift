import Foundation

enum PreMadeRoutineLibrary {

    static let allRoutines: [PreMadeRoutine] = beginnerRoutines + intermediateRoutines + advancedRoutines

    static let beginnerRoutines: [PreMadeRoutine] = [
        PreMadeRoutine(
            name: "3 Day Full Body Basic Movements",
            routineDescription: "Three-day full-body routine centered on fundamental compound lifts for beginners.",
            splitType: .fullBody,
            level: .beginner,
            goal: .muscleBuilding,
            daysPerWeek: 3,
            durationWeeks: 8,
            equipment: "Full Gym",
            days: [
                PreMadeRoutineDay(dayName: "Day 1", focus: "Full Body A", exercises: [
                    PreMadeRoutineExercise(name: "Barbell Back Squat", sets: 3, reps: "8"),
                    PreMadeRoutineExercise(name: "Barbell Bench Press", sets: 3, reps: "10"),
                    PreMadeRoutineExercise(name: "Barbell Bent-Over Row", sets: 3, reps: "10"),
                    PreMadeRoutineExercise(name: "Overhead Press", sets: 3, reps: "10"),
                    PreMadeRoutineExercise(name: "Barbell Curl", sets: 2, reps: "12"),
                    PreMadeRoutineExercise(name: "Calf Raise", sets: 3, reps: "15"),
                ]),
                PreMadeRoutineDay(dayName: "Day 2", focus: "Full Body B", exercises: [
                    PreMadeRoutineExercise(name: "Barbell Back Squat", sets: 3, reps: "8"),
                    PreMadeRoutineExercise(name: "Incline Dumbbell Press", sets: 3, reps: "10"),
                    PreMadeRoutineExercise(name: "Lat Pulldown", sets: 3, reps: "12"),
                    PreMadeRoutineExercise(name: "Seated Dumbbell Press", sets: 3, reps: "10"),
                    PreMadeRoutineExercise(name: "Skull Crusher", sets: 3, reps: "12"),
                    PreMadeRoutineExercise(name: "Hanging Leg Raise", sets: 3, reps: "12"),
                ]),
                PreMadeRoutineDay(dayName: "Day 3", focus: "Full Body C", exercises: [
                    PreMadeRoutineExercise(name: "Barbell Back Squat", sets: 3, reps: "8"),
                    PreMadeRoutineExercise(name: "Dumbbell Bench Press", sets: 3, reps: "10"),
                    PreMadeRoutineExercise(name: "Barbell Bent-Over Row", sets: 3, reps: "10"),
                    PreMadeRoutineExercise(name: "Seated Dumbbell Press", sets: 3, reps: "10"),
                    PreMadeRoutineExercise(name: "Hammer Curl", sets: 2, reps: "12"),
                    PreMadeRoutineExercise(name: "Plank", sets: 3, reps: "45 sec"),
                ]),
            ]
        ),

        PreMadeRoutine(
            name: "3 Day Push Pull Legs",
            routineDescription: "Three-day push/pull/legs split covering the full body once per week.",
            splitType: .pushPullLegs,
            level: .beginner,
            goal: .muscleBuilding,
            daysPerWeek: 3,
            durationWeeks: 8,
            equipment: "Full Gym",
            days: [
                PreMadeRoutineDay(dayName: "Day 1", focus: "Push — Chest, Shoulders, Triceps", exercises: [
                    PreMadeRoutineExercise(name: "Barbell Bench Press", sets: 4, reps: "8"),
                    PreMadeRoutineExercise(name: "Incline Dumbbell Press", sets: 3, reps: "10"),
                    PreMadeRoutineExercise(name: "Overhead Press", sets: 3, reps: "10"),
                    PreMadeRoutineExercise(name: "Dumbbell Lateral Raise", sets: 3, reps: "15"),
                    PreMadeRoutineExercise(name: "Tricep Pushdown", sets: 3, reps: "12"),
                    PreMadeRoutineExercise(name: "Overhead Tricep Extension", sets: 3, reps: "12"),
                ]),
                PreMadeRoutineDay(dayName: "Day 2", focus: "Pull — Back, Biceps, Rear Delts", exercises: [
                    PreMadeRoutineExercise(name: "Barbell Bent-Over Row", sets: 4, reps: "8"),
                    PreMadeRoutineExercise(name: "Lat Pulldown", sets: 3, reps: "12"),
                    PreMadeRoutineExercise(name: "Seated Cable Row", sets: 3, reps: "10"),
                    PreMadeRoutineExercise(name: "Face Pull", sets: 3, reps: "15"),
                    PreMadeRoutineExercise(name: "Barbell Curl", sets: 3, reps: "10"),
                    PreMadeRoutineExercise(name: "Hammer Curl", sets: 3, reps: "12"),
                ]),
                PreMadeRoutineDay(dayName: "Day 3", focus: "Legs — Quads, Hams, Glutes, Calves", exercises: [
                    PreMadeRoutineExercise(name: "Barbell Back Squat", sets: 4, reps: "8"),
                    PreMadeRoutineExercise(name: "Romanian Deadlift", sets: 3, reps: "10"),
                    PreMadeRoutineExercise(name: "Leg Press", sets: 3, reps: "12"),
                    PreMadeRoutineExercise(name: "Leg Curl", sets: 3, reps: "12"),
                    PreMadeRoutineExercise(name: "Walking Lunges", sets: 3, reps: "12/leg"),
                    PreMadeRoutineExercise(name: "Calf Raise", sets: 4, reps: "15"),
                ]),
            ]
        ),
    ]

    static let intermediateRoutines: [PreMadeRoutine] = [
        PreMadeRoutine(
            name: "10 Week Body Part Split",
            routineDescription: "Five-day body part split with compound and isolation lifts.",
            splitType: .bodyPart,
            level: .intermediate,
            goal: .hypertrophy,
            daysPerWeek: 5,
            durationWeeks: 10,
            equipment: "Full Gym",
            days: [
                PreMadeRoutineDay(dayName: "Day 1", focus: "Chest", exercises: [
                    PreMadeRoutineExercise(name: "Barbell Bench Press", sets: 4, reps: "8"),
                    PreMadeRoutineExercise(name: "Incline Dumbbell Press", sets: 4, reps: "10"),
                    PreMadeRoutineExercise(name: "Cable Crossover", sets: 3, reps: "12"),
                    PreMadeRoutineExercise(name: "Dumbbell Fly", sets: 3, reps: "12"),
                    PreMadeRoutineExercise(name: "Push-Up", sets: 2, reps: "AMRAP"),
                ]),
                PreMadeRoutineDay(dayName: "Day 2", focus: "Back", exercises: [
                    PreMadeRoutineExercise(name: "Barbell Deadlift", sets: 5, reps: "5"),
                    PreMadeRoutineExercise(name: "Barbell Bent-Over Row", sets: 4, reps: "8"),
                    PreMadeRoutineExercise(name: "Lat Pulldown", sets: 3, reps: "12"),
                    PreMadeRoutineExercise(name: "Seated Cable Row", sets: 3, reps: "10"),
                    PreMadeRoutineExercise(name: "Face Pull", sets: 3, reps: "15"),
                ]),
                PreMadeRoutineDay(dayName: "Day 3", focus: "Shoulders & Traps", exercises: [
                    PreMadeRoutineExercise(name: "Overhead Press", sets: 4, reps: "8"),
                    PreMadeRoutineExercise(name: "Dumbbell Lateral Raise", sets: 4, reps: "15"),
                    PreMadeRoutineExercise(name: "Rear Delt Fly", sets: 3, reps: "15"),
                    PreMadeRoutineExercise(name: "Seated Dumbbell Press", sets: 3, reps: "10"),
                    PreMadeRoutineExercise(name: "Barbell Shrug", sets: 4, reps: "12"),
                ]),
                PreMadeRoutineDay(dayName: "Day 4", focus: "Legs", exercises: [
                    PreMadeRoutineExercise(name: "Barbell Back Squat", sets: 5, reps: "5"),
                    PreMadeRoutineExercise(name: "Leg Press", sets: 4, reps: "12"),
                    PreMadeRoutineExercise(name: "Romanian Deadlift", sets: 4, reps: "8"),
                    PreMadeRoutineExercise(name: "Leg Extension", sets: 3, reps: "15"),
                    PreMadeRoutineExercise(name: "Leg Curl", sets: 3, reps: "12"),
                    PreMadeRoutineExercise(name: "Calf Raise", sets: 4, reps: "15"),
                ]),
                PreMadeRoutineDay(dayName: "Day 5", focus: "Arms", exercises: [
                    PreMadeRoutineExercise(name: "Barbell Curl", sets: 4, reps: "10"),
                    PreMadeRoutineExercise(name: "Close-Grip Bench Press", sets: 4, reps: "10"),
                    PreMadeRoutineExercise(name: "Hammer Curl", sets: 3, reps: "12"),
                    PreMadeRoutineExercise(name: "Skull Crusher", sets: 3, reps: "12"),
                    PreMadeRoutineExercise(name: "Preacher Curl", sets: 3, reps: "12"),
                    PreMadeRoutineExercise(name: "Tricep Pushdown", sets: 3, reps: "15"),
                ]),
            ]
        ),

        PreMadeRoutine(
            name: "4 Day Upper Lower",
            routineDescription: "Four-day upper/lower split balancing strength and hypertrophy.",
            splitType: .upperLower,
            level: .intermediate,
            goal: .hypertrophy,
            daysPerWeek: 4,
            durationWeeks: 10,
            equipment: "Full Gym",
            days: [
                PreMadeRoutineDay(dayName: "Day 1", focus: "Upper Body — Push Emphasis", exercises: [
                    PreMadeRoutineExercise(name: "Barbell Bench Press", sets: 4, reps: "8"),
                    PreMadeRoutineExercise(name: "Incline Dumbbell Press", sets: 4, reps: "10"),
                    PreMadeRoutineExercise(name: "Overhead Press", sets: 3, reps: "10"),
                    PreMadeRoutineExercise(name: "Cable Fly", sets: 3, reps: "12"),
                    PreMadeRoutineExercise(name: "Dumbbell Lateral Raise", sets: 4, reps: "15"),
                    PreMadeRoutineExercise(name: "Skull Crusher", sets: 3, reps: "12"),
                ]),
                PreMadeRoutineDay(dayName: "Day 2", focus: "Lower Body — Quad Focus", exercises: [
                    PreMadeRoutineExercise(name: "Barbell Back Squat", sets: 4, reps: "8"),
                    PreMadeRoutineExercise(name: "Leg Press", sets: 4, reps: "12"),
                    PreMadeRoutineExercise(name: "Bulgarian Split Squat", sets: 3, reps: "10/leg"),
                    PreMadeRoutineExercise(name: "Leg Extension", sets: 3, reps: "15"),
                    PreMadeRoutineExercise(name: "Leg Curl", sets: 3, reps: "12"),
                    PreMadeRoutineExercise(name: "Calf Raise", sets: 4, reps: "15"),
                ]),
                PreMadeRoutineDay(dayName: "Day 3", focus: "Upper Body — Pull Emphasis", exercises: [
                    PreMadeRoutineExercise(name: "Barbell Bent-Over Row", sets: 4, reps: "8"),
                    PreMadeRoutineExercise(name: "Weighted Pull-Up", sets: 4, reps: "6"),
                    PreMadeRoutineExercise(name: "Seated Cable Row", sets: 3, reps: "10"),
                    PreMadeRoutineExercise(name: "Face Pull", sets: 3, reps: "15"),
                    PreMadeRoutineExercise(name: "Barbell Curl", sets: 3, reps: "10"),
                    PreMadeRoutineExercise(name: "Incline Dumbbell Curl", sets: 3, reps: "12"),
                ]),
                PreMadeRoutineDay(dayName: "Day 4", focus: "Lower Body — Posterior Focus", exercises: [
                    PreMadeRoutineExercise(name: "Barbell Deadlift", sets: 4, reps: "6"),
                    PreMadeRoutineExercise(name: "Hip Thrust", sets: 4, reps: "10"),
                    PreMadeRoutineExercise(name: "Romanian Deadlift", sets: 3, reps: "10"),
                    PreMadeRoutineExercise(name: "Leg Curl", sets: 3, reps: "12"),
                    PreMadeRoutineExercise(name: "Walking Lunges", sets: 3, reps: "12/leg"),
                    PreMadeRoutineExercise(name: "Seated Calf Raise", sets: 4, reps: "15"),
                ]),
            ]
        ),

        PreMadeRoutine(
            name: "3 Day Strength Focus Complex",
            routineDescription: "Three-day full-body plan with compound lifts and accessory work for building strength.",
            splitType: .fullBody,
            level: .intermediate,
            goal: .hypertrophy,
            daysPerWeek: 3,
            durationWeeks: 10,
            equipment: "Full Gym",
            days: [
                PreMadeRoutineDay(dayName: "Day 1", focus: "Full Body — Squat Focus", exercises: [
                    PreMadeRoutineExercise(name: "Barbell Back Squat", sets: 4, reps: "6"),
                    PreMadeRoutineExercise(name: "Barbell Bench Press", sets: 4, reps: "8"),
                    PreMadeRoutineExercise(name: "Barbell Bent-Over Row", sets: 4, reps: "8"),
                    PreMadeRoutineExercise(name: "Dumbbell Lateral Raise", sets: 3, reps: "15"),
                    PreMadeRoutineExercise(name: "Barbell Curl", sets: 3, reps: "10"),
                    PreMadeRoutineExercise(name: "Plank", sets: 3, reps: "45 sec"),
                ]),
                PreMadeRoutineDay(dayName: "Day 2", focus: "Full Body — Bench Focus", exercises: [
                    PreMadeRoutineExercise(name: "Incline Barbell Press", sets: 4, reps: "6"),
                    PreMadeRoutineExercise(name: "Front Squat", sets: 4, reps: "8"),
                    PreMadeRoutineExercise(name: "Weighted Pull-Up", sets: 4, reps: "6"),
                    PreMadeRoutineExercise(name: "Romanian Deadlift", sets: 3, reps: "10"),
                    PreMadeRoutineExercise(name: "Skull Crusher", sets: 3, reps: "12"),
                    PreMadeRoutineExercise(name: "Hanging Leg Raise", sets: 3, reps: "12"),
                ]),
                PreMadeRoutineDay(dayName: "Day 3", focus: "Full Body — Deadlift Focus", exercises: [
                    PreMadeRoutineExercise(name: "Barbell Deadlift", sets: 4, reps: "5"),
                    PreMadeRoutineExercise(name: "Overhead Press", sets: 4, reps: "8"),
                    PreMadeRoutineExercise(name: "Lat Pulldown", sets: 3, reps: "12"),
                    PreMadeRoutineExercise(name: "Dumbbell Lunges", sets: 3, reps: "10/leg"),
                    PreMadeRoutineExercise(name: "Face Pull", sets: 3, reps: "15"),
                    PreMadeRoutineExercise(name: "Hammer Curl", sets: 3, reps: "12"),
                ]),
            ]
        ),
    ]

    static let advancedRoutines: [PreMadeRoutine] = [
        PreMadeRoutine(
            name: "6 Day Push Pull Legs",
            routineDescription: "Six-day push/pull/legs split training each muscle group twice per week.",
            splitType: .pushPullLegs,
            level: .advanced,
            goal: .hypertrophy,
            daysPerWeek: 6,
            durationWeeks: 10,
            equipment: "Full Gym",
            days: [
                PreMadeRoutineDay(dayName: "Day 1", focus: "Push A — Heavy", exercises: [
                    PreMadeRoutineExercise(name: "Barbell Bench Press", sets: 4, reps: "6"),
                    PreMadeRoutineExercise(name: "Overhead Press", sets: 4, reps: "6"),
                    PreMadeRoutineExercise(name: "Incline Dumbbell Press", sets: 3, reps: "10"),
                    PreMadeRoutineExercise(name: "Dumbbell Lateral Raise", sets: 4, reps: "15"),
                    PreMadeRoutineExercise(name: "Tricep Dip", sets: 3, reps: "AMRAP"),
                    PreMadeRoutineExercise(name: "Overhead Tricep Extension", sets: 3, reps: "12"),
                ]),
                PreMadeRoutineDay(dayName: "Day 2", focus: "Pull A — Heavy", exercises: [
                    PreMadeRoutineExercise(name: "Barbell Deadlift", sets: 4, reps: "5"),
                    PreMadeRoutineExercise(name: "Barbell Bent-Over Row", sets: 4, reps: "6"),
                    PreMadeRoutineExercise(name: "Lat Pulldown", sets: 3, reps: "10"),
                    PreMadeRoutineExercise(name: "Face Pull", sets: 3, reps: "15"),
                    PreMadeRoutineExercise(name: "Barbell Curl", sets: 3, reps: "10"),
                    PreMadeRoutineExercise(name: "Hammer Curl", sets: 3, reps: "12"),
                ]),
                PreMadeRoutineDay(dayName: "Day 3", focus: "Legs A — Heavy", exercises: [
                    PreMadeRoutineExercise(name: "Barbell Back Squat", sets: 4, reps: "6"),
                    PreMadeRoutineExercise(name: "Romanian Deadlift", sets: 4, reps: "8"),
                    PreMadeRoutineExercise(name: "Leg Press", sets: 3, reps: "10"),
                    PreMadeRoutineExercise(name: "Leg Curl", sets: 3, reps: "10"),
                    PreMadeRoutineExercise(name: "Walking Lunges", sets: 3, reps: "10/leg"),
                    PreMadeRoutineExercise(name: "Calf Raise", sets: 4, reps: "15"),
                ]),
                PreMadeRoutineDay(dayName: "Day 4", focus: "Push B — Volume", exercises: [
                    PreMadeRoutineExercise(name: "Incline Barbell Press", sets: 4, reps: "10"),
                    PreMadeRoutineExercise(name: "Dumbbell Bench Press", sets: 3, reps: "12"),
                    PreMadeRoutineExercise(name: "Cable Fly", sets: 3, reps: "15"),
                    PreMadeRoutineExercise(name: "Seated Dumbbell Press", sets: 3, reps: "10"),
                    PreMadeRoutineExercise(name: "Cable Lateral Raise", sets: 3, reps: "15"),
                    PreMadeRoutineExercise(name: "Tricep Pushdown", sets: 3, reps: "15"),
                ]),
                PreMadeRoutineDay(dayName: "Day 5", focus: "Pull B — Volume", exercises: [
                    PreMadeRoutineExercise(name: "Pull-Up", sets: 4, reps: "AMRAP"),
                    PreMadeRoutineExercise(name: "Seated Cable Row", sets: 4, reps: "12"),
                    PreMadeRoutineExercise(name: "Dumbbell Single-Arm Row", sets: 3, reps: "10/side"),
                    PreMadeRoutineExercise(name: "Rear Delt Fly", sets: 3, reps: "15"),
                    PreMadeRoutineExercise(name: "EZ Bar Curl", sets: 3, reps: "12"),
                    PreMadeRoutineExercise(name: "Incline Dumbbell Curl", sets: 3, reps: "12"),
                ]),
                PreMadeRoutineDay(dayName: "Day 6", focus: "Legs B — Volume", exercises: [
                    PreMadeRoutineExercise(name: "Front Squat", sets: 4, reps: "8"),
                    PreMadeRoutineExercise(name: "Bulgarian Split Squat", sets: 3, reps: "12/leg"),
                    PreMadeRoutineExercise(name: "Leg Extension", sets: 3, reps: "15"),
                    PreMadeRoutineExercise(name: "Leg Curl", sets: 3, reps: "15"),
                    PreMadeRoutineExercise(name: "Hip Thrust", sets: 3, reps: "12"),
                    PreMadeRoutineExercise(name: "Seated Calf Raise", sets: 4, reps: "15"),
                ]),
            ]
        ),

        PreMadeRoutine(
            name: "4 Day Volume Training",
            routineDescription: "Four-day 10x10 volume program for advanced lifters.",
            splitType: .upperLower,
            level: .advanced,
            goal: .hypertrophy,
            daysPerWeek: 4,
            durationWeeks: 6,
            equipment: "Full Gym",
            days: [
                PreMadeRoutineDay(dayName: "Day 1", focus: "Chest & Back", exercises: [
                    PreMadeRoutineExercise(name: "Barbell Bench Press", sets: 10, reps: "10", notes: "60% 1RM — 60 sec rest"),
                    PreMadeRoutineExercise(name: "Barbell Bent-Over Row", sets: 10, reps: "10", notes: "60% 1RM — 60 sec rest"),
                    PreMadeRoutineExercise(name: "Dumbbell Fly", sets: 3, reps: "12"),
                    PreMadeRoutineExercise(name: "Lat Pulldown", sets: 3, reps: "12"),
                ]),
                PreMadeRoutineDay(dayName: "Day 2", focus: "Legs & Abs", exercises: [
                    PreMadeRoutineExercise(name: "Barbell Back Squat", sets: 10, reps: "10", notes: "60% 1RM — 60 sec rest"),
                    PreMadeRoutineExercise(name: "Leg Curl", sets: 10, reps: "10", notes: "60 sec rest"),
                    PreMadeRoutineExercise(name: "Calf Raise", sets: 3, reps: "15"),
                    PreMadeRoutineExercise(name: "Hanging Leg Raise", sets: 3, reps: "12"),
                ]),
                PreMadeRoutineDay(dayName: "Day 3", focus: "Shoulders & Arms", exercises: [
                    PreMadeRoutineExercise(name: "Overhead Press", sets: 10, reps: "10", notes: "60% 1RM — 60 sec rest"),
                    PreMadeRoutineExercise(name: "Barbell Curl", sets: 10, reps: "10", notes: "60 sec rest"),
                    PreMadeRoutineExercise(name: "Dumbbell Lateral Raise", sets: 3, reps: "15"),
                    PreMadeRoutineExercise(name: "Tricep Pushdown", sets: 3, reps: "12"),
                ]),
                PreMadeRoutineDay(dayName: "Day 4", focus: "Legs & Back", exercises: [
                    PreMadeRoutineExercise(name: "Romanian Deadlift", sets: 10, reps: "10", notes: "60% 1RM — 60 sec rest"),
                    PreMadeRoutineExercise(name: "Lat Pulldown", sets: 10, reps: "10", notes: "60 sec rest"),
                    PreMadeRoutineExercise(name: "Leg Extension", sets: 3, reps: "15"),
                    PreMadeRoutineExercise(name: "Face Pull", sets: 3, reps: "15"),
                ]),
            ]
        ),

        PreMadeRoutine(
            name: "5 Day Body Part Split",
            routineDescription: "Five-day split training one major muscle group per session for maximum volume.",
            splitType: .bodyPart,
            level: .advanced,
            goal: .hypertrophy,
            daysPerWeek: 5,
            durationWeeks: 8,
            equipment: "Full Gym",
            days: [
                PreMadeRoutineDay(dayName: "Day 1", focus: "Chest", exercises: [
                    PreMadeRoutineExercise(name: "Barbell Bench Press", sets: 4, reps: "8"),
                    PreMadeRoutineExercise(name: "Incline Dumbbell Press", sets: 4, reps: "10"),
                    PreMadeRoutineExercise(name: "Cable Fly", sets: 3, reps: "12"),
                    PreMadeRoutineExercise(name: "Dumbbell Fly", sets: 3, reps: "12"),
                    PreMadeRoutineExercise(name: "Push-Up", sets: 2, reps: "AMRAP"),
                ]),
                PreMadeRoutineDay(dayName: "Day 2", focus: "Back", exercises: [
                    PreMadeRoutineExercise(name: "Barbell Deadlift", sets: 4, reps: "6"),
                    PreMadeRoutineExercise(name: "Pull-Up", sets: 4, reps: "AMRAP"),
                    PreMadeRoutineExercise(name: "Barbell Bent-Over Row", sets: 4, reps: "8"),
                    PreMadeRoutineExercise(name: "Lat Pulldown", sets: 3, reps: "12"),
                    PreMadeRoutineExercise(name: "Seated Cable Row", sets: 3, reps: "10"),
                ]),
                PreMadeRoutineDay(dayName: "Day 3", focus: "Shoulders", exercises: [
                    PreMadeRoutineExercise(name: "Overhead Press", sets: 4, reps: "8"),
                    PreMadeRoutineExercise(name: "Dumbbell Lateral Raise", sets: 4, reps: "15"),
                    PreMadeRoutineExercise(name: "Seated Dumbbell Press", sets: 3, reps: "10"),
                    PreMadeRoutineExercise(name: "Rear Delt Fly", sets: 3, reps: "15"),
                    PreMadeRoutineExercise(name: "Face Pull", sets: 3, reps: "15"),
                ]),
                PreMadeRoutineDay(dayName: "Day 4", focus: "Legs", exercises: [
                    PreMadeRoutineExercise(name: "Barbell Back Squat", sets: 5, reps: "6"),
                    PreMadeRoutineExercise(name: "Leg Press", sets: 4, reps: "12"),
                    PreMadeRoutineExercise(name: "Romanian Deadlift", sets: 3, reps: "10"),
                    PreMadeRoutineExercise(name: "Leg Extension", sets: 3, reps: "15"),
                    PreMadeRoutineExercise(name: "Leg Curl", sets: 3, reps: "12"),
                    PreMadeRoutineExercise(name: "Calf Raise", sets: 4, reps: "15"),
                ]),
                PreMadeRoutineDay(dayName: "Day 5", focus: "Arms", exercises: [
                    PreMadeRoutineExercise(name: "Barbell Curl", sets: 4, reps: "10"),
                    PreMadeRoutineExercise(name: "Close-Grip Bench Press", sets: 4, reps: "10"),
                    PreMadeRoutineExercise(name: "EZ Bar Curl", sets: 3, reps: "12"),
                    PreMadeRoutineExercise(name: "Skull Crusher", sets: 3, reps: "12"),
                    PreMadeRoutineExercise(name: "Hammer Curl", sets: 3, reps: "12"),
                    PreMadeRoutineExercise(name: "Tricep Pushdown", sets: 3, reps: "15"),
                ]),
            ]
        ),
    ]

    static func routines(for splitType: RoutineSplitType) -> [PreMadeRoutine] {
        allRoutines.filter { $0.splitType == splitType }
    }

    static func routines(for level: RoutineLevel) -> [PreMadeRoutine] {
        allRoutines.filter { $0.level == level }
    }

    static func search(_ query: String) -> [PreMadeRoutine] {
        guard !query.isEmpty else { return allRoutines }
        return allRoutines.filter {
            $0.name.localizedStandardContains(query) ||
            $0.routineDescription.localizedStandardContains(query) ||
            $0.splitType.rawValue.localizedStandardContains(query)
        }
    }
}
