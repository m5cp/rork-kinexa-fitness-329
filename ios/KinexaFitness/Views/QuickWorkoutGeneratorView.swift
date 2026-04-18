import SwiftUI

nonisolated enum QuickWorkoutType: String, CaseIterable, Identifiable, Sendable {
    case functional = "Functional Fitness"
    case weights = "Free Weights"
    case cardio = "Cardio"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .functional: return "bolt.heart.fill"
        case .weights: return "dumbbell.fill"
        case .cardio: return "heart.fill"
        }
    }

    var gradient: [Color] {
        switch self {
        case .functional: return [Color(hex: "#F59E0B"), Color(hex: "#D97706")]
        case .weights: return [Color(hex: "#6366F1"), Color(hex: "#4338CA")]
        case .cardio: return [Color(hex: "#EC4899"), Color(hex: "#BE185D")]
        }
    }
}

struct QuickWorkoutGeneratorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var vm

    @State private var selectedType: QuickWorkoutType = .functional
    @State private var selectedDuration: Int = 30
    @State private var generatedTemplate: WODTemplate?
    @State private var generatedCardio: CardioWorkoutDefinition?
    @State private var hasGenerated: Bool = false
    @State private var generateTrigger: Bool = false
    @State private var logTrigger: Bool = false
    @State private var didLog: Bool = false
    @State private var expandedMovementId: UUID?
    @State private var cardioGuideExpanded: Bool = false

    private let durations: [Int] = [15, 30, 45, 60]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    if hasGenerated {
                        resultSection
                    } else {
                        setupSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
            .background(KinexaTheme.background.ignoresSafeArea())
            .navigationTitle("Quick Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(KinexaTheme.background, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(KinexaTheme.accent)
                }
            }
            .sensoryFeedback(.impact(weight: .medium), trigger: generateTrigger)
            .sensoryFeedback(.success, trigger: logTrigger)
        }
    }

    // MARK: - Setup

    private var setupSection: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Build a one-off session")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)
                Text("Pick a style and how long you want to train.")
                    .font(.subheadline)
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("TYPE")
                    .font(.caption.weight(.heavy))
                    .tracking(1.2)
                    .foregroundStyle(KinexaTheme.tertiaryText)

                VStack(spacing: 10) {
                    ForEach(QuickWorkoutType.allCases) { type in
                        typeCard(type)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("DURATION")
                    .font(.caption.weight(.heavy))
                    .tracking(1.2)
                    .foregroundStyle(KinexaTheme.tertiaryText)

                HStack(spacing: 10) {
                    ForEach(durations, id: \.self) { d in
                        durationChip(d)
                    }
                }
            }

            Button {
                generateTrigger.toggle()
                generate()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.subheadline.weight(.bold))
                    Text("Generate Workout")
                        .font(.headline.weight(.bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    LinearGradient(
                        colors: selectedType.gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(.rect(cornerRadius: 16))
                .shadow(color: (selectedType.gradient.first ?? .clear).opacity(0.3), radius: 14, y: 8)
            }
            .buttonStyle(PressScaleButtonStyle())
        }
    }

    private func typeCard(_ type: QuickWorkoutType) -> some View {
        let isSelected = selectedType == type
        return Button {
            selectedType = type
        } label: {
            HStack(spacing: 14) {
                Image(systemName: type.icon)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(
                        LinearGradient(
                            colors: type.gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(.rect(cornerRadius: 12))

                Text(type.rawValue)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)

                Spacer(minLength: 0)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? (type.gradient.first ?? KinexaTheme.accent) : KinexaTheme.tertiaryText)
            }
            .padding(14)
            .background(KinexaTheme.card)
            .clipShape(.rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? (type.gradient.first ?? KinexaTheme.accent).opacity(0.5) : KinexaTheme.border, lineWidth: isSelected ? 1.5 : 1)
            }
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    private func durationChip(_ mins: Int) -> some View {
        let isSelected = selectedDuration == mins
        return Button {
            selectedDuration = mins
        } label: {
            Text("\(mins) min")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(isSelected ? .white : KinexaTheme.primaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background {
                    if isSelected {
                        LinearGradient(
                            colors: selectedType.gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        KinexaTheme.card
                    }
                }
                .clipShape(.rect(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.clear : KinexaTheme.border)
                }
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    // MARK: - Result

    @ViewBuilder
    private var resultSection: some View {
        if selectedType == .cardio, let cardio = generatedCardio {
            cardioResult(cardio)
        } else if let template = generatedTemplate {
            templateResult(template)
        } else {
            Text("No workout generated")
                .foregroundStyle(KinexaTheme.tertiaryText)
        }

        resultActions
    }

    private func templateResult(_ template: WODTemplate) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: selectedType.icon)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.9))
                    Text(selectedType.rawValue.uppercased())
                        .font(.caption2.weight(.heavy))
                        .tracking(1.0)
                        .foregroundStyle(.white.opacity(0.8))
                    Spacer()
                    Text("\(selectedDuration) min")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.white.opacity(0.18))
                        .clipShape(Capsule())
                }

                Text(template.title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)

                Text(template.workoutDescription)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                LinearGradient(
                    colors: selectedType.gradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            .clipShape(.rect(cornerRadius: 20))

            VStack(alignment: .leading, spacing: 8) {
                Text("MOVEMENTS")
                    .font(.caption.weight(.heavy))
                    .tracking(1.0)
                    .foregroundStyle(KinexaTheme.tertiaryText)
                    .padding(.leading, 4)

                ForEach(template.movements) { movement in
                    movementRow(movement)
                }
            }
        }
    }

    @ViewBuilder
    private func movementRow(_ movement: WODMovement) -> some View {
        let isExpanded = expandedMovementId == movement.id
        let accent = selectedType.gradient.first ?? KinexaTheme.accent
        let guide = MovementGuideLibrary.guide(for: movement.name)

        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    expandedMovementId = isExpanded ? nil : movement.id
                }
            } label: {
                HStack(spacing: 12) {
                    Circle()
                        .fill(accent.opacity(0.3))
                        .frame(width: 8, height: 8)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(movement.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(KinexaTheme.primaryText)
                            .multilineTextAlignment(.leading)
                        HStack(spacing: 8) {
                            if let reps = movement.reps {
                                Text(reps).font(.caption.weight(.medium)).foregroundStyle(accent)
                            }
                            if let dur = movement.duration {
                                Text(dur).font(.caption.weight(.medium)).foregroundStyle(accent)
                            }
                        }
                    }
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                guideDetails(guide, accent: accent)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 12)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12).stroke(KinexaTheme.border)
        }
    }

    private func guideDetails(_ guide: MovementGuide, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider().overlay(KinexaTheme.border)

            VStack(alignment: .leading, spacing: 4) {
                Text("WHAT IT IS")
                    .font(.caption2.weight(.heavy))
                    .tracking(1.0)
                    .foregroundStyle(accent)
                Text(guide.whatIsIt)
                    .font(.caption)
                    .foregroundStyle(KinexaTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("HOW TO DO IT")
                    .font(.caption2.weight(.heavy))
                    .tracking(1.0)
                    .foregroundStyle(accent)
                ForEach(Array(guide.howTo.enumerated()), id: \.offset) { idx, step in
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(idx + 1).")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(accent)
                        Text(step)
                            .font(.caption)
                            .foregroundStyle(KinexaTheme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("ALTERNATIVES")
                    .font(.caption2.weight(.heavy))
                    .tracking(1.0)
                    .foregroundStyle(accent)
                ForEach(guide.alternatives, id: \.self) { alt in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "arrow.triangle.swap")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(accent)
                        Text(alt)
                            .font(.caption)
                            .foregroundStyle(KinexaTheme.secondaryText)
                    }
                }
            }
        }
    }

    private func cardioResult(_ cardio: CardioWorkoutDefinition) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: cardio.icon)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.9))
                    Text("CARDIO")
                        .font(.caption2.weight(.heavy))
                        .tracking(1.0)
                        .foregroundStyle(.white.opacity(0.8))
                    Spacer()
                    Text("\(selectedDuration) min")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.white.opacity(0.18))
                        .clipShape(Capsule())
                }

                Text(cardio.name)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)

                Text(cardio.description)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 12) {
                    Label("\(cardio.difficultyLevel)", systemImage: "flame.fill")
                    Label("~\(selectedDuration * cardio.estimatedCaloriesPerMinute) cal", systemImage: "bolt.fill")
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.85))
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                LinearGradient(
                    colors: selectedType.gradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            .clipShape(.rect(cornerRadius: 20))

            let guide = CardioGuideLibrary.guide(for: cardio)
            let accent = selectedType.gradient.first ?? KinexaTheme.accent
            VStack(alignment: .leading, spacing: 0) {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        cardioGuideExpanded.toggle()
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "book.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(accent)
                        Text("How to do this workout")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(KinexaTheme.primaryText)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(KinexaTheme.tertiaryText)
                            .rotationEffect(.degrees(cardioGuideExpanded ? 180 : 0))
                    }
                    .padding(14)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if cardioGuideExpanded {
                    guideDetails(guide, accent: accent)
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
    }

    private var resultActions: some View {
        VStack(spacing: 10) {
            if !didLog {
                Button {
                    logTrigger.toggle()
                    logWorkout()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.subheadline.weight(.bold))
                        Text("Log Workout")
                            .font(.headline.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(KinexaTheme.heroGradient)
                    .clipShape(.rect(cornerRadius: 16))
                }
                .buttonStyle(PressScaleButtonStyle())
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(KinexaTheme.success)
                    Text("Workout Logged")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(KinexaTheme.success)
                }
                .frame(height: 52)
                .frame(maxWidth: .infinity)
            }

            HStack(spacing: 10) {
                Button {
                    generateTrigger.toggle()
                    didLog = false
                    generate()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                            .font(.caption.weight(.bold))
                        Text("Refresh")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(KinexaTheme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(KinexaTheme.cardSoft)
                    .clipShape(.rect(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12).stroke(KinexaTheme.border)
                    }
                }
                .buttonStyle(PressScaleButtonStyle())

                Button {
                    hasGenerated = false
                    didLog = false
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.caption.weight(.bold))
                        Text("Change")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(KinexaTheme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(KinexaTheme.cardSoft)
                    .clipShape(.rect(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12).stroke(KinexaTheme.border)
                    }
                }
                .buttonStyle(PressScaleButtonStyle())
            }
        }
    }

    // MARK: - Generation

    private func generate() {
        hasGenerated = true
        didLog = false
        switch selectedType {
        case .functional:
            generatedCardio = nil
            generatedTemplate = bestTemplate(from: WODTemplateLibrary.functionalWODs + WODTemplateLibrary.aftWODs)
        case .weights:
            generatedCardio = nil
            generatedTemplate = bestTemplate(from: FreeWeightLibrary.freeWeightWorkouts)
        case .cardio:
            generatedTemplate = nil
            let pool = CardioLibrary.running + CardioLibrary.cycling + CardioLibrary.classWorkouts + CardioLibrary.lowImpact + CardioLibrary.outdoor
            let currentId = generatedCardio?.id
            let filtered = pool.filter { $0.id != currentId }
            generatedCardio = filtered.randomElement() ?? pool.randomElement()
        }
        expandedMovementId = nil
        cardioGuideExpanded = false
    }

    private func bestTemplate(from pool: [WODTemplate]) -> WODTemplate? {
        guard !pool.isEmpty else { return nil }
        let target = selectedDuration
        let currentTitle = generatedTemplate?.title
        let sorted = pool
            .filter { $0.title != currentTitle }
            .sorted { abs($0.durationMinutes - target) < abs($1.durationMinutes - target) }
        let tolerance = 10
        let close = sorted.filter { abs($0.durationMinutes - target) <= tolerance }
        if let pick = close.randomElement() { return pick }
        return sorted.first ?? pool.randomElement()
    }

    private func logWorkout() {
        didLog = true
        if selectedType == .cardio, let cardio = generatedCardio {
            let cals = selectedDuration * cardio.estimatedCaloriesPerMinute
            let session = CardioSession(
                workoutName: cardio.name,
                category: cardio.category.rawValue,
                durationMinutes: selectedDuration,
                caloriesBurned: cals
            )
            vm.logCardioSession(session)
        } else if let template = generatedTemplate {
            var workout = WODService.convertToWorkoutDay(template)
            workout.source = .wod
            vm.completeStandaloneWorkout(workout)
        }
    }
}
