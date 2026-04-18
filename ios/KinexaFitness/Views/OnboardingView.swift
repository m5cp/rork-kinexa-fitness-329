import SwiftUI

nonisolated enum OnboardingGoal: String, CaseIterable, Sendable {
    case loseFat = "Lose Fat"
    case buildMuscle = "Build Muscle"
    case improvePerformance = "Improve Performance"
    case stayConsistent = "Stay Consistent"

    var icon: String {
        switch self {
        case .loseFat: return "flame.fill"
        case .buildMuscle: return "dumbbell.fill"
        case .improvePerformance: return "bolt.fill"
        case .stayConsistent: return "checkmark.seal.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .loseFat: return "Cut calories, keep strength"
        case .buildMuscle: return "Train heavy, eat more protein"
        case .improvePerformance: return "Push harder, recover smarter"
        case .stayConsistent: return "Build the habit, no pressure"
        }
    }
}

nonisolated enum TrackingPreference: String, CaseIterable, Sendable {
    case caloriesOnly = "Calories Only"
    case caloriesProtein = "Calories + Protein"
    case fullMacros = "Full Macros"

    var subtitle: String {
        switch self {
        case .caloriesOnly: return "Fastest — just the basics"
        case .caloriesProtein: return "Recommended"
        case .fullMacros: return "Protein, carbs, and fat"
        }
    }

    var icon: String {
        switch self {
        case .caloriesOnly: return "number"
        case .caloriesProtein: return "chart.bar.fill"
        case .fullMacros: return "chart.pie.fill"
        }
    }
}

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("selectedGoal") private var selectedGoalRaw: String = OnboardingGoal.stayConsistent.rawValue
    @AppStorage("trackingPreference") private var trackingPreferenceRaw: String = TrackingPreference.caloriesProtein.rawValue
    @AppStorage("pendingInitialTab") private var pendingInitialTab: Int = AppTab.home.rawValue
    @AppStorage("showFirstMealHint") private var showFirstMealHint: Bool = false

    @State private var step: Int = 0
    @State private var selectionTrigger: Bool = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                KinexaTheme.background.ignoresSafeArea()

                backgroundGlow
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    topBar
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    ScrollView(showsIndicators: false) {
                        content
                            .padding(.horizontal, 24)
                            .frame(maxWidth: min(geo.size.width, 480))
                            .frame(maxWidth: .infinity)
                            .padding(.top, step == 0 ? 40 : 16)
                            .padding(.bottom, 24)
                    }

                    bottomBar
                        .padding(.horizontal, 24)
                        .padding(.bottom, geo.safeAreaInsets.bottom > 0 ? 8 : 20)
                        .frame(maxWidth: min(geo.size.width, 480))
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: step)
        .sensoryFeedback(.selection, trigger: selectionTrigger)
    }

    private var backgroundGlow: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [KinexaTheme.accent.opacity(0.22), .clear],
                    center: .center,
                    startRadius: 20,
                    endRadius: 280
                )
            )
            .frame(width: 520, height: 520)
            .offset(y: -220)
            .blur(radius: 40)
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack(alignment: .center) {
            if step > 0 && step < 3 {
                progressBar
                    .frame(maxWidth: 160)
            } else {
                Spacer()
            }

            Spacer()

            Button {
                complete(initialTab: .home)
            } label: {
                Text("Skip")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(KinexaTheme.secondaryText)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.06))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .frame(height: 36)
    }

    private var progressBar: some View {
        HStack(spacing: 6) {
            ForEach(1...2, id: \.self) { i in
                Capsule()
                    .fill(i <= step ? KinexaTheme.accent : Color.white.opacity(0.12))
                    .frame(height: 4)
            }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch step {
        case 0: hookStep
        case 1: goalStep
        case 2: trackingStep
        default: readyStep
        }
    }

    // MARK: - Step 0 — Hook

    private var hookStep: some View {
        VStack(spacing: 28) {
            ZStack {
                Circle()
                    .fill(KinexaTheme.accent.opacity(0.12))
                    .frame(width: 120, height: 120)

                Image("AppLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 96, height: 96)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
            }

            VStack(spacing: 14) {
                Text("Train hard.\nFuel smarter.\nStay consistent.")
                    .font(.system(size: 34, weight: .heavy))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)

                Text("Track workouts, log meals, and stay on track without overthinking it.")
                    .font(.body)
                    .foregroundStyle(KinexaTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 8)
            }
        }
    }

    // MARK: - Step 1 — Goal

    private var goalStep: some View {
        VStack(spacing: 24) {
            stepHeader(
                eyebrow: "Step 1 of 2",
                title: "What are you focused on right now?",
                subtitle: "Pick one — you can change this anytime."
            )

            VStack(spacing: 10) {
                ForEach(OnboardingGoal.allCases, id: \.rawValue) { goal in
                    optionCard(
                        title: goal.rawValue,
                        subtitle: goal.subtitle,
                        icon: goal.icon,
                        isSelected: selectedGoalRaw == goal.rawValue
                    ) {
                        selectedGoalRaw = goal.rawValue
                        selectionTrigger.toggle()
                        advance()
                    }
                }
            }
        }
    }

    // MARK: - Step 2 — Tracking

    private var trackingStep: some View {
        VStack(spacing: 24) {
            stepHeader(
                eyebrow: "Step 2 of 2",
                title: "How do you want to track meals?",
                subtitle: "Keep it simple. You can switch later."
            )

            VStack(spacing: 10) {
                ForEach(TrackingPreference.allCases, id: \.rawValue) { pref in
                    optionCard(
                        title: pref.rawValue,
                        subtitle: pref.subtitle,
                        icon: pref.icon,
                        isSelected: trackingPreferenceRaw == pref.rawValue
                    ) {
                        trackingPreferenceRaw = pref.rawValue
                        selectionTrigger.toggle()
                        advance()
                    }
                }
            }
        }
    }

    // MARK: - Step 3 — Ready

    private var readyStep: some View {
        VStack(spacing: 28) {
            ZStack {
                Circle()
                    .fill(KinexaTheme.accent.opacity(0.14))
                    .frame(width: 96, height: 96)
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .heavy))
                    .foregroundStyle(KinexaTheme.accent)
            }

            VStack(spacing: 12) {
                Text("You're ready to start.")
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text("Log your first meal or start your first workout.")
                    .font(.body)
                    .foregroundStyle(KinexaTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 8)
            }
        }
    }

    // MARK: - Bottom bar

    @ViewBuilder
    private var bottomBar: some View {
        switch step {
        case 0:
            primaryButton(title: "Get Started") { advance() }
        case 3:
            VStack(spacing: 10) {
                primaryButton(title: "Log Meal", icon: "fork.knife") {
                    complete(initialTab: .nutrition, showHint: true)
                }
                primaryButton(title: "Start Workout", icon: "dumbbell.fill", style: .outline) {
                    complete(initialTab: .workouts)
                }
                Button {
                    complete(initialTab: .home)
                } label: {
                    Text("Explore App")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(KinexaTheme.secondaryText)
                        .frame(height: 44)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        default:
            EmptyView()
        }
    }

    private enum ButtonStyleKind { case filled, outline }

    private func primaryButton(
        title: String,
        icon: String? = nil,
        style: ButtonStyleKind = .filled,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let icon {
                    Image(systemName: icon)
                        .font(.headline.weight(.bold))
                }
                Text(title)
                    .font(.headline.weight(.bold))
            }
            .foregroundStyle(style == .filled ? .white : .white)
            .frame(height: 56)
            .frame(maxWidth: .infinity)
            .background {
                if style == .filled {
                    KinexaTheme.heroGradient
                } else {
                    Color.white.opacity(0.06)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                if style == .outline {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                }
            }
            .shadow(
                color: style == .filled ? KinexaTheme.accent.opacity(0.3) : .clear,
                radius: 14, y: 6
            )
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    // MARK: - Reusable

    private func stepHeader(eyebrow: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 10) {
            Text(eyebrow.uppercased())
                .font(.caption2.weight(.heavy))
                .tracking(1.5)
                .foregroundStyle(KinexaTheme.accent)

            Text(title)
                .font(.system(size: 26, weight: .heavy))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(2)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(KinexaTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 8)
    }

    private func optionCard(
        title: String,
        subtitle: String,
        icon: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(isSelected ? .white : KinexaTheme.accent)
                    .frame(width: 44, height: 44)
                    .background(isSelected ? KinexaTheme.accent : KinexaTheme.accent.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(KinexaTheme.secondaryText)
                }

                Spacer(minLength: 0)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? KinexaTheme.accent : KinexaTheme.tertiaryText.opacity(0.5))
            }
            .padding(14)
            .background(
                isSelected ? KinexaTheme.accent.opacity(0.10) : Color.white.opacity(0.04)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? KinexaTheme.accent.opacity(0.5) : Color.white.opacity(0.08),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            }
            .shadow(
                color: isSelected ? KinexaTheme.accent.opacity(0.2) : .clear,
                radius: 12, y: 4
            )
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    // MARK: - Flow

    private func advance() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
            step = min(step + 1, 3)
        }
    }

    private func complete(initialTab: AppTab, showHint: Bool = false) {
        pendingInitialTab = initialTab.rawValue
        if showHint {
            showFirstMealHint = true
        }
        withAnimation(.easeOut(duration: 0.25)) {
            hasCompletedOnboarding = true
        }
    }
}
