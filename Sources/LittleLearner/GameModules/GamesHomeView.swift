import SwiftUI

struct GamesHomeView: View {
    @Environment(\.theme) private var theme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(ProgressStore.self) private var progressStore
    @AppStorage("lastMatchingCategoryId") private var lastCategoryId = "animals"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.spacing) {
                AppHeaderView(title: "Chơi")

                if horizontalSizeClass == .regular {
                    regularContent
                } else {
                    compactContent
                }
            }
            .padding(.bottom, DesignTokens.spacing)
        }
        .organicBackground()
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - iPhone — danh sách 1 cột

    @ViewBuilder
    private var compactContent: some View {
        sectionLabel("Chưa cần biết chữ")
        VStack(spacing: 10) {
            NavigationLink {
                MatchingHomeView()
            } label: {
                gameRow(icon: "square.stack.3d.up.fill", title: "Lật Hình",
                        subtitle: "Tìm cặp thẻ giống nhau", tint: theme.base)
            }
            .buttonStyle(.plain)

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
    }

    // MARK: - iPad — thẻ "Chơi tiếp" + lưới 2×2 (P2)

    @ViewBuilder
    private var regularContent: some View {
        Text("5 trò · mỗi ván 8 câu")
            .font(.body(15))
            .foregroundStyle(Palette.ink.opacity(0.6))
            .padding(.horizontal, DesignTokens.spacing)

        continueCard
            .padding(.horizontal, DesignTokens.spacing)

        LazyVGrid(columns: [GridItem(.flexible(), spacing: DesignTokens.spacing), GridItem(.flexible(), spacing: DesignTokens.spacing)],
                  spacing: DesignTokens.spacing) {
            NavigationLink {
                SecretDoorGameView()
            } label: {
                gameTile(icon: "magnifyingglass", title: "Ô cửa bí mật", subtitle: "Nhìn ô cửa, đoán con vật",
                         questionCount: 8, stars: progressStore.starsByCategory["game_secretdoor", default: 0])
            }
            .buttonStyle(.plain)

            NavigationLink {
                OddOneOutGameView()
            } label: {
                gameTile(icon: "sparkles", title: "Tìm bạn khác loài", subtitle: "Chỉ ra đứa lạc đàn",
                         questionCount: 8, stars: progressStore.starsByCategory["game_oddoneout", default: 0])
            }
            .buttonStyle(.plain)

            NavigationLink {
                CountingGameView()
            } label: {
                gameTile(icon: "textformat.123", title: "Đếm cùng bé", subtitle: "Đếm rồi chọn đúng số",
                         questionCount: 8, stars: progressStore.starsByCategory["game_counting", default: 0])
            }
            .buttonStyle(.plain)

            NavigationLink {
                ListenChooseGameView()
            } label: {
                gameTile(icon: "speaker.wave.3.fill", title: "Nghe rồi chọn", subtitle: "Nghe từ, chỉ đúng ảnh",
                         questionCount: 8, stars: progressStore.starsByCategory["game_listen", default: 0])
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
    }

    private var lastCategory: VocabularyCategory {
        VocabularyContent.categories.first { $0.id == lastCategoryId } ?? VocabularyContent.categories[0]
    }

    private var peekCards: [VocabularyCard] {
        Array(VocabularyContent.cards(for: lastCategoryId).prefix(4))
    }

    private var continueCard: some View {
        NavigationLink {
            MatchingHomeView()
        } label: {
            HStack(spacing: 28) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("CHƠI TIẾP")
                        .font(.body(13, weight: .bold))
                        .tracking(1.0)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Palette.surface, in: Capsule())
                        .foregroundStyle(Palette.ink)
                    Text("Lật Hình")
                        .font(.display(32))
                        .foregroundStyle(Palette.ink)
                    Text("Tìm cặp thẻ giống nhau trong bộ \(lastCategory.title.lowercased()).")
                        .font(.body(15))
                        .foregroundStyle(Palette.ink.opacity(0.6))
                }
                Spacer(minLength: 0)
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(104), spacing: 14), count: 2), spacing: 14) {
                    ForEach(Array(peekCards.enumerated()), id: \.element.id) { index, card in
                        peekTile(card, faceUp: index == 0 || index == 3)
                    }
                }
            }
            .padding(28)
            .frame(maxWidth: .infinity, minHeight: 240, alignment: .leading)
            .background(theme.tint, in: RoundedRectangle(cornerRadius: DesignTokens.radiusLg, style: .continuous))
            .shadow(color: Palette.ink.opacity(0.14), radius: 10, y: 5)
        }
        .buttonStyle(.plain)
    }

    /// Ô thẻ xem trước trong thẻ "Chơi tiếp" — xen kẽ 2 thẻ lật ngửa (có ảnh)
    /// và 2 thẻ úp (chỉ màu nền) để gợi nhớ trò lật hình, giống mockup P2.
    private func peekTile(_ card: VocabularyCard, faceUp: Bool) -> some View {
        ZStack {
            if faceUp {
                Palette.surface
                if let imageName = card.imageName {
                    Image(imageName).resizable().scaledToFit().washed().padding(14)
                } else {
                    Text(card.emoji).font(.system(size: 34))
                }
            } else {
                theme.base
            }
        }
        .frame(width: 104, height: 104)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: Palette.ink.opacity(0.08), radius: 4, y: 2)
    }

    private func gameTile(icon: String, title: String, subtitle: String, questionCount: Int, stars: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(Palette.sageDeep)
                .frame(width: 54, height: 54)
                .background(Palette.sageTint, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            Text(title).font(.display(22))
            Text(subtitle).font(.body(13.5)).foregroundStyle(Palette.ink.opacity(0.55))
            Spacer(minLength: 0)
            Text("\(questionCount) câu · ⭐ \(stars)")
                .font(.body(14, weight: .bold))
                .foregroundStyle(theme.base)
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 170, alignment: .leading)
        .organicCard()
    }

    // MARK: - Chung

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
}
