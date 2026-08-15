import SwiftUI

struct StoryListView: View {
    @Binding var path: NavigationPath

    private let columns = [GridItem(.adaptive(minimum: 160))]

    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.spacing) {
                AppHeaderView(title: "Truyện")

                LazyVGrid(columns: columns, spacing: DesignTokens.spacing) {
                    ForEach(StoryContent.stories) { story in
                        NavigationLink(value: StoryRoute.story(story)) {
                            storyCard(story)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, DesignTokens.spacing)
            }
            .padding(.bottom, DesignTokens.spacing)
        }
        .organicBackground()
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(for: StoryRoute.self) { route in
            switch route {
            case .story(let story):
                StoryHomeView(story: story, path: $path)
            case .chapter(let chapter):
                StoryChapterView(chapter: chapter, path: $path)
            case .miniGame(let chapter):
                miniGameView(for: chapter)
            }
        }
    }

    private func storyCard(_ story: Story) -> some View {
        VStack(spacing: 0) {
            Group {
                if let coverImageName = story.coverImageName {
                    Image(coverImageName)
                        .resizable()
                        .scaledToFill()
                        .washed()
                } else {
                    ZStack {
                        Color(hex: story.accentHex).opacity(0.18)
                        Text("📖")
                            .font(.system(size: 40))
                    }
                }
            }
            .frame(height: DesignTokens.minTapTarget * 1.6)
            .frame(maxWidth: .infinity)
            .clipped()

            HStack(spacing: 8) {
                Circle()
                    .fill(Color(hex: story.accentHex))
                    .frame(width: 9, height: 9)
                Text(story.title)
                    .font(.display(16))
                    .foregroundStyle(Palette.ink)
                    .lineLimit(2)
                Spacer(minLength: 0)
            }
            .padding(12)
        }
        .organicCard()
    }

    @ViewBuilder
    private func miniGameView(for chapter: StoryChapter) -> some View {
        switch chapter.id {
        case "ch1": IceMeltGameView(chapter: chapter, path: $path)
        case "ch2": LaughChaseGameView(chapter: chapter, path: $path)
        case "ch3": LanternPathGameView(chapter: chapter, path: $path)
        case "ch4": StormBattleGameView(chapter: chapter, path: $path)
        default: EmptyView()
        }
    }
}
