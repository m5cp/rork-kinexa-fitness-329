import SwiftUI

struct NutritionGoalSheet: View {
    let nutritionVM: NutritionViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var calories: String = ""
    @State private var protein: String = ""
    @State private var carbs: String = ""
    @State private var fat: String = ""

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Image(systemName: "target")
                            .font(.system(size: 36))
                            .foregroundStyle(KinexaTheme.accent)
                        Text("Daily Nutrition Goals")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(KinexaTheme.primaryText)
                        Text("Set your daily targets for calories and macros")
                            .font(.caption)
                            .foregroundStyle(KinexaTheme.tertiaryText)
                    }
                    .padding(.top, 8)

                    VStack(spacing: 16) {
                        goalField(label: "Calories", placeholder: "2200", text: $calories, unit: "cal", color: KinexaTheme.success)
                        goalField(label: "Protein", placeholder: "150", text: $protein, unit: "g", color: Color(hex: "#3B82F6"))
                        goalField(label: "Carbs", placeholder: "250", text: $carbs, unit: "g", color: Color(hex: "#F59E0B"))
                        goalField(label: "Fat", placeholder: "75", text: $fat, unit: "g", color: Color(hex: "#EC4899"))
                    }

                    presetButtons

                    Button {
                        saveGoals()
                    } label: {
                        Text("Save Goals")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                LinearGradient(
                                    colors: [KinexaTheme.accent, KinexaTheme.brandGreenLight],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(.rect(cornerRadius: 14))
                    }
                    .buttonStyle(PressScaleButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .background(KinexaTheme.background.ignoresSafeArea())
            .navigationTitle("Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(KinexaTheme.secondaryText)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onAppear {
            let goal = nutritionVM.dailyGoal
            calories = "\(goal.calories)"
            protein = String(format: "%.0f", goal.protein)
            carbs = String(format: "%.0f", goal.carbs)
            fat = String(format: "%.0f", goal.fat)
        }
    }

    private func goalField(label: String, placeholder: String, text: Binding<String>, unit: String, color: Color) -> some View {
        HStack(spacing: 14) {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay {
                    Text(String(label.prefix(1)))
                        .font(.headline.weight(.black))
                        .foregroundStyle(color)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(KinexaTheme.secondaryText)
                HStack(spacing: 4) {
                    TextField(placeholder, text: text)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)
                        .keyboardType(.numberPad)
                    Text(unit)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                }
            }

            Spacer()
        }
        .padding(14)
        .background(KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 14))
        .elevatedCardShadow()
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(KinexaTheme.border)
        }
    }

    private var presetButtons: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Presets")
                .font(.caption.weight(.bold))
                .foregroundStyle(KinexaTheme.tertiaryText)

            HStack(spacing: 8) {
                presetButton("Cut", cal: 1800, p: 180, c: 150, f: 60)
                presetButton("Maintain", cal: 2200, p: 150, c: 250, f: 75)
                presetButton("Bulk", cal: 2800, p: 180, c: 330, f: 85)
            }
        }
    }

    private func presetButton(_ label: String, cal: Int, p: Double, c: Double, f: Double) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                calories = "\(cal)"
                protein = String(format: "%.0f", p)
                carbs = String(format: "%.0f", c)
                fat = String(format: "%.0f", f)
            }
        } label: {
            Text(label)
                .font(.caption.weight(.bold))
                .foregroundStyle(KinexaTheme.primaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(KinexaTheme.cardSoft)
                .clipShape(.rect(cornerRadius: 10))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(KinexaTheme.border)
                }
        }
        .buttonStyle(.plain)
    }

    private func saveGoals() {
        let goal = DailyNutritionGoal(
            calories: Int(calories) ?? 2200,
            protein: Double(protein) ?? 150,
            carbs: Double(carbs) ?? 250,
            fat: Double(fat) ?? 75
        )
        nutritionVM.updateGoal(goal)
        dismiss()
    }
}
