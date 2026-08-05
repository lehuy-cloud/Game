import SwiftUI

@main
struct LittleLearnerApp: App {
    @State private var progressStore = ProgressStore()
    @State private var profileStore = ProfileStore()

    var body: some Scene {
        WindowGroup {
            Group {
                if let character = profileStore.selectedCharacter {
                    RootTabView()
                        .tint(Color(hex: character.primaryHex))
                } else {
                    CharacterSelectionView()
                }
            }
            .environment(progressStore)
            .environment(profileStore)
            .preferredColorScheme(.light)
            .onAppear { SpeechService.shared.configureAudioSession() }
        }
    }
}
