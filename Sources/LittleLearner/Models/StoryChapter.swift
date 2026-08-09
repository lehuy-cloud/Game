import Foundation

struct StoryChapter: Identifiable, Hashable, Codable {
    let id: String
    let index: Int
    let title: String
    let icon: String
    let imageName: String?
    let accentHex: String
    let secondaryHex: String
    let pages: [StoryPage]
    let hasMiniGame: Bool
    let outroText: String
    let vocabCardIds: [String]
}
