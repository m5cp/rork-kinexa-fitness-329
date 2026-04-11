import SwiftUI

struct WeightTrainingBrowserView: View {
    @Environment(\.dismiss) private var dismiss
    let onAddExercise: (ManualRoutineExercise) -> Void

    @State private var selectedBodyPart: WeightBodyPart?
    @State private var searchText: String = ""
    @State private var addedTrigger: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                KinexaTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        if !searchText.isEmpty {
                            searchResults
                        } else if let part = selectedBodyPart {
                            bodyPartDetail(part)
                        } else {
                            bodyPartGrid
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 48)
                }
            }
            .navigationTitle(selectedBodyPart?.rawValue ?? "Weight Training")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search exercises")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if selectedBodyPart != nil && searchText.isEmpty {
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                selectedBodyPart = nil
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.caption.weight(.bold))
                                Text("Body Parts")
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
            .sensoryFeedback(.impact(weight: .light), trigger: addedTrigger)
        }
    }

    private var bodyPartGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(WeightBodyPart.allCases) { part in
                let count = WeightExerciseLibrary.exercises(for: part).count
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedBodyPart = part
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
        .overlay {
            RoundedRectangle(cornerRadius: 14).stroke(KinexaTheme.border)
        }
    }
}
