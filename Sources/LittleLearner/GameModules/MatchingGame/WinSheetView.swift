import SwiftUI

/// Bảng hiện ra khi bé ghép hết các cặp — thay cho `winOverlay` cũ.
struct WinSheetView: View {
    let level: GameLevel
    let moves: Int
    let firstTryPairs: Int
    let buddyEmoji: String
    let categoryWord: String
    let playAgain: () -> Void
    let goHome: () -> Void

    @Environment(\.theme) private var theme

    private var accuracy: Int {
        let attempts = max(1, Int(ceil(Double(moves) / 2)))
        return Int((Double(firstTryPairs) / Double(attempts) * 100).rounded())
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 0) {
                Text(buddyEmoji).font(.system(size: 56))
                Text("Giỏi lắm!")
                    .font(.display(34))
                    .padding(.top, 14)
                Text("Bé đã tìm hết \(level.pairs) cặp \(categoryWord).")
                    .font(.body(14.5))
                    .foregroundStyle(Palette.ink.opacity(0.6))
                    .padding(.top, 6)

                RewardStarsView(count: level.pairs)
                    .padding(.top, 18)

                HStack(spacing: 0) {
                    stat("\(moves)", "lượt lật")
                    Rectangle().fill(Palette.ink.opacity(0.14)).frame(width: 1, height: 34)
                    stat("\(accuracy)%", "đúng ngay lần đầu")
                }
                .padding(.vertical, 14)
                .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(theme.tint))
                .padding(.top, 20)

                Button("Chơi ván nữa", action: playAgain)
                    .buttonStyle(PillButtonStyle(theme: theme))
                    .padding(.top, 16)
                Button("Về nhà", action: goHome)
                    .buttonStyle(PillButtonStyle(theme: theme, filled: false))
                    .padding(.top, 10)
            }
            .padding(24)
            .padding(.top, 6)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 34, style: .continuous).fill(Palette.surface)
            )
            .padding(18)
        }
        .background(Palette.ink.opacity(0.42).ignoresSafeArea())
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.display(24)).foregroundStyle(theme.deep)
            Text(label).font(.body(11.5)).foregroundStyle(Palette.ink.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
    }
}
