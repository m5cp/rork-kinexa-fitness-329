import SwiftUI

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

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    mealTypeSelector
                    foodInputSection
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
                    Task { await estimateNutrition() }
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

    private var estimatingView: some View {
        HStack(spacing: 12) {
            ProgressView()
                .tint(Color(hex: "#6366F1"))
            Text("Analyzing your meal...")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(KinexaTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

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
                        Text("\(food.nutrition.calories) cal")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(KinexaTheme.primaryText)
                    }

                    HStack(spacing: 16) {
                        macroTag("P", value: food.nutrition.protein, color: Color(hex: "#3B82F6"))
                        macroTag("C", value: food.nutrition.carbs, color: Color(hex: "#F59E0B"))
                        macroTag("F", value: food.nutrition.fat, color: Color(hex: "#EC4899"))
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

    private func estimateNutrition() async {
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

    private func saveMeal() {
        guard !estimatedFoods.isEmpty else { return }
        let meal = MealEntry(
            mealType: selectedMealType,
            foods: estimatedFoods,
            notes: notes
        )
        nutritionVM.addMeal(meal)
        dismiss()
    }
}
