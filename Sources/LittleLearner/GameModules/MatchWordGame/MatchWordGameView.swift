import SwiftUI

/// Ghép chữ với hình — ba ảnh, ba thẻ chữ (chữ HOA). Bé kéo thẻ chữ lên ảnh
/// đúng để thả vào ô nhận; chạm thẻ chữ rồi chạm ảnh (không kéo) cũng ăn,
/// vì tay bé kéo không phải lúc nào cũng chính xác.
struct MatchWordGameView: View {
    private static let totalQuestions = 8
    private static let progressKey = "game_matchword"
    private static let cardsPerQuestion = 3
    private static let dragSpace = "matchWordSpace"

    @Environment(ProgressStore.self) private var progressStore
    @Environment(ProfileStore.self) private var profileStore
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss

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

    var body: some View {
        VStack(spacing: 14) {
            header
            progress
            if let question = currentQuestion {
                content(for: question)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 26)
        .organicBackground()
        .gameContentWidth()
        .navigationBarBackButtonHidden()
        .onAppear { if questions.isEmpty { buildRound() } }
        .task {
            try? await Task.sleep(for: .seconds(1.5))
            guard let q = currentQuestion, let card = q.cards.first else { return }
            draggingCardId = card.id
            dragTranslation = CGSize(width: 30, height: -160)
            try? await Task.sleep(for: .seconds(1.5))
            if let ownFrame = dropZoneFrames[card.id] {
                attemptDrop(card, at: CGPoint(x: ownFrame.midX, y: ownFrame.midY), question: q)
            }
            draggingCardId = nil
            dragTranslation = .zero
        }
        .overlay {
            if isRoundComplete {
                RoundCompleteSheetView(correctCount: correctCount, totalCount: Self.totalQuestions,
                                        buddyEmoji: buddyEmoji, playAgain: buildRound, goHome: { dismiss() })
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: isRoundComplete)
    }

    // MARK: - Chrome

    private var header: some View {
        HStack(spacing: 10) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left").font(.system(size: 17, weight: .bold))
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Palette.surface))
                    .foregroundStyle(Palette.ink)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text("Ghép chữ với hình").font(.display(17))
                Text("Câu \(currentIndex + 1)/\(Self.totalQuestions) · \(correctCount) đúng")
                    .font(.body(11.5)).foregroundStyle(Palette.ink.opacity(0.5))
            }
            Spacer()
        }
    }

    private var progress: some View {
        HStack(spacing: 6) {
            ForEach(0..<Self.totalQuestions, id: \.self) { i in
                Capsule()
                    .fill(i <= currentIndex ? theme.base : Palette.ink.opacity(0.12))
                    .frame(height: 7)
            }
        }
        .animation(.easeOut(duration: 0.3), value: currentIndex)
    }

    private func coach(hasSelection: Bool) -> some View {
        HStack(spacing: 10) {
            Text(buddyEmoji).font(.system(size: 19))
                .frame(width: 36, height: 36)
                .background(Circle().fill(Palette.onAccent))
            Text(hasSelection ? "Giờ chạm vào đúng ảnh nhé" : "Kéo hoặc chạm vào một thẻ chữ")
                .font(.body(14, weight: .semibold))
                .foregroundStyle(Palette.ink.opacity(0.62))
        }
    }

    // MARK: - Content

    private func content(for question: Question) -> some View {
        let isComplete = matchedIds.count == question.cards.count
        return VStack(spacing: 22) {
            if isComplete {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Palette.onAccent)
                        .frame(width: 68, height: 68)
                        .background(Circle().fill(Palette.sage))
                    Text("Ghép đúng hết!").font(.display(26))
                }
                .padding(.top, 6)
            }

            HStack(spacing: 14) {
                ForEach(question.cards) { card in
                    imageDropTile(card, question: question)
                }
            }

            if isComplete {
                Button("Câu tiếp theo ▸", action: advance)
                    .buttonStyle(PillButtonStyle(theme: theme))
            } else {
                wordTray(for: question)
                coach(hasSelection: selectedWordId != nil)
            }
        }
        .coordinateSpace(name: Self.dragSpace)
        .onPreferenceChange(DropZoneFrameKey.self) { dropZoneFrames = $0 }
        .animation(.easeOut(duration: 0.25), value: matchedIds)
    }

    @ViewBuilder
    private func imageView(_ card: VocabularyCard) -> some View {
        if let imageName = card.imageName {
            Image(imageName).resizable().scaledToFit().washed()
        } else {
            Text(card.emoji).font(.system(size: 34))
        }
    }

    private func imageDropTile(_ card: VocabularyCard, question: Question) -> some View {
        let isMatched = matchedIds.contains(card.id)
        let isTargetable = selectedWordId != nil && !isMatched
        return VStack(spacing: 8) {
            imageView(card).frame(width: 62, height: 62)
            Group {
                if isMatched {
                    Text(card.word.uppercased())
                        .font(.display(15))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background {
                            RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Palette.sageTint)
                            RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Palette.sage, lineWidth: 2.5)
                        }
                } else {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(isTargetable ? Palette.sage : theme.tint,
                                      style: StrokeStyle(lineWidth: 2.5, dash: isTargetable ? [] : [5, 4]))
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(isTargetable ? Palette.sageTint.opacity(0.5) : Palette.surfaceAlt))
                        .frame(height: 40)
                }
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: DesignTokens.radiusLg, style: .continuous).fill(Palette.surface)
            GeometryReader { geo in
                Color.clear.preference(key: DropZoneFrameKey.self, value: [card.id: geo.frame(in: .named(Self.dragSpace))])
            }
        }
        .shadow(color: Color(hex: "#2E2B25").opacity(0.1), radius: 6, y: 3)
        .modifier(ShakeEffect(animatableData: shakingCardId == card.id ? shakeToken : 0))
        .contentShape(Rectangle())
        .onTapGesture { handleImageTap(card, question: question) }
    }

    private func wordTray(for question: Question) -> some View {
        HStack(spacing: 12) {
            ForEach(question.wordOrder.filter { !matchedIds.contains($0.id) }) { card in
                wordChip(card, question: question)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 80)
    }

    private func wordChip(_ card: VocabularyCard, question: Question) -> some View {
        let isSelected = selectedWordId == card.id
        let isDragging = draggingCardId == card.id
        let isLifted = isSelected || isDragging
        return Text(card.word.uppercased())
            .font(.display(19))
            .foregroundStyle(isLifted ? Palette.onAccent : Palette.ink)
            .frame(minWidth: 96, minHeight: 64)
            .padding(.horizontal, 14)
            .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(isLifted ? theme.base : Palette.surface))
            .shadow(color: Color(hex: "#2E2B25").opacity(isLifted ? 0.22 : 0.1), radius: isLifted ? 12 : 6, y: 4)
            .scaleEffect(isDragging ? 1.1 : (isSelected ? 1.06 : 1))
            .rotationEffect(.degrees(isDragging ? -4 : 0))
            .offset(isDragging ? dragTranslation : .zero)
            .contentShape(RoundedRectangle(cornerRadius: 18))
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
        guard let target = dropZoneFrames.first(where: { !matchedIds.contains($0.key) && $0.value.contains(location) }) else {
            return
        }
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
