import SwiftUI

struct CharacterSelectionView: View {
    @Environment(ProfileStore.self) private var profileStore
    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.adaptive(minimum: 150))]

    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.spacing) {
                Text("Who are you today?")
                    .font(.largeTitle.bold())
                    .padding(.top, DesignTokens.spacing * 2)

                LazyVGrid(columns: columns, spacing: DesignTokens.spacing) {
                    ForEach(CharacterContent.all) { character in
                        CharacterCardView(character: character) {
                            select(character)
                        }
                    }
                }
                .padding()
            }
        }
    }

    private func select(_ character: CharacterAvatar) {
        SpeechService.shared.speak(character.name)
        profileStore.selectedCharacterId = character.id
        dismiss()
    }
}
