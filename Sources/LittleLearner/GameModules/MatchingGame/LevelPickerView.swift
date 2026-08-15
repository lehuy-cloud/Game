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
    @AppStorage("speakOnFlip") private var speakOnFlip = true
    @State private var selected: GameLevel = GameLevel.all[1]

    private var category: VocabularyCategory? {
        VocabularyContent.categories.first { $0.id == categoryId }
    }

    var body: some View {
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
        .navigationTitle(category?.title ?? "Bộ thẻ")
        .organicBackground()
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
}
