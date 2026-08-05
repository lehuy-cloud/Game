import SwiftUI

struct BigButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minWidth: DesignTokens.minTapTarget, minHeight: DesignTokens.minTapTarget)
            .background(.tint, in: RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
            .foregroundStyle(.white)
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == BigButtonStyle {
    static var big: BigButtonStyle { BigButtonStyle() }
}
