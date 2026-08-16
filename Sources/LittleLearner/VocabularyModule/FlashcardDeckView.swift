import SwiftUI

struct FlashcardDeckView: View {
    let categoryId: String

    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var currentIndex = 0
    @State private var cards: [VocabularyCard] = []

    private var isRegularWidth: Bool { horizontalSizeClass == .regular }

    private var categoryTitle: String {
        VocabularyContent.categories.first { $0.id == categoryId }?.title ?? "Từ vựng"
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 30)
            .onEnded { value in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                withAnimation {
                    if value.translation.width < 0 {
                        currentIndex = min(currentIndex + 1, cards.count - 1)
                    } else {
                        currentIndex = max(currentIndex - 1, 0)
                    }
                }
            }
    }

    var body: some View {
        VStack(spacing: 14) {
            header
            ReadingProgressBar(current: currentIndex + 1, total: cards.count, theme: theme)

            if cards.indices.contains(currentIndex) {
                FlashcardView(card: cards[currentIndex])
                    .id(currentIndex)
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))
            }

            if categoryId == "colors" {
                colorPickerStrip
            } else if isRegularWidth {
                filmstrip
            }

            Spacer(minLength: 0)

            bottomNav
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .organicBackground()
        .gesture(swipeGesture)
        .navigationBarBackButtonHidden()
        .enableSwipeBack()
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            let base = VocabularyContent.cards(for: categoryId)
            cards = categoryId == "animals" ? base.shuffled() : base
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left").font(.system(size: 17, weight: .bold))
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Palette.surface))
                    .foregroundStyle(Palette.ink)
            }
            Text(categoryTitle)
                .font(.display(20))
                .foregroundStyle(Palette.ink)
            Spacer(minLength: 0)
            Text("\(currentIndex + 1) / \(cards.count)")
                .font(.body(12, weight: .bold))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Palette.surface, in: Capsule())
                .foregroundStyle(Palette.ink.opacity(0.6))
        }
    }

    private var colorPickerStrip: some View {
        HStack(spacing: 10) {
            ForEach(cards.indices, id: \.self) { index in
                let isSelected = index == currentIndex
                let color = Color(hex: cards[index].colorHex ?? "#CCCCCC")
                Circle()
                    .fill(color)
                    .frame(width: isSelected ? 32 : 24, height: isSelected ? 32 : 24)
                    .overlay {
                        if isSelected {
                            Circle().strokeBorder(color, lineWidth: 2.5).padding(-4)
                        }
                    }
                    .onTapGesture { withAnimation { currentIndex = index } }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Palette.surface, in: Capsule())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentIndex)
    }

    private var filmstrip: some View {
        let windowSize = 5
        let start = max(0, min(currentIndex - windowSize / 2, cards.count - windowSize))
        let end = min(cards.count, start + windowSize)
        return HStack(spacing: 18) {
            ForEach(start..<end, id: \.self) { index in
                let isSelected = index == currentIndex
                thumbnail(for: cards[index])
                    .frame(width: 124, height: 124)
                    .background(isSelected ? theme.tint : Palette.surface, in: RoundedRectangle(cornerRadius: DesignTokens.radiusLg))
                    .overlay {
                        if isSelected {
                            RoundedRectangle(cornerRadius: DesignTokens.radiusLg)
                                .strokeBorder(theme.base, lineWidth: 3)
                        }
                    }
                    .opacity(isSelected ? 1 : 0.5)
                    .onTapGesture { withAnimation { currentIndex = index } }
            }

            Text("vuốt ngang\nđể đổi thẻ")
                .font(.body(14))
                .multilineTextAlignment(.center)
                .foregroundStyle(Palette.ink.opacity(0.45))
                .frame(maxWidth: .infinity)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentIndex)
    }

    @ViewBuilder
    private func thumbnail(for card: VocabularyCard) -> some View {
        if let imageName = card.imageName {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .padding(18)
                .washed()
        } else if let colorHex = card.colorHex {
            RoundedRectangle(cornerRadius: DesignTokens.radiusTile, style: .continuous)
                .fill(Color(hex: colorHex))
                .padding(18)
        } else {
            Text(card.emoji)
                .font(.system(size: 44))
        }
    }

    private var bottomNav: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation { currentIndex = max(currentIndex - 1, 0) }
            } label: {
                Image(systemName: "chevron.left")
                    .frame(width: 56, height: 56)
                    .background(Circle().fill(Palette.surface))
                    .foregroundStyle(Palette.ink)
            }
            .disabled(currentIndex == 0)
            .opacity(currentIndex == 0 ? 0.4 : 1)

            Text("vuốt để đổi thẻ")
                .font(.body(12))
                .foregroundStyle(Palette.ink.opacity(0.45))
                .frame(maxWidth: .infinity)

            Button {
                withAnimation { currentIndex = min(currentIndex + 1, cards.count - 1) }
            } label: {
                Image(systemName: "chevron.right")
                    .frame(width: 56, height: 56)
                    .background(Circle().fill(theme.base))
                    .foregroundStyle(Palette.onAccent)
            }
            .disabled(currentIndex == cards.count - 1)
            .opacity(currentIndex == cards.count - 1 ? 0.4 : 1)
        }
    }
}
