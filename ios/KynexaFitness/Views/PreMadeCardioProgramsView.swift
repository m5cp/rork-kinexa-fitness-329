import SwiftUI

struct PreMadeCardioProgramsView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var searchText: String = ""
    @State private var selectedProgram: PreMadeCardioProgram?
    @State private var showMode: CardioBrowseMode = .levels

    private enum CardioBrowseMode {
        case levels
        case levelDetail(CardioProgramLevel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                KynexaTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        disclaimerBanner

                        if !searchText.isEmpty {
                            searchResults
                        } else {
                            switch showMode {
                            case .levels:
                                levelHeroCards
                            case .levelDetail(let level):
                                levelProgramList(level)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 48)
                }
            }
            .navigationTitle(navTitle)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search programs")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if case .levelDetail = showMode, searchText.isEmpty {
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                showMode = .levels
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.caption.weight(.bold))
                                Text("Back")
                                    .font(.subheadline.weight(.medium))
                            }
                            .foregroundStyle(KynexaTheme.accent)
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(KynexaTheme.primaryText)
                }
            }
            .toolbarBackground(KynexaTheme.background, for: .navigationBar)
            
            .sheet(item: $selectedProgram) { program in
                PreMadeCardioProgramDetailView(program: program)
            }
        }
    }

    private var navTitle: String {
        switch showMode {
        case .levels: return "Cardio Programs"
        case .levelDetail(let level): return level.rawValue
        }
    }

    private var disclaimerBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "info.circle.fill")
                .font(.caption)
                .foregroundStyle(Color(hex: "#EC4899").opacity(0.7))

            Text("These are open source cardio programs blended together by traditional training methods. They are not a recommendation or guide. For tracking and accountability only.")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(KynexaTheme.tertiaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .background(Color(hex: "#EC4899").opacity(0.06))
        .clipShape(.rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#EC4899").opacity(0.1))
        }
    }

    // MARK: - Level Hero Cards

    private var levelHeroCards: some View {
        VStack(spacing: 14) {
            levelHeroCard(
                level: .beginner,
                gradient: [Color(hex: "#22C55E"), Color(hex: "#16A34A")],
                icon: "figure.walk",
                programs: PreMadeCardioLibrary.beginnerPrograms
            )

            levelHeroCard(
                level: .intermediate,
                gradient: [Color(hex: "#F59E0B"), Color(hex: "#D97706")],
                icon: "figure.run",
                programs: PreMadeCardioLibrary.intermediatePrograms
            )

            levelHeroCard(
                level: .advanced,
                gradient: [Color(hex: "#EF4444"), Color(hex: "#DC2626")],
                icon: "figure.run.treadmill",
                programs: PreMadeCardioLibrary.advancedPrograms
            )
        }
    }

    private func levelHeroCard(level: CardioProgramLevel, gradient: [Color], icon: String, programs: [PreMadeCardioProgram]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    showMode = .levelDetail(level)
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(.white.opacity(0.18))
                        .clipShape(.rect(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 3) {
                        Text(level.rawValue)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)

                        Text("\(programs.count) programs")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.white.opacity(0.7))
                    }

                    Spacer(minLength: 0)

                    Text("See All")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.white.opacity(0.15))
                        .clipShape(Capsule())
                }
                .padding(16)
                .background(
                    LinearGradient(
                        colors: gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(.rect(topLeadingRadius: 18, topTrailingRadius: 18))
            }
            .buttonStyle(.plain)

            VStack(spacing: 0) {
                ForEach(Array(programs.prefix(3).enumerated()), id: \.element.id) { idx, program in
                    if idx > 0 {
                        Divider().overlay(KynexaTheme.border)
                    }
                    Button {
                        selectedProgram = program
                    } label: {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(program.name)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(KynexaTheme.primaryText)
                                    .lineLimit(1)

                                HStack(spacing: 6) {
                                    Text("\(program.daysPerWeek) days/wk")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(gradient.first ?? .blue)
                                    Text(program.programType.rawValue)
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundStyle(KynexaTheme.tertiaryText)
                                }
                            }

                            Spacer(minLength: 0)

                            Image(systemName: "chevron.right")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(KynexaTheme.tertiaryText)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(KynexaTheme.card)
            .clipShape(.rect(bottomLeadingRadius: 18, bottomTrailingRadius: 18))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(gradient.first?.opacity(0.2) ?? Color.clear)
        }
        .shadow(color: (gradient.first ?? .clear).opacity(0.12), radius: 12, y: 6)
    }

    // MARK: - Level Detail

    private func levelProgramList(_ level: CardioProgramLevel) -> some View {
        let programs = PreMadeCardioLibrary.programs(for: level)
        return LazyVStack(spacing: 12) {
            ForEach(programs) { program in
                programCard(program)
            }
        }
    }

    // MARK: - Search

    private var searchResults: some View {
        let filtered = PreMadeCardioLibrary.search(searchText)
        return VStack(spacing: 12) {
            if filtered.isEmpty {
                emptyState
            } else {
                ForEach(filtered) { program in
                    programCard(program)
                }
            }
        }
    }

    private func programCard(_ program: PreMadeCardioProgram) -> some View {
        Button {
            selectedProgram = program
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: program.programType.icon)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: program.programType.gradientHex.0), Color(hex: program.programType.gradientHex.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(.rect(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(program.name)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(KynexaTheme.primaryText)
                            .multilineTextAlignment(.leading)

                        Text(program.programDescription)
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(KynexaTheme.tertiaryText)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(KynexaTheme.tertiaryText)
                        .padding(.top, 4)
                }

                HStack(spacing: 6) {
                    tagBadge(text: "\(program.daysPerWeek) days/wk", color: Color(hex: "#EC4899"))
                    tagBadge(text: "\(program.durationWeeks) weeks", color: Color(hex: "#8B5CF6"))
                    tagBadge(text: program.level.rawValue, color: levelColor(program.level))
                    tagBadge(text: program.programType.rawValue, color: Color(hex: program.programType.gradientHex.0))
                }
            }
            .padding(16)
            .background(KynexaTheme.card)
            .clipShape(.rect(cornerRadius: 16))
            .elevatedCardShadow()
            .overlay {
                RoundedRectangle(cornerRadius: 16).stroke(KynexaTheme.border)
            }
        }
        .buttonStyle(PressScaleButtonStyle())
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
        case .beginner: return KynexaTheme.success
        case .intermediate: return KynexaTheme.warning
        case .advanced: return KynexaTheme.danger
        case .allLevels: return Color(hex: "#EC4899")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.title)
                .foregroundStyle(KynexaTheme.tertiaryText)
            Text("No programs found")
                .font(.subheadline)
                .foregroundStyle(KynexaTheme.secondaryText)
        }
        .padding(.top, 40)
    }
}
