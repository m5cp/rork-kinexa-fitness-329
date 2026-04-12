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
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sensoryFeedback(.impact(weight: .medium), trigger: changeTrigger)
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


}
