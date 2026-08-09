import SwiftUI

struct IceMeltGameView: View {
    let chapter: StoryChapter
    @Binding var path: NavigationPath

    @Environment(ProgressStore.self) private var progressStore
    @State private var holdProgress: Double = 0
    @State private var isHolding = false
    @State private var showCompletion = false

    var body: some View {
        ZStack {
            VStack(spacing: DesignTokens.spacing * 2) {
                Text("Chạm và giữ để làm tan khối băng, cứu chú cáo!")
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 16)
                    Circle()
                        .trim(from: 0, to: holdProgress)
                        .stroke(Color(hex: chapter.accentHex), style: StrokeStyle(lineWidth: 16, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.1), value: holdProgress)

                    Text(holdProgress >= 1 ? "🦊" : "🧊")
                        .font(.system(size: 80))
                }
                .frame(width: 220, height: 220)
                .contentShape(Circle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in isHolding = true }
                        .onEnded { _ in isHolding = false }
                )
            }
            .padding()
            .background(
                LinearGradient(colors: [Color(hex: chapter.secondaryHex), .white], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )

            if showCompletion {
                StoryCompletionOverlay(outroText: chapter.outroText) {
                    path = NavigationPath()
                }
            }
        }
        .navigationTitle("Thử thách: Tan băng")
        .task {
            while !Task.isCancelled && holdProgress < 1 {
                try? await Task.sleep(for: .seconds(0.1))
                if isHolding {
                    holdProgress = min(holdProgress + 0.04, 1)
                }
            }
            if holdProgress >= 1 {
                complete()
            }
        }
    }

    private func complete() {
        progressStore.completeChapter(chapter.id)
        progressStore.addStar(for: "story")
        showCompletion = true
    }
}
