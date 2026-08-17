import SwiftUI

/// Màn Home riêng cho Lật Hình — thẻ "Chơi tiếp" nhớ bộ thẻ vừa chơi,
/// bên dưới là lưới chọn bộ thẻ.
///
/// LỖI ĐÃ SỬA: thẻ "BỘ THẺ ĐANG CHỌN" tô nguyên khối `theme.base` — với buddy
/// màu lam nó thành một mảng xanh gắt, chọi hẳn với nền kem và với thẻ "Chơi
/// tiếp" ở màn Chơi (vốn dùng `theme.tint`). Nay dùng nền tint nhạt, chữ ink,
/// nút "Chơi ngay" mới là chỗ duy nhất dùng màu đậm — đúng luật "màu chủ đề chỉ
/// là dấu nhận diện, không phải mảng nền lớn".
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
                    .font(.body(isRegularWidth ? 17 : 14))
                    .foregroundStyle(Palette.ink.opacity(0.6))
                    .padding(.horizontal, side)

                NavigationLink {
                    LevelPickerView(categoryId: lastCategoryId)
                } label: {
                    continueCard
                }
                .buttonStyle(.plain)
                .padding(.horizontal, side)

                sectionLabel("Chọn thứ bé thích")
                if isRegularWidth {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: gap), GridItem(.flexible(), spacing: gap)],
                              spacing: gap) {
                        ForEach(VocabularyContent.categories) { category in
                            NavigationLink {
                                LevelPickerView(categoryId: category.id)
                            } label: {
                                categoryCard(category)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, side)
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
                    .padding(.horizontal, side)
                }
            }
            .padding(.bottom, side)
        }
        .organicBackground()
        .navigationBarBackButtonHidden()
        .enableSwipeBack()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var side: CGFloat { Layout.side(isRegularWidth) }
    private var gap: CGFloat { Layout.gap(isRegularWidth) }

    private var header: some View {
        HStack(spacing: isRegularWidth ? 18 : 12) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: isRegularWidth ? 22 : 17, weight: .bold))
                    .frame(width: isRegularWidth ? 56 : 44, height: isRegularWidth ? 56 : 44)
                    .background(Circle().fill(Palette.surface))
                    .foregroundStyle(Palette.ink)
            }
            Text("Lật Hình")
                .font(.display(isRegularWidth ? 40 : 26))
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 6) {
                Text("⭐")
                Text("\(totalStars)")
                    .font(.body(isRegularWidth ? 18 : 15, weight: .bold))
            }
            .padding(.horizontal, isRegularWidth ? 18 : 14)
            .padding(.vertical, isRegularWidth ? 12 : 9)
            .background(theme.tint, in: Capsule())
            .foregroundStyle(theme.deep)
        }
        .padding(.horizontal, side)
    }

    private var continueCard: some View {
        VStack(alignment: .leading, spacing: isRegularWidth ? 18 : 14) {
            Text("BỘ THẺ ĐANG CHỌN")
                .font(.body(isRegularWidth ? 13 : 11, weight: .bold))
                .tracking(1.0)
                .foregroundStyle(Palette.ink.opacity(0.5))
            Text(lastCategory.title)
                .font(.display(isRegularWidth ? 38 : 28))
                .foregroundStyle(Palette.ink)

            HStack(spacing: isRegularWidth ? 12 : 8) {
                ForEach(peekCards, id: \.id) { card in
                    peekIcon(card)
                }
            }

            Text("Chơi ngay ▸")
                .font(.body(isRegularWidth ? 19 : 16, weight: .bold))
                .foregroundStyle(Palette.onAccent)
                .padding(.horizontal, isRegularWidth ? 28 : 20)
                .frame(height: isRegularWidth ? 58 : 46)
                .background(theme.deep, in: Capsule())
        }
        .padding(isRegularWidth ? 28 : 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.tint, in: RoundedRectangle(cornerRadius: DesignTokens.radiusLg, style: .continuous))
        .shadow(color: Palette.ink.opacity(0.08), radius: 8, y: 3)
    }

    private var peekCards: [VocabularyCard] {
        Array(VocabularyContent.cards(for: lastCategoryId).prefix(4))
    }

    private func peekIcon(_ card: VocabularyCard) -> some View {
        let size: CGFloat = isRegularWidth ? 58 : 44
        return ZStack {
            Palette.surface
            if let imageName = card.imageName {
                Image(imageName).resizable().scaledToFit().washed().padding(size * 0.16)
            } else if let colorHex = card.colorHex {
                // Bộ "Màu sắc": ô màu tràn viền, không phải chấm emoji trên nền trắng.
                Color(hex: colorHex)
            } else if let value = card.value {
                Text("\(value)").font(.display(isRegularWidth ? 28 : 22)).foregroundStyle(theme.deep)
            } else {
                Text(card.emoji).font(.system(size: isRegularWidth ? 28 : 22))
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: isRegularWidth ? 20 : 16, style: .continuous))
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.body(isRegularWidth ? 13 : 11, weight: .bold))
            .tracking(1.2)
            .foregroundStyle(Palette.ink.opacity(0.5))
            .padding(.horizontal, side)
    }

    private func categoryCard(_ category: VocabularyCategory) -> some View {
        VStack(spacing: 0) {
            imageArea(for: category)
                .frame(height: isRegularWidth ? 240 : 104)
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
                Text("⭐ \(progressStore.starsByCategory[category.id, default: 0])")
                    .font(.body(isRegularWidth ? 16 : 12))
                    .foregroundStyle(Palette.ink.opacity(0.5))
            }
            .padding(.horizontal, isRegularWidth ? 24 : 14)
            .padding(.vertical, isRegularWidth ? 20 : 12)
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
            .font(.display(isRegularWidth ? 72 : 32))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Palette.sageTint)

        default:
            if let imageName = category.imageName {
                CoverFill(imageName: imageName)
            } else {
                ZStack {
                    Color(hex: category.colorHex).opacity(0.18)
                    Image(systemName: category.symbolName)
                        .font(.system(size: isRegularWidth ? 54 : 36))
                        .foregroundStyle(Color(hex: category.colorHex))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
