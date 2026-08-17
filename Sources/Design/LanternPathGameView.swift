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
                // LỖI ĐÃ SỬA: `Grid` + `.aspectRatio(1, .fill)` trên từng ô cho
                // ra ba cột rộng khác nhau, vài ô bị kéo thành thanh xám mảnh.
                // Nay đo bảng bằng `GeometryReader` rồi chia ô vuông cố định.
                GeometryReader { proxy in
                    let gap: CGFloat = isRegularWidth ? 18 : 12
                    let pad: CGFloat = isRegularWidth ? 26 : 20
                    let board = min(proxy.size.width, proxy.size.height)
                    let cell = (board - pad * 2 - gap * 2) / 3
                    VStack(spacing: gap) {
                        ForEach(0..<3, id: \.self) { row in
                            HStack(spacing: gap) {
                                ForEach(0..<3, id: \.self) { col in
                                    tileView(row * 3 + col).frame(width: cell, height: cell)
                                }
                            }
                        }
                    }
                    .padding(pad)
                    .background(Palette.ink, in: RoundedRectangle(cornerRadius: DesignTokens.radiusLg))
                    .frame(width: board, height: board)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            ZStack {
                RoundedRectangle(cornerRadius: DesignTokens.cornerRadius, style: .continuous)
                    .fill(isLit ? Color(hex: chapter.accentHex) : Color.white.opacity(0.08))
                if isLit, let imageName = chapter.imageName {
                    CoverFill(imageName: imageName, washedStyle: false)
                } else if isLit {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: isRegularWidth ? 46 : 32))
                        .foregroundStyle(.white)
                } else {
                    // Ô chưa sáng: chấm mờ, KHÔNG dùng emoji "⬛" (hiện ra
                    // đúng một ô vuông đen xấu như trên ảnh chụp).
                    Circle()
                        .fill(Color.white.opacity(0.14))
                        .frame(width: isRegularWidth ? 18 : 13, height: isRegularWidth ? 18 : 13)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius, style: .continuous))
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
