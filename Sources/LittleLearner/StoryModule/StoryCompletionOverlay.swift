import SwiftUI

struct StoryCompletionOverlay: View {
    let outroText: String
    let onContinue: () -> Void

    @Environment(\.theme) private var theme

    var body: some View {
        VStack(spacing: DesignTokens.spacing) {
            Text("🎉")
                .font(.system(size: 60))
            Text(outroText)
                .font(.display(20))
                .foregroundStyle(Palette.ink)
                .multilineTextAlignment(.center)
            RewardStarsView(count: 1)
            Button("Về danh sách chương", action: onContinue)
                .buttonStyle(PillButtonStyle(theme: theme))
        }
        .padding(DesignTokens.spacing * 2)
        .organicCard()
        .padding()
    }
}
