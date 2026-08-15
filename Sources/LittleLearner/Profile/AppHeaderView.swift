import SwiftUI

struct AppHeaderView: View {
    let title: String

    @Environment(ProfileStore.self) private var profileStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.theme) private var theme
    @State private var showBuddySheet = false

    var body: some View {
        HStack(spacing: 12) {
            Button {
                showBuddySheet = true
            } label: {
                ZStack {
                    Circle().fill(Palette.surface)
                    Text(profileStore.selectedCharacter?.emoji ?? "🐝")
                        .font(.system(size: 22))
                }
                .frame(width: 46, height: 46)
                .overlay(Circle().strokeBorder(theme.base, lineWidth: 3))
            }
            .accessibilityLabel("Của bé")

            Text(title)
                .font(.display(26))
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 6) {
                Text("⭐")
                Text("\(totalStars)")
                    .font(.body(15, weight: .bold))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(theme.tint, in: Capsule())
            .foregroundStyle(theme.deep)
        }
        .padding(.horizontal, DesignTokens.spacing)
        .sheet(isPresented: $showBuddySheet) {
            BuddySheetView()
        }
    }

    private var totalStars: Int {
        progressStore.starsByCategory.values.reduce(0, +)
    }
}
