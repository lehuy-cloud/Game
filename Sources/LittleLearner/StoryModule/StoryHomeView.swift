import SwiftUI

struct StoryHomeView: View {
    let story: Story
    @Binding var path: NavigationPath
    @Environment(ProgressStore.self) private var progressStore

    private let columns = [GridItem(.adaptive(minimum: 150))]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: DesignTokens.spacing) {
                ForEach(story.chapters) { chapter in
                    let unlocked = isUnlocked(chapter)
                    NavigationLink(value: StoryRoute.chapter(chapter)) {
                        chapterCard(chapter, unlocked: unlocked)
                    }
                    .disabled(!unlocked)
                }
            }
            .padding()
        }
        .navigationTitle(story.title)
        .themedBackground()
    }

    private func chapterCard(_ chapter: StoryChapter, unlocked: Bool) -> some View {
        let hasImage = unlocked && chapter.imageName != nil
        let cardHeight = DesignTokens.minTapTarget * 1.8

        return ZStack(alignment: .bottom) {
            if hasImage, let imageName = chapter.imageName {
                GeometryReader { proxy in
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                }
            } else {
                Color(hex: chapter.accentHex)
                Text(unlocked ? chapter.icon : "🔒")
                    .font(.system(size: 40))
            }

            Text("Chương \(chapter.index): \(chapter.title)")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(8)
                .frame(maxWidth: .infinity)
                .background {
                    if hasImage {
                        Color.black.opacity(0.35)
                    }
                }
        }
        .frame(maxWidth: .infinity, minHeight: cardHeight, maxHeight: cardHeight)
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
        .opacity(unlocked ? 1 : 0.5)
    }

    private func isUnlocked(_ chapter: StoryChapter) -> Bool {
        guard let idx = story.chapters.firstIndex(of: chapter), idx > 0 else { return true }
        let previous = story.chapters[idx - 1]
        return progressStore.completedStoryChapterIds.contains(previous.id)
    }
}
