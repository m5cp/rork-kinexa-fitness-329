import SwiftUI
import Charts

struct ProgressViewScreen: View {
    @Environment(AppViewModel.self) private var vm

    @State private var appeared: Bool = false
    @State private var showCompletedWorkouts: Bool = false
    @State private var showDayWorkouts: Bool = false
    @State private var selectedDayRecord: CompletedWorkoutRecord?
    @State private var showDayDetail: Bool = false
    @State private var showTrainingCalendar: Bool = false


    var body: some View {
        ZStack {
            KinexaTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    topSummaryHeader
                    primaryMetricsRow
                    thisWeekHero
                    interactiveWeekStrip
                    localActivitySection
                    if !vm.quickStartRecords.isEmpty {
                        quickStartHistoryCard
                    }
                    weeklyFrequencyChart
                    AIInsightsCard()
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)

                    PerformanceHighlightsView(
                        highlights: vm.performanceHighlights,
                        showEmptyState: vm.performanceHighlights.isEmpty
                    )
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
                .padding(.bottom, 48)
                .adaptiveContainer()
            }
        }
        .navigationTitle("Progress")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(KinexaTheme.background, for: .navigationBar)
        
        .navigationDestination(isPresented: $showCompletedWorkouts) {
            CompletedWorkoutsListView()
        }
        .navigationDestination(isPresented: $showDayDetail) {
            if let record = selectedDayRecord {
                CompletedWorkoutDetailView(record: record)
            }
        }
        .navigationDestination(isPresented: $showTrainingCalendar) {
            TrainingCalendarView()
        }
        .onAppear {
            vm.pedometer.refreshTodaySteps()
            Task {
                try? await Task.sleep(for: .milliseconds(400))
                vm.syncTodaySteps()
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.05)) {
                appeared = true
            }
        }
    }

    // MARK: - Top Summary Header

    private var topSummaryHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text(todayDateString)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(KinexaTheme.secondaryText)
            }

            Spacer()

            if vm.streak > 0 {
                HStack(spacing: 5) {
                    Image(systemName: "flame.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(KinexaTheme.warning)
                    Text("\(vm.streak)")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)
                        .contentTransition(.numericText())
                    Text("day streak")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(KinexaTheme.warning.opacity(0.1))
                .clipShape(Capsule())
                .overlay {
                    Capsule().stroke(KinexaTheme.warning.opacity(0.2), lineWidth: 0.5)
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
    }

    private var todayDateString: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f.string(from: .now)
    }

    // MARK: - Primary Metrics Row

    private var primaryMetricsRow: some View {
        let todaySteps = vm.pedometer.todaySteps

        return HStack(spacing: 10) {
            primaryMetricCard(
                icon: "figure.walk",
                iconColor: KinexaTheme.success,
                value: todaySteps.formatted(),
                label: "Steps",
                sublabel: "Today"
            )

            primaryMetricCard(
                icon: "checkmark.seal.fill",
                iconColor: KinexaTheme.accent,
                value: "\(vm.totalWorkoutsCompleted)",
                label: "Workouts",
                sublabel: "Total"
            )

            primaryMetricCard(
                icon: "flame.fill",
                iconColor: Color(hex: "#FF6B35"),
                value: "\(vm.workoutsThisWeek)",
                label: "This Week",
                sublabel: "Sessions"
            )
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    private func primaryMetricCard(icon: String, iconColor: Color, value: String, label: String, sublabel: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(iconColor)
                .frame(width: 32, height: 32)
                .background(iconColor.opacity(0.12))
                .clipShape(Circle())

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(KinexaTheme.primaryText)
                .contentTransition(.numericText())
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            VStack(spacing: 1) {
                Text(label)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(KinexaTheme.secondaryText)
                Text(sublabel)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(KinexaTheme.border)
        }
        .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label), \(value) \(sublabel)")
    }

    // MARK: - This Week Hero

    private var thisWeekHero: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "target")
                    .foregroundStyle(KinexaTheme.accent)
                    .font(.subheadline.weight(.semibold))
                Text("This Week")
                    .font(.headline)
                    .foregroundStyle(KinexaTheme.primaryText)
                Spacer()
            }
            .padding(.bottom, 18)

            HStack(spacing: 0) {
                heroStat(
                    value: individualPTLabel,
                    label: "Strength",
                    icon: "dumbbell.fill",
                    color: KinexaTheme.accent
                )

                Rectangle()
                    .fill(KinexaTheme.border)
                    .frame(width: 1, height: 48)

                heroStat(
                    value: "\(vm.cardioSessionsThisWeek)",
                    label: "Cardio",
                    icon: "heart.fill",
                    color: Color(hex: "#EC4899")
                )

                Rectangle()
                    .fill(KinexaTheme.border)
                    .frame(width: 1, height: 48)

                heroStat(
                    value: "\(vm.totalWorkoutsCompleted)",
                    label: "Total",
                    icon: "checkmark.seal.fill",
                    color: KinexaTheme.success
                )
            }
        }
        .padding(20)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(KinexaTheme.card)
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [KinexaTheme.accent.opacity(0.06), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: 24)
                    .stroke(KinexaTheme.accent.opacity(0.15))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: KinexaTheme.accent.opacity(0.06), radius: 20, y: 10)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    private func heroStat(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(color)
                .frame(width: 30, height: 30)
                .background(color.opacity(0.12))
                .clipShape(Circle())

            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(KinexaTheme.primaryText)
                .contentTransition(.numericText())

            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(KinexaTheme.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }

    private var individualPTLabel: String {
        if let plan = vm.currentPlan {
            return "\(plan.completedCount)/\(plan.totalWorkoutDays)"
        }
        return "\(vm.workoutsThisWeek)"
    }

    // MARK: - Interactive 7-Day Strip

    private var interactiveWeekStrip: some View {
        Button {
            showTrainingCalendar = true
        } label: {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Training Week")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(KinexaTheme.secondaryText)

                    Spacer()

                    HStack(spacing: 4) {
                        Text("Calendar")
                            .font(.caption.weight(.semibold))
                        Image(systemName: "chevron.right")
                            .font(.caption2.weight(.bold))
                    }
                    .foregroundStyle(KinexaTheme.accent)
                }

                HStack(spacing: 5) {
                    ForEach(weekDates, id: \.self) { date in
                        let status = vm.calendarDateStatus(date)
                        let isToday = Calendar.current.isDateInToday(date)

                        VStack(spacing: 6) {
                            Text(dayAbbrev(date))
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(isToday ? KinexaTheme.accent : KinexaTheme.tertiaryText)

                            ZStack {
                                Circle()
                                    .fill(weekDotFill(status: status, isToday: isToday))
                                    .frame(width: 34, height: 34)

                                weekDotIcon(status: status, isToday: isToday)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(18)
            .premiumCard()
        }
        .buttonStyle(.plain)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    private var weekDates: [Date] {
        let cal = Calendar.current
        let start = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: .now)) ?? .now
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: start) }
    }

    private func weekDotFill(status: AppViewModel.CalendarWorkoutStatus?, isToday: Bool) -> Color {
        switch status {
        case .completed: return KinexaTheme.success
        case .planned: return isToday ? KinexaTheme.accent.opacity(0.25) : KinexaTheme.accent.opacity(0.15)
        case .missed: return KinexaTheme.tertiaryText.opacity(0.15)
        case nil: return isToday ? KinexaTheme.accent.opacity(0.12) : KinexaTheme.cardSoft
        }
    }

    @ViewBuilder
    private func weekDotIcon(status: AppViewModel.CalendarWorkoutStatus?, isToday: Bool) -> some View {
        switch status {
        case .completed:
            Image(systemName: "checkmark")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white)
        case .planned:
            Circle()
                .fill(KinexaTheme.accent)
                .frame(width: 6, height: 6)
        case .missed:
            Image(systemName: "minus")
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(KinexaTheme.tertiaryText)
        case nil:
            if isToday {
                Circle()
                    .fill(KinexaTheme.accent)
                    .frame(width: 6, height: 6)
            } else {
                EmptyView()
            }
        }
    }

    // MARK: - Activity Cards Section

    private var localActivitySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "figure.strengthtraining.traditional")
                    .foregroundStyle(KinexaTheme.accent)
                    .font(.subheadline.weight(.semibold))
                Text("Activity")
                    .font(.headline)
                    .foregroundStyle(KinexaTheme.primaryText)
                Spacer()
            }
            .padding(.horizontal, 4)

            HStack(spacing: 10) {
                localMetricTile(
                    icon: "figure.walk",
                    name: "Steps",
                    value: vm.pedometer.todaySteps.formatted(),
                    sublabel: "Today",
                    color: KinexaTheme.success
                )

                localMetricTile(
                    icon: "calendar",
                    name: "Streak",
                    value: "\(vm.streak)",
                    sublabel: vm.streak == 1 ? "day" : "days",
                    color: KinexaTheme.warning
                )
            }

            HStack(spacing: 10) {
                localMetricTile(
                    icon: "dumbbell.fill",
                    name: "Completed",
                    value: "\(vm.totalWorkoutsCompleted)",
                    sublabel: "All time",
                    color: KinexaTheme.slateAccent
                )

                localMetricTile(
                    icon: "chart.line.uptrend.xyaxis",
                    name: "Avg Steps",
                    value: vm.weeklyStepAverage.formatted(),
                    sublabel: "7-day avg",
                    color: KinexaTheme.accent
                )
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    private func localMetricTile(icon: String, name: String, value: String, sublabel: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(name)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(KinexaTheme.secondaryText)

                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(KinexaTheme.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .contentTransition(.numericText())

                Text(sublabel)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 100)
        .background(KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20).stroke(KinexaTheme.border)
        }
        .shadow(color: .black.opacity(0.12), radius: 10, y: 5)
    }

    // MARK: - Weekly Frequency Chart

    private var weeklyFrequencyChart: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(KinexaTheme.accent)
                    .font(.subheadline.weight(.semibold))
                Text("4-Week Training")
                    .font(.headline)
                    .foregroundStyle(KinexaTheme.primaryText)

                Spacer()

                let totalCompleted = last4WeeksData.reduce(0) { $0 + $1.count }
                if totalCompleted > 0 {
                    Text("\(totalCompleted) total")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }
            }

            let weekData = last4WeeksData

            if weekData.allSatisfy({ $0.count == 0 }) {
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 28))
                        .foregroundStyle(KinexaTheme.tertiaryText)

                    Text("No Training Data Yet")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(KinexaTheme.secondaryText)

                    Text("Complete workouts to see your training frequency.")
                        .font(.caption)
                        .foregroundStyle(KinexaTheme.tertiaryText)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            } else {
                Chart {
                    ForEach(weekData, id: \.label) { week in
                        BarMark(
                            x: .value("Week", week.label),
                            y: .value("Workouts", week.count)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [KinexaTheme.accent, KinexaTheme.accent.opacity(0.6)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                }
                .chartYAxis {
                    AxisMarks(values: .automatic(desiredCount: 4)) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(KinexaTheme.border)
                        AxisValueLabel()
                            .foregroundStyle(KinexaTheme.tertiaryText)
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel()
                            .foregroundStyle(KinexaTheme.secondaryText)
                    }
                }
                .frame(height: 150)

                Button {
                    showCompletedWorkouts = true
                } label: {
                    HStack(spacing: 6) {
                        Text("View Completed Workouts")
                            .font(.caption.weight(.semibold))
                        Image(systemName: "chevron.right")
                            .font(.caption2.weight(.bold))
                    }
                    .foregroundStyle(KinexaTheme.accent)
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(KinexaTheme.accent.opacity(0.08))
                    .clipShape(.rect(cornerRadius: 12))
                }
                .buttonStyle(PressScaleButtonStyle())
            }
        }
        .padding(20)
        .premiumCard()
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    private struct WeekFrequency {
        let label: String
        let count: Int
    }

    private var last4WeeksData: [WeekFrequency] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        return (0..<4).reversed().map { weeksAgo in
            let weekStart = calendar.date(byAdding: .weekOfYear, value: -weeksAgo, to: today).flatMap {
                calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: $0))
            } ?? today
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? today

            let count = vm.completedRecords.filter { $0.date >= weekStart && $0.date < weekEnd }.count

            let label: String
            if weeksAgo == 0 {
                label = "This"
            } else if weeksAgo == 1 {
                label = "Last"
            } else {
                label = "\(weeksAgo)w ago"
            }

            return WeekFrequency(label: label, count: count)
        }
    }



    // MARK: - Quick Start History

    private var quickStartHistoryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "bolt.fill")
                    .foregroundStyle(Color(hex: "#059669"))
                    .font(.subheadline.weight(.semibold))
                Text("Quick Start")
                    .font(.headline)
                    .foregroundStyle(KinexaTheme.primaryText)

                Spacer()

                Text("\(vm.quickStartRecords.count) sessions")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }

            ForEach(vm.quickStartRecords.prefix(5)) { record in
                quickStartRow(record)
            }

            if vm.quickStartRecords.count > 5 {
                Text("\(vm.quickStartRecords.count - 5) more sessions")
                    .font(.caption)
                    .foregroundStyle(KinexaTheme.tertiaryText)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(20)
        .premiumCard()
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    private func quickStartRow(_ record: QuickStartRecord) -> some View {
        HStack(spacing: 12) {
            Image(systemName: record.activity.icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color(hex: record.activity.gradientHex.0))
                .frame(width: 32, height: 32)
                .background(Color(hex: record.activity.gradientHex.0).opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(record.activity.rawValue)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(KinexaTheme.primaryText)
                Text(quickStartDateString(record.startDate))
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(record.formattedDuration)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)
                if record.activity.usesGPS {
                    Text(record.formattedDistance)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }
            }
        }
        .padding(12)
        .background(KinexaTheme.cardSoft)
        .clipShape(.rect(cornerRadius: 14))
    }

    private func quickStartDateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d, h:mm a"
        return f.string(from: date)
    }

    // MARK: - Helpers

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let totalMinutes = Int(seconds) / 60
        if totalMinutes == 0 { return "0m" }
        if totalMinutes < 60 { return "\(totalMinutes)m" }
        let hours = totalMinutes / 60
        let mins = totalMinutes % 60
        return "\(hours)h \(mins)m"
    }

    private func dayAbbrev(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return String(formatter.string(from: date).prefix(2)).uppercased()
    }
}
