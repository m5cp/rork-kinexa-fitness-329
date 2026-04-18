import SwiftUI

struct LogCardioSessionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var vm

    let workout: CardioWorkoutDefinition

    @State private var durationMinutes: Int = 30
    @State private var caloriesBurned: String = ""
    @State private var distanceMiles: String = ""
    @State private var notes: String = ""
    @State private var logTrigger: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    heroHeader
                    durationSection
                    if workout.isDistanceBased {
                        distanceSection
                    }
                    caloriesSection
                    notesSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
            .background(KinexaTheme.background.ignoresSafeArea())
            .navigationTitle("Log \(workout.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(KinexaTheme.background, for: .navigationBar)
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(KinexaTheme.secondaryText)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Log") {
                        logSession()
                    }
                    .font(.headline.weight(.bold))
                    .foregroundStyle(KinexaTheme.accent)
                }
            }
            .sensoryFeedback(.success, trigger: logTrigger)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(KinexaTheme.background)
    }

    private var heroHeader: some View {
        HStack(spacing: 16) {
            Image(systemName: workout.icon)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(
                    LinearGradient(
                        colors: [Color(hex: workout.category.gradientHex.0), Color(hex: workout.category.gradientHex.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 4) {
                Text(workout.name)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)
                Text(workout.category.rawValue)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }
            Spacer()
        }
    }

    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DURATION")
                .font(.caption.weight(.heavy))
                .tracking(1.2)
                .foregroundStyle(KinexaTheme.tertiaryText)

            HStack(spacing: 12) {
                ForEach([15, 30, 45, 60], id: \.self) { mins in
                    Button {
                        durationMinutes = mins
                    } label: {
                        Text("\(mins) min")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(durationMinutes == mins ? .white : KinexaTheme.secondaryText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(durationMinutes == mins ? KinexaTheme.accent : KinexaTheme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(durationMinutes == mins ? KinexaTheme.accent : KinexaTheme.border)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }

            Stepper("Custom: \(durationMinutes) min", value: $durationMinutes, in: 5...180, step: 5)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(KinexaTheme.secondaryText)
                .padding(14)
                .background(KinexaTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .elevatedCardShadow()
                .overlay {
                    RoundedRectangle(cornerRadius: 14).stroke(KinexaTheme.border)
                }
        }
    }

    private var distanceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("DISTANCE (MILES)")
                .font(.caption.weight(.heavy))
                .tracking(1.2)
                .foregroundStyle(KinexaTheme.tertiaryText)

            TextField("e.g. 3.1", text: $distanceMiles)
                .keyboardType(.decimalPad)
                .font(.body)
                .foregroundStyle(KinexaTheme.primaryText)
                .padding(14)
                .background(KinexaTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .elevatedCardShadow()
                .overlay {
                    RoundedRectangle(cornerRadius: 14).stroke(KinexaTheme.border)
                }
        }
    }

    private var caloriesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CALORIES BURNED (OPTIONAL)")
                .font(.caption.weight(.heavy))
                .tracking(1.2)
                .foregroundStyle(KinexaTheme.tertiaryText)

            let estimated = durationMinutes * workout.estimatedCaloriesPerMinute

            TextField("Est. ~\(estimated) cal", text: $caloriesBurned)
                .keyboardType(.numberPad)
                .font(.body)
                .foregroundStyle(KinexaTheme.primaryText)
                .padding(14)
                .background(KinexaTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .elevatedCardShadow()
                .overlay {
                    RoundedRectangle(cornerRadius: 14).stroke(KinexaTheme.border)
                }
        }
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("NOTES (OPTIONAL)")
                .font(.caption.weight(.heavy))
                .tracking(1.2)
                .foregroundStyle(KinexaTheme.tertiaryText)

            TextField("How did it feel?", text: $notes, axis: .vertical)
                .lineLimit(3...6)
                .font(.body)
                .foregroundStyle(KinexaTheme.primaryText)
                .padding(14)
                .background(KinexaTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .elevatedCardShadow()
                .overlay {
                    RoundedRectangle(cornerRadius: 14).stroke(KinexaTheme.border)
                }
        }
    }

    private func logSession() {
        let cals = Int(caloriesBurned) ?? (durationMinutes * workout.estimatedCaloriesPerMinute)
        let dist = Double(distanceMiles)

        let session = CardioSession(
            workoutName: workout.name,
            category: workout.category.rawValue,
            durationMinutes: durationMinutes,
            caloriesBurned: cals,
            distanceMiles: dist,
            notes: notes
        )

        vm.logCardioSession(session)
        logTrigger.toggle()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            dismiss()
        }
    }
}
