import SwiftUI

struct FunctionalFitnessBrowserView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var vm
    let onAddExercise: (ManualRoutineExercise) -> Void

    @State private var expandedID: UUID?
    @State private var searchText: String = ""
    @State private var addedTrigger: Bool = false
    @State private var showSearchExerciseSheet: Bool = false
    @State private var searchExerciseWorkoutIndex: Int?
    @State private var setAsTodayTrigger: Bool = false
    @State private var localWorkouts: [WODTemplate]

    init(onAddExercise: @escaping (ManualRoutineExercise) -> Void) {
        self.onAddExercise = onAddExercise
        _localWorkouts = State(initialValue: FunctionalFitnessLibrary.functionalFitnessWorkouts)
    }

    private var moderateWorkouts: [WODTemplate] {
        localWorkouts.filter { $0.intensityGrade == .moderate }
    }

    private var highWorkouts: [WODTemplate] {
        localWorkouts.filter { $0.intensityGrade == .high }
    }

    private var extremeWorkouts: [WODTemplate] {
        localWorkouts.filter { $0.intensityGrade == .extreme }
    }

    private var lowWorkouts: [WODTemplate] {
        localWorkouts.filter { $0.intensityGrade == .low }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                KinexaTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        if !searchText.isEmpty {
                            searchResults
                        } else {
                            intensityHeroCards
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 48)
                }
            }
            .navigationTitle("Functional Fitness")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search workouts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(KinexaTheme.primaryText)
                }
            }
            .toolbarBackground(KinexaTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sensoryFeedback(.impact(weight: .light), trigger: addedTrigger)
            .sensoryFeedback(.success, trigger: setAsTodayTrigger)
            .sheet(isPresented: $showSearchExerciseSheet) {
                ExerciseSearchSheet { movement in
                    if let idx = searchExerciseWorkoutIndex, idx < localWorkouts.count {
                        localWorkouts[idx].movements.append(movement)
                    }
                }
            }
        }
    }

    private var intensityHeroCards: some View {
        VStack(spacing: 14) {
            if !lowWorkouts.isEmpty {
                intensityHeroCard(
                    grade: .low,
                    gradient: [Color(hex: "#22C55E"), Color(hex: "#16A34A")],
                    workouts: lowWorkouts
                )
            }

            if !moderateWorkouts.isEmpty {
                intensityHeroCard(
                    grade: .moderate,
                    gradient: [Color(hex: "#F59E0B"), Color(hex: "#D97706")],
                    workouts: moderateWorkouts
                )
            }

            if !highWorkouts.isEmpty {
                intensityHeroCard(
                    grade: .high,
                    gradient: [Color(hex: "#EA580C"), Color(hex: "#C2410C")],
                    workouts: highWorkouts
                )
            }

            if !extremeWorkouts.isEmpty {
                intensityHeroCard(
                    grade: .extreme,
                    gradient: [Color(hex: "#EF4444"), Color(hex: "#DC2626")],
                    workouts: extremeWorkouts
                )
            }
        }
    }

    private func intensityHeroCard(grade: IntensityGrade, gradient: [Color], workouts: [WODTemplate]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                Circle()
                    .fill(gradient.first ?? .orange)
                    .frame(width: 12, height: 12)

                VStack(alignment: .leading, spacing: 3) {
                    Text(grade.rawValue)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)

                    Text("\(workouts.count) workouts")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.white.opacity(0.7))
                }

                Spacer(minLength: 0)

                Text("See All")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.white.opacity(0.15))
                    .clipShape(Capsule())
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: gradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(.rect(topLeadingRadius: 18, topTrailingRadius: 18))

            VStack(spacing: 0) {
                ForEach(Array(workouts.prefix(3).enumerated()), id: \.element.id) { idx, workout in
                    if idx > 0 {
                        Divider().overlay(KinexaTheme.border)
                    }
                    workoutPreviewRow(workout, gradient: gradient)
                }
            }
            .background(KinexaTheme.card)
            .clipShape(.rect(bottomLeadingRadius: 18, bottomTrailingRadius: 18))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(gradient.first?.opacity(0.2) ?? Color.clear)
        }
        .shadow(color: (gradient.first ?? .clear).opacity(0.12), radius: 12, y: 6)
    }

    private func workoutPreviewRow(_ workout: WODTemplate, gradient: [Color]) -> some View {
        let isExpanded = expandedID == workout.id
        let workoutIndex = localWorkouts.firstIndex(where: { $0.id == workout.id })

        return VStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    expandedID = isExpanded ? nil : workout.id
                }
            } label: {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(workout.title)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(KinexaTheme.primaryText)
                            .lineLimit(1)

                        HStack(spacing: 6) {
                            Text("~\(workout.durationMinutes) min")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(gradient.first ?? .orange)
                            Text("\(workout.movements.count) movements")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(KinexaTheme.tertiaryText)
                        }
                    }

                    Spacer(minLength: 0)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.right")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Divider().overlay(KinexaTheme.border)

                    Text(workout.workoutDescription)
                        .font(.caption)
                        .foregroundStyle(KinexaTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(spacing: 6) {
                        ForEach(Array(workout.movements.enumerated()), id: \.element.id) { mIdx, movement in
                            HStack(spacing: 10) {
                                Circle()
                                    .fill((gradient.first ?? .orange).opacity(0.5))
                                    .frame(width: 6, height: 6)

                                Text(movement.name)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(KinexaTheme.primaryText)

                                Spacer(minLength: 0)

                                if let reps = movement.reps {
                                    Text(reps)
                                        .font(.caption2.weight(.medium))
                                        .foregroundStyle(KinexaTheme.tertiaryText)
                                }

                                Button {
                                    addedTrigger.toggle()
                                    let exercise = ManualRoutineExercise(
                                        name: movement.name,
                                        category: "Functional Fitness",
                                        sets: 3,
                                        reps: movement.reps ?? movement.duration ?? "10",
                                        sourceType: .functionalFitness
                                    )
                                    onAddExercise(exercise)
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.body)
                                        .foregroundStyle(gradient.first ?? .orange)
                                }

                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        if let idx = workoutIndex, idx < localWorkouts.count {
                                            localWorkouts[idx].movements.remove(at: mIdx)
                                        }
                                    }
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.body)
                                        .foregroundStyle(.red.opacity(0.6))
                                }
                            }
                        }
                    }

                    HStack(spacing: 8) {
                        Button {
                            if let idx = workoutIndex {
                                searchExerciseWorkoutIndex = idx
                                showSearchExerciseSheet = true
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "magnifyingglass")
                                    .font(.caption2.weight(.bold))
                                Text("Add Movement")
                                    .font(.caption.weight(.semibold))
                            }
                            .foregroundStyle(gradient.first ?? .orange)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background((gradient.first ?? .orange).opacity(0.1))
                            .clipShape(.rect(cornerRadius: 10))
                        }
                        .buttonStyle(PressScaleButtonStyle())

                        Button {
                            setAsTodayTrigger.toggle()
                            setWorkoutAsToday(workout)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.caption2.weight(.bold))
                                Text("Today's Workout")
                                    .font(.caption.weight(.semibold))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(
                                LinearGradient(
                                    colors: gradient,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(.rect(cornerRadius: 10))
                        }
                        .buttonStyle(PressScaleButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 14)
            }
        }
    }

    private var searchResults: some View {
        let filtered = localWorkouts.filter {
            $0.title.localizedStandardContains(searchText) ||
            $0.workoutDescription.localizedStandardContains(searchText)
        }

        return VStack(spacing: 10) {
            if filtered.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.title)
                        .foregroundStyle(KinexaTheme.tertiaryText)
                    Text("No workouts found")
                        .font(.subheadline)
                        .foregroundStyle(KinexaTheme.secondaryText)
                }
                .padding(.top, 40)
            } else {
                ForEach(filtered) { workout in
                    searchWorkoutCard(workout)
                }
            }
        }
    }

    private func searchWorkoutCard(_ workout: WODTemplate) -> some View {
        let gradient = intensityGradient(workout.intensityGrade)

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                expandedID = expandedID == workout.id ? nil : workout.id
            }
        } label: {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(KinexaTheme.primaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 8) {
                        Text("~\(workout.durationMinutes) min")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(KinexaTheme.tertiaryText)
                        Text(workout.intensityGrade.rawValue)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(gradient.first ?? .orange)
                        Text("\(workout.movements.count) movements")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(KinexaTheme.tertiaryText)
                    }
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }
            .padding(14)
            .background(KinexaTheme.card)
            .clipShape(.rect(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14).stroke(KinexaTheme.border)
            }
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    private func intensityGradient(_ grade: IntensityGrade) -> [Color] {
        switch grade {
        case .low: return [Color(hex: "#22C55E"), Color(hex: "#16A34A")]
        case .moderate: return [Color(hex: "#F59E0B"), Color(hex: "#D97706")]
        case .high: return [Color(hex: "#EA580C"), Color(hex: "#C2410C")]
        case .extreme: return [Color(hex: "#EF4444"), Color(hex: "#DC2626")]
        }
    }

    private func setWorkoutAsToday(_ workout: WODTemplate) {
        vm.setFunctionalFitnessAsToday(workout)
    }
}

struct ExerciseSearchSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onAdd: (WODMovement) -> Void

    @State private var searchText: String = ""
    @State private var addedTrigger: Bool = false

    private var allExercises: [String] {
        var names: [String] = []
        names.append(contentsOf: WeightExerciseLibrary.allExercises.map(\.name))
        let ffMoves = FunctionalFitnessLibrary.functionalFitnessWorkouts.flatMap(\.movements).map(\.name)
        names.append(contentsOf: ffMoves)
        names.append(contentsOf: [
            "Burpee", "Mountain Climber", "Jumping Jack", "Box Jump",
            "Wall Ball", "Rope Climb", "Sled Push", "Sled Drag",
            "Battle Ropes", "Medicine Ball Slam", "Tire Flip",
            "Broad Jump", "Skater Hop", "Bear Crawl", "Crab Walk",
            "Inch Worm", "V-Up", "Bicycle Crunch", "Flutter Kick",
            "Superman Hold", "Pistol Squat", "Handstand Push-Up",
            "Ring Dip", "Ring Row", "L-Sit Hold", "Toes to Bar"
        ])
        return Array(Set(names)).sorted()
    }

    private var filteredExercises: [String] {
        guard !searchText.isEmpty else { return allExercises }
        return allExercises.filter { $0.localizedStandardContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                KinexaTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 6) {
                        ForEach(filteredExercises, id: \.self) { name in
                            Button {
                                addedTrigger.toggle()
                                let movement = WODMovement(name: name, reps: "3x10")
                                onAdd(movement)
                                dismiss()
                            } label: {
                                HStack(spacing: 12) {
                                    Text(name)
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(KinexaTheme.primaryText)

                                    Spacer(minLength: 0)

                                    Image(systemName: "plus.circle.fill")
                                        .font(.body)
                                        .foregroundStyle(Color(hex: "#F59E0B"))
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(KinexaTheme.card)
                                .clipShape(.rect(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }

                        if filteredExercises.isEmpty && !searchText.isEmpty {
                            Button {
                                addedTrigger.toggle()
                                let movement = WODMovement(name: searchText, reps: "3x10")
                                onAdd(movement)
                                dismiss()
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.body)
                                        .foregroundStyle(Color(hex: "#F59E0B"))
                                    Text("Add \"\(searchText)\"")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(KinexaTheme.primaryText)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(14)
                                .background(Color(hex: "#F59E0B").opacity(0.1))
                                .clipShape(.rect(cornerRadius: 14))
                            }
                            .buttonStyle(PressScaleButtonStyle())
                            .padding(.top, 20)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 48)
                }
            }
            .navigationTitle("Search Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search or type custom exercise")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(KinexaTheme.secondaryText)
                }
            }
            .toolbarBackground(KinexaTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sensoryFeedback(.impact(weight: .light), trigger: addedTrigger)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(KinexaTheme.background)
    }
}
