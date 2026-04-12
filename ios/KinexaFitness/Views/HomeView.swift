import SwiftUI

struct HomeView: View {
    @Environment(AppViewModel.self) private var vm
    @Environment(StoreViewModel.self) private var store

    @State private var showUpgrade: Bool = false

    @State private var animateHero: Bool = false
    @State private var animateMetrics: Bool = false
    @State private var showWODSheet: Bool = false
    @State private var showWODPlanSheet: Bool = false
    @State private var showWorkoutDetail: Bool = false
    @State private var showActiveSession: Bool = false
    @State private var showMyPTPlanSheet: Bool = false
    @State private var showScanSheet: Bool = false
    @State private var showRecoveryDetail: Bool = false
    @State private var showEditSheet: Bool = false
    @State private var showCalendarSheet: Bool = false
    @State private var showExportAlert: Bool = false
    @State private var exportAlertMessage: String = ""
    @State private var recoverySession: WorkoutDay?
    @State private var startWorkoutTrigger: Bool = false
    @State private var completeWorkoutTrigger: Bool = false
    @State private var toolTapTrigger: Bool = false

    @State private var selectedDate: Date = Calendar.current.startOfDay(for: .now)
    @State private var selectedDayIndex: Int?
    @State private var navigateToPlanDetail: Bool = false
    @State private var planDetailDayIndex: Int = 0
    @State private var navigateToPlanSession: Bool = false
    @State private var planSessionDayIndex: Int = 0

    @State private var calendarService = CalendarExportService()
    @State private var showCompletionShare: Bool = false
    @State private var completedWorkoutTitle: String = ""
    @State private var completedExerciseCount: Int = 0
    @State private var navigateToCalendarDay: Bool = false
    @State private var calendarDayDate: Date = .now
    @State private var navigateToTrainingCalendar: Bool = false
    @State private var showTodayShareSheet: Bool = false
    @State private var showTodayQRSheet: Bool = false
    @State private var showTodaySavedToast: Bool = false
    @State private var todayCompleteTrigger: Bool = false
    @State private var showFunctionalWODSheet: Bool = false
    @State private var showQuickStartSheet: Bool = false
    @State private var showActiveQuickStart: Bool = false
    @State private var quickStartVM: QuickStartViewModel = QuickStartViewModel()
    @State private var showPDFUploadSheet: Bool = false

    private let calendar = Calendar.current

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                VStack(spacing: 24) {
                    greetingHeader

                    todayFunctionalSection

                    quickStartSection

                    todayFitnessHero
                    recentCardioSection
                    dailyActivitySection
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 48)
                .adaptiveContainer()
            }
        }
        .background {
            ZStack {
                KinexaTheme.background.ignoresSafeArea()
                backgroundAmbience
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("KINEXA FIT")
                    .font(.caption.weight(.heavy))
                    .tracking(2.4)
                    .foregroundStyle(KinexaTheme.secondaryText)
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    if !store.isPremium {
                        Button {
                            showUpgrade = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "crown.fill")
                                    .font(.caption.weight(.bold))
                                Text("PRO")
                                    .font(.caption2.weight(.heavy))
                                    .tracking(0.5)
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                LinearGradient(
                                    colors: [KinexaTheme.accent, KinexaTheme.accent2],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                        }
                    }

                    Button {
                        navigateToTrainingCalendar = true
                    } label: {
                        Image(systemName: "calendar")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(KinexaTheme.secondaryText)
                    }

                    Button {
                        toolTapTrigger.toggle()
                        showScanSheet = true
                    } label: {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(KinexaTheme.secondaryText)
                    }

                    Menu {
                        if vm.currentPlan != nil {
                            Button {
                                vm.generateWeeklyPlan()
                            } label: {
                                Label("Regenerate Week", systemImage: "arrow.clockwise")
                            }
                            Button {
                                showCalendarSheet = true
                            } label: {
                                Label("Export to Calendar", systemImage: "calendar.badge.plus")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(KinexaTheme.secondaryText)
                    }
                }
            }
        }
        .toolbarBackground(KinexaTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationDestination(isPresented: $showWorkoutDetail) {
            if let today = vm.todayWorkout {
                WorkoutDetailView(dayIndex: today.dayIndex, isStandalone: false)
            } else {
                UnavailableFallbackView(title: "Workout Unavailable", message: "No workout found for today.", action: "Return Home") {
                    showWorkoutDetail = false
                }
            }
        }
        .navigationDestination(isPresented: $showActiveSession) {
            if let today = vm.todayWorkout {
                ActiveSessionView(dayIndex: today.dayIndex, isStandalone: false)
            } else {
                UnavailableFallbackView(title: "Session Unavailable", message: "No workout found to start.", action: "Return Home") {
                    showActiveSession = false
                }
            }
        }
        .navigationDestination(isPresented: $showRecoveryDetail) {
            if let session = recoverySession {
                WorkoutDetailView(dayIndex: session.dayIndex, isStandalone: false)
            } else {
                UnavailableFallbackView(title: "Recovery Unavailable", message: "Unable to load recovery session.", action: "Return Home") {
                    showRecoveryDetail = false
                }
            }
        }
        .navigationDestination(isPresented: $navigateToPlanDetail) {
            if vm.currentPlan?.days.contains(where: { $0.dayIndex == planDetailDayIndex }) == true {
                WorkoutDetailView(dayIndex: planDetailDayIndex, isStandalone: false)
            } else {
                UnavailableFallbackView(title: "Workout Unavailable", message: "This workout could not be loaded.", action: "Go Back") {
                    navigateToPlanDetail = false
                }
            }
        }
        .navigationDestination(isPresented: $navigateToPlanSession) {
            if vm.currentPlan?.days.contains(where: { $0.dayIndex == planSessionDayIndex }) == true {
                ActiveSessionView(dayIndex: planSessionDayIndex, isStandalone: false)
            } else {
                UnavailableFallbackView(title: "Session Unavailable", message: "This workout session could not be loaded.", action: "Go Back") {
                    navigateToPlanSession = false
                }
            }
        }
        .navigationDestination(isPresented: $navigateToCalendarDay) {
            CalendarDayDetailView(date: calendarDayDate)
        }
        .navigationDestination(isPresented: $navigateToTrainingCalendar) {
            TrainingCalendarView()
        }
        .sheet(isPresented: $showUpgrade) {
            UpgradeView()
        }
        .sheet(isPresented: $showWODSheet) {
            WODDetailView()
        }
        .sheet(isPresented: $showWODPlanSheet) {
            WODPlanSheet()
        }
        .sheet(isPresented: $showMyPTPlanSheet) {
            MyPTPlanSheet()
        }
        .sheet(isPresented: $showScanSheet) {
            QRScannerSheet()
        }
        .sheet(isPresented: $showEditSheet) {
            if let dayIndex = selectedDayIndex,
               let plan = vm.currentPlan,
               let day = plan.days.first(where: { $0.dayIndex == dayIndex }) {
                EditWorkoutSheet(day: day)
            } else {
                NavigationStack {
                    UnavailableFallbackView(title: "Edit Unavailable", message: "This workout could not be loaded for editing.", action: "Dismiss") {
                        showEditSheet = false
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") { showEditSheet = false }
                                .foregroundStyle(KinexaTheme.primaryText)
                        }
                    }
                    .toolbarBackground(KinexaTheme.background, for: .navigationBar)
                    .toolbarColorScheme(.dark, for: .navigationBar)
                }
            }
        }
        .sheet(isPresented: $showCalendarSheet) {
            calendarExportSheet
        }
        .alert("Calendar Export", isPresented: $showExportAlert) {
            Button("OK") {}
        } message: {
            Text(exportAlertMessage)
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: startWorkoutTrigger)
        .sensoryFeedback(.success, trigger: completeWorkoutTrigger)
        .sensoryFeedback(.selection, trigger: toolTapTrigger)
        .sheet(isPresented: $showCompletionShare) {
            WorkoutCompletionShareSheet(
                title: completedWorkoutTitle,
                exerciseCount: completedExerciseCount
            )
        }
        .sheet(isPresented: $showQuickStartSheet) {
            QuickStartSelectionView(quickStart: quickStartVM)
        }
        .sheet(item: Binding<QuickStartRecord?>(
            get: { quickStartVM.completedRecord },
            set: { _ in }
        )) { record in
            QuickStartCompletionView(record: record) {
                quickStartVM.dismiss()
            }
        }
        .navigationDestination(isPresented: $showActiveQuickStart) {
            ActiveQuickStartView(quickStart: quickStartVM)
        }
        .onChange(of: quickStartVM.isActive) { _, isActive in
            if isActive {
                showActiveQuickStart = true
            }
        }
        .onChange(of: quickStartVM.showCompletion) { _, showCompletion in
            if showCompletion {
                showActiveQuickStart = false
            }
        }
        .sheet(isPresented: $showPDFUploadSheet) {
            PDFUploadView()
        }
        .sheet(isPresented: $showFunctionalWODSheet) {
            if let template = vm.todayFunctionalWOD {
                WODDetailView(template: template)
            } else {
                WODDetailView()
            }
        }
        .sheet(isPresented: $showTodayShareSheet) {
            if let today = vm.todayWorkout {
                PTWODShareSheet(workout: today)
            }
        }
        .sheet(isPresented: $showTodayQRSheet) {
            if let today = vm.todayWorkout {
                WorkoutQRSheet(workout: today, workoutType: "Training Plan")
            } else if let template = vm.todayFunctionalWOD {
                let workout = WODService.convertToWorkoutDay(template)
                WorkoutQRSheet(workout: workout, workoutType: "FunctionFitness")
            }
        }
        .overlay {
            if showTodaySavedToast {
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
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showTodaySavedToast)
            }
        }
        .onAppear {
            vm.pedometer.refreshTodaySteps()
            Task {
                try? await Task.sleep(for: .milliseconds(400))
                vm.syncTodaySteps()
            }
            vm.ensureTodayHasWorkout()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.82)) {
                animateHero = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2)) {
                animateMetrics = true
            }
        }
    }

    // MARK: - Background Ambience

    private var backgroundAmbience: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [KinexaTheme.brandGreen.opacity(0.1), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 300
                    )
                )
                .frame(width: 600, height: 600)
                .offset(y: -200)
                .blur(radius: 80)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [KinexaTheme.slateAccent.opacity(0.04), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: 120, y: 100)
                .blur(radius: 60)
        }
        .ignoresSafeArea()
    }


    private func workoutIcon(for workout: WorkoutDay) -> String {
        let title = workout.title.lowercased()
        if title.contains("run") || title.contains("cardio") || title.contains("endurance") { return "figure.run" }
        if title.contains("strength") || title.contains("push") || title.contains("pull") { return "figure.strengthtraining.traditional" }
        if title.contains("recovery") || title.contains("stretch") || title.contains("mobility") { return "figure.cooldown" }
        if title.contains("unit") || title.contains("group") { return "person.3.fill" }
        return "figure.mixed.cardio"
    }

    // MARK: - Greeting Header

    private var greetingHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(greetingText)
                .font(.title2.weight(.bold))
                .foregroundStyle(KinexaTheme.primaryText)

            Text(todaySubtitle)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(KinexaTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .opacity(animateHero ? 1 : 0)
        .offset(y: animateHero ? 0 : 8)
    }

    private var todaySubtitle: String {
        let count = vm.todayCalendarEntryCount
        if count == 0 { return "No workouts scheduled today" }
        return "\(count) workout\(count == 1 ? "" : "s") today"
    }

    // MARK: - Today Fitness Hero (PRIORITY 1)

    private var todayFitnessHero: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                fitnessStatPill(
                    icon: "flame.fill",
                    value: "\(vm.streak)",
                    label: "Streak",
                    color: KinexaTheme.warning
                )
                fitnessStatPill(
                    icon: "checkmark.seal.fill",
                    value: "\(vm.workoutsThisWeek)",
                    label: "This Week",
                    color: KinexaTheme.success
                )
                fitnessStatPill(
                    icon: "heart.fill",
                    value: "\(vm.totalCardioMinutesThisWeek)",
                    label: "Cardio Min",
                    color: Color(hex: "#EC4899")
                )
            }

            let trackedCount = ExerciseWeightMemory.allTrackedExercises().count
            if trackedCount > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "brain.head.profile")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(KinexaTheme.accent)
                    Text("Smart Memory: \(trackedCount) exercises tracked")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(KinexaTheme.secondaryText)
                    Spacer()
                }
                .padding(.horizontal, 4)
            }
        }
        .scaleEffect(animateHero ? 1 : 0.96)
        .opacity(animateHero ? 1 : 0)
    }

    private func fitnessStatPill(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.12))
                .clipShape(Circle())

            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(KinexaTheme.primaryText)
                .contentTransition(.numericText())

            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(KinexaTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18).stroke(KinexaTheme.border)
        }
    }

    // MARK: - Today Workout Section (PRIORITY 2)

    private var todayWorkoutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TODAY'S WORKOUT")
                .font(.caption.weight(.heavy))
                .tracking(1.2)
                .foregroundStyle(KinexaTheme.tertiaryText)
                .padding(.leading, 4)

            if let today = vm.todayWorkout, !today.isRestDay {
                todayWorkoutCard(today)
            } else {
                todayEmptyCard
            }
        }
        .opacity(animateHero ? 1 : 0)
        .offset(y: animateHero ? 0 : 8)
    }

    private func todayWorkoutCard(_ workout: WorkoutDay) -> some View {
        Button {
            startWorkoutTrigger.toggle()
            showFunctionalWODSheet = true
        } label: {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: workoutIcon(for: workout))
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(.white.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        if workout.isCompleted {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption2)
                                Text("DONE")
                                    .font(.caption2.weight(.heavy))
                                    .tracking(0.5)
                            }
                            .foregroundStyle(KinexaTheme.success)
                        }
                    }

                    Text(workout.title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 8) {
                        Label("\(workout.exercises.count) exercises", systemImage: "list.bullet")
                        Label(estimatedDuration(workout), systemImage: "clock")
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.6))
                }

                Spacer(minLength: 0)

                VStack(spacing: 6) {
                    Image(systemName: "play.fill")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background(.white.opacity(0.15))
                        .clipShape(Circle())

                    Text("Start")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .padding(18)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(KinexaTheme.ptGradient)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color(hex: "#2E5A7C").opacity(0.2), radius: 16, y: 10)
        }
        .buttonStyle(PressScaleButtonStyle())
        .accessibilityLabel("Today's workout: \(workout.title), \(workout.exercises.count) exercises")
        .accessibilityHint("Tap to view workout details")
    }

    private func todayWorkoutActions(_ workout: WorkoutDay) -> some View {
        HStack(spacing: 8) {
            if !workout.isCompleted {
                Button {
                    todayCompleteTrigger.toggle()
                    vm.markDayCompleted(dayIndex: workout.dayIndex)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption.weight(.bold))
                        Text("Log Complete")
                            .font(.caption.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(KinexaTheme.heroGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .sensoryFeedback(.success, trigger: todayCompleteTrigger)
                .buttonStyle(PressScaleButtonStyle())
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption2)
                    Text("Logged")
                        .font(.caption.weight(.bold))
                }
                .foregroundStyle(KinexaTheme.success)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(KinexaTheme.success.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(KinexaTheme.success.opacity(0.3))
                }
            }

            Button {
                ShareCardRenderer.presentShareSheet(
                    cardType: .workout(title: workout.title, exercises: workout.exercises, tags: workout.tags)
                )
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(KinexaTheme.secondaryText)
                    .frame(width: 40, height: 40)
                    .background(KinexaTheme.cardSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(KinexaTheme.border)
                    }
            }
            .buttonStyle(PressScaleButtonStyle())

            Button {
                let saved = ShareCardRenderer.saveToPhotos(
                    cardType: .workout(title: workout.title, exercises: workout.exercises, tags: workout.tags)
                )
                if saved {
                    showTodaySavedToast = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showTodaySavedToast = false
                    }
                }
            } label: {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(KinexaTheme.secondaryText)
                    .frame(width: 40, height: 40)
                    .background(KinexaTheme.cardSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(KinexaTheme.border)
                    }
            }
            .buttonStyle(PressScaleButtonStyle())

            Button {
                showTodayQRSheet = true
            } label: {
                Image(systemName: "qrcode")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(KinexaTheme.secondaryText)
                    .frame(width: 40, height: 40)
                    .background(KinexaTheme.cardSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(KinexaTheme.border)
                    }
            }
            .buttonStyle(PressScaleButtonStyle())
        }
    }

    // MARK: - Today Functional Section

    private var todayFunctionalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TODAY'S SESSION")
                .font(.caption.weight(.heavy))
                .tracking(1.2)
                .foregroundStyle(KinexaTheme.tertiaryText)
                .padding(.leading, 4)

            if let template = vm.todayFunctionalWOD {
                todayFunctionalCardSimple(template)
            } else {
                Button {
                    showFunctionalWODSheet = true
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "bolt.heart.fill")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(KinexaTheme.heroAmber)
                            .frame(width: 44, height: 44)
                            .background(KinexaTheme.heroAmber.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        VStack(alignment: .leading, spacing: 3) {
                            Text("Generate Today's Session")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(KinexaTheme.primaryText)
                            Text("Get a workout session")
                                .font(.caption)
                                .foregroundStyle(KinexaTheme.tertiaryText)
                        }

                        Spacer(minLength: 0)

                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(KinexaTheme.tertiaryText)
                    }
                    .padding(16)
                    .premiumCard()
                }
                .buttonStyle(PressScaleButtonStyle())
            }
        }
        .opacity(animateHero ? 1 : 0)
        .offset(y: animateHero ? 0 : 8)
    }

    private func todayFunctionalCardSimple(_ template: WODTemplate) -> some View {
        return Button {
            showFunctionalWODSheet = true
        } label: {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "bolt.heart.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(.white.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        Text("TODAY'S SESSION")
                            .font(.caption2.weight(.heavy))
                            .tracking(0.8)
                            .foregroundStyle(.white.opacity(0.7))
                    }

                    Text(template.title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 8) {
                        Label("\(template.movements.count) movements", systemImage: "list.bullet")
                        Label("~\(template.durationMinutes) min", systemImage: "clock")
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.6))
                }

                Spacer(minLength: 0)

                VStack(spacing: 6) {
                    Image(systemName: "play.fill")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background(.white.opacity(0.15))
                        .clipShape(Circle())

                    Text("View")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .padding(18)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#F59E0B"), Color(hex: "#D97706").opacity(0.95)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color(hex: "#F59E0B").opacity(0.2), radius: 16, y: 10)
        }
        .buttonStyle(PressScaleButtonStyle())
        .accessibilityLabel("Today's FunctionFitness: \(template.title), \(template.movements.count) movements")
        .accessibilityHint("Tap to view workout details")
    }

    private func todayFunctionalActions(_ template: WODTemplate) -> some View {
        let workout = WODService.convertToWorkoutDay(template)

        return HStack(spacing: 8) {
            Button {
                todayCompleteTrigger.toggle()
                var wodWorkout = workout
                wodWorkout.source = .wod
                vm.completeStandaloneWorkout(wodWorkout)
                completedWorkoutTitle = workout.title
                completedExerciseCount = workout.exercises.count
                showCompletionShare = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption.weight(.bold))
                    Text("Log Complete")
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
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .sensoryFeedback(.success, trigger: todayCompleteTrigger)
            .buttonStyle(PressScaleButtonStyle())

            Button {
                ShareCardRenderer.presentShareSheet(
                    cardType: .workout(title: workout.title, exercises: workout.exercises, tags: workout.tags)
                )
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(KinexaTheme.secondaryText)
                    .frame(width: 40, height: 40)
                    .background(KinexaTheme.cardSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(KinexaTheme.border)
                    }
            }
            .buttonStyle(PressScaleButtonStyle())

            Button {
                let saved = ShareCardRenderer.saveToPhotos(
                    cardType: .workout(title: workout.title, exercises: workout.exercises, tags: workout.tags)
                )
                if saved {
                    showTodaySavedToast = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showTodaySavedToast = false
                    }
                }
            } label: {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(KinexaTheme.secondaryText)
                    .frame(width: 40, height: 40)
                    .background(KinexaTheme.cardSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(KinexaTheme.border)
                    }
            }
            .buttonStyle(PressScaleButtonStyle())

            Button {
                showTodayQRSheet = true
            } label: {
                Image(systemName: "qrcode")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(KinexaTheme.secondaryText)
                    .frame(width: 40, height: 40)
                    .background(KinexaTheme.cardSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(KinexaTheme.border)
                    }
            }
            .buttonStyle(PressScaleButtonStyle())
        }
    }

    private var todayEmptyCard: some View {
        Button {
            showMyPTPlanSheet = true
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "calendar.badge.plus")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(KinexaTheme.accent)
                    .frame(width: 44, height: 44)
                    .background(KinexaTheme.accent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 3) {
                    Text("No Workout Scheduled")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(KinexaTheme.primaryText)
                    Text("Create a plan to get started")
                        .font(.caption)
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }
            .padding(16)
            .premiumCard()
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    // MARK: - Quick Start Section

    private var quickStartSection: some View {
        Button {
            toolTapTrigger.toggle()
            showQuickStartSheet = true
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "bolt.fill")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#059669"), Color(hex: "#047857")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Quick Start")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)
                    Text("Run · Bike · Hike · Fitness")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }

                Spacer(minLength: 0)

                Image(systemName: "play.circle.fill")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color(hex: "#059669"))
            }
            .padding(14)
            .background(KinexaTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: "#059669").opacity(0.2))
            }
        }
        .buttonStyle(PressScaleButtonStyle())
        .accessibilityLabel("Quick Start an activity")
        .accessibilityHint("Choose from run, bike, hike or functional fitness")
        .opacity(animateHero ? 1 : 0)
        .offset(y: animateHero ? 0 : 8)
    }

    // MARK: - Recent Cardio Section

    private var recentCardioSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RECENT CARDIO")
                .font(.caption.weight(.heavy))
                .tracking(1.2)
                .foregroundStyle(KinexaTheme.tertiaryText)
                .padding(.leading, 4)

            if vm.cardioSessions.isEmpty {
                HStack(spacing: 14) {
                    Image(systemName: "heart.fill")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color(hex: "#EC4899"))
                        .frame(width: 44, height: 44)
                        .background(Color(hex: "#EC4899").opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 3) {
                        Text("No Cardio Logged Yet")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(KinexaTheme.primaryText)
                        Text("Go to Workouts tab to browse \(CardioLibrary.allWorkouts.count)+ cardio workouts")
                            .font(.caption2)
                            .foregroundStyle(KinexaTheme.tertiaryText)
                    }

                    Spacer(minLength: 0)
                }
                .padding(16)
                .premiumCard()
            } else {
                ForEach(vm.cardioSessions.prefix(3)) { session in
                    recentCardioRow(session)
                }
            }
        }
        .scaleEffect(animateHero ? 1 : 0.96)
        .opacity(animateHero ? 1 : 0)
    }

    private func recentCardioRow(_ session: CardioSession) -> some View {
        HStack(spacing: 14) {
            Image(systemName: cardioIcon(session.workoutName))
                .font(.body.weight(.semibold))
                .foregroundStyle(Color(hex: "#EC4899"))
                .frame(width: 40, height: 40)
                .background(Color(hex: "#EC4899").opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(session.workoutName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(KinexaTheme.primaryText)
                Text("\(session.durationMinutes) min · \(recentCardioDateString(session.date))")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }

            Spacer(minLength: 0)

            if let cals = session.caloriesBurned {
                Text("\(cals) cal")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(KinexaTheme.secondaryText)
            }
        }
        .padding(12)
        .background(KinexaTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14).stroke(KinexaTheme.border)
        }
    }

    private func cardioIcon(_ name: String) -> String {
        let lower = name.lowercased()
        if lower.contains("run") || lower.contains("sprint") || lower.contains("fartlek") || lower.contains("tempo") { return "figure.run" }
        if lower.contains("bike") || lower.contains("cycling") || lower.contains("spin") { return "figure.indoor.cycle" }
        if lower.contains("yoga") { return "figure.yoga" }
        if lower.contains("swim") { return "figure.pool.swim" }
        if lower.contains("walk") { return "figure.walk" }
        if lower.contains("hike") || lower.contains("ruck") { return "figure.hiking" }
        if lower.contains("row") { return "figure.rowing" }
        if lower.contains("dance") || lower.contains("zumba") { return "figure.dance" }
        if lower.contains("pilates") { return "figure.pilates" }
        if lower.contains("boxing") || lower.contains("kickbox") { return "figure.kickboxing" }
        return "heart.fill"
    }

    private func recentCardioDateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: date)
    }

    private func planRow(title: String, subtitle: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(KinexaTheme.primaryText)
                    Text(subtitle)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }
            .padding(14)
            .background(KinexaTheme.card)
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(KinexaTheme.border)
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    // MARK: - Daily Activity Section (PRIORITY 4)

    private var dailyActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DAILY ACTIVITY")
                .font(.caption.weight(.heavy))
                .tracking(1.2)
                .foregroundStyle(KinexaTheme.tertiaryText)
                .padding(.leading, 4)

            HStack(spacing: 0) {
                metricPill(
                    icon: "figure.walk",
                    value: formattedSteps,
                    label: "Steps Today",
                    color: KinexaTheme.accent
                )

                metricDivider

                metricPill(
                    icon: "checkmark.circle.fill",
                    value: "\(vm.weeklyCompletedCount)/\(vm.weeklyTotalDays)",
                    label: "This Week",
                    color: KinexaTheme.success
                )

                metricDivider

                metricPill(
                    icon: "flame.fill",
                    value: "\(vm.streak)",
                    label: vm.streak == 1 ? "Day" : "Days",
                    color: KinexaTheme.warning
                )
            }
            .padding(.vertical, 18)
            .background(KinexaTheme.card)
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(KinexaTheme.border)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .opacity(animateMetrics ? 1 : 0)
        .offset(y: animateMetrics ? 0 : 12)
    }

    private var metricDivider: some View {
        Rectangle()
            .fill(KinexaTheme.border)
            .frame(width: 1, height: 32)
    }

    private func metricPill(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(color)
                Text(value)
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)
                    .contentTransition(.numericText())
            }
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(KinexaTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }

    // MARK: - Calendar Export Sheet

    private var calendarExportSheet: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 40))
                    .foregroundStyle(KinexaTheme.accent)
                    .padding(.top, 8)

                Text("Export to Calendar")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)

                Text("Add your PT plan to your iOS Calendar.")
                    .font(.subheadline)
                    .foregroundStyle(KinexaTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            VStack(spacing: 12) {
                if let plan = vm.currentPlan {
                    Button {
                        Task {
                            let result = await calendarService.exportWeeklyPlan(plan)
                            handleExportResult(result)
                            showCalendarSheet = false
                        }
                    } label: {
                        HStack(spacing: 10) {
                            if calendarService.isExporting {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.subheadline.weight(.bold))
                            }
                            Text("Export Full Week")
                                .font(.headline.weight(.bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(KinexaTheme.heroGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(calendarService.isExporting)
                    .buttonStyle(PressScaleButtonStyle())
                }

                Button {
                    showCalendarSheet = false
                } label: {
                    Text("Cancel")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 20)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationBackground(KinexaTheme.background)
    }

    // MARK: - Helpers

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: .now)
        if hour < 12 { return "Good morning" }
        if hour < 17 { return "Keep going" }
        return "Good evening"
    }

    private var formattedSteps: String {
        let steps = vm.pedometer.todaySteps
        if steps >= 1000 { return String(format: "%.1fk", Double(steps) / 1000) }
        return "\(steps)"
    }

    private func estimatedDuration(_ workout: WorkoutDay) -> String {
        let mins = max(workout.exercises.count * 4, 15)
        return "~\(mins) min"
    }

    private func handleExportResult(_ result: CalendarExportService.ExportResult) {
        switch result {
        case .success(let count):
            exportAlertMessage = "\(count) workout\(count == 1 ? "" : "s") added to your calendar."
        case .partial(let exported, let failed):
            exportAlertMessage = "\(exported) exported, \(failed) failed. Try again for remaining."
        case .denied:
            exportAlertMessage = "Calendar access denied. Go to Settings → Kinexa Fitness → Calendars to enable."
        case .error(let message):
            exportAlertMessage = "Export failed: \(message)"
        }
        showExportAlert = true
    }
}
