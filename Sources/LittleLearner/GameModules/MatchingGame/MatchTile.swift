import Foundation

struct MatchTile: Identifiable {
    let id = UUID()
    let card: VocabularyCard
    var isFaceUp = false
    var isMatched = false
}
