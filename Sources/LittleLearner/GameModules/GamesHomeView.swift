import SwiftUI

struct GamesHomeView: View {
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.theme) private var theme
    private let columns = [GridItem(.adaptive(minimum: 150))]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.spacing) {
                AppHeaderView(title: "Chơi")

                sectionLabel("Chưa cần biết chữ")
                VStack(spacing: 10) {
                    NavigationLink {
                        ListenChooseGameView()
                    } label: {
                        gameRow(icon: "speaker.wave.3.fill", title: "Nghe rồi chọn",
                                subtitle: "Nghe từ, chỉ đúng ảnh", tint: theme.base)
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        SecretDoorGameView()
                    } label: {
                        gameRow(icon: "magnifyingglass", title: "Ô cửa bí mật",
                                subtitle: "Nhìn ô cửa, đoán con vật", tint: theme.base)
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        OddOneOutGameView()
                    } label: {
                        gameRow(icon: "sparkles", title: "Tìm bạn khác loài",
                                subtitle: "Chỉ ra đứa lạc đàn", tint: theme.base)
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        CountingGameView()
                    } label: {
                        gameRow(icon: "textformat.123", title: "Đếm cùng bé",
                                subtitle: "Đếm rồi chọn đúng số", tint: theme.base)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, DesignTokens.spacing)

                sectionLabel("Khi bé biết mặt chữ")
                NavigationLink {
                    MatchWordGameView()
                } label: {
                    gameRow(icon: "textformat.abc", title: "Ghép chữ với hình",
                            subtitle: "Kéo từ vào đúng ảnh", tint: theme.base)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, DesignTokens.spacing)

                LazyVGrid(columns: columns, spacing: DesignTokens.spacing) {
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
            .padding(.bottom, DesignTokens.spacing)
        }
        .organicBackground()
        .toolbar(.hidden, for: .navigationBar)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.body(11, weight: .bold))
            .tracking(1.2)
            .foregroundStyle(Palette.ink.opacity(0.5))
            .padding(.horizontal, DesignTokens.spacing)
    }

    private func gameRow(icon: String, title: String, subtitle: String, tint: Color) -> some View {
        HStack(spacing: 13) {
            Image(systemName: icon)
                .font(.system(size: 21))
                .foregroundStyle(Palette.onAccent)
                .frame(width: 46, height: 46)
                .background(tint, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.display(18))
                Text(subtitle).font(.body(12)).foregroundStyle(Palette.ink.opacity(0.55))
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Palette.ink.opacity(0.3))
        }
        .padding(13)
        .frame(minHeight: DesignTokens.minTapTarget)
        .organicCard()
    }

    private func categoryCard(_ category: VocabularyCategory) -> some View {
        VStack(spacing: 0) {
            ZStack {
                Color(hex: category.colorHex).opacity(0.18)
                if let imageName = category.imageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .washed()
                        .padding(12)
                } else {
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Color(hex: category.colorHex))
                }
            }
            .frame(height: 96)
            .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color(hex: category.colorHex))
                        .frame(width: 9, height: 9)
                    Text(category.title)
                        .font(.display(16))
                        .foregroundStyle(Palette.ink)
                        .lineLimit(2)
                }
                Text("⭐ \(progressStore.starsByCategory[category.id, default: 0])")
                    .font(.body(11))
                    .foregroundStyle(Palette.ink.opacity(0.5))
                    .padding(.leading, 17)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
        }
        .organicCard()
    }
}
