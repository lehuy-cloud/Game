import SwiftUI

// MARK: - Palette (Organic design system)

enum Palette {
    static let bg        = Color(hex: "#F5EAD8")
    static let surface   = Color(hex: "#F9F4ED")
    static let surfaceAlt = Color(hex: "#EEE7DB")
    static let ink       = Color(hex: "#201E1D")
    static let sage      = Color(hex: "#7A8A5E")
    static let sageTint  = Color(hex: "#E1EECC")
    static let sageDeep  = Color(hex: "#56633F")
    static let onAccent  = Color(hex: "#FFF5EC")
}

struct Theme: Identifiable, Hashable {
    let id: String
    let name: String
    let base: Color
    let dark: Color
    let tint: Color
    let deep: Color

    static let terracotta = Theme(id: "terracotta", name: "Cam đất",
        base: Color(hex: "#C67139"), dark: Color(hex: "#B2622D"),
        tint: Color(hex: "#FFE1D0"), deep: Color(hex: "#8C491A"))
    static let pink = Theme(id: "pink", name: "Hồng",
        base: Color(hex: "#D4568A"), dark: Color(hex: "#BD3F73"),
        tint: Color(hex: "#FFE0EC"), deep: Color(hex: "#8E2B53"))
    static let blue = Theme(id: "blue", name: "Xanh",
        base: Color(hex: "#3F7FBF"), dark: Color(hex: "#2F6BA7"),
        tint: Color(hex: "#DBE9F7"), deep: Color(hex: "#234F7D"))

    static let all: [Theme] = [.terracotta, .pink, .blue]
    static func named(_ id: String) -> Theme { all.first { $0.id == id } ?? .terracotta }
}

// Đọc theme hiện tại ở bất kỳ view nào: @Environment(\.theme) private var theme
private struct ThemeKey: EnvironmentKey { static let defaultValue: Theme = .terracotta }
extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

// MARK: - Type

extension Font {
    /// Baloo 2 — giọng tiêu đề, tròn và đủ dấu tiếng Việt.
    static func display(_ size: CGFloat) -> Font { .custom("Baloo2-ExtraBold", size: size) }
    /// Be Vietnam Pro — chữ thường, bảng dấu tiếng Việt đầy đủ.
    static func body(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let name: String
        switch weight {
        case .bold: name = "BeVietnamPro-Bold"
        case .semibold: name = "BeVietnamPro-SemiBold"
        default: name = "BeVietnamPro-Regular"
        }
        return .custom(name, size: size)
    }
}

// MARK: - Tokens bổ sung

extension DesignTokens {
    static let radiusLg: CGFloat = 28
    static let radiusTile: CGFloat = 20
}

// MARK: - Nền ấm dùng chung

struct OrganicBackground: ViewModifier {
    func body(content: Content) -> some View {
        content.background(
            LinearGradient(colors: [Palette.surface, Palette.bg, Color(hex: "#EFE0C6")],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }
}

extension View {
    func organicBackground() -> some View { modifier(OrganicBackground()) }
}

// MARK: - Giới hạn chiều rộng cho màn chơi game (tránh giãn quá rộng trên iPad)

extension View {
    /// Ép nội dung game không rộng quá bề ngang thiết kế gốc trên iPhone, căn
    /// giữa màn hình. Chỉ dùng cho các màn chơi (icon/ô nhỏ dễ trông lạc lõng
    /// trên iPad) — không dùng cho màn danh sách/menu vốn nên tận dụng hết
    /// chiều rộng iPad.
    func gameContentWidth() -> some View {
        self.frame(maxWidth: 420).frame(maxWidth: .infinity)
    }
}

// MARK: - Nút viên thuốc

struct PillButtonStyle: ButtonStyle {
    let theme: Theme
    var filled = true
    var compact = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(compact ? .body(13, weight: .bold) : .display(21))
            .foregroundStyle(filled ? Palette.onAccent : Palette.ink)
            .frame(maxWidth: compact ? nil : .infinity, minHeight: compact ? 38 : 58)
            .padding(.horizontal, compact ? 16 : 0)
            .background {
                Capsule().fill(filled ? (configuration.isPressed ? theme.dark : theme.base) : .clear)
                if !filled { Capsule().strokeBorder(Palette.ink.opacity(0.2), lineWidth: 1.5) }
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Ảnh "washed" hoà với nền kem

extension View {
    func washed() -> some View {
        self.saturation(0.6).contrast(0.85).brightness(0.06).opacity(0.94)
    }
}

// MARK: - Thẻ Organic dùng chung

extension View {
    func organicCard() -> some View {
        self
            .background(Palette.surface, in: RoundedRectangle(cornerRadius: DesignTokens.radiusLg))
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.radiusLg))
            .shadow(color: Palette.ink.opacity(0.08), radius: 8, y: 3)
    }
}

// MARK: - Thanh tiến độ đọc (thẻ từ / trang truyện)

/// Vạch tiến độ dùng chung cho màn đọc thẻ từ và đọc truyện.
/// Khi `total` nhỏ (vd. số trang 1 chương), mỗi mục 1 vạch bằng nhau.
/// Khi `total` lớn (vd. 86 thẻ từ), chỉ vẽ tối đa `maxTicks` vạch đã qua
/// cộng 1 vạch co giãn đại diện phần còn lại, tránh vẽ hàng chục vạch nhỏ xíu.
struct ReadingProgressBar: View {
    let current: Int
    let total: Int
    let theme: Theme
    var maxTicks: Int = 6

    var body: some View {
        HStack(spacing: 5) {
            if total <= maxTicks {
                ForEach(0..<total, id: \.self) { i in
                    Capsule().fill(i < current ? theme.base : Palette.ink.opacity(0.12))
                        .frame(height: 7)
                }
            } else {
                let filled = min(current, maxTicks - 1)
                ForEach(0..<filled, id: \.self) { _ in
                    Capsule().fill(theme.base).frame(width: 22, height: 7)
                }
                Capsule().fill(Palette.ink.opacity(0.12))
                    .frame(height: 7)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
        .animation(.easeOut(duration: 0.25), value: current)
    }
}
