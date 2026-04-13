import SwiftUI

struct GenerateRecipeSheet: View {
    var recipeVM: RecipeViewModel
    var nutritionVM: NutritionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: RecipeCategory = .all
    @State private var customRequest: String = ""
    @State private var isGenerating: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    macroSummary
                    categorySelection
                    customRequestField
                    generateButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .background(KinexaTheme.background.ignoresSafeArea())
            .navigationTitle("Generate Recipes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(KinexaTheme.secondaryText)
                }
            }
        }
        .presentationDetents([.large])
    }

    private var macroSummary: some View {
        VStack(spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "chart.pie.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(KinexaTheme.accent)
                Text("Today's Remaining Macros")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)
                Spacer()
            }

            let remaining = remainingMacros
            HStack(spacing: 12) {
                macroStat(label: "Calories", value: "\(remaining.cal)", color: Color(hex: "#22C55E"))
                macroStat(label: "Protein", value: "\(String(format: "%.0f", remaining.protein))g", color: Color(hex: "#3B82F6"))
                macroStat(label: "Carbs", value: "\(String(format: "%.0f", remaining.carbs))g", color: Color(hex: "#F59E0B"))
                macroStat(label: "Fat", value: "\(String(format: "%.0f", remaining.fat))g", color: Color(hex: "#EC4899"))
            }

            if nutritionVM.isProfileConfigured {
                HStack(spacing: 6) {
                    Image(systemName: nutritionVM.profile.goalType.icon)
                        .font(.system(size: 10))
                    Text("Goal: \(nutritionVM.profile.goalType.rawValue)")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundStyle(KinexaTheme.tertiaryText)
            }
        }
        .padding(16)
        .background(KinexaTheme.card)
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(KinexaTheme.border)
        }
        .clipShape(.rect(cornerRadius: 18))
    }

    private func macroStat(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(KinexaTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private var categorySelection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recipe Type")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(KinexaTheme.primaryText)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
                ForEach(RecipeCategory.allCases, id: \.rawValue) { category in
                    let isSelected = selectedCategory == category
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedCategory = category
                        }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: category.icon)
                                .font(.system(size: 10, weight: .bold))
                            Text(category.rawValue)
                                .font(.system(size: 11, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(isSelected ? KinexaTheme.accent : KinexaTheme.cardSoft)
                        .foregroundStyle(isSelected ? .white : KinexaTheme.secondaryText)
                        .clipShape(.rect(cornerRadius: 10))
                        .overlay {
                            if !isSelected {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(KinexaTheme.border)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var customRequestField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Special Requests (optional)")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(KinexaTheme.primaryText)

            TextField("e.g. No dairy, Mediterranean style, under 30 min...", text: $customRequest, axis: .vertical)
                .font(.subheadline)
                .foregroundStyle(KinexaTheme.primaryText)
                .lineLimit(3)
                .padding(14)
                .background(KinexaTheme.cardSoft)
                .clipShape(.rect(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(KinexaTheme.border)
                }
        }
    }

    private var generateButton: some View {
        Button {
            isGenerating = true
            Task {
                AIUsageTracker.shared.recordUsage()
                await recipeVM.generateRecipes(
                    profile: nutritionVM.profile,
                    currentNutrition: nutritionVM.todayNutrition,
                    goal: nutritionVM.dailyGoal,
                    category: selectedCategory,
                    customRequest: customRequest.isEmpty ? nil : customRequest
                )
                isGenerating = false
                dismiss()
            }
        } label: {
            HStack(spacing: 10) {
                if isGenerating {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "wand.and.stars")
                        .font(.subheadline.weight(.bold))
                }
                Text(isGenerating ? "Generating..." : "Generate 3 Recipes")
                    .font(.headline.weight(.bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                LinearGradient(
                    colors: [Color(hex: "#F59E0B"), Color(hex: "#D97706")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(.rect(cornerRadius: 14))
            .shadow(color: Color(hex: "#F59E0B").opacity(0.4), radius: 12, y: 6)
        }
        .buttonStyle(PressScaleButtonStyle())
        .disabled(isGenerating)
        .opacity(isGenerating ? 0.7 : 1)
    }

    private var remainingMacros: (cal: Int, protein: Double, carbs: Double, fat: Double) {
        let n = nutritionVM.todayNutrition
        let g = nutritionVM.dailyGoal
        return (
            cal: max(0, g.calories - n.calories),
            protein: max(0, g.protein - n.protein),
            carbs: max(0, g.carbs - n.carbs),
            fat: max(0, g.fat - n.fat)
        )
    }
}
