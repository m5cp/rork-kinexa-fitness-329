import SwiftUI

struct FunctionalFitnessBrowserView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var vm
    let onAddExercise: (ManualRoutineExercise) -> Void

    @State private var expandedID: UUID?
    @State private var searchText: String = ""
    @State private var addedTrigger: Bool = false
    @State private var showAddMovementSheet: Bool = false
    @State private var editingWorkoutIndex: Int?
    @State private var localWorkouts: [WODTemplate]
    @State private var showSearchExerciseSheet: Bool = false
    @State private var searchExerciseWorkoutIndex: Int?
    @State private var setAsTodayTrigger: Bool = false

    init(onAddExercise: @escaping (ManualRoutineExercise) -> Void) {
        self.onAddExercise = onAddExercise
        _localWorkouts = State(initialValue: FunctionalFitnessLibrary.functionalFitnessWorkouts)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                KinexaTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        actionButtons

                        ForEach(Array(filteredWorkouts.enumerated()), id: \.element.id) { idx, workout in
                            workoutCard(workout, index: localWorkouts.firstIndex(where: { $0.id == workout.id }) ?? idx)
                        }

                        if filteredWorkouts.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "magnifyingglass")
                                    .font(.title)
                                    .foregroundStyle(KinexaTheme.tertiaryText)
                                Text("No workouts found")
                                    .font(.subheadline)
                                    .foregroundStyle(KinexaTheme.secondaryText)
                            }
                            .padding(.top, 40)
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

    private var filteredWorkouts: [WODTemplate] {
        guard !searchText.isEmpty else { return localWorkouts }
        return localWorkouts.filter {
            $0.title.localizedStandardContains(searchText) ||
            $0.workoutDescription.localizedStandardContains(searchText)
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 10) {
            Button {
                setAsTodayTrigger.toggle()
                pickRandomWorkoutAsToday()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "shuffle")
                        .font(.caption.weight(.bold))
                    Text("Random")
                        .font(.caption.weight(.bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#F59E0B"), Color(hex: "#D97706")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(.rect(cornerRadius: 12))
            }
            .buttonStyle(PressScaleButtonStyle())
        }
    }

    // MARK: - Workout Card

    private func workoutCard(_ workout: WODTemplate, index: Int) -> some View {
        let isExpanded = expandedID == workout.id

        return VStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    expandedID = isExpanded ? nil : workout.id
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
                                .foregroundStyle(intensityColor(workout.intensityGrade))
                            Text("\(workout.movements.count) movements")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(KinexaTheme.tertiaryText)
                        }
                    }

                    Spacer(minLength: 0)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }
                .padding(14)
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
                                    .fill(Color(hex: "#F59E0B").opacity(0.5))
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
                                        .foregroundStyle(Color(hex: "#F59E0B"))
                                }

                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        if index < localWorkouts.count {
                                            localWorkouts[index].movements.remove(at: mIdx)
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
                            searchExerciseWorkoutIndex = index
                            showSearchExerciseSheet = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "magnifyingglass")
                                    .font(.caption2.weight(.bold))
                                Text("Add Movement")
                                    .font(.caption.weight(.semibold))
                            }
                            .foregroundStyle(Color(hex: "#F59E0B"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(Color(hex: "#F59E0B").opacity(0.1))
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
                                    colors: [Color(hex: "#F59E0B"), Color(hex: "#D97706")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(.rect(cornerRadius: 10))
                        }
                        .buttonStyle(PressScaleButtonStyle())
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
            }
        }
        .background(KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14).stroke(
                isExpanded ? Color(hex: "#F59E0B").opacity(0.3) : KinexaTheme.border
            )
        }
    }

    // MARK: - Actions

    private func setWorkoutAsToday(_ workout: WODTemplate) {
        vm.setFunctionalFitnessAsToday(workout)
    }

    private func pickRandomWorkoutAsToday() {
        guard let randomWorkout = localWorkouts.randomElement() else { return }
        vm.setFunctionalFitnessAsToday(randomWorkout)
    }

    private func intensityColor(_ grade: IntensityGrade) -> Color {
        switch grade {
        case .low: return .green
        case .moderate: return Color(hex: "#F59E0B")
        case .high: return .orange
        case .extreme: return .red
        }
    }
}

// MARK: - Exercise Search Sheet

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
