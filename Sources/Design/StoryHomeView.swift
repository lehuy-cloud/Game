import SwiftUI

struct StoryHomeView: View {
    let story: Story
    @Binding var path: NavigationPath
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isRegularWidth: Bool { horizontalSizeClass == .regular }
    private var side: CGFloat { Layout.side(isRegularWidth) }
    private var gap: CGFloat { Layout.gap(isRegularWidth) }

    var body: some View {
        Group {
            if isRegularWidth { regularBody } else { compactBody }
        }
        .organicBackground()
        // LỖI ĐÃ SỬA: navigationTitle của hệ thống dùng font/size mặc định và
        // căn giữa — không khớp thiết kế. Dùng header tự vẽ như các màn khác.
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden()
        .enableSwipeBack()
    }

    // MARK: - iPad: lưới 3 cột chia hết chiều cao
    //
    // LỖI ĐÃ SỬA: `GridItem(.adaptive(minimum: 150))` xếp cả 5 chương thành
    // một hàng thẻ tí hon (tên chương bị cắt "Người bạn đ..."), nửa dưới màn
    // trống. Nay 3 cột, thẻ cao bằng nhau và ăn hết chiều cao còn lại.

    private var regularBody: some View {
        VStack(spacing: 0) {
            header
            GeometryReader { proxy in
                let perRow = 3
                let rows = stride(from: 0, to: story.chapters.count, by: perRow).map {
                    Array(story.chapters[$0 ..< min($0 + perRow, story.chapters.count)])
                }
                let rowCount = CGFloat(max(rows.count, 1))
                let rowH = (proxy.size.height - gap * (rowCount - 1)) / rowCount
                VStack(spacing: gap) {
                    ForEach(rows.indices, id: \.self) { r in
                        HStack(spacing: gap) {
                            ForEach(rows[r]) { chapter in
                                chapterLink(chapter).frame(maxWidth: .infinity)
                            }
                            ForEach(0 ..< (perRow - rows[r].count), id: \.self) { _ in
                                Color.clear.frame(maxWidth: .infinity)
                            }
                        }
                        .frame(height: rowH)
                    }
                }
            }
            .padding(.horizontal, side)
            .padding(.top, gap)
            .padding(.bottom, side)
        }
    }

    private var compactBody: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: gap)], spacing: gap) {
                    ForEach(story.chapters) { chapter in
                        chapterLink(chapter)
                    }
                }
                .padding(.horizontal, side)
                .padding(.vertical, gap)
            }
        }
    }

    private var header: some View {
        HStack(spacing: isRegularWidth ? 18 : 12) {
            Button { path.removeLast() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: isRegularWidth ? 22 : 17, weight: .bold))
                    .frame(width: isRegularWidth ? 56 : 44, height: isRegularWidth ? 56 : 44)
                    .background(Circle().fill(Palette.surface))
                    .foregroundStyle(Palette.ink)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(story.title)
                    .font(.display(isRegularWidth ? 40 : 22))
                    .foregroundStyle(Palette.ink)
                    .lineLimit(2)
                Text("\(story.chapters.count) chương · \(completedCount) đã xong")
                    .font(.body(isRegularWidth ? 17 : 13))
                    .foregroundStyle(Palette.ink.opacity(0.55))
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, side)
        .padding(.top, isRegularWidth ? 18 : 8)
    }

    private var completedCount: Int {
        story.chapters.filter { progressStore.completedStoryChapterIds.contains($0.id) }.count
    }

    private func chapterLink(_ chapter: StoryChapter) -> some View {
        let unlocked = isUnlocked(chapter)
        return NavigationLink(value: StoryRoute.chapter(chapter)) {
            chapterCard(chapter, unlocked: unlocked)
        }
        .buttonStyle(.plain)
        .disabled(!unlocked)
    }

    private func chapterCard(_ chapter: StoryChapter, unlocked: Bool) -> some View {
        let hasImage = unlocked && chapter.imageName != nil
        let isCompleted = progressStore.completedStoryChapterIds.contains(chapter.id)

        return VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                Group {
                    if hasImage, let imageName = chapter.imageName {
                        Image(imageName).resizable().scaledToFill().washed()
                    } else {
                        ZStack {
                            Color(hex: chapter.accentHex).opacity(0.18)
                            Text(unlocked ? chapter.icon : "🔒")
                                .font(.system(size: isRegularWidth ? 64 : 40))
                        }
                    }
                }
                // Ảnh ăn hết phần trên thay vì cao cố định 180pt.
                .frame(maxWidth: .infinity, maxHeight: isRegularWidth ? .infinity : DesignTokens.minTapTarget * 1.8)
                .clipped()

                if unlocked {
                    Text(isCompleted ? "⭐ Xong" : "Đang đọc")
                        .font(.body(isRegularWidth ? 14 : 11, weight: .bold))
                        .padding(.horizontal, isRegularWidth ? 14 : 10)
                        .padding(.vertical, isRegularWidth ? 8 : 5)
                        .background(Palette.surface, in: Capsule())
                        .foregroundStyle(Palette.ink.opacity(0.75))
                        .padding(isRegularWidth ? 14 : 8)
                }
            }

            HStack(alignment: .top, spacing: isRegularWidth ? 11 : 8) {
                Circle()
                    .fill(Color(hex: chapter.accentHex))
                    .frame(width: isRegularWidth ? 11 : 9, height: isRegularWidth ? 11 : 9)
                    .padding(.top, isRegularWidth ? 9 : 5)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Chương \(chapter.index)")
                        .font(.body(isRegularWidth ? 15 : 12, weight: .bold))
                        .foregroundStyle(Palette.ink.opacity(0.5))
                    // Tên chương xuống dòng đủ chỗ, không còn bị cắt giữa chữ.
                    Text(chapter.title)
                        .font(.display(isRegularWidth ? 24 : 15))
                        .foregroundStyle(Palette.ink)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            .padding(isRegularWidth ? 22 : 12)
        }
        .frame(maxHeight: .infinity)
        .organicCard()
        .opacity(unlocked ? 1 : 0.5)
    }

    private func isUnlocked(_ chapter: StoryChapter) -> Bool {
        guard let idx = story.chapters.firstIndex(of: chapter), idx > 0 else { return true }
        let previous = story.chapters[idx - 1]
        return progressStore.completedStoryChapterIds.contains(previous.id)
    }
}
