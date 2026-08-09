import SwiftUI

struct LanternPathGameView: View {
    let chapter: StoryChapter
    @Binding var path: NavigationPath

    @Environment(ProgressStore.self) private var progressStore
    @State private var revealedCount = 0
    @State private var showCompletion = false

    private let pathSequence = [4, 1, 7, 3, 5]
    private let columns = Array(repeating: GridItem(.flexible()), count: 3)

    var body: some View {
        ZStack {
            VStack(spacing: DesignTokens.spacing * 2) {
                Text("Chạm đúng thứ tự để soi sáng lối đi trong bóng tối!")
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                LazyVGrid(columns: columns, spacing: DesignTokens.spacing) {
                    ForEach(0..<9, id: \.self) { tileIndex in
                        tileView(tileIndex)
                    }
                }
                .padding()
            }
            .padding()
            .background(Color.black.opacity(0.85).ignoresSafeArea())

            if showCompletion {
                StoryCompletionOverlay(outroText: chapter.outroText) {
                    path = NavigationPath()
                }
            }
        }
        .navigationTitle("Thử thách: Ngọn đèn")
    }

    private func tileView(_ tileIndex: Int) -> some View {
        let isLit = pathSequence.prefix(revealedCount).contains(tileIndex)
        return Button {
            tap(tileIndex)
        } label: {
            Text(isLit ? "🔦" : "⬛")
                .font(.system(size: 32))
                .frame(minWidth: DesignTokens.minTapTarget, minHeight: DesignTokens.minTapTarget)
                .background(
                    isLit ? Color(hex: chapter.accentHex) : Color.white.opacity(0.1),
                    in: RoundedRectangle(cornerRadius: DesignTokens.cornerRadius)
                )
        }
        .buttonStyle(.plain)
        .disabled(isLit)
    }

    private func tap(_ tileIndex: Int) {
        guard revealedCount < pathSequence.count, pathSequence[revealedCount] == tileIndex else { return }
        revealedCount += 1
        if revealedCount == pathSequence.count {
            complete()
        }
    }

    private func complete() {
        progressStore.completeChapter(chapter.id)
        progressStore.addStar(for: "story")
        showCompletion = true
    }
}
