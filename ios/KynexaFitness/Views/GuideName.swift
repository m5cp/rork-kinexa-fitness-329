import Foundation

struct GuideName: Identifiable, Hashable {
    var id: String { name }
    let name: String
}
