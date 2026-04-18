import SwiftUI

struct PreMadeCardioProgramDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let program: PreMadeCardioProgram

    @State private var expandedDay: UUID?


    var body: some View {
        NavigationStack {
            ZStack {
                KinexaTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        headerCard
                        statsRow
                        daysSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 48)
                }
            }
            .navigationTitle(program.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(KinexaTheme.primaryText)
                }
            }
            .toolbarBackground(KinexaTheme.background, for: .navigationBar)
            

        }
    }

    private var accentColor: Color {
        Color(hex: program.programType.gradientHex.0)
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                Image(systemName: program.programType.icon)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: program.programType.gradientHex.0), Color(hex: program.programType.gradientHex.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(.rect(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 4) {
                    Text(program.name)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)

                    HStack(spacing: 6) {
                        tagBadge(text: program.level.rawValue, color: levelColor(program.level))
                        tagBadge(text: program.goal.rawValue, color: Color(hex: "#8B5CF6"))
                    }
                }

                Spacer(minLength: 0)
            }

            Text(program.programDescription)
                .font(.caption.weight(.medium))
                .foregroundStyle(KinexaTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18).stroke(KinexaTheme.border)
        }
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            statBlock(value: "\(program.daysPerWeek)", label: "Days/Week", icon: "calendar")
            statBlock(value: "\(program.durationWeeks)", label: "Weeks", icon: "clock.fill")
            statBlock(value: program.equipment, label: "Equipment", icon: "figure.strengthtraining.functional")
        }
    }

    private func statBlock(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(accentColor)

            Text(value)
                .font(.caption.weight(.bold))
                .foregroundStyle(KinexaTheme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(KinexaTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12).stroke(KinexaTheme.border)
        }
    }

    private var daysSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("WORKOUT DAYS")
                .font(.caption.weight(.heavy))
                .tracking(1.2)
                .foregroundStyle(KinexaTheme.tertiaryText)
                .padding(.leading, 4)

            ForEach(program.days) { day in
                dayCard(day)
            }
        }
    }

    private func dayCard(_ day: CardioProgramDay) -> some View {
        let isExpanded = expandedDay == day.id

        return VStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    expandedDay = isExpanded ? nil : day.id
                }
            } label: {
                HStack(spacing: 12) {
                    Text(day.dayName)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)

                    Text(day.focus)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(accentColor)

                    Spacer(minLength: 0)

                    Text("\(day.steps.count) steps")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(KinexaTheme.tertiaryText)

                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(14)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 6) {
                    ForEach(day.steps) { step in
                        stepRow(step)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14).stroke(KinexaTheme.border)
        }
    }

    private func stepRow(_ step: CardioSessionStep) -> some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                Text(step.name)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(KinexaTheme.primaryText)

                HStack(spacing: 6) {
                    if !step.duration.isEmpty {
                        Text(step.duration)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(accentColor)
                    }
                    if !step.intensity.isEmpty {
                        Text(step.intensity)
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(KinexaTheme.tertiaryText)
                    }
                }

                if !step.notes.isEmpty {
                    Text(step.notes)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(KinexaTheme.secondaryText)
                        .italic()
                }
            }

            Spacer(minLength: 0)
        }
        .padding(10)
        .background(KinexaTheme.background.opacity(0.5))
        .clipShape(.rect(cornerRadius: 10))
    }

    private func tagBadge(text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .clipShape(.capsule)
    }

    private func levelColor(_ level: CardioProgramLevel) -> Color {
        switch level {
        case .beginner: return KinexaTheme.success
        case .intermediate: return KinexaTheme.warning
        case .advanced: return KinexaTheme.danger
        case .allLevels: return Color(hex: "#EC4899")
        }
    }
}
