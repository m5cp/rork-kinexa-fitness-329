import SwiftUI

struct WaterTrackerCard: View {
    let nutritionVM: NutritionViewModel
    @State private var showWaterGoalEdit: Bool = false
    @State private var animateWave: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "drop.fill")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color(hex: "#38BDF8"))
                    Text("Water")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(KynexaTheme.primaryText)
                }
                Spacer()
                Button {
                    showWaterGoalEdit = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(KynexaTheme.tertiaryText)
                }
            }

            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Color(hex: "#38BDF8").opacity(0.15), lineWidth: 8)
                        .frame(width: 70, height: 70)
                    Circle()
                        .trim(from: 0, to: animateWave ? nutritionVM.waterProgress : 0)
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "#38BDF8"), Color(hex: "#0EA5E9")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 70, height: 70)
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 1) {
                        Text("\(Int(nutritionVM.todayWaterOunces))")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(KynexaTheme.primaryText)
                            .contentTransition(.numericText())
                        Text("oz")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(KynexaTheme.tertiaryText)
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("\(Int(nutritionVM.waterGoal.dailyOunces - nutritionVM.todayWaterOunces)) oz remaining")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(nutritionVM.todayWaterOunces >= nutritionVM.waterGoal.dailyOunces ? KynexaTheme.success : Color(hex: "#38BDF8"))

                    HStack(spacing: 8) {
                        waterQuickButton(oz: 8, label: "Glass")
                        waterQuickButton(oz: 16, label: "Bottle")
                        waterQuickButton(oz: 24, label: "Large")
                    }

                    if nutritionVM.todayWaterOunces > 0 {
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                nutritionVM.removeLastWater()
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "minus.circle")
                                    .font(.system(size: 10, weight: .bold))
                                Text("Undo last")
                                    .font(.system(size: 10, weight: .semibold))
                            }
                            .foregroundStyle(KynexaTheme.tertiaryText)
                        }
                    }
                }

                Spacer()
            }
        }
        .padding(18)
        .background(KynexaTheme.card)
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(KynexaTheme.border)
        }
        .clipShape(.rect(cornerRadius: 20))
        .elevatedCardShadow()
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.5)) {
                animateWave = true
            }
        }
        .alert("Daily Water Goal", isPresented: $showWaterGoalEdit) {
            TextField("Ounces", text: .constant(""))
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showWaterGoalEdit) {
            WaterGoalSheet(nutritionVM: nutritionVM)
        }
    }

    private func waterQuickButton(oz: Double, label: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                nutritionVM.addWater(oz)
            }
        } label: {
            VStack(spacing: 2) {
                Text("+\(Int(oz))")
                    .font(.system(size: 12, weight: .bold))
                Text(label)
                    .font(.system(size: 8, weight: .semibold))
            }
            .foregroundStyle(Color(hex: "#38BDF8"))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(hex: "#38BDF8").opacity(0.12))
            .clipShape(.rect(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(weight: .light), trigger: nutritionVM.todayWaterOunces)
    }
}

struct WaterGoalSheet: View {
    let nutritionVM: NutritionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var goalText: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Color(hex: "#38BDF8"))
                    Text("Daily Water Goal")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(KynexaTheme.primaryText)
                }
                .padding(.top, 16)

                HStack(spacing: 8) {
                    TextField("100", text: $goalText)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(KynexaTheme.primaryText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .frame(width: 120)
                    Text("oz")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(KynexaTheme.tertiaryText)
                }
                .padding(20)
                .background(KynexaTheme.card)
                .clipShape(.rect(cornerRadius: 16))
                .elevatedCardShadow()
                .overlay {
                    RoundedRectangle(cornerRadius: 16).stroke(KynexaTheme.border)
                }

                HStack(spacing: 10) {
                    presetButton(64)
                    presetButton(80)
                    presetButton(100)
                    presetButton(128)
                }

                Button {
                    let oz = Double(goalText) ?? 100
                    nutritionVM.updateWaterGoal(WaterGoal(dailyOunces: max(16, oz)))
                    dismiss()
                } label: {
                    Text("Save")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#38BDF8"), Color(hex: "#0EA5E9")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(.rect(cornerRadius: 14))
                }
                .buttonStyle(PressScaleButtonStyle())

                Spacer()
            }
            .padding(.horizontal, 20)
            .background(KynexaTheme.background.ignoresSafeArea())
            .navigationTitle("Water Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(KynexaTheme.secondaryText)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .onAppear {
            goalText = "\(Int(nutritionVM.waterGoal.dailyOunces))"
        }
    }

    private func presetButton(_ oz: Int) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                goalText = "\(oz)"
            }
        } label: {
            Text("\(oz) oz")
                .font(.caption.weight(.bold))
                .foregroundStyle(KynexaTheme.primaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(KynexaTheme.cardSoft)
                .clipShape(.rect(cornerRadius: 10))
                .overlay {
                    RoundedRectangle(cornerRadius: 10).stroke(KynexaTheme.border)
                }
        }
        .buttonStyle(.plain)
    }
}
