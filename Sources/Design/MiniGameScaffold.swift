import SwiftUI

/// Khung dùng chung cho 4 mini-game của truyện.
///
/// BA LỖI GỐC ĐÃ SỬA (cả 4 game đều mắc):
///
/// 1. `.organicBackground()` đặt TRƯỚC `.gameContentWidth()` → nền chỉ vẽ trong
///    cột 420pt, hai bên màn iPad trắng bốc. Nền phải là modifier NGOÀI CÙNG.
/// 2. `.gameContentWidth()` bọc CẢ MÀN → toàn bộ game bị nhốt trong cột hẹp
///    giữa iPad. Nó chỉ nên giới hạn vùng chơi, không giới hạn nền và header.
/// 3. Header khoá cứng cỡ iPhone (nút 44, tiêu đề 17pt) → bé xíu trên iPad.
struct MiniGameShell<Content: View>: View {
    let title: String
    var counter: String? = nil
    var prompt: String
    var onBack: () -> Void
    /// true với game có toạ độ tự do (chạm mục tiêu bay) — vùng chơi lấy hết
    /// bề ngang; false với game ô/nút — vùng chơi giới hạn 560pt cho dễ nhìn.
    var freeform = false
    @ViewBuilder var content: () -> Content

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isRegularWidth: Bool { horizontalSizeClass == .regular }
    private var side: CGFloat { Layout.side(isRegularWidth) }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, side)
                .padding(.top, isRegularWidth ? 18 : 8)

            Text(prompt)
                .font(.body(isRegularWidth ? 24 : 17, weight: .semibold))
                .foregroundStyle(Palette.ink)
                .multilineTextAlignment(.center)
                .frame(maxWidth: isRegularWidth ? 700 : .infinity)
                .padding(.horizontal, side)
                .padding(.top, isRegularWidth ? 26 : 16)

            content()
                .frame(maxWidth: freeform ? .infinity : (isRegularWidth ? 560 : .infinity),
                       maxHeight: .infinity)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, freeform ? 0 : side)
                .padding(.vertical, isRegularWidth ? 30 : 18)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .organicBackground()                 // ngoài cùng — phủ hết bề ngang
        .navigationBarBackButtonHidden()
        .enableSwipeBack()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        HStack(spacing: isRegularWidth ? 18 : 12) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: isRegularWidth ? 22 : 17, weight: .bold))
                    .frame(width: isRegularWidth ? 56 : 44, height: isRegularWidth ? 56 : 44)
                    .background(Circle().fill(Palette.surface))
                    .foregroundStyle(Palette.ink)
            }
            Text(title)
                .font(.display(isRegularWidth ? 34 : 17))
                .foregroundStyle(Palette.ink)
                .lineLimit(1)
            Spacer(minLength: 0)
            if let counter {
                Text(counter)
                    .font(.body(isRegularWidth ? 16 : 12, weight: .bold))
                    .padding(.horizontal, isRegularWidth ? 18 : 12)
                    .padding(.vertical, isRegularWidth ? 10 : 6)
                    .background(Palette.surface, in: Capsule())
                    .foregroundStyle(Palette.ink.opacity(0.7))
            }
        }
    }
}
