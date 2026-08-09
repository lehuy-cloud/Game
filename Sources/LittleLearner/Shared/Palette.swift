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
    /// Caprasimo — giọng tiêu đề duy nhất của hệ thống.
    static func display(_ size: CGFloat) -> Font { .custom("Caprasimo", size: size) }
    /// Figtree — chữ thường.
    static func body(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("Figtree", size: size).weight(weight)
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

// MARK: - Nút viên thuốc

struct PillButtonStyle: ButtonStyle {
    let theme: Theme
    var filled = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.display(21))
            .foregroundStyle(filled ? Palette.onAccent : Palette.ink)
            .frame(maxWidth: .infinity, minHeight: 58)
            .background {
                Capsule().fill(filled ? (configuration.isPressed ? theme.dark : theme.base) : .clear)
                if !filled { Capsule().strokeBorder(Palette.ink.opacity(0.2), lineWidth: 1.5) }
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
