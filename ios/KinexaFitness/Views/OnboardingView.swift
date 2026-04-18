import SwiftUI
import RevenueCat

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
    @Environment(StoreViewModel.self) private var store
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("selectedGoal") private var selectedGoalRaw: String = OnboardingGoal.stayConsistent.rawValue
    @AppStorage("trackingPreference") private var trackingPreferenceRaw: String = TrackingPreference.caloriesProtein.rawValue
    @AppStorage("pendingInitialTab") private var pendingInitialTab: Int = AppTab.home.rawValue
    @AppStorage("showFirstMealHint") private var showFirstMealHint: Bool = false

    @State private var step: Int = 0
    @State private var selectionTrigger: Bool = false
    @State private var selectedPackageID: String?

    private let totalSelectionSteps = 2

    var body: some View {
        ZStack {
            KinexaTheme.background.ignoresSafeArea()
            backgroundGlow.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    content
                        .padding(.horizontal, 20)
                        .padding(.top, step == 0 ? 24 : 12)
                        .padding(.bottom, 16)
                        .frame(maxWidth: .infinity)
                }

                bottomBar
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
            }
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity)
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: step)
        .sensoryFeedback(.selection, trigger: selectionTrigger)
        .onChange(of: store.isPremium) { _, isPremium in
            if isPremium && step == 3 {
                complete(initialTab: .home)
            }
        }
        .task {
            if store.offerings == nil {
                await store.fetchOfferings()
            }
        }
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
        HStack(alignment: .center, spacing: 12) {
            if step > 0 && step < 3 {
                progressBar
                    .frame(maxWidth: 160)
            }

            Spacer(minLength: 0)

            Button {
                if step == 3 {
                    complete(initialTab: .home)
                } else {
                    complete(initialTab: .home)
                }
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
            ForEach(1...totalSelectionSteps, id: \.self) { i in
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
        default: paywallStep
        }
    }

    // MARK: - Step 0 — Hook (no logo)

    private var hookStep: some View {
        VStack(spacing: 28) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [KinexaTheme.accent.opacity(0.25), KinexaTheme.accent2.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)

                Circle()
                    .stroke(KinexaTheme.accent.opacity(0.4), lineWidth: 1)
                    .frame(width: 120, height: 120)

                Image(systemName: "bolt.heart.fill")
                    .font(.system(size: 52, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [KinexaTheme.accent, KinexaTheme.accent2],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(.top, 12)

            VStack(spacing: 14) {
                Text("Train hard.\nFuel smarter.\nStay consistent.")
                    .font(.system(size: 34, weight: .heavy))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .minimumScaleFactor(0.7)

                Text("Track workouts, log meals, and stay on track without overthinking it.")
                    .font(.body)
                    .foregroundStyle(KinexaTheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
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

    // MARK: - Step 3 — Paywall

    private var paywallStep: some View {
        VStack(spacing: 22) {
            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [KinexaTheme.accent, KinexaTheme.accent2],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 68, height: 68)
                        .shadow(color: KinexaTheme.accent.opacity(0.4), radius: 16, y: 6)

                    Image(systemName: "crown.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                }

                VStack(spacing: 8) {
                    Text("Unlock Kinexa Pro")
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.7)

                    Text("Smarter tracking, more AI, deeper insights.")
                        .font(.subheadline)
                        .foregroundStyle(KinexaTheme.secondaryText)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            proBenefitsList

            plansSection
        }
    }

    private var proBenefitsList: some View {
        VStack(alignment: .leading, spacing: 10) {
            benefitRow(icon: "fork.knife", text: "20 AI meal scans per day")
            benefitRow(icon: "figure.strengthtraining.traditional", text: "15 AI workouts per day")
            benefitRow(icon: "sparkles", text: "50 AI coach messages per day")
            benefitRow(icon: "chart.line.uptrend.xyaxis", text: "Advanced insights & exports")
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.08))
        }
    }

    private func benefitRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(KinexaTheme.accent)
                .frame(width: 24)
            Text(text)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private var plansSection: some View {
        if store.isLoading && store.offerings == nil {
            HStack(spacing: 10) {
                ProgressView().tint(KinexaTheme.accent)
                Text("Loading plans…")
                    .font(.footnote)
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
        } else if let current = store.offerings?.current {
            let packages = sortedPackages(from: current)
            if packages.isEmpty {
                unavailablePlans
            } else {
                HStack(spacing: 10) {
                    ForEach(packages, id: \.identifier) { package in
                        planCard(package, packages: packages)
                    }
                }
            }
        } else {
            unavailablePlans
        }
    }

    private var unavailablePlans: some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.subheadline)
                .foregroundStyle(KinexaTheme.tertiaryText)
            Text("Plans unavailable right now")
                .font(.footnote)
                .foregroundStyle(KinexaTheme.secondaryText)
            Button("Retry") {
                Task { await store.fetchOfferings() }
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(KinexaTheme.accent)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func planCard(_ package: Package, packages: [Package]) -> some View {
        let isSelected = (selectedPackageID ?? defaultPackageID(packages)) == package.identifier
        let isAnnual = package.packageType == .annual

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedPackageID = package.identifier
                selectionTrigger.toggle()
            }
        } label: {
            VStack(spacing: 0) {
                if isAnnual {
                    Text("BEST VALUE")
                        .font(.system(size: 10, weight: .heavy))
                        .tracking(1.0)
                        .foregroundStyle(.white)
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity)
                        .background(KinexaTheme.accent)
                } else {
                    Color.clear.frame(height: 22)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(planTitle(package))
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)

                    Text(package.storeProduct.localizedPriceString)
                        .font(.title2.weight(.heavy))
                        .foregroundStyle(isSelected ? KinexaTheme.accent : .white)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)

                    Text(planPeriod(package))
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(KinexaTheme.tertiaryText)

                    if let trial = trialText(package) {
                        Text(trial)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(KinexaTheme.success)
                            .padding(.top, 2)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
            }
            .background(
                isSelected ? KinexaTheme.accent.opacity(0.10) : Color.white.opacity(0.04)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? KinexaTheme.accent.opacity(0.6) : Color.white.opacity(0.1),
                        lineWidth: isSelected ? 1.6 : 1
                    )
            }
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    private func defaultPackageID(_ packages: [Package]) -> String {
        (packages.first { $0.packageType == .annual } ?? packages.first)?.identifier ?? ""
    }

    private func planTitle(_ package: Package) -> String {
        switch package.packageType {
        case .monthly: return "Monthly"
        case .annual: return "Annual"
        default: return package.storeProduct.localizedTitle
        }
    }

    private func planPeriod(_ package: Package) -> String {
        switch package.packageType {
        case .monthly: return "per month"
        case .annual: return "per year"
        default: return ""
        }
    }

    private func trialText(_ package: Package) -> String? {
        guard let intro = package.storeProduct.introductoryDiscount, intro.price == 0 else { return nil }
        let value = intro.subscriptionPeriod.value
        let unit: String
        switch intro.subscriptionPeriod.unit {
        case .day: unit = value == 1 ? "day" : "days"
        case .week: unit = value == 1 ? "week" : "weeks"
        case .month: unit = value == 1 ? "month" : "months"
        case .year: unit = value == 1 ? "year" : "years"
        @unknown default: unit = "days"
        }
        return "\(value)-\(unit) free trial"
    }

    private func sortedPackages(from offering: Offering) -> [Package] {
        let order: [PackageType] = [.monthly, .annual]
        return offering.availablePackages
            .filter { $0.packageType == .monthly || $0.packageType == .annual }
            .sorted { a, b in
                let aIdx = order.firstIndex(of: a.packageType) ?? 99
                let bIdx = order.firstIndex(of: b.packageType) ?? 99
                return aIdx < bIdx
            }
    }

    private func currentSelectedPackage() -> Package? {
        guard let current = store.offerings?.current else { return nil }
        let packages = sortedPackages(from: current)
        let id = selectedPackageID ?? defaultPackageID(packages)
        return packages.first { $0.identifier == id } ?? packages.first
    }

    // MARK: - Bottom bar

    @ViewBuilder
    private var bottomBar: some View {
        switch step {
        case 0:
            primaryButton(title: "Get Started") { advance() }
        case 3:
            VStack(spacing: 10) {
                if let package = currentSelectedPackage() {
                    primaryButton(
                        title: ctaText(package),
                        icon: store.isPurchasing ? nil : "lock.open.fill",
                        isLoading: store.isPurchasing
                    ) {
                        Task { await store.purchase(package: package) }
                    }
                } else {
                    primaryButton(title: "Continue", icon: "arrow.right") {
                        complete(initialTab: .home)
                    }
                    .opacity(0.5)
                    .disabled(true)
                }

                Button {
                    complete(initialTab: .home)
                } label: {
                    Text("Continue with Free")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(height: 44)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)

                Button {
                    Task { await store.restore() }
                } label: {
                    Text("Restore Purchases")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }
                .buttonStyle(.plain)
            }
        default:
            EmptyView()
        }
    }

    private func ctaText(_ package: Package) -> String {
        if trialText(package) != nil { return "Start Free Trial" }
        switch package.packageType {
        case .annual: return "Subscribe Annually"
        case .monthly: return "Subscribe Monthly"
        default: return "Subscribe"
        }
    }

    private enum ButtonStyleKind { case filled, outline }

    private func primaryButton(
        title: String,
        icon: String? = nil,
        style: ButtonStyleKind = .filled,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView().tint(.white)
                } else if let icon {
                    Image(systemName: icon)
                        .font(.headline.weight(.bold))
                }
                Text(title)
                    .font(.headline.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(.white)
            .frame(height: 54)
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
        .disabled(isLoading)
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
                .minimumScaleFactor(0.75)
                .fixedSize(horizontal: false, vertical: true)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(KinexaTheme.secondaryText)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 4)
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
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text(subtitle)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(KinexaTheme.secondaryText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? KinexaTheme.accent : KinexaTheme.tertiaryText.opacity(0.5))
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
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
