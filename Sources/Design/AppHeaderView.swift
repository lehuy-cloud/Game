import SwiftUI

struct AppHeaderView: View {
    let title: String

    @Environment(ProfileStore.self) private var profileStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.theme) private var theme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var showBuddySheet = false

    private var isRegularWidth: Bool { horizontalSizeClass == .regular }

    var body: some View {
        HStack(alignment: .center, spacing: isRegularWidth ? 16 : 12) {
            Button { showBuddySheet = true } label: {
                ZStack {
                    Circle().fill(Palette.surface)
                    Text(profileStore.selectedCharacter?.emoji ?? "🐝")
                        .font(.system(size: isRegularWidth ? 30 : 22))
                }
                .frame(width: isRegularWidth ? 62 : 46, height: isRegularWidth ? 62 : 46)
                .overlay(Circle().strokeBorder(theme.base, lineWidth: 3))
            }
            .accessibilityLabel("Của bé")

            // 44pt trên iPad theo thiết kế (bản cũ khoá cứng 26pt cho cả hai máy).
            Text(title)
                .font(.display(Layout.titleSize(isRegularWidth)))
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: isRegularWidth ? 9 : 6) {
                Text("⭐")
                Text("\(totalStars)")
                    .font(.body(isRegularWidth ? 19 : 15, weight: .bold))
            }
            .padding(.horizontal, isRegularWidth ? 20 : 14)
            .padding(.vertical, isRegularWidth ? 12 : 9)
            .background(theme.tint, in: Capsule())
            .foregroundStyle(theme.deep)
        }
        .padding(.horizontal, Layout.side(isRegularWidth))
        .sheet(isPresented: $showBuddySheet) { BuddySheetView() }
    }

    private var totalStars: Int {
        progressStore.starsByCategory.values.reduce(0, +)
    }
}
