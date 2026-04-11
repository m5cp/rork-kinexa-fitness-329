import SwiftUI

struct CardioWorkoutsView: View {
    @Environment(AppViewModel.self) private var vm
    @State private var searchText: String = ""
    @State private var selectedCategory: CardioCategory?
    @State private var selectedWorkout: CardioWorkoutDefinition?
    @State private var showLogSheet: Bool = false
    @State private var workoutToLog: CardioWorkoutDefinition?
    @State private var appeared: Bool = false

    private var filteredWorkouts: [CardioWorkoutDefinition] {
        var results: [CardioWorkoutDefinition]
        if let cat = selectedCategory {
            results = CardioLibrary.workouts(for: cat)
        } else {
            results = CardioLibrary.allWorkouts
        }
        if !searchText.isEmpty {
            let lower = searchText.lowercased()
            results = results.filter {
                $0.name.lowercased().contains(lower) ||
                $0.description.lowercased().contains(lower)
            }
        }
        return results
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                categoryFilterStrip
                workoutsList
            }
            .padding(.top, 8)
            .padding(.bottom, 48)
        }
        .background(KinexaTheme.background.ignoresSafeArea())
        .navigationTitle("Cardio")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(KinexaTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .searchable(text: $searchText, prompt: "Search workouts")
        .sheet(item: $workoutToLog) { workout in
            LogCardioSessionSheet(workout: workout)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
        }
    }

    private var categoryFilterStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                categoryChip(title: "All", category: nil)
                ForEach(CardioCategory.allCases) { category in
                    categoryChip(title: category.rawValue, category: category)
                }
            }
        }
        .contentMargins(.horizontal, 20)
    }

    private func categoryChip(title: String, category: CardioCategory?) -> some View {
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
            .background(isSelected ? KinexaTheme.accent : KinexaTheme.card)
            .clipShape(Capsule())
            .overlay {
                Capsule().stroke(isSelected ? KinexaTheme.accent : KinexaTheme.border)
            }
        }
        .buttonStyle(.plain)
    }

    private var workoutsList: some View {
        LazyVStack(spacing: 10) {
            ForEach(filteredWorkouts) { workout in
                cardioWorkoutRow(workout)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 8)
            }
        }
        .padding(.horizontal, 20)
    }

    private func cardioWorkoutRow(_ workout: CardioWorkoutDefinition) -> some View {
        Button {
            workoutToLog = workout
        } label: {
            HStack(spacing: 14) {
                Image(systemName: workout.icon)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color(hex: workout.category.gradientHex.0))
                    .frame(width: 44, height: 44)
                    .background(Color(hex: workout.category.gradientHex.0).opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(KinexaTheme.primaryText)

                    Text(workout.description)
                        .font(.caption2)
                        .foregroundStyle(KinexaTheme.tertiaryText)
                        .lineLimit(2)
                }

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: 4) {
                    Text("~\(workout.estimatedCaloriesPerMinute) cal/min")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(KinexaTheme.secondaryText)
                    Text(workout.difficultyLevel)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(difficultyColor(workout.difficultyLevel))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(difficultyColor(workout.difficultyLevel).opacity(0.12))
                        .clipShape(Capsule())
                }
            }
            .padding(14)
            .background(KinexaTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16).stroke(KinexaTheme.border)
            }
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    private func difficultyColor(_ level: String) -> Color {
        switch level {
        case "Easy", "Beginner": return KinexaTheme.success
        case "Moderate": return KinexaTheme.accent
        case "Hard": return Color(hex: "#F59E0B")
        default: return KinexaTheme.tertiaryText
        }
    }
}
