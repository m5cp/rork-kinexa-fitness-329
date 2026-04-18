import SwiftUI

struct StandaloneWorkoutSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var vm

    let workout: WorkoutDay
    let sheetTitle: String

    @State private var exercises: [WorkoutExercise] = []
    @State private var expandedID: UUID?
    @State private var didComplete = false
    @State private var showQRSheet = false


    var body: some View {
        NavigationStack {
            ZStack {
                KinexaTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        headerSection
                        progressSection

                        ForEach(Array(exercises.enumerated()), id: \.element.id) { index, _ in
                            exerciseCard(index: index)
                        }

                        completeButton
                    }
                    .padding(20)
                    .padding(.bottom, 36)
                    .adaptiveContainer()
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle(sheetTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(KinexaTheme.primaryText)
                }
            }
            .toolbarBackground(KinexaTheme.background, for: .navigationBar)
            
            .sheet(isPresented: $showQRSheet) {
                WorkoutQRSheet(workout: workout, workoutType: sheetTitle)
            }

        }
        .onAppear {
            exercises = workout.exercises
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(workout.title)
                .font(.title2.weight(.bold))
                .foregroundStyle(KinexaTheme.primaryText)

            HStack(spacing: 16) {
                Label("\(exercises.count) exercises", systemImage: "list.bullet")
                    .font(.subheadline)
                    .foregroundStyle(KinexaTheme.secondaryText)

                if vm.pedometer.todaySteps > 0 {
                    Label("\(vm.pedometer.todaySteps) steps", systemImage: "figure.walk")
                        .font(.subheadline)
                        .foregroundStyle(KinexaTheme.secondaryText)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .premiumCard()
    }

    private var progressSection: some View {
        let completed = exercises.filter(\.isCompleted).count
        let total = exercises.count
        let progress: Double = total > 0 ? Double(completed) / Double(total) : 0

        return HStack {
            Text("\(completed)/\(total) done")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(KinexaTheme.primaryText)

            Spacer()

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(KinexaTheme.cardSoft)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(KinexaTheme.heroGradient)
                        .frame(width: geo.size.width * progress)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: progress)
                }
            }
            .frame(width: 120, height: 6)

            Text("\(Int(progress * 100))%")
                .font(.caption.weight(.bold))
                .foregroundStyle(KinexaTheme.accent)
        }
        .padding(14)
        .premiumCard()
    }

    private func exerciseCard(index: Int) -> some View {
        let exercise = exercises[index]
        let isExpanded = expandedID == exercise.id

        return VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    expandedID = isExpanded ? nil : exercise.id
                }
            } label: {
                HStack(spacing: 14) {
                    Button {
                        exercises[index].isCompleted.toggle()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(exercise.isCompleted ? KinexaTheme.success : KinexaTheme.cardSoft)
                                .frame(width: 34, height: 34)
                            if exercise.isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .buttonStyle(.plain)

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            if exercise.isCardio, let ct = exercise.cardioType {
                                Image(systemName: ct.icon)
                                    .font(.caption)
                                    .foregroundStyle(KinexaTheme.accent)
                            }
                            Text(exercise.name)
                                .font(.headline)
                                .foregroundStyle(exercise.isCompleted ? KinexaTheme.secondaryText : KinexaTheme.primaryText)
                                .strikethrough(exercise.isCompleted, color: KinexaTheme.secondaryText)
                        }
                        Text(exercise.displayDetail)
                            .font(.subheadline)
                            .foregroundStyle(KinexaTheme.secondaryText)

                        if !exercise.weight.isEmpty {
                            Text(exercise.weight)
                                .font(.caption)
                                .foregroundStyle(KinexaTheme.tertiaryText)
                        }
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "pencil")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(KinexaTheme.accent)
                }
                .padding(16)
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider().overlay(KinexaTheme.border)

                exerciseEditor(index: index)
                    .padding(16)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .premiumCard()
    }

    private func exerciseEditor(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            if exercises[index].isCardio {
                cardioEditor(index: index)
            } else if exercises[index].isTimeBased {
                HStack(spacing: 16) {
                    intStepper(title: "Sets", value: $exercises[index].sets, range: 1...20)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Duration")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(KinexaTheme.secondaryText)

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
            } else {
                HStack(spacing: 16) {
                    intStepper(title: "Sets", value: $exercises[index].sets, range: 1...20)
                    intStepper(title: "Reps", value: $exercises[index].reps, range: 1...100)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Weight")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(KinexaTheme.secondaryText)

                    TextField("e.g. 135 lbs", text: $exercises[index].weight)
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .frame(height: 44)
                        .background(KinexaTheme.cardSoft)
                        .foregroundStyle(KinexaTheme.primaryText)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay { RoundedRectangle(cornerRadius: 12).stroke(KinexaTheme.border) }
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Notes")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(KinexaTheme.secondaryText)

                TextField("Add notes...", text: $exercises[index].notes)
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .background(KinexaTheme.cardSoft)
                    .foregroundStyle(KinexaTheme.primaryText)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay { RoundedRectangle(cornerRadius: 12).stroke(KinexaTheme.border) }
            }
        }
    }

    private func cardioEditor(index: Int) -> some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Cardio Type")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(KinexaTheme.secondaryText)

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
                                .foregroundStyle(selected ? .white : KinexaTheme.primaryText)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 7)
                                .background(selected ? KinexaTheme.accent : KinexaTheme.cardSoft)
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Duration (min)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(KinexaTheme.secondaryText)

                    compactStepper(value: Binding(
                        get: { exercises[index].durationSeconds / 60 },
                        set: { exercises[index].durationSeconds = $0 * 60 }
                    ), range: 1...180, label: "min")
                }

                numericField(title: "Distance (mi)", text: Binding(
                    get: { exercises[index].distanceMiles.map { String(format: "%.1f", $0) } ?? "" },
                    set: { exercises[index].distanceMiles = Double($0) }
                ), keyboard: .decimalPad)
            }

            HStack(spacing: 12) {
                numericField(title: "Speed (mph)", text: Binding(
                    get: { exercises[index].speedMph.map { String(format: "%.1f", $0) } ?? "" },
                    set: { exercises[index].speedMph = Double($0) }
                ), keyboard: .decimalPad)

                numericField(title: "Calories", text: Binding(
                    get: { exercises[index].caloriesBurned.map { "\($0)" } ?? "" },
                    set: { exercises[index].caloriesBurned = Int($0) }
                ), keyboard: .numberPad)
            }

            Button {
                exercises[index].stepsLogged = vm.pedometer.todaySteps
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "figure.walk")
                    Text("Sync Steps (\(vm.pedometer.todaySteps))")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(KinexaTheme.accent)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(KinexaTheme.accent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)

            if let steps = exercises[index].stepsLogged, steps > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(KinexaTheme.success)
                    Text("\(steps) steps synced")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(KinexaTheme.secondaryText)
                }
            }
        }
    }

    private var completeButton: some View {
        VStack(spacing: 12) {
            if !didComplete {
                Button {
                    vm.completeStandaloneWorkout(workout)
                    didComplete = true
                } label: {
                    Text("Complete Workout")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(height: 52)
                        .frame(maxWidth: .infinity)
                        .background(KinexaTheme.heroGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: KinexaTheme.accent.opacity(0.28), radius: 14, y: 8)
                }
                .buttonStyle(PressScaleButtonStyle())
                .sensoryFeedback(.success, trigger: didComplete)
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(KinexaTheme.success)
                    Text("Workout Complete")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(KinexaTheme.success)
                }
                .frame(height: 52)
                .frame(maxWidth: .infinity)
            }

            HStack(spacing: 10) {
                Button {
                    showQRSheet = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "qrcode")
                            .font(.caption.weight(.bold))
                        Text("QR")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(KinexaTheme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(KinexaTheme.cardSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12).stroke(KinexaTheme.border)
                    }
                }
                .buttonStyle(PressScaleButtonStyle())

                Button {
                    ShareCardRenderer.presentShareSheet(
                        cardType: .workout(title: workout.title, exercises: workout.exercises, tags: workout.tags)
                    )
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.caption.weight(.bold))
                        Text("Share")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(KinexaTheme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(KinexaTheme.cardSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12).stroke(KinexaTheme.border)
                    }
                }
                .buttonStyle(PressScaleButtonStyle())
            }
        }
    }

    private func intStepper(title: String, value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(KinexaTheme.secondaryText)

            HStack(spacing: 0) {
                Button {
                    if value.wrappedValue > range.lowerBound { value.wrappedValue -= 1 }
                } label: {
                    Image(systemName: "minus")
                        .font(.headline)
                        .foregroundStyle(KinexaTheme.primaryText)
                        .frame(width: 40, height: 44)
                }
                Text("\(value.wrappedValue)")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)
                    .frame(maxWidth: .infinity)
                    .contentTransition(.numericText())
                Button {
                    if value.wrappedValue < range.upperBound { value.wrappedValue += 1 }
                } label: {
                    Image(systemName: "plus")
                        .font(.headline)
                        .foregroundStyle(KinexaTheme.primaryText)
                        .frame(width: 40, height: 44)
                }
            }
            .background(KinexaTheme.cardSoft)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay { RoundedRectangle(cornerRadius: 12).stroke(KinexaTheme.border) }
        }
    }

    private func compactStepper(value: Binding<Int>, range: ClosedRange<Int>, label: String) -> some View {
        HStack(spacing: 0) {
            Button {
                if value.wrappedValue > range.lowerBound { value.wrappedValue -= 1 }
            } label: {
                Image(systemName: "minus")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)
                    .frame(width: 30, height: 44)
            }
            VStack(spacing: 0) {
                Text("\(value.wrappedValue)")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)
                    .contentTransition(.numericText())
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }
            .frame(maxWidth: .infinity)
            Button {
                if value.wrappedValue < range.upperBound { value.wrappedValue += 1 }
            } label: {
                Image(systemName: "plus")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)
                    .frame(width: 30, height: 44)
            }
        }
        .frame(height: 44)
        .background(KinexaTheme.cardSoft)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay { RoundedRectangle(cornerRadius: 12).stroke(KinexaTheme.border) }
    }

    private func numericField(title: String, text: Binding<String>, keyboard: UIKeyboardType) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(KinexaTheme.secondaryText)

            TextField("0", text: text)
                .keyboardType(keyboard)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(KinexaTheme.cardSoft)
                .foregroundStyle(KinexaTheme.primaryText)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay { RoundedRectangle(cornerRadius: 12).stroke(KinexaTheme.border) }
        }
    }
}
