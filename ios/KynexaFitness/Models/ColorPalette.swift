import SwiftUI
import UIKit

nonisolated enum ColorPalette: String, CaseIterable, Identifiable, Codable, Sendable {
    case ocean
    case sunset
    case berry
    case sage
    case slate
    case ember
    case lavender
    case midnight

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .ocean: return "Ocean"
        case .sunset: return "Sunset"
        case .berry: return "Berry"
        case .sage: return "Sage"
        case .slate: return "Slate"
        case .ember: return "Ember"
        case .lavender: return "Lavender"
        case .midnight: return "Midnight"
        }
    }

    var previewColors: [Color] {
        let c = colors
        return [c.accent, c.accent2, c.heroAmber, c.success]
    }

    var colors: PaletteColors {
        let d = darkSpec
        let l = lightSpec
        return PaletteColors(
            background: dynamic(l.background, d.background),
            card: dynamic(l.card, d.card),
            cardSoft: dynamic(l.cardSoft, d.cardSoft),
            accent: dynamic(l.accent, d.accent),
            accent2: dynamic(l.accent2, d.accent2),
            success: dynamic(l.success, d.success),
            warning: dynamic(l.warning, d.warning),
            danger: dynamic(l.danger, d.danger),
            brandPrimary: dynamic(l.brandPrimary, d.brandPrimary),
            brandPrimaryLight: dynamic(l.brandPrimaryLight, d.brandPrimaryLight),
            brandPrimaryDark: dynamic(l.brandPrimaryDark, d.brandPrimaryDark),
            slateAccent: dynamic(l.slateAccent, d.slateAccent),
            heroAmber: dynamic(l.heroAmber, d.heroAmber)
        )
    }

    private func dynamic(_ light: String, _ dark: String) -> Color {
        let lightUI = UIColor.fromHex(light)
        let darkUI = UIColor.fromHex(dark)
        return Color(UIColor { trait in
            trait.userInterfaceStyle == .light ? lightUI : darkUI
        })
    }

    private var darkSpec: PaletteSpec {
        switch self {
        case .ocean:
            return PaletteSpec(
                background: "#0B1117", card: "#121A22", cardSoft: "#182230",
                accent: "#2E86DE", accent2: "#54A0FF",
                success: "#22C55E", warning: "#F0932B", danger: "#EF4444",
                brandPrimary: "#1B5A8A", brandPrimaryLight: "#2E86DE", brandPrimaryDark: "#134266",
                slateAccent: "#6C8EAD", heroAmber: "#F0932B"
            )
        case .sunset:
            return PaletteSpec(
                background: "#12100E", card: "#1C1815", cardSoft: "#24201B",
                accent: "#E17055", accent2: "#F39C7A",
                success: "#55EFC4", warning: "#FDCB6E", danger: "#FF6B6B",
                brandPrimary: "#D35400", brandPrimaryLight: "#E17055", brandPrimaryDark: "#A04000",
                slateAccent: "#B08968", heroAmber: "#FDCB6E"
            )
        case .berry:
            return PaletteSpec(
                background: "#100C14", card: "#1A1520", cardSoft: "#221C28",
                accent: "#A855F7", accent2: "#C084FC",
                success: "#34D399", warning: "#F59E0B", danger: "#F43F5E",
                brandPrimary: "#7C3AED", brandPrimaryLight: "#A855F7", brandPrimaryDark: "#5B21B6",
                slateAccent: "#9B8AB8", heroAmber: "#F472B6"
            )
        case .sage:
            return PaletteSpec(
                background: "#0E1210", card: "#161C18", cardSoft: "#1E261F",
                accent: "#4ADE80", accent2: "#6EE7A0",
                success: "#22C55E", warning: "#D4915E", danger: "#EF4444",
                brandPrimary: "#2D8B57", brandPrimaryLight: "#4ADE80", brandPrimaryDark: "#1A6B3C",
                slateAccent: "#7BA892", heroAmber: "#C4833B"
            )
        case .slate:
            return PaletteSpec(
                background: "#0F1114", card: "#181B20", cardSoft: "#20242A",
                accent: "#64748B", accent2: "#94A3B8",
                success: "#22C55E", warning: "#EAB308", danger: "#EF4444",
                brandPrimary: "#475569", brandPrimaryLight: "#64748B", brandPrimaryDark: "#334155",
                slateAccent: "#94A3B8", heroAmber: "#CBD5E1"
            )
        case .ember:
            return PaletteSpec(
                background: "#120D0B", card: "#1C1412", cardSoft: "#261C18",
                accent: "#EF4444", accent2: "#F87171",
                success: "#4ADE80", warning: "#FB923C", danger: "#DC2626",
                brandPrimary: "#B91C1C", brandPrimaryLight: "#EF4444", brandPrimaryDark: "#7F1D1D",
                slateAccent: "#B09080", heroAmber: "#FB923C"
            )
        case .lavender:
            return PaletteSpec(
                background: "#0E0D14", card: "#17161F", cardSoft: "#1F1E2A",
                accent: "#818CF8", accent2: "#A5B4FC",
                success: "#34D399", warning: "#FBBF24", danger: "#FB7185",
                brandPrimary: "#6366F1", brandPrimaryLight: "#818CF8", brandPrimaryDark: "#4338CA",
                slateAccent: "#9B99B0", heroAmber: "#E0B0FF"
            )
        case .midnight:
            return PaletteSpec(
                background: "#08090E", card: "#101218", cardSoft: "#181B24",
                accent: "#38BDF8", accent2: "#7DD3FC",
                success: "#4ADE80", warning: "#FBBF24", danger: "#F43F5E",
                brandPrimary: "#0284C7", brandPrimaryLight: "#38BDF8", brandPrimaryDark: "#075985",
                slateAccent: "#7C9DB5", heroAmber: "#38BDF8"
            )
        }
    }

    private var lightSpec: PaletteSpec {
        switch self {
        case .ocean:
            return PaletteSpec(
                background: "#F4F7FB", card: "#FFFFFF", cardSoft: "#EEF3F9",
                accent: "#1F6FB8", accent2: "#2E86DE",
                success: "#16A34A", warning: "#D97706", danger: "#DC2626",
                brandPrimary: "#1B5A8A", brandPrimaryLight: "#2E86DE", brandPrimaryDark: "#0F345A",
                slateAccent: "#5D7A98", heroAmber: "#D97706"
            )
        case .sunset:
            return PaletteSpec(
                background: "#FBF5F1", card: "#FFFFFF", cardSoft: "#F4EAE2",
                accent: "#C05A3C", accent2: "#E17055",
                success: "#059669", warning: "#D97706", danger: "#DC2626",
                brandPrimary: "#B34B1E", brandPrimaryLight: "#E17055", brandPrimaryDark: "#7A2E0B",
                slateAccent: "#8E6B4F", heroAmber: "#D97706"
            )
        case .berry:
            return PaletteSpec(
                background: "#F8F5FC", card: "#FFFFFF", cardSoft: "#F0E9F8",
                accent: "#8B3FDE", accent2: "#A855F7",
                success: "#059669", warning: "#D97706", danger: "#E11D48",
                brandPrimary: "#7C3AED", brandPrimaryLight: "#A855F7", brandPrimaryDark: "#4C1D95",
                slateAccent: "#7D6B94", heroAmber: "#DB2777"
            )
        case .sage:
            return PaletteSpec(
                background: "#F4F8F3", card: "#FFFFFF", cardSoft: "#E8F0E7",
                accent: "#2D8B57", accent2: "#16A34A",
                success: "#16A34A", warning: "#B45309", danger: "#DC2626",
                brandPrimary: "#1F6B43", brandPrimaryLight: "#2D8B57", brandPrimaryDark: "#134E2E",
                slateAccent: "#5D8571", heroAmber: "#B45309"
            )
        case .slate:
            return PaletteSpec(
                background: "#F4F5F7", card: "#FFFFFF", cardSoft: "#E8EAEE",
                accent: "#475569", accent2: "#64748B",
                success: "#16A34A", warning: "#CA8A04", danger: "#DC2626",
                brandPrimary: "#334155", brandPrimaryLight: "#475569", brandPrimaryDark: "#1E293B",
                slateAccent: "#64748B", heroAmber: "#A1A1AA"
            )
        case .ember:
            return PaletteSpec(
                background: "#FBF5F3", card: "#FFFFFF", cardSoft: "#F5E7E3",
                accent: "#DC2626", accent2: "#EF4444",
                success: "#16A34A", warning: "#D97706", danger: "#B91C1C",
                brandPrimary: "#B91C1C", brandPrimaryLight: "#DC2626", brandPrimaryDark: "#7F1D1D",
                slateAccent: "#8C6A5E", heroAmber: "#D97706"
            )
        case .lavender:
            return PaletteSpec(
                background: "#F6F5FC", card: "#FFFFFF", cardSoft: "#ECEAF7",
                accent: "#4F46E5", accent2: "#6366F1",
                success: "#059669", warning: "#D97706", danger: "#E11D48",
                brandPrimary: "#4338CA", brandPrimaryLight: "#6366F1", brandPrimaryDark: "#312E81",
                slateAccent: "#7876A0", heroAmber: "#9333EA"
            )
        case .midnight:
            return PaletteSpec(
                background: "#F3F6FA", card: "#FFFFFF", cardSoft: "#E7EEF5",
                accent: "#0369A1", accent2: "#0284C7",
                success: "#16A34A", warning: "#D97706", danger: "#E11D48",
                brandPrimary: "#075985", brandPrimaryLight: "#0284C7", brandPrimaryDark: "#0C4A6E",
                slateAccent: "#5F7E94", heroAmber: "#0284C7"
            )
        }
    }
}

nonisolated struct PaletteSpec: Sendable {
    let background: String
    let card: String
    let cardSoft: String
    let accent: String
    let accent2: String
    let success: String
    let warning: String
    let danger: String
    let brandPrimary: String
    let brandPrimaryLight: String
    let brandPrimaryDark: String
    let slateAccent: String
    let heroAmber: String
}

nonisolated struct PaletteColors: Sendable {
    let background: Color
    let card: Color
    let cardSoft: Color
    let accent: Color
    let accent2: Color
    let success: Color
    let warning: Color
    let danger: Color
    let brandPrimary: Color
    let brandPrimaryLight: Color
    let brandPrimaryDark: Color
    let slateAccent: Color
    let heroAmber: Color
}
