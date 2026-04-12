import SwiftUI

struct MealDetailSheet: View {
    let meal: MealEntry
    let nutritionVM: NutritionViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var insight: GeminiMealInsight?
    @State private var isAnalyzing: Bool = false
    @State private var showDeleteConfirm: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    mealHeader
                    if meal.photoData != nil {
                        mealPhotoCard
                    }
                    nutritionSummaryCard
                    foodItemsList
                    if nutritionVM.isGeminiConfigured { aiAnalysisSection }
                    if !meal.notes.isEmpty { notesCard }
                    deleteButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .background(KinexaTheme.background.ignoresSafeArea())
            .navigationTitle(meal.mealType.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(KinexaTheme.accent)
                }
            }
            .alert("Delete Meal", isPresented: $showDeleteConfirm) {
                Button("Delete", role: .destructive) {
                    nutritionVM.deleteMeal(id: meal.id)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently remove this meal entry.")
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onAppear {
            if let cached = nutritionVM.mealInsights[meal.id] {
                insight = cached
            }
        }
    }

    private var mealHeader: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: meal.mealType.color).opacity(0.15))
                    .frame(width: 56, height: 56)
                Image(systemName: meal.mealType.icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color(hex: meal.mealType.color))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(meal.mealType.rawValue)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)
                Text(meal.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }

            Spacer()

            VStack(spacing: 2) {
                Text("\(meal.totalNutrition.calories)")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)
                Text("calories")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }
        }
    }

    private var mealPhotoCard: some View {
        Group {
            if let data = meal.photoData, let uiImage = UIImage(data: data) {
                Color(.secondarySystemBackground)
                    .frame(height: 200)
                    .overlay {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .allowsHitTesting(false)
                    }
                    .clipShape(.rect(cornerRadius: 16))
                    .overlay(alignment: .bottomLeading) {
                        HStack(spacing: 6) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 10, weight: .bold))
                            Text("AI Scanned")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .padding(10)
                    }
            }
        }
    }

    private var nutritionSummaryCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                macroColumn("Protein", value: meal.totalNutrition.protein, color: Color(hex: "#3B82F6"))
                divider
                macroColumn("Carbs", value: meal.totalNutrition.carbs, color: Color(hex: "#F59E0B"))
                divider
                macroColumn("Fat", value: meal.totalNutrition.fat, color: Color(hex: "#EC4899"))
                divider
                macroColumn("Fiber", value: meal.totalNutrition.fiber, color: Color(hex: "#22C55E"))
            }
            .padding(.vertical, 18)

            if meal.totalNutrition.alcohol > 0 {
                Rectangle()
                    .fill(KinexaTheme.border)
                    .frame(height: 0.5)
                HStack(spacing: 8) {
                    Image(systemName: "wineglass.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color(hex: "#A855F7"))
                    Text("Alcohol")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(KinexaTheme.secondaryText)
                    Spacer()
                    Text("\(String(format: "%.1f", meal.totalNutrition.alcohol))g")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color(hex: "#A855F7"))
                    Text("(\(Int(meal.totalNutrition.alcohol * 7)) cal)")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
        }
        .background(KinexaTheme.card)
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(KinexaTheme.border)
        }
        .clipShape(.rect(cornerRadius: 18))
    }

    private var divider: some View {
        Rectangle()
            .fill(KinexaTheme.border)
            .frame(width: 0.5, height: 40)
    }

    private func macroColumn(_ label: String, value: Double, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(String(format: "%.1f", value))
                .font(.subheadline.weight(.bold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(KinexaTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private var foodItemsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Food Items")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(KinexaTheme.secondaryText)

            ForEach(meal.foods) { food in
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(food.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(KinexaTheme.primaryText)
                        Text(food.quantity)
                            .font(.caption)
                            .foregroundStyle(KinexaTheme.tertiaryText)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 3) {
                        Text("\(food.nutrition.calories) cal")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(KinexaTheme.primaryText)
                        HStack(spacing: 4) {
                            Text("P:\(String(format: "%.0f", food.nutrition.protein)) C:\(String(format: "%.0f", food.nutrition.carbs)) F:\(String(format: "%.0f", food.nutrition.fat))")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(KinexaTheme.tertiaryText)
                            if food.nutrition.alcohol > 0 {
                                Text("A:\(String(format: "%.0f", food.nutrition.alcohol))")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(Color(hex: "#A855F7"))
                            }
                        }
                    }
                }
                .padding(14)
                .background(KinexaTheme.cardSoft)
                .clipShape(.rect(cornerRadius: 12))
            }
        }
    }

    private var aiAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color(hex: "#6366F1"))
                Text("AI Analysis")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(KinexaTheme.secondaryText)
                Spacer()
                if insight == nil && !isAnalyzing {
                    Button {
                        isAnalyzing = true
                        Task {
                            await nutritionVM.analyzeMeal(meal)
                            insight = nutritionVM.mealInsights[meal.id]
                            isAnalyzing = false
                        }
                    } label: {
                        Text("Analyze")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color(hex: "#6366F1"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(hex: "#6366F1").opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
            }

            if isAnalyzing {
                HStack(spacing: 10) {
                    ProgressView()
                        .tint(Color(hex: "#6366F1"))
                    Text("Analyzing meal...")
                        .font(.caption)
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            } else if let insight {
                VStack(alignment: .leading, spacing: 14) {
                    Text(insight.summary)
                        .font(.subheadline)
                        .foregroundStyle(KinexaTheme.primaryText)
                        .lineSpacing(3)

                    if !insight.strengths.isEmpty {
                        insightList(title: "Strengths", items: insight.strengths, icon: "checkmark.circle.fill", color: KinexaTheme.success)
                    }

                    if !insight.improvements.isEmpty {
                        insightList(title: "Improvements", items: insight.improvements, icon: "arrow.up.circle.fill", color: KinexaTheme.warning)
                    }

                    HStack(spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .font(.caption)
                            .foregroundStyle(Color(hex: "#F59E0B"))
                        Text(insight.tip)
                            .font(.caption)
                            .foregroundStyle(KinexaTheme.secondaryText)
                            .lineSpacing(2)
                    }
                    .padding(12)
                    .background(Color(hex: "#F59E0B").opacity(0.08))
                    .clipShape(.rect(cornerRadius: 10))
                }
            }
        }
        .padding(16)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(KinexaTheme.card)
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#6366F1").opacity(0.04), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color(hex: "#6366F1").opacity(0.12))
            }
        }
        .clipShape(.rect(cornerRadius: 18))
    }

    private func insightList(title: String, items: [String], icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(KinexaTheme.secondaryText)
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                        .foregroundStyle(color)
                        .padding(.top, 2)
                    Text(item)
                        .font(.caption)
                        .foregroundStyle(KinexaTheme.primaryText)
                        .lineSpacing(2)
                }
            }
        }
    }

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(KinexaTheme.secondaryText)
            Text(meal.notes)
                .font(.subheadline)
                .foregroundStyle(KinexaTheme.primaryText)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(KinexaTheme.border)
        }
    }

    private var deleteButton: some View {
        Button {
            showDeleteConfirm = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "trash")
                Text("Delete Meal")
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(KinexaTheme.danger)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(KinexaTheme.danger.opacity(0.1))
            .clipShape(.rect(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}
