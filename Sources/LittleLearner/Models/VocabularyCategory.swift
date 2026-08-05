import Foundation

struct VocabularyCategory: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let symbolName: String
    let colorHex: String
}
