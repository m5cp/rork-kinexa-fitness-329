import SwiftUI
import UIKit

enum KinexaTheme {
    private static var colors: PaletteColors { ThemeManager.shared.colors }

    static var background: Color { colors.background }
    static var card: Color { colors.card }
    static var cardSoft: Color { colors.cardSoft }
    static var border: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .light
                ? UIColor.black.withAlphaComponent(0.09)
                : UIColor.white.withAlphaComponent(0.08)
        })
    }
    static var cardShadow: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .light
                ? UIColor.black.withAlphaComponent(0.08)
                : UIColor.black.withAlphaComponent(0.35)
        })
    }
    static var accent: Color { colors.accent }
    static var accent2: Color { colors.accent2 }
    static var success: Color { colors.success }
    static var warning: Color { colors.warning }
    static var danger: Color { colors.danger }
    static var primaryText: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .light
                ? UIColor(red: 0.07, green: 0.09, blue: 0.12, alpha: 1)
                : UIColor.white
        })
    }
    static var secondaryText: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .light
                ? UIColor(red: 0.38, green: 0.42, blue: 0.49, alpha: 1)
                : UIColor(red: 0.61, green: 0.64, blue: 0.69, alpha: 1)
        })
    }
    static var tertiaryText: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .light
                ? UIColor(red: 0.55, green: 0.58, blue: 0.63, alpha: 1)
                : UIColor(red: 0.42, green: 0.45, blue: 0.50, alpha: 1)
        })
    }

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

    init(lightHex: String, darkHex: String) {
        let light = UIColor.fromHex(lightHex)
        let dark = UIColor.fromHex(darkHex)
        self = Color(UIColor { trait in
            trait.userInterfaceStyle == .light ? light : dark
        })
    }
}

extension UIColor {
    static func fromHex(_ hex: String) -> UIColor {
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
        return UIColor(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: 1)
    }
}
