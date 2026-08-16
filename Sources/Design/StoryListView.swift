import SwiftUI

struct StoryListView: View {
    @Binding var path: NavigationPath
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(TabRouter.self) private var router

    private var isRegularWidth: Bool { horizontalSizeClass == .regular }
    private var side: CGFloat { Layout.side(isRegularWidth) }
    private var gap: CGFloat { Layout.gap(isRegularWidth) }

    var body: some View {
        content
            .mainTabBar(router)
            .organicBackground()
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: StoryRoute.self) { route in
                switch route {
                case .story(let story): StoryHomeView(story: story, path: $path)
                case .chapter(let chapter): StoryChapterView(chapter: chapter, path: $path)
                case .miniGame(let chapter): miniGameView(for: chapter)
                }
            }
    }

    // LỖI ĐÃ SỬA: `GridItem(.adaptive(minimum: 160))` cho ra 4-5 cột tí hon
    // trên iPad. Thiết kế là lưới 2 cột, thẻ cao bằng nhau, lề 44.
    @ViewBuilder private var content: some View {
        if isRegularWidth {
            VStack(spacing: 0) {
                AppHeaderView(title: "Truyện").padding(.top, 18)
                GeometryReader { proxy in
                    let rows = stride(from: 0, to: StoryContent.stories.count, by: 2).map {
                        Array(StoryContent.stories[$0 ..< min($0 + 2, StoryContent.stories.count)])
                    }
                    let rowH = (proxy.size.height - CGFloat(max(rows.count - 1, 0)) * gap) / CGFloat(max(rows.count, 1))
                    VStack(spacing: gap) {
                        ForEach(rows.indices, id: \.self) { r in
                            HStack(spacing: gap) {
                                ForEach(rows[r]) { story in
                                    NavigationLink(value: StoryRoute.story(story)) { storyCard(story) }
                                        .buttonStyle(.plain)
                                        .frame(maxWidth: .infinity)
                                }
                                if rows[r].count == 1 { Color.clear.frame(maxWidth: .infinity) }
                            }
                            .frame(height: rowH)
                        }
                    }
                }
                .padding(.horizontal, side)
                .padding(.top, gap)
                .padding(.bottom, side)
            }
        } else {
            ScrollView {
                VStack(spacing: DesignTokens.spacing) {
                    AppHeaderView(title: "Truyện")
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: gap)], spacing: gap) {
                        ForEach(StoryContent.stories) { story in
                            NavigationLink(value: StoryRoute.story(story)) { storyCard(story) }
                                .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, side)
                }
                .padding(.bottom, DesignTokens.spacing)
            }
        }
    }

    private func storyCard(_ story: Story) -> some View {
        VStack(spacing: 0) {
            Group {
                if let coverImageName = story.coverImageName {
                    Image(coverImageName).resizable().scaledToFill().washed()
                } else {
                    ZStack {
                        Color(hex: story.accentHex).opacity(0.18)
                        Text("📖").font(.system(size: isRegularWidth ? 64 : 40))
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: isRegularWidth ? .infinity : DesignTokens.minTapTarget * 1.6)
            .clipped()

            HStack(alignment: .firstTextBaseline, spacing: isRegularWidth ? 11 : 8) {
                Circle()
                    .fill(Color(hex: story.accentHex))
                    .frame(width: isRegularWidth ? 11 : 9, height: isRegularWidth ? 11 : 9)
                    .alignmentGuide(.firstTextBaseline) { d in d.height * 0.9 }
                Text(story.title)
                    .font(.display(isRegularWidth ? 26 : 16))
                    .foregroundStyle(Palette.ink)
                    .lineLimit(2)
                Spacer(minLength: 0)
            }
            .padding(isRegularWidth ? 22 : 12)
        }
        .frame(maxHeight: .infinity)
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
