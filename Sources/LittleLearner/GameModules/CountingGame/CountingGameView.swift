import SwiftUI

/// Đếm cùng bé — cùng một ảnh con vật lặp lại 1–5 lần, bé chạm từng con để
/// đếm to (tuỳ chọn) rồi chọn số đúng trong ba số. Dùng bộ `VocabularyCategory
/// (id: "numbers")` mới thêm để đọc số và tên tiếng Anh khi trả lời đúng.
struct CountingGameView: View {
    private static let totalQuestions = 8
    private static let progressKey = "game_counting"
    private static let numberCards = VocabularyContent.cards(for: "numbers")

    @Environment(ProgressStore.self) private var progressStore
    @Environment(ProfileStore.self) private var profileStore
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isRegularWidth: Bool { horizontalSizeClass == .regular }

    @State private var questions: [Question] = []
    @State private var currentIndex = 0
    @State private var items: [DisplayItem] = []
    @State private var countedSoFar = 0
    @State private var selectedAnswer: Int?
    @State private var wrongChoices: Set<Int> = []
    @State private var correctCount = 0
    @State private var isRoundComplete = false

    private struct Question {
        let animal: VocabularyCard
        let count: Int
        let choices: [Int]
    }

    private struct DisplayItem: Identifiable {
        let id: Int
        var isCounted = false
    }

    private var currentQuestion: Question? {
        questions.indices.contains(currentIndex) ? questions[currentIndex] : nil
    }
    private var buddyEmoji: String { profileStore.selectedCharacter?.emoji ?? "🐝" }

    var body: some View {
        GameScreen(title: "Đếm cùng bé", index: currentIndex + 1, total: Self.totalQuestions,
                   correct: correctCount, hint: selectedAnswer == nil ? "Đếm từng bạn một nhé" : nil) {
            if let question = currentQuestion {
                if selectedAnswer != nil {
                    resultCard(for: question)
                } else {
                    VStack(spacing: 18) {
                        Text("Có mấy bạn ở đây?").font(.display(isRegularWidth ? 36 : 26))
                        countingCard(for: question)
                    }
                }
            }
        } answers: {
            if let question = currentQuestion {
                VStack(spacing: 18) {
                    HStack(spacing: isRegularWidth ? 18 : 12) {
                        ForEach(question.choices, id: \.self) { number in
                            numberTile(number, question: question)
                        }
                    }
                    if selectedAnswer != nil {
                        Button("Câu tiếp theo ▸", action: advance)
                            .buttonStyle(PillButtonStyle(theme: theme))
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
        } else {
            Text(card.emoji).font(.system(size: 40))
        }
    }

    /// Số cột cho lưới đếm — chọn thủ công để 4 con xếp 2×2 thay vì 3+1,
    /// và mọi số lượng đều nằm giữa khung thay vì dính lề trái.
    private func columnCount(for total: Int) -> Int {
        switch total {
        case 1: return 1
        case 2: return 2
        case 4: return 2
        default: return 3
        }
    }

    private func countingCard(for question: Question) -> some View {
        VStack(spacing: 14) {
            HStack(spacing: 0) {
                Spacer(minLength: 0)
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(isRegularWidth ? 130 : 90), spacing: isRegularWidth ? 16 : 10), count: columnCount(for: question.count)),
                          spacing: isRegularWidth ? 16 : 10) {
                    ForEach(items) { item in
                        itemTile(item, question: question)
                    }
                }
                Spacer(minLength: 0)
            }
            HStack(spacing: 8) {
                Image(systemName: "hand.tap.fill").font(.system(size: isRegularWidth ? 17 : 14))
                Text("Chạm để đếm").font(.body(isRegularWidth ? 15 : 12.5, weight: .bold))
            }
            .foregroundStyle(theme.deep)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(theme.tint, in: Capsule())
        }
        .padding(isRegularWidth ? 26 : 18)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: DesignTokens.radiusLg, style: .continuous).fill(Palette.surface))
        .shadow(color: Color(hex: "#2E2B25").opacity(0.1), radius: 8, y: 3)
    }

    private func itemTile(_ item: DisplayItem, question: Question) -> some View {
        ZStack(alignment: .topTrailing) {
            imageView(question.animal).frame(width: isRegularWidth ? 96 : 68, height: isRegularWidth ? 96 : 68)
            if item.isCounted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Palette.sage)
                    .background(Circle().fill(Palette.onAccent))
                    .offset(x: 4, y: -4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Palette.surfaceAlt))
        .contentShape(RoundedRectangle(cornerRadius: 16))
        .onTapGesture { handleItemTap(item.id) }
        .scaleEffect(item.isCounted ? 1.06 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: item.isCounted)
    }

    private func resultCard(for question: Question) -> some View {
        let numberCard = Self.numberCards[question.count - 1]
        return VStack(spacing: 16) {
            HStack(spacing: 8) {
                ForEach(items) { _ in
                    imageView(question.animal).frame(width: isRegularWidth ? 72 : 54, height: isRegularWidth ? 72 : 54)
                }
            }
            HStack(alignment: .lastTextBaseline, spacing: 14) {
                Text("\(question.count)").font(.display(isRegularWidth ? 84 : 64))
                VStack(alignment: .leading, spacing: 2) {
                    Text(numberCard.word).font(.display(isRegularWidth ? 34 : 26))
                    Text("\(numberCard.translation) \(question.animal.translation.lowercased())")
                        .font(.body(isRegularWidth ? 16 : 13)).foregroundStyle(Palette.ink.opacity(0.55))
                }
            }
            Button {
                SpeechService.shared.speak(numberCard.word)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "speaker.wave.2.fill").font(.system(size: 15))
                    Text("Nghe lại").font(.body(13, weight: .bold))
                    Image(systemName: "star.fill").foregroundStyle(.yellow).font(.system(size: 16))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .background(Palette.surface, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(isRegularWidth ? 26 : 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            RoundedRectangle(cornerRadius: DesignTokens.radiusLg, style: .continuous).fill(Palette.sageTint)
            RoundedRectangle(cornerRadius: DesignTokens.radiusLg, style: .continuous).strokeBorder(Palette.sage, lineWidth: 3)
        }
    }

    private func numberTile(_ number: Int, question: Question) -> some View {
        let isSelected = selectedAnswer == number
        let isWrong = wrongChoices.contains(number)
        return Text("\(number)")
            .font(.display(isRegularWidth ? 44 : 34))
            .frame(maxWidth: .infinity, minHeight: isRegularWidth ? 130 : DesignTokens.minTapTarget)
            .background {
                RoundedRectangle(cornerRadius: DesignTokens.radiusLg, style: .continuous)
                    .fill(isSelected ? Palette.sageTint : Palette.surface)
                if isSelected {
                    RoundedRectangle(cornerRadius: DesignTokens.radiusLg, style: .continuous)
                        .strokeBorder(Palette.sage, lineWidth: 3)
                }
            }
            .shadow(color: Color(hex: "#2E2B25").opacity(isSelected || isWrong ? 0 : 0.1), radius: 6, y: 3)
            .opacity(isWrong ? 0.35 : 1)
            .contentShape(RoundedRectangle(cornerRadius: DesignTokens.radiusLg))
            .onTapGesture { handleNumberTap(number, question: question) }
            .animation(.easeOut(duration: 0.2), value: selectedAnswer)
            .animation(.easeOut(duration: 0.2), value: wrongChoices)
    }

    // MARK: - Logic

    private func buildRound() {
        let animalPool = VocabularyContent.cards(for: "animals")
        questions = (0..<Self.totalQuestions).map { _ in
            let animal = animalPool.randomElement()!
            let count = Int.random(in: 1...5)
            var distractors: Set<Int> = []
            while distractors.count < 2 {
                let n = Int.random(in: 1...5)
                if n != count { distractors.insert(n) }
            }
            return Question(animal: animal, count: count, choices: ([count] + distractors).sorted())
        }
        currentIndex = 0
        correctCount = 0
        isRoundComplete = false
        setupCurrentQuestion()
    }

    private func setupCurrentQuestion() {
        guard let question = currentQuestion else { return }
        items = (0..<question.count).map { DisplayItem(id: $0) }
        countedSoFar = 0
        selectedAnswer = nil
        wrongChoices = []
    }

    private func handleItemTap(_ itemId: Int) {
        guard selectedAnswer == nil,
              let idx = items.firstIndex(where: { $0.id == itemId }),
              !items[idx].isCounted
        else { return }
        items[idx].isCounted = true
        countedSoFar += 1
        SpeechService.shared.speak(Self.numberCards[countedSoFar - 1].word)
    }

    private func handleNumberTap(_ number: Int, question: Question) {
        guard selectedAnswer == nil, !wrongChoices.contains(number) else { return }
        if number == question.count {
            selectedAnswer = number
            correctCount += 1
            progressStore.addStar(for: Self.progressKey)
            SpeechService.shared.speak(Self.numberCards[number - 1].word)
        } else {
            wrongChoices.insert(number)
        }
    }

    private func advance() {
        if currentIndex + 1 < questions.count {
            currentIndex += 1
            setupCurrentQuestion()
        } else {
            isRoundComplete = true
        }
    }
}
