import SwiftUI

struct MatchingGameView: View {
    let categoryId: String

    @Environment(ProgressStore.self) private var progressStore
    @State private var tiles: [MatchTile] = []
    @State private var faceUpIndices: [Int] = []
    @State private var isCheckingMatch = false

    private let pairCount = 4
    private let columns = [GridItem(.adaptive(minimum: 100))]

    var body: some View {
        ZStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: DesignTokens.spacing) {
                    ForEach(tiles.indices, id: \.self) { index in
                        tileView(for: index)
                    }
                }
                .padding()
            }
            .themedBackground()

            if isGameWon {
                winOverlay
            }
        }
        .navigationTitle("Matching Pairs")
        .onAppear(perform: buildBoard)
    }

    private var isGameWon: Bool {
        !tiles.isEmpty && tiles.allSatisfy(\.isMatched)
    }

    private func tileView(for index: Int) -> some View {
        let tile = tiles[index]
        return Button {
            handleTap(on: index)
        } label: {
            Group {
                if tile.isFaceUp || tile.isMatched {
                    Text(tile.card.emoji)
                        .font(.system(size: 40))
                } else {
                    Image(systemName: "questionmark")
                        .font(.title)
                }
            }
            .frame(minWidth: DesignTokens.minTapTarget, minHeight: DesignTokens.minTapTarget)
            .background(
                tile.isMatched ? Color.green.opacity(0.3) : Color.gray.opacity(0.2),
                in: RoundedRectangle(cornerRadius: DesignTokens.cornerRadius)
            )
        }
        .buttonStyle(.plain)
        .disabled(tile.isFaceUp || tile.isMatched || isCheckingMatch)
    }

    private var winOverlay: some View {
        VStack(spacing: DesignTokens.spacing) {
            Text("Great job! 🎉")
                .font(.largeTitle.bold())
            RewardStarsView(count: pairCount)
            Button("Play Again") {
                buildBoard()
            }
            .buttonStyle(.big)
        }
        .padding(DesignTokens.spacing * 2)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
        .padding()
    }

    private func buildBoard() {
        let selectedCards = Array(VocabularyContent.cards(for: categoryId).shuffled().prefix(pairCount))
        tiles = (selectedCards + selectedCards).map { MatchTile(card: $0) }.shuffled()
        faceUpIndices = []
        isCheckingMatch = false
    }

    private func handleTap(on index: Int) {
        guard faceUpIndices.count < 2 else { return }
        tiles[index].isFaceUp = true
        SpeechService.shared.speak(tiles[index].card.word)
        faceUpIndices.append(index)

        guard faceUpIndices.count == 2 else { return }
        isCheckingMatch = true

        Task {
            try? await Task.sleep(for: .seconds(0.6))
            checkMatch()
        }
    }

    private func checkMatch() {
        let first = faceUpIndices[0]
        let second = faceUpIndices[1]

        if tiles[first].card.id == tiles[second].card.id {
            tiles[first].isMatched = true
            tiles[second].isMatched = true
            progressStore.addStar(for: categoryId)
            SpeechService.shared.speak("Great job!")
        } else {
            tiles[first].isFaceUp = false
            tiles[second].isFaceUp = false
        }

        faceUpIndices = []
        isCheckingMatch = false
    }
}
