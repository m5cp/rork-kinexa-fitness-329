import SwiftUI

struct RingsDetailView: View {
    @Environment(AppViewModel.self) private var appVM
    let nutritionVM: NutritionViewModel
    let ringsVM: ReflectionRingsViewModel

    var onTapRing: (RingType) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var showHistory: Bool = false

    private var today: Date { Calendar.current.startOfDay(for: .now) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    summaryCard
                    ringsList
                    historyCard
                    viewAllHistoryButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
            .background(KinexaTheme.background.ignoresSafeArea())
            .navigationTitle("Reflection Rings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(KinexaTheme.accent)
                }
            }
            .toolbarBackground(KinexaTheme.background, for: .navigationBar)
            
            .sheet(isPresented: $showHistory) {
                RingsHistoryCalendarView(nutritionVM: nutritionVM, ringsVM: ringsVM)
                    .environment(appVM)
            }
        }
    }

    private var viewAllHistoryButton: some View {
        Button {
            showHistory = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "calendar")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(KinexaTheme.accent)
                    .frame(width: 44, height: 44)
                    .background(KinexaTheme.accent.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 2) {
                    Text("View All History")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)
                    Text("Browse every day and see your streak")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }
            .padding(14)
            .background(KinexaTheme.card)
            .clipShape(.rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16).stroke(KinexaTheme.border)
            }
        }
        .buttonStyle(.plain)
    }

    private var summaryCard: some View {
        let pts = ringsVM.pointsEarned(on: today, appVM: appVM, nutritionVM: nutritionVM)
        let streak = ringsVM.currentStreak(appVM: appVM, nutritionVM: nutritionVM)
        let total = ringsVM.totalPoints(appVM: appVM, nutritionVM: nutritionVM)

        return HStack(spacing: 12) {
            summaryPill(value: "\(pts)", label: "Today", color: KinexaTheme.accent)
            summaryPill(value: "\(streak)", label: "Streak", color: Color.orange)
            summaryPill(value: "\(total)", label: "Total", color: Color(hex: "#AF52DE"))
        }
    }

    private func summaryPill(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundStyle(KinexaTheme.primaryText)
            Text(label.uppercased())
                .font(.caption2.weight(.heavy))
                .tracking(1.0)
                .foregroundStyle(KinexaTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16).stroke(color.opacity(0.25))
        }
    }

    private var ringsList: some View {
        VStack(spacing: 10) {
            ForEach(RingType.allCases) { ring in
                ringRow(ring)
            }
        }
    }

    private func ringRow(_ ring: RingType) -> some View {
        let progress = ringsVM.progress(for: ring, on: today, appVM: appVM, nutritionVM: nutritionVM)
        let closed = progress >= 1.0

        return Button {
            onTapRing(ring)
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(ring.color.opacity(0.18), lineWidth: 5)
                    Circle()
                        .trim(from: 0, to: max(0.001, progress))
                        .stroke(ring.color, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Image(systemName: ring.icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(ring.color)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text(ring.title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)
                    Text(closed ? "Closed · +\(RingType.pointsPerRing) pts" : ring.subtitle)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(closed ? ring.color : KinexaTheme.secondaryText)
                }

                Spacer(minLength: 0)

                if closed {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(ring.color)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }
            }
            .padding(14)
            .background(KinexaTheme.card)
            .clipShape(.rect(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14).stroke(KinexaTheme.border)
            }
        }
        .buttonStyle(.plain)
    }

    private var historyCard: some View {
        let history = ringsVM.last7Days(appVM: appVM, nutritionVM: nutritionVM)

        return VStack(alignment: .leading, spacing: 12) {
            Text("LAST 7 DAYS")
                .font(.caption.weight(.heavy))
                .tracking(1.2)
                .foregroundStyle(KinexaTheme.tertiaryText)

            HStack(spacing: 8) {
                ForEach(history, id: \.date) { day in
                    VStack(spacing: 8) {
                        Text(dayLabel(day.date))
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(KinexaTheme.tertiaryText)

                        ZStack {
                            ForEach(Array(RingType.allCases.enumerated()), id: \.element) { index, ring in
                                let closed = day.closed.contains(ring)
                                Circle()
                                    .stroke(ring.color.opacity(closed ? 1.0 : 0.15), lineWidth: 3)
                                    .padding(CGFloat(index) * 4)
                            }
                        }
                        .frame(width: 38, height: 38)

                        Text("\(day.points)")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(KinexaTheme.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(14)
        .background(KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16).stroke(KinexaTheme.border)
        }
    }

    private func dayLabel(_ date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return "Today" }
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f.string(from: date).uppercased()
    }

}
