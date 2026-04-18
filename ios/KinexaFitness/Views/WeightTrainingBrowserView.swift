import SwiftUI

struct WeightTrainingBrowserView: View {
    @Environment(\.dismiss) private var dismiss
    let onAddExercise: (ManualRoutineExercise) -> Void

    @State private var browseMode: WeightBrowseMode = .landing
    @State private var searchText: String = ""
    @State private var addedTrigger: Bool = false
    @State private var showPreMadeRoutines: Bool = false

    private enum WeightBrowseMode: Equatable {
        case landing
        case bodyParts
        case bodyPartDetail(WeightBodyPart)
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
                            switch browseMode {
                            case .landing:
                                landingCards
                            case .bodyParts:
                                bodyPartGrid
                            case .bodyPartDetail(let part):
                                bodyPartDetail(part)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 48)
                }
            }
            .navigationTitle(navTitle)
            .navigationBarTitleDisplayMode(browseMode == .landing ? .large : .inline)
            .searchable(text: $searchText, prompt: "Search exercises")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if browseMode != .landing && searchText.isEmpty {
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                switch browseMode {
                                case .bodyPartDetail:
                                    browseMode = .bodyParts
                                default:
                                    browseMode = .landing
                                }
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
            
            .sensoryFeedback(.impact(weight: .light), trigger: addedTrigger)
            .sheet(isPresented: $showPreMadeRoutines) {
                PreMadeRoutinesView(onAddExercise: onAddExercise)
            }
        }
    }

    private var navTitle: String {
        switch browseMode {
        case .landing: return "Weight Training"
        case .bodyParts: return "Body Part"
        case .bodyPartDetail(let part): return part.rawValue
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

    private var landingCards: some View {
        VStack(spacing: 14) {
            heroCard(
                title: "Body Part",
                subtitle: "Browse exercises by muscle group",
                count: WeightExerciseLibrary.allExercises.count,
                countLabel: "exercises",
                icon: "figure.strengthtraining.traditional",
                iconColor: Color(hex: "#6366F1")
            ) {
                withAnimation(.spring(response: 0.3)) {
                    browseMode = .bodyParts
                }
            }

            heroCard(
                title: "Pre-made Routines",
                subtitle: "Complete workout programs ready to go",
                count: PreMadeRoutineLibrary.allRoutines.count,
                countLabel: "routines",
                icon: "doc.text.fill",
                iconColor: Color(hex: "#8B5CF6")
            ) {
                showPreMadeRoutines = true
            }
        }
    }

    private func heroCard(title: String, subtitle: String, count: Int, countLabel: String, icon: String, iconColor: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(
                        LinearGradient(
                            colors: [iconColor, iconColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(.rect(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)

                    Text(subtitle)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                        .lineLimit(2)

                    Text("\(count) \(countLabel)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(iconColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(iconColor.opacity(0.12))
                        .clipShape(Capsule())
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }
            .padding(16)
            .background(KinexaTheme.card)
            .clipShape(.rect(cornerRadius: 18))
            .elevatedCardShadow()
            .overlay {
                RoundedRectangle(cornerRadius: 18).stroke(KinexaTheme.border)
            }
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    private var bodyPartGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(WeightBodyPart.allCases) { part in
                let count = WeightExerciseLibrary.exercises(for: part).count
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        browseMode = .bodyPartDetail(part)
                    }
                } label: {
                    VStack(spacing: 10) {
                        Image(systemName: part.icon)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color(hex: "#6366F1"))
                            .frame(width: 48, height: 48)
                            .background(Color(hex: "#6366F1").opacity(0.12))
                            .clipShape(.rect(cornerRadius: 14))

                        Text(part.rawValue)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(KinexaTheme.primaryText)

                        Text("\(count) exercises")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(KinexaTheme.tertiaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(KinexaTheme.card)
                    .clipShape(.rect(cornerRadius: 18))
                    .elevatedCardShadow()
                    .overlay {
                        RoundedRectangle(cornerRadius: 18).stroke(KinexaTheme.border)
                    }
                }
                .buttonStyle(PressScaleButtonStyle())
            }
        }
    }

    private func bodyPartDetail(_ part: WeightBodyPart) -> some View {
        VStack(spacing: 10) {
            ForEach(WeightExerciseLibrary.exercises(for: part)) { exercise in
                exerciseRow(exercise)
            }
        }
    }

    private var searchResults: some View {
        let filtered = WeightExerciseLibrary.allExercises.filter {
            $0.name.localizedStandardContains(searchText)
        }

        return VStack(spacing: 10) {
            if filtered.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.title)
                        .foregroundStyle(KinexaTheme.tertiaryText)
                    Text("No exercises found")
                        .font(.subheadline)
                        .foregroundStyle(KinexaTheme.secondaryText)
                }
                .padding(.top, 40)
            } else {
                ForEach(filtered) { exercise in
                    exerciseRow(exercise)
                }
            }
        }
    }

    private func exerciseRow(_ exercise: WeightExerciseDefinition) -> some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(KinexaTheme.primaryText)

                HStack(spacing: 8) {
                    Text(exercise.bodyPart.rawValue)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color(hex: "#6366F1"))
                    Text(exercise.equipment)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                    Text("\(exercise.defaultSets)x\(exercise.defaultReps)")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }
            }

            Spacer(minLength: 0)

            Button {
                addedTrigger.toggle()
                let routineExercise = ManualRoutineExercise(
                    name: exercise.name,
                    category: exercise.bodyPart.rawValue,
                    sets: exercise.defaultSets,
                    reps: exercise.defaultReps,
                    sourceType: .weightTraining
                )
                onAddExercise(routineExercise)
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color(hex: "#6366F1"))
            }
        }
        .padding(14)
        .background(KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 14))
        .elevatedCardShadow()
        .overlay {
            RoundedRectangle(cornerRadius: 14).stroke(KinexaTheme.border)
        }
    }
}
