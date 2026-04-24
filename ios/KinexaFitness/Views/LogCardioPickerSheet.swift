import SwiftUI

struct LogCardioPickerSheet: View {
    @Environment(AppViewModel.self) private var vm
    @Environment(\.dismiss) private var dismiss

    private struct CardioActivity {
        let name: String
        let icon: String
        let category: String
        let isDistanceBased: Bool
    }

    private let activities: [CardioActivity] = [
        CardioActivity(name: "Walk",        icon: "figure.walk",           category: "Low Impact",      isDistanceBased: true),
        CardioActivity(name: "Run",         icon: "figure.run",            category: "Running",         isDistanceBased: true),
        CardioActivity(name: "Cycle",       icon: "figure.outdoor.cycle",  category: "Cycling",         isDistanceBased: true),
        CardioActivity(name: "Swim",        icon: "figure.pool.swim",      category: "Low Impact",      isDistanceBased: false),
        CardioActivity(name: "Row",         icon: "figure.rowing",         category: "HIIT & Intervals",isDistanceBased: false),
        CardioActivity(name: "Hike",        icon: "figure.hiking",         category: "Outdoor",         isDistanceBased: true),
        CardioActivity(name: "Jump Rope",   icon: "figure.jumprope",       category: "HIIT & Intervals",isDistanceBased: false),
        CardioActivity(name: "Stair Climb", icon: "figure.stairs",         category: "Low Impact",      isDistanceBased: false),
        CardioActivity(name: "Other",       icon: "bolt.heart.fill",       category: "Class Workouts",  isDistanceBased: false),
    ]

    @State private var selectedActivity: CardioActivity?
    @State private var customName: String = ""
    @State private var durationMinutes: Int = 30
    @State private var distanceMiles: String = ""
    @State private var caloriesBurned: String = ""
    @State private var notes: String = ""
    @State private var saveTrigger: Bool = false

    private let accentColor = Color(hex: "#10B981")

    private var effectiveName: String {
        guard let act = selectedActivity else { return "" }
        if act.name == "Other" { return customName.isEmpty ? "Cardio" : customName }
        return act.name
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    activityPickerSection
                    if selectedActivity != nil {
                        loggingSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 48)
            }
            .background(KinexaTheme.background.ignoresSafeArea())
            .navigationTitle("Log Cardio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(KinexaTheme.background, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(KinexaTheme.secondaryText)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Log") { logSession() }
                        .font(.headline.weight(.bold))
                        .foregroundStyle(selectedActivity != nil ? accentColor : KinexaTheme.tertiaryText)
                        .disabled(selectedActivity == nil)
                }
            }
            .sensoryFeedback(.success, trigger: saveTrigger)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(KinexaTheme.background)
    }

    private var activityPickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CHOOSE ACTIVITY")
                .font(.caption.weight(.heavy))
                .tracking(1.2)
                .foregroundStyle(KinexaTheme.tertiaryText)
                .padding(.leading, 4)

            let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(activities, id: \.name) { activity in
                    activityTile(activity)
                }
            }

            if selectedActivity?.name == "Other" {
                TextField("Activity name (e.g. Zumba)", text: $customName)
                    .padding(12)
                    .background(KinexaTheme.cardSoft)
                    .clipShape(.rect(cornerRadius: 10))
                    .foregroundStyle(KinexaTheme.primaryText)
            }
        }
    }

    private func activityTile(_ activity: CardioActivity) -> some View {
        let isSelected = selectedActivity?.name == activity.name
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedActivity = activity
            }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: activity.icon)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(isSelected ? .white : accentColor)
                    .frame(width: 40, height: 40)
                    .background(isSelected ? accentColor : accentColor.opacity(0.12))
                    .clipShape(.rect(cornerRadius: 10))
                Text(activity.name)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(KinexaTheme.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(KinexaTheme.card)
            .clipShape(.rect(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? accentColor : KinexaTheme.border, lineWidth: isSelected ? 1.5 : 0.5)
            }
            .scaleEffect(isSelected ? 1.03 : 1.0)
        }
        .buttonStyle(.plain)
    }

    private var loggingSection: some View {
        VStack(spacing: 16) {
            Text("LOG DETAILS")
                .font(.caption.weight(.heavy))
                .tracking(1.2)
                .foregroundStyle(KinexaTheme.tertiaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 4)

            detailCard {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Duration")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(KinexaTheme.secondaryText)
                    HStack {
                        Text("\(durationMinutes) min")
                            .font(.system(size: 24, weight: .heavy, design: .rounded))
                            .foregroundStyle(KinexaTheme.primaryText)
                            .contentTransition(.numericText())
                        Spacer()
                        Stepper("", value: $durationMinutes, in: 1...300, step: 5)
                            .labelsHidden()
                    }
                    Slider(value: Binding(
                        get: { Double(durationMinutes) },
                        set: { durationMinutes = Int($0) }
                    ), in: 1...120, step: 5)
                    .tint(accentColor)
                }
            }

            if selectedActivity?.isDistanceBased == true {
                detailCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Distance (miles)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(KinexaTheme.secondaryText)
                        HStack(spacing: 8) {
                            TextField("0.0", text: $distanceMiles)
                                .font(.system(size: 24, weight: .heavy, design: .rounded))
                                .foregroundStyle(KinexaTheme.primaryText)
                                .keyboardType(.decimalPad)
                            Text("mi")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(KinexaTheme.tertiaryText)
                            Spacer()
                        }
                    }
                }
            }

            detailCard {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Calories Burned (optional)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(KinexaTheme.secondaryText)
                    HStack(spacing: 8) {
                        TextField("\(durationMinutes * 8)", text: $caloriesBurned)
                            .font(.system(size: 24, weight: .heavy, design: .rounded))
                            .foregroundStyle(KinexaTheme.primaryText)
                            .keyboardType(.numberPad)
                        Text("cal")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(KinexaTheme.tertiaryText)
                        Spacer()
                    }
                }
            }

            detailCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes (optional)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(KinexaTheme.secondaryText)
                    TextField("How did it go?", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                        .foregroundStyle(KinexaTheme.primaryText)
                }
            }

            Button { logSession() } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.headline)
                    Text("Log \(effectiveName)")
                        .font(.headline.weight(.bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(accentColor)
                }
            }
            .buttonStyle(PressScaleButtonStyle())
        }
    }

    private func detailCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(KinexaTheme.card)
            .clipShape(.rect(cornerRadius: 14))
            .overlay { RoundedRectangle(cornerRadius: 14).stroke(KinexaTheme.border) }
    }

    private func logSession() {
        guard let activity = selectedActivity else { return }
        saveTrigger.toggle()
        let session = CardioSession(
            workoutName: effectiveName,
            category: activity.category,
            durationMinutes: durationMinutes,
            caloriesBurned: Int(caloriesBurned),
            distanceMiles: Double(distanceMiles),
            notes: notes
        )
        vm.logCardioSession(session)
        dismiss()
    }
}
