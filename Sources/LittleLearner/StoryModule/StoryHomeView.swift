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
                    .buttonStyle(.plain)
                    .disabled(!unlocked)
                }
            }
            .padding()
        }
        .navigationTitle(story.title)
        .organicBackground()
        .toolbar(.visible, for: .navigationBar)
    }

    private func chapterCard(_ chapter: StoryChapter, unlocked: Bool) -> some View {
        let hasImage = unlocked && chapter.imageName != nil
        let cardHeight = DesignTokens.minTapTarget * 1.8
        let isCompleted = progressStore.completedStoryChapterIds.contains(chapter.id)

        return VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                Group {
                    if hasImage, let imageName = chapter.imageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .washed()
                    } else {
                        ZStack {
                            Color(hex: chapter.accentHex).opacity(0.18)
                            Text(unlocked ? chapter.icon : "🔒")
                                .font(.system(size: 40))
                        }
                    }
                }
                .frame(height: cardHeight)
                .frame(maxWidth: .infinity)
                .clipped()

                if unlocked {
                    Text(isCompleted ? "⭐ Xong" : "Đang đọc")
                        .font(.body(11, weight: .bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Palette.surface, in: Capsule())
                        .foregroundStyle(Palette.ink.opacity(0.75))
                        .padding(8)
                }
            }

            HStack(spacing: 8) {
                Circle()
                    .fill(Color(hex: chapter.accentHex))
                    .frame(width: 9, height: 9)
                Text("Chương \(chapter.index): \(chapter.title)")
                    .font(.display(15))
                    .foregroundStyle(Palette.ink)
                    .lineLimit(2)
                Spacer(minLength: 0)
            }
            .padding(12)
        }
        .organicCard()
        .opacity(unlocked ? 1 : 0.5)
    }

    private func isUnlocked(_ chapter: StoryChapter) -> Bool {
        guard let idx = story.chapters.firstIndex(of: chapter), idx > 0 else { return true }
        let previous = story.chapters[idx - 1]
        return progressStore.completedStoryChapterIds.contains(previous.id)
    }
}
