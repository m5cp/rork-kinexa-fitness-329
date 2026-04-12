import SwiftUI

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
        switch self {
        case .ocean:
            return PaletteColors(
                background: Color(hex: "#0B1117"),
                card: Color(hex: "#121A22"),
                cardSoft: Color(hex: "#182230"),
                accent: Color(hex: "#2E86DE"),
                accent2: Color(hex: "#54A0FF"),
                success: Color(hex: "#22C55E"),
                warning: Color(hex: "#F0932B"),
                danger: Color(hex: "#EF4444"),
                brandPrimary: Color(hex: "#1B5A8A"),
                brandPrimaryLight: Color(hex: "#2E86DE"),
                brandPrimaryDark: Color(hex: "#134266"),
                slateAccent: Color(hex: "#6C8EAD"),
                heroAmber: Color(hex: "#F0932B")
            )
        case .sunset:
            return PaletteColors(
                background: Color(hex: "#12100E"),
                card: Color(hex: "#1C1815"),
                cardSoft: Color(hex: "#24201B"),
                accent: Color(hex: "#E17055"),
                accent2: Color(hex: "#F39C7A"),
                success: Color(hex: "#55EFC4"),
                warning: Color(hex: "#FDCB6E"),
                danger: Color(hex: "#FF6B6B"),
                brandPrimary: Color(hex: "#D35400"),
                brandPrimaryLight: Color(hex: "#E17055"),
                brandPrimaryDark: Color(hex: "#A04000"),
                slateAccent: Color(hex: "#B08968"),
                heroAmber: Color(hex: "#FDCB6E")
            )
        case .berry:
            return PaletteColors(
                background: Color(hex: "#100C14"),
                card: Color(hex: "#1A1520"),
                cardSoft: Color(hex: "#221C28"),
                accent: Color(hex: "#A855F7"),
                accent2: Color(hex: "#C084FC"),
                success: Color(hex: "#34D399"),
                warning: Color(hex: "#F59E0B"),
                danger: Color(hex: "#F43F5E"),
                brandPrimary: Color(hex: "#7C3AED"),
                brandPrimaryLight: Color(hex: "#A855F7"),
                brandPrimaryDark: Color(hex: "#5B21B6"),
                slateAccent: Color(hex: "#9B8AB8"),
                heroAmber: Color(hex: "#F472B6")
            )
        case .sage:
            return PaletteColors(
                background: Color(hex: "#0E1210"),
                card: Color(hex: "#161C18"),
                cardSoft: Color(hex: "#1E261F"),
                accent: Color(hex: "#4ADE80"),
                accent2: Color(hex: "#6EE7A0"),
                success: Color(hex: "#22C55E"),
                warning: Color(hex: "#D4915E"),
                danger: Color(hex: "#EF4444"),
                brandPrimary: Color(hex: "#2D8B57"),
                brandPrimaryLight: Color(hex: "#4ADE80"),
                brandPrimaryDark: Color(hex: "#1A6B3C"),
                slateAccent: Color(hex: "#7BA892"),
                heroAmber: Color(hex: "#C4833B")
            )
        case .slate:
            return PaletteColors(
                background: Color(hex: "#0F1114"),
                card: Color(hex: "#181B20"),
                cardSoft: Color(hex: "#20242A"),
                accent: Color(hex: "#64748B"),
                accent2: Color(hex: "#94A3B8"),
                success: Color(hex: "#22C55E"),
                warning: Color(hex: "#EAB308"),
                danger: Color(hex: "#EF4444"),
                brandPrimary: Color(hex: "#475569"),
                brandPrimaryLight: Color(hex: "#64748B"),
                brandPrimaryDark: Color(hex: "#334155"),
                slateAccent: Color(hex: "#94A3B8"),
                heroAmber: Color(hex: "#CBD5E1")
            )
        case .ember:
            return PaletteColors(
                background: Color(hex: "#120D0B"),
                card: Color(hex: "#1C1412"),
                cardSoft: Color(hex: "#261C18"),
                accent: Color(hex: "#EF4444"),
                accent2: Color(hex: "#F87171"),
                success: Color(hex: "#4ADE80"),
                warning: Color(hex: "#FB923C"),
                danger: Color(hex: "#DC2626"),
                brandPrimary: Color(hex: "#B91C1C"),
                brandPrimaryLight: Color(hex: "#EF4444"),
                brandPrimaryDark: Color(hex: "#7F1D1D"),
                slateAccent: Color(hex: "#B09080"),
                heroAmber: Color(hex: "#FB923C")
            )
        case .lavender:
            return PaletteColors(
                background: Color(hex: "#0E0D14"),
                card: Color(hex: "#17161F"),
                cardSoft: Color(hex: "#1F1E2A"),
                accent: Color(hex: "#818CF8"),
                accent2: Color(hex: "#A5B4FC"),
                success: Color(hex: "#34D399"),
                warning: Color(hex: "#FBBF24"),
                danger: Color(hex: "#FB7185"),
                brandPrimary: Color(hex: "#6366F1"),
                brandPrimaryLight: Color(hex: "#818CF8"),
                brandPrimaryDark: Color(hex: "#4338CA"),
                slateAccent: Color(hex: "#9B99B0"),
                heroAmber: Color(hex: "#E0B0FF")
            )
        case .midnight:
            return PaletteColors(
                background: Color(hex: "#08090E"),
                card: Color(hex: "#101218"),
                cardSoft: Color(hex: "#181B24"),
                accent: Color(hex: "#38BDF8"),
                accent2: Color(hex: "#7DD3FC"),
                success: Color(hex: "#4ADE80"),
                warning: Color(hex: "#FBBF24"),
                danger: Color(hex: "#F43F5E"),
                brandPrimary: Color(hex: "#0284C7"),
                brandPrimaryLight: Color(hex: "#38BDF8"),
                brandPrimaryDark: Color(hex: "#075985"),
                slateAccent: Color(hex: "#7C9DB5"),
                heroAmber: Color(hex: "#38BDF8")
            )
        }
    }
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
