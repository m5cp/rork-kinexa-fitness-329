import SwiftUI

struct RecipesView: View {
    @State private var recipeVM = RecipeViewModel()
    var nutritionVM: NutritionViewModel
    @State private var showGenerateSheet: Bool = false
    @State private var selectedRecipe: Recipe?
    @State private var showFavoritesOnly: Bool = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                VStack(spacing: 20) {
                    headerSection
                    if !recipeVM.isGroqConfigured {
                        apiKeyMissing
                    } else {
                        generateCard
                        categoryFilter
                        if recipeVM.isGenerating {
                            generatingPlaceholder
                        }
                        if let error = recipeVM.errorMessage {
                            errorCard(error)
                        }
                        recipesGrid
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 48)
                .adaptiveContainer()
            }
        }
        .background {
            ZStack {
                KinexaTheme.background.ignoresSafeArea()
                recipeAmbience
            }
        }
        .navigationTitle("Recipes")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        showFavoritesOnly.toggle()
                    }
                } label: {
                    Image(systemName: showFavoritesOnly ? "heart.fill" : "heart")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(showFavoritesOnly ? Color(hex: "#EF4444") : KinexaTheme.secondaryText)
                }
            }
        }
        .sheet(isPresented: $showGenerateSheet) {
            GenerateRecipeSheet(recipeVM: recipeVM, nutritionVM: nutritionVM)
        }
        .sheet(item: $selectedRecipe) { recipe in
            RecipeDetailSheet(recipe: recipe, recipeVM: recipeVM, nutritionVM: nutritionVM)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("AI Recipes")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(KinexaTheme.primaryText)
            Text("Personalized recipes based on your macros & goals")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(KinexaTheme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var apiKeyMissing: some View {
        VStack(spacing: 16) {
            Image(systemName: "key.fill")
                .font(.system(size: 36))
                .foregroundStyle(KinexaTheme.tertiaryText)
            Text("Groq API Key Required")
                .font(.headline.weight(.bold))
                .foregroundStyle(KinexaTheme.primaryText)
            Text("Add your Groq API key in settings to enable AI recipe generation.")
                .font(.subheadline)
                .foregroundStyle(KinexaTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(KinexaTheme.card)
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(KinexaTheme.border)
        }
        .clipShape(.rect(cornerRadius: 20))
    }

    private var generateCard: some View {
        Button {
            showGenerateSheet = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#F59E0B").opacity(0.2), Color(hex: "#F59E0B").opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 52, height: 52)
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color(hex: "#F59E0B"))
                        .symbolEffect(.pulse, options: .repeating.speed(0.5))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Generate Recipes")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)
                    Text("AI creates meals that fit your macros")
                        .font(.caption)
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }

                Spacer()

                Image(systemName: "chevron.right.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color(hex: "#F59E0B"))
            }
            .padding(16)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(KinexaTheme.card)
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#F59E0B").opacity(0.06), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "#F59E0B").opacity(0.15))
                }
            }
            .clipShape(.rect(cornerRadius: 20))
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(RecipeCategory.allCases, id: \.rawValue) { category in
                    let isSelected = recipeVM.selectedCategory == category
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            recipeVM.selectedCategory = category
                        }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: category.icon)
                                .font(.system(size: 10, weight: .bold))
                            Text(category.rawValue)
                                .font(.system(size: 11, weight: .bold))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(isSelected ? KinexaTheme.accent : KinexaTheme.card)
                        .foregroundStyle(isSelected ? .white : KinexaTheme.secondaryText)
                        .clipShape(.capsule)
                        .overlay {
                            if !isSelected {
                                Capsule().stroke(KinexaTheme.border)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .contentMargins(.horizontal, 0)
    }

    private var generatingPlaceholder: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(Color(hex: "#F59E0B"))
                .scaleEffect(1.2)
            Text("Generating recipes...")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(KinexaTheme.secondaryText)
            Text("Groq AI is creating personalized meals")
                .font(.caption)
                .foregroundStyle(KinexaTheme.tertiaryText)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(KinexaTheme.card)
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(KinexaTheme.border)
        }
        .clipShape(.rect(cornerRadius: 20))
    }

    private func errorCard(_ message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(KinexaTheme.warning)
            Text(message)
                .font(.caption.weight(.medium))
                .foregroundStyle(KinexaTheme.secondaryText)
            Spacer()
            Button {
                recipeVM.errorMessage = nil
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }
        }
        .padding(14)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(KinexaTheme.card)
                RoundedRectangle(cornerRadius: 14)
                    .fill(KinexaTheme.warning.opacity(0.06))
                RoundedRectangle(cornerRadius: 14)
                    .stroke(KinexaTheme.warning.opacity(0.2))
            }
        }
        .clipShape(.rect(cornerRadius: 14))
    }

    private var displayedRecipes: [Recipe] {
        showFavoritesOnly ? recipeVM.favoriteRecipes : recipeVM.filteredRecipes
    }

    private var recipesGrid: some View {
        Group {
            if displayedRecipes.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: 14) {
                    ForEach(displayedRecipes) { recipe in
                        Button {
                            selectedRecipe = recipe
                        } label: {
                            recipeCard(recipe)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: showFavoritesOnly ? "heart.slash" : "frying.pan.fill")
                .font(.system(size: 40))
                .foregroundStyle(KinexaTheme.tertiaryText)
                .symbolEffect(.pulse, options: .repeating.speed(0.5))

            Text(showFavoritesOnly ? "No Favorites Yet" : "No Recipes Yet")
                .font(.headline.weight(.bold))
                .foregroundStyle(KinexaTheme.secondaryText)

            Text(showFavoritesOnly ? "Heart a recipe to save it here" : "Generate AI recipes tailored to\nyour goals and remaining macros")
                .font(.caption)
                .foregroundStyle(KinexaTheme.tertiaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(2)

            if !showFavoritesOnly {
                Button {
                    showGenerateSheet = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                        Text("Generate Recipes")
                    }
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#F59E0B"), Color(hex: "#D97706")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(.rect(cornerRadius: 12))
                }
                .buttonStyle(PressScaleButtonStyle())
            }
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(KinexaTheme.card)
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(KinexaTheme.border)
        }
        .clipShape(.rect(cornerRadius: 20))
    }

    private func recipeCard(_ recipe: Recipe) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Text(recipe.summary)
                        .font(.caption)
                        .foregroundStyle(KinexaTheme.tertiaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.3)) {
                        recipeVM.toggleFavorite(id: recipe.id)
                    }
                } label: {
                    Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(recipe.isFavorite ? Color(hex: "#EF4444") : KinexaTheme.tertiaryText)
                        .frame(width: 36, height: 36)
                        .background(KinexaTheme.cardSoft)
                        .clipShape(Circle())
                }
            }

            HStack(spacing: 16) {
                macroTag(value: "\(recipe.nutrition.calories)", label: "cal", color: Color(hex: "#22C55E"))
                macroTag(value: "\(String(format: "%.0f", recipe.nutrition.protein))g", label: "protein", color: Color(hex: "#3B82F6"))
                macroTag(value: "\(String(format: "%.0f", recipe.nutrition.carbs))g", label: "carbs", color: Color(hex: "#F59E0B"))
                macroTag(value: "\(String(format: "%.0f", recipe.nutrition.fat))g", label: "fat", color: Color(hex: "#EC4899"))
            }

            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 9))
                    Text(recipe.prepTime)
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundStyle(KinexaTheme.tertiaryText)

                HStack(spacing: 4) {
                    Image(systemName: recipe.difficulty.icon)
                        .font(.system(size: 9))
                    Text(recipe.difficulty.rawValue)
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundStyle(Color(hex: recipe.difficulty.color))

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 9))
                    Text("\(recipe.servings) servings")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundStyle(KinexaTheme.tertiaryText)
            }

            if !recipe.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(recipe.tags.prefix(4), id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 9, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(KinexaTheme.accent.opacity(0.12))
                                .foregroundStyle(KinexaTheme.accent)
                                .clipShape(.capsule)
                        }
                    }
                }
                .contentMargins(.horizontal, 0)
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

    private func macroTag(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 8, weight: .semibold))
                .foregroundStyle(KinexaTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private var recipeAmbience: some View {
        RadialGradient(
            colors: [Color(hex: "#F59E0B").opacity(0.05), .clear],
            center: .topTrailing,
            startRadius: 80,
            endRadius: 350
        )
        .ignoresSafeArea()
    }
}
