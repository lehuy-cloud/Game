import SwiftUI

private struct FallingCloud: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
}

struct StormBattleGameView: View {
    let chapter: StoryChapter
    @Binding var path: NavigationPath

    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var clouds: [FallingCloud] = []
    @State private var defeatedCount = 0
    @State private var showCompletion = false
    @State private var playArea: CGSize = .zero

    private let targetDefeats = 8
    private let fallDuration: Double = 4
    private var isRegularWidth: Bool { horizontalSizeClass == .regular }
    private var cloudSize: CGFloat { isRegularWidth ? 110 : 72 }

    var body: some View {
        ZStack {
            MiniGameShell(title: "Đại chiến bão tuyết",
                          counter: "\(defeatedCount) / \(targetDefeats)",
                          prompt: "Chạm vào các đám mây bão trước khi chúng rơi xuống!",
                          onBack: { path.removeLast() },
                          freeform: true) {
                // Toạ độ mây tính trong vùng chơi (đã trừ header + câu hỏi),
                // không còn dùng chiều cao cả màn với offset 150pt đoán mò.
                GeometryReader { proxy in
                    ZStack {
                        ForEach(clouds) { cloud in
                            cloudView
                                .position(x: cloud.x, y: cloud.y)
                                .onTapGesture { defeat(cloud) }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear { playArea = proxy.size }
                    .onChange(of: proxy.size) { _, newValue in playArea = newValue }
                }
            }

            if showCompletion {
                StoryCompletionOverlay(outroText: chapter.outroText) {
                    path = NavigationPath()
                }
            }
        }
        .task { await runStorm() }
    }

    @ViewBuilder private var cloudView: some View {
        if let imageName = chapter.imageName {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: cloudSize, height: cloudSize)
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(Color.white.opacity(0.85), lineWidth: 2.5))
                .shadow(color: Color(hex: chapter.accentHex).opacity(0.5), radius: 8, y: 4)
        } else {
            Text("🌪️").font(.system(size: isRegularWidth ? 64 : 44))
        }
    }

    private func defeat(_ cloud: FallingCloud) {
        clouds.removeAll { $0.id == cloud.id }
        defeatedCount += 1
        if defeatedCount >= targetDefeats { complete() }
    }

    private func spawnCloud() {
        let size = playArea
        let margin = cloudSize / 2 + 10
        guard size.width > margin * 2, size.height > margin * 2 else { return }
        let cloud = FallingCloud(x: .random(in: margin...(size.width - margin)), y: margin)
        clouds.append(cloud)

        withAnimation(.linear(duration: fallDuration)) {
            if let idx = clouds.firstIndex(where: { $0.id == cloud.id }) {
                clouds[idx].y = size.height - margin
            }
        }

        Task {
            try? await Task.sleep(for: .seconds(fallDuration))
            clouds.removeAll { $0.id == cloud.id }
        }
    }

    private func runStorm() async {
        while !Task.isCancelled && defeatedCount < targetDefeats {
            spawnCloud()
            try? await Task.sleep(for: .seconds(1))
        }
    }

    private func complete() {
        progressStore.completeChapter(chapter.id)
        progressStore.addStar(for: "story")
        showCompletion = true
    }
}
