import SwiftUI

struct RingsHistoryCalendarView: View {
    @Environment(AppViewModel.self) private var appVM
    @Environment(\.dismiss) private var dismiss
    let nutritionVM: NutritionViewModel
    let ringsVM: ReflectionRingsViewModel

    @State private var selectedDate: Date?

    private let calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.firstWeekday = 2 // Monday
        return c
    }()

    private var today: Date { calendar.startOfDay(for: .now) }

    private var earliestDate: Date {
        var candidates: [Date] = []
        if let d = appVM.completedRecords.map({ $0.date }).min() { candidates.append(d) }
        if let d = appVM.quickStartRecords.map({ $0.startDate }).min() { candidates.append(d) }
        if let d = appVM.cardioSessions.map({ $0.date }).min() { candidates.append(d) }
        if let d = nutritionVM.meals.map({ $0.date }).min() { candidates.append(d) }
        if let d = nutritionVM.waterEntries.map({ $0.date }).min() { candidates.append(d) }
        if let d = ringsVM.sleepEntries.map({ $0.date }).min() { candidates.append(d) }
        let earliest = candidates.min() ?? calendar.date(byAdding: .day, value: -30, to: today) ?? today
        return calendar.startOfDay(for: earliest)
    }

    private var months: [Date] {
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: earliestDate)) ?? earliestDate
        let end = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) ?? today
        var result: [Date] = []
        var d = start
        while d <= end {
            result.append(d)
            guard let next = calendar.date(byAdding: .month, value: 1, to: d) else { break }
            d = next
        }
        return result
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 28, pinnedViews: []) {
                        streakHeader
                        ForEach(months, id: \.self) { month in
                            monthSection(month)
                                .id(monthID(month))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
                .background(KinexaTheme.background.ignoresSafeArea())
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        withAnimation(.easeOut(duration: 0.4)) {
                            proxy.scrollTo(monthID(today), anchor: .bottom)
                        }
                    }
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(KinexaTheme.accent)
                }
            }
            .toolbarBackground(KinexaTheme.background, for: .navigationBar)
            
            .sheet(item: Binding(
                get: { selectedDate.map { IdentifiableDate(date: $0) } },
                set: { selectedDate = $0?.date }
            )) { wrapper in
                RingDayDetailSheet(
                    date: wrapper.date,
                    nutritionVM: nutritionVM,
                    ringsVM: ringsVM
                )
                .environment(appVM)
                .presentationDetents([.large])
            }
        }
    }

    private func monthID(_ date: Date) -> String {
        let comps = calendar.dateComponents([.year, .month], from: date)
        return "\(comps.year ?? 0)-\(comps.month ?? 0)"
    }

    // MARK: - Streak Header

    private var streakHeader: some View {
        let streak = ringsVM.currentStreak(appVM: appVM, nutritionVM: nutritionVM)
        let totalPts = ringsVM.totalPoints(appVM: appVM, nutritionVM: nutritionVM)

        return HStack(spacing: 12) {
            statBlock(icon: "flame.fill", color: .orange, value: "\(streak)", label: streak == 1 ? "Day streak" : "Day streak")
            statBlock(icon: "star.fill", color: Color(hex: "#AF52DE"), value: "\(totalPts)", label: "Total points")
        }
    }

    private func statBlock(icon: String, color: Color, value: String, label: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(color)
                .frame(width: 34, height: 34)
                .background(color.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundStyle(KinexaTheme.primaryText)
                Text(label)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 16))
        .elevatedCardShadow()
        .overlay { RoundedRectangle(cornerRadius: 16).stroke(KinexaTheme.border) }
    }

    // MARK: - Month Section

    private func monthSection(_ month: Date) -> some View {
        let days = daysInMonth(month)
        let leading = leadingEmpty(for: month)

        return VStack(alignment: .leading, spacing: 14) {
            Text(monthTitle(month))
                .font(.title3.weight(.bold))
                .foregroundStyle(KinexaTheme.primaryText)
                .padding(.horizontal, 4)

            HStack(spacing: 0) {
                ForEach(weekdaySymbols, id: \.self) { sym in
                    Text(sym)
                        .font(.caption2.weight(.heavy))
                        .tracking(0.6)
                        .foregroundStyle(KinexaTheme.tertiaryText)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 10) {
                ForEach(0..<leading, id: \.self) { _ in
                    Color.clear.frame(height: 54)
                }
                ForEach(days, id: \.self) { date in
                    dayCell(date)
                }
            }
        }
    }

    private func dayCell(_ date: Date) -> some View {
        let isFuture = date > today
        let isToday = calendar.isDate(date, inSameDayAs: today)
        let closed: Set<RingType> = isFuture ? [] : ringsVM.closedRings(on: date, appVM: appVM, nutritionVM: nutritionVM)

        return Button {
            guard !isFuture else { return }
            selectedDate = date
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    ForEach(Array(RingType.allCases.enumerated()), id: \.element) { idx, ring in
                        let isClosed = closed.contains(ring)
                        Circle()
                            .stroke(ring.color.opacity(isFuture ? 0.08 : (isClosed ? 1.0 : 0.18)), lineWidth: 3)
                            .padding(CGFloat(idx) * 3.5)
                    }
                }
                .frame(width: 38, height: 38)
                .opacity(isFuture ? 0.35 : 1)

                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 11, weight: isToday ? .heavy : .semibold, design: .rounded))
                    .foregroundStyle(isFuture ? KinexaTheme.tertiaryText.opacity(0.5) :
                                    (isToday ? KinexaTheme.accent : KinexaTheme.secondaryText))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isToday ? KinexaTheme.accent.opacity(0.08) : .clear)
            )
        }
        .buttonStyle(.plain)
        .disabled(isFuture)
    }

    // MARK: - Date helpers

    private var weekdaySymbols: [String] {
        ["M", "T", "W", "T", "F", "S", "S"]
    }

    private func daysInMonth(_ month: Date) -> [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: month),
              let first = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else {
            return []
        }
        return range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: first)
        }
    }

    private func leadingEmpty(for month: Date) -> Int {
        guard let first = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else { return 0 }
        let weekday = calendar.component(.weekday, from: first) // 1=Sun..7=Sat
        // firstWeekday = 2 (Mon). Convert: Mon=0, Tue=1, ... Sun=6
        let offset = (weekday - calendar.firstWeekday + 7) % 7
        return offset
    }

    private func monthTitle(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: date)
    }
}

private struct IdentifiableDate: Identifiable {
    let date: Date
    var id: TimeInterval { date.timeIntervalSince1970 }
}
