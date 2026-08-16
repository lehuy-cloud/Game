import SwiftUI

/// Chọn độ khó trước khi vào ván — thay cho việc hard-code `pairCount = 4`
/// trong `MatchingGameView`.
struct GameLevel: Identifiable, Hashable {
    let id: String
    let name: String
    let desc: String
    let pairs: Int
    let columns: Int

    static let all: [GameLevel] = [
        GameLevel(id: "easy",   name: "Dễ",  desc: "3 cặp · lưới 3 × 2", pairs: 3, columns: 3),
        GameLevel(id: "medium", name: "Vừa", desc: "6 cặp · lưới 3 × 4", pairs: 6, columns: 3),
        GameLevel(id: "hard",   name: "Khó", desc: "8 cặp · lưới 4 × 4", pairs: 8, columns: 4),
    ]
}

struct LevelPickerView: View {
    let categoryId: String

    @Environment(\.theme) private var theme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dismiss) private var dismiss
    @AppStorage("speakOnFlip") private var speakOnFlip = true
    @AppStorage("hintsEnabled") private var hintsEnabled = false
    @AppStorage("lastMatchingCategoryId") private var lastCategoryId = "animals"
    @State private var selected: GameLevel = GameLevel.all[1]

    private var isRegularWidth: Bool { horizontalSizeClass == .regular }

    private var category: VocabularyCategory? {
        VocabularyContent.categories.first { $0.id == categoryId }
    }

    var body: some View {
        Group {
            if isRegularWidth {
                regularContent
            } else {
                compactContent
            }
        }
        .organicBackground()
        .onAppear { lastCategoryId = categoryId }
    }

    // MARK: - iPhone — giữ nguyên bố cục gốc

    private var compactContent: some View {
        VStack(alignment: .leading, spacing: DesignTokens.spacing) {
            Text("Chọn độ khó")
                .font(.display(36))
                .foregroundStyle(Palette.ink)
            Text("Bé nhỏ thì bắt đầu từ Dễ nhé.")
                .font(.body(14))
                .foregroundStyle(Palette.ink.opacity(0.58))

            ForEach(GameLevel.all) { level in
                Button { selected = level } label: { row(for: level) }
                    .buttonStyle(.plain)
            }

            Spacer(minLength: 0)

            Toggle(isOn: $speakOnFlip) {
                Text("Đọc từ tiếng Anh khi lật").font(.body(14, weight: .semibold))
            }
            .tint(Palette.sage)
            .padding(.horizontal, 18)
            .frame(minHeight: 56)
            .background(Capsule().fill(Palette.surface))

            NavigationLink {
                MatchingGameView(categoryId: categoryId, level: selected)
            } label: {
                Text("Bắt đầu")
            }
            .buttonStyle(PillButtonStyle(theme: theme))
        }
        .padding(22)
        .gameContentWidth()
        .navigationTitle(category?.title ?? "Bộ thẻ")
        .toolbar(.visible, for: .navigationBar)
    }

    private func row(for level: GameLevel) -> some View {
        let on = level.id == selected.id
        return HStack(spacing: 14) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: level.columns), spacing: 3) {
                ForEach(0..<(level.pairs * 2), id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(on ? theme.base : Color(hex: "#C0B6A5"))
                        .aspectRatio(1, contentMode: .fit)
                }
            }
            .frame(width: 44)

            VStack(alignment: .leading, spacing: 3) {
                Text(level.name).font(.display(23))
                Text(level.desc).font(.body(13)).foregroundStyle(Palette.ink.opacity(0.58))
            }
            Spacer()

            Image(systemName: "checkmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Palette.onAccent)
                .frame(width: 26, height: 26)
                .background(Circle().fill(theme.base))
                .opacity(on ? 1 : 0)
        }
        .padding(16)
        .frame(minHeight: DesignTokens.minTapTarget)
        .background {
            RoundedRectangle(cornerRadius: DesignTokens.radiusLg, style: .continuous)
                .fill(on ? theme.tint : Palette.surface)
            if on {
                RoundedRectangle(cornerRadius: DesignTokens.radiusLg, style: .continuous)
                    .strokeBorder(theme.base, lineWidth: 2.5)
            }
        }
        .animation(.easeOut(duration: 0.18), value: on)
    }

    // MARK: - iPad — P11: tab lớn, 3 thẻ ngang

    private var regularContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left").font(.system(size: 17, weight: .bold))
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Palette.surface))
                        .foregroundStyle(Palette.ink)
                }

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Circle().fill(Color(hex: category?.colorHex ?? "#C77D99")).frame(width: 7, height: 7)
                        Text("\(category?.title ?? "Bộ thẻ") · Lật Hình")
                            .font(.body(13, weight: .bold))
                            .foregroundStyle(Palette.ink.opacity(0.55))
                    }
                    Text("Chọn độ khó")
                        .font(.display(40))
                        .foregroundStyle(Palette.ink)
                    Text("Bé nhỏ thì bắt đầu từ Dễ nhé.")
                        .font(.body(16))
                        .foregroundStyle(Palette.ink.opacity(0.58))
                }

                HStack(spacing: 18) {
                    ForEach(GameLevel.all) { level in
                        Button { selected = level } label: { levelCard(for: level) }
                            .buttonStyle(.plain)
                    }
                }

                HStack(spacing: 18) {
                    optionCard(icon: "speaker.wave.2.fill", title: "Đọc từ tiếng Anh khi lật",
                               subtitle: "Giọng đọc chậm, rõ", isOn: $speakOnFlip)
                    optionCard(icon: "lightbulb.fill", title: "Cho dùng gợi ý",
                               subtitle: "Mỗi ván 3 lần", isOn: $hintsEnabled)
                }

                HStack(alignment: .center, spacing: 16) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Ván này \(selected.desc).")
                        Text("Xong ván được thêm ⭐.")
                    }
                    .font(.body(14))
                    .foregroundStyle(Palette.ink.opacity(0.6))
                    Spacer(minLength: 0)
                    startButton
                }
                .padding(.top, 6)
            }
            .padding(40)
        }
        .frame(maxWidth: 900)
        .frame(maxWidth: .infinity)
        .navigationBarBackButtonHidden()
        .enableSwipeBack()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var startButton: some View {
        NavigationLink {
            MatchingGameView(categoryId: categoryId, level: selected)
        } label: {
            HStack(spacing: 8) {
                Text("Bắt đầu")
                Image(systemName: "chevron.right").font(.system(size: 14, weight: .bold))
            }
            .font(.display(19))
            .foregroundStyle(Palette.onAccent)
            .padding(.horizontal, 30)
            .frame(height: 58)
            .background(theme.base, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private func levelCard(for level: GameLevel) -> some View {
        let on = level.id == selected.id
        return VStack(spacing: 14) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: level.columns), spacing: 3) {
                ForEach(0..<(level.pairs * 2), id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(on ? theme.base : Color(hex: "#C0B6A5"))
                        .aspectRatio(1, contentMode: .fit)
                }
            }
            .frame(width: 64)

            VStack(spacing: 4) {
                Text(level.name).font(.display(24))
                Text(level.desc).font(.body(13.5)).foregroundStyle(Palette.ink.opacity(0.55))
            }

            ZStack {
                if on {
                    Circle().fill(theme.base)
                    Image(systemName: "checkmark").font(.system(size: 13, weight: .bold)).foregroundStyle(Palette.onAccent)
                } else {
                    Circle().strokeBorder(Palette.ink.opacity(0.18), lineWidth: 2)
                }
            }
            .frame(width: 28, height: 28)
        }
        .padding(.vertical, 22)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: DesignTokens.radiusLg, style: .continuous)
                .fill(on ? theme.tint : Palette.surface)
            if on {
                RoundedRectangle(cornerRadius: DesignTokens.radiusLg, style: .continuous)
                    .strokeBorder(theme.base, lineWidth: 2.5)
            }
        }
        .animation(.easeOut(duration: 0.18), value: on)
    }

    private func optionCard(icon: String, title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 17))
                    .foregroundStyle(Palette.sageDeep)
                    .frame(width: 40, height: 40)
                    .background(Palette.sageTint, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                Text(title)
                    .font(.body(15, weight: .bold))
                    .foregroundStyle(Palette.ink)
                Spacer(minLength: 8)
                Toggle("", isOn: isOn).labelsHidden().tint(Palette.sage)
            }
            Text(subtitle)
                .font(.body(12.5))
                .foregroundStyle(Palette.ink.opacity(0.5))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.surface, in: RoundedRectangle(cornerRadius: DesignTokens.radiusLg))
    }
}
