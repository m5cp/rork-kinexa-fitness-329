import Foundation

enum HeroWODLibrary {

    static let heroWODs: [WODTemplate] = []

    static func isHeroWorkout(_ template: WODTemplate) -> Bool {
        false
    }

    static func isMemorialWorkout(_ template: WODTemplate) -> Bool {
        false
    }

    static func tributeFor(_ templateTitle: String) -> HeroWODInfo? {
        nil
    }
}

nonisolated struct HeroWODInfo: Codable, Hashable, Sendable {
    let honoreeFullName: String
    let rankOrRole: String
    let serviceBranch: String
    let dateOfDeath: String
    let location: String
    let shortTribute: String

    var displayName: String { "" }
    var formattedTribute: String { "" }
    var isValid: Bool { false }
}
