import SwiftUI

struct WODDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var vm

    @State private var wodTemplate: WODTemplate?
    @State private var workout: WorkoutDay?
    @State private var didComplete: Bool = false
    @State private var isLoading: Bool = true
    @State private var completeTrigger: Bool = false
    @State private var generateTrigger: Bool = false
    @State private var showQRSheet: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var showCalendarSync: Bool = false
    @State private var calendarService = CalendarExportService()
    @State private var showExportAlert: Bool = false
    @State private var exportAlertMessage: String = ""

    let initialTemplate: WODTemplate?

    init(template: WODTemplate? = nil) {
        self.initialTemplate = template
    }

    var body: some View {
        NavigationStack {
            ZStack {
                KinexaTheme.background.ignoresSafeArea()

                if isLoading {
                    loadingState
                } else if let template = wodTemplate, let workout {
                    wodContent(template: template, workout: workout)
                } else {
                    unavailableState
                }
            }
            .navigationTitle("FunctionFitness Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(KinexaTheme.primaryText)
                }
            }
            .toolbarBackground(KinexaTheme.background, for: .navigationBar)
            
            .sheet(isPresented: $showQRSheet) {
                if let workout {
                    WorkoutQRSheet(workout: workout, workoutType: "FunctionFitness")
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let template = wodTemplate {
                    WODShareSheet(template: template)
                }
            }
            .sheet(isPresented: $showCalendarSync) {
                calendarSyncSheet
            }
            .alert("Calendar", isPresented: $showExportAlert) {
                Button("OK") {}
            } message: {
                Text(exportAlertMessage)
            }
        }
        .onAppear {
            loadWOD()
        }
    }

    private func loadWOD() {
        if let initial = initialTemplate {
            wodTemplate = initial
            workout = WODService.convertToWorkoutDay(initial)
            isLoading = false
        } else {
            let template = WODService.generateWOD(
                equipment: vm.currentEquipment,
                dutyType: vm.currentDutyType
            )
            wodTemplate = template
            workout = WODService.convertToWorkoutDay(template)
            isLoading = false
        }
    }

    private var loadingState: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(KinexaTheme.accent)
            Text("Generating workout...")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(KinexaTheme.secondaryText)
        }
    }

    private var unavailableState: some View {
        VStack(spacing: 20) {
            Image(systemName: "star.slash")
                .font(.system(size: 44))
                .foregroundStyle(KinexaTheme.accent.opacity(0.5))

            Text("FunctionFitness Workout Unavailable")
                .font(.title3.weight(.bold))
                .foregroundStyle(KinexaTheme.primaryText)

            Text("Tap below to generate a new session")
                .font(.subheadline)
                .foregroundStyle(KinexaTheme.secondaryText)

            Button {
                generateAnother()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.subheadline.weight(.bold))
                    Text("Generate Workout")
                        .font(.headline.weight(.bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(KinexaTheme.heroGradient)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: KinexaTheme.accent.opacity(0.3), radius: 12, y: 6)
            }
            .buttonStyle(PressScaleButtonStyle())
            .padding(.horizontal, 40)
        }
        .padding(20)
    }

    private func wodContent(template: WODTemplate, workout: WorkoutDay) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                wodHeader(template)

                wodDetails(template)
                movementsList(template)
                actionButtons(workout)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 48)
            .adaptiveContainer()
        }
    }

    private func wodHeader(_ template: WODTemplate) -> some View {
        return VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.9))

                Text("FUNCTIONFITNESS")
                    .font(.caption2.weight(.heavy))
                    .tracking(1.0)
                    .foregroundStyle(.white.opacity(0.8))

                Spacer()

                Text(template.format.rawValue)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.white.opacity(0.15))
                    .clipShape(Capsule())
            }

            Text(template.title)
                .font(.title.weight(.bold))
                .foregroundStyle(.white)

            Text(template.workoutDescription)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(22)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#3B6DE0"), Color(hex: "#5B4DC7").opacity(0.95)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: 24)
                    .fill(KinexaTheme.subtleGradient)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: KinexaTheme.accent.opacity(0.2), radius: 20, y: 12)
    }

    private func wodDetails(_ template: WODTemplate) -> some View {
        HStack(spacing: 0) {
            detailPill(icon: "clock", value: "~\(template.durationMinutes) min", label: "Duration")
            detailDivider
            detailPill(icon: "tag", value: template.category.rawValue, label: "Type")
            detailDivider
            detailPill(icon: "wrench.and.screwdriver", value: template.equipment.rawValue, label: "Equipment")
        }
        .padding(.vertical, 14)
        .background(KinexaTheme.card)
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(KinexaTheme.border)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var detailDivider: some View {
        Rectangle()
            .fill(KinexaTheme.border)
            .frame(width: 1, height: 28)
    }

    private func detailPill(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(KinexaTheme.accent)
                Text(value)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(KinexaTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private func movementsList(_ template: WODTemplate) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("MOVEMENTS")
                .font(.caption.weight(.bold))
                .tracking(1.0)
                .foregroundStyle(KinexaTheme.tertiaryText)
                .padding(.leading, 4)

            ForEach(template.movements) { movement in
                HStack(spacing: 12) {
                    Circle()
                        .fill(KinexaTheme.accent.opacity(0.3))
                        .frame(width: 8, height: 8)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(movement.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(KinexaTheme.primaryText)

                        HStack(spacing: 8) {
                            if let reps = movement.reps {
                                Text(reps)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(KinexaTheme.accent)
                            }
                            if let dur = movement.duration {
                                Text(dur)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(KinexaTheme.accent)
                            }
                            if let notes = movement.notes, !notes.isEmpty {
                                Text(notes)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(KinexaTheme.tertiaryText)
                            }
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(KinexaTheme.card)
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(KinexaTheme.border)
                }
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            if let notes = template.notes, !notes.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(KinexaTheme.warning)
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(KinexaTheme.secondaryText)
                }
                .padding(12)
                .background(KinexaTheme.warning.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private func actionButtons(_ workout: WorkoutDay) -> some View {
        VStack(spacing: 10) {
            if !didComplete {
                Button {
                    completeTrigger.toggle()
                    var wodWorkout = workout
                    wodWorkout.source = .wod
                    vm.completeStandaloneWorkout(wodWorkout)
                    didComplete = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.subheadline.weight(.bold))
                        Text("Log Workout")
                            .font(.headline.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(KinexaTheme.heroGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: KinexaTheme.accent.opacity(0.28), radius: 14, y: 8)
                }
                .sensoryFeedback(.success, trigger: completeTrigger)
                .buttonStyle(PressScaleButtonStyle())
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(KinexaTheme.success)
                    Text("Workout Logged & Tracked")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(KinexaTheme.success)
                }
                .frame(height: 52)
                .frame(maxWidth: .infinity)
            }

            HStack(spacing: 10) {
                Button {
                    generateTrigger.toggle()
                    generateAnother()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                            .font(.caption.weight(.bold))
                        Text("New Workout")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(KinexaTheme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(KinexaTheme.cardSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(KinexaTheme.border)
                    }
                }

                Button {
                    showCalendarSync = true
                } label: {
                    Image(systemName: "calendar.badge.plus")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(KinexaTheme.secondaryText)
                        .frame(width: 44, height: 44)
                        .background(KinexaTheme.cardSoft)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(KinexaTheme.border)
                        }
                }
                .buttonStyle(PressScaleButtonStyle())

                Button {
                    showQRSheet = true
                } label: {
                    Image(systemName: "qrcode")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(KinexaTheme.secondaryText)
                        .frame(width: 44, height: 44)
                        .background(KinexaTheme.cardSoft)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(KinexaTheme.border)
                        }
                }
                .buttonStyle(PressScaleButtonStyle())

                Button {
                    showShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(KinexaTheme.secondaryText)
                        .frame(width: 44, height: 44)
                        .background(KinexaTheme.cardSoft)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(KinexaTheme.border)
                        }
                }
                .buttonStyle(PressScaleButtonStyle())
            }
        }
    }

    private var calendarSyncSheet: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 40))
                    .foregroundStyle(KinexaTheme.accent)
                    .padding(.top, 8)

                Text("Sync to Calendar")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)

                Text("Add this FunctionFitness Workout to your iOS Calendar.")
                    .font(.subheadline)
                    .foregroundStyle(KinexaTheme.secondaryText)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                if let workout {
                    Button {
                        Task {
                            let result = await calendarService.exportWorkout(workout)
                            handleCalendarResult(result)
                            showCalendarSync = false
                        }
                    } label: {
                        HStack(spacing: 10) {
                            if calendarService.isExporting {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.subheadline.weight(.bold))
                            }
                            Text("Sync to Calendar")
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
                    showCalendarSync = false
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

    private func handleCalendarResult(_ result: CalendarExportService.ExportResult) {
        switch result {
        case .success(let count):
            exportAlertMessage = "\(count) workout\(count == 1 ? "" : "s") synced to calendar."
        case .partial(let exported, let failed):
            exportAlertMessage = "\(exported) exported, \(failed) failed."
        case .denied:
            exportAlertMessage = "Calendar access denied. Go to Settings to enable."
        case .error(let message):
            exportAlertMessage = "Sync failed: \(message)"
        }
        showExportAlert = true
    }

    private func generateAnother() {
        didComplete = false
        let template = WODService.generateWOD(
            equipment: vm.currentEquipment,
            dutyType: vm.currentDutyType
        )
        wodTemplate = template
        workout = WODService.convertToWorkoutDay(template)
    }




}
