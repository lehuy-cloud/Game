import SwiftUI

struct FlashcardView: View {
    let card: VocabularyCard

    var body: some View {
        Button {
            SpeechService.shared.speak(card.word)
        } label: {
            VStack(spacing: DesignTokens.spacing) {
                if let imageName = card.imageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 160, height: 160)
                        .clipShape(Circle())
                } else {
                    Text(card.emoji)
                        .font(.system(size: 120))
                }
                Text(card.word)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                Image(systemName: "speaker.wave.2.fill")
                    .font(.title2)
            }
            .frame(maxWidth: .infinity)
            .padding(DesignTokens.spacing * 2)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
    }
}
