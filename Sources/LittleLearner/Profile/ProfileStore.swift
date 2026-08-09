import Foundation
import Observation

@Observable
final class ProfileStore {
    private let key = "selectedCharacterId"
    private let themeKey = "themeId"

    var selectedCharacterId: String? {
        didSet { UserDefaults.standard.set(selectedCharacterId, forKey: key) }
    }

    var selectedCharacter: CharacterAvatar? {
        CharacterContent.all.first { $0.id == selectedCharacterId }
    }

    var themeId: String = "terracotta" {
        didSet { UserDefaults.standard.set(themeId, forKey: themeKey) }
    }

    init() {
        selectedCharacterId = UserDefaults.standard.string(forKey: key)
        themeId = UserDefaults.standard.string(forKey: themeKey) ?? "terracotta"
    }
}
