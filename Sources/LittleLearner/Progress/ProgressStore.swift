import Foundation
import Observation

@Observable
final class ProgressStore {
    private let starsKey = "starsByCategory"
    private let storyKey = "completedStoryChapterIds"

    var starsByCategory: [String: Int] = [:] {
        didSet { persistStars() }
    }

    var completedStoryChapterIds: Set<String> = [] {
        didSet { persistStoryProgress() }
    }

    init() {
        loadStars()
        loadStoryProgress()
    }

    func addStar(for categoryId: String) {
        starsByCategory[categoryId, default: 0] += 1
    }

    func completeChapter(_ chapterId: String) {
        completedStoryChapterIds.insert(chapterId)
    }

    private func persistStars() {
        if let data = try? JSONEncoder().encode(starsByCategory) {
            UserDefaults.standard.set(data, forKey: starsKey)
        }
    }

    private func loadStars() {
        guard let data = UserDefaults.standard.data(forKey: starsKey),
              let decoded = try? JSONDecoder().decode([String: Int].self, from: data)
        else { return }
        starsByCategory = decoded
    }

    private func persistStoryProgress() {
        if let data = try? JSONEncoder().encode(completedStoryChapterIds) {
            UserDefaults.standard.set(data, forKey: storyKey)
        }
    }

    private func loadStoryProgress() {
        guard let data = UserDefaults.standard.data(forKey: storyKey),
              let decoded = try? JSONDecoder().decode(Set<String>.self, from: data)
        else { return }
        completedStoryChapterIds = decoded
    }
}
