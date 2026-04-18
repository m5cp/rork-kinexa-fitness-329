import SwiftUI

struct StandaloneWorkoutDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var vm

    let workout: WorkoutDay

    @State private var completeTrigger: Bool = false

    var body: some View {
        ZStack {
            KinexaTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    headerCard

                    ForEach(workout.exercises, id: \.id) { exercise in
                        exerciseCard(exercise)
                    }

                    if !workout.isCompleted {
                        Button {
                            completeTrigger.toggle()
                            vm.completeStandaloneWorkout(workout)
                            dismiss()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.subheadline.weight(.bold))
                                Text("Mark Complete")
                                    .font(.headline.weight(.bold))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "#2563EB"), Color(hex: "#1D4ED8")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(PressScaleButtonStyle())
                    }
                }
                .padding(20)
                .padding(.bottom, 40)
                .adaptiveContainer()
            }
        }
        .navigationTitle(workout.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(KinexaTheme.background, for: .navigationBar)
        
        .sensoryFeedback(.success, trigger: completeTrigger)
    }

    private var headerCard: some View {
        VStack(spacing: 14) {
            Image(systemName: "person.3.fill")
                .font(.title.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#2563EB"), Color(hex: "#1D4ED8")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 18))

            Text(workout.title)
                .font(.title3.weight(.bold))
                .foregroundStyle(KinexaTheme.primaryText)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Label("\(workout.exercises.count) blocks", systemImage: "list.bullet")
                if let start = workout.startTime {
                    Label(start.formatted(date: .omitted, time: .shortened), systemImage: "clock")
                }
                if let end = workout.endTime {
                    Label("to \(end.formatted(date: .omitted, time: .shortened))", systemImage: "clock.badge.checkmark")
                }
            }
            .font(.caption.weight(.medium))
            .foregroundStyle(KinexaTheme.secondaryText)

            if workout.isCompleted {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Completed")
                }
                .font(.subheadline.weight(.bold))
                .foregroundStyle(KinexaTheme.success)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(KinexaTheme.card)
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(KinexaTheme.border)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .elevatedCardShadow()
    }

    private func exerciseCard(_ exercise: WorkoutExercise) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(exercise.name)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)

                Spacer()

                if exercise.isTimeBased {
                    let mins = exercise.durationSeconds / 60
                    Text(mins > 0 ? "\(mins) min" : "\(exercise.durationSeconds)s")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(KinexaTheme.accent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(KinexaTheme.accent.opacity(0.1))
                        .clipShape(Capsule())
                } else if exercise.reps > 0 {
                    Text(exercise.displayDetail)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(KinexaTheme.accent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(KinexaTheme.accent.opacity(0.1))
                        .clipShape(Capsule())
                }
            }

            if !exercise.notes.isEmpty {
                Text(exercise.notes)
                    .font(.caption)
                    .foregroundStyle(KinexaTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(KinexaTheme.card)
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(KinexaTheme.border)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .elevatedCardShadow()
    }
}
