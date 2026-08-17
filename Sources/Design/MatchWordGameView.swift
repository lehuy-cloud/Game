import SwiftUI

/// Ghép chữ với hình — ba ảnh, ba thẻ chữ (chữ HOA). Bé kéo thẻ chữ lên ảnh
/// đúng để thả vào ô nhận; chạm thẻ chữ rồi chạm ảnh (không kéo) cũng ăn,
/// vì tay bé kéo không phải lúc nào cũng chính xác.
///
/// LỖI ĐÃ SỬA (ảnh chụp iPad: mọi thứ bé xíu dồn lên đỉnh, dưới trống hơn nửa màn):
/// 1. `.gameContentWidth()` bọc CẢ MÀN → toàn bộ game bị nhốt trong cột 420pt
///    giữa iPad (đúng lỗi số 9 đã sửa cho 4 mini-game truyện, màn này bị sót).
///    Nay dùng `GameScreen` như các game khác — nền + header full bề ngang, chỉ
///    vùng chơi mới giới hạn bề rộng.
/// 2. Header, thanh tiến độ, ảnh (62pt), ô nhận (40pt), thẻ chữ (19pt) khoá cứng
///    cỡ iPhone → trên iPad nhỏ như đồ chơi. Nay mọi cỡ theo `isRegularWidth`.
/// 3. `Spacer(minLength: 0)` cuối `VStack` đẩy hết nội dung lên đỉnh, chừa
///    khoảng trống lớn. Nay ba ô ảnh giãn chia đều chiều cao vùng chơi.
struct MatchWordGameView: View {
    private static let totalQuestions = 8
    private static let progressKey = "game_matchword"
    private static let cardsPerQuestion = 3
    private static let dragSpace = "matchWordSpace"

    @Environment(ProgressStore.self) private var progressStore
    @Environment(ProfileStore.self) private var profileStore
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isRegularWidth: Bool { horizontalSizeClass == .regular }

    @State private var questions: [Question] = []
    @State private var currentIndex = 0
    @State private var matchedIds: Set<String> = []
    @State private var selectedWordId: String?
    @State private var draggingCardId: String?
    @State private var dragTranslation: CGSize = .zero
    @State private var dropZoneFrames: [String: CGRect] = [:]
    @State private var shakingCardId: String?
    @State private var shakeToken: CGFloat = 0
    @State private var correctCount = 0
    @State private var isRoundComplete = false

    private struct Question {
        let cards: [VocabularyCard]
        let wordOrder: [VocabularyCard]
    }

    private var currentQuestion: Question? {
        questions.indices.contains(currentIndex) ? questions[currentIndex] : nil
    }
    private var buddyEmoji: String { profileStore.selectedCharacter?.emoji ?? "🐝" }

    private var isComplete: Bool {
        guard let question = currentQuestion else { return false }
        return matchedIds.count == question.cards.count
    }

    var body: some View {
        GameScreen(title: "Ghép chữ với hình", index: currentIndex + 1, total: Self.totalQuestions,
                   correct: correctCount,
                   hint: isComplete ? nil : (selectedWordId != nil ? "Giờ chạm vào đúng ảnh nhé"
                                                                   : "Kéo hoặc chạm vào một thẻ chữ")) {
            if let question = currentQuestion {
                VStack(spacing: isRegularWidth ? 26 : 16) {
                    if isComplete {
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark")
                                .font(.system(size: isRegularWidth ? 34 : 28, weight: .bold))
                                .foregroundStyle(Palette.onAccent)
                                .frame(width: isRegularWidth ? 84 : 68, height: isRegularWidth ? 84 : 68)
                                .background(Circle().fill(Palette.sage))
                            Text("Ghép đúng hết!").font(AppFont.question(isRegularWidth))
                        }
                        .frame(maxWidth: .infinity)
                    }

                    HStack(spacing: isRegularWidth ? 24 : 14) {
                        ForEach(question.cards) { card in
                            imageDropTile(card, question: question)
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
                .coordinateSpace(name: Self.dragSpace)
                .onPreferenceChange(DropZoneFrameKey.self) { dropZoneFrames = $0 }
                .animation(.easeOut(duration: 0.25), value: matchedIds)
            }
        } answers: {
            if let question = currentQuestion {
                if isComplete {
                    Button("Câu tiếp theo ▸", action: advance)
                        .buttonStyle(PillButtonStyle(theme: theme))
                } else {
                    wordTray(for: question)
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

    // MARK: - Ô ảnh

    @ViewBuilder
    private func imageView(_ card: VocabularyCard) -> some View {
        if let imageName = card.imageName {
            Image(imageName).resizable().scaledToFit().washed()
        } else {
            Text(card.emoji).font(.system(size: isRegularWidth ? 64 : 34))
        }
    }

    private func imageDropTile(_ card: VocabularyCard, question: Question) -> some View {
        let isMatched = matchedIds.contains(card.id)
        let isTargetable = selectedWordId != nil && !isMatched
        let slotH: CGFloat = isRegularWidth ? 64 : 40
        let radius: CGFloat = isRegularWidth ? 20 : 14
        return VStack(spacing: isRegularWidth ? 16 : 8) {
            imageView(card)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Group {
                if isMatched {
                    Text(card.word.uppercased())
                        .font(AppFont.tileTitle(isRegularWidth))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .frame(maxWidth: .infinity)
                        .frame(height: slotH)
                        .background {
                            RoundedRectangle(cornerRadius: radius, style: .continuous).fill(Palette.sageTint)
                            RoundedRectangle(cornerRadius: radius, style: .continuous)
                                .strokeBorder(Palette.sage, lineWidth: 2.5)
                        }
                } else {
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .strokeBorder(isTargetable ? Palette.sage : theme.tint,
                                      style: StrokeStyle(lineWidth: 2.5, dash: isTargetable ? [] : [5, 4]))
                        .background {
                            RoundedRectangle(cornerRadius: radius, style: .continuous)
                                .fill(isTargetable ? Palette.sageTint.opacity(0.5) : Palette.surfaceAlt)
                        }
                        .frame(height: slotH)
                }
            }
        }
        .padding(isRegularWidth ? 22 : 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            RoundedRectangle(cornerRadius: DesignTokens.radiusLg, style: .continuous).fill(Palette.surface)
            GeometryReader { geo in
                Color.clear.preference(key: DropZoneFrameKey.self,
                                       value: [card.id: geo.frame(in: .named(Self.dragSpace))])
            }
        }
        .shadow(color: Color(hex: "#2E2B25").opacity(0.1), radius: 6, y: 3)
        .modifier(ShakeEffect(animatableData: shakingCardId == card.id ? shakeToken : 0))
        .contentShape(Rectangle())
        .onTapGesture { handleImageTap(card, question: question) }
    }

    // MARK: - Khay chữ

    private func wordTray(for question: Question) -> some View {
        HStack(spacing: isRegularWidth ? 20 : 12) {
            ForEach(question.wordOrder.filter { !matchedIds.contains($0.id) }) { card in
                wordChip(card, question: question)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: isRegularWidth ? 108 : 80)
    }

    private func wordChip(_ card: VocabularyCard, question: Question) -> some View {
        let isSelected = selectedWordId == card.id
        let isDragging = draggingCardId == card.id
        let isLifted = isSelected || isDragging
        return Text(card.word.uppercased())
            .font(.display(isRegularWidth ? 30 : 19))
            .foregroundStyle(isLifted ? Palette.onAccent : Palette.ink)
            .frame(minWidth: isRegularWidth ? 168 : 96, minHeight: isRegularWidth ? 88 : 64)
            .padding(.horizontal, isRegularWidth ? 26 : 14)
            .background {
                RoundedRectangle(cornerRadius: isRegularWidth ? 26 : 18, style: .continuous)
                    .fill(isLifted ? theme.base : Palette.surface)
            }
            .shadow(color: Color(hex: "#2E2B25").opacity(isLifted ? 0.22 : 0.1),
                    radius: isLifted ? 12 : 6, y: 4)
            .scaleEffect(isDragging ? 1.1 : (isSelected ? 1.06 : 1))
            .rotationEffect(.degrees(isDragging ? -4 : 0))
            .offset(isDragging ? dragTranslation : .zero)
            .contentShape(RoundedRectangle(cornerRadius: isRegularWidth ? 26 : 18))
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .named(Self.dragSpace))
                    .onChanged { value in
                        draggingCardId = card.id
                        dragTranslation = value.translation
                    }
                    .onEnded { value in
                        let distance = hypot(value.translation.width, value.translation.height)
                        if distance < 14 {
                            handleWordTap(card)
                        } else {
                            attemptDrop(card, at: value.location, question: question)
                        }
                        draggingCardId = nil
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            dragTranslation = .zero
                        }
                    }
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
            .zIndex(isDragging ? 1 : 0)
    }

    // MARK: - Logic

    private func buildRound() {
        let pool = VocabularyContent.cards(for: "animals")
        questions = (0..<Self.totalQuestions).map { _ in
            let cards = Array(pool.shuffled().prefix(Self.cardsPerQuestion))
            return Question(cards: cards, wordOrder: cards.shuffled())
        }
        currentIndex = 0
        matchedIds = []
        selectedWordId = nil
        correctCount = 0
        isRoundComplete = false
    }

    private func handleWordTap(_ card: VocabularyCard) {
        guard !matchedIds.contains(card.id) else { return }
        selectedWordId = (selectedWordId == card.id) ? nil : card.id
    }

    private func handleImageTap(_ card: VocabularyCard, question: Question) {
        guard let selectedId = selectedWordId, !matchedIds.contains(card.id) else { return }
        resolveDrop(cardId: selectedId, targetId: card.id, question: question)
    }

    private func attemptDrop(_ card: VocabularyCard, at location: CGPoint, question: Question) {
        guard !matchedIds.contains(card.id) else { return }
        guard let target = dropZoneFrames.first(where: {
            !matchedIds.contains($0.key) && $0.value.contains(location)
        }) else { return }
        resolveDrop(cardId: card.id, targetId: target.key, question: question)
    }

    private func resolveDrop(cardId: String, targetId: String, question: Question) {
        if cardId == targetId {
            matchedIds.insert(cardId)
            selectedWordId = nil
            if let card = question.cards.first(where: { $0.id == cardId }) {
                SpeechService.shared.speak(card.word)
            }
            if matchedIds.count == question.cards.count {
                correctCount += 1
                progressStore.addStar(for: Self.progressKey)
            }
        } else {
            shakingCardId = targetId
            withAnimation(.default) { shakeToken += 1 }
        }
    }

    private func advance() {
        if currentIndex + 1 < questions.count {
            currentIndex += 1
            matchedIds = []
            selectedWordId = nil
        } else {
            isRoundComplete = true
        }
    }
}

private struct DropZoneFrameKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}

/// Hiệu ứng lắc nhẹ ô nhận khi bé thả sai chữ — không mất gì, chỉ báo thử lại.
private struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 8
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(
            translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}
