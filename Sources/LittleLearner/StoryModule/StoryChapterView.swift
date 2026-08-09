import SwiftUI

struct StoryChapterView: View {
    let chapter: StoryChapter
    @Binding var path: NavigationPath

    @Environment(ProgressStore.self) private var progressStore
    @State private var pageIndex = 0
    @State private var showCompletion = false
    @State private var revealedWord: String?

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

            ScrollView {
                VStack(spacing: DesignTokens.spacing) {
                    let page = currentPage

                    if hasHeroImage {
                        Color.clear
                            .frame(height: 500)
                            .contentShape(Rectangle())
                            .onTapGesture { speakPrimaryVocabWord() }
                    } else {
                        Text(page.emoji)
                            .font(.system(size: 100))
                    }

                    if isChallengeStep {
                        challengeCard
                    } else {
                        narrationCard(page, isOverlay: hasHeroImage)

                        if isLastNarrativePage && !chapter.hasMiniGame {
                            continueButton
                        }
                    }
                }
                .padding()
            }
            .scrollBounceBehavior(.basedOnSize)
            .gesture(swipeGesture)

            if let revealedWord {
                Text(revealedWord)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, DesignTokens.spacing * 1.5)
                    .padding(.vertical, DesignTokens.spacing)
                    .background(Color.black.opacity(0.5), in: RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
                    .transition(.scale.combined(with: .opacity))
            }

            if showCompletion {
                StoryCompletionOverlay(outroText: chapter.outroText) {
                    path = NavigationPath()
                }
            }
        }
        .navigationTitle("Chương \(chapter.index)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(hasHeroImage ? .dark : nil, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    SpeechService.shared.speak(currentPage.text, language: "vi-VN")
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                }
                .opacity(isChallengeStep ? 0 : 1)
                .disabled(isChallengeStep)
            }
        }
    }

    private var hasHeroImage: Bool {
        currentPage.imageName != nil
    }

    private func speakPrimaryVocabWord() {
        guard let cardId = chapter.vocabCardIds.first,
              let card = VocabularyContent.cards.first(where: { $0.id == cardId })
        else { return }
        SpeechService.shared.speak(card.word)

        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            revealedWord = card.word
        }
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            withAnimation {
                revealedWord = nil
            }
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
            LinearGradient(colors: [Color(hex: chapter.secondaryHex), .white], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        }
    }

    private func narrationCard(_ page: StoryPage, isOverlay: Bool) -> some View {
        Text(narrationText(page, isOverlay: isOverlay))
            .font(.title3.bold())
            .foregroundStyle(isOverlay ? .white : .primary)
            .multilineTextAlignment(.center)
            .padding()
            .background {
                if isOverlay {
                    RoundedRectangle(cornerRadius: DesignTokens.cornerRadius)
                        .fill(Color.black.opacity(0.35))
                }
            }
    }

    private func narrationText(_ page: StoryPage, isOverlay: Bool) -> AttributedString {
        var attributed = AttributedString(page.text)
        if SpeechService.shared.speakingText == page.text,
           let nsRange = SpeechService.shared.speakingRange,
           let stringRange = Range(nsRange, in: page.text),
           let attrRange = Range(stringRange, in: attributed) {
            attributed[attrRange].foregroundColor = isOverlay ? .yellow : Color.accentColor
        }
        return attributed
    }

    private var challengeCard: some View {
        VStack(spacing: DesignTokens.spacing) {
            Text("Sẵn sàng thử thách chưa?")
                .font(.title3.bold())
                .foregroundStyle(hasHeroImage ? .white : .primary)
                .multilineTextAlignment(.center)

            continueButton
        }
        .padding()
        .background {
            if hasHeroImage {
                RoundedRectangle(cornerRadius: DesignTokens.cornerRadius)
                    .fill(Color.black.opacity(0.35))
            }
        }
    }

    @ViewBuilder
    private var continueButton: some View {
        if chapter.hasMiniGame {
            NavigationLink(value: StoryRoute.miniGame(chapter)) {
                Text("Bắt đầu thử thách")
            }
            .buttonStyle(.big)
        } else {
            Button("Hoàn thành câu chuyện") {
                progressStore.completeChapter(chapter.id)
                progressStore.addStar(for: "story")
                showCompletion = true
            }
            .buttonStyle(.big)
        }
    }
}
