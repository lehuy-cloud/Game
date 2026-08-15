import SwiftUI

/// `MatchingGameView` viết lại theo design Lật Hình: nhận `level` thay vì
/// hard-code `pairCount`, dùng `MatchTileView`, thanh tiến độ theo cặp,
/// nút Gợi ý, và `WinSheetView`.
struct MatchingGameView: View {
    let categoryId: String
    let level: GameLevel

    @Environment(ProgressStore.self) private var progressStore
    @Environment(ProfileStore.self) private var profileStore
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    @AppStorage("speakOnFlip") private var speakOnFlip = true

    @State private var tiles: [MatchTile] = []
    @State private var faceUpIndices: [Int] = []
    @State private var isCheckingMatch = false
    @State private var isPeeking = false
    @State private var moves = 0
    @State private var firstTryPairs = 0
    @State private var coachIndex = 0

    private let coachLines = ["Cứ từ từ nhé bé", "Bé nhớ giỏi lắm!", "Thẻ này ở đâu nhỉ?", "Sắp xong rồi!"]

    private var matchedPairs: Int { tiles.filter(\.isMatched).count / 2 }
    private var isGameWon: Bool { !tiles.isEmpty && tiles.allSatisfy(\.isMatched) }
    private var buddyEmoji: String { profileStore.selectedCharacter?.emoji ?? "🐝" }
    private var categoryWord: String {
        VocabularyContent.categories.first { $0.id == categoryId }?.title.lowercased() ?? "thẻ"
    }

    var body: some View {
        VStack(spacing: 14) {
            header
            progress
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: level.columns), spacing: 10) {
                ForEach(tiles.indices, id: \.self) { index in
                    MatchTileView(tile: displayTile(at: index), showWord: true) { handleTap(on: index) }
                }
            }
            Spacer(minLength: 0)
            coach
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 26)
        .organicBackground()
        .gameContentWidth()
        .navigationBarBackButtonHidden()
        .onAppear(perform: buildBoard)
        .overlay {
            if isGameWon {
                WinSheetView(level: level, moves: moves, firstTryPairs: firstTryPairs,
                             buddyEmoji: buddyEmoji, categoryWord: categoryWord,
                             playAgain: buildBoard, goHome: { dismiss() })
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: isGameWon)
    }

    // MARK: - Chrome

    private var header: some View {
        HStack(spacing: 10) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left").font(.system(size: 17, weight: .bold))
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Palette.surface))
                    .foregroundStyle(Palette.ink)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(VocabularyContent.categories.first { $0.id == categoryId }?.title ?? "Lật Hình")
                    .font(.display(17))
                Text("\(level.name) · \(moves) lượt · \(matchedPairs)/\(level.pairs) cặp")
                    .font(.body(11.5)).foregroundStyle(Palette.ink.opacity(0.5))
            }
            Spacer()
            Button(action: peekBoard) {
                Label("Gợi ý", systemImage: "lightbulb.fill")
                    .font(.body(14, weight: .bold))
                    .padding(.horizontal, 16)
                    .frame(height: 44)
                    .background(Capsule().fill(Palette.sageTint))
                    .foregroundStyle(Palette.sageDeep)
            }
            .disabled(isCheckingMatch)
        }
    }

    private var progress: some View {
        HStack(spacing: 6) {
            ForEach(0..<level.pairs, id: \.self) { i in
                Capsule()
                    .fill(i < matchedPairs ? Palette.sage : Palette.ink.opacity(0.12))
                    .frame(height: 7)
            }
        }
        .animation(.easeOut(duration: 0.3), value: matchedPairs)
    }

    private var coach: some View {
        HStack(spacing: 10) {
            Text(buddyEmoji).font(.system(size: 19))
                .frame(width: 36, height: 36)
                .background(Circle().fill(Palette.onAccent))
            Text(coachLines[coachIndex])
                .font(.body(14, weight: .semibold))
                .foregroundStyle(Palette.ink.opacity(0.62))
        }
    }

    // MARK: - Logic

    private func displayTile(at index: Int) -> MatchTile {
        var t = tiles[index]
        if isPeeking { t.isFaceUp = true }
        return t
    }

    private func buildBoard() {
        let selected = Array(VocabularyContent.cards(for: categoryId).shuffled().prefix(level.pairs))
        tiles = (selected + selected).map { MatchTile(card: $0) }.shuffled()
        faceUpIndices = []
        isCheckingMatch = false
        moves = 0
        firstTryPairs = 0
        coachIndex = 0
    }

    private func peekBoard() {
        guard !isCheckingMatch else { return }
        withAnimation { isPeeking = true }
        Task {
            try? await Task.sleep(for: .seconds(1.1))
            withAnimation { isPeeking = false }
        }
    }

    private func handleTap(on index: Int) {
        guard faceUpIndices.count < 2, !isCheckingMatch else { return }
        tiles[index].isFaceUp = true
        moves += 1
        if speakOnFlip { SpeechService.shared.speak(tiles[index].card.word) }
        faceUpIndices.append(index)

        guard faceUpIndices.count == 2 else { return }
        isCheckingMatch = true
        Task {
            try? await Task.sleep(for: .seconds(0.6))
            checkMatch()
        }
    }

    private func checkMatch() {
        let first = faceUpIndices[0], second = faceUpIndices[1]
        if tiles[first].card.id == tiles[second].card.id {
            tiles[first].isMatched = true
            tiles[second].isMatched = true
            firstTryPairs += 1
            progressStore.addStar(for: categoryId)
            if speakOnFlip { SpeechService.shared.speak("Great job!") }
        } else {
            tiles[first].isFaceUp = false
            tiles[second].isFaceUp = false
        }
        coachIndex = (coachIndex + 1) % coachLines.count
        faceUpIndices = []
        isCheckingMatch = false
    }
}
