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
    @State private var inputMode: MealInputMode = .manual
    @State private var showManualEntry: Bool = false
    @State private var showUpgrade: Bool = false
    @State private var showTokenStore: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    mealTypeSelector
                    inputModeSelector
                    switch inputMode {
                    case .text:
                        foodInputSection
                    case .photo:
                        photoInputSection
                    case .barcode:
                        barcodeInputSection
                    case .manual:
                        manualInputSection
                    case .favorites:
                        favoritesSection
                    }
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
    }

    private var aiUsageBadge: some View {
        let tracker = AIUsageTracker.shared
        let remaining = tracker.remainingToday
        let bonus = tracker.bonusTokens
        let limit = tracker.dailyLimit
        return HStack(spacing: 4) {
            Image(systemName: "sparkle")
                .font(.system(size: 8, weight: .bold))
            if store.isPremium {
                Text("\(remaining)/\(limit) today")
                    .font(.system(size: 9, weight: .bold))
            } else {
                Text(tracker.hasFreeTrialRemaining ? "1 free scan" : "No free scans")
                    .font(.system(size: 9, weight: .bold))
            }
            if bonus > 0 {
                Text("+\(bonus)")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color(hex: "#8B5CF6"))
            }
        }
        .foregroundStyle(remaining <= 0 && bonus == 0 ? KinexaTheme.warning : KinexaTheme.tertiaryText)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(remaining <= 0 && bonus == 0 ? KinexaTheme.warning.opacity(0.1) : KinexaTheme.cardSoft)
        .clipShape(Capsule())
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

    private var inputModeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                inputModeButton(mode: .manual, icon: "pencil.line", label: "Manual")
                inputModeButton(mode: .barcode, icon: "barcode.viewfinder", label: "Barcode")
                inputModeButton(mode: .favorites, icon: "star.fill", label: "Favorites")
                inputModeButton(mode: .text, icon: "sparkles", label: "AI Text")
                inputModeButton(mode: .photo, icon: "camera.fill", label: "Photo")
            }
        }
        .contentMargins(.horizontal, 0)
    }

    private func inputModeButton(mode: MealInputMode, icon: String, label: String, isPremiumFeature: Bool = false) -> some View {
        let isSelected = inputMode == mode
        let isLocked = isPremiumFeature && !store.isPremium
        return Button {
            if isLocked {
                showUpgrade = true
            } else {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    inputMode = mode
                    errorMessage = nil
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: isLocked ? "lock.fill" : icon)
                    .font(.system(size: 12, weight: .bold))
                Text(label)
                    .font(.system(size: 11, weight: .bold))
                if isPremiumFeature && !isLocked {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 8))
                        .foregroundStyle(Color(hex: "#F59E0B"))
                }
            }
            .foregroundStyle(isLocked ? KinexaTheme.tertiaryText : (isSelected ? .white : KinexaTheme.secondaryText))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isLocked ? KinexaTheme.cardSoft : (isSelected ? KinexaTheme.accent : KinexaTheme.card))
            .clipShape(.rect(cornerRadius: 12))
            .overlay {
                if !isSelected || isLocked {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isLocked ? KinexaTheme.border.opacity(0.5) : KinexaTheme.border)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var foodInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color(hex: "#6366F1"))
                Text("Describe your meal")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(KinexaTheme.secondaryText)
                Spacer()
                aiUsageBadge
            }

            VStack(spacing: 12) {
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
                    .opacity(foodDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || AIUsageTracker.shared.hasReachedLimit ? 0.5 : 1)
                }
                .buttonStyle(PressScaleButtonStyle())
                .disabled(foodDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isEstimating || AIUsageTracker.shared.hasReachedLimit)

                if AIUsageTracker.shared.hasReachedLimit {
                    dailyLimitReachedBanner
                } else {
                    Text("Gemini AI will estimate calories and macros from your description")
                        .font(.system(size: 10))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }

    private var photoInputSection: some View {
        VStack(spacing: 16) {
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

            HStack(alignment: .center) {
                Spacer()
                aiUsageBadge
            }

            if AIUsageTracker.shared.hasReachedLimit {
                dailyLimitReachedBanner
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

                VStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.title3)
                        .foregroundStyle(Color(hex: "#6366F1"))
                    Text("Snap a photo of your food and AI will identify every item and estimate nutrition automatically")
                        .font(.caption)
                        .foregroundStyle(KinexaTheme.tertiaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }
                .padding(.top, 4)
            }
        }
    }

    private var barcodeInputSection: some View {
        VStack(spacing: 16) {
            Button {
                showBarcode = true
            } label: {
                VStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(KinexaTheme.accent.opacity(0.12))
                            .frame(width: 64, height: 64)
                        Image(systemName: "barcode.viewfinder")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(KinexaTheme.accent)
                            .symbolEffect(.pulse, options: .repeating.speed(0.5))
                    }

                    Text("Scan Barcode")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)

                    Text("Point your camera at a product barcode to instantly look up nutrition facts")
                        .font(.caption)
                        .foregroundStyle(KinexaTheme.tertiaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
                .background(KinexaTheme.card)
                .clipShape(.rect(cornerRadius: 18))
                .overlay {
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(KinexaTheme.accent.opacity(0.2), lineWidth: 1.5)
                }
            }
            .buttonStyle(PressScaleButtonStyle())

            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .font(.caption)
                    .foregroundStyle(KinexaTheme.tertiaryText)
                Text("Uses Open Food Facts database for product lookup")
                    .font(.system(size: 10))
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }
        }
    }

    private var manualInputSection: some View {
        VStack(spacing: 16) {
            if !estimatedFoods.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Added Items")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(KinexaTheme.secondaryText)
                    ForEach(estimatedFoods) { food in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(food.name)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(KinexaTheme.primaryText)
                                Text("\(food.quantity) · \(food.nutrition.calories) cal")
                                    .font(.caption)
                                    .foregroundStyle(KinexaTheme.tertiaryText)
                            }
                            Spacer()
                            Button {
                                estimatedFoods.removeAll { $0.id == food.id }
                                if estimatedFoods.isEmpty { hasEstimated = false }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.subheadline)
                                    .foregroundStyle(KinexaTheme.tertiaryText)
                            }
                        }
                        .padding(12)
                        .background(KinexaTheme.cardSoft)
                        .clipShape(.rect(cornerRadius: 12))
                    }
                }
            }

            Button {
                showManualEntry = true
            } label: {
                VStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(hex: "#F59E0B").opacity(0.12))
                            .frame(width: 64, height: 64)
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(Color(hex: "#F59E0B"))
                    }

                    Text("Add Food Manually")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)

                    Text("Enter food name, serving size, and nutrition info by hand")
                        .font(.caption)
                        .foregroundStyle(KinexaTheme.tertiaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
                .background(KinexaTheme.card)
                .clipShape(.rect(cornerRadius: 18))
                .overlay {
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color(hex: "#F59E0B").opacity(0.2), lineWidth: 1.5)
                }
            }
            .buttonStyle(PressScaleButtonStyle())
        }
    }

    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if nutritionVM.favorites.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "star.circle")
                        .font(.system(size: 40))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                    Text("No favorites yet")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(KinexaTheme.secondaryText)
                    Text("Foods you log will automatically appear here for quick re-logging")
                        .font(.caption)
                        .foregroundStyle(KinexaTheme.tertiaryText)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                if !nutritionVM.recentFoods.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 6) {
                            Image(systemName: "clock.fill")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color(hex: "#3B82F6"))
                            Text("Recent")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(KinexaTheme.secondaryText)
                        }

                        ForEach(nutritionVM.recentFoods) { fav in
                            favoriteRow(fav)
                        }
                    }
                }

                let topFavs = nutritionVM.topFavorites.filter { fav in
                    fav.usageCount > 1
                }
                if !topFavs.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 6) {
                            Image(systemName: "star.fill")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color(hex: "#F59E0B"))
                            Text("Most Used")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(KinexaTheme.secondaryText)
                        }

                        ForEach(topFavs) { fav in
                            favoriteRow(fav)
                        }
                    }
                }
            }
        }
    }

    private func favoriteRow(_ fav: FavoriteFoodItem) -> some View {
        Button {
            let food = fav.toFoodItem()
            estimatedFoods.append(food)
            hasEstimated = true
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(fav.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(KinexaTheme.primaryText)
                    HStack(spacing: 6) {
                        Text(fav.quantity)
                            .font(.caption)
                            .foregroundStyle(KinexaTheme.tertiaryText)
                        Text("·")
                            .foregroundStyle(KinexaTheme.tertiaryText)
                        Text("\(fav.nutrition.calories) cal")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(KinexaTheme.secondaryText)
                    }
                }
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(KinexaTheme.accent)
            }
            .padding(14)
            .background(KinexaTheme.card)
            .clipShape(.rect(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(KinexaTheme.border)
            }
        }
        .buttonStyle(.plain)
    }

    private var estimatingView: some View {
        HStack(spacing: 12) {
            ProgressView()
                .tint(Color(hex: "#6366F1"))
            Text(inputMode == .barcode ? "Looking up product..." : "Analyzing your meal...")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(KinexaTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    private var estimatedFoodsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: sourceIcon)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(sourceColor)
                    Text("Estimated Nutrition")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(KinexaTheme.secondaryText)
                }
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
                        HStack(spacing: 8) {
                            Text("\(food.nutrition.calories) cal")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(KinexaTheme.primaryText)
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
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(KinexaTheme.border)
                }
            }

            if inputMode != .manual {
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

    private var sourceIcon: String {
        switch inputMode {
        case .text: return "sparkles"
        case .photo: return "camera.fill"
        case .barcode: return "barcode"
        case .manual: return "pencil.line"
        case .favorites: return "star.fill"
        }
    }

    private var sourceColor: Color {
        switch inputMode {
        case .text: return Color(hex: "#6366F1")
        case .photo: return Color(hex: "#22C55E")
        case .barcode: return KinexaTheme.accent
        case .manual: return Color(hex: "#F59E0B")
        case .favorites: return Color(hex: "#F59E0B")
        }
    }

    private func estimateFromText() async {
        let description = foodDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !description.isEmpty else { return }
        guard !AIUsageTracker.shared.hasReachedLimit else {
            errorMessage = store.isPremium ? "Daily limit reached. Buy tokens for more scans." : "Subscribe or buy tokens to continue scanning."
            return
        }

        isEstimating = true
        errorMessage = nil

        do {
            estimatedFoods = try await nutritionVM.estimateFoodFromText(description)
            hasEstimated = true
            AIUsageTracker.shared.recordUsage()
        } catch {
            errorMessage = "Could not estimate nutrition. Please try again or check your connection."
        }

        isEstimating = false
    }

    private func analyzePhoto(_ data: Data) async {
        guard !AIUsageTracker.shared.hasReachedLimit else {
            errorMessage = store.isPremium ? "Daily limit reached. Buy tokens for more scans." : "Subscribe or buy tokens to continue scanning."
            return
        }

        isEstimating = true
        errorMessage = nil

        do {
            estimatedFoods = try await nutritionVM.estimateFoodFromImage(data)
            hasEstimated = true
            AIUsageTracker.shared.recordUsage()
        } catch {
            errorMessage = "Could not analyze photo. Please try again or use text description."
        }

        isEstimating = false
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

nonisolated enum MealInputMode: Sendable {
    case text
    case photo
    case barcode
    case manual
    case favorites
}
