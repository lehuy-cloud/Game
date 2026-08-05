import Foundation

struct VocabularyCard: Identifiable, Codable, Hashable {
    let id: String
    let word: String
    let emoji: String
    let symbolName: String?
    let imageName: String?
    let categoryId: String
}
