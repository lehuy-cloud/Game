import SwiftUI

struct VocabularyHomeView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.theme) private var theme
    @Environment(TabRouter.self) private var router

    private let previewSwatches: [Color] = [
        Color(hex: "#E04A4A"), Color(hex: "#3F7FBF"), Color(hex: "#E9B83A"), Color(hex: "#7A8A5E")
    ]
    private let previewAnimalImages = ["animal_fox", "animal_tiger"]

    private var isRegularWidth: Bool { horizontalSizeClass == .regular }
    private var side: CGFloat { Layout.side(isRegularWidth) }
    private var gap: CGFloat { Layout.gap(isRegularWidth) }

    var body: some View {
        Group {
            if isRegularWidth { regularBody } else { compactBody }
        }
        .mainTabBar(router)
        .organicBackground()
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - iPad: tiêu đề cố định + lưới 2×2 ăn hết chiều cao còn lại (P1)
    //
    // LỖI ĐÃ SỬA: bản cũ dùng ScrollView + LazyVGrid. LazyVGrid co theo nội
    // dung và dồn lên trên, ScrollView lại lấy chiều cao bằng nội dung, nên
    // nửa dưới màn hình trống trơn. Thiết kế là `flex:1` + `rows: 1fr 1fr`
    // — phải đo chiều cao còn lại rồi chia đôi.

    private var regularBody: some View {
        VStack(spacing: 0) {
            titleBlock
            GeometryReader { proxy in
                let rowH = (proxy.size.height - gap) / 2
                let rows = stride(from: 0, to: VocabularyContent.categories.count, by: 2).map {
                    Array(VocabularyContent.categories[$0 ..< min($0 + 2, VocabularyContent.categories.count)])
                }
                VStack(spacing: gap) {
                    ForEach(rows.indices, id: \.self) { r in
                        HStack(spacing: gap) {
                            ForEach(rows[r]) { category in
                                NavigationLink {
                                    FlashcardDeckView(categoryId: category.id)
                                } label: {
                                    categoryCard(category)
                                }
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
    }

    // MARK: - iPhone: giữ nguyên danh sách cuộn 1 cột

    private var compactBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.spacing) {
                titleBlock
                VStack(spacing: 13) {
                    ForEach(VocabularyContent.categories) { category in
                        NavigationLink {
                            FlashcardDeckView(categoryId: category.id)
                        } label: {
                            categoryCard(category)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, side)
            }
            .padding(.bottom, DesignTokens.spacing)
        }
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            AppHeaderView(title: "Học")
            Text("Chọn một chủ đề để đọc thẻ từ")
                .font(.body(isRegularWidth ? 17 : 14))
                .foregroundStyle(Palette.ink.opacity(0.58))
                .padding(.horizontal, side)
        }
        .padding(.top, isRegularWidth ? 18 : 0)
    }

    private func categoryCard(_ category: VocabularyCategory) -> some View {
        VStack(spacing: 0) {
            imageArea(for: category)
                // Ăn hết phần trên của thẻ thay vì cao cố định 240pt.
                .frame(maxWidth: .infinity, maxHeight: isRegularWidth ? .infinity : 104)
                .contentShape(Rectangle())
                .clipped()

            HStack(spacing: isRegularWidth ? 11 : 8) {
                Circle()
                    .fill(Color(hex: category.colorHex))
                    .frame(width: isRegularWidth ? 11 : 9, height: isRegularWidth ? 11 : 9)
                Text(category.title)
                    .font(.display(isRegularWidth ? 26 : 17))
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                Spacer(minLength: 0)
                Text("\(VocabularyContent.cards(for: category.id).count) thẻ")
                    .font(.body(isRegularWidth ? 16 : 12))
                    .foregroundStyle(Palette.ink.opacity(0.5))
            }
            .padding(.horizontal, isRegularWidth ? 24 : 14)
            .padding(.vertical, isRegularWidth ? 20 : 12)
        }
        .frame(maxHeight: .infinity)
        .organicCard()
    }

    @ViewBuilder
    private func imageArea(for category: VocabularyCategory) -> some View {
        switch category.id {
        case "animals":
            HStack(spacing: isRegularWidth ? 20 : 10) {
                ForEach(previewAnimalImages, id: \.self) { name in
                    Image(name)
                        .resizable()
                        .scaledToFit()
                        .frame(width: isRegularWidth ? 120 : 56, height: isRegularWidth ? 120 : 56)
                        .washed()
                }
            }
            .padding(isRegularWidth ? 20 : 0)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(theme.tint)

        case "colors":
            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                GridRow { previewSwatches[0]; previewSwatches[1] }
                GridRow { previewSwatches[2]; previewSwatches[3] }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case "numbers":
            HStack(spacing: isRegularWidth ? 14 : 6) {
                Text("1").foregroundStyle(theme.deep)
                Text("2").foregroundStyle(Palette.ink.opacity(0.3))
                Text("3").foregroundStyle(Palette.ink.opacity(0.18))
            }
            .font(.display(isRegularWidth ? 96 : 32))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Palette.sageTint)

        default:
            if let imageName = category.imageName {
                CoverFill(imageName: imageName)
            } else {
                ZStack {
                    Color(hex: category.colorHex).opacity(0.18)
                    Image(systemName: category.symbolName)
                        .font(.system(size: 36))
                        .foregroundStyle(Color(hex: category.colorHex))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
