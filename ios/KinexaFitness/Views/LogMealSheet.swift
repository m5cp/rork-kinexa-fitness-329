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
    #if DEBUG
    @State private var showGeminiDiagnostic: Bool = false
    #endif
    @State private var isRepeatingYesterday: Bool = false
    @State private var servingMultipliers: [UUID: Double] = [:]

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

            heroCard(
                icon: "sparkles",
                title: "AI Describe",
                subtitle: "Type your meal",
                gradient: [Color(hex: "#6366F1"), Color(hex: "#8B5CF6")],
                badge: aiBadgeText,
                mode: .text
            )
            .frame(height: 120)

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

            if PhotoScanFailureTracker.shared.isLocked {
                photoScanLockoutBanner
            } else if AIUsageTracker.shared.hasReachedLimit {
                foodScanLimitBanner
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Scan a meal")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)
                    Text("AI identifies the items on your plate and estimates the nutrition for you.")
                        .font(.caption)
                        .foregroundStyle(KinexaTheme.secondaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                photoTipsSection

                Button {
                    guard !isEstimating else { return }
                    showCamera = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "camera.fill")
                            .font(.subheadline.weight(.bold))
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Take Photo")
                                .font(.subheadline.weight(.bold))
                            Text("Use the camera")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
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
                .disabled(isEstimating)

                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    HStack(spacing: 10) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.subheadline.weight(.bold))
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Choose from Gallery")
                                .font(.subheadline.weight(.bold))
                            Text("Pick a recent photo")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
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
                .disabled(isEstimating)

                Text(scanUsageCaption)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(KinexaTheme.tertiaryText)
                    .frame(maxWidth: .infinity)
            }

            #if DEBUG
            Button {
                showGeminiDiagnostic = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "stethoscope")
                    Text("Run Gemini Diagnostic")
                }
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.orange)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.1))
                .clipShape(.rect(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.orange.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [4]))
                }
            }
            .sheet(isPresented: $showGeminiDiagnostic) {
                GeminiDiagnosticSheet()
            }
            #endif
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

    // MARK: - Photo Tips

    private var photoTipsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color(hex: "#F59E0B"))
                Text("TIPS FOR A GOOD PHOTO")
                    .font(.system(size: 10, weight: .heavy))
                    .tracking(0.8)
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }

            VStack(alignment: .leading, spacing: 6) {
                photoTipRow(good: true, text: "Bright, even lighting")
                photoTipRow(good: true, text: "Plain background, food centered")
                photoTipRow(good: true, text: "One plate or bowl in frame")
                photoTipRow(good: true, text: "Whole plate visible, hold camera steady")
                photoTipRow(good: false, text: "Blur, glare, or harsh shadows")
                photoTipRow(good: false, text: "Multiple plates or crowded tables")
            }

            if PhotoScanFailureTracker.shared.failureCount > 0 {
                Text("\(PhotoScanFailureTracker.shared.remainingFailuresBeforeLockout) tries left before photo scan pauses for 24 hrs")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(KinexaTheme.warning)
                    .padding(.top, 2)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#F59E0B").opacity(0.06))
        .clipShape(.rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#F59E0B").opacity(0.2))
        }
    }

    private func photoTipRow(good: Bool, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: good ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(good ? KinexaTheme.success : KinexaTheme.danger)
            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(KinexaTheme.secondaryText)
            Spacer(minLength: 0)
        }
    }

    private var aiDescribeTipsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color(hex: "#F59E0B"))
                Text("TIPS FOR BETTER RESULTS")
                    .font(.system(size: 10, weight: .heavy))
                    .tracking(0.8)
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }

            VStack(alignment: .leading, spacing: 6) {
                photoTipRow(good: true, text: "List each ingredient (e.g. chicken, rice, broccoli)")
                photoTipRow(good: true, text: "Include portion size (1 cup, 6 oz, 2 slices)")
                photoTipRow(good: true, text: "Mention cooking method (grilled, fried, baked)")
                photoTipRow(good: true, text: "Note sauces, oils, or dressings")
                photoTipRow(good: false, text: "Vague terms like “a plate of food”")
                photoTipRow(good: false, text: "Just brand names without details")
            }

            if AITextFailureTracker.shared.failureCount > 0 {
                Text("\(AITextFailureTracker.shared.remainingFailuresBeforeLockout) tries left before AI Describe pauses for 24 hrs")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(KinexaTheme.warning)
                    .padding(.top, 2)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#F59E0B").opacity(0.06))
        .clipShape(.rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#F59E0B").opacity(0.2))
        }
    }

    private var aiTextLockoutBanner: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(KinexaTheme.warning)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Network issue")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)
                    Text("We couldn’t reach the AI service after several attempts. Please try again in \(AITextFailureTracker.shared.hoursRemaining) hrs. If this keeps happening, contact support.")
                        .font(.system(size: 11))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }

            Button {
                if let url = URL(string: "mailto:contact@m5cairo.com?subject=Kynexa%20Fit%20-%20AI%20Describe%20Issue") {
                    UIApplication.shared.open(url)
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 11, weight: .bold))
                    Text("Email Support")
                        .font(.caption.weight(.bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#6366F1"), Color(hex: "#8B5CF6")],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .clipShape(.rect(cornerRadius: 10))
            }
            .buttonStyle(PressScaleButtonStyle())
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(KinexaTheme.warning.opacity(0.08))
        .clipShape(.rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(KinexaTheme.warning.opacity(0.25))
        }
    }

    private var photoScanLockoutBanner: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "clock.badge.exclamationmark.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(KinexaTheme.warning)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Photo scanning paused")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)
                    Text("Too many failed scans. Photo scanning unlocks in \(PhotoScanFailureTracker.shared.hoursRemaining) hrs. In the meantime, try AI Describe or enter your meal manually.")
                        .font(.system(size: 11))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }

            Button {
                if !navPath.contains(.text) { navPath.append(.text) }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 11, weight: .bold))
                    Text("Use AI Describe")
                        .font(.caption.weight(.bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#6366F1"), Color(hex: "#8B5CF6")],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .clipShape(.rect(cornerRadius: 10))
            }
            .buttonStyle(PressScaleButtonStyle())

            Button {
                showManualEntry = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "pencil.line")
                        .font(.system(size: 11, weight: .bold))
                    Text("Enter Manually")
                        .font(.caption.weight(.bold))
                }
                .foregroundStyle(Color(hex: "#F59E0B"))
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(Color(hex: "#F59E0B").opacity(0.12))
                .clipShape(.rect(cornerRadius: 10))
            }
            .buttonStyle(PressScaleButtonStyle())
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(KinexaTheme.warning.opacity(0.08))
        .clipShape(.rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(KinexaTheme.warning.opacity(0.25))
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

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color(hex: "#3B82F6"))
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Heads up")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(KinexaTheme.primaryText)
                        Text("There are millions of products in the Open Food Facts database, but some items may not be listed. If a barcode isn’t found, try AI Describe or contact support.")
                            .font(.system(size: 11))
                            .foregroundStyle(KinexaTheme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Button {
                    if let url = URL(string: "mailto:contact@m5cairo.com?subject=Kynexa%20Fit%20-%20Barcode%20Not%20Found") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 10, weight: .bold))
                        Text("Email Support")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundStyle(Color(hex: "#3B82F6"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(hex: "#3B82F6").opacity(0.1))
                    .clipShape(Capsule())
                }
                .buttonStyle(PressScaleButtonStyle())
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: "#3B82F6").opacity(0.05))
            .clipShape(.rect(cornerRadius: 12))
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
            if AITextFailureTracker.shared.isLocked {
                aiTextLockoutBanner
            } else if AIUsageTracker.shared.hasReachedLimit {
                foodScanLimitBanner
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Describe your meal")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)
                    Text("Describe your meal in plain language and I\u{2019}ll estimate the calories and macros.")
                        .font(.caption)
                        .foregroundStyle(KinexaTheme.secondaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                aiDescribeTipsSection

                TextField("e.g. grilled chicken breast with rice and steamed broccoli", text: $foodDescription, axis: .vertical)
                    .font(.subheadline)
                    .foregroundStyle(KinexaTheme.primaryText)
                    .lineLimit(4...8)
                    .padding(16)
                    .frame(minHeight: 120, alignment: .topLeading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(KinexaTheme.cardSoft)
                    .clipShape(.rect(cornerRadius: 14))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(hex: "#6366F1").opacity(0.35), lineWidth: 1.5)
                    }
                    .disabled(isEstimating)

                let isEmpty = foodDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                Button {
                    guard !isEstimating, !isEmpty else { return }
                    Task { await estimateFromText() }
                } label: {
                    HStack(spacing: 8) {
                        if isEstimating {
                            ProgressView().tint(.white)
                            Text("Estimating\u{2026}")
                                .font(.subheadline.weight(.bold))
                        } else {
                            Image(systemName: "sparkles")
                                .font(.subheadline.weight(.bold))
                            Text(hasEstimated ? "Re-estimate with AI" : "Estimate with AI")
                                .font(.subheadline.weight(.bold))
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#6366F1"), Color(hex: "#8B5CF6")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(.rect(cornerRadius: 14))
                    .opacity((isEmpty || isEstimating) ? 0.5 : 1)
                }
                .buttonStyle(PressScaleButtonStyle())
                .disabled(isEmpty || isEstimating)

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
                TextField("Search meals (e.g. banana, greek yogurt)", text: $usdaQuery)
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
                let trimmed = newValue.trimmingCharacters(in: .whitespaces)
                guard trimmed.count >= 3 else {
                    usdaResults = []
                    usdaSearching = false
                    return
                }
                usdaSearchTask = Task {
                    try? await Task.sleep(for: .milliseconds(600))
                    if Task.isCancelled { return }
                    await performUSDASearch(trimmed)
                }
            }

            if usdaSearching {
                HStack(spacing: 8) {
                    ProgressView().tint(Color(hex: "#0EA5E9"))
                    Text("Searching meals\u{2026}")
                        .font(.caption)
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            } else if !usdaQuery.isEmpty && usdaQuery.trimmingCharacters(in: .whitespaces).count < 3 {
                VStack(spacing: 6) {
                    Image(systemName: "character.cursor.ibeam")
                        .font(.system(size: 28))
                        .foregroundStyle(Color(hex: "#0EA5E9").opacity(0.5))
                    Text("Keep typing\u{2026}")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(KinexaTheme.secondaryText)
                    Text("Type at least 3 letters to search meals.")
                        .font(.caption)
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
            } else if usdaResults.isEmpty && !usdaQuery.isEmpty {
                Text("No matches found")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(KinexaTheme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            } else if usdaResults.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "fork.knife.circle")
                        .font(.system(size: 36))
                        .foregroundStyle(Color(hex: "#0EA5E9").opacity(0.5))
                    Text("Start typing to search meals")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(KinexaTheme.secondaryText)
                    Text("Search thousands of foods with accurate macros.")
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
        let trimmed = usdaQuery.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 3 else { return }
        usdaSearchTask?.cancel()
        usdaSearchTask = Task { await performUSDASearch(trimmed) }
    }

    private func performUSDASearch(_ query: String) async {
        usdaSearching = true
        do {
            let results = try await USDAFoodService.shared.search(query: query, limit: 8)
            if !Task.isCancelled {
                usdaResults = results
                usdaSearching = false
            }
        } catch {
            if !Task.isCancelled {
                usdaResults = []
                usdaSearching = false
                errorMessage = "Could not search meals. Check your connection."
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
                Text("\(totalScaledCalories) cal total")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(KinexaTheme.success)
            }

            ForEach(estimatedFoods) { food in
                estimatedFoodCard(food)
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

            Button {
                saveMeal()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.subheadline.weight(.bold))
                    Text("Log This Meal")
                        .font(.subheadline.weight(.bold))
                    Spacer()
                    Text("\(totalScaledCalories) cal")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(.white.opacity(0.9))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    LinearGradient(
                        colors: [KinexaTheme.accent, Color(hex: "#2E7D52")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(.rect(cornerRadius: 14))
                .shadow(color: KinexaTheme.accent.opacity(0.3), radius: 10, y: 4)
            }
            .buttonStyle(PressScaleButtonStyle())
            .padding(.top, 4)
        }
    }

    private var totalScaledCalories: Int {
        estimatedFoods.reduce(0) { $0 + scaledNutrition($1).calories }
    }

    private func servings(for food: FoodItem) -> Double {
        servingMultipliers[food.id] ?? 1.0
    }

    private func scaledNutrition(_ food: FoodItem) -> NutritionInfo {
        let m = servings(for: food)
        return NutritionInfo(
            calories: Int((Double(food.nutrition.calories) * m).rounded()),
            protein: food.nutrition.protein * m,
            carbs: food.nutrition.carbs * m,
            fat: food.nutrition.fat * m,
            fiber: food.nutrition.fiber * m,
            sugar: food.nutrition.sugar * m,
            alcohol: food.nutrition.alcohol * m
        )
    }

    private func adjustServings(_ food: FoodItem, by delta: Double) {
        let current = servings(for: food)
        let next = max(0.25, min(10.0, (current + delta)))
        let rounded = (next * 4).rounded() / 4
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            servingMultipliers[food.id] = rounded
        }
    }

    private func servingsLabel(_ value: Double) -> String {
        if abs(value - value.rounded()) < 0.01 {
            return "\(Int(value))"
        }
        return String(format: "%.2g", value)
    }

    @ViewBuilder
    private func estimatedFoodCard(_ food: FoodItem) -> some View {
        let scaled = scaledNutrition(food)
        let servingsValue = servings(for: food)

        VStack(spacing: 12) {
            HStack(alignment: .top) {
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
                    Text("\(scaled.calories) cal")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)
                        .contentTransition(.numericText())

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
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            estimatedFoods.removeAll { $0.id == food.id }
                            servingMultipliers.removeValue(forKey: food.id)
                            if estimatedFoods.isEmpty { hasEstimated = false }
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(KinexaTheme.tertiaryText)
                    }
                }
            }

            HStack(spacing: 10) {
                Button {
                    adjustServings(food, by: -0.5)
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundStyle(servingsValue <= 0.25 ? KinexaTheme.tertiaryText : KinexaTheme.accent)
                        .frame(width: 34, height: 34)
                        .background(KinexaTheme.cardSoft)
                        .clipShape(Circle())
                }
                .buttonStyle(PressScaleButtonStyle())
                .disabled(servingsValue <= 0.25)

                VStack(spacing: 1) {
                    Text("\(servingsLabel(servingsValue))×")
                        .font(.subheadline.weight(.heavy))
                        .foregroundStyle(KinexaTheme.primaryText)
                        .contentTransition(.numericText())
                    Text(servingsValue == 1.0 ? "serving" : "servings")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }
                .frame(minWidth: 70)

                Button {
                    adjustServings(food, by: 0.5)
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundStyle(KinexaTheme.accent)
                        .frame(width: 34, height: 34)
                        .background(KinexaTheme.accent.opacity(0.12))
                        .clipShape(Circle())
                }
                .buttonStyle(PressScaleButtonStyle())
                .disabled(servingsValue >= 10.0)

                Spacer(minLength: 0)

                HStack(spacing: 6) {
                    macroTag("P", value: scaled.protein, color: Color(hex: "#3B82F6"))
                    macroTag("C", value: scaled.carbs, color: Color(hex: "#F59E0B"))
                    macroTag("F", value: scaled.fat, color: Color(hex: "#EC4899"))
                    if scaled.alcohol > 0 {
                        macroTag("A", value: scaled.alcohol, color: Color(hex: "#A855F7"))
                    }
                }
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
                    Text(AIUsageTracker.shared.limitReachedTitle)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)
                    Text(AIUsageTracker.shared.limitReachedMessage)
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
            errorMessage = AIUsageTracker.shared.limitReachedMessage
            return
        }

        isEstimating = true
        errorMessage = nil

        do {
            let foods = try await nutritionVM.estimateFoodFromText(description)
            if foods.isEmpty {
                AITextFailureTracker.shared.recordFailure()
                errorMessage = Self.aiTextFailureMessage()
                isEstimating = false
                return
            }
            estimatedFoods = foods
            hasEstimated = true
            AIUsageTracker.shared.recordUsage()
            AITextFailureTracker.shared.recordSuccess()
        } catch let error as GeminiError {
            AITextFailureTracker.shared.recordFailure()
            errorMessage = Self.friendlyMessage(for: error, isImage: false) + Self.aiTextFailureSuffix()
        } catch {
            AITextFailureTracker.shared.recordFailure()
            errorMessage = "AI request failed. Check your connection and try again." + Self.aiTextFailureSuffix()
        }

        isEstimating = false
    }

    private static func aiTextFailureMessage() -> String {
        let base = "AI couldn't estimate your meal. Try adding more detail — ingredients, cooking method, and portion size (e.g. '2 scrambled eggs, 1 slice wheat toast with butter')."
        return base + aiTextFailureSuffix()
    }

    private static func aiTextFailureSuffix() -> String {
        if AITextFailureTracker.shared.isLocked {
            return " AI Describe is paused for 24 hours due to repeated issues."
        }
        let remaining = AITextFailureTracker.shared.remainingFailuresBeforeLockout
        if remaining <= 3 {
            return " (\(remaining) tries left before AI Describe pauses for 24 hrs)"
        }
        return ""
    }

    private func analyzePhoto(_ data: Data) async {
        guard !isEstimating else { return }
        if PhotoScanFailureTracker.shared.isLocked {
            errorMessage = "Photo scanning is paused for \(PhotoScanFailureTracker.shared.hoursRemaining) hrs after too many failed attempts. Try AI Describe instead, or try photo again tomorrow."
            return
        }
        guard !AIUsageTracker.shared.hasReachedLimit else {
            errorMessage = AIUsageTracker.shared.limitReachedMessage
            return
        }

        isEstimating = true
        errorMessage = nil

        do {
            let foods = try await nutritionVM.estimateFoodFromImage(data)
            if foods.isEmpty {
                PhotoScanFailureTracker.shared.recordFailure()
                errorMessage = Self.photoFailureMessage(reason: .noFoodDetected)
                isEstimating = false
                return
            }
            estimatedFoods = foods
            hasEstimated = true
            AIUsageTracker.shared.recordUsage()
            PhotoScanFailureTracker.shared.recordSuccess()
        } catch let error as GeminiError {
            PhotoScanFailureTracker.shared.recordFailure()
            errorMessage = Self.friendlyMessage(for: error, isImage: true)
        } catch {
            PhotoScanFailureTracker.shared.recordFailure()
            errorMessage = Self.photoFailureMessage(reason: .unknown)
        }

        isEstimating = false
    }

    private enum PhotoFailureReason {
        case noFoodDetected
        case blurry
        case unknown
    }

    private static func photoFailureMessage(reason: PhotoFailureReason) -> String {
        let remaining = PhotoScanFailureTracker.shared.remainingFailuresBeforeLockout
        let base: String
        switch reason {
        case .noFoodDetected:
            base = "Couldn't identify any food. Try a plainer background, better lighting, or a closer shot of a single plate."
        case .blurry:
            base = "Image looks blurry or dark. Retake in brighter light with the phone held steady."
        case .unknown:
            base = "Couldn't read this photo. Try brighter light, a plain background, and one plate in frame."
        }
        if PhotoScanFailureTracker.shared.isLocked {
            return "Photo scanning is paused for 24 hours after too many failed attempts. Try AI Describe instead."
        }
        if remaining <= 3 {
            return base + " (\(remaining) tries left before photo scan pauses for 24 hrs)"
        }
        return base
    }

    private static func friendlyMessage(for error: GeminiError, isImage: Bool) -> String {
        switch error {
        case .missingAPIKey:
            return "AI is not configured — missing Gemini API key."
        case .invalidURL:
            return "AI request failed. Please try again."
        case .networkError(let msg):
            return "AI request failed: \(msg)"
        case .httpError(let status, let msg):
            if status == 401 || status == 403 {
                return "AI key is invalid or unauthorized. Please check your Gemini API key."
            }
            if status == 429 {
                return "AI quota reached. Please try again later."
            }
            return "AI error (\(status)): \(msg)"
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
        let scaledFoods: [FoodItem] = estimatedFoods.map { food in
            let m = servings(for: food)
            guard m != 1.0 else { return food }
            var updated = food
            updated.nutrition = scaledNutrition(food)
            let label = servingsLabel(m)
            updated.quantity = "\(label)× \(food.quantity)"
            return updated
        }
        let meal = MealEntry(
            mealType: selectedMealType,
            foods: scaledFoods,
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
