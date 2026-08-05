import SwiftUI

struct FlashcardDeckView: View {
    let categoryId: String
    @State private var currentIndex = 0

    private var cards: [VocabularyCard] {
        VocabularyContent.cards(for: categoryId)
    }

    var body: some View {
        VStack(spacing: DesignTokens.spacing) {
            if cards.indices.contains(currentIndex) {
                FlashcardView(card: cards[currentIndex])
            }

            HStack(spacing: DesignTokens.spacing) {
                Button {
                    currentIndex = max(currentIndex - 1, 0)
                } label: {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(.big)
                .disabled(currentIndex == 0)

                Button {
                    currentIndex = min(currentIndex + 1, cards.count - 1)
                } label: {
                    Image(systemName: "chevron.right")
                }
                .buttonStyle(.big)
                .disabled(currentIndex == cards.count - 1)
            }
        }
        .padding()
        .themedBackground()
    }
}
