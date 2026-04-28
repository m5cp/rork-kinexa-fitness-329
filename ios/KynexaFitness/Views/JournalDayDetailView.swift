import SwiftUI

struct JournalDayDetailView: View {
    @Environment(AppViewModel.self) private var vm
    @Environment(NutritionViewModel.self) private var nutritionVM

    let date: Date

    @State private var showShareSheet: Bool = false
    @State private var pdfData: Data?
    @State private var exportTrigger: Bool = false

    private let calendar = Calendar.current

    private var workouts: [CompletedWorkoutRecord] {
        vm.completedRecordsForDate(date)
    }

    private var cardioSessions: [CardioSession] {
        vm.cardioSessions.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    private var quickStarts: [QuickStartRecord] {
        vm.quickStartRecords.filter { calendar.isDate($0.startDate, inSameDayAs: date) }
    }

    private var meals: [MealEntry] {
        nutritionVM.mealsForDate(date)
    }

    private var nutrition: NutritionInfo {
        nutritionVM.nutritionForDate(date)
    }

    private var waterOz: Double {
        nutritionVM.waterForDate(date)
    }

    private var steps: Int {
        if calendar.isDateInToday(date) { return vm.pedometer.todaySteps }
        return vm.stepHistory.first { calendar.isDate($0.date, inSameDayAs: date) }?.steps ?? 0
    }

    private var totalActivityCount: Int {
        workouts.count + cardioSessions.count + quickStarts.count
    }

    var body: some View {
        ZStack {
            KynexaTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    dayHeader
                    overviewGrid
                    if totalActivityCount > 0 { workoutSection }
                    nutritionSection
                    if nutrition.calories > 0 { macroBreakdown }
                    if waterOz > 0 { waterCard }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 48)
                .adaptiveContainer()
            }
        }
        .navigationTitle(shortDate)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(KynexaTheme.background, for: .navigationBar)
        
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    generateAndSharePDF()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.caption.weight(.bold))
                        Text("PDF")
                            .font(.caption.weight(.bold))
                    }
                    .foregroundStyle(KynexaTheme.accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(KynexaTheme.accent.opacity(0.12))
                    .clipShape(Capsule())
                }
            }
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: exportTrigger)
        .sheet(isPresented: $showShareSheet) {
            if let data = pdfData {
                ShareSheet(items: [data])
            }
        }
    }

    // MARK: - Header

    private var dayHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dayOfWeek)
                        .font(.caption.weight(.heavy))
                        .tracking(1.0)
                        .foregroundStyle(KynexaTheme.tertiaryText)
                    Text(fullDate)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(KynexaTheme.primaryText)
                }
                Spacer()
                if calendar.isDateInToday(date) {
                    Text("TODAY")
                        .font(.system(size: 11, weight: .heavy))
                        .tracking(0.5)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(KynexaTheme.accent)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(18)
        .premiumCard()
    }

    // MARK: - Overview Grid

    private var overviewGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            overviewTile(icon: "figure.mixed.cardio", value: "\(totalActivityCount)", label: "Workouts", color: KynexaTheme.success, gradient: [KynexaTheme.success, KynexaTheme.success.opacity(0.6)])
            overviewTile(icon: "flame.fill", value: "\(nutrition.calories)", label: "Calories", color: Color(hex: "#F59E0B"), gradient: [Color(hex: "#F59E0B"), Color(hex: "#D97706")])
            overviewTile(icon: "shoeprints.fill", value: "\(steps)", label: "Steps", color: KynexaTheme.accent, gradient: [KynexaTheme.accent, KynexaTheme.accent2])
            overviewTile(icon: "drop.fill", value: "\(Int(waterOz))oz", label: "Water", color: Color(hex: "#38BDF8"), gradient: [Color(hex: "#38BDF8"), Color(hex: "#0284C7")])
        }
    }

    private func overviewTile(icon: String, value: String, label: String, color: Color, gradient: [Color]) -> some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .clipShape(.rect(cornerRadius: 8))
                Spacer()
            }
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(value)
                        .font(.system(.title3, design: .rounded).weight(.bold))
                        .foregroundStyle(KynexaTheme.primaryText)
                        .contentTransition(.numericText())
                    Text(label)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(KynexaTheme.tertiaryText)
                }
                Spacer()
            }
        }
        .padding(14)
        .premiumCard()
    }

    // MARK: - Workouts

    private var workoutSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("WORKOUTS", icon: "figure.strengthtraining.traditional")

            ForEach(workouts) { record in
                workoutRecordCard(record)
            }

            ForEach(cardioSessions) { session in
                cardioSessionCard(session)
            }

            ForEach(quickStarts) { qs in
                quickStartCard(qs)
            }
        }
    }

    private func workoutRecordCard(_ record: CompletedWorkoutRecord) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(KynexaTheme.success)
                    .frame(width: 38, height: 38)
                    .background(KynexaTheme.success.opacity(0.12))
                    .clipShape(.rect(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 3) {
                    Text(record.title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(KynexaTheme.primaryText)
                        .lineLimit(1)
                    HStack(spacing: 6) {
                        Text("\(record.exerciseCount) exercises")
                        Text("·")
                        Text(record.source.rawValue)
                    }
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(KynexaTheme.tertiaryText)
                }
                Spacer()

                let timeF = DateFormatter()
                let _ = timeF.dateFormat = "h:mm a"
                Text(timeF.string(from: record.date))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(KynexaTheme.tertiaryText)
            }

            if !record.exercises.isEmpty {
                VStack(spacing: 0) {
                    ForEach(record.exercises.prefix(6)) { exercise in
                        HStack(spacing: 8) {
                            Image(systemName: exercise.isCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 10))
                                .foregroundStyle(exercise.isCompleted ? KynexaTheme.success : KynexaTheme.tertiaryText.opacity(0.5))
                            Text(exercise.name)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(KynexaTheme.primaryText)
                                .lineLimit(1)
                            Spacer()
                            Text(exercise.displayDetail)
                                .font(.system(size: 9, weight: .medium))
                                .foregroundStyle(KynexaTheme.tertiaryText)
                        }
                        .padding(.vertical, 5)
                    }
                    if record.exercises.count > 6 {
                        Text("+\(record.exercises.count - 6) more")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(KynexaTheme.tertiaryText)
                            .padding(.top, 4)
                    }
                }
                .padding(10)
                .background(KynexaTheme.cardSoft)
                .clipShape(.rect(cornerRadius: 10))
            }
        }
        .padding(14)
        .premiumCard()
    }

    private func cardioSessionCard(_ session: CardioSession) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "heart.fill")
                .font(.body.weight(.semibold))
                .foregroundStyle(Color(hex: "#EC4899"))
                .frame(width: 38, height: 38)
                .background(Color(hex: "#EC4899").opacity(0.12))
                .clipShape(.rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 3) {
                Text(session.workoutName)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(KynexaTheme.primaryText)
                HStack(spacing: 8) {
                    Text("\(session.durationMinutes) min")
                    if let d = session.distanceMiles, d > 0 { Text(String(format: "%.1f mi", d)) }
                    if let c = session.caloriesBurned { Text("\(c) cal") }
                }
                .font(.caption2.weight(.medium))
                .foregroundStyle(KynexaTheme.tertiaryText)
            }
            Spacer()
        }
        .padding(14)
        .premiumCard()
    }

    private func quickStartCard(_ qs: QuickStartRecord) -> some View {
        HStack(spacing: 12) {
            Image(systemName: qs.activity.icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(Color(hex: "#6366F1"))
                .frame(width: 38, height: 38)
                .background(Color(hex: "#6366F1").opacity(0.12))
                .clipShape(.rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 3) {
                Text(qs.activity.rawValue)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(KynexaTheme.primaryText)
                HStack(spacing: 8) {
                    Text(qs.formattedDuration)
                    if qs.activity.usesGPS {
                        Text(qs.formattedDistance)
                        Text(qs.formattedPace)
                    }
                }
                .font(.caption2.weight(.medium))
                .foregroundStyle(KynexaTheme.tertiaryText)
            }
            Spacer()
        }
        .padding(14)
        .premiumCard()
    }

    // MARK: - Nutrition

    private var nutritionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("NUTRITION", icon: "fork.knife")

            if meals.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "tray")
                        .font(.title3)
                        .foregroundStyle(KynexaTheme.tertiaryText.opacity(0.4))
                    Text("No meals logged")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(KynexaTheme.tertiaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .premiumCard()
            } else {
                ForEach(meals) { meal in
                    mealCard(meal)
                }
            }
        }
    }

    private func mealCard(_ meal: MealEntry) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: meal.mealType.icon)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color(hex: meal.mealType.color))
                    .frame(width: 34, height: 34)
                    .background(Color(hex: meal.mealType.color).opacity(0.12))
                    .clipShape(.rect(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text(meal.mealType.rawValue)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(KynexaTheme.primaryText)
                    Text("\(meal.foods.count) item\(meal.foods.count == 1 ? "" : "s")")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(KynexaTheme.tertiaryText)
                }
                Spacer()
                Text("\(meal.totalNutrition.calories) cal")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color(hex: meal.mealType.color))
            }

            ForEach(meal.foods) { food in
                HStack(spacing: 6) {
                    Circle().fill(Color(hex: meal.mealType.color).opacity(0.4)).frame(width: 4, height: 4)
                    Text(food.name)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(KynexaTheme.secondaryText)
                        .lineLimit(1)
                    Spacer()
                    Text("\(food.nutrition.calories) cal")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(KynexaTheme.tertiaryText)
                }
            }
        }
        .padding(14)
        .premiumCard()
    }

    // MARK: - Macro Breakdown

    private var macroBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("MACROS", icon: "chart.pie.fill")

            HStack(spacing: 16) {
                macroRing("Protein", value: nutrition.protein, goal: nutritionVM.dailyGoal.protein, unit: "g", color: Color(hex: "#3B82F6"))
                macroRing("Carbs", value: nutrition.carbs, goal: nutritionVM.dailyGoal.carbs, unit: "g", color: Color(hex: "#F59E0B"))
                macroRing("Fat", value: nutrition.fat, goal: nutritionVM.dailyGoal.fat, unit: "g", color: Color(hex: "#EC4899"))
            }
            .padding(16)
            .premiumCard()
        }
    }

    private func macroRing(_ label: String, value: Double, goal: Double, unit: String, color: Color) -> some View {
        let progress = goal > 0 ? min(value / goal, 1.0) : 0

        return VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.12), lineWidth: 6)
                    .frame(width: 52, height: 52)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 52, height: 52)
                    .rotationEffect(.degrees(-90))
                Text("\(Int(value))")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
            }
            Text(label)
                .font(.caption2.weight(.bold))
                .foregroundStyle(KynexaTheme.secondaryText)
            Text("\(Int(value))/\(Int(goal))\(unit)")
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(KynexaTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Water

    private var waterCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "drop.fill")
                .font(.title3.weight(.bold))
                .foregroundStyle(Color(hex: "#38BDF8"))
                .frame(width: 40, height: 40)
                .background(Color(hex: "#38BDF8").opacity(0.12))
                .clipShape(.rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 3) {
                Text("Water Intake")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(KynexaTheme.primaryText)
                Text("\(Int(waterOz))oz of \(Int(nutritionVM.waterGoal.dailyOunces))oz goal")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(KynexaTheme.tertiaryText)
            }

            Spacer()

            let progress = nutritionVM.waterGoal.dailyOunces > 0 ? min(waterOz / nutritionVM.waterGoal.dailyOunces, 1.0) : 0
            CircularProgressView(progress: progress, size: 32, lineWidth: 4, color: Color(hex: "#38BDF8"))
        }
        .padding(14)
        .premiumCard()
    }

    // MARK: - Helpers

    private func sectionLabel(_ title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2.weight(.bold))
                .foregroundStyle(KynexaTheme.tertiaryText)
            Text(title)
                .font(.caption.weight(.bold))
                .tracking(0.8)
                .foregroundStyle(KynexaTheme.tertiaryText)
        }
        .padding(.horizontal, 4)
    }

    private var shortDate: String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: date)
    }

    private var fullDate: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM d, yyyy"
        return f.string(from: date)
    }

    private var dayOfWeek: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE"
        return f.string(from: date).uppercased()
    }

    private func generateAndSharePDF() {
        exportTrigger.toggle()
        pdfData = DailyJournalPDFService.generateDayPDF(
            date: date,
            workouts: workouts,
            cardioSessions: cardioSessions,
            quickStartRecords: quickStarts,
            meals: meals,
            nutrition: nutrition,
            nutritionGoal: nutritionVM.dailyGoal,
            waterOunces: waterOz,
            steps: steps
        )
        showShareSheet = true
    }
}
