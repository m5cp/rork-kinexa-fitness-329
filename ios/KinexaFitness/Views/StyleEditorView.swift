import SwiftUI

struct StyleEditorView: View {
    @State private var themeManager = ThemeManager.shared
    @State private var selectedPalette: ColorPalette = ThemeManager.shared.currentPalette
    @State private var changeTrigger: Bool = false

    var body: some View {
        ZStack {
            KinexaTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    previewCard

                    palettePicker

                    syncInfo
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
                .adaptiveContainer()
            }
        }
        .navigationTitle("Style Editor")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(KinexaTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sensoryFeedback(.impact(weight: .medium), trigger: changeTrigger)
    }

    private var previewCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                Image(systemName: "paintpalette.fill")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(KinexaTheme.tertiaryText)
                Text("PREVIEW")
                    .font(.caption.weight(.bold))
                    .tracking(0.8)
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
            .padding(.bottom, 10)

            VStack(spacing: 16) {
                HStack(spacing: 14) {
                    Circle()
                        .fill(KinexaTheme.accent.opacity(0.15))
                        .frame(width: 48, height: 48)
                        .overlay {
                            Image(systemName: "figure.run")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(KinexaTheme.accent)
                        }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Morning Run")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(KinexaTheme.primaryText)
                        Text("30 min · 3.2 mi")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(KinexaTheme.secondaryText)
                    }

                    Spacer()

                    Image(systemName: "play.fill")
                        .font(.body.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(KinexaTheme.heroGradient)
                        .clipShape(Circle())
                }

                HStack(spacing: 8) {
                    previewStat(value: "12", label: "Streak", color: KinexaTheme.warning)
                    previewStat(value: "5", label: "This Week", color: KinexaTheme.success)
                    previewStat(value: "142", label: "Cardio Min", color: KinexaTheme.heroAmber)
                }

                HStack(spacing: 10) {
                    Text("Start Workout")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(KinexaTheme.heroGradient)
                        .clipShape(.rect(cornerRadius: 12))

                    Text("Browse")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(KinexaTheme.accent)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(KinexaTheme.accent.opacity(0.12))
                        .clipShape(.rect(cornerRadius: 12))
                }
            }
            .padding(18)
            .background(KinexaTheme.card)
            .clipShape(.rect(cornerRadius: 20))
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(KinexaTheme.border)
            }
        }
    }

    private func previewStat(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(KinexaTheme.primaryText)
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(KinexaTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(KinexaTheme.cardSoft)
        .clipShape(.rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.15))
        }
    }

    private var palettePicker: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                Image(systemName: "swatchpalette.fill")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(KinexaTheme.tertiaryText)
                Text("COLOR SCHEME")
                    .font(.caption.weight(.bold))
                    .tracking(0.8)
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
            .padding(.bottom, 10)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(ColorPalette.allCases) { palette in
                    paletteCard(palette)
                }
            }
        }
    }

    private func paletteCard(_ palette: ColorPalette) -> some View {
        let isSelected = selectedPalette == palette
        let colors = palette.colors

        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                selectedPalette = palette
                themeManager.currentPalette = palette
                changeTrigger.toggle()
            }
        } label: {
            VStack(spacing: 12) {
                HStack(spacing: 6) {
                    ForEach(Array(palette.previewColors.enumerated()), id: \.offset) { _, color in
                        Circle()
                            .fill(color)
                            .frame(width: 20, height: 20)
                    }
                }

                VStack(spacing: 4) {
                    Text(palette.displayName)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.white)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [colors.brandPrimary, colors.brandPrimaryLight],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 4)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .background(colors.card)
            .clipShape(.rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? colors.accent : Color.white.opacity(0.06),
                        lineWidth: isSelected ? 2 : 1
                    )
            }
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.body.weight(.bold))
                        .foregroundStyle(colors.accent)
                        .background(Circle().fill(colors.card).padding(-2))
                        .offset(x: -8, y: 8)
                }
            }
        }
        .buttonStyle(PressScaleButtonStyle())
    }

    private var syncInfo: some View {
        HStack(spacing: 12) {
            Image(systemName: "applewatch")
                .font(.title3.weight(.semibold))
                .foregroundStyle(KinexaTheme.accent)
                .frame(width: 40, height: 40)
                .background(KinexaTheme.accent.opacity(0.12))
                .clipShape(.rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 3) {
                Text("Apple Watch Sync")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(KinexaTheme.primaryText)
                Text("Your color scheme syncs automatically via shared storage")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(KinexaTheme.tertiaryText)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(KinexaTheme.card)
        .clipShape(.rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(KinexaTheme.border)
        }
    }
}
