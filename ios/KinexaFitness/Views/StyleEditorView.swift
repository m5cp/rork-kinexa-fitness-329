import SwiftUI

struct StyleEditorView: View {
    @State private var themeManager = ThemeManager.shared
    @State private var selectedPalette: ColorPalette = ThemeManager.shared.currentPalette
    @AppStorage("appearanceMode") private var appearanceModeRaw = AppearanceMode.system.rawValue
    @State private var changeTrigger: Bool = false

    private var appearanceMode: AppearanceMode {
        AppearanceMode(rawValue: appearanceModeRaw) ?? .system
    }

    var body: some View {
        ZStack {
            KinexaTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    appearanceSection
                    palettePicker
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
        .sensoryFeedback(.impact(weight: .medium), trigger: changeTrigger)
    }

    private var appearanceSection: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                Image(systemName: "circle.lefthalf.filled")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(KinexaTheme.tertiaryText)
                Text("APPEARANCE")
                    .font(.caption.weight(.bold))
                    .tracking(0.8)
                    .foregroundStyle(KinexaTheme.tertiaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
            .padding(.bottom, 10)

            HStack(spacing: 8) {
                ForEach(AppearanceMode.allCases) { mode in
                    appearanceButton(mode)
                }
            }
        }
    }

    private func appearanceButton(_ mode: AppearanceMode) -> some View {
        let isSelected = appearanceMode == mode
        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                appearanceModeRaw = mode.rawValue
                changeTrigger.toggle()
            }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: mode.iconName)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(isSelected ? KinexaTheme.accent : KinexaTheme.secondaryText)
                Text(mode.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(isSelected ? KinexaTheme.primaryText : KinexaTheme.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? KinexaTheme.accent.opacity(0.12) : KinexaTheme.card)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isSelected ? KinexaTheme.accent.opacity(0.5) : KinexaTheme.border,
                        lineWidth: isSelected ? 1.5 : 1
                    )
            }
        }
        .buttonStyle(PressScaleButtonStyle())
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
                        .foregroundStyle(KinexaTheme.primaryText)

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
                        isSelected ? colors.accent : KinexaTheme.border,
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
}
