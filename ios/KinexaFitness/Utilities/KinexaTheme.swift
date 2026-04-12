import SwiftUI

enum KinexaTheme {
    private static var colors: PaletteColors { ThemeManager.shared.colors }

    static var background: Color { colors.background }
    static var card: Color { colors.card }
    static var cardSoft: Color { colors.cardSoft }
    static var border: Color { Color.white.opacity(0.08) }
    static var accent: Color { colors.accent }
    static var accent2: Color { colors.accent2 }
    static var success: Color { colors.success }
    static var warning: Color { colors.warning }
    static var danger: Color { colors.danger }
    static var primaryText: Color { Color.white }
    static var secondaryText: Color { Color(hex: "#9CA3AF") }
    static var tertiaryText: Color { Color(hex: "#6B7280") }

    static var brandGreen: Color { colors.brandPrimary }
    static var brandGreenLight: Color { colors.brandPrimaryLight }
    static var brandGreenDark: Color { colors.brandPrimaryDark }
    static var slateAccent: Color { colors.slateAccent }
    static var heroAmber: Color { colors.heroAmber }

    static var heroGradient: LinearGradient {
        LinearGradient(
            colors: [
                colors.brandPrimary.opacity(0.95),
                colors.brandPrimaryLight.opacity(0.90)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var subtleGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.08),
                Color.clear
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var aftGradient: LinearGradient {
        LinearGradient(
            colors: [
                colors.brandPrimary,
                colors.brandPrimaryDark,
                colors.brandPrimaryDark.opacity(0.8)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var ptGradient: LinearGradient {
        LinearGradient(
            colors: [
                colors.accent.opacity(0.8),
                colors.accent.opacity(0.5)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var functionalGradient: LinearGradient {
        LinearGradient(
            colors: [
                colors.heroAmber.opacity(0.8),
                colors.heroAmber.opacity(0.5)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)

        let r, g, b: UInt64
        switch cleaned.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (255, 255, 255)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}
