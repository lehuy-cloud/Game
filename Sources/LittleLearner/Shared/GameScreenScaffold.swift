import SwiftUI

/// Khung dùng chung cho các mini-game hỏi-đáp (Ô cửa bí mật, Đếm cùng bé,
/// Nghe rồi chọn, Tìm bạn khác loài): header (back + tiêu đề + tiến độ) rồi
/// vùng câu hỏi (giãn hết chỗ trống) + hàng đáp án + gợi ý. iPhone/iPad dùng
/// chung, chỉ khác cỡ chữ/khoảng cách qua `horizontalSizeClass` — tránh lặp
/// lại 3 lỗi hay gặp trên iPad: nội dung kẹt cột hẹp, nửa dưới màn trống, ô
/// đáp án không giãn theo bề rộng thật.
struct GameScreen<Question: View, Answers: View>: View {
    let title: String
    let index: Int
    let total: Int
    let correct: Int
    var hint: String? = nil
    @ViewBuilder var question: () -> Question
    @ViewBuilder var answers: () -> Answers

    @Environment(\.theme) private var theme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dismiss) private var dismiss

    private var isRegularWidth: Bool { horizontalSizeClass == .regular }
    private var sidePadding: CGFloat { isRegularWidth ? 44 : 18 }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, sidePadding)
                .padding(.top, isRegularWidth ? 22 : 8)

            VStack(spacing: isRegularWidth ? 26 : 18) {
                question()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                answers()
                    .frame(maxWidth: .infinity)

                if let hint {
                    Label(hint, systemImage: "lightbulb.fill")
                        .font(.body(isRegularWidth ? 17 : 14, weight: .semibold))
                        .padding(.horizontal, 20)
                        .padding(.vertical, isRegularWidth ? 14 : 10)
                        .background(Capsule().fill(Palette.surfaceAlt))
                }
            }
            .padding(.horizontal, sidePadding)
            .padding(.top, isRegularWidth ? 26 : 18)
            .padding(.bottom, isRegularWidth ? 40 : 26)
        }
        // KHÔNG .frame(width:) cố định ở đây — đó là nguồn gốc lỗi cột hẹp
        // giữa màn trên iPad.
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .organicBackground()
        .navigationBarBackButtonHidden()
        .enableSwipeBack()
    }

    private var header: some View {
        HStack(spacing: isRegularWidth ? 18 : 10) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: isRegularWidth ? 20 : 17, weight: .bold))
                    .frame(width: isRegularWidth ? 56 : 44, height: isRegularWidth ? 56 : 44)
                    .background(Circle().fill(Palette.surface))
                    .foregroundStyle(Palette.ink)
            }
            VStack(alignment: .leading, spacing: isRegularWidth ? 4 : 1) {
                Text(title).font(.display(isRegularWidth ? 34 : 17))
                Text("Câu \(index) / \(total) · \(correct) đúng")
                    .font(.body(isRegularWidth ? 16 : 11.5))
                    .foregroundStyle(Palette.ink.opacity(0.5))
            }
            Spacer(minLength: 0)
            if isRegularWidth {
                progressBar.frame(width: 220)
            }
        }
        .overlay(alignment: .bottom) {
            if !isRegularWidth {
                progressBar.offset(y: 18)
            }
        }
    }

    private var progressBar: some View {
        GeometryReader { proxy in
            let ratio = total == 0 ? 0 : CGFloat(index) / CGFloat(total)
            HStack(spacing: 6) {
                Capsule().fill(theme.base).frame(width: proxy.size.width * ratio)
                Capsule().fill(Palette.ink.opacity(0.12))
            }
        }
        .frame(height: isRegularWidth ? 9 : 7)
    }
}
