import SwiftUI

struct PreMadeRoutinesView: View {
    @Environment(\.dismiss) private var dismiss
    let onAddExercise: (ManualRoutineExercise) -> Void

    @State private var searchText: String = ""
    @State private var selectedRoutine: PreMadeRoutine?
    @State private var showMode: RoutineBrowseMode = .levels

    private enum RoutineBrowseMode {
        case levels
        case levelDetail(RoutineLevel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                KinexaTheme.background.ignoresSafeArea()

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
                                levelRoutineList(level)
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
            .searchable(text: $searchText, prompt: "Search routines")
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
                            .foregroundStyle(KinexaTheme.accent)
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(KinexaTheme.primaryText)
                }
            }
            .toolbarBackground(KinexaTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(item: $selectedRoutine) { routine in
                PreMadeRoutineDetailView(routine: routine, onAddExercise: onAddExercise)
            }
        }
    }

    private var navTitle: String {
        switch showMode {
        case .levels: return "Pre-made Routines"
        case .levelDetail(let level): return level.rawValue
        }
    }

    private var disclaimerBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "info.circle.fill")
                .font(.caption)
                .foregroundStyle(Color(hex: "#6366F1").opacity(0.7))

            Text("These are open source muscle group exercises blended together by traditional splits. They are not a recommendation or guide. For tracking and accountability only.")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(KinexaTheme.tertiaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .background(Color(hex: "#6366F1").opacity(0.06))
        .clipShape(.rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#6366F1").opacity(0.1))
        }
    }

    // MARK: - Level Hero Cards

    private var levelHeroCards: some View {
        VStack(spacing: 14) {
            levelHeroCard(
                level: .beginner,
                gradient: [Color(hex: "#22C55E"), Color(hex: "#16A34A")],
                icon: "figure.walk",
                routines: PreMadeRoutineLibrary.beginnerRoutines
            )

            levelHeroCard(
                level: .intermediate,
                gradient: [Color(hex: "#F59E0B"), Color(hex: "#D97706")],
                icon: "figure.strengthtraining.traditional",
                routines: PreMadeRoutineLibrary.intermediateRoutines
            )

            levelHeroCard(
                level: .advanced,
                gradient: [Color(hex: "#EF4444"), Color(hex: "#DC2626")],
                icon: "figure.highintensity.intervaltraining",
                routines: PreMadeRoutineLibrary.advancedRoutines
            )
        }
    }

    private func levelHeroCard(level: RoutineLevel, gradient: [Color], icon: String, routines: [PreMadeRoutine]) -> some View {
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

                        Text("\(routines.count) routines")
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
                ForEach(Array(routines.prefix(3).enumerated()), id: \.element.id) { idx, routine in
                    if idx > 0 {
                        Divider().overlay(KinexaTheme.border)
                    }
                    Button {
                        selectedRoutine = routine
                    } label: {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(routine.name)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(KinexaTheme.primaryText)
                                    .lineLimit(1)

                                HStack(spacing: 6) {
                                    Text("\(routine.daysPerWeek) days/wk")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(gradient.first ?? .blue)
                                    Text(routine.splitType.rawValue)
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundStyle(KinexaTheme.tertiaryText)
                                }
                            }

                            Spacer(minLength: 0)

                            Image(systemName: "chevron.right")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(KinexaTheme.tertiaryText)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(KinexaTheme.card)
            .clipShape(.rect(bottomLeadingRadius: 18, bottomTrailingRadius: 18))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(gradient.first?.opacity(0.2) ?? Color.clear)
        }
        .shadow(color: (gradient.first ?? .clear).opacity(0.12), radius: 12, y: 6)
    }

    // MARK: - Level Detail

    private func levelRoutineList(_ level: RoutineLevel) -> some View {
        let routines = PreMadeRoutineLibrary.routines(for: level)
        return LazyVStack(spacing: 12) {
            ForEach(routines) { routine in
                routineCard(routine)
            }
        }
    }

    // MARK: - Search

    private var searchResults: some View {
        let filtered = PreMadeRoutineLibrary.search(searchText)
        return VStack(spacing: 12) {
            if filtered.isEmpty {
                emptyState
            } else {
                ForEach(filtered) { routine in
                    routineCard(routine)
                }
            }
        }
    }

    private func routineCard(_ routine: PreMadeRoutine) -> some View {
        Button {
            selectedRoutine = routine
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: routine.splitType.icon)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#6366F1"), Color(hex: "#4338CA")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(.rect(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(routine.name)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(KinexaTheme.primaryText)
                            .multilineTextAlignment(.leading)

                        Text(routine.routineDescription)
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(KinexaTheme.tertiaryText)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                        .padding(.top, 4)
                }

                HStack(spacing: 6) {
                    tagBadge(text: "\(routine.daysPerWeek) days/wk", color: Color(hex: "#6366F1"))
                    tagBadge(text: "\(routine.durationWeeks) weeks", color: Color(hex: "#8B5CF6"))
                    tagBadge(text: routine.level.rawValue, color: levelColor(routine.level))
                    tagBadge(text: routine.splitType.rawValue, color: Color(hex: "#0EA5E9"))
                }
            }
            .padding(16)
            .background(KinexaTheme.card)
            .clipShape(.rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16).stroke(KinexaTheme.border)
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

    private func levelColor(_ level: RoutineLevel) -> Color {
        switch level {
        case .beginner: return KinexaTheme.success
        case .intermediate: return KinexaTheme.warning
        case .advanced: return KinexaTheme.danger
        case .allLevels: return Color(hex: "#6366F1")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.title)
                .foregroundStyle(KinexaTheme.tertiaryText)
            Text("No routines found")
                .font(.subheadline)
                .foregroundStyle(KinexaTheme.secondaryText)
        }
        .padding(.top, 40)
    }
}
