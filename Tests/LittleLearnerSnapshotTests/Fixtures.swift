import Foundation
@testable import LittleLearner

/// Dữ liệu cố định cho snapshot test — không phụ thuộc UserDefaults còn sót lại
/// từ những lần chạy simulator thủ công.
enum Fixtures {
    @MainActor
    static func profileStore() -> ProfileStore {
        let store = ProfileStore()
        store.selectedCharacterId = "bee"
        store.themeId = "terracotta"
        return store
    }

    @MainActor
    static func progressStore() -> ProgressStore {
        let store = ProgressStore()
        store.starsByCategory = ["animals": 12, "colors": 3, "story": 1, "numbers": 0]
        store.completedStoryChapterIds = ["ch1"]
        return store
    }

    static let categoryId = "animals"
    static let colorsCategoryId = "colors"
    static let numbersCategoryId = "numbers"
    static let level = GameLevel.all[1]

    static var story: Story { StoryContent.stories.first { $0.id == "hoang_tu_tuyet" }! }
    static func chapter(_ id: String) -> StoryChapter { story.chapters.first { $0.id == id }! }
}
