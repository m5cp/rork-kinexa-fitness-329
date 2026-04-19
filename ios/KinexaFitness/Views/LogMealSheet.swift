import SwiftUI
import PhotosUI

struct LogMealSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(StoreViewModel.self) private var store
    let nutritionVM: NutritionViewModel

    @State private var selectedMealType: MealType = .lunch
    @State private var foodDescription: String = ""
    @State private var estimatedFoods: [FoodItem] = []
    @State private var isEstimating: Bool = false
    @State private var errorMessage: String?
    @State private var notes: String = ""
    @State private var hasEstimated: Bool = false
    @State private var showCamera: Bool = false
    @State private var showBarcode: Bool = false
    @State private var capturedPhotoData: Data?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var activeMode: MealInputMode?
    @State private var navPath: [MealInputMode] = []
    @State private var showManualEntry: Bool = false
    @State private var showUpgrade: Bool = false
    @State private var showTokenStore: Bool = false
    @State private var quickLogToast: String?
    @State private var showTemplates: Bool = false
    @State private var isRepeatingYesterday: Bool = false

    var body: some View {
        NavigationStack(path: $navPath) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    mealTypeSelector
                    quickRepeatRow
                    heroCardsGrid
                    if isEstimating { estimatingView }
                    if hasEstimated && !estimatedFoods.isEmpty { estimatedFoodsSection }
                    if let error = errorMessage { errorView(error) }
                    if hasEstimated && !estimatedFoods.isEmpty { notesSection }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .background(KinexaTheme.background.ignoresSafeArea())
            .navigationTitle("Log Meal")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: MealInputMode.self) { mode in
                destinationView(for: mode)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(KinexaTheme.secondaryText)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveMeal() }
                        .font(.headline.weight(.bold))
                        .foregroundStyle(estimatedFoods.isEmpty ? KinexaTheme.tertiaryText : KinexaTheme.success)
                        .disabled(estimatedFoods.isEmpty)
                }
            }
            .overlay(alignment: .bottom) {
                if let toast = quickLogToast {
                    quickLogToastView(toast)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 20)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .fullScreenCover(isPresented: $showCamera) {
            FoodCameraView { data in
                capturedPhotoData = data
                Task { await analyzePhoto(data) }
            }
        }
        .fullScreenCover(isPresented: $showBarcode) {
            BarcodeScannerView { code in
                Task { await lookupBarcode(code) }
            }
        }
        .sheet(isPresented: $showManualEntry) {
            ManualFoodEntrySheet { food in
                estimatedFoods.append(food)
                hasEstimated = true
            }
        }
        .onChange(of: selectedPhoto) { _, newValue in
            guard let newValue else { return }
            Task { await loadAndAnalyzePhoto(newValue) }
        }
        .sheet(isPresented: $showUpgrade) {
            UpgradeView()
        }
        .sheet(isPresented: $showTokenStore) {
            TokenStoreView()
        }
        .sheet(isPresented: $showTemplates) {
            MealTemplatesSheet(nutritionVM: nutritionVM, initialMealType: selectedMealType) {
                showQuickLogToast("Template logged")
                dismiss()
            }
        }
    }

    // MARK: - Quick Repeat Row

    private var quickRepeatRow: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Button {
                    guard !isRepeatingYesterday else { return }
                    guard !nutritionVM.yesterdaysMeals.isEmpty else { return }
                    isRepeatingYesterday = true
                    nutritionVM.repeatYesterday()
                    showQuickLogToast("Yesterday's meals logged")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { dismiss() }
                } label: {
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.22))
                                .frame(width: 34, height: 34)
                            Image(systemName: "arrow.uturn.backward")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Repeat Yesterday")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                            Text(yesterdaySubtitle)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.white.opacity(0.8))
                                .lineLimit(1)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .background(
                        LinearGradient(
                            colors: nutritionVM.yesterdaysMeals.isEmpty
                            ? [Color(hex: "#6366F1"), Color(hex: "#4338CA")]
                            : [Color(hex: "#0EA5E9"), Color(hex: "#0369A1")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(.rect(cornerRadius: 14))
                    .shadow(color: (nutritionVM.yesterdaysMeals.isEmpty ? Color(hex: "#6366F1") : Color(hex: "#0EA5E9")).opacity(0.25), radius: 10, y: 5)
                    .opacity(nutritionVM.yesterdaysMeals.isEmpty ? 0.85 : 1)
                }
                .buttonStyle(PressScaleButtonStyle())
                .disabled(nutritionVM.yesterdaysMeals.isEmpty || isRepeatingYesterday)

                Button {
                    showTemplates = true
                } label: {
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.22))
                                .frame(width: 34, height: 34)
                            Image(systemName: "square.stack.3d.up.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Templates")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                            Text(templatesSubtitle)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.white.opacity(0.8))
                                .lineLimit(1)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#F59E0B"), Color(hex: "#D97706")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(.rect(cornerRadius: 14))
                    .shadow(color: Color(hex: "#F59E0B").opacity(0.25), radius: 10, y: 5)
                }
                .buttonStyle(PressScaleButtonStyle())
            }

            if !nutritionVM.recentFoods.isEmpty {
                recentFoodsStrip
            }
        }
    }

    private var yesterdaySubtitle: String {
        let meals = nutritionVM.yesterdaysMeals
        if meals.isEmpty { return "No meals logged yesterday" }
        let cals = meals.map(\.totalNutrition.calories).reduce(0, +)
        return "\(meals.count) meal\(meals.count == 1 ? "" : "s") · \(cals) cal"
    }

    private var templatesSubtitle: String {
        let count = nutritionVM.mealTemplates.count
        if count == 0 { return "Save meals for one-tap logs" }
        return "\(count) saved · tap to log"
    }

    private var recentFoodsStrip: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Recent & Frequent")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(KinexaTheme.secondaryText)
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(nutritionVM.recentFoods) { fav in
                        Button {
                            nutritionVM.quickLogFavorite(fav, mealType: selectedMealType)
                            showQuickLogToast(fav.name)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(KinexaTheme.accent)
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(fav.name)
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(KinexaTheme.primaryText)
                                        .lineLimit(1)
                                    Text("\(fav.nutrition.calories) cal")
                                        .font(.system(size: 9, weight: .semibold))
                                        .foregroundStyle(KinexaTheme.tertiaryText)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
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
            .contentMargins(.horizontal, 0)
        }
    }

    // MARK: - Meal Type

    private var mealTypeSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Meal Type")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(KinexaTheme.secondaryText)

            HStack(spacing: 8) {
                ForEach(MealType.allCases, id: \.rawValue) { type in
                    let isSelected = selectedMealType == type
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedMealType = type
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: type.icon)
                                .font(.system(size: 16, weight: .bold))
                            Text(type.rawValue)
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundStyle(isSelected ? .white : Color(hex: type.color))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(isSelected ? Color(hex: type.color) : Color(hex: type.color).opacity(0.12))
                        .clipShape(.rect(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Hero Cards Grid

    private var heroCardsGrid: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                heroCard(
                    icon: "camera.fill",
                    title: "Scan Food",
                    subtitle: "Photo or gallery",
                    gradient: [Color(hex: "#22C55E"), Color(hex: "#16A34A")],
                    badge: aiBadgeText,
                    mode: .photo
                )

                heroCard(
                    icon: "barcode.viewfinder",
                    title: "Barcode",
                    subtitle: "Scan a product",
                    gradient: [Color(hex: "#3B82F6"), Color(hex: "#2563EB")],
                    badge: nil,
                    mode: .barcode
                )
            }

            HStack(spacing: 12) {
                heroCard(
                    icon: "sparkles",
                    title: "AI Describe",
                    subtitle: "Type your meal",
                    gradient: [Color(hex: "#6366F1"), Color(hex: "#8B5CF6")],
                    badge: aiBadgeText,
                    mode: .text
                )

                heroCard(
                    icon: "magnifyingglass",
                    title: "Food Search",
                    subtitle: "Search foods & brands",
                    gradient: [Color(hex: "#0EA5E9"), Color(hex: "#0369A1")],
                    badge: nil,
                    mode: .database
                )
            }

            HStack(spacing: 12) {
                heroCard(
                    icon: "star.fill",
                    title: "Favorites",
                    subtitle: "\(nutritionVM.favorites.count) saved",
                    gradient: [Color(hex: "#F59E0B"), Color(hex: "#D97706")],
                    badge: nil,
                    mode: .favorites
                )
            }

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    activeMode = .manual
                }
                showManualEntry = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "pencil.line")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color(hex: "#F59E0B"))
                    Text("Enter Manually")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(KinexaTheme.card)
                .clipShape(.rect(cornerRadius: 14))
                .elevatedCardShadow()
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(KinexaTheme.border)
                }
            }
            .buttonStyle(PressScaleButtonStyle())
        }
    }

    private var aiBadgeText: String? {
        let scan = AIUsageTracker.shared
        if scan.hasReachedLimit { return nil }
        return "\(scan.totalRemaining) left"
    }

    private var scanUsageCaption: String {
        let scan = AIUsageTracker.shared
        return "\(scan.dailyUsageCount) / \(scan.dailyLimit) AI scans used today"
    }

    private func heroCard(icon: String, title: String, subtitle: String, gradient: [Color], badge: String?, mode: MealInputMode) -> some View {
        return Button {
            errorMessage = nil
            if mode == .manual {
                showManualEntry = true
            } else {
                navPath.append(mode)
            }
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.2))
                            .frame(width: 40, height: 40)
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    if let badge {
                        Text(badge)
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundStyle(.white.opacity(0.9))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(.white.opacity(0.2))
                            .clipShape(Capsule())
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .clipShape(.rect(cornerRadius: 18))
            .shadow(color: (gradient.first ?? .clear).opacity(0.30), radius: 12, y: 6)
            .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    @ViewBuilder
    private func destinationView(for mode: MealInputMode) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                switch mode {
                case .photo: photoInputSection
                case .barcode: barcodeInputSection
                case .text: foodInputSection
                case .favorites: favoritesSection
                case .database: usdaSearchSection
                case .manual: EmptyView()
                }
                if isEstimating { estimatingView }
                if hasEstimated && !estimatedFoods.isEmpty { estimatedFoodsSection }
                if let error = errorMessage { errorView(error) }
                if hasEstimated && !estimatedFoods.isEmpty { notesSection }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .background(KinexaTheme.background.ignoresSafeArea())
        .navigationTitle(modeTitle(mode))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveMeal()
                }
                .font(.headline.weight(.bold))
                .foregroundStyle(estimatedFoods.isEmpty ? KinexaTheme.tertiaryText : KinexaTheme.success)
                .disabled(estimatedFoods.isEmpty)
            }
        }
    }

    private func modeTitle(_ mode: MealInputMode) -> String {
        switch mode {
        case .photo: return "Scan Food"
        case .barcode: return "Scan Barcode"
        case .text: return "AI Describe"
        case .favorites: return "Favorites"
        case .database: return "Food Search"
        case .manual: return "Manual Entry"
        }
    }

    // MARK: - Photo Input

    private var photoInputSection: some View {
        VStack(spacing: 14) {
            if let data = capturedPhotoData, let uiImage = UIImage(data: data) {
                Color(.secondarySystemBackground)
                    .frame(height: 200)
                    .overlay {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .allowsHitTesting(false)
                    }
                    .clipShape(.rect(cornerRadius: 16))
                    .overlay(alignment: .topTrailing) {
                        Button {
                            capturedPhotoData = nil
                            estimatedFoods = []
                            hasEstimated = false
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.white)
                                .shadow(radius: 4)
                        }
                        .padding(10)
                    }
            }

            if AIUsageTracker.shared.hasReachedLimit {
                foodScanLimitBanner
            } else {
                HStack(spacing: 12) {
                    Button {
                        showCamera = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.subheadline.weight(.bold))
                            Text("Take Photo")
                                .font(.subheadline.weight(.bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#22C55E"), Color(hex: "#16A34A")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(.rect(cornerRadius: 14))
                    }
                    .buttonStyle(PressScaleButtonStyle())

                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        HStack(spacing: 8) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.subheadline.weight(.bold))
                            Text("Gallery")
                                .font(.subheadline.weight(.bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#6366F1"), Color(hex: "#8B5CF6")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(.rect(cornerRadius: 14))
                    }
                    .buttonStyle(PressScaleButtonStyle())
                }

                Text("AI identifies every item and estimates nutrition automatically")
                    .font(.system(size: 10))
                    .foregroundStyle(KinexaTheme.tertiaryText)
                    .multilineTextAlignment(.center)

                Text(scanUsageCaption)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(KinexaTheme.tertiaryText)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(16)
        .background(KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 18))
        .elevatedCardShadow()
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(hex: "#22C55E").opacity(0.2))
        }
    }

    // MARK: - Barcode Input

    private var barcodeInputSection: some View {
        VStack(spacing: 14) {
            Button {
                showBarcode = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "barcode.viewfinder")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color(hex: "#3B82F6"))
                        .symbolEffect(.pulse, options: .repeating.speed(0.5))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Open Scanner")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(KinexaTheme.primaryText)
                        Text("Point at any product barcode")
                            .font(.caption)
                            .foregroundStyle(KinexaTheme.tertiaryText)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }
                .padding(16)
                .background(Color(hex: "#3B82F6").opacity(0.08))
                .clipShape(.rect(cornerRadius: 14))
            }
            .buttonStyle(PressScaleButtonStyle())

            HStack(spacing: 6) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 10))
                Text("Uses Open Food Facts database")
                    .font(.system(size: 10))
            }
            .foregroundStyle(KinexaTheme.tertiaryText)
        }
        .padding(16)
        .background(KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 18))
        .elevatedCardShadow()
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(hex: "#3B82F6").opacity(0.2))
        }
    }

    // MARK: - AI Text Input

    private var foodInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if AIUsageTracker.shared.hasReachedLimit {
                foodScanLimitBanner
            } else {
                TextField("e.g. grilled chicken breast with rice and steamed broccoli", text: $foodDescription, axis: .vertical)
                    .font(.subheadline)
                    .foregroundStyle(KinexaTheme.primaryText)
                    .lineLimit(3...6)
                    .padding(14)
                    .background(KinexaTheme.cardSoft)
                    .clipShape(.rect(cornerRadius: 14))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(KinexaTheme.border)
                    }

                Button {
                    Task { await estimateFromText() }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.subheadline.weight(.bold))
                        Text(hasEstimated ? "Re-estimate" : "Estimate with AI")
                            .font(.subheadline.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#6366F1"), Color(hex: "#8B5CF6")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(.rect(cornerRadius: 14))
                    .opacity(foodDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
                }
                .buttonStyle(PressScaleButtonStyle())
                .disabled(foodDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isEstimating)

                Text("AI will estimate calories and macros from your description")
                    .font(.system(size: 10))
                    .foregroundStyle(KinexaTheme.tertiaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                Text(scanUsageCaption)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(KinexaTheme.tertiaryText)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(16)
        .background(KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 18))
        .elevatedCardShadow()
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(hex: "#6366F1").opacity(0.2))
        }
    }

    // MARK: - Food Search Section

    @State private var usdaQuery: String = ""
    @State private var usdaResults: [USDAFood] = []
    @State private var usdaSearching: Bool = false
    @State private var usdaSearchTask: Task<Void, Never>?

    private var usdaSearchSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color(hex: "#0EA5E9"))
                TextField("Search foods (e.g. banana, greek yogurt)", text: $usdaQuery)
                    .font(.subheadline)
                    .foregroundStyle(KinexaTheme.primaryText)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                    .onSubmit { runUSDASearch() }
                if !usdaQuery.isEmpty {
                    Button {
                        usdaQuery = ""
                        usdaResults = []
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(KinexaTheme.tertiaryText)
                    }
                }
            }
            .padding(12)
            .background(KinexaTheme.cardSoft)
            .clipShape(.rect(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(KinexaTheme.border)
            }
            .onChange(of: usdaQuery) { _, newValue in
                usdaSearchTask?.cancel()
                guard newValue.trimmingCharacters(in: .whitespaces).count >= 2 else {
                    usdaResults = []
                    return
                }
                usdaSearchTask = Task {
                    try? await Task.sleep(for: .milliseconds(350))
                    if Task.isCancelled { return }
                    await performUSDASearch(newValue)
                }
            }

            if usdaSearching {
                HStack(spacing: 8) {
                    ProgressView().tint(Color(hex: "#0EA5E9"))
                    Text("Searching foods...")
                        .font(.caption)
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            } else if usdaResults.isEmpty && !usdaQuery.isEmpty {
                Text("No results. Try a different search term.")
                    .font(.caption)
                    .foregroundStyle(KinexaTheme.tertiaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            } else if usdaResults.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "fork.knife.circle")
                        .font(.system(size: 36))
                        .foregroundStyle(Color(hex: "#0EA5E9").opacity(0.5))
                    Text("Verified nutrition database")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(KinexaTheme.secondaryText)
                    Text("Search over 300,000 foods with accurate macros — no AI estimates.")
                        .font(.caption)
                        .foregroundStyle(KinexaTheme.tertiaryText)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
            } else {
                VStack(spacing: 8) {
                    ForEach(usdaResults) { food in
                        usdaRow(food)
                    }
                }
            }
        }
        .padding(16)
        .background(KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 18))
        .elevatedCardShadow()
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(hex: "#0EA5E9").opacity(0.2))
        }
    }

    private func usdaRow(_ food: USDAFood) -> some View {
        Button {
            let item = USDAFoodService.shared.toFoodItem(food)
            estimatedFoods.append(item)
            hasEstimated = true
            showQuickLogToast(item.name)
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(food.displayName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(KinexaTheme.primaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    HStack(spacing: 6) {
                        Text(food.displayServing)
                            .font(.caption)
                            .foregroundStyle(KinexaTheme.tertiaryText)
                        Text("·")
                            .foregroundStyle(KinexaTheme.tertiaryText)
                        Text("\(food.calories) cal")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(KinexaTheme.secondaryText)
                        Text("· P \(Int(food.protein))g")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color(hex: "#3B82F6"))
                        Text("C \(Int(food.carbs))g")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color(hex: "#F59E0B"))
                        Text("F \(Int(food.fat))g")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color(hex: "#EC4899"))
                    }
                }
                Spacer(minLength: 4)
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color(hex: "#0EA5E9"))
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(KinexaTheme.cardSoft)
            .clipShape(.rect(cornerRadius: 12))
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    private func runUSDASearch() {
        usdaSearchTask?.cancel()
        usdaSearchTask = Task { await performUSDASearch(usdaQuery) }
    }

    private func performUSDASearch(_ query: String) async {
        usdaSearching = true
        defer { usdaSearching = false }
        do {
            let results = try await USDAFoodService.shared.search(query: query)
            if !Task.isCancelled {
                usdaResults = results
            }
        } catch {
            if !Task.isCancelled {
                usdaResults = []
                errorMessage = "Could not search food database. Check your connection."
            }
        }
    }

    // MARK: - Favorites Section

    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            if nutritionVM.favorites.isEmpty {
                VStack(spacing: 14) {
                    Image(systemName: "star.circle")
                        .font(.system(size: 36))
                        .foregroundStyle(Color(hex: "#F59E0B").opacity(0.5))
                    Text("No favorites yet")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(KinexaTheme.secondaryText)
                    Text("Tap the star on any food item to save it here for quick re-logging")
                        .font(.caption)
                        .foregroundStyle(KinexaTheme.tertiaryText)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
            } else {
                ForEach(nutritionVM.favorites) { fav in
                    favoriteRow(fav)
                }
            }
        }
        .padding(16)
        .background(KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 18))
        .elevatedCardShadow()
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(hex: "#F59E0B").opacity(0.2))
        }
    }

    private func favoriteRow(_ fav: FavoriteFoodItem) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(fav.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(KinexaTheme.primaryText)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Text(fav.quantity)
                        .font(.caption)
                        .foregroundStyle(KinexaTheme.tertiaryText)
                    Text("·")
                        .foregroundStyle(KinexaTheme.tertiaryText)
                    Text("\(fav.nutrition.calories) cal")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(KinexaTheme.secondaryText)
                    if fav.usageCount > 1 {
                        Text("· \(fav.usageCount)×")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color(hex: "#F59E0B"))
                    }
                }
            }

            Spacer(minLength: 4)

            HStack(spacing: 8) {
                Button {
                    nutritionVM.quickLogFavorite(fav, mealType: selectedMealType)
                    showQuickLogToast(fav.name)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 11, weight: .heavy))
                        Text("Log")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(KinexaTheme.accent)
                    .clipShape(Capsule())
                }
                .buttonStyle(PressScaleButtonStyle())

                Button {
                    let food = fav.toFoodItem()
                    estimatedFoods.append(food)
                    hasEstimated = true
                } label: {
                    Image(systemName: "text.badge.plus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(KinexaTheme.secondaryText)
                        .frame(width: 34, height: 34)
                        .background(KinexaTheme.cardSoft)
                        .clipShape(Circle())
                }
                .buttonStyle(PressScaleButtonStyle())

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        nutritionVM.removeFavorite(id: fav.id)
                    }
                } label: {
                    Image(systemName: "star.slash.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color(hex: "#F59E0B"))
                        .frame(width: 34, height: 34)
                        .background(Color(hex: "#F59E0B").opacity(0.12))
                        .clipShape(Circle())
                }
                .buttonStyle(PressScaleButtonStyle())
            }
        }
        .padding(12)
        .background(KinexaTheme.cardSoft)
        .clipShape(.rect(cornerRadius: 14))
    }

    // MARK: - Quick Log Toast

    private func showQuickLogToast(_ name: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            quickLogToast = "\(name) logged as \(selectedMealType.rawValue)"
        }
        Task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation(.easeOut(duration: 0.3)) {
                quickLogToast = nil
            }
        }
    }

    private func quickLogToastView(_ message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(KinexaTheme.success)
            Text(message)
                .font(.caption.weight(.bold))
                .foregroundStyle(KinexaTheme.primaryText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.3), radius: 12, y: 4)
    }

    // MARK: - Estimated Foods

    private var estimatedFoodsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Estimated Nutrition")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(KinexaTheme.secondaryText)
                Spacer()
                let totalCal = estimatedFoods.map(\.nutrition.calories).reduce(0, +)
                Text("\(totalCal) cal total")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(KinexaTheme.success)
            }

            ForEach(estimatedFoods) { food in
                VStack(spacing: 10) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(food.name)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(KinexaTheme.primaryText)
                            Text(food.quantity)
                                .font(.caption)
                                .foregroundStyle(KinexaTheme.tertiaryText)
                        }
                        Spacer()
                        HStack(spacing: 6) {
                            Text("\(food.nutrition.calories) cal")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(KinexaTheme.primaryText)

                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    nutritionVM.toggleFavorite(food)
                                }
                            } label: {
                                Image(systemName: nutritionVM.isFavorite(food.name) ? "star.fill" : "star")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color(hex: "#F59E0B"))
                                    .frame(width: 30, height: 30)
                                    .background(Color(hex: "#F59E0B").opacity(nutritionVM.isFavorite(food.name) ? 0.2 : 0.08))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(PressScaleButtonStyle())

                            Button {
                                estimatedFoods.removeAll { $0.id == food.id }
                                if estimatedFoods.isEmpty { hasEstimated = false }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(KinexaTheme.tertiaryText)
                            }
                        }
                    }

                    HStack(spacing: 12) {
                        macroTag("P", value: food.nutrition.protein, color: Color(hex: "#3B82F6"))
                        macroTag("C", value: food.nutrition.carbs, color: Color(hex: "#F59E0B"))
                        macroTag("F", value: food.nutrition.fat, color: Color(hex: "#EC4899"))
                        if food.nutrition.alcohol > 0 {
                            macroTag("A", value: food.nutrition.alcohol, color: Color(hex: "#A855F7"))
                        }
                        Spacer()
                    }
                }
                .padding(14)
                .background(KinexaTheme.card)
                .clipShape(.rect(cornerRadius: 14))
                .elevatedCardShadow()
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(KinexaTheme.border)
                }
            }

            Button {
                showManualEntry = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                    Text("Add another item")
                }
                .font(.caption.weight(.bold))
                .foregroundStyle(KinexaTheme.accent)
            }
        }
    }

    // MARK: - Shared Components

    private var estimatingView: some View {
        HStack(spacing: 12) {
            ProgressView()
                .tint(Color(hex: "#6366F1"))
            Text(activeMode == .barcode ? "Looking up product..." : "Analyzing your meal...")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(KinexaTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    private func macroTag(_ label: String, value: Double, color: Color) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 9, weight: .black))
                .foregroundStyle(color)
            Text("\(String(format: "%.1f", value))g")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(KinexaTheme.secondaryText)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .clipShape(Capsule())
    }

    private func errorView(_ message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(KinexaTheme.warning)
            Text(message)
                .font(.caption)
                .foregroundStyle(KinexaTheme.secondaryText)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(KinexaTheme.warning.opacity(0.1))
        .clipShape(.rect(cornerRadius: 12))
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes (optional)")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(KinexaTheme.secondaryText)

            TextField("Add notes about this meal...", text: $notes, axis: .vertical)
                .font(.subheadline)
                .foregroundStyle(KinexaTheme.primaryText)
                .lineLimit(2...4)
                .padding(14)
                .background(KinexaTheme.cardSoft)
                .clipShape(.rect(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(KinexaTheme.border)
                }
        }
    }

    private var foodScanLimitBanner: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(KinexaTheme.warning)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Daily AI scans used up")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)
                    Text("You've used all \(AIUsageTracker.shared.dailyLimit) AI scans today. They refresh tomorrow.")
                        .font(.system(size: 11))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }

            Text("Try one of these instead")
                .font(.system(size: 10, weight: .heavy))
                .foregroundStyle(KinexaTheme.tertiaryText)
                .textCase(.uppercase)

            VStack(spacing: 8) {
                fallbackRow(icon: "pencil.line", title: "Enter Manually", tint: Color(hex: "#F59E0B")) {
                    showManualEntry = true
                }
                fallbackRow(icon: "arrow.uturn.backward", title: "Repeat Yesterday's Meals", tint: Color(hex: "#0EA5E9"), disabled: nutritionVM.yesterdaysMeals.isEmpty) {
                    guard !nutritionVM.yesterdaysMeals.isEmpty else { return }
                    nutritionVM.repeatYesterday()
                    showQuickLogToast("Yesterday's meals logged")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { dismiss() }
                }
                fallbackRow(icon: "barcode.viewfinder", title: "Scan a Barcode", tint: Color(hex: "#3B82F6")) {
                    if !navPath.contains(.barcode) { navPath.append(.barcode) }
                }
                fallbackRow(icon: "magnifyingglass", title: "Search Food Database", tint: Color(hex: "#0EA5E9")) {
                    if !navPath.contains(.database) { navPath.append(.database) }
                }
                if !nutritionVM.favorites.isEmpty {
                    fallbackRow(icon: "star.fill", title: "Pick a Favorite", tint: Color(hex: "#F59E0B")) {
                        if !navPath.contains(.favorites) { navPath.append(.favorites) }
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(KinexaTheme.warning.opacity(0.08))
        .clipShape(.rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(KinexaTheme.warning.opacity(0.2))
        }
    }

    private func fallbackRow(icon: String, title: String, tint: Color, disabled: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(tint.opacity(0.15)).frame(width: 30, height: 30)
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(tint)
                }
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(KinexaTheme.primaryText)
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(KinexaTheme.card)
            .clipShape(.rect(cornerRadius: 12))
            .elevatedCardShadow()
            .opacity(disabled ? 0.5 : 1)
        }
        .buttonStyle(PressScaleButtonStyle())
        .disabled(disabled)
    }

    private var dailyLimitReachedBanner: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(KinexaTheme.warning)
                VStack(alignment: .leading, spacing: 2) {
                    if store.isPremium {
                        Text("Daily AI limit reached")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(KinexaTheme.primaryText)
                        Text("You've used all 15 included scans for today.")
                            .font(.system(size: 10))
                            .foregroundStyle(KinexaTheme.tertiaryText)
                    } else {
                        Text("Free AI scan used")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(KinexaTheme.primaryText)
                        Text("Subscribe for 15 daily scans, or buy tokens for more.")
                            .font(.system(size: 10))
                            .foregroundStyle(KinexaTheme.tertiaryText)
                    }
                }
                Spacer(minLength: 0)
            }

            if store.isPremium {
                Button {
                    showTokenStore = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 11, weight: .bold))
                        Text("Get More Tokens")
                            .font(.caption.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#8B5CF6"), Color(hex: "#6366F1")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(.rect(cornerRadius: 10))
                }
                .buttonStyle(PressScaleButtonStyle())
            } else {
                HStack(spacing: 8) {
                    Button {
                        showUpgrade = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 11, weight: .bold))
                            Text("Subscribe")
                                .font(.caption.weight(.bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(
                            LinearGradient(
                                colors: [KinexaTheme.accent, Color(hex: "#2E7D52")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(.rect(cornerRadius: 10))
                    }
                    .buttonStyle(PressScaleButtonStyle())

                    Button {
                        showTokenStore = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 11, weight: .bold))
                            Text("Buy Tokens")
                                .font(.caption.weight(.bold))
                        }
                        .foregroundStyle(Color(hex: "#8B5CF6"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(Color(hex: "#8B5CF6").opacity(0.12))
                        .clipShape(.rect(cornerRadius: 10))
                    }
                    .buttonStyle(PressScaleButtonStyle())
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(KinexaTheme.warning.opacity(0.08))
        .clipShape(.rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(KinexaTheme.warning.opacity(0.2))
        }
    }

    // MARK: - Actions

    private func estimateFromText() async {
        guard !isEstimating else { return }
        let description = foodDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !description.isEmpty else { return }
        guard !AIUsageTracker.shared.hasReachedLimit else {
            errorMessage = "You've used all \(AIUsageTracker.shared.dailyLimit) AI scans today. They refresh tomorrow."
            return
        }

        isEstimating = true
        errorMessage = nil

        do {
            estimatedFoods = try await nutritionVM.estimateFoodFromText(description)
            hasEstimated = true
            AIUsageTracker.shared.recordUsage()
        } catch let error as GeminiError {
            errorMessage = Self.friendlyMessage(for: error, isImage: false)
        } catch {
            errorMessage = "AI request failed. Check your connection and try again."
        }

        isEstimating = false
    }

    private func analyzePhoto(_ data: Data) async {
        guard !isEstimating else { return }
        guard !AIUsageTracker.shared.hasReachedLimit else {
            errorMessage = "You've used all \(AIUsageTracker.shared.dailyLimit) AI scans today. They refresh tomorrow."
            return
        }

        isEstimating = true
        errorMessage = nil

        do {
            estimatedFoods = try await nutritionVM.estimateFoodFromImage(data)
            hasEstimated = true
            AIUsageTracker.shared.recordUsage()
        } catch let error as GeminiError {
            errorMessage = Self.friendlyMessage(for: error, isImage: true)
        } catch {
            errorMessage = "Could not analyze this image. Try a clearer, well-lit photo."
        }

        isEstimating = false
    }

    private static func friendlyMessage(for error: GeminiError, isImage: Bool) -> String {
        switch error {
        case .missingAPIKey:
            return "AI is not configured — missing Gemini API key."
        case .invalidURL, .networkError:
            return "AI request failed. Check your connection and try again."
        case .decodingError:
            return "AI response couldn't be read. Please try again."
        case .noContent, .emptyResult:
            return isImage
                ? "Could not analyze this image. Try a clearer, well-lit photo."
                : "AI didn't return any usable food data. Try rewording your description."
        }
    }

    private func loadAndAnalyzePhoto(_ item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self) else {
            errorMessage = "Could not load selected photo."
            return
        }

        let compressed = UIImage(data: data)?
            .jpegData(compressionQuality: 0.7)
        let photoData = compressed ?? data
        capturedPhotoData = photoData
        await analyzePhoto(photoData)
    }

    private func lookupBarcode(_ code: String) async {
        isEstimating = true
        errorMessage = nil

        do {
            let food = try await nutritionVM.lookupBarcode(code)
            estimatedFoods = [food]
            hasEstimated = true
        } catch is BarcodeLookupError {
            errorMessage = "Product not found in database. Try describing it manually instead."
        } catch {
            errorMessage = "Could not look up barcode. Check your connection."
        }

        isEstimating = false
    }

    private func saveMeal() {
        guard !estimatedFoods.isEmpty else { return }
        let meal = MealEntry(
            mealType: selectedMealType,
            foods: estimatedFoods,
            notes: notes,
            photoData: capturedPhotoData
        )
        nutritionVM.addMeal(meal)
        dismiss()
    }
}

extension MealInputMode: Hashable {}

nonisolated enum MealInputMode: Sendable {
    case text
    case photo
    case barcode
    case manual
    case favorites
    case database
}
