import SwiftUI

/// Một ô thẻ trong game Lật Hình — mặt sau nền accent + vòng tròn mềm,
/// mặt trước nền kem với emoji và từ tiếng Anh. Lật bằng rotation3DEffect.
struct MatchTileView: View {
    let tile: MatchTile
    let showWord: Bool
    let action: () -> Void

    @Environment(\.theme) private var theme

    private var isShown: Bool { tile.isFaceUp || tile.isMatched }

    var body: some View {
        Button(action: action) {
            ZStack {
                back.opacity(isShown ? 0 : 1)
                front.opacity(isShown ? 1 : 0)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .rotation3DEffect(.degrees(isShown ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            .animation(.spring(response: 0.45, dampingFraction: 0.8), value: isShown)
        }
        .buttonStyle(.plain)
        .disabled(tile.isFaceUp || tile.isMatched)
        .accessibilityLabel(isShown ? tile.card.word : "Thẻ úp")
    }

    private var back: some View {
        RoundedRectangle(cornerRadius: DesignTokens.radiusTile, style: .continuous)
            .fill(theme.base)
            .overlay {
                Circle()
                    .strokeBorder(Palette.onAccent.opacity(0.6), lineWidth: 3.5)
                    .padding(.horizontal, 0)
                    .scaleEffect(0.46)
            }
            .shadow(color: Color(hex: "#2E2B25").opacity(0.18), radius: 6, y: 3)
    }

    private var front: some View {
        RoundedRectangle(cornerRadius: DesignTokens.radiusTile, style: .continuous)
            .fill(tile.isMatched ? Palette.sageTint : Palette.surface)
            .overlay {
                if tile.isMatched {
                    RoundedRectangle(cornerRadius: DesignTokens.radiusTile, style: .continuous)
                        .strokeBorder(Palette.sage, lineWidth: 3)
                }
                VStack(spacing: 2) {
                    if let imageName = tile.card.imageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 44, height: 44)
                    } else if let value = tile.card.value {
                        Text("\(value)").font(.display(30)).foregroundStyle(theme.deep)
                    } else if let colorHex = tile.card.colorHex {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(hex: colorHex))
                            .frame(width: 40, height: 40)
                    } else {
                        Text(tile.card.emoji).font(.system(size: 38))
                    }
                    if showWord {
                        Text(tile.card.word)
                            .font(.body(11, weight: .bold))
                            .foregroundStyle(tile.isMatched ? Palette.sageDeep : Palette.ink.opacity(0.55))
                    }
                }
            }
            .shadow(color: Color(hex: "#2E2B25").opacity(tile.isMatched ? 0 : 0.18), radius: 6, y: 3)
    }
}

#Preview {
    let card = VocabularyCard(id: "animal_rabbit", word: "Rabbit", translation: "Con thỏ", emoji: "🐰",
                              symbolName: nil, imageName: nil, categoryId: "animals")
    return LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 10) {
        MatchTileView(tile: MatchTile(card: card), showWord: true) {}
        MatchTileView(tile: { var t = MatchTile(card: card); t.isFaceUp = true; return t }(), showWord: true) {}
        MatchTileView(tile: { var t = MatchTile(card: card); t.isMatched = true; return t }(), showWord: true) {}
    }
    .padding()
    .organicBackground()
    .environment(\.theme, .pink)
}
