import SwiftUI

struct IceMeltGameView: View {
    let chapter: StoryChapter
    @Binding var path: NavigationPath

    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var holdProgress: Double = 0
    @State private var isHolding = false
    @State private var showCompletion = false

    private var isRegularWidth: Bool { horizontalSizeClass == .regular }
    private var dialSize: CGFloat { isRegularWidth ? 380 : 220 }

    var body: some View {
        ZStack {
            MiniGameShell(title: "Tan băng",
                          prompt: "Chạm và giữ để làm tan khối băng, cứu chú cáo!",
                          onBack: { path.removeLast() }) {
                VStack {
                    Spacer(minLength: 0)
                    ZStack {
                        Circle()
                            .stroke(Palette.ink.opacity(0.12), lineWidth: isRegularWidth ? 26 : 16)
                        Circle()
                            .trim(from: 0, to: holdProgress)
                            .stroke(Color(hex: chapter.accentHex),
                                    style: StrokeStyle(lineWidth: isRegularWidth ? 26 : 16, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 0.1), value: holdProgress)
                        Text(holdProgress >= 1 ? "🦊" : "🧊")
                            .font(.system(size: isRegularWidth ? 150 : 80))
                    }
                    .frame(width: dialSize, height: dialSize)
                    .contentShape(Circle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in isHolding = true }
                            .onEnded { _ in isHolding = false }
                    )
                    Spacer(minLength: 0)
                }
            }

            if showCompletion {
                StoryCompletionOverlay(outroText: chapter.outroText) {
                    path = NavigationPath()
                }
            }
        }
        .task {
            while !Task.isCancelled && holdProgress < 1 {
                try? await Task.sleep(for: .seconds(0.1))
                if isHolding { holdProgress = min(holdProgress + 0.04, 1) }
            }
            if holdProgress >= 1 { complete() }
        }
    }

    private func complete() {
        progressStore.completeChapter(chapter.id)
        progressStore.addStar(for: "story")
        showCompletion = true
    }
}
