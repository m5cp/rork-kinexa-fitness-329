import SwiftUI

struct PreMadeRoutinesView: View {
    @Environment(\.dismiss) private var dismiss
    let onAddExercise: (ManualRoutineExercise) -> Void

    @State private var searchText: String = ""
    @State private var showMode: RoutineBrowseMode = .levels
    @State private var selectedRoutine: PreMadeRoutine?
    @State private var addedTrigger: Bool = false

    private enum RoutineBrowseMode: Equatable {
        case levels
        case levelDetail(RoutineLevel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                KinexaTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        disclaimerBanner

                        if !searchText.isEmpty {
                            searchResults
                        } else {
                            switch showMode {
                            case .levels:
                                levelHeroCards
                            case .levelDetail(let level):
                                levelRoutineList(level)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 48)
                }
            }
            .navigationTitle(navTitle)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search routines")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if case .levelDetail = showMode, searchText.isEmpty {
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                showMode = .levels
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.caption.weight(.bold))
                                Text("Back")
                                    .font(.subheadline.weight(.medium))
                            }
                            .foregroundStyle(KinexaTheme.accent)
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(KinexaTheme.primaryText)
                }
            }
            .toolbarBackground(KinexaTheme.background, for: .navigationBar)
            
            .sensoryFeedback(.impact(weight: .light), trigger: addedTrigger)
            .sheet(item: $selectedRoutine) { routine in
                PreMadeRoutineDetailSheet(routine: routine, onAddExercise: onAddExercise)
            }
        }
    }

    private var navTitle: String {
        switch showMode {
        case .levels: return "Pre-made Routines"
        case .levelDetail(let level): return level.rawValue
        }
    }

    private var disclaimerBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "info.circle.fill")
                .font(.caption)
                .foregroundStyle(Color(hex: "#6366F1").opacity(0.7))

            Text("These are open source muscle group exercises blended together by traditional splits. They are not a recommendation or guide. For tracking and accountability only.")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(KinexaTheme.tertiaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .background(Color(hex: "#6366F1").opacity(0.06))
        .clipShape(.rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#6366F1").opacity(0.1))
        }
    }

    private var levelHeroCards: some View {
        VStack(spacing: 14) {
            levelHeroCard(
                level: .beginner,
                gradient: [Color(hex: "#22C55E"), Color(hex: "#16A34A")],
                icon: "figure.walk",
                routines: PreMadeRoutineLibrary.beginnerRoutines
            )

            levelHeroCard(
                level: .intermediate,
                gradient: [Color(hex: "#F59E0B"), Color(hex: "#D97706")],
                icon: "figure.strengthtraining.traditional",
                routines: PreMadeRoutineLibrary.intermediateRoutines
            )

            levelHeroCard(
                level: .advanced,
                gradient: [Color(hex: "#EF4444"), Color(hex: "#DC2626")],
                icon: "figure.strengthtraining.functional",
                routines: PreMadeRoutineLibrary.advancedRoutines
            )
        }
    }

    private func levelHeroCard(level: RoutineLevel, gradient: [Color], icon: String, routines: [PreMadeRoutine]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    showMode = .levelDetail(level)
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(.white.opacity(0.18))
                        .clipShape(.rect(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 3) {
                        Text(level.rawValue)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)

                        Text("\(routines.count) routines")
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
            }
            .buttonStyle(.plain)

            VStack(spacing: 0) {
                ForEach(Array(routines.enumerated()), id: \.element.id) { idx, routine in
                    if idx > 0 {
                        Divider().overlay(KinexaTheme.border)
                    }
                    Button {
                        selectedRoutine = routine
                    } label: {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(routine.name)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(KinexaTheme.primaryText)
                                    .lineLimit(1)

                                HStack(spacing: 6) {
                                    Text("\(routine.daysPerWeek) days/wk")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(gradient.first ?? .green)
                                    Text(routine.splitType.rawValue)
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundStyle(KinexaTheme.tertiaryText)
                                }
                            }

                            Spacer(minLength: 0)

                            Image(systemName: "chevron.right")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(KinexaTheme.tertiaryText)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.plain)
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

    private func levelRoutineList(_ level: RoutineLevel) -> some View {
        let routines = PreMadeRoutineLibrary.routines(for: level)
        return LazyVStack(spacing: 12) {
            ForEach(routines) { routine in
                routineCard(routine)
            }
        }
    }

    private var searchResults: some View {
        let filtered = PreMadeRoutineLibrary.search(searchText)
        return VStack(spacing: 12) {
            if filtered.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.title)
                        .foregroundStyle(KinexaTheme.tertiaryText)
                    Text("No routines found")
                        .font(.subheadline)
                        .foregroundStyle(KinexaTheme.secondaryText)
                }
                .padding(.top, 40)
            } else {
                ForEach(filtered) { routine in
                    routineCard(routine)
                }
            }
        }
    }

    private func routineCard(_ routine: PreMadeRoutine) -> some View {
        Button {
            selectedRoutine = routine
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: routine.splitType.icon)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            LinearGradient(
                                colors: levelGradient(routine.level),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(.rect(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(routine.name)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(KinexaTheme.primaryText)
                            .multilineTextAlignment(.leading)

                        Text(routine.routineDescription)
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(KinexaTheme.tertiaryText)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                        .padding(.top, 4)
                }

                HStack(spacing: 6) {
                    tagBadge(text: "\(routine.daysPerWeek) days/wk", color: Color(hex: "#6366F1"))
                    tagBadge(text: "\(routine.durationWeeks) weeks", color: Color(hex: "#8B5CF6"))
                    tagBadge(text: routine.level.rawValue, color: levelColor(routine.level))
                    tagBadge(text: routine.splitType.rawValue, color: Color(hex: "#0EA5E9"))
                }
            }
            .padding(16)
            .background(KinexaTheme.card)
            .clipShape(.rect(cornerRadius: 16))
            .elevatedCardShadow()
            .overlay {
                RoundedRectangle(cornerRadius: 16).stroke(KinexaTheme.border)
            }
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    private func tagBadge(text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .clipShape(.capsule)
    }

    private func levelColor(_ level: RoutineLevel) -> Color {
        switch level {
        case .beginner: return KinexaTheme.success
        case .intermediate: return KinexaTheme.warning
        case .advanced: return KinexaTheme.danger
        case .allLevels: return Color(hex: "#6366F1")
        }
    }

    private func levelGradient(_ level: RoutineLevel) -> [Color] {
        switch level {
        case .beginner: return [Color(hex: "#22C55E"), Color(hex: "#16A34A")]
        case .intermediate: return [Color(hex: "#F59E0B"), Color(hex: "#D97706")]
        case .advanced: return [Color(hex: "#EF4444"), Color(hex: "#DC2626")]
        case .allLevels: return [Color(hex: "#6366F1"), Color(hex: "#4338CA")]
        }
    }
}

// MARK: - Editable Premade Detail Sheet

struct PreMadeRoutineDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var appVM
    let routine: PreMadeRoutine
    let onAddExercise: (ManualRoutineExercise) -> Void

    @State private var addedTrigger: Bool = false
    @State private var editableDays: [EditableDay] = []
    @State private var hasEdits: Bool = false
    @State private var swapTarget: SwapTarget?
    @State private var addTargetDayIndex: Int?
    @State private var showSaveDecision: Bool = false
    @State private var saveTrigger: Bool = false

    struct EditableDay: Identifiable, Hashable {
        let id: UUID
        var dayName: String
        var focus: String
        var exercises: [ManualRoutineExercise]
    }

    struct SwapTarget: Identifiable {
        let id = UUID()
        let dayIndex: Int
        let exerciseIndex: Int
        let bodyPart: WeightBodyPart?
    }

    var body: some View {
        NavigationStack {
            ZStack {
                KinexaTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        routineHeader

                        ForEach(Array(editableDays.enumerated()), id: \.element.id) { dayIdx, day in
                            dayCard(day, dayIndex: dayIdx)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 48)
                }
            }
            .navigationTitle(routine.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if hasEdits {
                            showSaveDecision = true
                        } else {
                            activateAsIs()
                            dismiss()
                        }
                    } label: {
                        Text(hasEdits ? "Save" : "Use Plan")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(KinexaTheme.accent)
                    }
                }
            }
            .toolbarBackground(KinexaTheme.background, for: .navigationBar)
            .sensoryFeedback(.impact(weight: .light), trigger: addedTrigger)
            .sensoryFeedback(.success, trigger: saveTrigger)
            .onAppear(perform: loadEditable)
            .sheet(item: $swapTarget) { target in
                ExerciseSwapPickerSheet(
                    suggestedBodyPart: target.bodyPart,
                    onPick: { newExercise in
                        editableDays[target.dayIndex].exercises[target.exerciseIndex] = newExercise
                        hasEdits = true
                    }
                )
            }
            .sheet(isPresented: Binding(
                get: { addTargetDayIndex != nil },
                set: { if !$0 { addTargetDayIndex = nil } }
            )) {
                ExerciseSwapPickerSheet(
                    suggestedBodyPart: nil,
                    onPick: { newExercise in
                        if let idx = addTargetDayIndex {
                            editableDays[idx].exercises.append(newExercise)
                            hasEdits = true
                        }
                    }
                )
            }
            .confirmationDialog("Save Changes", isPresented: $showSaveDecision, titleVisibility: .visible) {
                Button("Save as New Routine") {
                    saveAsCopy()
                    saveTrigger.toggle()
                    dismiss()
                }
                Button("Use for This Week Only") {
                    activateEdited()
                    saveTrigger.toggle()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You've modified this routine. Save as a new custom routine, or use these changes for this week only (original stays intact).")
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(KinexaTheme.background)
    }

    private var routineHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(routine.routineDescription)
                .font(.subheadline)
                .foregroundStyle(KinexaTheme.secondaryText)

            HStack(spacing: 8) {
                infoPill(text: "\(routine.daysPerWeek) days/wk", color: Color(hex: "#6366F1"))
                infoPill(text: "\(routine.durationWeeks) weeks", color: Color(hex: "#8B5CF6"))
                infoPill(text: routine.splitType.rawValue, color: Color(hex: "#0EA5E9"))
            }
        }
    }

    private func infoPill(text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }

    private func dayCard(_ day: EditableDay, dayIndex: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(day.dayName)
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(KinexaTheme.tertiaryText)
                Text("—")
                    .foregroundStyle(KinexaTheme.tertiaryText)
                Text(day.focus)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color(hex: "#6366F1"))
            }

            VStack(spacing: 8) {
                ForEach(Array(day.exercises.enumerated()), id: \.element.id) { exIdx, exercise in
                    exerciseRow(exercise, dayIndex: dayIndex, exerciseIndex: exIdx, focus: day.focus)
                }

                Button {
                    addTargetDayIndex = dayIndex
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.caption)
                        Text("Add More")
                            .font(.caption.weight(.semibold))
                        Spacer(minLength: 0)
                    }
                    .foregroundStyle(KinexaTheme.accent)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(KinexaTheme.accent.opacity(0.06))
                    .clipShape(.rect(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(KinexaTheme.accent.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                    }
                }
                .buttonStyle(PressScaleButtonStyle())
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

    private func exerciseRow(_ exercise: ManualRoutineExercise, dayIndex: Int, exerciseIndex: Int, focus: String) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Color(hex: "#6366F1").opacity(0.5))
                .frame(width: 6, height: 6)

            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(KinexaTheme.primaryText)
                    .lineLimit(1)
                Text("\(exercise.sets)×\(exercise.reps)")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }

            Spacer(minLength: 0)

            Button {
                swapTarget = SwapTarget(
                    dayIndex: dayIndex,
                    exerciseIndex: exerciseIndex,
                    bodyPart: inferBodyPart(from: focus)
                )
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.caption)
                    .foregroundStyle(KinexaTheme.accent)
                    .padding(7)
                    .background(KinexaTheme.accent.opacity(0.12))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Button {
                editableDays[dayIndex].exercises.remove(at: exerciseIndex)
                hasEdits = true
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.red.opacity(0.7))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
    }

    private func inferBodyPart(from focus: String) -> WeightBodyPart? {
        let f = focus.lowercased()
        if f.contains("chest") { return .chest }
        if f.contains("back") { return .back }
        if f.contains("shoulder") { return .shoulders }
        if f.contains("bicep") { return .biceps }
        if f.contains("tricep") { return .triceps }
        if f.contains("leg") || f.contains("quad") || f.contains("hamstring") { return .legs }
        if f.contains("glute") { return .glutes }
        if f.contains("core") || f.contains("ab") { return .core }
        return nil
    }

    private func loadEditable() {
        guard editableDays.isEmpty else { return }
        editableDays = routine.days.map { day in
            EditableDay(
                id: day.id,
                dayName: day.dayName,
                focus: day.focus,
                exercises: day.exercises.map {
                    ManualRoutineExercise(
                        name: $0.name,
                        category: day.focus,
                        sets: $0.sets,
                        reps: $0.reps,
                        notes: $0.notes,
                        sourceType: .weightTraining
                    )
                }
            )
        }
    }

    private func toManualRoutine(name: String) -> ManualRoutine {
        let days = editableDays.map { ed in
            ManualRoutineDay(dayName: ed.dayName, exercises: ed.exercises)
        }
        return ManualRoutine(name: name, days: days)
    }

    private func activateAsIs() {
        appVM.activateManualRoutine(toManualRoutine(name: routine.name))
    }

    private func activateEdited() {
        appVM.activateManualRoutine(toManualRoutine(name: routine.name))
    }

    private func saveAsCopy() {
        let copy = toManualRoutine(name: "\(routine.name) (My Copy)")
        var saved = LocalStore.load([ManualRoutine].self, forKey: "manualRoutines", fallback: [])
        saved.append(copy)
        LocalStore.save(saved, forKey: "manualRoutines")
        appVM.activateManualRoutine(copy)
    }
}

// MARK: - Swap / Add Picker

struct ExerciseSwapPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let suggestedBodyPart: WeightBodyPart?
    let onPick: (ManualRoutineExercise) -> Void

    @State private var searchText: String = ""
    @State private var viewAll: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                KinexaTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        if let part = suggestedBodyPart, !viewAll, searchText.isEmpty {
                            sectionHeader("Suggested for \(part.rawValue)")
                            exerciseList(WeightExerciseLibrary.exercises(for: part))

                            Button {
                                viewAll = true
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "books.vertical.fill")
                                    Text("Browse Full Library")
                                        .font(.subheadline.weight(.semibold))
                                }
                                .foregroundStyle(KinexaTheme.accent)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(KinexaTheme.accent.opacity(0.08))
                                .clipShape(.rect(cornerRadius: 12))
                            }
                            .buttonStyle(PressScaleButtonStyle())
                            .padding(.top, 4)
                        } else {
                            sectionHeader(searchText.isEmpty ? "All Exercises" : "Results")
                            exerciseList(filteredExercises)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 48)
                }
            }
            .navigationTitle("Pick Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search exercises")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }
            }
            .toolbarBackground(KinexaTheme.background, for: .navigationBar)
        }
    }

    private var filteredExercises: [WeightExerciseDefinition] {
        if searchText.isEmpty {
            return WeightExerciseLibrary.allExercises
        }
        return WeightExerciseLibrary.allExercises.filter {
            $0.name.localizedStandardContains(searchText)
        }
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.caption.weight(.heavy))
            .tracking(1.2)
            .foregroundStyle(KinexaTheme.tertiaryText)
            .padding(.leading, 4)
    }

    private func exerciseList(_ exercises: [WeightExerciseDefinition]) -> some View {
        LazyVStack(spacing: 8) {
            ForEach(exercises) { ex in
                Button {
                    let picked = ManualRoutineExercise(
                        name: ex.name,
                        category: ex.bodyPart.rawValue,
                        sets: ex.defaultSets,
                        reps: ex.defaultReps,
                        sourceType: .weightTraining
                    )
                    onPick(picked)
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: ex.bodyPart.icon)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color(hex: "#6366F1"))
                            .frame(width: 32, height: 32)
                            .background(Color(hex: "#6366F1").opacity(0.12))
                            .clipShape(.rect(cornerRadius: 8))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(ex.name)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(KinexaTheme.primaryText)
                            Text("\(ex.bodyPart.rawValue) · \(ex.equipment)")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(KinexaTheme.tertiaryText)
                        }

                        Spacer(minLength: 0)

                        Text("\(ex.defaultSets)×\(ex.defaultReps)")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(KinexaTheme.tertiaryText)
                    }
                    .padding(12)
                    .background(KinexaTheme.card)
                    .clipShape(.rect(cornerRadius: 12))
                    .elevatedCardShadow()
                    .overlay {
                        RoundedRectangle(cornerRadius: 12).stroke(KinexaTheme.border)
                    }
                }
                .buttonStyle(PressScaleButtonStyle())
            }
        }
    }
}
