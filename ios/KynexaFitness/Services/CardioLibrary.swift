import Foundation

enum CardioLibrary {

    static let allWorkouts: [CardioWorkoutDefinition] = running + cycling + classWorkouts + lowImpact + hiit + outdoor

    static let running: [CardioWorkoutDefinition] = [
        CardioWorkoutDefinition(
            name: "Outdoor Run",
            category: .running, icon: "figure.run",
            description: "Steady-state outdoor running at your own pace",
            estimatedCaloriesPerMinute: 10, difficultyLevel: "Moderate",
            isDistanceBased: true, usesGPS: true
        ),
        CardioWorkoutDefinition(
            name: "Treadmill Run",
            category: .running, icon: "figure.run.treadmill",
            description: "Indoor treadmill run with controlled speed and incline",
            estimatedCaloriesPerMinute: 9, difficultyLevel: "Moderate"
        ),
        CardioWorkoutDefinition(
            name: "Sprints",
            category: .running, icon: "figure.run",
            description: "Short burst all-out sprints with rest intervals",
            estimatedCaloriesPerMinute: 14, difficultyLevel: "Hard"
        ),
        CardioWorkoutDefinition(
            name: "Interval Run",
            category: .running, icon: "figure.run",
            description: "Alternate between fast and recovery pace segments",
            estimatedCaloriesPerMinute: 11, difficultyLevel: "Moderate"
        ),
        CardioWorkoutDefinition(
            name: "Fartlek Run",
            category: .running, icon: "figure.run",
            description: "Unstructured speed play — vary pace by feel throughout the run",
            estimatedCaloriesPerMinute: 11, difficultyLevel: "Moderate",
            isDistanceBased: true, usesGPS: true
        ),
        CardioWorkoutDefinition(
            name: "Tempo Run",
            category: .running, icon: "figure.run",
            description: "Sustained effort at comfortably hard pace to build lactate threshold",
            estimatedCaloriesPerMinute: 10, difficultyLevel: "Hard",
            isDistanceBased: true, usesGPS: true
        ),
        CardioWorkoutDefinition(
            name: "Long Run",
            category: .running, icon: "figure.run",
            description: "Extended easy-pace run to build aerobic endurance",
            estimatedCaloriesPerMinute: 9, difficultyLevel: "Moderate",
            isDistanceBased: true, usesGPS: true
        ),
        CardioWorkoutDefinition(
            name: "Hill Repeats",
            category: .running, icon: "figure.run",
            description: "Repeated uphill sprints for power and leg strength",
            estimatedCaloriesPerMinute: 13, difficultyLevel: "Hard",
            usesGPS: true
        ),
        CardioWorkoutDefinition(
            name: "Track Workout",
            category: .running, icon: "figure.run",
            description: "Structured intervals on a track — 200s, 400s, 800s, or mile repeats",
            estimatedCaloriesPerMinute: 12, difficultyLevel: "Hard"
        ),
        CardioWorkoutDefinition(
            name: "Easy Recovery Run",
            category: .running, icon: "figure.run",
            description: "Light jog at conversational pace for active recovery",
            estimatedCaloriesPerMinute: 7, difficultyLevel: "Easy",
            isDistanceBased: true, usesGPS: true
        ),
        CardioWorkoutDefinition(
            name: "Couch to 5K",
            category: .running, icon: "figure.run",
            description: "Walk/run intervals for beginners building up to a 5K",
            estimatedCaloriesPerMinute: 7, difficultyLevel: "Beginner"
        ),
    ]

    static let cycling: [CardioWorkoutDefinition] = [
        CardioWorkoutDefinition(
            name: "Outdoor Bike",
            category: .cycling, icon: "figure.outdoor.cycle",
            description: "Road or trail cycling at your own pace",
            estimatedCaloriesPerMinute: 9, difficultyLevel: "Moderate",
            isDistanceBased: true, usesGPS: true
        ),
        CardioWorkoutDefinition(
            name: "Indoor Bike",
            category: .cycling, icon: "figure.indoor.cycle",
            description: "Stationary bike session with adjustable resistance",
            estimatedCaloriesPerMinute: 8, difficultyLevel: "Moderate"
        ),
        CardioWorkoutDefinition(
            name: "Spin Class",
            category: .cycling, icon: "figure.indoor.cycle",
            description: "High-energy indoor cycling with intervals and climbs",
            estimatedCaloriesPerMinute: 11, difficultyLevel: "Hard"
        ),
        CardioWorkoutDefinition(
            name: "Hill Cycling",
            category: .cycling, icon: "figure.outdoor.cycle",
            description: "Outdoor ride focused on climbing hills for leg power",
            estimatedCaloriesPerMinute: 10, difficultyLevel: "Hard",
            isDistanceBased: true, usesGPS: true
        ),
        CardioWorkoutDefinition(
            name: "Cycling Intervals",
            category: .cycling, icon: "figure.indoor.cycle",
            description: "Alternate between high resistance sprints and easy spinning",
            estimatedCaloriesPerMinute: 10, difficultyLevel: "Moderate"
        ),
    ]

    static let classWorkouts: [CardioWorkoutDefinition] = [
        CardioWorkoutDefinition(
            name: "Yoga",
            category: .classWorkouts, icon: "figure.yoga",
            description: "Flow through poses for flexibility, balance, and mindfulness",
            estimatedCaloriesPerMinute: 4, difficultyLevel: "Easy"
        ),
        CardioWorkoutDefinition(
            name: "Hot Yoga",
            category: .classWorkouts, icon: "figure.yoga",
            description: "Yoga practiced in a heated room for deeper stretches",
            estimatedCaloriesPerMinute: 6, difficultyLevel: "Moderate"
        ),
        CardioWorkoutDefinition(
            name: "Pilates",
            category: .classWorkouts, icon: "figure.pilates",
            description: "Core-focused mat or reformer exercises for stability and tone",
            estimatedCaloriesPerMinute: 5, difficultyLevel: "Moderate"
        ),
        CardioWorkoutDefinition(
            name: "Zumba",
            category: .classWorkouts, icon: "figure.dance",
            description: "Latin-inspired dance fitness party with easy-to-follow moves",
            estimatedCaloriesPerMinute: 9, difficultyLevel: "Moderate"
        ),
        CardioWorkoutDefinition(
            name: "Aerobics",
            category: .classWorkouts, icon: "figure.aerobics",
            description: "Classic group cardio with choreographed movements",
            estimatedCaloriesPerMinute: 8, difficultyLevel: "Moderate"
        ),
        CardioWorkoutDefinition(
            name: "Step Aerobics",
            category: .classWorkouts, icon: "figure.step.training",
            description: "Aerobics using a step platform for added intensity",
            estimatedCaloriesPerMinute: 9, difficultyLevel: "Moderate"
        ),
        CardioWorkoutDefinition(
            name: "Dance Cardio",
            category: .classWorkouts, icon: "figure.dance",
            description: "Fun dance-based workout blending multiple styles",
            estimatedCaloriesPerMinute: 8, difficultyLevel: "Moderate"
        ),
        CardioWorkoutDefinition(
            name: "Barre",
            category: .classWorkouts, icon: "figure.barre",
            description: "Ballet-inspired workout targeting small muscle groups",
            estimatedCaloriesPerMinute: 5, difficultyLevel: "Moderate"
        ),
        CardioWorkoutDefinition(
            name: "Kickboxing",
            category: .classWorkouts, icon: "figure.kickboxing",
            description: "High-energy martial arts inspired cardio with punches and kicks",
            estimatedCaloriesPerMinute: 10, difficultyLevel: "Hard"
        ),
        CardioWorkoutDefinition(
            name: "Boxing",
            category: .classWorkouts, icon: "figure.boxing",
            description: "Heavy bag or shadow boxing for full-body conditioning",
            estimatedCaloriesPerMinute: 10, difficultyLevel: "Hard"
        ),
    ]

    static let lowImpact: [CardioWorkoutDefinition] = [
        CardioWorkoutDefinition(
            name: "Walking",
            category: .lowImpact, icon: "figure.walk",
            description: "Brisk walking for heart health and active recovery",
            estimatedCaloriesPerMinute: 5, difficultyLevel: "Easy",
            isDistanceBased: true, usesGPS: true
        ),
        CardioWorkoutDefinition(
            name: "Power Walking",
            category: .lowImpact, icon: "figure.walk",
            description: "Fast-paced walking with arm movement for extra calorie burn",
            estimatedCaloriesPerMinute: 6, difficultyLevel: "Easy",
            isDistanceBased: true, usesGPS: true
        ),
        CardioWorkoutDefinition(
            name: "Swimming",
            category: .lowImpact, icon: "figure.pool.swim",
            description: "Full-body low-impact workout in the pool",
            estimatedCaloriesPerMinute: 8, difficultyLevel: "Moderate"
        ),
        CardioWorkoutDefinition(
            name: "Rowing Machine",
            category: .lowImpact, icon: "figure.rowing",
            description: "Full-body pull on the erg for cardio and strength",
            estimatedCaloriesPerMinute: 9, difficultyLevel: "Moderate"
        ),
        CardioWorkoutDefinition(
            name: "Elliptical",
            category: .lowImpact, icon: "figure.elliptical",
            description: "Low-impact machine that mimics running without joint stress",
            estimatedCaloriesPerMinute: 8, difficultyLevel: "Moderate"
        ),
        CardioWorkoutDefinition(
            name: "Stair Climber",
            category: .lowImpact, icon: "figure.stair.stepper",
            description: "Climb stairs continuously for leg and glute conditioning",
            estimatedCaloriesPerMinute: 9, difficultyLevel: "Moderate"
        ),
        CardioWorkoutDefinition(
            name: "Stretching & Mobility",
            category: .lowImpact, icon: "figure.flexibility",
            description: "Guided stretching routine for flexibility and recovery",
            estimatedCaloriesPerMinute: 3, difficultyLevel: "Easy"
        ),
        CardioWorkoutDefinition(
            name: "Tai Chi",
            category: .lowImpact, icon: "figure.taichi",
            description: "Slow flowing movements for balance, calm, and joint health",
            estimatedCaloriesPerMinute: 3, difficultyLevel: "Easy"
        ),
    ]

    static let hiit: [CardioWorkoutDefinition] = [
        CardioWorkoutDefinition(
            name: "HIIT Circuit",
            category: .hiit, icon: "bolt.heart.fill",
            description: "High-intensity intervals alternating work and rest periods",
            estimatedCaloriesPerMinute: 12, difficultyLevel: "Hard"
        ),
        CardioWorkoutDefinition(
            name: "Tabata",
            category: .hiit, icon: "timer",
            description: "20 seconds on, 10 seconds off for 4-minute rounds",
            estimatedCaloriesPerMinute: 14, difficultyLevel: "Hard"
        ),
        CardioWorkoutDefinition(
            name: "AMRAP",
            category: .hiit, icon: "repeat",
            description: "As Many Rounds As Possible in a set time window",
            estimatedCaloriesPerMinute: 11, difficultyLevel: "Hard"
        ),
        CardioWorkoutDefinition(
            name: "EMOM",
            category: .hiit, icon: "clock.badge.checkmark",
            description: "Every Minute On the Minute — complete work, rest remainder",
            estimatedCaloriesPerMinute: 10, difficultyLevel: "Moderate"
        ),
        CardioWorkoutDefinition(
            name: "Circuit Training",
            category: .hiit, icon: "arrow.triangle.2.circlepath",
            description: "Rotate through stations with minimal rest between exercises",
            estimatedCaloriesPerMinute: 9, difficultyLevel: "Moderate"
        ),
        CardioWorkoutDefinition(
            name: "Metabolic Conditioning",
            category: .hiit, icon: "flame.fill",
            description: "Compound movements at high intensity to maximize calorie burn",
            estimatedCaloriesPerMinute: 12, difficultyLevel: "Hard"
        ),
        CardioWorkoutDefinition(
            name: "Jump Rope",
            category: .hiit, icon: "figure.jumprope",
            description: "Skipping rope for coordination, footwork, and cardio endurance",
            estimatedCaloriesPerMinute: 11, difficultyLevel: "Moderate"
        ),
    ]

    static let outdoor: [CardioWorkoutDefinition] = [
        CardioWorkoutDefinition(
            name: "Hiking",
            category: .outdoor, icon: "figure.hiking",
            description: "Trail hiking for endurance, scenery, and fresh air",
            estimatedCaloriesPerMinute: 7, difficultyLevel: "Moderate",
            isDistanceBased: true, usesGPS: true
        ),
        CardioWorkoutDefinition(
            name: "Trail Running",
            category: .outdoor, icon: "figure.run",
            description: "Off-road running on trails for varied terrain challenge",
            estimatedCaloriesPerMinute: 11, difficultyLevel: "Hard",
            isDistanceBased: true, usesGPS: true
        ),
        CardioWorkoutDefinition(
            name: "Rucking",
            category: .outdoor, icon: "figure.hiking",
            description: "Walking with a weighted backpack for strength endurance",
            estimatedCaloriesPerMinute: 8, difficultyLevel: "Moderate",
            isDistanceBased: true, usesGPS: true
        ),
        CardioWorkoutDefinition(
            name: "Stair Running",
            category: .outdoor, icon: "figure.stairs",
            description: "Running stadium or building stairs for explosive leg power",
            estimatedCaloriesPerMinute: 12, difficultyLevel: "Hard"
        ),
        CardioWorkoutDefinition(
            name: "Outdoor Boot Camp",
            category: .outdoor, icon: "figure.strengthtraining.functional",
            description: "Group or solo circuit training in a park or field",
            estimatedCaloriesPerMinute: 10, difficultyLevel: "Hard"
        ),
        CardioWorkoutDefinition(
            name: "Beach Run",
            category: .outdoor, icon: "figure.run",
            description: "Sand running for extra resistance and ankle stability",
            estimatedCaloriesPerMinute: 12, difficultyLevel: "Hard",
            isDistanceBased: true, usesGPS: true
        ),
    ]

    static func workouts(for category: CardioCategory) -> [CardioWorkoutDefinition] {
        allWorkouts.filter { $0.category == category }
    }

    static func search(_ query: String) -> [CardioWorkoutDefinition] {
        guard !query.isEmpty else { return allWorkouts }
        let lower = query.lowercased()
        return allWorkouts.filter {
            $0.name.lowercased().contains(lower) ||
            $0.description.lowercased().contains(lower) ||
            $0.category.rawValue.lowercased().contains(lower)
        }
    }
}
