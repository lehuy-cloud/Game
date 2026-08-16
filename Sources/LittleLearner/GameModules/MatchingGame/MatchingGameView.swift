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
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @AppStorage("speakOnFlip") private var speakOnFlip = true

    private var isRegularWidth: Bool { horizontalSizeClass == .regular }

    @State private var tiles: [MatchTile] = []
    @State private var faceUpIndices: [Int] = []
    @State private var isCheckingMatch = false
    @State private var isPeeking = false
    @State private var moves = 0
    @State private var firstTryPairs = 0
    @State private var coachIndex = 0

    private let coachLines = ["Cứ từ từ nhé bé", "Bé nhớ giỏi lắm!", "Thẻ này ở đâu nhỉ?", "Sắp xong rồi!"]

    private var levelNumber: Int {
        (GameLevel.all.firstIndex { $0.id == level.id } ?? 0) + 1
    }

    private var matchedPairs: Int { tiles.filter(\.isMatched).count / 2 }
    private var isGameWon: Bool { !tiles.isEmpty && tiles.allSatisfy(\.isMatched) }
    private var buddyEmoji: String { profileStore.selectedCharacter?.emoji ?? "🐝" }
    private var categoryWord: String {
        VocabularyContent.categories.first { $0.id == categoryId }?.title.lowercased() ?? "thẻ"
    }

    var body: some View {
        VStack(spacing: isRegularWidth ? 20 : 14) {
            header
            progress
            grid
            coach
        }
        .padding(.horizontal, isRegularWidth ? 44 : 18)
        .padding(.bottom, 26)
        .organicBackground()
        .frame(maxWidth: isRegularWidth ? 1032 : 420)
        .frame(maxWidth: .infinity)
        .navigationBarBackButtonHidden()
        .enableSwipeBack()
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
        HStack(spacing: isRegularWidth ? 18 : 10) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left").font(.system(size: isRegularWidth ? 20 : 17, weight: .bold))
                    .frame(width: isRegularWidth ? 56 : 44, height: isRegularWidth ? 56 : 44)
                    .background(Circle().fill(Palette.surface))
                    .foregroundStyle(Palette.ink)
            }
            VStack(alignment: .leading, spacing: isRegularWidth ? 4 : 1) {
                if isRegularWidth {
                    Text("Lật hình · Cấp \(levelNumber)")
                        .font(.display(34))
                    Text("\(level.pairs) cặp · \(matchedPairs) cặp đã tìm · \(moves) lượt lật")
                        .font(.body(16)).foregroundStyle(Palette.ink.opacity(0.5))
                } else {
                    Text(VocabularyContent.categories.first { $0.id == categoryId }?.title ?? "Lật Hình")
                        .font(.display(17))
                    Text("\(level.name) · \(moves) lượt · \(matchedPairs)/\(level.pairs) cặp")
                        .font(.body(11.5)).foregroundStyle(Palette.ink.opacity(0.5))
                }
            }
            Spacer()
            if isRegularWidth {
                Text("⭐ \(progressStore.starsByCategory[categoryId, default: 0])")
                    .font(.body(18, weight: .bold))
                    .padding(.horizontal, 20)
                    .frame(height: 52)
                    .background(theme.tint, in: Capsule())
                    .foregroundStyle(theme.deep)
            }
            Button(action: peekBoard) {
                Label("Gợi ý", systemImage: "lightbulb.fill")
                    .font(.body(isRegularWidth ? 18 : 14, weight: .bold))
                    .padding(.horizontal, isRegularWidth ? 20 : 16)
                    .frame(height: isRegularWidth ? 52 : 44)
                    .background(Capsule().fill(isRegularWidth ? Palette.surface : Palette.sageTint).shadow(color: Palette.ink.opacity(isRegularWidth ? 0.08 : 0), radius: 6, y: 3))
                    .foregroundStyle(isRegularWidth ? Palette.ink : Palette.sageDeep)
            }
            .disabled(isCheckingMatch)
        }
    }

    /// Ô thẻ vuông (`aspectRatio(1)`) chỉ co theo bề ngang — nếu bề ngang có
    /// nhiều chỗ trống (như trên iPad rộng), thẻ sẽ phình to theo chiều ngang
    /// rồi kéo chiều cao theo tỉ lệ vuông, làm cả lưới tràn quá chiều cao màn
    /// hình. Đo cả hai chiều ở đây rồi lấy cạnh nhỏ hơn để thẻ luôn vừa khung.
    private var grid: some View {
        let spacing: CGFloat = isRegularWidth ? 18 : 10
        let columns = level.columns
        let rows = (tiles.count + columns - 1) / max(columns, 1)
        return GeometryReader { proxy in
            let tileWidth = (proxy.size.width - spacing * CGFloat(columns - 1)) / CGFloat(columns)
            let tileHeight = rows > 0 ? (proxy.size.height - spacing * CGFloat(rows - 1)) / CGFloat(rows) : tileWidth
            let tileSize = max(0, min(tileWidth, tileHeight))
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(tileSize), spacing: spacing), count: columns), spacing: spacing) {
                ForEach(tiles.indices, id: \.self) { index in
                    MatchTileView(tile: displayTile(at: index), showWord: true) { handleTap(on: index) }
                        .frame(width: tileSize, height: tileSize)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var progress: some View {
        Group {
            if isRegularWidth {
                GeometryReader { proxy in
                    HStack(spacing: 6) {
                        Capsule().fill(theme.base)
                            .frame(width: proxy.size.width * (level.pairs == 0 ? 0 : CGFloat(matchedPairs) / CGFloat(level.pairs)))
                        Capsule().fill(Palette.ink.opacity(0.12))
                    }
                }
                .frame(height: 10)
            } else {
                HStack(spacing: 6) {
                    ForEach(0..<level.pairs, id: \.self) { i in
                        Capsule()
                            .fill(i < matchedPairs ? Palette.sage : Palette.ink.opacity(0.12))
                            .frame(height: 7)
                    }
                }
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
