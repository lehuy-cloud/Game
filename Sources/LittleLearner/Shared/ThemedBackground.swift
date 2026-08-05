import SwiftUI

private struct ThemedBackgroundModifier: ViewModifier {
    @Environment(ProfileStore.self) private var profileStore

    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(colors: [backgroundColor, .white], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
    }

    private var backgroundColor: Color {
        guard let character = profileStore.selectedCharacter else { return .white }
        return Color(hex: character.secondaryHex)
    }
}

extension View {
    func themedBackground() -> some View {
        modifier(ThemedBackgroundModifier())
    }
}
