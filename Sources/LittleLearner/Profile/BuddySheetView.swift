import SwiftUI

struct BuddySheetView: View {
    @Environment(ProfileStore.self) private var profileStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    @State private var isChoosingCharacter = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.spacing) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle().fill(Palette.bg)
                        Text(profileStore.selectedCharacter?.emoji ?? "🐝")
                            .font(.system(size: 33))
                    }
                    .frame(width: 64, height: 64)
                    .overlay(Circle().strokeBorder(theme.base, lineWidth: 4))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(profileStore.selectedCharacter?.name ?? "Bạn nhỏ")
                            .font(.display(24))
                        Text("\(totalStars) sao")
                            .font(.body(13))
                            .foregroundStyle(Palette.ink.opacity(0.55))
                    }
                }

                sectionLabel("Sao theo chủ đề")
                VStack(spacing: 8) {
                    ForEach(VocabularyContent.categories) { category in
                        HStack(spacing: 10) {
                            Circle()
                                .fill(Color(hex: category.colorHex))
                                .frame(width: 9, height: 9)
                            Text(category.title)
                                .font(.body(14, weight: .semibold))
                            Spacer()
                            Text("\(progressStore.starsByCategory[category.id, default: 0])")
                                .font(.body(14, weight: .bold))
                                .foregroundStyle(theme.deep)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Palette.bg, in: RoundedRectangle(cornerRadius: DesignTokens.radiusTile))
                    }
                }

                sectionLabel("Màu của bé")
                    .padding(.top, DesignTokens.spacing / 2)
                HStack(spacing: 12) {
                    ForEach(Theme.all) { t in
                        Button {
                            profileStore.themeId = t.id
                        } label: {
                            Circle()
                                .fill(t.base)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .strokeBorder(Palette.ink.opacity(profileStore.themeId == t.id ? 0.5 : 0), lineWidth: 3)
                                )
                                .padding(3)
                        }
                        .accessibilityLabel(t.name)
                    }

                    Spacer()

                    Button("Đổi bạn") {
                        isChoosingCharacter = true
                    }
                    .buttonStyle(PillButtonStyle(theme: theme, filled: false, compact: true))
                }
            }
            .padding(DesignTokens.spacing)
        }
        .organicBackground()
        .sheet(isPresented: $isChoosingCharacter) {
            CharacterSelectionView()
        }
    }

    private var totalStars: Int {
        progressStore.starsByCategory.values.reduce(0, +)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.body(11, weight: .bold))
            .foregroundStyle(Palette.ink.opacity(0.45))
            .tracking(0.8)
    }
}
