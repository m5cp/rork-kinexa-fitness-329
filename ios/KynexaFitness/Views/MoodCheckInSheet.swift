import SwiftUI

struct SleepCheckInSheet: View {
    let ringsVM: ReflectionRingsViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedHours: Int?
    @State private var saveTrigger: Bool = false

    private let sleepColor = RingType.mood.color
    private let hourOptions = [1, 2, 3, 4, 5, 6, 7, 8]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    VStack(spacing: 8) {
                        Text("How did you sleep?")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(KynexaTheme.primaryText)
                        Text("Log your hours to close the Rest ring")
                            .font(.subheadline)
                            .foregroundStyle(KynexaTheme.secondaryText)
                    }
                    .padding(.top, 12)

                    VStack(spacing: 10) {
                        HStack(spacing: 10) {
                            ForEach(hourOptions.prefix(4), id: \.self) { h in
                                hourTile(h)
                            }
                        }
                        HStack(spacing: 10) {
                            ForEach(Array(hourOptions.dropFirst(4)), id: \.self) { h in
                                hourTile(h)
                            }
                        }
                    }

                    HStack(spacing: 6) {
                        Image(systemName: "moon.fill")
                            .font(.caption)
                            .foregroundStyle(sleepColor)
                        Text("Ring closes at \(ringsVM.goals.sleepHours)+ hrs")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(KynexaTheme.tertiaryText)
                        Spacer()
                        if let h = selectedHours {
                            let closes = h >= ringsVM.goals.sleepHours
                            Label(
                                closes ? "Ring closes!" : "\(ringsVM.goals.sleepHours - h) hrs to go",
                                systemImage: closes ? "checkmark.circle.fill" : "moon.zzz.fill"
                            )
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(closes ? KynexaTheme.success : sleepColor)
                        }
                    }
                    .padding(.horizontal, 4)

                    Button {
                        guard let h = selectedHours else { return }
                        saveTrigger.toggle()
                        ringsVM.logSleep(hours: h)
                        dismiss()
                    } label: {
                        Text("Log Sleep")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(selectedHours != nil ? sleepColor : KynexaTheme.cardSoft)
                            }
                    }
                    .disabled(selectedHours == nil)
                    .opacity(selectedHours == nil ? 0.5 : 1)
                    .sensoryFeedback(.success, trigger: saveTrigger)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .background(KynexaTheme.background.ignoresSafeArea())
            .navigationTitle("Sleep Check-In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(KynexaTheme.accent)
                }
            }
            .toolbarBackground(KynexaTheme.background, for: .navigationBar)
        }
        .onAppear {
            if let existing = ringsVM.todaySleep {
                selectedHours = existing.hours
            }
        }
    }

    private func hourTile(_ hours: Int) -> some View {
        let isSelected = selectedHours == hours
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedHours = hours
            }
        } label: {
            VStack(spacing: 6) {
                Text(hours >= 8 ? "8+" : "\(hours)")
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundStyle(isSelected ? .white : KynexaTheme.primaryText)
                Text(hours == 1 ? "hr" : "hrs")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(isSelected ? .white.opacity(0.85) : KynexaTheme.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background {
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? sleepColor : KynexaTheme.cardSoft)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? sleepColor : KynexaTheme.border, lineWidth: 1)
            }
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(hours >= 8 ? "8 or more hours" : "\(hours) hour\(hours == 1 ? "" : "s")")
    }
}
