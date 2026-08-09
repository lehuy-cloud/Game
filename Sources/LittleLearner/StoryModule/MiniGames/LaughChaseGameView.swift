import SwiftUI

struct LaughChaseGameView: View {
    let chapter: StoryChapter
    @Binding var path: NavigationPath

    @Environment(ProgressStore.self) private var progressStore
    @State private var bubblePosition = CGPoint(x: 100, y: 200)
    @State private var tapCount = 0
    @State private var showCompletion = false

    private let targetTaps = 6

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(colors: [Color(hex: chapter.secondaryHex), .white], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                VStack {
                    Text("Chạm vào chú chim cánh cụt trước khi bạn ấy chạy mất!")
                        .font(.title3.bold())
                        .multilineTextAlignment(.center)
                        .padding()
                    Text("Đã chạm: \(tapCount)/\(targetTaps)")
                        .font(.headline)
                    Spacer()
                }

                Image("chim_canh_cut_portrait")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
                    .position(bubblePosition)
                    .onTapGesture {
                        tapCount += 1
                        relocate(in: proxy.size)
                        if tapCount >= targetTaps {
                            complete()
                        }
                    }

                if showCompletion {
                    StoryCompletionOverlay(outroText: chapter.outroText) {
                        path = NavigationPath()
                    }
                }
            }
            .onAppear { relocate(in: proxy.size) }
            .task {
                while !Task.isCancelled && tapCount < targetTaps {
                    try? await Task.sleep(for: .seconds(1.5))
                    relocate(in: proxy.size)
                }
            }
        }
        .navigationTitle("Thử thách: Tiếng cười")
    }

    private func relocate(in size: CGSize) {
        guard size.width > 120, size.height > 260 else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            bubblePosition = CGPoint(
                x: .random(in: 60...(size.width - 60)),
                y: .random(in: 180...(size.height - 100))
            )
        }
    }

    private func complete() {
        progressStore.completeChapter(chapter.id)
        progressStore.addStar(for: "story")
        showCompletion = true
    }
}
