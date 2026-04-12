import SwiftUI

struct NutritionTabView: View {
    @State private var nutritionVM = NutritionViewModel()
    @State private var showLogMeal: Bool = false
    @State private var showGoalSheet: Bool = false
    @State private var showProfileSheet: Bool = false
    @State private var showDailyInsight: Bool = false
    @State private var showHistoryView: Bool = false
    @State private var showRecipesView: Bool = false
    @State private var selectedMeal: MealEntry?
    @State private var animateRings: Bool = false
    @State private var showExportSheet: Bool = false
    @State private var exportedPDFURL: URL?
    @State private var mealSuggestion: String?
    @State private var isLoadingSuggestion: Bool = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                VStack(spacing: 24) {
                    headerSection
                    if !nutritionVM.isProfileConfigured {
                        profileSetupBanner
                    }
                    dateSelector
                    calorieRingCard
                    macroProgressRow
                    if nutritionVM.todayNutrition.alcohol > 0 {
                        alcoholBadge
                    }
                    WaterTrackerCard(nutritionVM: nutritionVM)
                    mealsSection
                    recipesCard
                    if nutritionVM.isGeminiConfigured && !nutritionVM.mealsForSelectedDate.isEmpty {
                        smartSuggestionCard
                    }
                    if nutritionVM.isGeminiConfigured && !nutritionVM.mealsForSelectedDate.isEmpty {
                        aiInsightButton
                    }
                    weeklyPreviewCard
                    if !nutritionVM.mealsForSelectedDate.isEmpty {
                        exportButton
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
                nutritionAmbience
            }
        }
        .navigationTitle("Nutrition")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    Button {
                        exportWeekPDF()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(KinexaTheme.secondaryText)
                    }
                    Button {
                        showProfileSheet = true
                    } label: {
                        Image(systemName: "person.crop.circle")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(KinexaTheme.accent)
                    }
                }
            }
        }
        .sheet(isPresented: $showLogMeal) {
            LogMealSheet(nutritionVM: nutritionVM)
        }
        .sheet(isPresented: $showGoalSheet) {
            NutritionGoalSheet(nutritionVM: nutritionVM)
        }
        .sheet(isPresented: $showProfileSheet) {
            NutritionProfileSheet(nutritionVM: nutritionVM)
        }
        .sheet(item: $selectedMeal) { meal in
            MealDetailSheet(meal: meal, nutritionVM: nutritionVM)
        }
        .sheet(isPresented: $showDailyInsight) {
            DailyInsightSheet(nutritionVM: nutritionVM)
        }
        .sheet(isPresented: $showExportSheet) {
            if let url = exportedPDFURL {
                ShareSheet(items: [url])
                    .presentationDetents([.medium])
            }
        }
        .navigationDestination(isPresented: $showHistoryView) {
            NutritionHistoryView(nutritionVM: nutritionVM)
        }
        .navigationDestination(isPresented: $showRecipesView) {
            RecipesView(nutritionVM: nutritionVM)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.3)) {
                animateRings = true
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Nutrition")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(KinexaTheme.primaryText)
                HStack(spacing: 8) {
                    Text(nutritionVM.mealsForSelectedDate.isEmpty ? "Log your first meal" : "\(nutritionVM.mealsForSelectedDate.count) meal\(nutritionVM.mealsForSelectedDate.count == 1 ? "" : "s") logged")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(KinexaTheme.secondaryText)
                    if nutritionVM.loggingStreak > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 10))
                            Text("\(nutritionVM.loggingStreak)")
                                .font(.system(size: 11, weight: .bold))
                        }
                        .foregroundStyle(Color(hex: "#F59E0B"))
                    }
                }
            }
            Spacer()
            Button {
                showLogMeal = true
            } label: {
                Image(systemName: "plus")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#22C55E"), Color(hex: "#16A34A")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(color: Color(hex: "#22C55E").opacity(0.4), radius: 8, y: 4)
            }
            .buttonStyle(PressScaleButtonStyle())
        }
    }

    // MARK: - Profile Setup Banner

    private var profileSetupBanner: some View {
        Button {
            showProfileSheet = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(KinexaTheme.accent.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "person.text.rectangle.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(KinexaTheme.accent)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Set Up Your Profile")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)
                    Text("Auto-calculate calorie & macro targets based on your body stats and goals")
                        .font(.caption)
                        .foregroundStyle(KinexaTheme.tertiaryText)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(KinexaTheme.accent)
            }
            .padding(14)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(KinexaTheme.card)
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [KinexaTheme.accent.opacity(0.06), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(KinexaTheme.accent.opacity(0.2))
                }
            }
            .clipShape(.rect(cornerRadius: 16))
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    // MARK: - Date Selector

    private var dateSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(-3...3, id: \.self) { offset in
                    let date = Calendar.current.date(byAdding: .day, value: offset, to: Calendar.current.startOfDay(for: .now)) ?? .now
                    let isSelected = Calendar.current.isDate(date, inSameDayAs: nutritionVM.selectedDate)
                    let isToday = Calendar.current.isDateInToday(date)

                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            nutritionVM.selectedDate = date
                            animateRings = false
                        }
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
                            animateRings = true
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Text(dayLabel(date))
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(isSelected ? .white : KinexaTheme.tertiaryText)
                            Text("\(Calendar.current.component(.day, from: date))")
                                .font(.system(size: 16, weight: isSelected ? .bold : .semibold))
                                .foregroundStyle(isSelected ? .white : KinexaTheme.primaryText)
                            if isToday {
                                Circle()
                                    .fill(isSelected ? .white : KinexaTheme.accent)
                                    .frame(width: 4, height: 4)
                            } else {
                                Circle()
                                    .fill(.clear)
                                    .frame(width: 4, height: 4)
                            }
                        }
                        .frame(width: 48, height: 68)
                        .background(isSelected ? KinexaTheme.accent : KinexaTheme.card)
                        .clipShape(.rect(cornerRadius: 14))
                        .overlay {
                            if !isSelected {
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(KinexaTheme.border)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .contentMargins(.horizontal, 0)
    }

    // MARK: - Calorie Ring

    private var calorieRingCard: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(KinexaTheme.cardSoft, lineWidth: 14)
                    .frame(width: 160, height: 160)

                Circle()
                    .trim(from: 0, to: animateRings ? nutritionVM.calorieProgress : 0)
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "#22C55E"), Color(hex: "#16A34A")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 4) {
                    Text("\(nutritionVM.todayNutrition.calories)")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(KinexaTheme.primaryText)
                        .contentTransition(.numericText())
                    Text("of \(nutritionVM.dailyGoal.calories)")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                    Text("calories")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(KinexaTheme.secondaryText)
                }
            }

            let remaining = max(0, nutritionVM.dailyGoal.calories - nutritionVM.todayNutrition.calories)
            Text("\(remaining) cal remaining")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(remaining > 0 ? KinexaTheme.success : KinexaTheme.warning)

            if nutritionVM.isProfileConfigured {
                HStack(spacing: 6) {
                    Image(systemName: nutritionVM.profile.goalType.icon)
                        .font(.system(size: 10, weight: .bold))
                    Text(nutritionVM.profile.goalType.rawValue)
                        .font(.system(size: 10, weight: .bold))
                    Text("·")
                    Text("TDEE \(Int(nutritionVM.profile.tdee))")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundStyle(KinexaTheme.tertiaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(KinexaTheme.card)
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(KinexaTheme.border)
        }
        .clipShape(.rect(cornerRadius: 24))
    }

    // MARK: - Macro Progress

    private var macroProgressRow: some View {
        HStack(spacing: 12) {
            macroCard(
                label: "Protein",
                current: nutritionVM.todayNutrition.protein,
                goal: nutritionVM.dailyGoal.protein,
                progress: nutritionVM.proteinProgress,
                color: Color(hex: "#3B82F6"),
                unit: "g"
            )
            macroCard(
                label: "Carbs",
                current: nutritionVM.todayNutrition.carbs,
                goal: nutritionVM.dailyGoal.carbs,
                progress: nutritionVM.carbsProgress,
                color: Color(hex: "#F59E0B"),
                unit: "g"
            )
            macroCard(
                label: "Fat",
                current: nutritionVM.todayNutrition.fat,
                goal: nutritionVM.dailyGoal.fat,
                progress: nutritionVM.fatProgress,
                color: Color(hex: "#EC4899"),
                unit: "g"
            )
        }
    }

    private func macroCard(label: String, current: Double, goal: Double, progress: Double, color: Color, unit: String) -> some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: 6)
                    .frame(width: 50, height: 50)
                Circle()
                    .trim(from: 0, to: animateRings ? progress : 0)
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(color)
            }
            Text(label)
                .font(.caption2.weight(.bold))
                .foregroundStyle(KinexaTheme.secondaryText)
            Text("\(String(format: "%.0f", current))/\(String(format: "%.0f", goal))\(unit)")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(KinexaTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(KinexaTheme.card)
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(KinexaTheme.border)
        }
        .clipShape(.rect(cornerRadius: 18))
    }

    // MARK: - Alcohol Badge

    private var alcoholBadge: some View {
        HStack(spacing: 10) {
            Image(systemName: "wineglass.fill")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color(hex: "#A855F7"))

            VStack(alignment: .leading, spacing: 2) {
                Text("Alcohol")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(KinexaTheme.secondaryText)
                Text("\(String(format: "%.1f", nutritionVM.todayNutrition.alcohol))g today")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }

            Spacer()

            Text("\(Int(nutritionVM.todayNutrition.alcohol * 7)) cal")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color(hex: "#A855F7"))
        }
        .padding(14)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(KinexaTheme.card)
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(hex: "#A855F7").opacity(0.05))
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(hex: "#A855F7").opacity(0.15))
            }
        }
        .clipShape(.rect(cornerRadius: 14))
    }

    // MARK: - Meals Section

    private var mealsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Meals")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)
                Spacer()
                Button {
                    showLogMeal = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("Log Meal")
                    }
                    .font(.caption.weight(.bold))
                    .foregroundStyle(KinexaTheme.accent)
                }
            }

            if nutritionVM.mealsForSelectedDate.isEmpty {
                emptyMealsCard
            } else {
                ForEach(nutritionVM.mealsForSelectedDate) { meal in
                    Button {
                        selectedMeal = meal
                    } label: {
                        mealRow(meal)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var emptyMealsCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 40))
                .foregroundStyle(KinexaTheme.tertiaryText)
                .symbolEffect(.pulse, options: .repeating.speed(0.5))

            Text("No meals logged yet")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(KinexaTheme.secondaryText)

            Text("Tap + to log your first meal.\nUse AI, camera, barcode, or manual entry.")
                .font(.caption)
                .foregroundStyle(KinexaTheme.tertiaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(2)

            Button {
                showLogMeal = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                    Text("Log with AI")
                }
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#22C55E"), Color(hex: "#16A34A")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(.rect(cornerRadius: 12))
            }
            .buttonStyle(PressScaleButtonStyle())
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(KinexaTheme.card)
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(KinexaTheme.border)
        }
        .clipShape(.rect(cornerRadius: 20))
    }

    private func mealRow(_ meal: MealEntry) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: meal.mealType.color).opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: meal.mealType.icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color(hex: meal.mealType.color))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(meal.mealType.rawValue)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)
                Text(meal.foods.map(\.name).joined(separator: ", "))
                    .font(.caption)
                    .foregroundStyle(KinexaTheme.tertiaryText)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(meal.totalNutrition.calories)")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)
                Text("cal")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(KinexaTheme.tertiaryText)
        }
        .padding(16)
        .background(KinexaTheme.card)
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(KinexaTheme.border)
        }
        .clipShape(.rect(cornerRadius: 16))
    }

    // MARK: - Recipes Card

    private var recipesCard: some View {
        Button {
            showRecipesView = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#F59E0B").opacity(0.2), Color(hex: "#F59E0B").opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    Image(systemName: "frying.pan.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color(hex: "#F59E0B"))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("AI Recipes")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)
                    Text("Groq-powered meals matched to your macros")
                        .font(.caption)
                        .foregroundStyle(KinexaTheme.tertiaryText)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color(hex: "#F59E0B"))
            }
            .padding(16)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(KinexaTheme.card)
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#F59E0B").opacity(0.05), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color(hex: "#F59E0B").opacity(0.12))
                }
            }
            .clipShape(.rect(cornerRadius: 18))
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    // MARK: - Smart Suggestion

    private var smartSuggestionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let suggestion = mealSuggestion {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color(hex: "#F59E0B"))
                    Text("Smart Suggestion")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(KinexaTheme.secondaryText)
                    Spacer()
                    Button {
                        mealSuggestion = nil
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(KinexaTheme.tertiaryText)
                    }
                }

                Text(suggestion)
                    .font(.subheadline)
                    .foregroundStyle(KinexaTheme.primaryText)
                    .lineSpacing(3)
            } else {
                Button {
                    isLoadingSuggestion = true
                    Task {
                        mealSuggestion = await nutritionVM.generateMealSuggestion()
                        isLoadingSuggestion = false
                    }
                } label: {
                    HStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: "#F59E0B").opacity(0.15))
                                .frame(width: 32, height: 32)
                            if isLoadingSuggestion {
                                ProgressView()
                                    .tint(Color(hex: "#F59E0B"))
                                    .scaleEffect(0.7)
                            } else {
                                Image(systemName: "lightbulb.fill")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(Color(hex: "#F59E0B"))
                            }
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("What should I eat next?")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(KinexaTheme.primaryText)
                            Text("AI suggests based on remaining macros")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(KinexaTheme.tertiaryText)
                        }

                        Spacer()

                        Image(systemName: "sparkles")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color(hex: "#F59E0B"))
                    }
                }
                .buttonStyle(.plain)
                .disabled(isLoadingSuggestion)
            }
        }
        .padding(14)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(KinexaTheme.card)
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "#F59E0B").opacity(0.04))
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: "#F59E0B").opacity(0.12))
            }
        }
        .clipShape(.rect(cornerRadius: 16))
    }

    // MARK: - AI Insight Button

    private var aiInsightButton: some View {
        Button {
            showDailyInsight = true
            Task { await nutritionVM.generateDailyInsight() }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: "#6366F1").opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: "sparkles")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color(hex: "#6366F1"))
                        .symbolEffect(.pulse, options: .repeating.speed(0.5))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("AI Daily Analysis")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)
                    Text("Powered by Gemini")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }

                Spacer()

                Image(systemName: "arrow.right.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color(hex: "#6366F1"))
            }
            .padding(16)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(KinexaTheme.card)
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#6366F1").opacity(0.05), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color(hex: "#6366F1").opacity(0.15))
                }
            }
            .clipShape(.rect(cornerRadius: 18))
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    // MARK: - Weekly Preview

    private var weeklyPreviewCard: some View {
        Button {
            showHistoryView = true
        } label: {
            VStack(spacing: 14) {
                HStack(spacing: 8) {
                    Image(systemName: "chart.bar.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color(hex: "#3B82F6"))
                    Text("Weekly Overview")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }

                let weekData = nutritionVM.weeklyCalories()
                let maxCal = max(Double(weekData.map(\.calories).max() ?? 1), 1)

                HStack(alignment: .bottom, spacing: 6) {
                    ForEach(Array(weekData.enumerated()), id: \.offset) { _, item in
                        VStack(spacing: 4) {
                            let height = maxCal > 0 ? CGFloat(Double(item.calories) / maxCal) * 40 : 0
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    item.calories > nutritionVM.dailyGoal.calories
                                    ? KinexaTheme.warning.opacity(0.7)
                                    : KinexaTheme.success.opacity(0.7)
                                )
                                .frame(height: max(2, height))

                            Text(miniDayLabel(item.date))
                                .font(.system(size: 7, weight: .bold))
                                .foregroundStyle(Calendar.current.isDateInToday(item.date) ? KinexaTheme.success : KinexaTheme.tertiaryText)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 56)
            }
            .padding(16)
            .background(KinexaTheme.card)
            .clipShape(.rect(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18).stroke(KinexaTheme.border)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Export

    private var exportButton: some View {
        Button {
            exportWeekPDF()
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(KinexaTheme.accent.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: "doc.text.fill")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(KinexaTheme.accent)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Export Meal Plan")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)
                    Text("PDF day-by-day tracker")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }

                Spacer()

                Image(systemName: "square.and.arrow.up")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(KinexaTheme.accent)
            }
            .padding(16)
            .background(KinexaTheme.card)
            .clipShape(.rect(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(KinexaTheme.border)
            }
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    // MARK: - Helpers

    private func exportWeekPDF() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let weekStart = calendar.date(byAdding: .day, value: -6, to: today) ?? today

        let pdfData = NutritionPDFService.generateMealPlanPDF(
            meals: nutritionVM.meals,
            goal: nutritionVM.dailyGoal,
            startDate: weekStart,
            endDate: today
        )

        let tempDir = FileManager.default.temporaryDirectory
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let fileName = "Kinexa_Nutrition_\(formatter.string(from: today)).pdf"
        let fileURL = tempDir.appendingPathComponent(fileName)

        try? pdfData.write(to: fileURL)
        exportedPDFURL = fileURL
        showExportSheet = true
    }

    private var nutritionAmbience: some View {
        ZStack {
            RadialGradient(
                colors: [Color(hex: "#22C55E").opacity(0.06), .clear],
                center: .topTrailing,
                startRadius: 80,
                endRadius: 350
            )
            .ignoresSafeArea()
        }
    }

    private func dayLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }

    private func miniDayLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1)).uppercased()
    }
}
