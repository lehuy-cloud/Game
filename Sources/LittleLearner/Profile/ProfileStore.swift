import Foundation
import Observation

@Observable
final class ProfileStore {
    private let key = "selectedCharacterId"

    var selectedCharacterId: String? {
        didSet { UserDefaults.standard.set(selectedCharacterId, forKey: key) }
    }

    var selectedCharacter: CharacterAvatar? {
        CharacterContent.all.first { $0.id == selectedCharacterId }
    }

    init() {
        selectedCharacterId = UserDefaults.standard.string(forKey: key)
    }
}
