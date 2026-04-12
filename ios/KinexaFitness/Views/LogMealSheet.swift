import SwiftUI
import PhotosUI

struct LogMealSheet: View {
    @Environment(\.dismiss) private var dismiss
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
    @State private var inputMode: MealInputMode = .text

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
        .onChange(of: selectedPhoto) { _, newValue in
            guard let newValue else { return }
            Task { await loadAndAnalyzePhoto(newValue) }
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
        HStack(spacing: 8) {
            inputModeButton(mode: .text, icon: "text.cursor", label: "Type It")
            inputModeButton(mode: .photo, icon: "camera.fill", label: "Photo")
            inputModeButton(mode: .barcode, icon: "barcode.viewfinder", label: "Barcode")
        }
    }

    private func inputModeButton(mode: MealInputMode, icon: String, label: String) -> some View {
        let isSelected = inputMode == mode
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                inputMode = mode
                errorMessage = nil
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .bold))
                Text(label)
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundStyle(isSelected ? .white : KinexaTheme.secondaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? KinexaTheme.accent : KinexaTheme.card)
            .clipShape(.rect(cornerRadius: 12))
            .overlay {
                if !isSelected {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(KinexaTheme.border)
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
                    .opacity(foodDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
                }
                .buttonStyle(PressScaleButtonStyle())
                .disabled(foodDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isEstimating)

                Text("Gemini AI will estimate calories and macros from your description")
                    .font(.system(size: 10))
                    .foregroundStyle(KinexaTheme.tertiaryText)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var photoInputSection: some View {
        VStack(spacing: 16) {
            if let data = capturedPhotoData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
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
                        Text("\(food.nutrition.calories) cal")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(KinexaTheme.primaryText)
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
        }
    }

    private var sourceColor: Color {
        switch inputMode {
        case .text: return Color(hex: "#6366F1")
        case .photo: return Color(hex: "#22C55E")
        case .barcode: return KinexaTheme.accent
        }
    }

    private func estimateFromText() async {
        let description = foodDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !description.isEmpty else { return }

        isEstimating = true
        errorMessage = nil

        do {
            estimatedFoods = try await nutritionVM.estimateFoodFromText(description)
            hasEstimated = true
        } catch {
            errorMessage = "Could not estimate nutrition. Please try again or check your connection."
        }

        isEstimating = false
    }

    private func analyzePhoto(_ data: Data) async {
        isEstimating = true
        errorMessage = nil

        do {
            estimatedFoods = try await nutritionVM.estimateFoodFromImage(data)
            hasEstimated = true
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
}
