import SwiftUI

struct LogStrengthWorkoutSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var vm

    @State private var workoutTitle: String = ""
    @State private var exercises: [MutableExerciseEntry] = [MutableExerciseEntry()]
    @State private var logTrigger: Bool = false
    @FocusState private var focusedField: FieldFocus?

    enum FieldFocus: Hashable {
        case title
        case exerciseName(Int)
        case sets(Int)
        case reps(Int)
        case weight(Int)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    titleSection
                    exercisesSection
                    addExerciseButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(KinexaTheme.background.ignoresSafeArea())
            .navigationTitle("Log Strength Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(KinexaTheme.background, for: .navigationBar)
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(KinexaTheme.secondaryText)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveWorkout() }
                        .font(.headline.weight(.bold))
                        .foregroundStyle(KinexaTheme.accent)
                        .disabled(exercises.allSatisfy { $0.name.isEmpty })
                }
            }
            .safeAreaInset(edge: .bottom) {
                saveBottomBar
            }
            .sensoryFeedback(.success, trigger: logTrigger)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(KinexaTheme.background)
        .presentationContentInteraction(.scrolls)
        .onAppear {
            focusedField = .title
        }
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("WORKOUT NAME")
                .font(.caption.weight(.heavy))
                .tracking(1.2)
                .foregroundStyle(KinexaTheme.tertiaryText)

            TextField("e.g. Push Day, Leg Day, Full Body", text: $workoutTitle)
                .font(.body)
                .foregroundStyle(KinexaTheme.primaryText)
                .focused($focusedField, equals: .title)
                .padding(14)
                .background(KinexaTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14).stroke(KinexaTheme.border)
                }
        }
    }

    private var exercisesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("EXERCISES")
                .font(.caption.weight(.heavy))
                .tracking(1.2)
                .foregroundStyle(KinexaTheme.tertiaryText)

            ForEach(Array(exercises.enumerated()), id: \.element.id) { index, entry in
                exerciseCard(index: index, entry: entry)
            }
        }
    }

    private func exerciseCard(index: Int, entry: MutableExerciseEntry) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("#\(index + 1)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(KinexaTheme.accent)
                    .frame(width: 28, height: 28)
                    .background(KinexaTheme.accent.opacity(0.12))
                    .clipShape(Circle())

                TextField("Exercise name", text: exerciseBinding(index: index, keyPath: \.name))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(KinexaTheme.primaryText)
                    .focused($focusedField, equals: .exerciseName(index))
                    .onChange(of: safeElement(from: exercises, at: index)?.name ?? "") { _, newValue in
                        prefillWeight(index: index, name: newValue)
                    }

                if exercises.count > 1 {
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            let _ = exercises.remove(at: index)
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(KinexaTheme.tertiaryText)
                    }
                }
            }

            HStack(spacing: 10) {
                compactField(label: "Sets", text: exerciseBinding(index: index, keyPath: \.setsText), focus: .sets(index))
                compactField(label: "Reps", text: exerciseBinding(index: index, keyPath: \.repsText), focus: .reps(index))
                weightField(index: index)
            }

            if let suggestion = safeElement(from: exercises, at: index)?.suggestedWeight, !suggestion.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 9, weight: .bold))
                    Text("Last time: \(suggestion)")
                        .font(.caption2.weight(.medium))
                }
                .foregroundStyle(KinexaTheme.accent.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(14)
        .background(KinexaTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16).stroke(KinexaTheme.border)
        }
    }

    private func compactField(label: String, text: Binding<String>, focus: FieldFocus) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(KinexaTheme.tertiaryText)
            TextField("0", text: text)
                .keyboardType(.numberPad)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(KinexaTheme.primaryText)
                .multilineTextAlignment(.center)
                .focused($focusedField, equals: focus)
                .frame(height: 36)
                .background(KinexaTheme.cardSoft)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private func weightField(index: Int) -> some View {
        VStack(spacing: 4) {
            Text("Weight")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(KinexaTheme.tertiaryText)
            TextField("lbs", text: exerciseBinding(index: index, keyPath: \.weightText))
                .keyboardType(.default)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(KinexaTheme.primaryText)
                .multilineTextAlignment(.center)
                .focused($focusedField, equals: .weight(index))
                .frame(height: 36)
                .background(
                    safeElement(from: exercises, at: index)?.suggestedWeight != nil && safeElement(from: exercises, at: index)?.weightText == safeElement(from: exercises, at: index)?.suggestedWeight
                    ? KinexaTheme.accent.opacity(0.08) : KinexaTheme.cardSoft
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay {
                    if safeElement(from: exercises, at: index)?.suggestedWeight != nil && safeElement(from: exercises, at: index)?.weightText == safeElement(from: exercises, at: index)?.suggestedWeight {
                        RoundedRectangle(cornerRadius: 10).stroke(KinexaTheme.accent.opacity(0.3))
                    }
                }
        }
    }

    private var addExerciseButton: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                let newEntry = MutableExerciseEntry()
                exercises.append(newEntry)
                focusedField = .exerciseName(exercises.count - 1)
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.subheadline.weight(.bold))
                Text("Add Exercise")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(KinexaTheme.accent)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(KinexaTheme.accent.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14).stroke(KinexaTheme.accent.opacity(0.2))
            }
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    private var saveBottomBar: some View {
        Button {
            saveWorkout()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.subheadline.weight(.bold))
                Text("Save Workout")
                    .font(.headline.weight(.bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(KinexaTheme.heroGradient)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(PressScaleButtonStyle())
        .disabled(exercises.allSatisfy { $0.name.isEmpty })
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
        .background(.bar)
    }

    private func exerciseBinding(index: Int, keyPath: WritableKeyPath<MutableExerciseEntry, String>) -> Binding<String> {
        Binding(
            get: { safeElement(from: exercises, at: index)?[keyPath: keyPath] ?? "" },
            set: { newValue in
                guard index < exercises.count else { return }
                exercises[index][keyPath: keyPath] = newValue
            }
        )
    }

    private func prefillWeight(index: Int, name: String) {
        guard index >= 0, index < exercises.count, name.count >= 3 else { return }
        if let remembered = ExerciseWeightMemory.suggestedWeight(for: name) {
            exercises[index].suggestedWeight = remembered
            if exercises[index].weightText.isEmpty {
                exercises[index].weightText = remembered
            }
        }
    }

    private func saveWorkout() {
        let validExercises = exercises.filter { !$0.name.isEmpty }
        guard !validExercises.isEmpty else { return }

        let title = workoutTitle.isEmpty ? "Strength Workout" : workoutTitle

        let workoutExercises = validExercises.map { entry in
            WorkoutExercise(
                name: entry.name,
                sets: Int(entry.setsText) ?? 3,
                reps: Int(entry.repsText) ?? 10,
                weight: entry.weightText,
                isCompleted: true,
                category: .strength
            )
        }

        ExerciseWeightMemory.recordWorkout(workoutExercises)

        let workout = WorkoutDay(
            dayIndex: -1,
            date: .now,
            title: title,
            exercises: workoutExercises,
            isCompleted: true,
            templateTag: "manual_strength",
            tags: ["Strength", "Manual Log"],
            source: .individual
        )

        vm.completeStandaloneWorkout(workout)
        logTrigger.toggle()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            dismiss()
        }
    }
}

struct MutableExerciseEntry: Identifiable {
    let id = UUID()
    var name: String = ""
    var setsText: String = "3"
    var repsText: String = "10"
    var weightText: String = ""
    var suggestedWeight: String?
}

private func safeElement<T>(from array: [T], at index: Int) -> T? {
    index >= 0 && index < array.count ? array[index] : nil
}
