import Foundation

struct VocabularyCard: Identifiable, Codable, Hashable {
    let id: String
    let word: String
    let translation: String
    let emoji: String
    let symbolName: String?
    let imageName: String?
    let categoryId: String
    let value: Int?
    let colorHex: String?

    init(id: String, word: String, translation: String, emoji: String, symbolName: String?, imageName: String?, categoryId: String, value: Int? = nil, colorHex: String? = nil) {
        self.id = id
        self.word = word
        self.translation = translation
        self.emoji = emoji
        self.symbolName = symbolName
        self.imageName = imageName
        self.categoryId = categoryId
        self.value = value
        self.colorHex = colorHex
    }
}
