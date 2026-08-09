import Foundation

struct Story: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let coverImageName: String?
    let accentHex: String
    let secondaryHex: String
    let chapters: [StoryChapter]
}
