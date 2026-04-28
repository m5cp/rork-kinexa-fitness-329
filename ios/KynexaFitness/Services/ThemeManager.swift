import SwiftUI

@Observable
final class ThemeManager {
    static let shared = ThemeManager()

    var currentPalette: ColorPalette {
        didSet {
            guard oldValue != currentPalette else { return }
            savePalette()
        }
    }

    private init() {
        let defaults = UserDefaults(suiteName: SharedDataManager.appGroupID) ?? .standard
        let raw = defaults.string(forKey: "selectedColorPalette") ?? ""
        self.currentPalette = ColorPalette(rawValue: raw) ?? .ocean
    }

    var colors: PaletteColors {
        currentPalette.colors
    }

    private func savePalette() {
        let defaults = UserDefaults(suiteName: SharedDataManager.appGroupID) ?? .standard
        defaults.set(currentPalette.rawValue, forKey: "selectedColorPalette")
        UserDefaults.standard.set(currentPalette.rawValue, forKey: "selectedColorPalette")
    }
}
