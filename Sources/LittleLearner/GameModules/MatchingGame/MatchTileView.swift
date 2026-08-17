import SwiftUI

/// Một ô thẻ trong game Lật Hình — mặt sau nền accent + vòng tròn mềm,
/// mặt trước nền kem với emoji và từ tiếng Anh. Lật bằng rotation3DEffect.
struct MatchTileView: View {
    let tile: MatchTile
    let showWord: Bool
    let action: () -> Void

    @Environment(\.theme) private var theme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isRegularWidth: Bool { horizontalSizeClass == .regular }
    private var isShown: Bool { tile.isFaceUp || tile.isMatched }
    private var radius: CGFloat { isRegularWidth ? DesignTokens.radiusLg : DesignTokens.radiusTile }

    var body: some View {
        Button(action: action) {
            ZStack {
                back.opacity(isShown ? 0 : 1)
                front.opacity(isShown ? 1 : 0)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .drawingGroup()
            .rotation3DEffect(.degrees(isShown ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            .animation(.spring(response: 0.45, dampingFraction: 0.8), value: isShown)
        }
        .buttonStyle(.plain)
        .disabled(tile.isFaceUp || tile.isMatched)
        .accessibilityLabel(isShown ? tile.card.word : "Thẻ úp")
    }

    private var back: some View {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
            .fill(theme.base)
            .overlay {
                if !isRegularWidth {
                    Circle()
                        .strokeBorder(Palette.onAccent.opacity(0.6), lineWidth: 3.5)
                        .padding(.horizontal, 0)
                        .scaleEffect(0.46)
                }
            }
            .shadow(color: Color(hex: "#2E2B25").opacity(0.18), radius: 6, y: 3)
    }

    /// iPad theo đúng mockup P7: chỉ ảnh con vật, không crop, không chữ chú
    /// thích — khác hẳn bản trước (ảnh crop to + chữ) mà vẫn chưa vừa ý.
    private var front: some View {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
            .fill(tile.isMatched ? Palette.sageTint : Palette.surface)
            .overlay {
                if tile.isMatched {
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .strokeBorder(Palette.sage, lineWidth: 3)
                }
                if isRegularWidth {
                    contentView
                        .padding(14)
                } else {
                    VStack(spacing: 2) {
                        contentView
                        if showWord {
                            Text(tile.card.word)
                                .font(.body(11, weight: .bold))
                                .foregroundStyle(tile.isMatched ? Palette.sageDeep : Palette.ink.opacity(0.55))
                        }
                    }
                    .padding(6)
                }
            }
            .shadow(color: Color(hex: "#2E2B25").opacity(tile.isMatched ? 0 : 0.18), radius: 6, y: 3)
    }

    @ViewBuilder
    private var contentView: some View {
        if let imageName = tile.card.imageName {
            Image(imageName)
                .resizable()
                .scaledToFit()
        } else if let value = tile.card.value {
            Text("\(value)").font(.display(isRegularWidth ? 52 : 30)).foregroundStyle(theme.deep)
        } else if let colorHex = tile.card.colorHex {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(hex: colorHex))
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Palette.ink.opacity(0.18), lineWidth: 1.5)
                }
        } else {
            Text(tile.card.emoji).font(.system(size: isRegularWidth ? 60 : 38))
        }
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
