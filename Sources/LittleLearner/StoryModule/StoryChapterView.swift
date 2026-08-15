import SwiftUI

struct StoryChapterView: View {
    let chapter: StoryChapter
    @Binding var path: NavigationPath

    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.theme) private var theme
    @State private var pageIndex = 0
    @State private var showCompletion = false

    /// One extra step past the last narrative page, where the challenge-start button lives.
    private var maxPageIndex: Int {
        chapter.hasMiniGame ? chapter.pages.count : chapter.pages.count - 1
    }

    private var isChallengeStep: Bool {
        chapter.hasMiniGame && pageIndex == chapter.pages.count
    }

    private var isLastNarrativePage: Bool {
        pageIndex == chapter.pages.count - 1
    }

    /// Clamped so the challenge step (past the real pages) can still show the last page's art/background.
    private var currentPage: StoryPage {
        chapter.pages[min(pageIndex, chapter.pages.count - 1)]
    }

    private var pageVocabCards: [VocabularyCard] {
        chapter.vocabCardIds.compactMap { id in VocabularyContent.cards.first { $0.id == id } }
    }

    private var hasHeroImage: Bool {
        currentPage.imageName != nil
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 30)
            .onEnded { value in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                withAnimation {
                    if value.translation.width < 0 {
                        pageIndex = min(pageIndex + 1, maxPageIndex)
                    } else {
                        pageIndex = max(pageIndex - 1, 0)
                    }
                }
            }
    }

    var body: some View {
        ZStack {
            pageBackground

            if !hasHeroImage {
                VStack {
                    Spacer()
                    Text(currentPage.emoji).font(.system(size: 100))
                    Spacer()
                }
            }

            VStack(spacing: 0) {
                header
                    .padding(.horizontal)
                    .padding(.top, 8)
                ReadingProgressBar(current: pageIndex + 1, total: chapter.pages.count, theme: theme, maxTicks: 8)
                    .padding(.horizontal)
                    .padding(.top, 12)
                Spacer(minLength: 0)
            }

            VStack {
                Spacer(minLength: 0)
                sheet
            }

            if showCompletion {
                StoryCompletionOverlay(outroText: chapter.outroText) {
                    path = NavigationPath()
                }
            }
        }
        .gesture(swipeGesture)
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button { path.removeLast() } label: {
                Image(systemName: "chevron.left").font(.system(size: 17, weight: .bold))
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(hasHeroImage ? Color.white.opacity(0.92) : Palette.surface))
                    .foregroundStyle(Palette.ink)
            }
            Text("Chương \(chapter.index) · \(chapter.title)")
                .font(.display(17))
                .foregroundStyle(hasHeroImage ? .white : Palette.ink)
                .shadow(color: .black.opacity(hasHeroImage ? 0.4 : 0), radius: 4, y: 1)
                .lineLimit(1)
            Spacer(minLength: 0)
            Text("\(min(pageIndex + 1, chapter.pages.count)) / \(chapter.pages.count)")
                .font(.body(12, weight: .bold))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(hasHeroImage ? Color.white.opacity(0.92) : Palette.surface, in: Capsule())
                .foregroundStyle(Palette.ink.opacity(0.7))
        }
    }

    @ViewBuilder
    private var pageBackground: some View {
        if let imageName = currentPage.imageName {
            GeometryReader { proxy in
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
            }
            .ignoresSafeArea()
        } else {
            LinearGradient(colors: [Color(hex: chapter.secondaryHex), Palette.bg], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        }
    }

    private var sheet: some View {
        VStack(alignment: .leading, spacing: 14) {
            if isChallengeStep {
                Text("Sẵn sàng thử thách chưa?")
                    .font(.display(20))
                    .foregroundStyle(Palette.ink)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                continueButton
            } else {
                HStack(alignment: .top, spacing: 14) {
                    Text(narrationText(currentPage))
                        .font(.body(17, weight: .semibold))
                        .foregroundStyle(Palette.ink)
                    Spacer(minLength: 0)
                    speakerButton
                }

                if !pageVocabCards.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(pageVocabCards) { card in
                            Button {
                                SpeechService.shared.speak(card.word)
                            } label: {
                                HStack(spacing: 6) {
                                    Text(card.emoji)
                                    Text(card.word)
                                        .font(.body(13, weight: .bold))
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Palette.bg, in: Capsule())
                                .foregroundStyle(Palette.ink)
                            }
                        }
                    }
                }

                if isLastNarrativePage && !chapter.hasMiniGame {
                    continueButton
                } else {
                    bottomHintNav
                }
            }
        }
        .padding(20)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: DesignTokens.radiusLg,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: DesignTokens.radiusLg
            )
            .fill(Palette.surface)
        )
        .shadow(color: Palette.ink.opacity(0.14), radius: 20, y: -6)
    }

    private var speakerButton: some View {
        Button {
            SpeechService.shared.speak(currentPage.text, language: "vi-VN")
        } label: {
            Image(systemName: "speaker.wave.2.fill")
                .font(.system(size: 18))
                .foregroundStyle(Palette.onAccent)
                .frame(width: 48, height: 48)
                .background(Circle().fill(theme.base))
        }
    }

    private var bottomHintNav: some View {
        HStack {
            Text("vuốt để sang trang")
                .font(.body(12))
                .foregroundStyle(Palette.ink.opacity(0.45))
            Spacer(minLength: 0)
            HStack(spacing: 10) {
                Button {
                    withAnimation { pageIndex = max(pageIndex - 1, 0) }
                } label: {
                    Image(systemName: "chevron.left")
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Palette.bg))
                        .foregroundStyle(Palette.ink)
                }
                .disabled(pageIndex == 0)
                .opacity(pageIndex == 0 ? 0.4 : 1)

                Button {
                    withAnimation { pageIndex = min(pageIndex + 1, maxPageIndex) }
                } label: {
                    Image(systemName: "chevron.right")
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(theme.base))
                        .foregroundStyle(Palette.onAccent)
                }
            }
        }
    }

    private func narrationText(_ page: StoryPage) -> AttributedString {
        var attributed = AttributedString(page.text)
        if SpeechService.shared.speakingText == page.text,
           let nsRange = SpeechService.shared.speakingRange,
           let stringRange = Range(nsRange, in: page.text),
           let attrRange = Range(stringRange, in: attributed) {
            attributed[attrRange].foregroundColor = theme.base
        }
        return attributed
    }

    @ViewBuilder
    private var continueButton: some View {
        if chapter.hasMiniGame {
            NavigationLink(value: StoryRoute.miniGame(chapter)) {
                Text("Bắt đầu thử thách")
            }
            .buttonStyle(PillButtonStyle(theme: theme))
        } else {
            Button("Hoàn thành câu chuyện") {
                progressStore.completeChapter(chapter.id)
                progressStore.addStar(for: "story")
                showCompletion = true
            }
            .buttonStyle(PillButtonStyle(theme: theme))
        }
    }
}
