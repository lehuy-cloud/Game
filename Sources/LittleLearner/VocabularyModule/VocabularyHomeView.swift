import SwiftUI

struct VocabularyHomeView: View {
    private let previewSwatches: [Color] = [
        Color(hex: "#E04A4A"), Color(hex: "#3F7FBF"), Color(hex: "#E9B83A"), Color(hex: "#7A8A5E")
    ]
    private let previewAnimalImages = ["animal_fox", "animal_lion", "animal_elephant", "animal_tiger"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.spacing) {
                AppHeaderView(title: "Học")

                Text("Ba chủ đề, đúng như VocabularyContent.")
                    .font(.body(14))
                    .foregroundStyle(Palette.ink.opacity(0.58))
                    .padding(.horizontal, DesignTokens.spacing)

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
            .padding(.bottom, DesignTokens.spacing)
        }
        .organicBackground()
        .toolbar(.hidden, for: .navigationBar)
    }

    private func categoryCard(_ category: VocabularyCategory) -> some View {
        VStack(spacing: 0) {
            imageArea(for: category)
                .frame(height: 104)
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
            HStack(spacing: 6) {
                ForEach(previewAnimalImages, id: \.self) { name in
                    ZStack {
                        Circle().fill(Palette.surface)
                        // Sticker art is cropped tight to its canvas; inset it so ears/tails
                        // aren't cut off by the circular clip.
                        Image(name)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 64, height: 64)
                            .washed()
                    }
                    .frame(width: 80, height: 80)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: category.colorHex).opacity(0.18))

        case "colors":
            HStack(spacing: 9) {
                ForEach(previewSwatches.indices, id: \.self) { i in
                    Circle().fill(previewSwatches[i]).frame(width: 30, height: 30)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Palette.surfaceAlt)

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
