import SwiftUI

struct GamesHomeView: View {
    @Environment(\.theme) private var theme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(ProgressStore.self) private var progressStore
    @Environment(TabRouter.self) private var router
    @AppStorage("lastMatchingCategoryId") private var lastCategoryId = "animals"

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

    // MARK: - iPad (P2): thẻ "Chơi tiếp" + lưới 2×2 chia hết chiều cao
    //
    // LỖI ĐÃ SỬA: ScrollView + LazyVGrid + lề 16pt → nội dung dồn lên nửa trên,
    // ô game chỉ cao 170pt, lề hẹp hơn thiết kế (44pt).

    private var regularBody: some View {
        VStack(spacing: 0) {
            AppHeaderView(title: "Chơi").padding(.top, 18)
            Text("5 trò · mỗi ván 8 câu")
                .font(AppFont.bodyText(isRegularWidth))
                .foregroundStyle(Palette.ink.opacity(0.6))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, side)
                .padding(.top, 6)

            GeometryReader { proxy in
                // LỖI ĐÃ SỬA: chiều cao hàng cuối được đoán là 96pt nhưng thẻ
                // "Ghép chữ với hình" cao hơn thế (lề 20 + nội dung 58), nên
                // tổng vượt chiều cao thật → VStack ép khoảng cách về 0 và thẻ
                // "Lật Hình" dính vào hàng "Ô cửa bí mật / Tìm bạn khác loài".
                // Nay chia ngân sách theo đúng thứ tự: hàng cuối cố định navH,
                // ba khoảng cách, phần còn lại mới chia cho thẻ chơi tiếp + 2 hàng.
                let navH: CGFloat = 104
                let available = proxy.size.height - navH - gap * 3
                let continueH = min(max(available * 0.34, 200), 320)
                let rowH = max((available - continueH) / 2, 150)
                VStack(spacing: gap) {
                    continueCard.frame(height: continueH)

                    VStack(spacing: gap) {
                        HStack(spacing: gap) {
                            tile("magnifyingglass", "Ô cửa bí mật", "Nhìn ô cửa, đoán con vật", "game_secretdoor") { SecretDoorGameView() }
                            tile("sparkles", "Tìm bạn khác loài", "Chỉ ra đứa lạc đàn", "game_oddoneout") { OddOneOutGameView() }
                        }
                        .frame(height: rowH)
                        HStack(spacing: gap) {
                            tile("textformat.123", "Đếm cùng bé", "Đếm rồi chọn đúng số", "game_counting") { CountingGameView() }
                            tile("speaker.wave.3.fill", "Nghe rồi chọn", "Nghe từ, chỉ đúng ảnh", "game_listen") { ListenChooseGameView() }
                        }
                        .frame(height: rowH)
                    }

                    NavigationLink { MatchWordGameView() } label: {
                        gameRow(icon: "textformat.abc", title: "Ghép chữ với hình",
                                subtitle: "Kéo từ vào đúng ảnh", tint: theme.base)
                    }
                    .buttonStyle(.plain)
                    .frame(height: navH)
                }
            }
            .padding(.horizontal, side)
            .padding(.top, gap)
            .padding(.bottom, side)
        }
    }

    private func tile<Destination: View>(_ icon: String, _ title: String, _ subtitle: String,
                                         _ progressKey: String,
                                         @ViewBuilder destination: @escaping () -> Destination) -> some View {
        NavigationLink { destination() } label: {
            gameTile(icon: icon, title: title, subtitle: subtitle, questionCount: 8,
                     stars: progressStore.starsByCategory[progressKey, default: 0])
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - iPhone — danh sách 1 cột (giữ nguyên)

    private var compactBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.spacing) {
                AppHeaderView(title: "Chơi")

                sectionLabel("Chưa cần biết chữ")
                VStack(spacing: 10) {
                    NavigationLink { MatchingHomeView() } label: {
                        gameRow(icon: "square.stack.3d.up.fill", title: "Lật Hình", subtitle: "Tìm cặp thẻ giống nhau", tint: theme.base)
                    }.buttonStyle(.plain)
                    NavigationLink { ListenChooseGameView() } label: {
                        gameRow(icon: "speaker.wave.3.fill", title: "Nghe rồi chọn", subtitle: "Nghe từ, chỉ đúng ảnh", tint: theme.base)
                    }.buttonStyle(.plain)
                    NavigationLink { SecretDoorGameView() } label: {
                        gameRow(icon: "magnifyingglass", title: "Ô cửa bí mật", subtitle: "Nhìn ô cửa, đoán con vật", tint: theme.base)
                    }.buttonStyle(.plain)
                    NavigationLink { OddOneOutGameView() } label: {
                        gameRow(icon: "sparkles", title: "Tìm bạn khác loài", subtitle: "Chỉ ra đứa lạc đàn", tint: theme.base)
                    }.buttonStyle(.plain)
                    NavigationLink { CountingGameView() } label: {
                        gameRow(icon: "textformat.123", title: "Đếm cùng bé", subtitle: "Đếm rồi chọn đúng số", tint: theme.base)
                    }.buttonStyle(.plain)
                }
                .padding(.horizontal, side)

                sectionLabel("Khi bé biết mặt chữ")
                NavigationLink { MatchWordGameView() } label: {
                    gameRow(icon: "textformat.abc", title: "Ghép chữ với hình", subtitle: "Kéo từ vào đúng ảnh", tint: theme.base)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, side)
            }
            .padding(.bottom, DesignTokens.spacing)
        }
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
                        .font(AppFont.label(isRegularWidth))
                        .tracking(1.0)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Palette.surface, in: Capsule())
                        .foregroundStyle(Palette.ink)
                    Text("Lật Hình")
                        .font(AppFont.navTitle(isRegularWidth))
                        .foregroundStyle(Palette.ink)
                    Text("Tìm cặp thẻ giống nhau trong bộ \(lastCategory.title.lowercased()).")
                        .font(AppFont.bodyText(isRegularWidth))
                        .foregroundStyle(Palette.ink.opacity(0.6))
                }
                Spacer(minLength: 0)
                Grid(horizontalSpacing: 14, verticalSpacing: 14) {
                    GridRow {
                        peekTile(peekCards.indices.contains(0) ? peekCards[0] : nil, faceUp: true)
                        peekTile(peekCards.indices.contains(1) ? peekCards[1] : nil, faceUp: false)
                    }
                    GridRow {
                        peekTile(peekCards.indices.contains(2) ? peekCards[2] : nil, faceUp: false)
                        peekTile(peekCards.indices.contains(3) ? peekCards[3] : nil, faceUp: true)
                    }
                }
            }
            .padding(28)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(theme.tint, in: RoundedRectangle(cornerRadius: DesignTokens.radiusLg, style: .continuous))
            .shadow(color: Palette.ink.opacity(0.14), radius: 10, y: 5)
        }
        .buttonStyle(.plain)
    }

    private func peekTile(_ card: VocabularyCard?, faceUp: Bool) -> some View {
        ZStack {
            if faceUp {
                Palette.surface
                if let imageName = card?.imageName {
                    Image(imageName).resizable().scaledToFit().washed().padding(14)
                } else if let colorHex = card?.colorHex {
                    // Bộ "Màu sắc": ô màu tràn viền — trước đây rơi xuống nhánh
                    // emoji nên hiện chấm 🔴🟢 kiểu icon cũ.
                    Color(hex: colorHex)
                } else if let value = card?.value {
                    Text("\(value)").font(.display(40)).foregroundStyle(theme.deep)
                } else if let card {
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
                .font(.system(size: 26))
                .foregroundStyle(Palette.sageDeep)
                .frame(width: 60, height: 60)
                .background(Palette.sageTint, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            Text(title).font(AppFont.tileTitle(isRegularWidth))
            Text(subtitle).font(AppFont.caption(isRegularWidth)).foregroundStyle(Palette.ink.opacity(0.55))
            Spacer(minLength: 0)
            Text("\(questionCount) câu · ⭐ \(stars)")
                .font(AppFont.badge(isRegularWidth))
                .foregroundStyle(theme.base)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .organicCard()
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(AppFont.label(isRegularWidth))
            .tracking(1.2)
            .foregroundStyle(Palette.ink.opacity(0.5))
            .padding(.horizontal, side)
    }

    private func gameRow(icon: String, title: String, subtitle: String, tint: Color) -> some View {
        HStack(spacing: isRegularWidth ? 18 : 13) {
            Image(systemName: icon)
                .font(.system(size: isRegularWidth ? 26 : 21))
                .foregroundStyle(Palette.onAccent)
                .frame(width: isRegularWidth ? 58 : 46, height: isRegularWidth ? 58 : 46)
                .background(tint, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(AppFont.tileTitle(isRegularWidth))
                Text(subtitle).font(AppFont.caption(isRegularWidth)).foregroundStyle(Palette.ink.opacity(0.55))
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Palette.ink.opacity(0.3))
        }
        .padding(isRegularWidth ? 20 : 13)
        .frame(minHeight: isRegularWidth ? 96 : DesignTokens.minTapTarget)
        .organicCard()
    }
}
