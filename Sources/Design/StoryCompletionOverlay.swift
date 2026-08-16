import SwiftUI

/// LỖI ĐÃ SỬA: thẻ chúc mừng nổi trần trên nền game, không có lớp làm mờ phía
/// sau nên trông như một khối trắng lạc giữa màn; trên iPad chữ vẫn cỡ iPhone.
struct StoryCompletionOverlay: View {
    let outroText: String
    let onContinue: () -> Void

    @Environment(\.theme) private var theme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isRegularWidth: Bool { horizontalSizeClass == .regular }

    var body: some View {
        ZStack {
            Palette.ink.opacity(0.35)
                .ignoresSafeArea()

            VStack(spacing: isRegularWidth ? 22 : 16) {
                Text("🎉").font(.system(size: isRegularWidth ? 84 : 60))
                Text(outroText)
                    .font(.display(isRegularWidth ? 30 : 20))
                    .foregroundStyle(Palette.ink)
                    .multilineTextAlignment(.center)
                    .lineSpacing(isRegularWidth ? 8 : 4)
                RewardStarsView(count: 1)
                Button("Về danh sách chương", action: onContinue)
                    .buttonStyle(PillButtonStyle(theme: theme))
            }
            .padding(isRegularWidth ? 46 : 32)
            .frame(maxWidth: isRegularWidth ? 620 : .infinity)
            .organicCard()
            .padding(isRegularWidth ? 44 : 16)
            .transition(.scale(scale: 0.92).combined(with: .opacity))
        }
    }
}
