import SwiftUI

struct EditWorkoutSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var vm

    let day: WorkoutDay

    @State private var exercises: [WorkoutExercise] = []
    @State private var expandedID: UUID?
    @State private var editMode: EditMode = .inactive
    @State private var showAddExercise: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                KynexaTheme.background.ignoresSafeArea()

                List {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(day.title)
                                .font(.title3.weight(.bold))
                                .foregroundStyle(KynexaTheme.primaryText)

                            Text("Drag to reorder. Swipe to delete. Tap to edit.")
                                .font(.subheadline)
                                .foregroundStyle(KynexaTheme.secondaryText)
                        }
                        .listRowBackground(KynexaTheme.card)
                    }

                    Section {
                        ForEach(Array(exercises.enumerated()), id: \.element.id) { index, exercise in
                            editableExerciseRow(index: index, exercise: exercise)
                                .listRowBackground(KynexaTheme.card)
                        }
                        .onMove { from, to in
                            exercises.move(fromOffsets: from, toOffset: to)
                        }
                        .onDelete { indexSet in
                            exercises.remove(atOffsets: indexSet)
                        }
                    } header: {
                        HStack {
                            Text("EXERCISES")
                                .font(.caption.weight(.bold))
                                .tracking(1.0)
                                .foregroundStyle(KynexaTheme.tertiaryText)

                            Spacer()

                            Button {
                                withAnimation {
                                    editMode = editMode == .active ? .inactive : .active
                                }
                            } label: {
                                Text(editMode == .active ? "Done" : "Reorder")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(KynexaTheme.accent)
                            }
                        }
                    }

                    Section {
                        Button {
                            showAddExercise = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(KynexaTheme.accent)
                                Text("Add Exercise")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(KynexaTheme.accent)
                            }
                        }
                        .listRowBackground(KynexaTheme.card)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .environment(\.editMode, $editMode)
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("Edit Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(KynexaTheme.secondaryText)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        vm.updateDayExercises(dayIndex: day.dayIndex, exercises: exercises)
                        dismiss()
                    }
                    .foregroundStyle(KynexaTheme.accent)
                    .fontWeight(.semibold)
                }
            }
            .toolbarBackground(KynexaTheme.background, for: .navigationBar)
            
            .sheet(isPresented: $showAddExercise) {
                AddExerciseSheet { newExercise in
                    exercises.append(newExercise)
                }
            }
        }
        .onAppear {
            exercises = day.exercises
        }
    }

    private func editableExerciseRow(index: Int, exercise: WorkoutExercise) -> some View {
        let isExpanded = expandedID == exercise.id

        return VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    expandedID = isExpanded ? nil : exercise.id
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            if exercise.isCardio, let ct = exercise.cardioType {
                                Image(systemName: ct.icon)
                                    .font(.caption)
                                    .foregroundStyle(KynexaTheme.accent)
                            }
                            Text(exercise.name)
                                .font(.headline)
                                .foregroundStyle(KynexaTheme.primaryText)
                        }
                        Text(exercise.displayDetail)
                            .font(.subheadline)
                            .foregroundStyle(KynexaTheme.secondaryText)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "pencil")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(KynexaTheme.accent)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider().overlay(KynexaTheme.border)

                VStack(alignment: .leading, spacing: 14) {
                    ExerciseAutocompleteField(
                        title: "Name",
                        text: $exercises[index].name,
                        accentColor: KynexaTheme.accent
                    )
                    .zIndex(10)

                    if exercises[index].isCardio {
                        cardioFields(index: index)
                    } else if exercises[index].isTimeBased {
                        timedFields(index: index)
                    } else {
                        strengthFields(index: index)
                    }

                    if !exercises[index].isCardio {
                        weightField(index: index)
                    }

                    noteField(index: index)

                    Button(role: .destructive) {
                        withAnimation {
                            exercises.remove(at: index)
                            expandedID = nil
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "trash")
                                .font(.caption.weight(.semibold))
                            Text("Remove Exercise")
                                .font(.caption.weight(.semibold))
                        }
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(.red.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 12)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private func strengthFields(index: Int) -> some View {
        HStack(spacing: 16) {
            intStepperField(title: "Sets", value: Binding(
                get: { exercises[index].sets },
                set: { exercises[index].sets = $0 }
            ), range: 1...20)

            intStepperField(title: "Reps", value: Binding(
                get: { exercises[index].reps },
                set: { exercises[index].reps = $0 }
            ), range: 1...100)
        }
    }

    private func timedFields(index: Int) -> some View {
        HStack(spacing: 16) {
            intStepperField(title: "Sets", value: Binding(
                get: { exercises[index].sets },
                set: { exercises[index].sets = $0 }
            ), range: 1...20)

            VStack(alignment: .leading, spacing: 6) {
                Text("Duration")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(KynexaTheme.secondaryText)

                HStack(spacing: 6) {
                    compactStepper(value: Binding(
                        get: { exercises[index].durationSeconds / 60 },
                        set: {
                            let secs = exercises[index].durationSeconds % 60
                            exercises[index].durationSeconds = $0 * 60 + secs
                        }
                    ), range: 0...120, label: "min")

                    compactStepper(value: Binding(
                        get: { exercises[index].durationSeconds % 60 },
                        set: {
                            let mins = exercises[index].durationSeconds / 60
                            exercises[index].durationSeconds = mins * 60 + $0
                        }
                    ), range: 0...59, label: "sec")
                }
            }
        }
    }

    private func cardioFields(index: Int) -> some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Cardio Type")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(KynexaTheme.secondaryText)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(CardioType.allCases) { type in
                            let selected = exercises[index].cardioType == type
                            Button {
                                exercises[index].cardioType = type
                            } label: {
                                HStack(spacing: 5) {
                                    Image(systemName: type.icon)
                                        .font(.caption2)
                                    Text(type.rawValue)
                                        .font(.caption.weight(.semibold))
                                }
                                .foregroundStyle(selected ? .white : KynexaTheme.primaryText)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 7)
                                .background(selected ? KynexaTheme.accent : KynexaTheme.cardSoft)
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .contentMargins(.horizontal, 0)
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Duration (min)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(KynexaTheme.secondaryText)

                    compactStepper(value: Binding(
                        get: { exercises[index].durationSeconds / 60 },
                        set: { exercises[index].durationSeconds = $0 * 60 }
                    ), range: 1...180, label: "min")
                }

                textField(title: "Distance (mi)", text: Binding(
                    get: { exercises[index].distanceMiles.map { String(format: "%.1f", $0) } ?? "" },
                    set: { exercises[index].distanceMiles = Double($0) }
                ), keyboard: .decimalPad)
            }

            Button {
                exercises[index].stepsLogged = vm.pedometer.todaySteps
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "figure.walk")
                    Text("Sync Steps (\(vm.pedometer.todaySteps))")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(KynexaTheme.accent)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(KynexaTheme.accent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
    }

    private func weightField(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "scalemass.fill")
                    .font(.caption2)
                    .foregroundStyle(KynexaTheme.accent)
                Text("Weight / Load")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(KynexaTheme.secondaryText)
            }

            TextField("e.g. 135 lbs, 20 lb vest", text: $exercises[index].weight)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(KynexaTheme.cardSoft)
                .foregroundStyle(KynexaTheme.primaryText)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay { RoundedRectangle(cornerRadius: 12).stroke(KynexaTheme.border) }
        }
    }

    private func noteField(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Notes")
                .font(.caption.weight(.semibold))
                .foregroundStyle(KynexaTheme.secondaryText)

            TextField("Add notes...", text: $exercises[index].notes)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(KynexaTheme.cardSoft)
                .foregroundStyle(KynexaTheme.primaryText)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay { RoundedRectangle(cornerRadius: 12).stroke(KynexaTheme.border) }
        }
    }

    private func textField(title: String, text: Binding<String>, keyboard: UIKeyboardType) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(KynexaTheme.secondaryText)

            TextField("0", text: text)
                .keyboardType(keyboard)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(KynexaTheme.cardSoft)
                .foregroundStyle(KynexaTheme.primaryText)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay { RoundedRectangle(cornerRadius: 12).stroke(KynexaTheme.border) }
        }
    }

    private func intStepperField(title: String, value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(KynexaTheme.secondaryText)

            HStack(spacing: 0) {
                Button {
                    if value.wrappedValue > range.lowerBound { value.wrappedValue -= 1 }
                } label: {
                    Image(systemName: "minus")
                        .font(.headline)
                        .foregroundStyle(KynexaTheme.primaryText)
                        .frame(width: 40, height: 44)
                }

                Text("\(value.wrappedValue)")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(KynexaTheme.primaryText)
                    .frame(maxWidth: .infinity)
                    .contentTransition(.numericText())

                Button {
                    if value.wrappedValue < range.upperBound { value.wrappedValue += 1 }
                } label: {
                    Image(systemName: "plus")
                        .font(.headline)
                        .foregroundStyle(KynexaTheme.primaryText)
                        .frame(width: 40, height: 44)
                }
            }
            .background(KynexaTheme.cardSoft)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay { RoundedRectangle(cornerRadius: 12).stroke(KynexaTheme.border) }
        }
    }

    private func compactStepper(value: Binding<Int>, range: ClosedRange<Int>, label: String) -> some View {
        HStack(spacing: 0) {
            Button {
                if value.wrappedValue > range.lowerBound { value.wrappedValue -= 1 }
            } label: {
                Image(systemName: "minus")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(KynexaTheme.primaryText)
                    .frame(width: 30, height: 44)
            }

            VStack(spacing: 0) {
                Text("\(value.wrappedValue)")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(KynexaTheme.primaryText)
                    .contentTransition(.numericText())
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(KynexaTheme.tertiaryText)
            }
            .frame(maxWidth: .infinity)

            Button {
                if value.wrappedValue < range.upperBound { value.wrappedValue += 1 }
            } label: {
                Image(systemName: "plus")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(KynexaTheme.primaryText)
                    .frame(width: 30, height: 44)
            }
        }
        .frame(height: 44)
        .background(KynexaTheme.cardSoft)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay { RoundedRectangle(cornerRadius: 12).stroke(KynexaTheme.border) }
    }
}

struct AddExerciseSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onAdd: (WorkoutExercise) -> Void

    @State private var name: String = ""
    @State private var sets: Int = 3
    @State private var reps: Int = 10
    @State private var durationSeconds: Int = 0
    @State private var weight: String = ""
    @State private var notes: String = ""
    @State private var exerciseType: Int = 0

    var body: some View {
        NavigationStack {
            ZStack {
                KynexaTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        ExerciseAutocompleteField(
                            title: "Exercise Name",
                            text: $name,
                            accentColor: KynexaTheme.accent
                        )
                        .zIndex(10)

                        Picker("Type", selection: $exerciseType) {
                            Text("Strength").tag(0)
                            Text("Timed").tag(1)
                            Text("Cardio").tag(2)
                        }
                        .pickerStyle(.segmented)

                        if exerciseType == 0 {
                            HStack(spacing: 16) {
                                stepperField(title: "Sets", value: $sets, range: 1...20)
                                stepperField(title: "Reps", value: $reps, range: 1...100)
                            }
                        } else if exerciseType == 1 {
                            HStack(spacing: 16) {
                                stepperField(title: "Sets", value: $sets, range: 1...20)
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Duration (sec)")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(KynexaTheme.secondaryText)
                                    stepperField(title: "", value: $durationSeconds, range: 5...600)
                                }
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Duration (min)")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(KynexaTheme.secondaryText)
                                let durationMinutes = Binding(
                                    get: { durationSeconds / 60 },
                                    set: { durationSeconds = $0 * 60 }
                                )
                                stepperField(title: "", value: durationMinutes, range: 1...180)
                            }
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Weight / Load")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(KynexaTheme.secondaryText)

                            TextField("e.g. 135 lbs", text: $weight)
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .frame(height: 44)
                                .background(KynexaTheme.cardSoft)
                                .foregroundStyle(KynexaTheme.primaryText)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay { RoundedRectangle(cornerRadius: 12).stroke(KynexaTheme.border) }
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Notes")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(KynexaTheme.secondaryText)

                            TextField("Optional notes...", text: $notes)
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .frame(height: 44)
                                .background(KynexaTheme.cardSoft)
                                .foregroundStyle(KynexaTheme.primaryText)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay { RoundedRectangle(cornerRadius: 12).stroke(KynexaTheme.border) }
                        }

                        Button {
                            let category: ExerciseCategory = exerciseType == 0 ? .strength : exerciseType == 1 ? .timed : .cardio
                            let exercise = WorkoutExercise(
                                name: name.isEmpty ? "New Exercise" : name,
                                sets: sets,
                                reps: exerciseType == 0 ? reps : 0,
                                durationSeconds: exerciseType != 0 ? durationSeconds : 0,
                                weight: weight,
                                notes: notes,
                                category: category,
                                cardioType: exerciseType == 2 ? .run : nil
                            )
                            onAdd(exercise)
                            dismiss()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.subheadline.weight(.bold))
                                Text("Add Exercise")
                                    .font(.headline.weight(.bold))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(KynexaTheme.heroGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(PressScaleButtonStyle())
                        .disabled(name.isEmpty)
                        .opacity(name.isEmpty ? 0.5 : 1)
                    }
                    .padding(20)
                    .padding(.bottom, 36)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(KynexaTheme.secondaryText)
                }
            }
            .toolbarBackground(KynexaTheme.background, for: .navigationBar)
            
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(KynexaTheme.background)
    }

    private func stepperField(title: String, value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if !title.isEmpty {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(KynexaTheme.secondaryText)
            }

            HStack(spacing: 0) {
                Button {
                    if value.wrappedValue > range.lowerBound { value.wrappedValue -= 1 }
                } label: {
                    Image(systemName: "minus")
                        .font(.headline)
                        .foregroundStyle(KynexaTheme.primaryText)
                        .frame(width: 40, height: 44)
                }

                Text("\(value.wrappedValue)")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(KynexaTheme.primaryText)
                    .frame(maxWidth: .infinity)
                    .contentTransition(.numericText())

                Button {
                    if value.wrappedValue < range.upperBound { value.wrappedValue += 1 }
                } label: {
                    Image(systemName: "plus")
                        .font(.headline)
                        .foregroundStyle(KynexaTheme.primaryText)
                        .frame(width: 40, height: 44)
                }
            }
            .background(KynexaTheme.cardSoft)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay { RoundedRectangle(cornerRadius: 12).stroke(KynexaTheme.border) }
        }
    }
}
