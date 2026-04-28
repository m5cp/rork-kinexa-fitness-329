import SwiftUI

struct PressScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .brightness(configuration.isPressed ? -0.05 : 0)
            .animation(.spring(response: 0.15, dampingFraction: 0.7), value: configuration.isPressed)
            .sensoryFeedback(.impact(weight: .medium, intensity: 0.6), trigger: configuration.isPressed)
    }
}

extension View {
    @ViewBuilder
    func liquidGlass(in shape: some Shape = Capsule(), tint: Color? = nil, prominent: Bool = false) -> some View {
        if #available(iOS 26.0, *) {
            if prominent, let tint {
                self.glassEffect(.regular.tint(tint).interactive(), in: shape)
            } else if let tint {
                self.glassEffect(.regular.tint(tint.opacity(0.35)).interactive(), in: shape)
            } else {
                self.glassEffect(.regular.interactive(), in: shape)
            }
        } else {
            self.background {
                shape.fill(.ultraThinMaterial)
                    .overlay { shape.fill((tint ?? .clear).opacity(prominent ? 0.85 : 0.18)) }
                    .overlay { shape.stroke(.white.opacity(0.18), lineWidth: 0.5) }
            }
        }
    }
}

extension View {
    func premiumCardStyle() -> some View {
        self
            .background(KynexaTheme.card)
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(KynexaTheme.border)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.25), radius: 18, y: 10)
    }

    func premiumCard() -> some View {
        self.premiumCardStyle()
    }

    func elevatedCardShadow() -> some View {
        self.shadow(color: KynexaTheme.cardShadow, radius: 4, y: 2)
    }

    func adaptiveWidth() -> some View {
        self.frame(maxWidth: 700)
    }

    func adaptiveContainer() -> some View {
        self
            .frame(maxWidth: 700)
            .frame(maxWidth: .infinity)
    }
}
