import SwiftUI

struct NutritionHistoryView: View {
    let nutritionVM: NutritionViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                weeklyCalorieChart
                weeklyMacroBreakdown
                streakCard
                dailyBreakdownList
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 48)
        }
        .background(KinexaTheme.background.ignoresSafeArea())
        .navigationTitle("Weekly Overview")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var weeklyCalorieChart: some View {
        let data = nutritionVM.weeklyCalories()
        let maxCal = max(Double(data.map(\.calories).max() ?? 1), Double(nutritionVM.dailyGoal.calories))

        return VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.fill")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(KinexaTheme.success)
                Text("Calorie Trend")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)
                Spacer()
                let avg = data.isEmpty ? 0 : data.map(\.calories).reduce(0, +) / data.count
                Text("Avg \(avg) cal")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(data.enumerated()), id: \.offset) { _, item in
                    VStack(spacing: 6) {
                        Text("\(item.calories)")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(KinexaTheme.tertiaryText)

                        let height = maxCal > 0 ? CGFloat(Double(item.calories) / maxCal) * 100 : 0
                        let isOverGoal = item.calories > nutritionVM.dailyGoal.calories

                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: isOverGoal ? [KinexaTheme.warning, KinexaTheme.warning.opacity(0.6)] : [KinexaTheme.success, KinexaTheme.success.opacity(0.6)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: max(4, height))

                        Text(dayAbbrev(item.date))
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Calendar.current.isDateInToday(item.date) ? KinexaTheme.success : KinexaTheme.tertiaryText)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 140)

            HStack(spacing: 8) {
                Circle().fill(KinexaTheme.success).frame(width: 6, height: 6)
                Text("Under goal")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(KinexaTheme.tertiaryText)
                Circle().fill(KinexaTheme.warning).frame(width: 6, height: 6)
                Text("Over goal")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(KinexaTheme.tertiaryText)
                Spacer()
                Rectangle()
                    .fill(KinexaTheme.tertiaryText.opacity(0.4))
                    .frame(width: 20, height: 1)
                Text("Goal: \(nutritionVM.dailyGoal.calories)")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }
        }
        .padding(18)
        .background(KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 20))
        .elevatedCardShadow()
        .overlay {
            RoundedRectangle(cornerRadius: 20).stroke(KinexaTheme.border)
        }
    }

    private var weeklyMacroBreakdown: some View {
        let data = nutritionVM.weeklyMacros()
        let totalP = data.map(\.protein).reduce(0, +)
        let totalC = data.map(\.carbs).reduce(0, +)
        let totalF = data.map(\.fat).reduce(0, +)
        let count = max(1, Double(data.count))

        return VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "chart.pie.fill")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color(hex: "#6366F1"))
                Text("Weekly Macros")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)
                Spacer()
                Text("7-day average")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }

            HStack(spacing: 16) {
                macroAvgColumn("Protein", avg: totalP / count, goal: nutritionVM.dailyGoal.protein, color: Color(hex: "#3B82F6"))
                macroAvgColumn("Carbs", avg: totalC / count, goal: nutritionVM.dailyGoal.carbs, color: Color(hex: "#F59E0B"))
                macroAvgColumn("Fat", avg: totalF / count, goal: nutritionVM.dailyGoal.fat, color: Color(hex: "#EC4899"))
            }
        }
        .padding(18)
        .background(KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 20))
        .elevatedCardShadow()
        .overlay {
            RoundedRectangle(cornerRadius: 20).stroke(KinexaTheme.border)
        }
    }

    private func macroAvgColumn(_ label: String, avg: Double, goal: Double, color: Color) -> some View {
        let progress = goal > 0 ? min(avg / goal, 1.0) : 0

        return VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: 6)
                    .frame(width: 50, height: 50)
                Circle()
                    .trim(from: 0, to: progress)
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
            Text("\(Int(avg))g avg")
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(KinexaTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private var streakCard: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(hex: "#F59E0B").opacity(0.15))
                    .frame(width: 50, height: 50)
                Image(systemName: "flame.fill")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color(hex: "#F59E0B"))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Logging Streak")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)
                Text(nutritionVM.loggingStreak == 0 ? "Log a meal to start your streak" : "\(nutritionVM.loggingStreak) day\(nutritionVM.loggingStreak == 1 ? "" : "s") in a row")
                    .font(.caption)
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }

            Spacer()

            if nutritionVM.loggingStreak > 0 {
                Text("\(nutritionVM.loggingStreak)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "#F59E0B"))
            }
        }
        .padding(16)
        .background(KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 18))
        .elevatedCardShadow()
        .overlay {
            RoundedRectangle(cornerRadius: 18).stroke(KinexaTheme.border)
        }
    }

    private var dailyBreakdownList: some View {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let days: [Date] = (0..<7).reversed().compactMap { calendar.date(byAdding: .day, value: -$0, to: today) }

        return VStack(alignment: .leading, spacing: 14) {
            Text("Daily Breakdown")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(KinexaTheme.secondaryText)

            ForEach(days, id: \.timeIntervalSince1970) { date in
                let n = nutritionVM.nutritionForDate(date)
                let mealCount = nutritionVM.mealsForDate(date).count
                let water = nutritionVM.waterForDate(date)
                let isToday = calendar.isDateInToday(date)

                HStack(spacing: 12) {
                    VStack(spacing: 2) {
                        Text(dayAbbrev(date))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(isToday ? KinexaTheme.success : KinexaTheme.tertiaryText)
                        Text("\(calendar.component(.day, from: date))")
                            .font(.subheadline.weight(isToday ? .bold : .semibold))
                            .foregroundStyle(isToday ? KinexaTheme.primaryText : KinexaTheme.secondaryText)
                    }
                    .frame(width: 36)

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text("\(n.calories) cal")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(KinexaTheme.primaryText)
                            if mealCount > 0 {
                                Text("\(mealCount) meal\(mealCount == 1 ? "" : "s")")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(KinexaTheme.tertiaryText)
                            }
                        }
                        HStack(spacing: 8) {
                            Text("P:\(Int(n.protein))g")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(Color(hex: "#3B82F6"))
                            Text("C:\(Int(n.carbs))g")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(Color(hex: "#F59E0B"))
                            Text("F:\(Int(n.fat))g")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(Color(hex: "#EC4899"))
                            if water > 0 {
                                HStack(spacing: 2) {
                                    Image(systemName: "drop.fill")
                                        .font(.system(size: 7))
                                    Text("\(Int(water))oz")
                                }
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(Color(hex: "#38BDF8"))
                            }
                        }
                    }

                    Spacer()

                    let progress = nutritionVM.dailyGoal.calories > 0 ? min(Double(n.calories) / Double(nutritionVM.dailyGoal.calories), 1.0) : 0
                    CircularProgressView(progress: progress, size: 28, lineWidth: 3, color: n.calories > nutritionVM.dailyGoal.calories ? KinexaTheme.warning : KinexaTheme.success)
                }
                .padding(12)
                .background(isToday ? KinexaTheme.accent.opacity(0.06) : KinexaTheme.card)
                .clipShape(.rect(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isToday ? KinexaTheme.accent.opacity(0.2) : KinexaTheme.border)
                }
            }
        }
    }

    private func dayAbbrev(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }
}

struct CircularProgressView: View {
    let progress: Double
    let size: CGFloat
    let lineWidth: CGFloat
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.15), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: size, height: size)
    }
}
