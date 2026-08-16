import SwiftUI

struct LanternPathGameView: View {
    let chapter: StoryChapter
    @Binding var path: NavigationPath

    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var revealedCount = 0
    @State private var showCompletion = false

    private let pathSequence = [4, 1, 7, 3, 5]
    private var isRegularWidth: Bool { horizontalSizeClass == .regular }

    var body: some View {
        ZStack {
            MiniGameShell(title: "Ngọn đèn",
                          counter: "\(revealedCount) / \(pathSequence.count)",
                          prompt: "Chạm đúng thứ tự để soi sáng lối đi trong bóng tối!",
                          onBack: { path.removeLast() }) {
                VStack {
                    Spacer(minLength: 0)
                    // Lưới 3×3 vuông, ô giãn theo bề rộng thật thay vì
                    // `minWidth: 100` cố định.
                    Grid(horizontalSpacing: isRegularWidth ? 18 : 12,
                         verticalSpacing: isRegularWidth ? 18 : 12) {
                        ForEach(0..<3, id: \.self) { row in
                            GridRow {
                                ForEach(0..<3, id: \.self) { col in
                                    tileView(row * 3 + col)
                                }
                            }
                        }
                    }
                    .padding(isRegularWidth ? 26 : 20)
                    .background(Palette.ink, in: RoundedRectangle(cornerRadius: DesignTokens.radiusLg))
                    .aspectRatio(1, contentMode: .fit)
                    Spacer(minLength: 0)
                }
            }

            if showCompletion {
                StoryCompletionOverlay(outroText: chapter.outroText) {
                    path = NavigationPath()
                }
            }
        }
    }

    private func tileView(_ tileIndex: Int) -> some View {
        let isLit = pathSequence.prefix(revealedCount).contains(tileIndex)
        return Button {
            tap(tileIndex)
        } label: {
            Group {
                if isLit, let imageName = chapter.imageName {
                    Image(imageName).resizable().scaledToFill()
                } else {
                    Text(isLit ? "🔦" : "⬛")
                        .font(.system(size: isRegularWidth ? 46 : 32))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fill)
            .background(isLit ? Color(hex: chapter.accentHex) : Color.white.opacity(0.1),
                        in: RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
        }
        .buttonStyle(.plain)
        .disabled(isLit)
    }

    private func tap(_ tileIndex: Int) {
        guard revealedCount < pathSequence.count, pathSequence[revealedCount] == tileIndex else { return }
        revealedCount += 1
        if revealedCount == pathSequence.count { complete() }
    }

    private func complete() {
        progressStore.completeChapter(chapter.id)
        progressStore.addStar(for: "story")
        showCompletion = true
    }
}
