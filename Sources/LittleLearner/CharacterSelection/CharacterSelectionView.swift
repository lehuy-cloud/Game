import SwiftUI

struct CharacterSelectionView: View {
    @Environment(ProfileStore.self) private var profileStore
    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.adaptive(minimum: 150))]

    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.spacing) {
                Text("Bé là ai hôm nay?")
                    .font(.display(30))
                    .foregroundStyle(Palette.ink)
                    .multilineTextAlignment(.center)
                    .padding(.top, DesignTokens.spacing * 2)

                LazyVGrid(columns: columns, spacing: DesignTokens.spacing) {
                    ForEach(CharacterContent.all) { character in
                        CharacterCardView(character: character) {
                            select(character)
                        }
                    }
                }
                .padding()

                Text("MÀU CHỦ ĐẠO")
                    .font(.body(11, weight: .bold))
                    .foregroundStyle(Palette.ink.opacity(0.45))
                    .tracking(0.8)
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
        .organicBackground()
    }

    private func select(_ character: CharacterAvatar) {
        SpeechService.shared.speak(character.name)
        profileStore.selectedCharacterId = character.id
        dismiss()
    }
}
