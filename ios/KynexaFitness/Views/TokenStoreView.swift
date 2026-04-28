import SwiftUI
import RevenueCat

struct TokenStoreView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(StoreViewModel.self) private var store
    @State private var purchasedTokenCount: Int = 0
    @State private var showSuccess: Bool = false
    @State private var showUpgrade: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                KynexaTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        headerSection
                        balanceCard
                        subscriptionUpsell
                        packagesSection
                        infoSection
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
                            .foregroundStyle(KynexaTheme.tertiaryText)
                    }
                }
            }
            .toolbarBackground(KynexaTheme.background, for: .navigationBar)
            
            .alert("Error", isPresented: .init(
                get: { store.error != nil },
                set: { if !$0 { store.error = nil } }
            )) {
                Button("OK") { store.error = nil }
            } message: {
                Text(store.error ?? "")
            }
            .overlay {
                if showSuccess {
                    successOverlay
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "#8B5CF6").opacity(0.3), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 60
                        )
                    )
                    .frame(width: 100, height: 100)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#8B5CF6"), Color(hex: "#6366F1")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)
                    .shadow(color: Color(hex: "#8B5CF6").opacity(0.4), radius: 20, y: 8)

                Image(systemName: "sparkles")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 6) {
                Text("AI Token Packs")
                    .font(.title.weight(.bold))
                    .foregroundStyle(KynexaTheme.primaryText)

                Text("Need more AI analyses? Buy tokens that never expire.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(KynexaTheme.secondaryText)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 8)
    }

    private var balanceCard: some View {
        let tracker = AIUsageTracker.shared
        return HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Token Balance")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(KynexaTheme.tertiaryText)

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(tracker.bonusTokens)")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color(hex: "#8B5CF6"))
                        .contentTransition(.numericText())

                    Text("tokens")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(KynexaTheme.secondaryText)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(store.isPremium ? "Daily Included" : "Free Scans")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(KynexaTheme.tertiaryText)

                if store.isPremium {
                    Text("\(tracker.remainingToday)/15")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(KynexaTheme.success)
                } else {
                    let freeLeft = tracker.remainingToday
                    Text("\(freeLeft) left")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(freeLeft > 0 ? KynexaTheme.success : KynexaTheme.warning)
                }
            }
        }
        .padding(16)
        .background(KynexaTheme.card)
        .clipShape(.rect(cornerRadius: 18))
        .elevatedCardShadow()
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(hex: "#8B5CF6").opacity(0.2))
        }
    }

    private var packagesSection: some View {
        VStack(spacing: 10) {
            if store.isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(Color(hex: "#8B5CF6"))
                    Text("Loading token packs...")
                        .font(.caption)
                        .foregroundStyle(KynexaTheme.tertiaryText)
                }
                .frame(height: 200)
            } else if store.tokenPackages.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title2)
                        .foregroundStyle(KynexaTheme.tertiaryText)
                    Text("Unable to load token packs")
                        .font(.subheadline)
                        .foregroundStyle(KynexaTheme.secondaryText)
                    Button("Retry") {
                        Task { await store.fetchOfferings() }
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(hex: "#8B5CF6"))
                }
                .frame(height: 200)
            } else {
                ForEach(store.tokenPackages, id: \.identifier) { package in
                    tokenPackCard(package)
                }
            }
        }
    }

    private func tokenPackCard(_ package: Package) -> some View {
        let identifier = package.storeProduct.productIdentifier
        let tokenCount = AIUsageTracker.shared.tokenCountForProduct(identifier)
        let isBestValue = identifier == "kinexa_tokens_100"
        let isPopular = identifier == "kinexa_tokens_30"

        return Button {
            if !store.isPremium {
                showUpgrade = true
                return
            }
            Task {
                purchasedTokenCount = tokenCount
                await store.purchaseTokens(package: package)
                if store.tokenPurchaseSuccess {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showSuccess = true
                    }
                    try? await Task.sleep(for: .seconds(2))
                    withAnimation { showSuccess = false }
                }
            }
        } label: {
            VStack(spacing: 0) {
                if isBestValue {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10, weight: .bold))
                        Text("BEST VALUE")
                            .font(.system(size: 10, weight: .heavy))
                            .tracking(1.0)
                    }
                    .foregroundStyle(.white)
                    .padding(.vertical, 7)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#8B5CF6"), Color(hex: "#6366F1")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                } else if isPopular {
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
                    .background(KynexaTheme.accent)
                }

                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#8B5CF6").opacity(0.12))
                            .frame(width: 44, height: 44)

                        Image(systemName: "sparkles")
                            .font(.body.weight(.bold))
                            .foregroundStyle(Color(hex: "#8B5CF6"))
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("\(tokenCount) Tokens")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(KynexaTheme.primaryText)

                        Text(packSubtitle(identifier))
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(KynexaTheme.tertiaryText)
                    }

                    Spacer(minLength: 0)

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(package.storeProduct.localizedPriceString)
                            .font(.title3.weight(.heavy))
                            .foregroundStyle(Color(hex: "#8B5CF6"))

                        Text(perTokenPrice(package, tokenCount: tokenCount))
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(KynexaTheme.tertiaryText)
                    }
                }
                .padding(16)
            }
            .background(KynexaTheme.card)
            .clipShape(.rect(cornerRadius: 18))
            .elevatedCardShadow()
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        isBestValue ? Color(hex: "#8B5CF6").opacity(0.4) :
                        isPopular ? KynexaTheme.accent.opacity(0.3) :
                        KynexaTheme.border,
                        lineWidth: isBestValue || isPopular ? 1.5 : 1
                    )
            }
        }
        .buttonStyle(PressScaleButtonStyle())
        .disabled(store.isPurchasing)
    }

    private func packSubtitle(_ identifier: String) -> String {
        switch identifier {
        case "kinexa_tokens_10": return "Starter Pack"
        case "kinexa_tokens_30": return "Plus Pack"
        case "kinexa_tokens_100": return "Power Pack"
        default: return ""
        }
    }

    private func perTokenPrice(_ package: Package, tokenCount: Int) -> String {
        guard tokenCount > 0 else { return "" }
        let price = package.storeProduct.price as Decimal
        let perToken = price / Decimal(tokenCount)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = package.storeProduct.priceFormatter?.locale ?? .current
        formatter.maximumFractionDigits = 3
        return "\(formatter.string(from: perToken as NSDecimalNumber) ?? "")/token"
    }

    private var subscriptionUpsell: some View {
        Group {
            if !store.isPremium {
                Button {
                    showUpgrade = true
                } label: {
                    VStack(spacing: 10) {
                        HStack(spacing: 10) {
                            Image(systemName: "crown.fill")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(KynexaTheme.heroAmber)
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Subscribe for the best value")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(KynexaTheme.primaryText)
                                Text("Get 15 AI scans per day — up to 450/month")
                                    .font(.caption2)
                                    .foregroundStyle(KynexaTheme.secondaryText)
                            }
                            Spacer(minLength: 0)
                            Image(systemName: "chevron.right")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(KynexaTheme.heroAmber)
                        }

                        Text("From ~$0.01/scan annually vs $0.20–$0.30/token")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(KynexaTheme.accent)
                    }
                    .padding(14)
                    .background(KynexaTheme.heroAmber.opacity(0.08))
                    .clipShape(.rect(cornerRadius: 14))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(KynexaTheme.heroAmber.opacity(0.2))
                    }
                }
                .buttonStyle(PressScaleButtonStyle())
                .sheet(isPresented: $showUpgrade) {
                    UpgradeView()
                }
            }
        }
    }

    private var infoSection: some View {
        VStack(spacing: 12) {
            infoRow(icon: "crown.fill", text: "Requires an active subscription")
            infoRow(icon: "plus.circle", text: "Tokens extend your daily scan limit")
            infoRow(icon: "infinity", text: "Tokens never expire")
            infoRow(icon: "bolt.fill", text: "Used automatically when your daily scans run out")
        }
        .padding(16)
        .background(KynexaTheme.cardSoft)
        .clipShape(.rect(cornerRadius: 16))
    }

    private func infoRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color(hex: "#8B5CF6"))
                .frame(width: 24, height: 24)
            Text(text)
                .font(.caption.weight(.medium))
                .foregroundStyle(KynexaTheme.secondaryText)
            Spacer()
        }
    }

    private var successOverlay: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(KynexaTheme.success)

            Text("+\(purchasedTokenCount) Tokens Added!")
                .font(.title2.weight(.bold))
                .foregroundStyle(KynexaTheme.primaryText)

            Text("Balance: \(AIUsageTracker.shared.bonusTokens) tokens")
                .font(.subheadline)
                .foregroundStyle(KynexaTheme.secondaryText)
        }
        .padding(32)
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 24))
        .transition(.scale.combined(with: .opacity))
    }
}
