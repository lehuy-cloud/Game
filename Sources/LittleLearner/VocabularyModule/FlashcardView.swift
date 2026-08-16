import SwiftUI

struct FlashcardView: View {
    let card: VocabularyCard

    @Environment(\.theme) private var theme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isRegularWidth: Bool { horizontalSizeClass == .regular }

    var body: some View {
        if isRegularWidth {
            HStack(spacing: 26) {
                imageArea.frame(maxWidth: .infinity, maxHeight: .infinity)
                infoCard.frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: 480)
        } else {
            VStack(spacing: 14) {
                imageArea.frame(maxWidth: .infinity).frame(height: 280)
                infoCard
            }
        }
    }

    private var imageArea: some View {
        let artSize: CGFloat = isRegularWidth ? 260 : 176
        return ZStack {
            theme.tint
            if let imageName = card.imageName {
                if card.categoryId == "animals" {
                    // Sticker art is cropped tight to its canvas; inset it so ears/tails
                    // aren't cut off by the circular clip.
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: artSize, height: artSize)
                        .shadow(color: Palette.ink.opacity(0.12), radius: 6, y: 3)
                } else {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: isRegularWidth ? 300 : 220, height: isRegularWidth ? 300 : 220)
                        .clipShape(Circle())
                        .shadow(color: Palette.ink.opacity(0.12), radius: 6, y: 3)
                }
            } else if card.categoryId == "numbers", let value = card.value {
                tenFrame(value)
            } else if card.categoryId == "colors", let colorHex = card.colorHex {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(Color(hex: colorHex))
                    .frame(width: artSize, height: artSize)
                    .shadow(color: Palette.ink.opacity(0.12), radius: 6, y: 3)
            } else {
                Text(card.emoji)
                    .font(.system(size: isRegularWidth ? 160 : 120))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.radiusLg))
        .contentShape(RoundedRectangle(cornerRadius: DesignTokens.radiusLg))
        .onTapGesture { SpeechService.shared.speak(word: card.word, caption: card.translation, description: card.description) }
    }

    private var infoCard: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 2) {
                Text(card.word)
                    .font(.display(isRegularWidth ? 48 : 34))
                    .foregroundStyle(card.colorHex.map { Color(hex: $0) } ?? Palette.ink)
                Text(card.translation)
                    .font(.body(isRegularWidth ? 18 : 14))
                    .foregroundStyle(Palette.ink.opacity(0.55))
                if let description = card.description {
                    Text(description)
                        .font(.body(isRegularWidth ? 16 : 13))
                        .foregroundStyle(Palette.ink.opacity(0.58))
                        .padding(.top, isRegularWidth ? 14 : 8)
                }
            }
            Spacer(minLength: 0)
            Button {
                SpeechService.shared.speak(word: card.word, caption: card.translation, description: card.description)
            } label: {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Palette.onAccent)
                    .frame(width: 52, height: 52)
                    .background(Circle().fill(theme.base))
            }
        }
        .padding(isRegularWidth ? 26 : 16)
        .frame(maxHeight: isRegularWidth ? .infinity : nil)
        .organicCard()
    }

    /// Khung mười ô — số lớn phía trên, hai hàng 5 chấm bên dưới, số chấm tô
    /// đậm bằng đúng giá trị của thẻ. Giúp bé thấy được "lượng" đứng sau số.
    private func tenFrame(_ value: Int) -> some View {
        VStack(spacing: 18) {
            Text("\(value)")
                .font(.display(isRegularWidth ? 110 : 88))
                .foregroundStyle(theme.deep)
            VStack(spacing: 10) {
                ForEach(0..<2, id: \.self) { row in
                    HStack(spacing: 10) {
                        ForEach(0..<5, id: \.self) { col in
                            let filled = row * 5 + col < value
                            Circle()
                                .fill(filled ? theme.deep : theme.deep.opacity(0.15))
                                .frame(width: isRegularWidth ? 26 : 20, height: isRegularWidth ? 26 : 20)
                        }
                    }
                }
            }
        }
    }
}
