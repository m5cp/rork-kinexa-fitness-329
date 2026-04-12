import SwiftUI

struct RecipeDetailSheet: View {
    let recipe: Recipe
    var recipeVM: RecipeViewModel
    var nutritionVM: NutritionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showLogConfirm: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    titleSection
                    macroRow
                    metaRow
                    ingredientsSection
                    instructionsSection
                    logMealButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(KinexaTheme.background.ignoresSafeArea())
            .navigationTitle("Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(KinexaTheme.secondaryText)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                recipeVM.toggleFavorite(id: recipe.id)
                            }
                        } label: {
                            let isFav = recipeVM.recipes.first(where: { $0.id == recipe.id })?.isFavorite ?? recipe.isFavorite
                            Image(systemName: isFav ? "heart.fill" : "heart")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(isFav ? Color(hex: "#EF4444") : KinexaTheme.secondaryText)
                        }

                        ShareLink(item: recipeShareText) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(KinexaTheme.secondaryText)
                        }
                    }
                }
            }
            .alert("Log This Meal?", isPresented: $showLogConfirm) {
                Button("Log as Meal") {
                    logRecipeAsMeal()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Add \(recipe.title) to today's meals with its nutritional info.")
            }
        }
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(recipe.title)
                .font(.title2.weight(.bold))
                .foregroundStyle(KinexaTheme.primaryText)

            Text(recipe.summary)
                .font(.subheadline)
                .foregroundStyle(KinexaTheme.secondaryText)
                .lineSpacing(3)

            if !recipe.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(recipe.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 10, weight: .bold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(KinexaTheme.accent.opacity(0.12))
                                .foregroundStyle(KinexaTheme.accent)
                                .clipShape(.capsule)
                        }
                    }
                }
                .contentMargins(.horizontal, 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var macroRow: some View {
        HStack(spacing: 0) {
            macroCell(value: "\(recipe.nutrition.calories)", label: "Calories", color: Color(hex: "#22C55E"))
            divider
            macroCell(value: "\(String(format: "%.0f", recipe.nutrition.protein))g", label: "Protein", color: Color(hex: "#3B82F6"))
            divider
            macroCell(value: "\(String(format: "%.0f", recipe.nutrition.carbs))g", label: "Carbs", color: Color(hex: "#F59E0B"))
            divider
            macroCell(value: "\(String(format: "%.0f", recipe.nutrition.fat))g", label: "Fat", color: Color(hex: "#EC4899"))
        }
        .padding(.vertical, 18)
        .background(KinexaTheme.card)
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(KinexaTheme.border)
        }
        .clipShape(.rect(cornerRadius: 18))
    }

    private func macroCell(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(KinexaTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private var divider: some View {
        Rectangle()
            .fill(KinexaTheme.border)
            .frame(width: 1, height: 36)
    }

    private var metaRow: some View {
        HStack(spacing: 0) {
            metaItem(icon: "clock.fill", label: "Prep", value: recipe.prepTime)
            metaItem(icon: "flame.fill", label: "Cook", value: recipe.cookTime)
            metaItem(icon: recipe.difficulty.icon, label: "Level", value: recipe.difficulty.rawValue)
            metaItem(icon: "person.2.fill", label: "Serves", value: "\(recipe.servings)")
        }
        .padding(.vertical, 14)
        .background(KinexaTheme.card)
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(KinexaTheme.border)
        }
        .clipShape(.rect(cornerRadius: 14))
    }

    private func metaItem(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(KinexaTheme.accent)
            Text(value)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(KinexaTheme.primaryText)
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(KinexaTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "basket.fill")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color(hex: "#22C55E"))
                Text("Ingredients")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)
                Spacer()
                Text("\(recipe.ingredients.count) items")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }

            VStack(spacing: 0) {
                ForEach(Array(recipe.ingredients.enumerated()), id: \.element.id) { index, ingredient in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(KinexaTheme.accent.opacity(0.2))
                            .frame(width: 6, height: 6)

                        Text(ingredient.amount)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(KinexaTheme.accent)
                            .frame(width: 70, alignment: .leading)

                        Text(ingredient.name)
                            .font(.subheadline)
                            .foregroundStyle(KinexaTheme.primaryText)

                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)

                    if index < recipe.ingredients.count - 1 {
                        Rectangle()
                            .fill(KinexaTheme.border)
                            .frame(height: 0.5)
                            .padding(.leading, 32)
                    }
                }
            }
            .background(KinexaTheme.card)
            .clipShape(.rect(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(KinexaTheme.border)
            }
        }
    }

    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "list.number")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color(hex: "#6366F1"))
                Text("Instructions")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)
            }

            VStack(spacing: 12) {
                ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 14) {
                        Text("\(index + 1)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 26, height: 26)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "#6366F1"), Color(hex: "#4F46E5")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())

                        Text(step)
                            .font(.subheadline)
                            .foregroundStyle(KinexaTheme.primaryText)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(KinexaTheme.card)
                    .clipShape(.rect(cornerRadius: 14))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(KinexaTheme.border)
                    }
                }
            }
        }
    }

    private var logMealButton: some View {
        Button {
            showLogConfirm = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.subheadline.weight(.bold))
                Text("Log as Meal")
                    .font(.headline.weight(.bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                LinearGradient(
                    colors: [Color(hex: "#22C55E"), Color(hex: "#16A34A")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(.rect(cornerRadius: 14))
            .shadow(color: Color(hex: "#22C55E").opacity(0.4), radius: 12, y: 6)
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    private func logRecipeAsMeal() {
        let food = FoodItem(
            name: recipe.title,
            quantity: "\(recipe.servings) serving\(recipe.servings == 1 ? "" : "s")",
            nutrition: NutritionInfo(
                calories: recipe.nutrition.calories,
                protein: recipe.nutrition.protein,
                carbs: recipe.nutrition.carbs,
                fat: recipe.nutrition.fat,
                fiber: recipe.nutrition.fiber,
                sugar: 0,
                alcohol: 0
            ),
            source: .aiText
        )

        let mealType = suggestedMealType
        let meal = MealEntry(mealType: mealType, foods: [food])
        nutritionVM.addMeal(meal)
    }

    private var suggestedMealType: MealType {
        let hour = Calendar.current.component(.hour, from: .now)
        if hour < 11 { return .breakfast }
        if hour < 15 { return .lunch }
        if hour < 20 { return .dinner }
        return .snack
    }

    private var recipeShareText: String {
        var text = "\(recipe.title)\n\n"
        text += "\(recipe.summary)\n\n"
        text += "Macros per serving: \(recipe.nutrition.calories) cal | \(String(format: "%.0f", recipe.nutrition.protein))g protein | \(String(format: "%.0f", recipe.nutrition.carbs))g carbs | \(String(format: "%.0f", recipe.nutrition.fat))g fat\n\n"
        text += "Ingredients:\n"
        for ingredient in recipe.ingredients {
            text += "• \(ingredient.amount) \(ingredient.name)\n"
        }
        text += "\nInstructions:\n"
        for (i, step) in recipe.instructions.enumerated() {
            text += "\(i + 1). \(step)\n"
        }
        text += "\nGenerated by Kinexa Fitness"
        return text
    }
}
