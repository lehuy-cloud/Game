import SwiftUI

/// Màn Home riêng cho Lật Hình — thẻ "Chơi tiếp" nhớ bộ thẻ vừa chơi,
/// bên dưới là lưới chọn bộ thẻ. Buddy/sao dùng chung `AppHeaderView` với
/// phần còn lại của app thay vì làm riêng một hệ thống buddy khác.
struct MatchingHomeView: View {
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @AppStorage("lastMatchingCategoryId") private var lastCategoryId = "animals"

    private let previewSwatches: [Color] = [
        Color(hex: "#E04A4A"), Color(hex: "#3F7FBF"), Color(hex: "#E9B83A"), Color(hex: "#7A8A5E")
    ]
    private let previewAnimalImages = ["animal_fox", "animal_tiger"]

    private var isRegularWidth: Bool { horizontalSizeClass == .regular }

    private var lastCategory: VocabularyCategory {
        VocabularyContent.categories.first { $0.id == lastCategoryId } ?? VocabularyContent.categories[0]
    }

    private var totalStars: Int {
        progressStore.starsByCategory.values.reduce(0, +)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.spacing) {
                header

                Text("Tìm hai thẻ giống nhau. Không có đồng hồ — cứ thong thả nhé.")
                    .font(.body(14))
                    .foregroundStyle(Palette.ink.opacity(0.6))
                    .padding(.horizontal, DesignTokens.spacing)

                NavigationLink {
                    LevelPickerView(categoryId: lastCategoryId)
                } label: {
                    continueCard
                }
                .buttonStyle(.plain)
                .padding(.horizontal, DesignTokens.spacing)

                sectionLabel("Chọn thứ bé thích")
                if isRegularWidth {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: DesignTokens.spacing), GridItem(.flexible(), spacing: DesignTokens.spacing)],
                              spacing: DesignTokens.spacing) {
                        ForEach(VocabularyContent.categories) { category in
                            NavigationLink {
                                LevelPickerView(categoryId: category.id)
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
                                LevelPickerView(categoryId: category.id)
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
        .navigationBarBackButtonHidden()
        .enableSwipeBack()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left").font(.system(size: 17, weight: .bold))
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Palette.surface))
                    .foregroundStyle(Palette.ink)
            }
            Text("Lật Hình")
                .font(.display(26))
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 6) {
                Text("⭐")
                Text("\(totalStars)")
                    .font(.body(15, weight: .bold))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(theme.tint, in: Capsule())
            .foregroundStyle(theme.deep)
        }
        .padding(.horizontal, DesignTokens.spacing)
    }

    private var continueCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("BỘ THẺ ĐANG CHỌN")
                .font(.body(11, weight: .bold))
                .tracking(1.0)
                .foregroundStyle(Palette.onAccent.opacity(0.8))
            Text(lastCategory.title)
                .font(.display(28))
                .foregroundStyle(Palette.onAccent)

            HStack(spacing: 8) {
                ForEach(peekCards, id: \.id) { card in
                    peekIcon(card)
                }
            }

            Text("Chơi ngay ▸")
                .font(.body(16, weight: .bold))
                .foregroundStyle(theme.deep)
                .padding(.horizontal, 20)
                .frame(height: 46)
                .background(Palette.onAccent, in: Capsule())
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.base, in: RoundedRectangle(cornerRadius: DesignTokens.radiusLg, style: .continuous))
        .shadow(color: Palette.ink.opacity(0.14), radius: 10, y: 5)
    }

    private var peekCards: [VocabularyCard] {
        Array(VocabularyContent.cards(for: lastCategoryId).prefix(4))
    }

    /// Ảnh thẻ thật thay vì emoji chung chung, cho khớp với ảnh minh hoạ
    /// vẽ riêng của app (giống `categoryCard`/`FlashcardDeckView`).
    private func peekIcon(_ card: VocabularyCard) -> some View {
        ZStack {
            Palette.onAccent.opacity(0.92)
            if let imageName = card.imageName {
                Image(imageName).resizable().scaledToFit().washed().padding(7)
            } else if let value = card.value {
                Text("\(value)").font(.display(22)).foregroundStyle(theme.deep)
            } else {
                Text(card.emoji).font(.system(size: 22))
            }
        }
        .frame(width: 44, height: 44)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.body(11, weight: .bold))
            .tracking(1.2)
            .foregroundStyle(Palette.ink.opacity(0.5))
            .padding(.horizontal, DesignTokens.spacing)
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
                Text("⭐ \(progressStore.starsByCategory[category.id, default: 0])")
                    .font(.body(12))
                    .foregroundStyle(Palette.ink.opacity(0.5))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
        .organicCard()
    }

    /// Cùng kiểu ảnh minh hoạ với màn "Học" (`VocabularyHomeView`) để hai màn
    /// nhất quán với nhau, chỉ đổi phần chân thẻ (sao thay vì số thẻ).
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
