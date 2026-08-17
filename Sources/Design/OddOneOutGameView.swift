import SwiftUI

/// Tìm bạn khác loài — bốn ô LỚN chia đều vùng chơi (thiết kế P13), mỗi ô là
/// một ảnh + tên thẻ. Ba ô cùng một `VocabularyCategory`, một ô lạc.
///
/// LỖI ĐÃ SỬA (thấy trên ảnh chụp iPad):
/// 1. Bốn ô bé xíu dồn xuống đáy, giữa màn trống một khoảng lớn. Nguyên nhân:
///    câu hỏi ("Ai không cùng nhóm?") nằm ở slot `question` với
///    `maxHeight: .infinity` nên nuốt hết chỗ trống, còn `optionTile` dùng
///    `.aspectRatio(1, contentMode: .fit)` quanh một HStack → ô co lại đúng
///    bằng cỡ ảnh (140pt) thay vì giãn hết bề rộng cột.
///    Nay câu hỏi + lưới cùng nằm trong slot `question`; lưới đo bằng
///    `GeometryReader` và chia đôi cả bề ngang lẫn chiều cao còn lại.
/// 2. Ba ô hiện SỐ (4, 5, 6) đứng cạnh một ô ảnh koala — nhóm bốc trúng
///    category "numbers"/"colors" nên câu hỏi thành so sánh số với ảnh, sai
///    thiết kế "4 ô lớn cùng bộ ảnh". Nay nhóm 3 thẻ luôn lấy từ category có
///    ẢNH; số/màu chỉ được dùng làm ô lạc (và vẫn vẽ to, có tên thẻ).
/// 3. Ô đáp án không có tên thẻ — thiết kế có dòng chữ dưới ảnh.
struct OddOneOutGameView: View {
    private static let totalQuestions = 8
    private static let progressKey = "game_oddoneout"

    @Environment(ProgressStore.self) private var progressStore
    @Environment(ProfileStore.self) private var profileStore
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isRegularWidth: Bool { horizontalSizeClass == .regular }
    private var tileGap: CGFloat { isRegularWidth ? 26 : 14 }

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
                        .frame(maxWidth: isRegularWidth ? 620 : .infinity)
                } else {
                    VStack(spacing: isRegularWidth ? 26 : 16) {
                        Text("Ai không cùng nhóm?")
                            .font(.display(isRegularWidth ? 40 : 26))
                            .frame(maxWidth: .infinity)
                        optionGrid(question)
                    }
                }
            }
        } answers: {
            if currentQuestion != nil, selectedId != nil {
                Button("Câu tiếp theo ▸", action: advance)
                    .buttonStyle(PillButtonStyle(theme: theme))
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

    // MARK: - Lưới 2×2 chia hết vùng chơi

    private func optionGrid(_ question: Question) -> some View {
        GeometryReader { proxy in
            let cellW = (proxy.size.width - tileGap) / 2
            let cellH = (proxy.size.height - tileGap) / 2
            let rows = stride(from: 0, to: question.allCards.count, by: 2).map {
                Array(question.allCards[$0 ..< min($0 + 2, question.allCards.count)])
            }
            VStack(spacing: tileGap) {
                ForEach(rows.indices, id: \.self) { r in
                    HStack(spacing: tileGap) {
                        ForEach(rows[r]) { card in
                            optionTile(card, question: question)
                                .frame(width: cellW, height: cellH)
                        }
                    }
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }

    private func optionTile(_ card: VocabularyCard, question: Question) -> some View {
        VStack(spacing: isRegularWidth ? 12 : 8) {
            imageView(card)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Text(card.word)
                .font(.body(isRegularWidth ? 20 : 15, weight: .bold))
                .foregroundStyle(Palette.ink)
                .lineLimit(1)
        }
        .padding(isRegularWidth ? 28 : 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RoundedRectangle(cornerRadius: DesignTokens.radiusLg, style: .continuous).fill(Palette.surface))
        .shadow(color: Color(hex: "#2E2B25").opacity(0.1), radius: 6, y: 3)
        .scaleEffect(bounceId == card.id ? 1.06 : 1)
        .contentShape(RoundedRectangle(cornerRadius: DesignTokens.radiusLg))
        .onTapGesture { handleTap(card, question: question) }
        .animation(.spring(response: 0.3, dampingFraction: 0.4), value: bounceId)
    }

    @ViewBuilder
    private func imageView(_ card: VocabularyCard) -> some View {
        if let imageName = card.imageName {
            Image(imageName).resizable().scaledToFit().washed()
        } else if let value = card.value {
            Text("\(value)")
                .font(.display(isRegularWidth ? 96 : 48))
                .foregroundStyle(theme.deep)
                .minimumScaleFactor(0.4)
        } else if let colorHex = card.colorHex {
            RoundedRectangle(cornerRadius: isRegularWidth ? 24 : 14, style: .continuous)
                .fill(Color(hex: colorHex))
                .aspectRatio(1, contentMode: .fit)
        } else {
            Text(card.emoji).font(.system(size: isRegularWidth ? 90 : 44))
        }
    }

    private func resultSection(for question: Question) -> some View {
        VStack(spacing: isRegularWidth ? 26 : 18) {
            VStack(spacing: 8) {
                Image(systemName: "checkmark")
                    .font(.system(size: isRegularWidth ? 34 : 28, weight: .bold))
                    .foregroundStyle(Palette.onAccent)
                    .frame(width: isRegularWidth ? 84 : 68, height: isRegularWidth ? 84 : 68)
                    .background(Circle().fill(Palette.sage))
                Text("Đúng rồi!").font(.display(isRegularWidth ? 36 : 26))
            }
            .padding(.top, 6)

            VStack(alignment: .leading, spacing: isRegularWidth ? 16 : 12) {
                Text(groupTitle(for: question).uppercased())
                    .font(.body(isRegularWidth ? 14 : 11, weight: .bold))
                    .tracking(1.0)
                    .foregroundStyle(Palette.ink.opacity(0.6))
                HStack(spacing: isRegularWidth ? 14 : 10) {
                    ForEach(question.groupCards) { card in
                        imageView(card)
                            .frame(width: isRegularWidth ? 96 : 58, height: isRegularWidth ? 96 : 58)
                            .padding(isRegularWidth ? 12 : 8)
                            .background(Palette.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(isRegularWidth ? 24 : 16)
            .background {
                RoundedRectangle(cornerRadius: DesignTokens.radiusLg, style: .continuous).fill(Palette.sageTint)
                RoundedRectangle(cornerRadius: DesignTokens.radiusLg, style: .continuous).strokeBorder(Palette.sage, lineWidth: 3)
            }

            HStack(spacing: isRegularWidth ? 20 : 14) {
                imageView(question.oddCard)
                    .frame(width: isRegularWidth ? 88 : 56, height: isRegularWidth ? 88 : 56)
                VStack(alignment: .leading, spacing: 2) {
                    Text(question.oddCard.translation).font(.display(isRegularWidth ? 30 : 20))
                    Text(question.oddCard.word)
                        .font(.body(isRegularWidth ? 17 : 12))
                        .foregroundStyle(Palette.ink.opacity(0.55))
                }
                Spacer(minLength: 0)
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .font(.system(size: isRegularWidth ? 30 : 22))
            }
            .padding(isRegularWidth ? 20 : 14)
            .background(RoundedRectangle(cornerRadius: DesignTokens.radiusLg, style: .continuous).fill(Palette.surfaceAlt))
        }
    }

    private func groupTitle(for question: Question) -> String {
        let title = VocabularyContent.categories.first { $0.id == question.groupCategoryId }?.title ?? ""
        return "Nhóm \(title.lowercased())"
    }

    // MARK: - Logic

    // "story" là ảnh minh hoạ riêng của từng chương (bão tuyết, phù thuỷ) —
    // không hợp bốc ngẫu nhiên vào mini-game vui, nên loại.
    private static let eligibleCategoryIds = VocabularyContent.categories.map(\.id).filter { $0 != "story" }

    /// Nhóm 3 thẻ luôn lấy từ category có ảnh thật, để bốn ô nhìn "cùng một bộ"
    /// như thiết kế; số/màu chỉ làm ô lạc.
    private static let imageCategoryIds: [String] = eligibleCategoryIds.filter { id in
        VocabularyContent.cards(for: id).contains { $0.imageName != nil }
    }

    private func buildRound() {
        let groupPool = Self.imageCategoryIds.isEmpty ? Self.eligibleCategoryIds : Self.imageCategoryIds
        questions = (0 ..< Self.totalQuestions).map { _ in
            let groupId = groupPool.randomElement()!
            let oddId = Self.eligibleCategoryIds.filter { $0 != groupId }.randomElement() ?? groupId
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
