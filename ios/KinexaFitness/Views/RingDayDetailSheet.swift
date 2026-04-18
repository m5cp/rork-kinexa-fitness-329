import SwiftUI

struct RingDayDetailSheet: View {
    @Environment(AppViewModel.self) private var appVM
    @Environment(\.dismiss) private var dismiss
    let date: Date
    let nutritionVM: NutritionViewModel
    let ringsVM: ReflectionRingsViewModel

    private let calendar = Calendar.current

    private var closedRings: Set<RingType> {
        ringsVM.closedRings(on: date, appVM: appVM, nutritionVM: nutritionVM)
    }

    private var points: Int {
        ringsVM.pointsEarned(on: date, appVM: appVM, nutritionVM: nutritionVM)
    }

    private var allClosed: Bool {
        closedRings.count == RingType.allCases.count
    }

    private var dayWorkouts: [CompletedWorkoutRecord] {
        appVM.completedRecords.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    private var dayQuickStarts: [QuickStartRecord] {
        appVM.quickStartRecords.filter { calendar.isDate($0.startDate, inSameDayAs: date) }
    }

    private var dayCardio: [CardioSession] {
        appVM.cardioSessions.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    private var dayMeals: [MealEntry] {
        nutritionVM.mealsForDate(date)
    }

    private var dayNutrition: NutritionInfo {
        nutritionVM.nutritionForDate(date)
    }

    private var dayWater: Double {
        nutritionVM.waterForDate(date)
    }

    private var dayMood: MoodEntry? {
        ringsVM.moodForDate(date)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ringsHeroCard
                    if !dayWorkouts.isEmpty || !dayQuickStarts.isEmpty || !dayCardio.isEmpty {
                        fitnessSection
                    }
                    if !dayMeals.isEmpty {
                        mealsSection
                    }
                    moodSection
                    waterSection
                    pointsCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
            .background(KinexaTheme.background.ignoresSafeArea())
            .navigationTitle(dateTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(KinexaTheme.accent)
                }
            }
            .toolbarBackground(KinexaTheme.background, for: .navigationBar)
            
        }
    }

    private var dateTitle: String {
        let f = DateFormatter()
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        f.dateFormat = "EEE, MMM d"
        return f.string(from: date)
    }

    // MARK: - Rings Hero

    private var ringsHeroCard: some View {
        VStack(spacing: 16) {
            ZStack {
                ForEach(Array(RingType.allCases.enumerated()), id: \.element) { idx, ring in
                    let prog = ringsVM.progress(for: ring, on: date, appVM: appVM, nutritionVM: nutritionVM)
                    Circle()
                        .stroke(ring.color.opacity(0.14), lineWidth: 10)
                        .padding(CGFloat(idx) * 14)
                    Circle()
                        .trim(from: 0, to: max(0.001, prog))
                        .stroke(ring.color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .padding(CGFloat(idx) * 14)
                }
            }
            .frame(width: 180, height: 180)
            .padding(.vertical, 6)

            HStack(spacing: 10) {
                ForEach(RingType.allCases) { ring in
                    ringPill(ring)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 20))
        .elevatedCardShadow()
        .overlay { RoundedRectangle(cornerRadius: 20).stroke(KinexaTheme.border) }
    }

    private func ringPill(_ ring: RingType) -> some View {
        let prog = ringsVM.progress(for: ring, on: date, appVM: appVM, nutritionVM: nutritionVM)
        let closed = prog >= 1.0

        return VStack(spacing: 4) {
            Image(systemName: ring.icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(ring.color)
            Text("\(Int(prog * 100))%")
                .font(.caption2.weight(.heavy))
                .foregroundStyle(closed ? ring.color : KinexaTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(ring.color.opacity(closed ? 0.15 : 0.06))
        .clipShape(.rect(cornerRadius: 10))
    }

    // MARK: - Fitness

    private var fitnessSection: some View {
        sectionCard(title: "Fitness", icon: "figure.run", color: RingType.fitness.color) {
            VStack(spacing: 10) {
                ForEach(dayWorkouts) { w in
                    activityRow(icon: "dumbbell.fill", title: w.title, subtitle: "\(w.exerciseCount) exercise\(w.exerciseCount == 1 ? "" : "s")", color: KinexaTheme.accent)
                }
                ForEach(dayQuickStarts) { q in
                    activityRow(
                        icon: q.activity.icon,
                        title: q.activity.rawValue,
                        subtitle: q.formattedDuration + (q.activity.usesGPS ? " · \(String(format: "%.2f mi", q.distanceMiles))" : ""),
                        color: Color(hex: q.activity.gradientHex.0)
                    )
                }
                ForEach(dayCardio) { c in
                    activityRow(
                        icon: "heart.fill",
                        title: c.workoutName,
                        subtitle: "\(c.durationMinutes) min" + (c.caloriesBurned.map { " · \($0) cal" } ?? ""),
                        color: Color(hex: "#EC4899")
                    )
                }
            }
        }
    }

    private func activityRow(icon: String, title: String, subtitle: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(KinexaTheme.primaryText)
                Text(subtitle)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .background(KinexaTheme.cardSoft)
        .clipShape(.rect(cornerRadius: 12))
    }

    // MARK: - Meals

    private var mealsSection: some View {
        sectionCard(title: "Meals", icon: "fork.knife", color: RingType.meals.color) {
            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    macroPill(label: "Cal", value: "\(dayNutrition.calories)", color: KinexaTheme.accent)
                    macroPill(label: "P", value: "\(Int(dayNutrition.protein))g", color: Color(hex: "#3B82F6"))
                    macroPill(label: "C", value: "\(Int(dayNutrition.carbs))g", color: Color(hex: "#F59E0B"))
                    macroPill(label: "F", value: "\(Int(dayNutrition.fat))g", color: Color(hex: "#EC4899"))
                }

                ForEach(dayMeals) { meal in
                    activityRow(
                        icon: meal.mealType.icon,
                        title: meal.mealType.rawValue,
                        subtitle: "\(meal.foods.count) item\(meal.foods.count == 1 ? "" : "s") · \(meal.totalNutrition.calories) cal",
                        color: Color(hex: meal.mealType.color)
                    )
                }
            }
        }
    }

    private func macroPill(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundStyle(KinexaTheme.primaryText)
            Text(label)
                .font(.caption2.weight(.bold))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .clipShape(.rect(cornerRadius: 10))
    }

    // MARK: - Mood

    private var moodSection: some View {
        sectionCard(title: "Mood", icon: "face.smiling.fill", color: RingType.mood.color) {
            if let mood = dayMood {
                HStack(spacing: 14) {
                    Text(mood.level.emoji)
                        .font(.system(size: 40))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(mood.level.label)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(KinexaTheme.primaryText)
                        if !mood.note.isEmpty {
                            Text(mood.note)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(KinexaTheme.secondaryText)
                                .lineLimit(3)
                        } else {
                            Text("No note")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(KinexaTheme.tertiaryText)
                        }
                    }
                    Spacer(minLength: 0)
                }
            } else {
                Text("No mood check-in logged.")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(KinexaTheme.tertiaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    // MARK: - Water

    private var waterSection: some View {
        sectionCard(title: "Water", icon: "drop.fill", color: RingType.water.color) {
            let goal = nutritionVM.waterGoal.dailyOunces
            let progress = goal > 0 ? min(dayWater / goal, 1.0) : 0

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(Int(dayWater))")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundStyle(KinexaTheme.primaryText)
                    Text("/ \(Int(goal)) oz")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                    Spacer()
                    if dayWater >= goal && goal > 0 {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(RingType.water.color)
                    }
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(RingType.water.color.opacity(0.15))
                        Capsule()
                            .fill(RingType.water.color)
                            .frame(width: geo.size.width * CGFloat(progress))
                    }
                }
                .frame(height: 10)
            }
        }
    }

    // MARK: - Points

    private var pointsCard: some View {
        HStack(spacing: 14) {
            Image(systemName: allClosed ? "star.fill" : "star.circle.fill")
                .font(.title2.weight(.bold))
                .foregroundStyle(Color(hex: "#AF52DE"))
                .frame(width: 44, height: 44)
                .background(Color(hex: "#AF52DE").opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text("\(points) points")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)
                Text(allClosed ? "All rings closed · +\(RingType.allRingsBonus) bonus" : "\(closedRings.count) of \(RingType.allCases.count) rings closed")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 16))
        .elevatedCardShadow()
        .overlay { RoundedRectangle(cornerRadius: 16).stroke(KinexaTheme.border) }
    }

    // MARK: - Section helper

    private func sectionCard<Content: View>(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(color)
                    .frame(width: 28, height: 28)
                    .background(color.opacity(0.15))
                    .clipShape(Circle())
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)
                Spacer()
            }
            content()
        }
        .padding(16)
        .background(KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 20))
        .elevatedCardShadow()
        .overlay { RoundedRectangle(cornerRadius: 20).stroke(KinexaTheme.border) }
    }
}
