import SwiftUI

/// Bảng "hết vòng" dùng chung cho các game mới (Nghe rồi chọn, Ô cửa bí mật,
/// Tìm bạn khác loài, Đếm cùng bé...) — theo design doc, các game này đều
/// dùng chung một màn hết vòng thay vì mỗi game tự vẽ lại.
struct RoundCompleteSheetView: View {
    let correctCount: Int
    let totalCount: Int
    let buddyEmoji: String
    let playAgain: () -> Void
    let goHome: () -> Void

    @Environment(\.theme) private var theme

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 0) {
                Text(buddyEmoji).font(.system(size: 56))
                Text("Giỏi lắm!")
                    .font(.display(34))
                    .padding(.top, 14)
                Text("Bé trả lời đúng \(correctCount) trong \(totalCount) câu.")
                    .font(.body(14.5))
                    .foregroundStyle(Palette.ink.opacity(0.6))
                    .padding(.top, 6)

                RewardStarsView(count: correctCount)
                    .padding(.top, 18)

                Button("Chơi vòng nữa", action: playAgain)
                    .buttonStyle(PillButtonStyle(theme: theme))
                    .padding(.top, 22)
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
}
