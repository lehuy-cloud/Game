import Foundation

struct CharacterAvatar: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let emoji: String
    let symbolName: String?
    let imageName: String?
    let primaryHex: String
    let secondaryHex: String
}
