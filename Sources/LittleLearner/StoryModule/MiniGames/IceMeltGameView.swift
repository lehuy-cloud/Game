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
            VStack(spacing: 0) {
                header
                    .padding(.horizontal)
                    .padding(.top, 8)

                Spacer(minLength: 0)

                VStack(spacing: DesignTokens.spacing * 2) {
                    Text("Chạm và giữ để làm tan khối băng, cứu chú cáo!")
                        .font(.body(17, weight: .semibold))
                        .foregroundStyle(Palette.ink)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    ZStack {
                        Circle()
                            .stroke(Palette.ink.opacity(0.12), lineWidth: 16)
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

                Spacer(minLength: 0)
            }
            .padding(.bottom, DesignTokens.spacing)

            if showCompletion {
                StoryCompletionOverlay(outroText: chapter.outroText) {
                    path = NavigationPath()
                }
            }
        }
        .organicBackground()
        .gameContentWidth()
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
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

    private var header: some View {
        HStack(spacing: 12) {
            Button { path.removeLast() } label: {
                Image(systemName: "chevron.left").font(.system(size: 17, weight: .bold))
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Palette.surface))
                    .foregroundStyle(Palette.ink)
            }
            Text("Tan băng")
                .font(.display(17))
                .foregroundStyle(Palette.ink)
            Spacer(minLength: 0)
        }
    }

    private func complete() {
        progressStore.completeChapter(chapter.id)
        progressStore.addStar(for: "story")
        showCompletion = true
    }
}
