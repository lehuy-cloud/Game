import SwiftUI

struct CharacterCardView: View {
    let character: CharacterAvatar
    let action: () -> Void

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isRegularWidth: Bool { horizontalSizeClass == .regular }

    var body: some View {
        Button(action: action) {
            VStack(spacing: isRegularWidth ? 14 : 10) {
                ZStack {
                    Circle().fill(Color(hex: character.primaryHex).opacity(0.18))
                    Text(character.emoji)
                        .font(.system(size: isRegularWidth ? 56 : 38))
                }
                .frame(width: isRegularWidth ? 108 : 72, height: isRegularWidth ? 108 : 72)
                Text(character.name)
                    .font(.display(isRegularWidth ? 19 : 15))
                    .foregroundStyle(Palette.ink)
            }
            .frame(maxWidth: .infinity, minHeight: isRegularWidth ? 200 : DesignTokens.minTapTarget * 1.3)
            .padding(isRegularWidth ? 20 : 16)
            .organicCard()
        }
        .buttonStyle(.plain)
    }
}
