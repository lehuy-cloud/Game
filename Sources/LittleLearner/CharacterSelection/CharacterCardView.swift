import SwiftUI

struct CharacterCardView: View {
    let character: CharacterAvatar
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(character.emoji)
                    .font(.system(size: 56))
                Text(character.name)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity, minHeight: DesignTokens.minTapTarget * 1.3)
            .padding()
            .background(Color(hex: character.primaryHex), in: RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
            .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
    }
}
