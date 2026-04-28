import SwiftUI

struct ViewWorkoutSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var vm

    var onStartPTSession: (Int) -> Void
    var onOpenPlanner: () -> Void
    var onOpenManualBuilder: () -> Void

    @State private var showResetConfirm: Bool = false
    @State private var resetTrigger: Bool = false
    @State private var showCardioPicker: Bool = false
    @State private var showLogStrength: Bool = false
    @State private var showFunctionalBrowser: Bool = false
    @State private var showManualBuilder: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    if let today = vm.todayWorkout, !today.isRestDay {
                        ptWorkoutCard(today)
                        actionButtons(today)
                    } else if let template = vm.todayFunctionalWOD {
                        wodCard(template)
                        wodActions(template)
                    } else {
                        emptyCard
                    }

                    changeWorkoutCard
                    resetRow
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
            .background(KynexaTheme.background.ignoresSafeArea())
            .navigationTitle("Today's Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(KynexaTheme.background, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(KynexaTheme.accent)
                }
            }
            .confirmationDialog(
                "Reset today's workout?",
                isPresented: $showResetConfirm,
                titleVisibility: .visible
            ) {
                Button("Reset & Open Planner", role: .destructive) {
                    resetTrigger.toggle()
                    resetToday()
                    dismiss()
                    onOpenPlanner()
                }
                Button("Reset & Open Manual Build", role: .destructive) {
                    resetTrigger.toggle()
                    resetToday()
                    dismiss()
                    onOpenManualBuilder()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This clears today's planned workout so you can pick or generate a new one.")
            }
            .sensoryFeedback(.impact(weight: .medium), trigger: resetTrigger)
            .sheet(isPresented: $showCardioPicker) {
                LogCardioPickerSheet()
            }
            .sheet(isPresented: $showLogStrength) {
                LogStrengthWorkoutSheet()
            }
            .sheet(isPresented: $showFunctionalBrowser) {
                FunctionalFitnessBrowserView { _ in }
            }
            .sheet(isPresented: $showManualBuilder) {
                ManualRoutineBuilderView(initialExercises: [])
            }
        }
    }

    // MARK: - Change Workout

    private var changeWorkoutCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(KynexaTheme.accent)
                Text("CHANGE TODAY'S WORKOUT")
                    .font(.caption2.weight(.heavy))
                    .tracking(1.0)
                    .foregroundStyle(KynexaTheme.tertiaryText)
            }

            Text("Swap in a different workout for today and log it as you go.")
                .font(.caption.weight(.medium))
                .foregroundStyle(KynexaTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            let cols = [GridItem(.flexible()), GridItem(.flexible())]
            LazyVGrid(columns: cols, spacing: 10) {
                changeTile(
                    title: "Cardio",
                    subtitle: "Walk · Run · Bike",
                    icon: "heart.fill",
                    color: Color(hex: "#10B981")
                ) { showCardioPicker = true }

                changeTile(
                    title: "Weights",
                    subtitle: "Log a strength session",
                    icon: "dumbbell.fill",
                    color: Color(hex: "#6366F1")
                ) { showLogStrength = true }

                changeTile(
                    title: "Functional",
                    subtitle: "WODs & circuits",
                    icon: "bolt.heart.fill",
                    color: Color(hex: "#F59E0B")
                ) { showFunctionalBrowser = true }

                changeTile(
                    title: "Manual Build",
                    subtitle: "Pick your own moves",
                    icon: "square.and.pencil",
                    color: Color(hex: "#EC4899")
                ) { showManualBuilder = true }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(KynexaTheme.card)
        .clipShape(.rect(cornerRadius: 18))
        .overlay { RoundedRectangle(cornerRadius: 18).stroke(KynexaTheme.border) }
    }

    private func changeTile(title: String, subtitle: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(color)
                    .clipShape(.rect(cornerRadius: 10))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(KynexaTheme.primaryText)
                    Text(subtitle)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(KynexaTheme.tertiaryText)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(KynexaTheme.cardSoft)
            .clipShape(.rect(cornerRadius: 14))
            .overlay { RoundedRectangle(cornerRadius: 14).stroke(color.opacity(0.25)) }
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    // MARK: - Empty

    private var emptyCard: some View {
        VStack(spacing: 14) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(KynexaTheme.accent)
                .frame(width: 64, height: 64)
                .background(KynexaTheme.accent.opacity(0.12))
                .clipShape(Circle())

            Text("No workout today")
                .font(.title3.weight(.bold))
                .foregroundStyle(KynexaTheme.primaryText)

            Text("Build a plan or create a manual routine to get started.")
                .font(.subheadline)
                .foregroundStyle(KynexaTheme.secondaryText)
                .multilineTextAlignment(.center)

            HStack(spacing: 10) {
                Button {
                    dismiss()
                    onOpenPlanner()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "wand.and.stars")
                            .font(.caption.weight(.bold))
                        Text("Open Planner")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(KynexaTheme.accent)
                    .clipShape(.rect(cornerRadius: 12))
                }
                .buttonStyle(PressScaleButtonStyle())

                Button {
                    dismiss()
                    onOpenManualBuilder()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.pencil")
                            .font(.caption.weight(.bold))
                        Text("Manual Build")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(KynexaTheme.primaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(KynexaTheme.cardSoft)
                    .clipShape(.rect(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12).stroke(KynexaTheme.border)
                    }
                }
                .buttonStyle(PressScaleButtonStyle())
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity)
        .background(KynexaTheme.card)
        .clipShape(.rect(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20).stroke(KynexaTheme.border)
        }
    }

    // MARK: - PT Workout

    private func ptWorkoutCard(_ workout: WorkoutDay) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.9))
                Text("TODAY'S SESSION")
                    .font(.caption2.weight(.heavy))
                    .tracking(1.0)
                    .foregroundStyle(.white.opacity(0.8))
                Spacer()
                if workout.isCompleted {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill").font(.caption2)
                        Text("DONE").font(.caption2.weight(.heavy)).tracking(0.5)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.white.opacity(0.18))
                    .clipShape(Capsule())
                }
            }

            Text(workout.title)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)

            HStack(spacing: 14) {
                Label("\(workout.exercises.count) exercises", systemImage: "list.bullet")
                Label("~\(max(workout.exercises.count * 4, 15)) min", systemImage: "clock")
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white.opacity(0.8))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 22).fill(KynexaTheme.ptGradient)
        }
        .clipShape(.rect(cornerRadius: 22))
        .overlay(alignment: .bottom) {
            exerciseList(workout.exercises.prefix(6).map { $0.name })
                .offset(y: 1)
                .opacity(0)
        }
        .overlay(alignment: .topTrailing) {}
    }

    private func exerciseList(_ names: [String]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(names, id: \.self) { name in
                Text("• \(name)")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.75))
            }
        }
    }

    private func actionButtons(_ workout: WorkoutDay) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 8) {
                Text("MOVEMENTS")
                    .font(.caption.weight(.heavy))
                    .tracking(1.0)
                    .foregroundStyle(KynexaTheme.tertiaryText)
                    .padding(.leading, 4)

                ForEach(workout.exercises.prefix(12)) { ex in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(KynexaTheme.accent.opacity(0.3))
                            .frame(width: 8, height: 8)
                        Text(ex.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(KynexaTheme.primaryText)
                        Spacer()
                        Text(repsOrDuration(ex))
                            .font(.caption.weight(.medium))
                            .foregroundStyle(KynexaTheme.tertiaryText)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(KynexaTheme.card)
                    .clipShape(.rect(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12).stroke(KynexaTheme.border)
                    }
                }
            }

            Button {
                let idx = workout.dayIndex
                dismiss()
                onStartPTSession(idx)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                        .font(.subheadline.weight(.bold))
                    Text("Start Workout")
                        .font(.headline.weight(.bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(KynexaTheme.heroGradient)
                .clipShape(.rect(cornerRadius: 16))
                .shadow(color: KynexaTheme.accent.opacity(0.28), radius: 14, y: 8)
            }
            .buttonStyle(PressScaleButtonStyle())
        }
    }

    private func repsOrDuration(_ ex: WorkoutExercise) -> String {
        if ex.durationSeconds > 0 {
            return ex.durationSeconds >= 60 ? "\(ex.durationSeconds / 60) min" : "\(ex.durationSeconds) sec"
        }
        if ex.sets > 0 && ex.reps > 0 { return "\(ex.sets) × \(ex.reps)" }
        if ex.reps > 0 { return "\(ex.reps) reps" }
        return ""
    }

    // MARK: - WOD

    private func wodCard(_ template: WODTemplate) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "bolt.heart.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.9))
                Text("TODAY'S SESSION")
                    .font(.caption2.weight(.heavy))
                    .tracking(1.0)
                    .foregroundStyle(.white.opacity(0.8))
                Spacer()
                Text(template.format.rawValue)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.white.opacity(0.18))
                    .clipShape(Capsule())
            }

            Text(template.title)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)

            Text(template.workoutDescription)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 14) {
                Label("~\(template.durationMinutes) min", systemImage: "clock")
                Label("\(template.movements.count) moves", systemImage: "list.bullet")
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white.opacity(0.85))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            LinearGradient(
                colors: [Color(hex: "#F59E0B"), Color(hex: "#D97706")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .clipShape(.rect(cornerRadius: 22))
    }

    private func wodActions(_ template: WODTemplate) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 8) {
                Text("MOVEMENTS")
                    .font(.caption.weight(.heavy))
                    .tracking(1.0)
                    .foregroundStyle(KynexaTheme.tertiaryText)
                    .padding(.leading, 4)

                ForEach(template.movements) { movement in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(KynexaTheme.accent.opacity(0.3))
                            .frame(width: 8, height: 8)
                        Text(movement.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(KynexaTheme.primaryText)
                        Spacer()
                        if let reps = movement.reps {
                            Text(reps).font(.caption.weight(.medium)).foregroundStyle(KynexaTheme.tertiaryText)
                        } else if let dur = movement.duration {
                            Text(dur).font(.caption.weight(.medium)).foregroundStyle(KynexaTheme.tertiaryText)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(KynexaTheme.card)
                    .clipShape(.rect(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12).stroke(KynexaTheme.border)
                    }
                }
            }

            Button {
                var workout = WODService.convertToWorkoutDay(template)
                workout.source = .wod
                vm.completeStandaloneWorkout(workout)
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.subheadline.weight(.bold))
                    Text("Log Workout")
                        .font(.headline.weight(.bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(KynexaTheme.heroGradient)
                .clipShape(.rect(cornerRadius: 16))
            }
            .buttonStyle(PressScaleButtonStyle())
        }
    }

    // MARK: - Reset

    private var resetRow: some View {
        Button {
            showResetConfirm = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(KynexaTheme.warning)
                    .frame(width: 32, height: 32)
                    .background(KynexaTheme.warning.opacity(0.12))
                    .clipShape(.rect(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Reset Today's Workout")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(KynexaTheme.primaryText)
                    Text("Clear and pick or generate a new one")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(KynexaTheme.tertiaryText)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(KynexaTheme.tertiaryText)
            }
            .padding(14)
            .background(KynexaTheme.card)
            .clipShape(.rect(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14).stroke(KynexaTheme.warning.opacity(0.3))
            }
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    private func resetToday() {
        let today = Calendar.current.startOfDay(for: .now)
        let service = CalendarExportService()
        vm.deleteTodaysWorkout(on: today, calendarService: service)
    }
}
