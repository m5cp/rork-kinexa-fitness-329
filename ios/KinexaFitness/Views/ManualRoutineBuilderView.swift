import SwiftUI

struct ManualRoutineBuilderView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var routine: ManualRoutine
    @State private var showWeightBrowser: Bool = false
    @State private var showFunctionalBrowser: Bool = false
    @State private var showCardioBrowser: Bool = false
    @State private var selectedDayID: UUID?
    @State private var showAddDay: Bool = false
    @State private var newDayName: String = ""
    @State private var editingExerciseID: UUID?
    @State private var saveTrigger: Bool = false

    init(initialExercises: [ManualRoutineExercise] = []) {
        let defaultDays = [
            ManualRoutineDay(dayName: "Monday"),
            ManualRoutineDay(dayName: "Tuesday"),
            ManualRoutineDay(dayName: "Wednesday"),
            ManualRoutineDay(dayName: "Thursday"),
            ManualRoutineDay(dayName: "Friday"),
        ]
        var r = ManualRoutine(days: defaultDays)
        if !initialExercises.isEmpty {
            r.days[0].exercises = initialExercises
        }
        _routine = State(initialValue: r)
        if !initialExercises.isEmpty {
            _selectedDayID = State(initialValue: r.days[0].id)
        }
    }

    init(existing: ManualRoutine) {
        _routine = State(initialValue: existing)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                KinexaTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        routineNameField
                        addExerciseButtons
                        daysList
                        addDayButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 48)
                }
            }
            .navigationTitle("Manual Build")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        saveTrigger.toggle()
                        saveRoutine()
                        dismiss()
                    } label: {
                        Text("Save")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(KinexaTheme.accent)
                    }
                }
            }
            .toolbarBackground(KinexaTheme.background, for: .navigationBar)
            
            .sensoryFeedback(.success, trigger: saveTrigger)
            .sheet(isPresented: $showWeightBrowser) {
                WeightTrainingBrowserView { exercise in
                    addExerciseToSelectedDay(exercise)
                }
            }
            .sheet(isPresented: $showFunctionalBrowser) {
                FunctionalFitnessBrowserView { exercise in
                    addExerciseToSelectedDay(exercise)
                }
            }
            .sheet(isPresented: $showCardioBrowser) {
                CardioBrowserForRoutineView { exercise in
                    addExerciseToSelectedDay(exercise)
                }
            }
            .alert("Add Day", isPresented: $showAddDay) {
                TextField("Day name", text: $newDayName)
                Button("Add") {
                    if !newDayName.isEmpty {
                        routine.days.append(ManualRoutineDay(dayName: newDayName))
                        newDayName = ""
                    }
                }
                Button("Cancel", role: .cancel) { newDayName = "" }
            }
        }
    }

    private var routineNameField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("ROUTINE NAME")
                .font(.caption.weight(.bold))
                .tracking(1.0)
                .foregroundStyle(KinexaTheme.tertiaryText)

            TextField("My Routine", text: $routine.name)
                .font(.headline.weight(.bold))
                .foregroundStyle(KinexaTheme.primaryText)
                .padding(14)
                .background(KinexaTheme.card)
                .clipShape(.rect(cornerRadius: 14))
                .elevatedCardShadow()
                .overlay {
                    RoundedRectangle(cornerRadius: 14).stroke(KinexaTheme.border)
                }
        }
    }

    private var addExerciseButtons: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ADD EXERCISES")
                .font(.caption.weight(.bold))
                .tracking(1.0)
                .foregroundStyle(KinexaTheme.tertiaryText)

            HStack(spacing: 10) {
                addSourceButton(
                    title: "Weights",
                    icon: "dumbbell.fill",
                    color: Color(hex: "#6366F1")
                ) {
                    ensureSelectedDay()
                    showWeightBrowser = true
                }

                addSourceButton(
                    title: "Functional",
                    icon: "bolt.heart.fill",
                    color: Color(hex: "#F59E0B")
                ) {
                    ensureSelectedDay()
                    showFunctionalBrowser = true
                }

                addSourceButton(
                    title: "Cardio",
                    icon: "heart.fill",
                    color: Color(hex: "#EC4899")
                ) {
                    ensureSelectedDay()
                    showCardioBrowser = true
                }
            }
        }
    }

    private func addSourceButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.body.weight(.bold))
                    .foregroundStyle(color)
                    .frame(width: 36, height: 36)
                    .background(color.opacity(0.12))
                    .clipShape(.rect(cornerRadius: 10))

                Text(title)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(KinexaTheme.card)
            .clipShape(.rect(cornerRadius: 14))
            .elevatedCardShadow()
            .overlay {
                RoundedRectangle(cornerRadius: 14).stroke(KinexaTheme.border)
            }
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    private var daysList: some View {
        VStack(spacing: 14) {
            ForEach(Array(routine.days.enumerated()), id: \.element.id) { index, day in
                dayCard(day, index: index)
            }
        }
    }

    private func dayCard(_ day: ManualRoutineDay, index: Int) -> some View {
        let isSelected = selectedDayID == day.id

        return VStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    selectedDayID = isSelected ? nil : day.id
                }
            } label: {
                HStack(spacing: 12) {
                    Text(day.dayName)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)

                    Spacer(minLength: 0)

                    Text("\(day.exercises.count) exercises")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(KinexaTheme.tertiaryText)

                    Image(systemName: isSelected ? "chevron.up" : "chevron.down")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }
                .padding(14)
            }
            .buttonStyle(.plain)

            if isSelected {
                Divider().overlay(KinexaTheme.border)

                if day.exercises.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle")
                            .foregroundStyle(KinexaTheme.tertiaryText)
                        Text("Tap Weights, Functional, or Cardio above to add exercises")
                            .font(.caption)
                            .foregroundStyle(KinexaTheme.tertiaryText)
                    }
                    .padding(14)
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(day.exercises.enumerated()), id: \.element.id) { exIdx, exercise in
                            if exIdx > 0 {
                                Divider().overlay(KinexaTheme.border.opacity(0.5)).padding(.leading, 14)
                            }
                            exerciseRow(exercise, dayIndex: index, exerciseIndex: exIdx)
                        }
                    }
                }
            }
        }
        .background(isSelected ? KinexaTheme.accent.opacity(0.04) : KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16).stroke(
                isSelected ? KinexaTheme.accent.opacity(0.3) : KinexaTheme.border
            )
        }
    }

    private func exerciseRow(_ exercise: ManualRoutineExercise, dayIndex: Int, exerciseIndex: Int) -> some View {
        HStack(spacing: 10) {
            sourceIcon(exercise.sourceType)

            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(KinexaTheme.primaryText)
                    .lineLimit(1)

                Text("\(exercise.sets) sets × \(exercise.reps)")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }

            Spacer(minLength: 0)

            HStack(spacing: 6) {
                Button {
                    if routine.days[dayIndex].exercises[exerciseIndex].sets > 1 {
                        routine.days[dayIndex].exercises[exerciseIndex].sets -= 1
                    }
                } label: {
                    Image(systemName: "minus.circle")
                        .font(.caption)
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }

                Text("\(exercise.sets)")
                    .font(.caption.weight(.bold).monospacedDigit())
                    .foregroundStyle(KinexaTheme.primaryText)
                    .frame(width: 20)

                Button {
                    routine.days[dayIndex].exercises[exerciseIndex].sets += 1
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.caption)
                        .foregroundStyle(KinexaTheme.accent)
                }
            }

            Button {
                routine.days[dayIndex].exercises.remove(at: exerciseIndex)
            } label: {
                Image(systemName: "trash")
                    .font(.caption2)
                    .foregroundStyle(.red.opacity(0.7))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private func sourceIcon(_ source: ManualExerciseSource) -> some View {
        let color: Color = {
            switch source {
            case .weightTraining: return Color(hex: "#6366F1")
            case .cardio: return Color(hex: "#EC4899")
            case .functionalFitness: return Color(hex: "#F59E0B")
            }
        }()

        let icon: String = {
            switch source {
            case .weightTraining: return "dumbbell.fill"
            case .cardio: return "heart.fill"
            case .functionalFitness: return "bolt.heart.fill"
            }
        }()

        return Image(systemName: icon)
            .font(.caption2.weight(.bold))
            .foregroundStyle(color)
            .frame(width: 24, height: 24)
            .background(color.opacity(0.12))
            .clipShape(.rect(cornerRadius: 6))
    }

    private var addDayButton: some View {
        Button {
            showAddDay = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.body)
                Text("Add Day")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(KinexaTheme.accent)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(KinexaTheme.accent.opacity(0.08))
            .clipShape(.rect(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14).stroke(KinexaTheme.accent.opacity(0.2))
            }
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    private func ensureSelectedDay() {
        if selectedDayID == nil, let first = routine.days.first {
            selectedDayID = first.id
        }
    }

    private func addExerciseToSelectedDay(_ exercise: ManualRoutineExercise) {
        guard let dayID = selectedDayID,
              let idx = routine.days.firstIndex(where: { $0.id == dayID }) else {
            if !routine.days.isEmpty {
                routine.days[0].exercises.append(exercise)
            }
            return
        }
        routine.days[idx].exercises.append(exercise)
    }

    private func saveRoutine() {
        var saved = LocalStore.load([ManualRoutine].self, forKey: "manualRoutines", fallback: [])
        if let idx = saved.firstIndex(where: { $0.id == routine.id }) {
            saved[idx] = routine
        } else {
            saved.append(routine)
        }
        LocalStore.save(saved, forKey: "manualRoutines")
    }
}

struct CardioBrowserForRoutineView: View {
    @Environment(\.dismiss) private var dismiss
    let onAddExercise: (ManualRoutineExercise) -> Void

    @State private var searchText: String = ""
    @State private var addedTrigger: Bool = false
    @State private var showCardioByType: Bool = false
    @State private var showCardioPrograms: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                KinexaTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        cardioDisclaimerBanner

                        if !searchText.isEmpty {
                            cardioSearchResults
                        } else {
                            cardioLandingCards
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 48)
                }
            }
            .navigationTitle("Cardio")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search cardio")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(KinexaTheme.primaryText)
                }
            }
            .toolbarBackground(KinexaTheme.background, for: .navigationBar)
            
            .sensoryFeedback(.impact(weight: .light), trigger: addedTrigger)
            .sheet(isPresented: $showCardioByType) {
                CardioByTypeView(onAddExercise: onAddExercise)
            }
            .sheet(isPresented: $showCardioPrograms) {
                PreMadeCardioProgramsView()
            }
        }
    }

    private var cardioDisclaimerBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "info.circle.fill")
                .font(.caption)
                .foregroundStyle(Color(hex: "#EC4899").opacity(0.7))

            Text("These are open source cardio exercises blended together by traditional training methods. They are not a recommendation or guide. For tracking and accountability only.")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(KinexaTheme.tertiaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .background(Color(hex: "#EC4899").opacity(0.06))
        .clipShape(.rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#EC4899").opacity(0.1))
        }
    }

    private var cardioLandingCards: some View {
        VStack(spacing: 14) {
            Button {
                showCardioByType = true
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: "heart.fill")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#EC4899"), Color(hex: "#BE185D")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(.rect(cornerRadius: 14))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Cardio by Type")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(KinexaTheme.primaryText)

                        Text("Browse workouts by category")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(KinexaTheme.tertiaryText)

                        Text("\(CardioLibrary.allWorkouts.count) workouts")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color(hex: "#EC4899"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color(hex: "#EC4899").opacity(0.12))
                            .clipShape(Capsule())
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }
                .padding(16)
                .background(KinexaTheme.card)
                .clipShape(.rect(cornerRadius: 18))
                .elevatedCardShadow()
                .overlay {
                    RoundedRectangle(cornerRadius: 18).stroke(KinexaTheme.border)
                }
            }
            .buttonStyle(PressScaleButtonStyle())

            Button {
                showCardioPrograms = true
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: "doc.text.fill")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#F59E0B"), Color(hex: "#D97706")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(.rect(cornerRadius: 14))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Pre-made Programs")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(KinexaTheme.primaryText)

                        Text("Complete cardio programs ready to go")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(KinexaTheme.tertiaryText)
                            .lineLimit(2)

                        Text("\(PreMadeCardioLibrary.allPrograms.count) programs")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color(hex: "#F59E0B"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color(hex: "#F59E0B").opacity(0.12))
                            .clipShape(Capsule())
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }
                .padding(16)
                .background(KinexaTheme.card)
                .clipShape(.rect(cornerRadius: 18))
                .elevatedCardShadow()
                .overlay {
                    RoundedRectangle(cornerRadius: 18).stroke(KinexaTheme.border)
                }
            }
            .buttonStyle(PressScaleButtonStyle())
        }
    }

    private var cardioSearchResults: some View {
        let filtered = CardioLibrary.allWorkouts.filter {
            $0.name.localizedStandardContains(searchText) ||
            $0.description.localizedStandardContains(searchText)
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
                    HStack(spacing: 14) {
                        Image(systemName: workout.icon)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Color(hex: "#EC4899"))
                            .frame(width: 36, height: 36)
                            .background(Color(hex: "#EC4899").opacity(0.12))
                            .clipShape(.rect(cornerRadius: 10))

                        VStack(alignment: .leading, spacing: 3) {
                            Text(workout.name)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(KinexaTheme.primaryText)

                            HStack(spacing: 8) {
                                Text(workout.category.rawValue)
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(Color(hex: "#EC4899"))
                                Text(workout.difficultyLevel)
                                    .font(.caption2.weight(.medium))
                                    .foregroundStyle(KinexaTheme.tertiaryText)
                            }
                        }

                        Spacer(minLength: 0)

                        Button {
                            addedTrigger.toggle()
                            let exercise = ManualRoutineExercise(
                                name: workout.name,
                                category: workout.category.rawValue,
                                sets: 1,
                                reps: "30 min",
                                sourceType: .cardio
                            )
                            onAddExercise(exercise)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(Color(hex: "#EC4899"))
                        }
                    }
                    .padding(14)
                    .background(KinexaTheme.card)
                    .clipShape(.rect(cornerRadius: 14))
                    .elevatedCardShadow()
                    .overlay {
                        RoundedRectangle(cornerRadius: 14).stroke(KinexaTheme.border)
                    }
                }
            }
        }
    }
}
