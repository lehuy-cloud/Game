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

                Text("Màu chủ đạo")
                    .font(.headline)
                HStack(spacing: 12) {
                    ForEach(Theme.all) { theme in
                        Button {
                            profileStore.themeId = theme.id
                        } label: {
                            Circle()
                                .fill(theme.base)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .strokeBorder(Palette.ink.opacity(profileStore.themeId == theme.id ? 0.5 : 0), lineWidth: 3)
                                )
                                .padding(3)
                        }
                        .accessibilityLabel(theme.name)
                    }
                }
                .padding(.bottom, DesignTokens.spacing * 2)
            }
        }
    }

    private func select(_ character: CharacterAvatar) {
        SpeechService.shared.speak(character.name)
        profileStore.selectedCharacterId = character.id
        dismiss()
    }
}
