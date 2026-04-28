import SwiftUI

struct CardioWorkoutDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let workout: CardioWorkoutDefinition
    var onAdd: ((CardioWorkoutDefinition) -> Void)?
    var onLog: ((CardioWorkoutDefinition) -> Void)?

    var body: some View {
        let gradient = [Color(hex: workout.category.gradientHex.0), Color(hex: workout.category.gradientHex.1)]
        let guide = CardioGuideLibrary.guide(for: workout)

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    heroCard(gradient: gradient)

                    statsRow

                    section(title: "ABOUT") {
                        Text(workout.description)
                            .font(.subheadline)
                            .foregroundStyle(KynexaTheme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    section(title: "WHAT IT IS") {
                        Text(guide.whatIsIt)
                            .font(.subheadline)
                            .foregroundStyle(KynexaTheme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    section(title: "HOW TO DO IT") {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(Array(guide.howTo.enumerated()), id: \.offset) { idx, step in
                                HStack(alignment: .top, spacing: 10) {
                                    Text("\(idx + 1)")
                                        .font(.caption.weight(.heavy))
                                        .foregroundStyle(.white)
                                        .frame(width: 22, height: 22)
                                        .background(Color(hex: workout.category.gradientHex.0))
                                        .clipShape(Circle())
                                    Text(step)
                                        .font(.subheadline)
                                        .foregroundStyle(KynexaTheme.secondaryText)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }

                    section(title: "ALTERNATIVES") {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(guide.alternatives, id: \.self) { alt in
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: "arrow.triangle.swap")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(Color(hex: workout.category.gradientHex.0))
                                    Text(alt)
                                        .font(.subheadline)
                                        .foregroundStyle(KynexaTheme.secondaryText)
                                }
                            }
                        }
                    }

                    VStack(spacing: 10) {
                        if let onLog {
                            Button {
                                onLog(workout)
                                dismiss()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Log This Workout").font(.headline.weight(.bold))
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                                .clipShape(.rect(cornerRadius: 14))
                            }
                            .buttonStyle(PressScaleButtonStyle())
                        }
                        if let onAdd {
                            Button {
                                onAdd(workout)
                                dismiss()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add to Routine").font(.headline.weight(.bold))
                                }
                                .foregroundStyle(Color(hex: workout.category.gradientHex.0))
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(KynexaTheme.card)
                                .clipShape(.rect(cornerRadius: 14))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color(hex: workout.category.gradientHex.0).opacity(0.5), lineWidth: 1.5)
                                }
                            }
                            .buttonStyle(PressScaleButtonStyle())
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(KynexaTheme.background.ignoresSafeArea())
            .navigationTitle(workout.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(KynexaTheme.background, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(KynexaTheme.accent)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(KynexaTheme.background)
    }

    private func heroCard(gradient: [Color]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                Image(systemName: workout.icon)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(.white.opacity(0.2))
                    .clipShape(.rect(cornerRadius: 14))
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.category.rawValue.uppercased())
                        .font(.caption2.weight(.heavy))
                        .tracking(1.0)
                        .foregroundStyle(.white.opacity(0.8))
                    Text(workout.name)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                }
                Spacer()
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
        .clipShape(.rect(cornerRadius: 20))
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            statPill(icon: "flame.fill", label: workout.difficultyLevel)
            statPill(icon: "bolt.fill", label: "~\(workout.estimatedCaloriesPerMinute) cal/min")
            if workout.usesGPS {
                statPill(icon: "location.fill", label: "GPS")
            }
        }
    }

    private func statPill(icon: String, label: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon).font(.caption2.weight(.bold))
            Text(label).font(.caption.weight(.semibold))
        }
        .foregroundStyle(KynexaTheme.secondaryText)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(KynexaTheme.card)
        .clipShape(Capsule())
        .overlay { Capsule().stroke(KynexaTheme.border) }
    }

    @ViewBuilder
    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption.weight(.heavy))
                .tracking(1.0)
                .foregroundStyle(KynexaTheme.tertiaryText)
            content()
        }
    }
}
