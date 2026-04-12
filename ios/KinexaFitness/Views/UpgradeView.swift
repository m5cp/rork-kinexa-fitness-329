import SwiftUI
import RevenueCat

struct UpgradeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(StoreViewModel.self) private var store

    @State private var selectedPackageID: String?
    @State private var animateIn: Bool = false
    @State private var pulseGlow: Bool = false
    @State private var purchaseTrigger: Bool = false

    private let proFeatures: [(icon: String, title: String, desc: String)] = [
        ("bolt.shield.fill", "Advanced PT Plans", "Unlimited plan generation & customization"),
        ("chart.line.uptrend.xyaxis", "AI Insights", "On-device intelligence for smarter training"),
        ("fork.knife", "Full Nutrition Suite", "Unlimited recipes, meal plans & macro tracking"),
        ("person.3.fill", "Unit PT Builder", "Build & share group workouts"),
        ("doc.text.fill", "PDF & Calendar Export", "Export plans, scores & schedules"),
        ("square.and.arrow.up.fill", "Share Cards & QR", "Share progress & import workouts")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                KinexaTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        headerSection
                        featuresGrid
                        plansSection
                        ctaButton
                        legalSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 48)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(KinexaTheme.tertiaryText)
                    }
                }
            }
            .toolbarBackground(KinexaTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("Error", isPresented: .init(
                get: { store.error != nil },
                set: { if !$0 { store.error = nil } }
            )) {
                Button("OK") { store.error = nil }
            } message: {
                Text(store.error ?? "")
            }
            .onChange(of: store.isPremium) { _, isPremium in
                if isPremium { dismiss() }
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.82).delay(0.1)) {
                    animateIn = true
                }
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(0.6)) {
                    pulseGlow = true
                }
                if selectedPackageID == nil, let current = store.offerings?.current {
                    let lifetime = current.availablePackages.first { $0.packageType == .lifetime }
                    let annual = current.availablePackages.first { $0.packageType == .annual }
                    selectedPackageID = (lifetime ?? annual)?.identifier
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [KinexaTheme.accent.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 60
                        )
                    )
                    .frame(width: 100, height: 100)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [KinexaTheme.accent, KinexaTheme.accent2],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)
                    .shadow(color: KinexaTheme.accent.opacity(0.4), radius: 20, y: 8)

                Image(systemName: "crown.fill")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.white)
            }
            .scaleEffect(animateIn ? 1 : 0.5)
            .opacity(animateIn ? 1 : 0)

            VStack(spacing: 6) {
                Text("Unlock Kinexa Pro")
                    .font(.title.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)

                Text("Train smarter. Eat better. Perform at your best.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(KinexaTheme.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .opacity(animateIn ? 1 : 0)
            .offset(y: animateIn ? 0 : 10)
        }
        .padding(.top, 8)
    }

    private var featuresGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10)
        ], spacing: 10) {
            ForEach(Array(proFeatures.enumerated()), id: \.element.title) { index, feature in
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: feature.icon)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(KinexaTheme.accent)
                        .frame(width: 32, height: 32)
                        .background(KinexaTheme.accent.opacity(0.12))
                        .clipShape(.rect(cornerRadius: 8))

                    Text(feature.title)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)

                    Text(feature.desc)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(KinexaTheme.card)
                .clipShape(.rect(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(KinexaTheme.border)
                }
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 8)
                .animation(
                    .spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.04 + 0.15),
                    value: animateIn
                )
            }
        }
    }

    private var plansSection: some View {
        VStack(spacing: 10) {
            if store.isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(KinexaTheme.accent)
                    Text("Loading plans...")
                        .font(.caption)
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }
                .frame(height: 180)
            } else if let current = store.offerings?.current {
                let packages = sortedPackages(from: current)

                ForEach(packages, id: \.identifier) { package in
                    planCard(package, packages: packages)
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title2)
                        .foregroundStyle(KinexaTheme.tertiaryText)
                    Text("Unable to load subscription options")
                        .font(.subheadline)
                        .foregroundStyle(KinexaTheme.secondaryText)
                    Button("Retry") {
                        Task { await store.fetchOfferings() }
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(KinexaTheme.accent)
                }
                .frame(height: 180)
            }
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 12)
        .animation(.spring(response: 0.6, dampingFraction: 0.82).delay(0.3), value: animateIn)
    }

    private func planCard(_ package: Package, packages: [Package]) -> some View {
        let isSelected = selectedPackageID == package.identifier
        let isLifetime = package.packageType == .lifetime
        let isAnnual = package.packageType == .annual

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedPackageID = package.identifier
            }
        } label: {
            VStack(spacing: 0) {
                if isLifetime {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10, weight: .bold))
                        Text("BEST VALUE")
                            .font(.system(size: 10, weight: .heavy))
                            .tracking(1.0)
                    }
                    .foregroundStyle(Color(hex: "#0C0F0E"))
                    .padding(.vertical, 7)
                    .frame(maxWidth: .infinity)
                    .background(KinexaTheme.heroAmber)
                } else if isAnnual {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 10, weight: .bold))
                        Text("MOST POPULAR")
                            .font(.system(size: 10, weight: .heavy))
                            .tracking(1.0)
                    }
                    .foregroundStyle(.white)
                    .padding(.vertical, 7)
                    .frame(maxWidth: .infinity)
                    .background(KinexaTheme.accent)
                }

                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .stroke(isSelected ? (isLifetime ? KinexaTheme.heroAmber : KinexaTheme.accent) : KinexaTheme.tertiaryText.opacity(0.4), lineWidth: 2)
                            .frame(width: 24, height: 24)
                        if isSelected {
                            Circle()
                                .fill(isLifetime ? KinexaTheme.heroAmber : KinexaTheme.accent)
                                .frame(width: 14, height: 14)
                        }
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(planTitle(package))
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(KinexaTheme.primaryText)

                        Text(planSubtitle(package, packages: packages))
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(isLifetime ? KinexaTheme.heroAmber : KinexaTheme.success)
                    }

                    Spacer(minLength: 0)

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(package.storeProduct.localizedPriceString)
                            .font(.title3.weight(.heavy))
                            .foregroundStyle(isSelected ? (isLifetime ? KinexaTheme.heroAmber : KinexaTheme.accent) : KinexaTheme.primaryText)

                        Text(planPeriod(package))
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(KinexaTheme.tertiaryText)
                    }
                }
                .padding(16)
            }
            .background(
                isLifetime && isSelected ?
                LinearGradient(
                    colors: [Color(hex: "#1A1A2E"), Color(hex: "#16213E")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ) :
                LinearGradient(
                    colors: [isSelected ? KinexaTheme.accent.opacity(0.06) : KinexaTheme.card, isSelected ? KinexaTheme.accent.opacity(0.03) : KinexaTheme.card],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(.rect(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        isSelected ?
                        (isLifetime ? KinexaTheme.heroAmber.opacity(pulseGlow ? 0.7 : 0.4) : KinexaTheme.accent.opacity(0.5)) :
                        KinexaTheme.border,
                        lineWidth: isSelected ? 1.5 : 1
                    )
            }
            .shadow(
                color: isLifetime && isSelected ? KinexaTheme.heroAmber.opacity(pulseGlow ? 0.15 : 0.05) : .clear,
                radius: 16, y: 8
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: selectedPackageID)
    }

    private func planTitle(_ package: Package) -> String {
        switch package.packageType {
        case .monthly: return "Monthly"
        case .annual: return "Annual"
        case .lifetime: return "Lifetime Access"
        default: return package.storeProduct.localizedTitle
        }
    }

    private func planSubtitle(_ package: Package, packages: [Package]) -> String {
        switch package.packageType {
        case .monthly:
            return "Cancel anytime"
        case .annual:
            if let intro = package.storeProduct.introductoryDiscount {
                return "\(intro.subscriptionPeriod.value)-\(intro.subscriptionPeriod.unit == .day ? "day" : intro.subscriptionPeriod.unit == .week ? "week" : "month") free trial"
            }
            return "Save 58% vs monthly"
        case .lifetime:
            return "One payment. Yours forever."
        default:
            return ""
        }
    }

    private func planPeriod(_ package: Package) -> String {
        switch package.packageType {
        case .monthly: return "per month"
        case .annual: return "per year"
        case .lifetime: return "one time"
        default: return ""
        }
    }

    private var ctaButton: some View {
        Group {
            if let current = store.offerings?.current, let selected = selectedPackage(from: current) {
                Button {
                    purchaseTrigger.toggle()
                    Task { await store.purchase(package: selected) }
                } label: {
                    HStack(spacing: 10) {
                        if store.isPurchasing {
                            ProgressView().tint(.white)
                        } else {
                            Image(systemName: selected.packageType == .lifetime ? "crown.fill" : "lock.open.fill")
                                .font(.subheadline.weight(.bold))
                        }
                        Text(ctaText(selected))
                            .font(.headline.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        selected.packageType == .lifetime ?
                        LinearGradient(colors: [KinexaTheme.heroAmber, KinexaTheme.heroAmber.opacity(0.85)], startPoint: .leading, endPoint: .trailing) :
                        KinexaTheme.heroGradient
                    )
                    .clipShape(.rect(cornerRadius: 18))
                    .shadow(
                        color: (selected.packageType == .lifetime ? KinexaTheme.heroAmber : KinexaTheme.accent).opacity(0.3),
                        radius: 16, y: 8
                    )
                }
                .disabled(store.isPurchasing)
                .buttonStyle(PressScaleButtonStyle())
                .sensoryFeedback(.impact(weight: .medium), trigger: purchaseTrigger)
            }
        }
        .opacity(animateIn ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.82).delay(0.4), value: animateIn)
    }

    private func ctaText(_ package: Package) -> String {
        switch package.packageType {
        case .lifetime: return "Get Lifetime Access"
        case .annual:
            if package.storeProduct.introductoryDiscount != nil {
                return "Start Free Trial"
            }
            return "Subscribe Annually"
        case .monthly: return "Subscribe Monthly"
        default: return "Continue"
        }
    }

    private func sortedPackages(from offering: Offering) -> [Package] {
        let order: [PackageType] = [.monthly, .annual, .lifetime]
        return offering.availablePackages.sorted { a, b in
            let aIdx = order.firstIndex(of: a.packageType) ?? 99
            let bIdx = order.firstIndex(of: b.packageType) ?? 99
            return aIdx < bIdx
        }
    }

    private func selectedPackage(from offering: Offering) -> Package? {
        if let id = selectedPackageID {
            return offering.availablePackages.first { $0.identifier == id }
        }
        return offering.availablePackages.first { $0.packageType == .lifetime } ?? offering.availablePackages.first
    }

    private var legalSection: some View {
        VStack(spacing: 10) {
            Button("Restore Purchases") {
                Task { await store.restore() }
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(KinexaTheme.accent)

            HStack(spacing: 16) {
                NavigationLink {
                    LegalTextView(title: "Terms of Use", content: LegalContent.termsOfUse)
                } label: {
                    Text("Terms of Use")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                        .underline()
                }

                NavigationLink {
                    LegalTextView(title: "Privacy Policy", content: LegalContent.privacyPolicy)
                } label: {
                    Text("Privacy Policy")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                        .underline()
                }
            }

            Text("Payment will be charged to your Apple ID account at confirmation of purchase. Subscriptions automatically renew unless cancelled at least 24 hours before the end of the current period. Manage subscriptions in Settings > Apple ID > Subscriptions.")
                .font(.system(size: 9))
                .foregroundStyle(KinexaTheme.tertiaryText.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
        .opacity(animateIn ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.5), value: animateIn)
    }
}
