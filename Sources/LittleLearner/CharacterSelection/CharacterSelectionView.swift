import SwiftUI

struct CharacterSelectionView: View {
    @Environment(ProfileStore.self) private var profileStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private let columns = [GridItem(.adaptive(minimum: 150))]
    private var isRegularWidth: Bool { horizontalSizeClass == .regular }

    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.spacing) {
                Text("Bé là ai hôm nay?")
                    .font(.display(isRegularWidth ? 40 : 30))
                    .foregroundStyle(Palette.ink)
                    .multilineTextAlignment(.center)
                    .padding(.top, DesignTokens.spacing * 2)

                if isRegularWidth {
                    // 5 nhân vật với lưới .adaptive trên bề ngang iPad sẽ tự
                    // sinh dư cột, dồn cả hàng về bên trái thay vì giãn đều —
                    // dùng số cột cố định + giới hạn bề rộng, căn giữa.
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 24), count: 3), spacing: 24) {
                        ForEach(CharacterContent.all) { character in
                            CharacterCardView(character: character) {
                                select(character)
                            }
                        }
                    }
                    .frame(maxWidth: 720)
                    .padding()
                } else {
                    LazyVGrid(columns: columns, spacing: DesignTokens.spacing) {
                        ForEach(CharacterContent.all) { character in
                            CharacterCardView(character: character) {
                                select(character)
                            }
                        }
                    }
                    .padding()
                }

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
                                .frame(width: isRegularWidth ? 56 : 44, height: isRegularWidth ? 56 : 44)
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
            .frame(maxWidth: .infinity)
        }
        .organicBackground()
    }

    private func select(_ character: CharacterAvatar) {
        SpeechService.shared.speak(character.name)
        profileStore.selectedCharacterId = character.id
        dismiss()
    }
}
