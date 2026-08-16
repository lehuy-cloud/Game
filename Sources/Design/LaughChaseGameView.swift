import SwiftUI

struct LaughChaseGameView: View {
    let chapter: StoryChapter
    @Binding var path: NavigationPath

    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var bubblePosition: CGPoint = .zero
    @State private var playArea: CGSize = .zero
    @State private var tapCount = 0
    @State private var showCompletion = false

    private let targetTaps = 6
    private var isRegularWidth: Bool { horizontalSizeClass == .regular }
    private var targetSize: CGFloat { isRegularWidth ? 120 : 70 }

    var body: some View {
        ZStack {
            MiniGameShell(title: "Tiếng cười",
                          counter: "\(tapCount) / \(targetTaps)",
                          prompt: "Chạm vào chú chim cánh cụt trước khi bạn ấy chạy mất!",
                          onBack: { path.removeLast() },
                          freeform: true) {
                // LỖI ĐÃ SỬA: trước đây toạ độ tính theo cả màn nhưng nội dung bị
                // `gameContentWidth()` kẹp còn 420pt, nên mục tiêu nhảy ra ngoài
                // vùng thấy được. Nay toạ độ tính trong đúng vùng chơi.
                GeometryReader { proxy in
                    Image("chim_canh_cut_portrait")
                        .resizable()
                        .scaledToFill()
                        .frame(width: targetSize, height: targetSize)
                        .clipShape(Circle())
                        .position(bubblePosition == .zero
                                  ? CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
                                  : bubblePosition)
                        .onTapGesture {
                            tapCount += 1
                            relocate(in: proxy.size)
                            if tapCount >= targetTaps { complete() }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onAppear {
                            playArea = proxy.size
                            relocate(in: proxy.size)
                        }
                        .onChange(of: proxy.size) { _, newValue in playArea = newValue }
                }
            }

            if showCompletion {
                StoryCompletionOverlay(outroText: chapter.outroText) {
                    path = NavigationPath()
                }
            }
        }
        .task {
            while !Task.isCancelled && tapCount < targetTaps {
                try? await Task.sleep(for: .seconds(1.5))
                relocate(in: playArea)
            }
        }
    }

    private func relocate(in size: CGSize) {
        let margin = targetSize / 2 + 8
        guard size.width > margin * 2, size.height > margin * 2 else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            bubblePosition = CGPoint(x: .random(in: margin...(size.width - margin)),
                                     y: .random(in: margin...(size.height - margin)))
        }
    }

    private func complete() {
        progressStore.completeChapter(chapter.id)
        progressStore.addStar(for: "story")
        showCompletion = true
    }
}
