import SwiftUI

struct LanternPathGameView: View {
    let chapter: StoryChapter
    @Binding var path: NavigationPath

    @Environment(ProgressStore.self) private var progressStore
    @State private var revealedCount = 0
    @State private var showCompletion = false

    private let pathSequence = [4, 1, 7, 3, 5]
    private let columns = Array(repeating: GridItem(.flexible()), count: 3)

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                header
                    .padding(.horizontal)
                    .padding(.top, 8)

                Spacer(minLength: 0)

                VStack(spacing: DesignTokens.spacing * 1.5) {
                    Text("Chạm đúng thứ tự để soi sáng lối đi trong bóng tối!")
                        .font(.body(17, weight: .semibold))
                        .foregroundStyle(Palette.ink)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    LazyVGrid(columns: columns, spacing: DesignTokens.spacing) {
                        ForEach(0..<9, id: \.self) { tileIndex in
                            tileView(tileIndex)
                        }
                    }
                    .padding(20)
                    .background(Palette.ink, in: RoundedRectangle(cornerRadius: DesignTokens.radiusLg))
                }
                .padding(.horizontal, DesignTokens.spacing)

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
        .enableSwipeBack()
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
            Text("Ngọn đèn")
                .font(.display(17))
                .foregroundStyle(Palette.ink)
            Spacer(minLength: 0)
            Text("\(revealedCount) / \(pathSequence.count)")
                .font(.body(12, weight: .bold))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Palette.surface, in: Capsule())
                .foregroundStyle(Palette.ink.opacity(0.7))
        }
    }

    private func tileView(_ tileIndex: Int) -> some View {
        let isLit = pathSequence.prefix(revealedCount).contains(tileIndex)
        return Button {
            tap(tileIndex)
        } label: {
            Group {
                if isLit, let imageName = chapter.imageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                } else {
                    Text(isLit ? "🔦" : "⬛")
                        .font(.system(size: 32))
                }
            }
            .frame(minWidth: DesignTokens.minTapTarget, minHeight: DesignTokens.minTapTarget)
            .background(
                isLit ? Color(hex: chapter.accentHex) : Color.white.opacity(0.1),
                in: RoundedRectangle(cornerRadius: DesignTokens.cornerRadius)
            )
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
        }
        .buttonStyle(.plain)
        .disabled(isLit)
    }

    private func tap(_ tileIndex: Int) {
        guard revealedCount < pathSequence.count, pathSequence[revealedCount] == tileIndex else { return }
        revealedCount += 1
        if revealedCount == pathSequence.count {
            complete()
        }
    }

    private func complete() {
        progressStore.completeChapter(chapter.id)
        progressStore.addStar(for: "story")
        showCompletion = true
    }
}
