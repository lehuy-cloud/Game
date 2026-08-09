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
    @State private var clouds: [FallingCloud] = []
    @State private var defeatedCount = 0
    @State private var showCompletion = false

    private let targetDefeats = 8
    private let fallDuration: Double = 4

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(colors: [Color(hex: chapter.secondaryHex), .white], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                VStack {
                    Text("Chạm vào các đám mây bão trước khi chúng rơi xuống!")
                        .font(.title3.bold())
                        .multilineTextAlignment(.center)
                    Text("Đã đánh bại: \(defeatedCount)/\(targetDefeats)")
                        .font(.headline)
                    Spacer()
                }
                .padding()

                ForEach(clouds) { cloud in
                    Text("🌪️")
                        .font(.system(size: 44))
                        .position(x: cloud.x, y: cloud.y)
                        .onTapGesture { defeat(cloud) }
                }

                if showCompletion {
                    StoryCompletionOverlay(outroText: chapter.outroText) {
                        path = NavigationPath()
                    }
                }
            }
            .task { await runStorm(in: proxy.size) }
        }
        .navigationTitle("Đại chiến bão tuyết")
    }

    private func defeat(_ cloud: FallingCloud) {
        clouds.removeAll { $0.id == cloud.id }
        defeatedCount += 1
        if defeatedCount >= targetDefeats {
            complete()
        }
    }

    private func spawnCloud(in size: CGSize) {
        let cloud = FallingCloud(x: .random(in: 40...(size.width - 40)), y: 80)
        clouds.append(cloud)

        withAnimation(.linear(duration: fallDuration)) {
            if let idx = clouds.firstIndex(where: { $0.id == cloud.id }) {
                clouds[idx].y = size.height - 60
            }
        }

        Task {
            try? await Task.sleep(for: .seconds(fallDuration))
            clouds.removeAll { $0.id == cloud.id }
        }
    }

    private func runStorm(in size: CGSize) async {
        guard size.width > 80 else { return }
        while !Task.isCancelled && defeatedCount < targetDefeats {
            spawnCloud(in: size)
            try? await Task.sleep(for: .seconds(1))
        }
    }

    private func complete() {
        progressStore.completeChapter(chapter.id)
        progressStore.addStar(for: "story")
        showCompletion = true
    }
}
