import SwiftUI

struct VocabularyHomeView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.theme) private var theme

    private let previewSwatches: [Color] = [
        Color(hex: "#E04A4A"), Color(hex: "#3F7FBF"), Color(hex: "#E9B83A"), Color(hex: "#7A8A5E")
    ]
    private let previewAnimalImages = ["animal_fox", "animal_tiger"]

    private var isRegularWidth: Bool { horizontalSizeClass == .regular }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.spacing) {
                AppHeaderView(title: "Học")

                Text("Chọn một chủ đề để đọc thẻ từ")
                    .font(.body(14))
                    .foregroundStyle(Palette.ink.opacity(0.58))
                    .padding(.horizontal, DesignTokens.spacing)

                if isRegularWidth {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: DesignTokens.spacing), GridItem(.flexible(), spacing: DesignTokens.spacing)],
                              spacing: DesignTokens.spacing) {
                        ForEach(VocabularyContent.categories) { category in
                            NavigationLink {
                                FlashcardDeckView(categoryId: category.id)
                            } label: {
                                categoryCard(category)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, DesignTokens.spacing)
                } else {
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
                    .padding(.horizontal, DesignTokens.spacing)
                }
            }
            .padding(.bottom, DesignTokens.spacing)
        }
        .organicBackground()
        .toolbar(.hidden, for: .navigationBar)
    }

    private func categoryCard(_ category: VocabularyCategory) -> some View {
        VStack(spacing: 0) {
            imageArea(for: category)
                .frame(height: isRegularWidth ? 240 : 104)
                .contentShape(Rectangle())
                .clipped()

            HStack(spacing: 8) {
                Circle()
                    .fill(Color(hex: category.colorHex))
                    .frame(width: 9, height: 9)
                Text(category.title)
                    .font(.display(17))
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                Spacer(minLength: 0)
                Text("\(VocabularyContent.cards(for: category.id).count) thẻ")
                    .font(.body(12))
                    .foregroundStyle(Palette.ink.opacity(0.5))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(theme.tint)

        case "colors":
            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                GridRow {
                    previewSwatches[0]
                    previewSwatches[1]
                }
                GridRow {
                    previewSwatches[2]
                    previewSwatches[3]
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case "numbers":
            HStack(spacing: isRegularWidth ? 14 : 6) {
                Text("1")
                    .foregroundStyle(theme.deep)
                Text("2")
                    .foregroundStyle(Palette.ink.opacity(0.3))
                Text("3")
                    .foregroundStyle(Palette.ink.opacity(0.18))
            }
            .font(.display(isRegularWidth ? 72 : 32))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Palette.sageTint)

        default:
            if let imageName = category.imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .washed()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
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
