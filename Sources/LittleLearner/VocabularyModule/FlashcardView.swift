import SwiftUI

struct FlashcardView: View {
    let card: VocabularyCard

    @Environment(\.theme) private var theme

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                theme.tint
                if let imageName = card.imageName {
                    if card.categoryId == "animals" {
                        // Sticker art is cropped tight to its canvas; inset it so ears/tails
                        // aren't cut off by the circular clip.
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 176, height: 176)
                            .shadow(color: Palette.ink.opacity(0.12), radius: 6, y: 3)
                    } else {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 220, height: 220)
                            .clipShape(Circle())
                            .shadow(color: Palette.ink.opacity(0.12), radius: 6, y: 3)
                    }
                } else if card.categoryId == "numbers", let value = card.value {
                    tenFrame(value)
                } else if card.categoryId == "colors", let colorHex = card.colorHex {
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(Color(hex: colorHex))
                        .frame(width: 176, height: 176)
                        .shadow(color: Palette.ink.opacity(0.12), radius: 6, y: 3)
                } else {
                    Text(card.emoji)
                        .font(.system(size: 120))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 280)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.radiusLg))
            .contentShape(RoundedRectangle(cornerRadius: DesignTokens.radiusLg))
            .onTapGesture { SpeechService.shared.speak(card.word) }

            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(card.word)
                        .font(.display(34))
                        .foregroundStyle(card.colorHex.map { Color(hex: $0) } ?? Palette.ink)
                    Text(card.translation)
                        .font(.body(14))
                        .foregroundStyle(Palette.ink.opacity(0.55))
                }
                Spacer(minLength: 0)
                Button {
                    SpeechService.shared.speak(card.word)
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Palette.onAccent)
                        .frame(width: 52, height: 52)
                        .background(Circle().fill(theme.base))
                }
            }
            .padding(16)
            .organicCard()
        }
    }

    /// Khung mười ô — số lớn phía trên, hai hàng 5 chấm bên dưới, số chấm tô
    /// đậm bằng đúng giá trị của thẻ. Giúp bé thấy được "lượng" đứng sau số.
    private func tenFrame(_ value: Int) -> some View {
        VStack(spacing: 18) {
            Text("\(value)")
                .font(.display(88))
                .foregroundStyle(theme.deep)
            VStack(spacing: 10) {
                ForEach(0..<2, id: \.self) { row in
                    HStack(spacing: 10) {
                        ForEach(0..<5, id: \.self) { col in
                            let filled = row * 5 + col < value
                            Circle()
                                .fill(filled ? theme.deep : theme.deep.opacity(0.15))
                                .frame(width: 20, height: 20)
                        }
                    }
                }
            }
        }
    }
}
