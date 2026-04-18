import SwiftUI

struct CardioByTypeView: View {
    @Environment(\.dismiss) private var dismiss
    let onAddExercise: (ManualRoutineExercise) -> Void

    @State private var searchText: String = ""
    @State private var selectedCategory: CardioCategory?
    @State private var addedTrigger: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                KinexaTheme.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        disclaimerBanner

                        categoryFilterStrip

                        if !searchText.isEmpty {
                            searchResults
                        } else if let cat = selectedCategory {
                            singleCategorySection(cat)
                        } else {
                            allCategorySections
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 48)
                }
            }
            .navigationTitle("Cardio by Type")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search cardio")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
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
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(KinexaTheme.primaryText)
                }
            }
            .toolbarBackground(KinexaTheme.background, for: .navigationBar)
            
            .sensoryFeedback(.impact(weight: .light), trigger: addedTrigger)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(KinexaTheme.background)
    }

    private var disclaimerBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "info.circle.fill")
                .font(.caption)
                .foregroundStyle(Color(hex: "#EC4899").opacity(0.7))

            Text("These are open source cardio exercises blended together by traditional training methods. They are not a recommendation or guide. For tracking and accountability only.")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(KinexaTheme.tertiaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .background(Color(hex: "#EC4899").opacity(0.06))
        .clipShape(.rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#EC4899").opacity(0.1))
        }
        .padding(.horizontal, 20)
    }

    private var categoryFilterStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(title: "All", category: nil)
                ForEach(CardioCategory.allCases) { category in
                    filterChip(title: category.rawValue, category: category)
                }
            }
        }
        .contentMargins(.horizontal, 20)
    }

    private func filterChip(title: String, category: CardioCategory?) -> some View {
        let isSelected = selectedCategory == category
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedCategory = category
            }
        } label: {
            HStack(spacing: 6) {
                if let cat = category {
                    Image(systemName: cat.icon)
                        .font(.caption2.weight(.bold))
                }
                Text(title)
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(isSelected ? .white : KinexaTheme.secondaryText)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color(hex: "#EC4899") : KinexaTheme.card)
            .clipShape(Capsule())
            .overlay {
                Capsule().stroke(isSelected ? Color(hex: "#EC4899") : KinexaTheme.border)
            }
        }
        .buttonStyle(.plain)
    }

    private var allCategorySections: some View {
        VStack(spacing: 14) {
            ForEach(CardioCategory.allCases) { category in
                let workouts = CardioLibrary.workouts(for: category)
                if !workouts.isEmpty {
                    categoryHeroCard(category: category, workouts: workouts)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private func singleCategorySection(_ category: CardioCategory) -> some View {
        let workouts = CardioLibrary.workouts(for: category)
        return VStack(spacing: 10) {
            ForEach(workouts) { workout in
                workoutRow(workout)
            }
        }
        .padding(.horizontal, 20)
    }

    private func categoryHeroCard(category: CardioCategory, workouts: [CardioWorkoutDefinition]) -> some View {
        let gradient = [Color(hex: category.gradientHex.0), Color(hex: category.gradientHex.1)]

        return VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(.white.opacity(0.18))
                    .clipShape(.rect(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 3) {
                    Text(category.rawValue)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)

                    Text("\(workouts.count) workouts")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.white.opacity(0.7))
                }

                Spacer(minLength: 0)

                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedCategory = category
                    }
                } label: {
                    Text("See All")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.white.opacity(0.15))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
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

            VStack(spacing: 0) {
                ForEach(Array(workouts.prefix(3).enumerated()), id: \.element.id) { idx, workout in
                    if idx > 0 {
                        Divider().overlay(KinexaTheme.border)
                    }
                    Button {
                        addedTrigger.toggle()
                        let exercise = ManualRoutineExercise(
                            name: workout.name,
                            category: workout.category.rawValue,
                            sets: 1,
                            reps: "30 min",
                            sourceType: .cardio
                        )
                        onAddExercise(exercise)
                    } label: {
                        HStack(spacing: 12) {
                            Text(workout.name)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(KinexaTheme.primaryText)
                                .lineLimit(1)

                            Spacer(minLength: 0)

                            Text(workout.difficultyLevel)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(difficultyColor(workout.difficultyLevel))

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

    private func workoutRow(_ workout: CardioWorkoutDefinition) -> some View {
        Button {
            addedTrigger.toggle()
            let exercise = ManualRoutineExercise(
                name: workout.name,
                category: workout.category.rawValue,
                sets: 1,
                reps: "30 min",
                sourceType: .cardio
            )
            onAddExercise(exercise)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: workout.icon)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color(hex: workout.category.gradientHex.0))
                    .frame(width: 36, height: 36)
                    .background(Color(hex: workout.category.gradientHex.0).opacity(0.12))
                    .clipShape(.rect(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 3) {
                    Text(workout.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(KinexaTheme.primaryText)

                    Text(workout.description)
                        .font(.caption2)
                        .foregroundStyle(KinexaTheme.tertiaryText)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                Text(workout.difficultyLevel)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(difficultyColor(workout.difficultyLevel))

                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color(hex: workout.category.gradientHex.0))
            }
            .padding(14)
            .background(KinexaTheme.card)
            .clipShape(.rect(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14).stroke(KinexaTheme.border)
            }
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    private var searchResults: some View {
        let filtered = CardioLibrary.allWorkouts.filter {
            $0.name.localizedStandardContains(searchText) ||
            $0.description.localizedStandardContains(searchText)
        }

        return VStack(spacing: 10) {
            if filtered.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.title)
                        .foregroundStyle(KinexaTheme.tertiaryText)
                    Text("No workouts found")
                        .font(.subheadline)
                        .foregroundStyle(KinexaTheme.secondaryText)
                }
                .padding(.top, 40)
            } else {
                ForEach(filtered) { workout in
                    workoutRow(workout)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private func difficultyColor(_ level: String) -> Color {
        switch level {
        case "Easy", "Beginner": return KinexaTheme.success
        case "Moderate": return KinexaTheme.warning
        case "Hard": return Color(hex: "#F59E0B")
        default: return KinexaTheme.tertiaryText
        }
    }
}
