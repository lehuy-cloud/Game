import Foundation
import Observation

@Observable
final class ProgressStore {
    private let defaultsKey = "starsByCategory"

    var starsByCategory: [String: Int] = [:] {
        didSet { persist() }
    }

    init() { load() }

    func addStar(for categoryId: String) {
        starsByCategory[categoryId, default: 0] += 1
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(starsByCategory) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey),
              let decoded = try? JSONDecoder().decode([String: Int].self, from: data)
        else { return }
        starsByCategory = decoded
    }
}
