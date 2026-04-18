import SwiftUI

struct WorkoutsTabView: View {
    @Environment(AppViewModel.self) private var vm
    @Environment(StoreViewModel.self) private var store

    @State private var appeared: Bool = false
    @State private var showWODPlanSheet: Bool = false
    @State private var showFunctionalWODSheet: Bool = false
    @State private var showPDFUploadSheet: Bool = false
    @State private var showLogStrengthSheet: Bool = false
    @State private var toolTapTrigger: Bool = false
    @State private var showManualBuilder: Bool = false
    @State private var showWeightBrowser: Bool = false
    @State private var showFunctionalBrowser: Bool = false
    @State private var showCardioBrowser: Bool = false
    @State private var pendingExercises: [ManualRoutineExercise] = []

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {
                topActionButtons
                plannerBlocks
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 48)
            .adaptiveContainer()
        }
        .background {
            ZStack {
                KinexaTheme.background.ignoresSafeArea()
                backgroundGlow
            }
        }
        .navigationTitle("Workouts")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(KinexaTheme.background, for: .navigationBar)
        
        .sheet(isPresented: $showWODPlanSheet) {
            WODPlanSheet()
        }
        .sheet(isPresented: $showFunctionalWODSheet) {
            WODDetailView()
        }
        .sheet(isPresented: $showPDFUploadSheet) {
            PDFUploadView()
        }
        .sheet(isPresented: $showLogStrengthSheet) {
            LogStrengthWorkoutSheet()
        }
        .sheet(isPresented: $showManualBuilder) {
            ManualRoutineBuilderView(initialExercises: pendingExercises)
        }
        .sheet(isPresented: $showWeightBrowser) {
            WeightTrainingBrowserView { exercise in
                pendingExercises.append(exercise)
            }
        }
        .sheet(isPresented: $showFunctionalBrowser) {
            FunctionalFitnessBrowserView { exercise in
                pendingExercises.append(exercise)
            }
        }
        .sheet(isPresented: $showCardioBrowser) {
            CardioBrowserForRoutineView { exercise in
                pendingExercises.append(exercise)
            }
        }
        .sensoryFeedback(.selection, trigger: toolTapTrigger)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
        }
    }

    private var backgroundGlow: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [KinexaTheme.accent.opacity(0.08), .clear],
                    center: .center, startRadius: 0, endRadius: 300
                )
            )
            .frame(width: 500, height: 500)
            .offset(y: -150)
            .blur(radius: 60)
            .ignoresSafeArea()
    }

    // MARK: - Top Action Buttons

    private var topActionButtons: some View {
        VStack(spacing: 12) {
            heroActionCard(
                title: "Build My Training Plan",
                subtitle: "AI-generated weekly programming",
                icon: "sparkles",
                gradient: [Color(hex: "#F59E0B"), Color(hex: "#D97706")]
            ) {
                toolTapTrigger.toggle()
                showWODPlanSheet = true
            }

            heroActionCard(
                title: "Manual Build",
                subtitle: "Design your own weekly routine",
                icon: "square.and.pencil",
                gradient: [Color(hex: "#6366F1"), Color(hex: "#4338CA")]
            ) {
                toolTapTrigger.toggle()
                pendingExercises = []
                showManualBuilder = true
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
    }

    private func heroActionCard(title: String, subtitle: String, icon: String, gradient: [Color], action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.body.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(.rect(cornerRadius: 11))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)
                    Text(subtitle)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(KinexaTheme.card)
            .clipShape(.rect(cornerRadius: 16))
            .elevatedCardShadow()
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke((gradient.first ?? .clear).opacity(0.2))
            }
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    // MARK: - Planner Blocks

    private var plannerBlocks: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("BROWSE & ADD")
                .font(.caption.weight(.heavy))
                .tracking(1.2)
                .foregroundStyle(KinexaTheme.tertiaryText)
                .padding(.leading, 4)

            if !pendingExercises.isEmpty {
                pendingExerciseBanner
            }

            HStack(spacing: 10) {
                plannerBlock(
                    title: "Functional",
                    subtitle: "Fitness",
                    icon: "bolt.heart.fill",
                    gradient: [Color(hex: "#F59E0B"), Color(hex: "#D97706")],
                    shadowColor: Color(hex: "#F59E0B")
                ) {
                    toolTapTrigger.toggle()
                    showFunctionalBrowser = true
                }

                plannerBlock(
                    title: "Free",
                    subtitle: "Weights",
                    icon: "dumbbell.fill",
                    gradient: [Color(hex: "#6366F1"), Color(hex: "#4338CA")],
                    shadowColor: Color(hex: "#6366F1")
                ) {
                    toolTapTrigger.toggle()
                    showWeightBrowser = true
                }

                plannerBlock(
                    title: "Cardio",
                    subtitle: " ",
                    icon: "heart.fill",
                    gradient: [Color(hex: "#EC4899"), Color(hex: "#BE185D")],
                    shadowColor: Color(hex: "#EC4899")
                ) {
                    toolTapTrigger.toggle()
                    showCardioBrowser = true
                }
            }

            HStack(spacing: 10) {
                smallPlanCard(
                    title: "Quick Workout",
                    subtitle: "One-off randomized session",
                    icon: "sparkles",
                    color: Color(hex: "#8B5CF6")
                ) {
                    toolTapTrigger.toggle()
                    showFunctionalWODSheet = true
                }

                smallPlanCard(
                    title: "Import PDF",
                    subtitle: "Upload your own workout",
                    icon: "doc.text.fill",
                    color: Color(hex: "#0EA5E9")
                ) {
                    toolTapTrigger.toggle()
                    showPDFUploadSheet = true
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    private var pendingExerciseBanner: some View {
        Button {
            showManualBuilder = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "tray.full.fill")
                    .font(.body.weight(.bold))
                    .foregroundStyle(KinexaTheme.accent)

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(pendingExercises.count) exercise\(pendingExercises.count == 1 ? "" : "s") queued")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)
                    Text("Tap to open Manual Build")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }
            .padding(12)
            .background(KinexaTheme.accent.opacity(0.08))
            .clipShape(.rect(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14).stroke(KinexaTheme.accent.opacity(0.2))
            }
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    private func plannerBlock(title: String, subtitle: String, icon: String, gradient: [Color], shadowColor: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(0.15))
                    .clipShape(.rect(cornerRadius: 12))

                VStack(spacing: 1) {
                    Text(title)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                }
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 130)
            .padding(.horizontal, 8)
            .background {
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .shadow(color: shadowColor.opacity(0.2), radius: 12, y: 8)
        }
        .buttonStyle(PressScaleButtonStyle())
        .accessibilityLabel("Browse \(title) workouts")
    }

    private func smallPlanCard(title: String, subtitle: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.12))
                    .clipShape(.rect(cornerRadius: 10))

                VStack(spacing: 3) {
                    Text(title)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text(subtitle)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(KinexaTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .elevatedCardShadow()
            .overlay {
                RoundedRectangle(cornerRadius: 16).stroke(KinexaTheme.border)
            }
        }
        .buttonStyle(PressScaleButtonStyle())
        .accessibilityLabel(title)
    }
}
