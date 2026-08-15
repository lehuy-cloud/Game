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
    private let cloudSize: CGFloat = 72

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                VStack(spacing: 0) {
                    header
                        .padding(.horizontal)
                        .padding(.top, 8)
                    Text("Chạm vào các đám mây bão trước khi chúng rơi xuống!")
                        .font(.body(17, weight: .semibold))
                        .foregroundStyle(Palette.ink)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer(minLength: 0)
                }

                ForEach(clouds) { cloud in
                    Group {
                        if let imageName = chapter.imageName {
                            Image(imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: cloudSize, height: cloudSize)
                                .clipShape(Circle())
                                .overlay(Circle().strokeBorder(Color.white.opacity(0.85), lineWidth: 2.5))
                                .shadow(color: Color(hex: chapter.accentHex).opacity(0.5), radius: 8, y: 4)
                        } else {
                            Text("🌪️")
                                .font(.system(size: 44))
                        }
                    }
                    .position(x: cloud.x, y: cloud.y)
                    .onTapGesture { defeat(cloud) }
                }

                if showCompletion {
                    StoryCompletionOverlay(outroText: chapter.outroText) {
                        path = NavigationPath()
                    }
                }
            }
            .organicBackground()
            .gameContentWidth()
            .task { await runStorm(in: proxy.size) }
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
            Text("Đại chiến bão tuyết")
                .font(.display(17))
                .foregroundStyle(Palette.ink)
                .lineLimit(1)
            Spacer(minLength: 0)
            Text("\(defeatedCount) / \(targetDefeats)")
                .font(.body(12, weight: .bold))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Palette.surface, in: Capsule())
                .foregroundStyle(Palette.ink.opacity(0.7))
        }
    }

    private func defeat(_ cloud: FallingCloud) {
        clouds.removeAll { $0.id == cloud.id }
        defeatedCount += 1
        if defeatedCount >= targetDefeats {
            complete()
        }
    }

    private func spawnCloud(in size: CGSize) {
        let margin = cloudSize / 2 + 10
        let cloud = FallingCloud(x: .random(in: margin...(size.width - margin)), y: 150)
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
