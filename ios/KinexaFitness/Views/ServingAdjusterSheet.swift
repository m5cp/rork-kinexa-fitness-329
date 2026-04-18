import SwiftUI

struct ServingAdjusterSheet: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let foods: [FoodItem]
    let defaultMealType: MealType
    let onConfirm: (Double, MealType) -> Void

    @State private var multiplier: Double = 1.0
    @State private var mealType: MealType
    @State private var isSaving: Bool = false

    init(title: String, foods: [FoodItem], defaultMealType: MealType, onConfirm: @escaping (Double, MealType) -> Void) {
        self.title = title
        self.foods = foods
        self.defaultMealType = defaultMealType
        self.onConfirm = onConfirm
        _mealType = State(initialValue: defaultMealType)
    }

    private let presets: [Double] = [0.5, 1.0, 1.5, 2.0]

    private var scaledTotals: NutritionInfo {
        let m = multiplier
        let cals = foods.map(\.nutrition.calories).reduce(0, +)
        let p = foods.map(\.nutrition.protein).reduce(0, +)
        let c = foods.map(\.nutrition.carbs).reduce(0, +)
        let f = foods.map(\.nutrition.fat).reduce(0, +)
        let fi = foods.map(\.nutrition.fiber).reduce(0, +)
        let s = foods.map(\.nutrition.sugar).reduce(0, +)
        let a = foods.map(\.nutrition.alcohol).reduce(0, +)
        return NutritionInfo(
            calories: Int((Double(cals) * m).rounded()),
            protein: p * m,
            carbs: c * m,
            fat: f * m,
            fiber: fi * m,
            sugar: s * m,
            alcohol: a * m
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    header
                    mealTypeRow
                    servingCard
                    totalsCard
                    itemsList
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(KinexaTheme.background.ignoresSafeArea())
            .navigationTitle("Adjust Serving")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(KinexaTheme.secondaryText)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        guard !isSaving else { return }
                        isSaving = true
                        onConfirm(multiplier, mealType)
                        dismiss()
                    } label: {
                        Text("Log")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(KinexaTheme.success)
                    }
                    .disabled(isSaving)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(KinexaTheme.primaryText)
            Text("Scale the serving before logging. Values update automatically.")
                .font(.caption)
                .foregroundStyle(KinexaTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var mealTypeRow: some View {
        HStack(spacing: 8) {
            ForEach(MealType.allCases, id: \.rawValue) { type in
                let isSelected = mealType == type
                Button {
                    mealType = type
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: type.icon)
                            .font(.system(size: 14, weight: .bold))
                        Text(type.rawValue)
                            .font(.system(size: 9, weight: .bold))
                    }
                    .foregroundStyle(isSelected ? .white : Color(hex: type.color))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(isSelected ? Color(hex: type.color) : Color(hex: type.color).opacity(0.12))
                    .clipShape(.rect(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var servingCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Serving Size")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(KinexaTheme.secondaryText)
                Spacer()
                Text(String(format: "%.2fx", multiplier))
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(KinexaTheme.accent)
                    .contentTransition(.numericText())
            }

            HStack(spacing: 8) {
                ForEach(presets, id: \.self) { preset in
                    let isSelected = abs(multiplier - preset) < 0.01
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            multiplier = preset
                        }
                    } label: {
                        Text(preset == 1.0 ? "1×" : String(format: "%.1f×", preset))
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(isSelected ? .white : KinexaTheme.primaryText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(isSelected ? KinexaTheme.accent : KinexaTheme.cardSoft)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }

            Slider(value: $multiplier, in: 0.25...3.0, step: 0.05)
                .tint(KinexaTheme.accent)
        }
        .padding(16)
        .background(KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 16))
        .elevatedCardShadow()
        .overlay {
            RoundedRectangle(cornerRadius: 16).stroke(KinexaTheme.border)
        }
    }

    private var totalsCard: some View {
        let t = scaledTotals
        return VStack(spacing: 10) {
            HStack {
                Text("Total")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(KinexaTheme.secondaryText)
                Spacer()
                Text("\(t.calories) cal")
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundStyle(KinexaTheme.primaryText)
                    .contentTransition(.numericText())
            }
            HStack(spacing: 10) {
                macroPill("P", value: t.protein, color: Color(hex: "#3B82F6"))
                macroPill("C", value: t.carbs, color: Color(hex: "#F59E0B"))
                macroPill("F", value: t.fat, color: Color(hex: "#EC4899"))
                if t.alcohol > 0 {
                    macroPill("A", value: t.alcohol, color: Color(hex: "#A855F7"))
                }
            }
        }
        .padding(16)
        .background(KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 16))
        .elevatedCardShadow()
        .overlay {
            RoundedRectangle(cornerRadius: 16).stroke(KinexaTheme.border)
        }
    }

    private func macroPill(_ label: String, value: Double, color: Color) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .black))
                .foregroundStyle(color)
            Text("\(Int(value))g")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(KinexaTheme.primaryText)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
    }

    private var itemsList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Items")
                .font(.caption.weight(.bold))
                .foregroundStyle(KinexaTheme.tertiaryText)
            ForEach(foods) { food in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(food.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(KinexaTheme.primaryText)
                        Text(food.quantity)
                            .font(.caption)
                            .foregroundStyle(KinexaTheme.tertiaryText)
                    }
                    Spacer()
                    Text("\(Int(Double(food.nutrition.calories) * multiplier)) cal")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(KinexaTheme.secondaryText)
                        .contentTransition(.numericText())
                }
                .padding(12)
                .background(KinexaTheme.cardSoft)
                .clipShape(.rect(cornerRadius: 12))
            }
        }
    }
}
