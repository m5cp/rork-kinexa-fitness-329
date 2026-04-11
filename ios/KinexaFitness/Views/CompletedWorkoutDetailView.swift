import SwiftUI

struct CompletedWorkoutDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var vm

    let record: CompletedWorkoutRecord

    @State private var exercises: [WorkoutExercise] = []
    @State private var editingExerciseID: UUID?
    @State private var hasChanges: Bool = false
    @State private var saveTrigger: Bool = false
    @State private var shareItem: CompletedWorkoutRecord?
    @State private var showQRSheet: Bool = false
    @State private var showCalendarSync: Bool = false
    @State private var calendarService = CalendarExportService()
    @State private var showExportAlert: Bool = false
    @State private var exportAlertMessage: String = ""
    @State private var showSavedToast: Bool = false


    var body: some View {
        ZStack {
            KinexaTheme.background.ignoresSafeArea()

            if exercises.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "list.bullet.rectangle")
                        .font(.system(size: 44))
                        .foregroundStyle(KinexaTheme.tertiaryText)

                    Text("No Exercise Details")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(KinexaTheme.secondaryText)

                    Text("This workout was logged before exercise details were saved.")
                        .font(.subheadline)
                        .foregroundStyle(KinexaTheme.tertiaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        headerCard
                        progressSummary

                        ForEach(Array(exercises.enumerated()), id: \.element.id) { index, _ in
                            exerciseCard(index: index)
                        }

                        if hasChanges {
                            saveButton
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 40)
                    .adaptiveContainer()
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .navigationTitle(record.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(KinexaTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    Button {
                        shareItem = CompletedWorkoutRecord(
                            date: record.date,
                            title: record.title,
                            exerciseCount: exercises.count,
                            exercises: exercises,
                            source: record.source
                        )
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(KinexaTheme.accent)
                    }

                    if hasChanges {
                        Button("Save") {
                            saveChanges()
                        }
                        .foregroundStyle(KinexaTheme.accent)
                        .fontWeight(.semibold)
                    }
                }
            }
        }
        .onAppear {
            exercises = record.exercises
        }
        .sheet(item: $shareItem) { item in
            CompletedWorkoutShareSheet(record: item)
        }
        .sheet(isPresented: $showQRSheet) {
            let workout = WorkoutDay(
                dayIndex: -1,
                date: record.date,
                title: record.title,
                exercises: record.exercises,
                isCompleted: true,
                source: record.source
            )
            WorkoutQRSheet(workout: workout, workoutType: record.source.rawValue)
        }
        .alert("Calendar", isPresented: $showExportAlert) {
            Button("OK") {}
        } message: {
            Text(exportAlertMessage)
        }
        .overlay {
            if showSavedToast {
                VStack {
                    Spacer()
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(KinexaTheme.success)
                        Text("Saved to Photos")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(.bottom, 40)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showSavedToast)
            }
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(record.title)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)

                    HStack(spacing: 8) {
                        Label(record.source.rawValue, systemImage: sourceIcon)
                        Text("\u{00b7}")
                        Text(formatDate(record.date))
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(KinexaTheme.tertiaryText)
                }

                Spacer()

                Image(systemName: "checkmark.seal.fill")
                    .font(.title2)
                    .foregroundStyle(KinexaTheme.success)
            }

            unifiedActionRow
        }
        .padding(18)
        .premiumCard()
    }

    private var unifiedActionRow: some View {
        HStack(spacing: 8) {
            actionButton(icon: "square.and.arrow.up", label: "Share") {
                shareItem = CompletedWorkoutRecord(
                    date: record.date,
                    title: record.title,
                    exerciseCount: exercises.count,
                    exercises: exercises,
                    source: record.source
                )
            }

            actionButton(icon: "photo.on.rectangle.angled", label: "Save") {
                let saved = ShareCardRenderer.saveToPhotos(
                    cardType: .completedWorkout(record: CompletedWorkoutRecord(
                        date: record.date,
                        title: record.title,
                        exerciseCount: exercises.count,
                        exercises: exercises,
                        source: record.source
                    ))
                )
                if saved {
                    showSavedToast = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showSavedToast = false
                    }
                }
            }

            actionButton(icon: "qrcode", label: "QR") {
                showQRSheet = true
            }

            actionButton(icon: "calendar.badge.plus", label: "Calendar") {
                let workout = WorkoutDay(
                    dayIndex: -1,
                    date: record.date,
                    title: record.title,
                    exercises: record.exercises,
                    isCompleted: true,
                    source: record.source
                )
                Task {
                    let result = await calendarService.exportWorkout(workout)
                    switch result {
                    case .success(let count):
                        exportAlertMessage = "\(count) workout\(count == 1 ? "" : "s") synced."
                    case .partial(let exported, let failed):
                        exportAlertMessage = "\(exported) exported, \(failed) failed."
                    case .denied:
                        exportAlertMessage = "Calendar access denied. Go to Settings to enable."
                    case .error(let message):
                        exportAlertMessage = "Sync failed: \(message)"
                    }
                    showExportAlert = true
                }
            }
        }
    }

    private func actionButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(KinexaTheme.accent)
                    .frame(width: 36, height: 36)
                    .background(KinexaTheme.accent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Text(label)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(KinexaTheme.secondaryText)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    private var sourceIcon: String {
        switch record.source {
        case .individual: return "figure.strengthtraining.traditional"
        case .unit: return "person.3.fill"
        case .wod: return "bolt.fill"
        case .random: return "shuffle"
        case .imported: return "square.and.arrow.down"
        }
    }

    private var progressSummary: some View {
        let completed = exercises.filter(\.isCompleted).count
        let total = exercises.count
        let progress: Double = total > 0 ? Double(completed) / Double(total) : 0

        return HStack(spacing: 0) {
            VStack(spacing: 4) {
                Text("\(completed)/\(total)")
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)
                Text("Completed")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }
            .frame(maxWidth: .infinity)

            Rectangle()
                .fill(KinexaTheme.border)
                .frame(width: 1, height: 32)

            VStack(spacing: 4) {
                Text("\(Int(progress * 100))%")
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundStyle(KinexaTheme.accent)
                Text("Progress")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 14)
        .premiumCard()
    }

    private func exerciseCard(index: Int) -> some View {
        let exercise = exercises[index]
        let isEditing = editingExerciseID == exercise.id

        return VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    editingExerciseID = isEditing ? nil : exercise.id
                }
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(exercise.isCompleted ? KinexaTheme.success : KinexaTheme.cardSoft)
                            .frame(width: 36, height: 36)

                        if exercise.isCompleted {
                            Image(systemName: "checkmark")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                        } else {
                            Text("\(index + 1)")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(KinexaTheme.tertiaryText)
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            if exercise.isCardio, let ct = exercise.cardioType {
                                Image(systemName: ct.icon)
                                    .font(.caption)
                                    .foregroundStyle(KinexaTheme.accent)
                            }
                            Text(exercise.name)
                                .font(.headline)
                                .foregroundStyle(KinexaTheme.primaryText)
                        }

                        Text(exercise.displayDetail)
                            .font(.subheadline)
                            .foregroundStyle(KinexaTheme.secondaryText)
                    }

                    Spacer()

                    Image(systemName: isEditing ? "chevron.up" : "pencil")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(KinexaTheme.accent)
                }
                .padding(16)
            }
            .buttonStyle(.plain)

            if isEditing {
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
                timedEditor(index: index)
            } else {
                strengthEditor(index: index)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Notes")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(KinexaTheme.secondaryText)

                TextField("Add notes...", text: Binding(
                    get: { exercises[index].notes },
                    set: { exercises[index].notes = $0; hasChanges = true }
                ))
                .font(.subheadline)
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(KinexaTheme.cardSoft)
                .foregroundStyle(KinexaTheme.primaryText)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay { RoundedRectangle(cornerRadius: 12).stroke(KinexaTheme.border) }
            }

            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    exercises[index].isCompleted.toggle()
                    hasChanges = true
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: exercises[index].isCompleted ? "arrow.uturn.backward" : "checkmark.circle.fill")
                        .font(.caption.weight(.bold))
                    Text(exercises[index].isCompleted ? "Mark Incomplete" : "Mark Complete")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(exercises[index].isCompleted ? KinexaTheme.secondaryText : KinexaTheme.success)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(exercises[index].isCompleted ? KinexaTheme.cardSoft : KinexaTheme.success.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
    }

    private func strengthEditor(index: Int) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                stepperField(title: "Sets", value: Binding(
                    get: { exercises[index].sets },
                    set: { exercises[index].sets = $0; hasChanges = true }
                ), range: 1...20)

                stepperField(title: "Reps", value: Binding(
                    get: { exercises[index].reps },
                    set: { exercises[index].reps = $0; hasChanges = true }
                ), range: 1...100)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Weight")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(KinexaTheme.secondaryText)

                TextField("e.g. 135 lbs", text: Binding(
                    get: { exercises[index].weight },
                    set: { exercises[index].weight = $0; hasChanges = true }
                ))
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

    private func timedEditor(index: Int) -> some View {
        HStack(spacing: 16) {
            stepperField(title: "Sets", value: Binding(
                get: { exercises[index].sets },
                set: { exercises[index].sets = $0; hasChanges = true }
            ), range: 1...20)

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
                            hasChanges = true
                        }
                    ), range: 0...120, label: "min")

                    compactStepper(value: Binding(
                        get: { exercises[index].durationSeconds % 60 },
                        set: {
                            let mins = exercises[index].durationSeconds / 60
                            exercises[index].durationSeconds = mins * 60 + $0
                            hasChanges = true
                        }
                    ), range: 0...59, label: "sec")
                }
            }
        }
    }

    private func cardioEditor(index: Int) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Duration (min)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(KinexaTheme.secondaryText)

                    compactStepper(value: Binding(
                        get: { exercises[index].durationSeconds / 60 },
                        set: { exercises[index].durationSeconds = $0 * 60; hasChanges = true }
                    ), range: 1...180, label: "min")
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Distance (mi)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(KinexaTheme.secondaryText)

                    TextField("0.0", text: Binding(
                        get: { exercises[index].distanceMiles.map { String(format: "%.1f", $0) } ?? "" },
                        set: { exercises[index].distanceMiles = Double($0); hasChanges = true }
                    ))
                    .keyboardType(.decimalPad)
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .background(KinexaTheme.cardSoft)
                    .foregroundStyle(KinexaTheme.primaryText)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay { RoundedRectangle(cornerRadius: 12).stroke(KinexaTheme.border) }
                }
            }

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Speed (mph)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(KinexaTheme.secondaryText)

                    TextField("0.0", text: Binding(
                        get: { exercises[index].speedMph.map { String(format: "%.1f", $0) } ?? "" },
                        set: { exercises[index].speedMph = Double($0); hasChanges = true }
                    ))
                    .keyboardType(.decimalPad)
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .background(KinexaTheme.cardSoft)
                    .foregroundStyle(KinexaTheme.primaryText)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay { RoundedRectangle(cornerRadius: 12).stroke(KinexaTheme.border) }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Calories")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(KinexaTheme.secondaryText)

                    TextField("0", text: Binding(
                        get: { exercises[index].caloriesBurned.map { "\($0)" } ?? "" },
                        set: { exercises[index].caloriesBurned = Int($0); hasChanges = true }
                    ))
                    .keyboardType(.numberPad)
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
    }

    private func stepperField(title: String, value: Binding<Int>, range: ClosedRange<Int>) -> some View {
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

    private var saveButton: some View {
        Button {
            saveTrigger.toggle()
            saveChanges()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.down")
                    .font(.subheadline.weight(.bold))
                Text("Save Changes")
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .frame(height: 52)
            .frame(maxWidth: .infinity)
            .background(KinexaTheme.accent)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .sensoryFeedback(.impact(weight: .light), trigger: saveTrigger)
        .buttonStyle(PressScaleButtonStyle())
    }

    private func saveChanges() {
        vm.updateCompletedRecord(id: record.id, exercises: exercises)
        hasChanges = false
    }

    private func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d, h:mm a"
        return f.string(from: date)
    }
}
