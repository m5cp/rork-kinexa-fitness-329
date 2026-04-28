import SwiftUI

struct WaterQuickAddSheet: View {
    @Environment(\.dismiss) private var dismiss
    let nutritionVM: NutritionViewModel

    @State private var customAmount: String = ""
    @State private var logTrigger: Bool = false

    private let presets: [(oz: Double, label: String, icon: String)] = [
        (8, "Glass", "cup.and.saucer.fill"),
        (16, "Bottle", "waterbottle.fill"),
        (24, "Large", "drop.fill")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    hero
                    quickAddGrid
                    customSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .background(KynexaTheme.background.ignoresSafeArea())
            .navigationTitle("Log Water")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(KynexaTheme.background, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(KynexaTheme.accent)
                }
            }
            .sensoryFeedback(.success, trigger: logTrigger)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationBackground(KynexaTheme.background)
    }

    private var hero: some View {
        let goal = nutritionVM.waterGoal.dailyOunces
        let current = nutritionVM.todayWaterOunces
        let progress = goal > 0 ? min(current / goal, 1.0) : 0
        let waterColor = Color(hex: "#38BDF8")

        return HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(waterColor.opacity(0.15), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: max(0.001, progress))
                    .stroke(waterColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Image(systemName: "drop.fill")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(waterColor)
            }
            .frame(width: 64, height: 64)

            VStack(alignment: .leading, spacing: 3) {
                Text("\(Int(current)) of \(Int(goal)) oz")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(KynexaTheme.primaryText)
                    .contentTransition(.numericText())
                Text(current >= goal ? "Goal reached — nice work" : "\(Int(max(goal - current, 0))) oz to goal")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(KynexaTheme.tertiaryText)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(KynexaTheme.card)
        .clipShape(.rect(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18).stroke(KynexaTheme.border)
        }
    }

    private var quickAddGrid: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("QUICK ADD")
                .font(.caption.weight(.heavy))
                .tracking(1.2)
                .foregroundStyle(KynexaTheme.tertiaryText)
                .padding(.leading, 4)

            HStack(spacing: 10) {
                ForEach(presets, id: \.oz) { preset in
                    Button {
                        nutritionVM.addWater(preset.oz)
                        logTrigger.toggle()
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: preset.icon)
                                .font(.title3.weight(.bold))
                                .foregroundStyle(Color(hex: "#38BDF8"))
                                .frame(width: 42, height: 42)
                                .background(Color(hex: "#38BDF8").opacity(0.12))
                                .clipShape(.rect(cornerRadius: 11))
                            Text("\(Int(preset.oz)) oz")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(KynexaTheme.primaryText)
                            Text(preset.label)
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(KynexaTheme.tertiaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(KynexaTheme.card)
                        .clipShape(.rect(cornerRadius: 16))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16).stroke(KynexaTheme.border)
                        }
                    }
                    .buttonStyle(PressScaleButtonStyle())
                }
            }
        }
    }

    private var customSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CUSTOM AMOUNT")
                .font(.caption.weight(.heavy))
                .tracking(1.2)
                .foregroundStyle(KynexaTheme.tertiaryText)
                .padding(.leading, 4)

            HStack(spacing: 10) {
                TextField("oz", text: $customAmount)
                    .keyboardType(.decimalPad)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(KynexaTheme.primaryText)
                    .padding(14)
                    .background(KynexaTheme.card)
                    .clipShape(.rect(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12).stroke(KynexaTheme.border)
                    }

                Button {
                    if let oz = Double(customAmount), oz > 0 {
                        nutritionVM.addWater(oz)
                        customAmount = ""
                        logTrigger.toggle()
                    }
                } label: {
                    Text("Add")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#38BDF8"), Color(hex: "#0284C7")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(.rect(cornerRadius: 12))
                }
                .buttonStyle(PressScaleButtonStyle())
                .disabled(Double(customAmount) ?? 0 <= 0)
                .opacity((Double(customAmount) ?? 0) > 0 ? 1 : 0.5)
            }
        }
    }
}
