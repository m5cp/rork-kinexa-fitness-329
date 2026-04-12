import SwiftUI

struct NutritionProfileSheet: View {
    let nutritionVM: NutritionViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var age: String = "30"
    @State private var sex: BiologicalSex = .male
    @State private var heightFeet: String = "5"
    @State private var heightInches: String = "9"
    @State private var heightCm: String = "175"
    @State private var weightLbs: String = "176"
    @State private var weightKg: String = "80"
    @State private var activityLevel: ActivityLevel = .moderatelyActive
    @State private var goalType: NutritionGoalType = .maintain
    @State private var heightUnit: HeightUnit = .imperial
    @State private var weightUnit: WeightUnit = .lbs
    @State private var currentStep: Int = 0

    private let totalSteps = 4

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                stepIndicator
                    .padding(.top, 8)
                    .padding(.horizontal, 20)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        switch currentStep {
                        case 0: basicInfoStep
                        case 1: bodyMeasurementsStep
                        case 2: activityStep
                        case 3: goalAndReviewStep
                        default: EmptyView()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 120)
                }

                navigationButtons
            }
            .background(KinexaTheme.background.ignoresSafeArea())
            .navigationTitle("Nutrition Profile")
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
        .onAppear { loadExistingProfile() }
    }

    private var stepIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Capsule()
                    .fill(step <= currentStep ? KinexaTheme.accent : KinexaTheme.cardSoft)
                    .frame(height: 4)
            }
        }
    }

    private var basicInfoStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            stepHeader(icon: "person.fill", title: "About You", subtitle: "Basic info to calculate your calorie needs")

            VStack(alignment: .leading, spacing: 14) {
                Text("Age")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(KinexaTheme.secondaryText)

                HStack(spacing: 12) {
                    TextField("30", text: $age)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)
                        .keyboardType(.numberPad)
                        .frame(width: 80)
                    Text("years old")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                    Spacer()
                }
                .padding(16)
                .background(KinexaTheme.card)
                .clipShape(.rect(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(KinexaTheme.border)
                }
            }

            VStack(alignment: .leading, spacing: 14) {
                Text("Biological Sex")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(KinexaTheme.secondaryText)

                HStack(spacing: 12) {
                    ForEach(BiologicalSex.allCases, id: \.rawValue) { option in
                        let isSelected = sex == option
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                sex = option
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: option.icon)
                                    .font(.headline.weight(.bold))
                                Text(option.rawValue)
                                    .font(.subheadline.weight(.bold))
                            }
                            .foregroundStyle(isSelected ? .white : KinexaTheme.secondaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isSelected ? KinexaTheme.accent : KinexaTheme.card)
                            .clipShape(.rect(cornerRadius: 14))
                            .overlay {
                                if !isSelected {
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(KinexaTheme.border)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var bodyMeasurementsStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            stepHeader(icon: "ruler.fill", title: "Body Measurements", subtitle: "Used to calculate your BMR and calorie needs")

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Height")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(KinexaTheme.secondaryText)
                    Spacer()
                    Picker("", selection: $heightUnit) {
                        ForEach(HeightUnit.allCases, id: \.rawValue) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 120)
                }

                if heightUnit == .imperial {
                    HStack(spacing: 12) {
                        HStack(spacing: 6) {
                            TextField("5", text: $heightFeet)
                                .font(.title2.weight(.bold))
                                .foregroundStyle(KinexaTheme.primaryText)
                                .keyboardType(.numberPad)
                                .frame(width: 50)
                            Text("ft")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(KinexaTheme.tertiaryText)
                        }
                        HStack(spacing: 6) {
                            TextField("9", text: $heightInches)
                                .font(.title2.weight(.bold))
                                .foregroundStyle(KinexaTheme.primaryText)
                                .keyboardType(.numberPad)
                                .frame(width: 50)
                            Text("in")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(KinexaTheme.tertiaryText)
                        }
                        Spacer()
                    }
                    .padding(16)
                    .background(KinexaTheme.card)
                    .clipShape(.rect(cornerRadius: 14))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14).stroke(KinexaTheme.border)
                    }
                } else {
                    HStack(spacing: 8) {
                        TextField("175", text: $heightCm)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(KinexaTheme.primaryText)
                            .keyboardType(.decimalPad)
                            .frame(width: 80)
                        Text("cm")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(KinexaTheme.tertiaryText)
                        Spacer()
                    }
                    .padding(16)
                    .background(KinexaTheme.card)
                    .clipShape(.rect(cornerRadius: 14))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14).stroke(KinexaTheme.border)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Weight")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(KinexaTheme.secondaryText)
                    Spacer()
                    Picker("", selection: $weightUnit) {
                        ForEach(WeightUnit.allCases, id: \.rawValue) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 120)
                }

                HStack(spacing: 8) {
                    TextField(weightUnit == .lbs ? "176" : "80", text: weightUnit == .lbs ? $weightLbs : $weightKg)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)
                        .keyboardType(.decimalPad)
                        .frame(width: 80)
                    Text(weightUnit.rawValue)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                    Spacer()
                }
                .padding(16)
                .background(KinexaTheme.card)
                .clipShape(.rect(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14).stroke(KinexaTheme.border)
                }
            }
        }
    }

    private var activityStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            stepHeader(icon: "flame.fill", title: "Activity Level", subtitle: "How active are you outside of planned workouts?")

            VStack(spacing: 10) {
                ForEach(ActivityLevel.allCases, id: \.rawValue) { level in
                    let isSelected = activityLevel == level
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            activityLevel = level
                        }
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(isSelected ? KinexaTheme.accent.opacity(0.2) : KinexaTheme.cardSoft)
                                    .frame(width: 44, height: 44)
                                Image(systemName: level.icon)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(isSelected ? KinexaTheme.accent : KinexaTheme.tertiaryText)
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                Text(level.rawValue)
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(isSelected ? KinexaTheme.primaryText : KinexaTheme.secondaryText)
                                Text(level.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(KinexaTheme.tertiaryText)
                            }

                            Spacer()

                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(KinexaTheme.accent)
                            }
                        }
                        .padding(14)
                        .background(isSelected ? KinexaTheme.accent.opacity(0.08) : KinexaTheme.card)
                        .clipShape(.rect(cornerRadius: 16))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isSelected ? KinexaTheme.accent.opacity(0.3) : KinexaTheme.border)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var goalAndReviewStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            stepHeader(icon: "target", title: "Your Goal", subtitle: "Choose your primary nutrition goal")

            HStack(spacing: 10) {
                ForEach(NutritionGoalType.allCases, id: \.rawValue) { goal in
                    let isSelected = goalType == goal
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            goalType = goal
                        }
                    } label: {
                        VStack(spacing: 10) {
                            Image(systemName: goal.icon)
                                .font(.title2.weight(.bold))
                                .foregroundStyle(isSelected ? .white : Color(hex: goal.color))
                            Text(goal.rawValue)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(isSelected ? .white : KinexaTheme.primaryText)
                            Text(goal.subtitle)
                                .font(.system(size: 9, weight: .medium))
                                .foregroundStyle(isSelected ? .white.opacity(0.8) : KinexaTheme.tertiaryText)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .padding(.horizontal, 8)
                        .background(isSelected ? Color(hex: goal.color) : KinexaTheme.card)
                        .clipShape(.rect(cornerRadius: 16))
                        .overlay {
                            if !isSelected {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(KinexaTheme.border)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            calculatedResultsCard
        }
    }

    private var calculatedResultsCard: some View {
        let profile = buildProfile()
        return VStack(spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.fill")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(KinexaTheme.success)
                Text("Your Calculated Targets")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)
                Spacer()
            }

            VStack(spacing: 12) {
                HStack {
                    Text("BMR")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                    Spacer()
                    Text("\(Int(profile.bmr)) cal/day")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(KinexaTheme.secondaryText)
                }

                HStack {
                    Text("TDEE")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(KinexaTheme.tertiaryText)
                    Spacer()
                    Text("\(Int(profile.tdee)) cal/day")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(KinexaTheme.secondaryText)
                }

                Rectangle()
                    .fill(KinexaTheme.border)
                    .frame(height: 0.5)

                HStack {
                    Text("Daily Target")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(KinexaTheme.primaryText)
                    Spacer()
                    Text("\(profile.calorieTarget) cal")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(KinexaTheme.success)
                }

                HStack(spacing: 16) {
                    targetMacro("Protein", grams: profile.proteinGrams, color: Color(hex: "#3B82F6"))
                    targetMacro("Carbs", grams: profile.carbsGrams, color: Color(hex: "#F59E0B"))
                    targetMacro("Fat", grams: profile.fatGrams, color: Color(hex: "#EC4899"))
                }
            }
        }
        .padding(18)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(KinexaTheme.card)
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [KinexaTheme.success.opacity(0.05), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: 20)
                    .stroke(KinexaTheme.success.opacity(0.15))
            }
        }
        .clipShape(.rect(cornerRadius: 20))
    }

    private func targetMacro(_ label: String, grams: Double, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(Int(grams))g")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(KinexaTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private var navigationButtons: some View {
        HStack(spacing: 12) {
            if currentStep > 0 {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        currentStep -= 1
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(KinexaTheme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(KinexaTheme.card)
                    .clipShape(.rect(cornerRadius: 14))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14).stroke(KinexaTheme.border)
                    }
                }
                .buttonStyle(.plain)
            }

            Button {
                if currentStep < totalSteps - 1 {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        currentStep += 1
                    }
                } else {
                    saveProfile()
                }
            } label: {
                HStack(spacing: 6) {
                    Text(currentStep == totalSteps - 1 ? "Save Profile" : "Next")
                    Image(systemName: currentStep == totalSteps - 1 ? "checkmark" : "chevron.right")
                }
                .font(.subheadline.weight(.bold))
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
        .padding(.vertical, 12)
        .background {
            KinexaTheme.background
                .overlay(alignment: .top) {
                    Rectangle().fill(KinexaTheme.border).frame(height: 0.5)
                }
                .ignoresSafeArea(edges: .bottom)
        }
    }

    private func stepHeader(icon: String, title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(KinexaTheme.accent)
                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(KinexaTheme.primaryText)
            }
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(KinexaTheme.tertiaryText)
        }
    }

    private func buildProfile() -> NutritionProfile {
        let heightInCm: Double
        if heightUnit == .imperial {
            let ft = Double(heightFeet) ?? 5
            let inches = Double(heightInches) ?? 9
            heightInCm = (ft * 12 + inches) * 2.54
        } else {
            heightInCm = Double(heightCm) ?? 175
        }

        let weightInKg: Double
        if weightUnit == .lbs {
            weightInKg = (Double(weightLbs) ?? 176) / 2.20462
        } else {
            weightInKg = Double(weightKg) ?? 80
        }

        return NutritionProfile(
            age: Int(age) ?? 30,
            sex: sex,
            heightCm: heightInCm,
            weightKg: weightInKg,
            activityLevel: activityLevel,
            goalType: goalType,
            heightUnit: heightUnit,
            weightUnit: weightUnit,
            isConfigured: true
        )
    }

    private func saveProfile() {
        let profile = buildProfile()
        nutritionVM.updateProfile(profile)
        nutritionVM.updateGoal(profile.calculatedGoal)
        dismiss()
    }

    private func loadExistingProfile() {
        let profile = nutritionVM.profile
        age = "\(profile.age)"
        sex = profile.sex
        heightUnit = profile.heightUnit
        weightUnit = profile.weightUnit
        activityLevel = profile.activityLevel
        goalType = profile.goalType

        if heightUnit == .imperial {
            heightFeet = "\(profile.heightFeet)"
            heightInches = "\(profile.heightInches)"
        } else {
            heightCm = String(format: "%.0f", profile.heightCm)
        }

        if weightUnit == .lbs {
            weightLbs = String(format: "%.0f", profile.weightLbs)
        } else {
            weightKg = String(format: "%.0f", profile.weightKg)
        }
    }
}
