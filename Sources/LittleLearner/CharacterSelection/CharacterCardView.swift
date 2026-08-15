import SwiftUI

struct CharacterCardView: View {
    let character: CharacterAvatar
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle().fill(Color(hex: character.primaryHex).opacity(0.18))
                    Text(character.emoji)
                        .font(.system(size: 38))
                }
                .frame(width: 72, height: 72)
                Text(character.name)
                    .font(.display(15))
                    .foregroundStyle(Palette.ink)
            }
            .frame(maxWidth: .infinity, minHeight: DesignTokens.minTapTarget * 1.3)
            .padding()
            .organicCard()
        }
        .buttonStyle(.plain)
    }
}
