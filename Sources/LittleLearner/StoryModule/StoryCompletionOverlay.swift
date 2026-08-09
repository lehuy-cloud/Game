import SwiftUI

struct StoryCompletionOverlay: View {
    let outroText: String
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: DesignTokens.spacing) {
            Text("🎉")
                .font(.system(size: 60))
            Text(outroText)
                .font(.title3.bold())
                .multilineTextAlignment(.center)
            RewardStarsView(count: 1)
            Button("Về danh sách chương", action: onContinue)
                .buttonStyle(.big)
        }
        .padding(DesignTokens.spacing * 2)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
        .padding()
    }
}
