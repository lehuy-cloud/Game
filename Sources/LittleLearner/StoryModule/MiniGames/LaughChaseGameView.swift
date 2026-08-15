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
                VStack(spacing: 0) {
                    header
                        .padding(.horizontal)
                        .padding(.top, 8)
                    Text("Chạm vào chú chim cánh cụt trước khi bạn ấy chạy mất!")
                        .font(.body(17, weight: .semibold))
                        .foregroundStyle(Palette.ink)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer(minLength: 0)
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
            .organicBackground()
            .gameContentWidth()
            .onAppear { relocate(in: proxy.size) }
            .task {
                while !Task.isCancelled && tapCount < targetTaps {
                    try? await Task.sleep(for: .seconds(1.5))
                    relocate(in: proxy.size)
                }
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button { path.removeLast() } label: {
                Image(systemName: "chevron.left").font(.system(size: 17, weight: .bold))
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Palette.surface))
                    .foregroundStyle(Palette.ink)
            }
            Text("Tiếng cười")
                .font(.display(17))
                .foregroundStyle(Palette.ink)
            Spacer(minLength: 0)
            Text("\(tapCount) / \(targetTaps)")
                .font(.body(12, weight: .bold))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Palette.surface, in: Capsule())
                .foregroundStyle(Palette.ink.opacity(0.7))
        }
    }

    private func relocate(in size: CGSize) {
        guard size.width > 120, size.height > 260 else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            bubblePosition = CGPoint(
                x: .random(in: 60...(size.width - 60)),
                y: .random(in: 230...(size.height - 100))
            )
        }
    }

    private func complete() {
        progressStore.completeChapter(chapter.id)
        progressStore.addStar(for: "story")
        showCompletion = true
    }
}
