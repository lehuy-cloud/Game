import SwiftUI

/// Pill điều hướng chính (Học / Chơi / Truyện) — thay cho tab bar hệ thống vì
/// tab bar mặc định của iPadOS dùng font/size hệ thống, không khớp thiết kế
/// (chữ Baloo2/Be Vietnam Pro to hơn, mục đang chọn có nền fill đặc).
struct MainTabBar<Tab: Hashable>: View {
    struct Item {
        let tab: Tab
        let title: String
    }

    @Binding var selection: Tab
    let items: [Item]

    @Environment(\.theme) private var theme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isRegularWidth: Bool { horizontalSizeClass == .regular }

    var body: some View {
        HStack(spacing: isRegularWidth ? 6 : 4) {
            ForEach(items, id: \.tab) { item in
                let isSelected = selection == item.tab
                Button {
                    selection = item.tab
                } label: {
                    Text(item.title)
                        .font(.body(isRegularWidth ? 19 : 15, weight: .bold))
                        .foregroundStyle(isSelected ? Palette.onAccent : Palette.ink.opacity(0.55))
                        .padding(.horizontal, isRegularWidth ? 30 : 18)
                        .padding(.vertical, isRegularWidth ? 11 : 9)
                        .background {
                            if isSelected {
                                Capsule().fill(theme.base)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(Palette.surface, in: Capsule())
        .shadow(color: Palette.ink.opacity(0.08), radius: 6, y: 2)
    }
}
