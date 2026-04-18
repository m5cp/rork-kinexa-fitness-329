import SwiftUI

struct ActivityJournalView: View {
    @Environment(AppViewModel.self) private var vm
    @State private var nutritionVM = NutritionViewModel()

    @State private var displayedMonth: Date = Calendar.current.startOfDay(for: .now)
    @State private var selectedDate: Date = Calendar.current.startOfDay(for: .now)
    @State private var navigateToDay: Bool = false

    private let calendar = Calendar.current
    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        ZStack {
            KinexaTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    summaryStrip
                    calendarCard
                    selectedDayCard
                    recentActivityList
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 48)
                .adaptiveContainer()
            }
        }
        .navigationTitle("Activity Journal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(KinexaTheme.background, for: .navigationBar)
        
        .navigationDestination(isPresented: $navigateToDay) {
            JournalDayDetailView(date: selectedDate)
        }
    }

    // MARK: - Summary Strip

    private var summaryStrip: some View {
        HStack(spacing: 0) {
            journalStat(value: "\(vm.totalWorkoutsCompleted)", label: "Total", icon: "figure.mixed.cardio")
            journalDivider
            journalStat(value: "\(vm.streak)", label: "Streak", icon: "flame.fill")
            journalDivider
            journalStat(value: "\(nutritionVM.loggingStreak)", label: "Meals", icon: "fork.knife")
            journalDivider
            journalStat(value: "\(vm.pedometer.todaySteps)", label: "Steps", icon: "shoeprints.fill")
        }
        .padding(.vertical, 16)
        .premiumCard()
    }

    private func journalStat(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(KinexaTheme.accent)
            Text(value)
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundStyle(KinexaTheme.primaryText)
                .contentTransition(.numericText())
            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(KinexaTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private var journalDivider: some View {
        Rectangle()
            .fill(KinexaTheme.border)
            .frame(width: 1, height: 36)
    }

    // MARK: - Calendar

    private var calendarCard: some View {
        VStack(spacing: 14) {
            HStack {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(KinexaTheme.secondaryText)
                        .frame(width: 32, height: 32)
                        .background(KinexaTheme.cardSoft)
                        .clipShape(Circle())
                }

                Spacer()

                Text(monthLabel)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(KinexaTheme.secondaryText)
                        .frame(width: 32, height: 32)
                        .background(KinexaTheme.cardSoft)
                        .clipShape(Circle())
                }
            }

            HStack(spacing: 0) {
                ForEach(weekdays, id: \.self) { d in
                    Text(d)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                        .frame(maxWidth: .infinity)
                }
            }

            let dates = monthDates
            let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(dates, id: \.self) { date in
                    if let date {
                        calendarDayCell(date)
                    } else {
                        Color.clear.frame(height: 40)
                    }
                }
            }

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    let today = calendar.startOfDay(for: .now)
                    displayedMonth = today
                    selectedDate = today
                }
            } label: {
                Text("Today")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(KinexaTheme.accent)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(KinexaTheme.accent.opacity(0.12))
                    .clipShape(Capsule())
            }
        }
        .padding(16)
        .premiumCard()
    }

    private func calendarDayCell(_ date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let isCurrentMonth = calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month)
        let hasActivity = dayHasActivity(date)
        let hasMeals = !nutritionVM.mealsForDate(date).isEmpty

        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                selectedDate = date
            }
        } label: {
            VStack(spacing: 3) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 13, weight: isSelected || isToday ? .bold : .medium))
                    .foregroundStyle(
                        isSelected ? .white :
                        !isCurrentMonth ? KinexaTheme.tertiaryText.opacity(0.3) :
                        isToday ? KinexaTheme.accent :
                        KinexaTheme.primaryText
                    )

                HStack(spacing: 3) {
                    if hasActivity {
                        Circle()
                            .fill(isSelected ? .white : KinexaTheme.success)
                            .frame(width: 4, height: 4)
                    }
                    if hasMeals {
                        Circle()
                            .fill(isSelected ? .white.opacity(0.7) : Color(hex: "#F59E0B"))
                            .frame(width: 4, height: 4)
                    }
                    if !hasActivity && !hasMeals {
                        Color.clear.frame(width: 4, height: 4)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(KinexaTheme.heroGradient)
                }
            }
        }
    }

    // MARK: - Selected Day Card

    private var selectedDayCard: some View {
        let workouts = vm.completedRecordsForDate(selectedDate)
        let meals = nutritionVM.mealsForDate(selectedDate)
        let nutrition = nutritionVM.nutritionForDate(selectedDate)
        let cardio = vm.cardioSessions.filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
        let steps = stepsForDate(selectedDate)

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(selectedDateLabel)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)
                    Text(selectedRelative)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }

                Spacer()

                Button {
                    navigateToDay = true
                } label: {
                    HStack(spacing: 4) {
                        Text("View Details")
                            .font(.caption.weight(.semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 9, weight: .bold))
                    }
                    .foregroundStyle(KinexaTheme.accent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(KinexaTheme.accent.opacity(0.12))
                    .clipShape(Capsule())
                }
            }

            HStack(spacing: 0) {
                miniStat(icon: "figure.mixed.cardio", value: "\(workouts.count + cardio.count)", label: "Workouts", color: KinexaTheme.success)
                miniDivider
                miniStat(icon: "flame.fill", value: "\(nutrition.calories)", label: "Calories", color: Color(hex: "#F59E0B"))
                miniDivider
                miniStat(icon: "fork.knife", value: "\(meals.count)", label: "Meals", color: Color(hex: "#6366F1"))
                miniDivider
                miniStat(icon: "shoeprints.fill", value: "\(steps)", label: "Steps", color: KinexaTheme.accent)
            }
            .padding(.vertical, 10)
            .background(KinexaTheme.cardSoft)
            .clipShape(.rect(cornerRadius: 12))

            if workouts.isEmpty && meals.isEmpty && cardio.isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.title3)
                        .foregroundStyle(KinexaTheme.tertiaryText.opacity(0.5))
                    Text("No activity logged for this day")
                        .font(.subheadline)
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
        }
        .padding(16)
        .premiumCard()
    }

    private func miniStat(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(KinexaTheme.primaryText)
                .contentTransition(.numericText())
            Text(label)
                .font(.system(size: 8, weight: .semibold))
                .foregroundStyle(KinexaTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private var miniDivider: some View {
        Rectangle()
            .fill(KinexaTheme.border)
            .frame(width: 1, height: 28)
    }

    // MARK: - Recent Activity

    private var recentActivityList: some View {
        let recentDates = recentActiveDates(limit: 10)

        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(KinexaTheme.tertiaryText)
                Text("RECENT ACTIVITY")
                    .font(.caption.weight(.bold))
                    .tracking(0.8)
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }
            .padding(.horizontal, 4)

            if recentDates.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.title2)
                        .foregroundStyle(KinexaTheme.tertiaryText.opacity(0.4))
                    Text("No recent activity")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .premiumCard()
            } else {
                ForEach(recentDates, id: \.timeIntervalSince1970) { date in
                    Button {
                        selectedDate = date
                        navigateToDay = true
                    } label: {
                        recentDayRow(date)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func recentDayRow(_ date: Date) -> some View {
        let workouts = vm.completedRecordsForDate(date)
        let cardio = vm.cardioSessions.filter { calendar.isDate($0.date, inSameDayAs: date) }
        let meals = nutritionVM.mealsForDate(date)
        let nutrition = nutritionVM.nutritionForDate(date)
        let totalWorkouts = workouts.count + cardio.count

        return HStack(spacing: 14) {
            VStack(spacing: 2) {
                Text(dayAbbrev(date))
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(calendar.isDateInToday(date) ? KinexaTheme.accent : KinexaTheme.tertiaryText)
                Text("\(calendar.component(.day, from: date))")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(calendar.isDateInToday(date) ? KinexaTheme.primaryText : KinexaTheme.secondaryText)
            }
            .frame(width: 36)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    if totalWorkouts > 0 {
                        Label("\(totalWorkouts) workout\(totalWorkouts == 1 ? "" : "s")", systemImage: "figure.mixed.cardio")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(KinexaTheme.success)
                    }
                    if !meals.isEmpty {
                        Label("\(meals.count) meal\(meals.count == 1 ? "" : "s")", systemImage: "fork.knife")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color(hex: "#F59E0B"))
                    }
                }

                HStack(spacing: 10) {
                    if nutrition.calories > 0 {
                        Text("\(nutrition.calories) cal")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(KinexaTheme.tertiaryText)
                    }
                    if nutrition.protein > 0 {
                        Text("P:\(Int(nutrition.protein))g")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color(hex: "#3B82F6"))
                    }
                }
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.caption2.weight(.bold))
                .foregroundStyle(KinexaTheme.tertiaryText)
        }
        .padding(14)
        .background(calendar.isDateInToday(date) ? KinexaTheme.accent.opacity(0.06) : KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(calendar.isDateInToday(date) ? KinexaTheme.accent.opacity(0.2) : KinexaTheme.border)
        }
    }

    // MARK: - Helpers

    private func dayHasActivity(_ date: Date) -> Bool {
        !vm.completedRecordsForDate(date).isEmpty ||
        vm.cardioSessions.contains { calendar.isDate($0.date, inSameDayAs: date) } ||
        vm.quickStartRecords.contains { calendar.isDate($0.startDate, inSameDayAs: date) }
    }

    private func stepsForDate(_ date: Date) -> Int {
        if calendar.isDateInToday(date) { return vm.pedometer.todaySteps }
        return vm.stepHistory.first { calendar.isDate($0.date, inSameDayAs: date) }?.steps ?? 0
    }

    private func recentActiveDates(limit: Int) -> [Date] {
        var dates: Set<Date> = []

        for record in vm.completedRecords {
            dates.insert(calendar.startOfDay(for: record.date))
        }
        for session in vm.cardioSessions {
            dates.insert(calendar.startOfDay(for: session.date))
        }
        for meal in nutritionVM.meals {
            dates.insert(calendar.startOfDay(for: meal.date))
        }
        for qs in vm.quickStartRecords {
            dates.insert(calendar.startOfDay(for: qs.startDate))
        }

        return Array(dates.sorted(by: >).prefix(limit))
    }

    private var monthLabel: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: displayedMonth)
    }

    private var selectedDateLabel: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f.string(from: selectedDate)
    }

    private var selectedRelative: String {
        if calendar.isDateInToday(selectedDate) { return "Today" }
        if calendar.isDateInYesterday(selectedDate) { return "Yesterday" }
        if calendar.isDateInTomorrow(selectedDate) { return "Tomorrow" }
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: .now), to: calendar.startOfDay(for: selectedDate)).day ?? 0
        if days > 0 { return "In \(days) day\(days == 1 ? "" : "s")" }
        return "\(abs(days)) day\(abs(days) == 1 ? "" : "s") ago"
    }

    private var monthDates: [Date?] {
        let comps = calendar.dateComponents([.year, .month], from: displayedMonth)
        guard let firstOfMonth = calendar.date(from: comps),
              let range = calendar.range(of: .day, in: .month, for: firstOfMonth) else { return [] }
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let leadingEmpty = firstWeekday - 1
        var dates: [Date?] = Array(repeating: nil, count: leadingEmpty)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                dates.append(date)
            }
        }
        let trailing = (7 - (dates.count % 7)) % 7
        dates += Array(repeating: nil as Date?, count: trailing)
        return dates
    }

    private func dayAbbrev(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f.string(from: date).uppercased()
    }
}
