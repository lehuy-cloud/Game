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

private struct ThemeKey: EnvironmentKey { static let defaultValue: Theme = .terracotta }
extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

// MARK: - Type

extension Font {
    static func display(_ size: CGFloat) -> Font { .custom("Baloo2-ExtraBold", size: size) }
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

/// SỐ ĐO THEO THIẾT KẾ. `DesignTokens.spacing` (16) là số của iPhone; dùng nó
/// làm padding lề trên iPad là nguyên nhân các màn iPad trông chật và lệch
/// mockup. Mọi màn iPad phải lấy lề/khoảng cách từ đây.
enum Layout {
    static func side(_ isRegular: Bool) -> CGFloat { isRegular ? 44 : 16 }
    static func gap(_ isRegular: Bool) -> CGFloat { isRegular ? 24 : 13 }
    static func titleSize(_ isRegular: Bool) -> CGFloat { isRegular ? 44 : 26 }
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

extension View {
    /// Chỉ dùng cho màn CHƠI game (ô nhỏ dễ lạc lõng khi giãn quá rộng).
    /// Không dùng cho màn danh sách/menu — chúng phải tận dụng hết bề ngang iPad.
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


// MARK: - Ảnh phủ kín ô (không được làm phình thẻ)

/// LỖI ĐÃ SỬA: `Image().resizable().scaledToFill()` đặt thẳng trong thẻ vẫn
/// khai báo kích thước gốc rất lớn với hệ thống layout, nên ô lưới phình ra:
/// thẻ có ảnh rộng/cao hơn thẻ bên cạnh, đè lên header, tràn khỏi hàng.
/// `.clipped()` chỉ cắt lúc vẽ, không sửa layout. Ảnh phải nằm trong
/// `overlay` của một hình trong suốt — overlay không tham gia tính layout.
struct CoverFill: View {
    let imageName: String
    var washedStyle: Bool = true

    var body: some View {
        Color.clear
            .overlay {
                Group {
                    if washedStyle {
                        Image(imageName).resizable().scaledToFill().washed()
                    } else {
                        Image(imageName).resizable().scaledToFill()
                    }
                }
            }
            .clipped()
            .contentShape(Rectangle())
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

// MARK: - Lớp phủ tối trên ảnh (để chữ trắng đọc được)

/// Thiếu lớp này là lý do header chương "dính" vào tranh trên bản chạy thật.
struct TopScrim: View {
    var height: CGFloat = 300
    var body: some View {
        LinearGradient(colors: [Palette.ink.opacity(0.62), Palette.ink.opacity(0.28), Palette.ink.opacity(0)],
                       startPoint: .top, endPoint: .bottom)
            .frame(height: height)
            .frame(maxHeight: .infinity, alignment: .top)
            .allowsHitTesting(false)
            .ignoresSafeArea()
    }
}

// MARK: - Thanh tiến độ đọc (thẻ từ / trang truyện)

struct ReadingProgressBar: View {
    let current: Int
    let total: Int
    let theme: Theme
    var maxTicks: Int = 6
    /// 7pt cho iPhone, 9pt cho iPad theo thiết kế.
    var thickness: CGFloat = 7
    var filledColor: Color? = nil
    var trackColor: Color? = nil

    private var filled: Color { filledColor ?? theme.base }
    private var track: Color { trackColor ?? Palette.ink.opacity(0.12) }

    var body: some View {
        HStack(spacing: 5) {
            if total <= maxTicks {
                ForEach(0..<max(total, 1), id: \.self) { i in
                    Capsule().fill(i < current ? filled : track)
                        .frame(height: thickness)
                        .frame(maxWidth: .infinity)   // chia đều, tràn hết bề ngang
                }
            } else {
                let filledCount = min(current, maxTicks - 1)
                ForEach(0..<filledCount, id: \.self) { _ in
                    Capsule().fill(filled).frame(width: 22, height: thickness)
                }
                Capsule().fill(track)
                    .frame(height: thickness)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
        .animation(.easeOut(duration: 0.25), value: current)
    }
}
