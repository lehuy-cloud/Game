import SwiftUI
import AVFoundation

/// Thẻ từ chủ đề "Số đếm" — thay cho ảnh số nhỏ trong bản cũ.
/// Số vẽ bằng chữ Baloo 2 nên to bao nhiêu cũng nét, kèm N chấm để bé đối chiếu số lượng.
/// Bản 9a: 1–5 chấm một hàng. Bản 9c: 6–10 dùng khung mười ô (2×5).
struct NumberCardView: View {
    let value: Int              // 1...10
    let english: String         // "One"
    let vietnamese: String      // "Một"
    let index: Int              // vị trí thẻ, 1-based
    let total: Int
    var onSpeak: () -> Void = {}
    var onPrev: () -> Void = {}
    var onNext: () -> Void = {}

    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // LỖI ĐÃ SỬA: màn này khoá cứng cỡ iPhone (tiêu đề 20, chữ 38/19, nút 44/60)
    // và còn dùng SF Symbol `speaker.wave.2.fill` thay vì glyph 🔊 dùng chung.
    private var isRegularWidth: Bool { horizontalSizeClass == .regular }
    private var usesTenFrame: Bool { value > 5 }

    var body: some View {
        VStack(spacing: 0) {
            header
            progress.padding(.vertical, isRegularWidth ? 20 : 14)
            hero
            wordCard.padding(.top, isRegularWidth ? 22 : 14)
            Spacer(minLength: 18)
            navRow
        }
        .padding(.horizontal, Layout.side(isRegularWidth))
        .padding(.bottom, isRegularWidth ? 44 : 30)
        .organicBackground()
        .navigationBarBackButtonHidden()
        .gesture(
            DragGesture(minimumDistance: 40).onEnded { g in
                if g.translation.width < 0 { onNext() } else { onPrev() }
            }
        )
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: isRegularWidth ? 18 : 12) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: Layout.backGlyph(isRegularWidth), weight: .semibold))
                    .frame(width: Layout.backCircle(isRegularWidth), height: Layout.backCircle(isRegularWidth))
                    .background(Circle().fill(Palette.surface))
                    .foregroundStyle(Palette.ink)
            }
            Text("Số đếm").font(AppFont.navTitle(isRegularWidth))
            Spacer()
            Text("\(index) / \(total)")
                .font(AppFont.badge(isRegularWidth))
                .padding(.horizontal, isRegularWidth ? 18 : 13)
                .padding(.vertical, isRegularWidth ? 10 : 7)
                .background(Capsule().fill(Palette.surfaceAlt))
        }
    }

    private var progress: some View {
        GeometryReader { geo in
            let done = CGFloat(index) / CGFloat(total)
            HStack(spacing: 5) {
                Capsule().fill(theme.base)
                    .frame(width: max(7, geo.size.width * done - 2.5))
                Capsule().fill(Palette.ink.opacity(0.12))
            }
        }
        .frame(height: Layout.progressThickness(isRegularWidth))
    }

    // MARK: Hero — số lớn + số lượng

    private var hero: some View {
        VStack(spacing: usesTenFrame ? 14 : 6) {
            Text("\(value)")
                .font(.display(isRegularWidth ? (usesTenFrame ? 210 : 280) : (usesTenFrame ? 150 : 210)))
                .foregroundStyle(theme.deep)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            if usesTenFrame { tenFrame } else { dotRow }
        }
        .frame(maxWidth: .infinity)
        .frame(height: isRegularWidth ? 420 : 290)
        .background(RoundedRectangle(cornerRadius: DesignTokens.radiusLg, style: .continuous).fill(theme.tint))
        .shadow(color: Palette.ink.opacity(0.10), radius: 14, y: 6)
    }

    private var dotRow: some View {
        HStack(spacing: 10) {
            ForEach(0..<value, id: \.self) { _ in
                Circle().fill(theme.deep)
                    .frame(width: isRegularWidth ? 32 : 22, height: isRegularWidth ? 32 : 22)
            }
        }
        .padding(.top, 6)
    }

    private var tenFrame: some View {
        VStack(spacing: 8) {
            ForEach(0..<2, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(0..<5, id: \.self) { col in
                        let n = row * 5 + col
                        Circle()
                            .fill(n < value ? theme.deep : Color.white.opacity(0.62))
                            .frame(width: isRegularWidth ? 38 : 26, height: isRegularWidth ? 38 : 26)
                    }
                }
            }
        }
    }

    // MARK: Chữ

    private var wordCard: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 2) {
                Text(english).font(.display(isRegularWidth ? 52 : 38))
                Text(vietnamese)
                    .font(AppFont.reading(isRegularWidth))
                    .foregroundStyle(Palette.ink.opacity(0.62))
            }
            Spacer(minLength: 0)
            Button(action: onSpeak) {
                SpeakGlyph(size: isRegularWidth ? 34 : 26)
                    .frame(width: isRegularWidth ? 76 : 56, height: isRegularWidth ? 76 : 56)
                    .background {
                        Circle().fill(theme.tint)
                        Circle().strokeBorder(theme.base.opacity(0.5), lineWidth: 2.5)
                    }
            }
        }
        .padding(.horizontal, isRegularWidth ? 30 : 20).padding(.vertical, isRegularWidth ? 26 : 18)
        .background(RoundedRectangle(cornerRadius: DesignTokens.radiusLg, style: .continuous).fill(Palette.surface))
        .shadow(color: Palette.ink.opacity(0.07), radius: 8, y: 3)
    }

    // MARK: Điều hướng

    private var navRow: some View {
        HStack(spacing: isRegularWidth ? 18 : 12) {
            Button(action: onPrev) {
                Image(systemName: "chevron.left")
                    .font(.system(size: isRegularWidth ? 26 : 22, weight: .semibold))
                    .frame(width: Layout.navCircle(isRegularWidth), height: Layout.navCircle(isRegularWidth))
                    .background(Circle().fill(Palette.surface))
                    .foregroundStyle(Palette.ink.opacity(index > 1 ? 1 : 0.35))
            }
            .disabled(index <= 1)
            Text("vuốt để đổi thẻ")
                .font(AppFont.caption(isRegularWidth)).foregroundStyle(Palette.ink.opacity(0.45))
                .frame(maxWidth: .infinity)
            Button(action: onNext) {
                Image(systemName: "chevron.right")
                    .font(.system(size: isRegularWidth ? 26 : 22, weight: .semibold))
                    .frame(width: Layout.navCircle(isRegularWidth), height: Layout.navCircle(isRegularWidth))
                    .background(Circle().fill(theme.deep))
                    .foregroundStyle(Palette.onAccent)
            }
        }
    }
}

// MARK: - Dữ liệu chủ đề số đếm

struct NumberCard: Identifiable, Hashable {
    let id: Int
    let english: String
    let vietnamese: String

    static let all: [NumberCard] = [
        .init(id: 1, english: "One", vietnamese: "Một"),
        .init(id: 2, english: "Two", vietnamese: "Hai"),
        .init(id: 3, english: "Three", vietnamese: "Ba"),
        .init(id: 4, english: "Four", vietnamese: "Bốn"),
        .init(id: 5, english: "Five", vietnamese: "Năm"),
        .init(id: 6, english: "Six", vietnamese: "Sáu"),
        .init(id: 7, english: "Seven", vietnamese: "Bảy"),
        .init(id: 8, english: "Eight", vietnamese: "Tám"),
        .init(id: 9, english: "Nine", vietnamese: "Chín"),
        .init(id: 10, english: "Ten", vietnamese: "Mười")
    ]
}

/// Bọc cả bộ 10 thẻ, giữ vị trí hiện tại.
struct NumberDeckView: View {
    @State private var i = 0
    private let cards = NumberCard.all
    private let speech = AVSpeechSynthesizer()

    var body: some View {
        let c = cards[i]
        NumberCardView(
            value: c.id, english: c.english, vietnamese: c.vietnamese,
            index: i + 1, total: cards.count,
            onSpeak: { speak(c.english) },
            onPrev: { withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { i = max(0, i - 1) } },
            onNext: { withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { i = min(cards.count - 1, i + 1) } }
        )
        .id(c.id)
        .transition(.opacity)
        .onAppear { speak(c.english) }
    }

    private func speak(_ text: String) {
        let u = AVSpeechUtterance(string: text)
        u.voice = AVSpeechSynthesisVoice(language: "en-US")
        u.rate = 0.38
        speech.speak(u)
    }
}

#Preview { NumberDeckView().environment(\.theme, .pink) }
