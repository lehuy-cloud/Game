import SwiftUI

/// Tìm bạn khác loài — bốn ảnh, ba ảnh cùng một `VocabularyCategory`, một ảnh
/// lấy từ category khác. Bé chạm vào ảnh lạc. Game duy nhất trộn nhiều
/// category cùng lúc nên tự sinh thêm câu hỏi khi có category mới, không
/// cần dữ liệu riêng.
struct OddOneOutGameView: View {
    private static let totalQuestions = 8
    private static let progressKey = "game_oddoneout"

    @Environment(ProgressStore.self) private var progressStore
    @Environment(ProfileStore.self) private var profileStore
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isRegularWidth: Bool { horizontalSizeClass == .regular }

    @State private var questions: [Question] = []
    @State private var currentIndex = 0
    @State private var selectedId: String?
    @State private var bounceId: String?
    @State private var correctCount = 0
    @State private var isRoundComplete = false

    private struct Question {
        let groupCategoryId: String
        let groupCards: [VocabularyCard]
        let oddCard: VocabularyCard
        let allCards: [VocabularyCard]
    }

    private var currentQuestion: Question? {
        questions.indices.contains(currentIndex) ? questions[currentIndex] : nil
    }
    private var buddyEmoji: String { profileStore.selectedCharacter?.emoji ?? "🐝" }

    var body: some View {
        GameScreen(title: "Tìm bạn khác loài", index: currentIndex + 1, total: Self.totalQuestions,
                   correct: correctCount,
                   hint: (currentQuestion != nil && selectedId == nil) ? "Chạm vào bạn không cùng nhóm nhé" : nil) {
            if let question = currentQuestion {
                if selectedId != nil {
                    resultSection(for: question)
                } else {
                    Text("Ai không cùng nhóm?")
                        .font(.display(isRegularWidth ? 36 : 26))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        } answers: {
            if let question = currentQuestion {
                if selectedId != nil {
                    Button("Câu tiếp theo ▸", action: advance)
                        .buttonStyle(PillButtonStyle(theme: theme))
                } else {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: isRegularWidth ? 20 : 14), count: 2),
                              spacing: isRegularWidth ? 20 : 14) {
                        ForEach(question.allCards) { card in
                            optionTile(card, question: question)
                        }
                    }
                }
            }
        }
        .onAppear { if questions.isEmpty { buildRound() } }
        .overlay {
            if isRoundComplete {
                RoundCompleteSheetView(correctCount: correctCount, totalCount: Self.totalQuestions,
                                        buddyEmoji: buddyEmoji, playAgain: buildRound, goHome: { dismiss() })
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: isRoundComplete)
    }

    @ViewBuilder
    private func imageView(_ card: VocabularyCard) -> some View {
        if let imageName = card.imageName {
            Image(imageName).resizable().scaledToFit().washed()
        } else if let value = card.value {
            Text("\(value)").font(.display(34)).foregroundStyle(theme.deep)
        } else if let colorHex = card.colorHex {
            RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color(hex: colorHex))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Palette.ink.opacity(0.18), lineWidth: 1.5)
                }
        } else {
            Text(card.emoji).font(.system(size: 40))
        }
    }

    private func optionTile(_ card: VocabularyCard, question: Question) -> some View {
        HStack {
            Spacer(minLength: 0)
            imageView(card).frame(width: isRegularWidth ? 140 : 84, height: isRegularWidth ? 140 : 84)
            Spacer(minLength: 0)
        }
        .aspectRatio(1, contentMode: .fit)
        .background(RoundedRectangle(cornerRadius: DesignTokens.radiusLg, style: .continuous).fill(Palette.surface))
        .shadow(color: Color(hex: "#2E2B25").opacity(0.1), radius: 6, y: 3)
        .scaleEffect(bounceId == card.id ? 1.08 : 1)
        .contentShape(RoundedRectangle(cornerRadius: DesignTokens.radiusLg))
        .onTapGesture { handleTap(card, question: question) }
        .animation(.spring(response: 0.3, dampingFraction: 0.4), value: bounceId)
    }

    private func resultSection(for question: Question) -> some View {
        VStack(spacing: 18) {
            VStack(spacing: 8) {
                Image(systemName: "checkmark")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Palette.onAccent)
                    .frame(width: 68, height: 68)
                    .background(Circle().fill(Palette.sage))
                Text("Đúng rồi!").font(.display(26))
            }
            .padding(.top, 6)

            VStack(alignment: .leading, spacing: 12) {
                Text(groupTitle(for: question).uppercased())
                    .font(.body(11, weight: .bold))
                    .tracking(1.0)
                    .foregroundStyle(Palette.ink.opacity(0.6))
                HStack(spacing: 10) {
                    ForEach(question.groupCards) { card in
                        imageView(card)
                            .frame(width: 58, height: 58)
                            .padding(8)
                            .background(Palette.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: DesignTokens.radiusLg, style: .continuous).fill(Palette.sageTint)
                RoundedRectangle(cornerRadius: DesignTokens.radiusLg, style: .continuous).strokeBorder(Palette.sage, lineWidth: 3)
            }

            HStack(spacing: 14) {
                imageView(question.oddCard).frame(width: 56, height: 56)
                VStack(alignment: .leading, spacing: 2) {
                    Text(question.oddCard.word).font(.display(20))
                    Text(question.oddCard.translation).font(.body(12)).foregroundStyle(Palette.ink.opacity(0.55))
                }
                Spacer(minLength: 0)
                Image(systemName: "star.fill").foregroundStyle(.yellow).font(.system(size: 22))
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: DesignTokens.radiusLg, style: .continuous).fill(Palette.surfaceAlt))
        }
    }

    private func groupTitle(for question: Question) -> String {
        let title = VocabularyContent.categories.first { $0.id == question.groupCategoryId }?.title ?? ""
        return "Nhóm \(title.lowercased())"
    }

    // MARK: - Logic

    // "story" chỉ gồm ảnh minh hoạ riêng cho từng chương truyện (có ảnh khá
    // u tối như bão tuyết/phù thuỷ) — không hợp để bốc ngẫu nhiên vào một
    // mini-game vui nhộn, nên loại khỏi danh sách category dùng ở đây.
    private static let eligibleCategoryIds = VocabularyContent.categories.map(\.id).filter { $0 != "story" }

    private func buildRound() {
        let categoryIds = Self.eligibleCategoryIds
        questions = (0..<Self.totalQuestions).map { _ in
            let groupId = categoryIds.randomElement()!
            let oddId = categoryIds.filter { $0 != groupId }.randomElement()!
            let groupCards = Array(VocabularyContent.cards(for: groupId).shuffled().prefix(3))
            let oddCard = VocabularyContent.cards(for: oddId).randomElement()!
            return Question(groupCategoryId: groupId, groupCards: groupCards, oddCard: oddCard,
                             allCards: (groupCards + [oddCard]).shuffled())
        }
        currentIndex = 0
        selectedId = nil
        bounceId = nil
        correctCount = 0
        isRoundComplete = false
    }

    private func handleTap(_ card: VocabularyCard, question: Question) {
        guard selectedId == nil else { return }
        if card.id == question.oddCard.id {
            selectedId = card.id
            correctCount += 1
            progressStore.addStar(for: Self.progressKey)
            SpeechService.shared.speak(question.oddCard.word)
        } else {
            bounceId = card.id
            Task {
                try? await Task.sleep(for: .seconds(0.35))
                bounceId = nil
            }
        }
    }

    private func advance() {
        if currentIndex + 1 < questions.count {
            currentIndex += 1
            selectedId = nil
        } else {
            isRoundComplete = true
        }
    }
}
