import SwiftUI

struct RingGoalsSheet: View {
    let ringsVM: ReflectionRingsViewModel
    let nutritionVM: NutritionViewModel
    var focusRing: RingType? = nil

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let focus = focusRing {
                        ringCard(focus)
                    } else {
                        ForEach(RingType.allCases) { ring in
                            ringCard(ring)
                        }
                    }

                    Button {
                        ringsVM.resetGoalsToDefault()
                        nutritionVM.updateWaterGoal(WaterGoal(dailyOunces: RingGoals.defaultWaterOunces))
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset to Defaults")
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(KinexaTheme.accent)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(KinexaTheme.accent.opacity(0.12))
                        .clipShape(.rect(cornerRadius: 14))
                    }
                    .padding(.top, 4)
                }
                .padding(20)
            }
            .background(KinexaTheme.background.ignoresSafeArea())
            .navigationTitle(focusRing?.title ?? "Ring Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(KinexaTheme.accent)
                }
            }
            .toolbarBackground(KinexaTheme.background, for: .navigationBar)
        }
        .presentationDetents(focusRing == nil ? [.large] : [.medium, .large])
        .presentationDragIndicator(.visible)
    }

    @ViewBuilder
    private func ringCard(_ ring: RingType) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: ring.icon)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(ring.color)
                    .frame(width: 40, height: 40)
                    .background(ring.color.opacity(0.15))
                    .clipShape(.rect(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text(ring.title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)
                    Text(ringDescription(ring))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }
                Spacer(minLength: 0)
            }

            controls(for: ring)
        }
        .padding(16)
        .background(KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18).stroke(KinexaTheme.border)
        }
    }

    private func ringDescription(_ ring: RingType) -> String {
        switch ring {
        case .fitness: return "Close by hitting your step goal or logging a workout"
        case .meals: return "Close by logging this many meals today"
        case .water: return "Close by hitting your daily water goal"
        case .mood: return "Close by logging your hours of sleep"
        }
    }

    @ViewBuilder
    private func controls(for ring: RingType) -> some View {
        switch ring {
        case .fitness:
            stepGoalControls
        case .meals:
            mealsGoalControls
        case .water:
            waterGoalControls
        case .mood:
            sleepGoalControls
        }
    }

    private var sleepGoalControls: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(ringsVM.goals.sleepHours)")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(KinexaTheme.primaryText)
                    .contentTransition(.numericText())
                Text("hrs to close ring")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(KinexaTheme.tertiaryText)
                Spacer()
                Stepper("", value: Binding(
                    get: { ringsVM.goals.sleepHours },
                    set: { ringsVM.updateSleepGoal($0) }
                ), in: RingGoals.sleepRange)
                .labelsHidden()
            }
            Text("Range: \(RingGoals.sleepRange.lowerBound)–\(RingGoals.sleepRange.upperBound) hours")
                .font(.caption.weight(.medium))
                .foregroundStyle(KinexaTheme.tertiaryText)
        }
    }

    private var stepGoalControls: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(ringsVM.goals.moveSteps)")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(KinexaTheme.primaryText)
                    .contentTransition(.numericText())
                Text("steps")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(KinexaTheme.tertiaryText)
                Spacer()
                Stepper("", value: Binding(
                    get: { ringsVM.goals.moveSteps },
                    set: { ringsVM.updateMoveSteps($0) }
                ), in: RingGoals.moveRange, step: RingGoals.moveStep)
                .labelsHidden()
            }

            Slider(
                value: Binding(
                    get: { Double(ringsVM.goals.moveSteps) },
                    set: { ringsVM.updateMoveSteps(Int($0)) }
                ),
                in: Double(RingGoals.moveRange.lowerBound)...Double(RingGoals.moveRange.upperBound),
                step: Double(RingGoals.moveStep)
            )
            .tint(RingType.fitness.color)
        }
    }

    private var mealsGoalControls: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text("\(ringsVM.goals.meals)")
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundStyle(KinexaTheme.primaryText)
                .contentTransition(.numericText())
            Text("meal\(ringsVM.goals.meals == 1 ? "" : "s")")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(KinexaTheme.tertiaryText)
            Spacer()
            Stepper("", value: Binding(
                get: { ringsVM.goals.meals },
                set: { ringsVM.updateMealsGoal($0) }
            ), in: RingGoals.mealsRange)
            .labelsHidden()
        }
    }

    private var waterGoalControls: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(Int(nutritionVM.waterGoal.dailyOunces))")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(KinexaTheme.primaryText)
                    .contentTransition(.numericText())
                Text("oz")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(KinexaTheme.tertiaryText)
                Spacer()
                Stepper("", value: Binding(
                    get: { nutritionVM.waterGoal.dailyOunces },
                    set: { nutritionVM.updateWaterGoal(WaterGoal(dailyOunces: min(max($0, RingGoals.waterRange.lowerBound), RingGoals.waterRange.upperBound))) }
                ), in: RingGoals.waterRange, step: RingGoals.waterStep)
                .labelsHidden()
            }

            Slider(
                value: Binding(
                    get: { nutritionVM.waterGoal.dailyOunces },
                    set: { nutritionVM.updateWaterGoal(WaterGoal(dailyOunces: $0)) }
                ),
                in: RingGoals.waterRange,
                step: RingGoals.waterStep
            )
            .tint(RingType.water.color)
        }
    }
}
