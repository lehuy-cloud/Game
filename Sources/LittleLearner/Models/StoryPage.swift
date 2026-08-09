import Foundation

struct StoryPage: Identifiable, Hashable, Codable {
    let id: String
    let text: String
    let emoji: String
    let imageName: String?
}
