import SwiftUI

struct ManualFoodEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    let onAdd: (FoodItem) -> Void

    @State private var name: String = ""
    @State private var quantity: String = ""
    @State private var calories: String = ""
    @State private var protein: String = ""
    @State private var carbs: String = ""
    @State private var fat: String = ""
    @State private var fiber: String = ""
    @State private var sugar: String = ""
    @State private var alcohol: String = ""

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (Int(calories) ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Food Info")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(KinexaTheme.secondaryText)

                        fieldRow(label: "Food Name", placeholder: "e.g. Grilled Chicken", text: $name, keyboard: .default)
                        fieldRow(label: "Serving Size", placeholder: "e.g. 6 oz, 1 cup", text: $quantity, keyboard: .default)
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        Text("Nutrition")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(KinexaTheme.secondaryText)

                        macroField(label: "Calories", text: $calories, unit: "cal", color: KinexaTheme.success)

                        HStack(spacing: 10) {
                            macroField(label: "Protein", text: $protein, unit: "g", color: Color(hex: "#3B82F6"))
                            macroField(label: "Carbs", text: $carbs, unit: "g", color: Color(hex: "#F59E0B"))
                            macroField(label: "Fat", text: $fat, unit: "g", color: Color(hex: "#EC4899"))
                        }

                        HStack(spacing: 10) {
                            macroField(label: "Fiber", text: $fiber, unit: "g", color: Color(hex: "#22C55E"))
                            macroField(label: "Sugar", text: $sugar, unit: "g", color: Color(hex: "#F97316"))
                            macroField(label: "Alcohol", text: $alcohol, unit: "g", color: Color(hex: "#A855F7"))
                        }
                    }

                    Button {
                        addFood()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Food")
                        }
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            LinearGradient(
                                colors: isValid ? [Color(hex: "#F59E0B"), Color(hex: "#D97706")] : [KinexaTheme.tertiaryText, KinexaTheme.tertiaryText],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(.rect(cornerRadius: 14))
                    }
                    .buttonStyle(PressScaleButtonStyle())
                    .disabled(!isValid)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .background(KinexaTheme.background.ignoresSafeArea())
            .navigationTitle("Manual Entry")
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
    }

    private func fieldRow(label: String, placeholder: String, text: Binding<String>, keyboard: UIKeyboardType) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption.weight(.bold))
                .foregroundStyle(KinexaTheme.tertiaryText)
            TextField(placeholder, text: text)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(KinexaTheme.primaryText)
                .keyboardType(keyboard)
                .padding(14)
                .background(KinexaTheme.card)
                .clipShape(.rect(cornerRadius: 12))
                .elevatedCardShadow()
                .overlay {
                    RoundedRectangle(cornerRadius: 12).stroke(KinexaTheme.border)
                }
        }
    }

    private func macroField(label: String, text: Binding<String>, unit: String, color: Color) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Circle()
                    .fill(color)
                    .frame(width: 6, height: 6)
                Text(label)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }
            HStack(spacing: 4) {
                TextField("0", text: text)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                Text(unit)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 10)
            .background(KinexaTheme.card)
            .clipShape(.rect(cornerRadius: 10))
            .elevatedCardShadow()
            .overlay {
                RoundedRectangle(cornerRadius: 10).stroke(KinexaTheme.border)
            }
        }
    }

    private func addFood() {
        let food = FoodItem(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            quantity: quantity.isEmpty ? "1 serving" : quantity,
            nutrition: NutritionInfo(
                calories: Int(calories) ?? 0,
                protein: Double(protein) ?? 0,
                carbs: Double(carbs) ?? 0,
                fat: Double(fat) ?? 0,
                fiber: Double(fiber) ?? 0,
                sugar: Double(sugar) ?? 0,
                alcohol: Double(alcohol) ?? 0
            ),
            source: .manual
        )
        onAdd(food)
        dismiss()
    }
}
