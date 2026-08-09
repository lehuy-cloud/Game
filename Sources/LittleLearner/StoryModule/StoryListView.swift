import SwiftUI

struct StoryListView: View {
    @Binding var path: NavigationPath

    private let columns = [GridItem(.adaptive(minimum: 160))]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: DesignTokens.spacing) {
                ForEach(StoryContent.stories) { story in
                    NavigationLink(value: StoryRoute.story(story)) {
                        storyCard(story)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Truyện")
        .themedBackground()
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
        ZStack(alignment: .bottom) {
            if let coverImageName = story.coverImageName {
                GeometryReader { proxy in
                    Image(coverImageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                }
            } else {
                Color(hex: story.accentHex)
                Text("📖")
                    .font(.system(size: 40))
            }

            Text(story.title)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(8)
                .frame(maxWidth: .infinity)
                .background {
                    if story.coverImageName != nil {
                        Color.black.opacity(0.35)
                    }
                }
        }
        .frame(maxWidth: .infinity, minHeight: DesignTokens.minTapTarget * 2, maxHeight: DesignTokens.minTapTarget * 2)
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
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
