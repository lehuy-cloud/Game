import SwiftUI

/// Nghe rồi chọn — bé nghe một từ tiếng Anh rồi chạm vào đúng ảnh.
///
/// LỖI ĐÃ SỬA (ảnh chụp iPad): màn iPad đang xếp DỌC như iPhone — loa nhỏ ở
/// giữa, ba ô đáp án là ba thanh ngang mỏng với ảnh tí hon, chừa một khoảng
/// trống lớn giữa màn. Thiết kế P10 cho iPad là hai cột: bảng câu hỏi 272pt
/// bên trái (loa 172pt + câu hỏi 30pt + gợi ý) và lưới đáp án 2×2 ảnh lớn
/// chiếm hết phần còn lại. Bản iPhone giữ nguyên kiểu thanh ngang.
struct ListenChooseGameView: View {
    private static let totalQuestions = 8
    private static let progressKey = "game_listen"

    @Environment(ProgressStore.self) private var progressStore
    @Environment(ProfileStore.self) private var profileStore
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isRegularWidth: Bool { horizontalSizeClass == .regular }
    /// iPad chơi 4 ảnh (lưới 2×2), iPhone 3 ảnh xếp dọc.
    private var optionCount: Int { isRegularWidth ? 4 : 3 }

    @State private var questions: [Question] = []
    @State private var currentIndex = 0
    @State private var selectedId: String?
    @State private var correctCount = 0
    @State private var shakeTokens: [String: CGFloat] = [:]
    @State private var isRoundComplete = false

    private struct Question {
        let answer: VocabularyCard
        let options: [VocabularyCard]
    }

    private var currentQuestion: Question? {
        questions.indices.contains(currentIndex) ? questions[currentIndex] : nil
    }
    private var buddyEmoji: String { profileStore.selectedCharacter?.emoji ?? "🐝" }

    var body: some View {
        GameScreen(title: "Nghe rồi chọn", index: currentIndex + 1, total: Self.totalQuestions,
                   correct: correctCount,
                   hint: (!isRegularWidth && selectedId == nil) ? "Nghe kỹ nhé bé" : nil) {
            if let question = currentQuestion {
                if isRegularWidth {
                    HStack(spacing: 28) {
                        questionPanel(question)
                        optionGrid(question)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    compactQuestion(question)
                }
            }
        } answers: {
            if !isRegularWidth, let question = currentQuestion {
                VStack(spacing: 13) {
                    ForEach(question.options) { option in
                        optionRow(option, question: question)
                    }
                    if selectedId != nil {
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

    // MARK: - iPad

    private func questionPanel(_ question: Question) -> some View {
        VStack(spacing: 26) {
            speakerButton(size: 172, glyph: 76)

            VStack(spacing: 12) {
                if selectedId == nil {
                    Text("Con nào là \(question.answer.word)?")
                        .font(.display(30))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Palette.ink)
                    Text("Chạm loa để nghe lại")
                        .font(.body(16))
                        .foregroundStyle(Palette.ink.opacity(0.55))
                } else {
                    Text("Đúng rồi!").font(.display(34))
                    Text(question.answer.translation)
                        .font(.body(18))
                        .foregroundStyle(Palette.ink.opacity(0.55))
                }
            }

            Spacer(minLength: 0)

            if selectedId == nil {
                Label("Nghe kỹ nhé bé", systemImage: "lightbulb.fill")
                    .font(.body(16, weight: .semibold))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(Palette.surfaceAlt))
            } else {
                Button("Câu tiếp theo ▸", action: advance)
                    .buttonStyle(PillButtonStyle(theme: theme))
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 36)
        .frame(width: 272)
        .frame(maxHeight: .infinity)
        .background(RoundedRectangle(cornerRadius: DesignTokens.radiusLg, style: .continuous).fill(Palette.surface))
        .shadow(color: Palette.ink.opacity(0.1), radius: 8, y: 4)
    }

    private func optionGrid(_ question: Question) -> some View {
        GeometryReader { proxy in
            let gap: CGFloat = 24
            let cellW = (proxy.size.width - gap) / 2
            let cellH = (proxy.size.height - gap) / 2
            let rows = stride(from: 0, to: question.options.count, by: 2).map {
                Array(question.options[$0 ..< min($0 + 2, question.options.count)])
            }
            VStack(spacing: gap) {
                ForEach(rows.indices, id: \.self) { r in
                    HStack(spacing: gap) {
                        ForEach(rows[r]) { option in
                            optionTile(option, question: question)
                                .frame(width: cellW, height: cellH)
                        }
                    }
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }

    private func optionTile(_ option: VocabularyCard, question: Question) -> some View {
        let isSelected = selectedId == option.id
        let isDimmed = selectedId != nil && !isSelected
        return VStack(spacing: 10) {
            imageView(option)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            if isSelected {
                Text(option.word).font(.display(24)).foregroundStyle(Palette.ink)
            }
        }
        .padding(26)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            RoundedRectangle(cornerRadius: DesignTokens.radiusLg, style: .continuous)
                .fill(isSelected ? Palette.sageTint : Palette.surface)
            if isSelected {
                RoundedRectangle(cornerRadius: DesignTokens.radiusLg, style: .continuous)
                    .strokeBorder(Palette.sage, lineWidth: 3)
            }
        }
        .shadow(color: Color(hex: "#2E2B25").opacity(isSelected ? 0 : 0.1), radius: 6, y: 3)
        .opacity(isDimmed ? 0.4 : 1)
        .contentShape(RoundedRectangle(cornerRadius: DesignTokens.radiusLg))
        .modifier(ShakeEffect(animatableData: shakeTokens[option.id] ?? 0))
        .onTapGesture { handleTap(option, question: question) }
        .animation(.easeOut(duration: 0.2), value: selectedId)
    }

    // MARK: - iPhone

    private func compactQuestion(_ question: Question) -> some View {
        VStack(spacing: 14) {
            speakerButton(size: 112, glyph: 38)
            if selectedId == nil {
                Text("Con nào là \(question.answer.word)?")
                    .font(.body(15, weight: .semibold))
                    .foregroundStyle(Palette.ink.opacity(0.62))
            } else {
                Text("Đúng rồi!").font(.display(26))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func speakerButton(size: CGFloat, glyph: CGFloat) -> some View {
        Button(action: speakCurrent) {
            ZStack {
                Circle().fill(theme.deep)
                Circle().strokeBorder(theme.tint, lineWidth: 3).padding(-6)
                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: glyph))
                    .foregroundStyle(Palette.onAccent)
            }
            .frame(width: size, height: size)
            .shadow(color: Palette.ink.opacity(0.15), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func imageView(_ card: VocabularyCard) -> some View {
        if let imageName = card.imageName {
            Image(imageName).resizable().scaledToFit().washed()
        } else {
            Text(card.emoji).font(.system(size: isRegularWidth ? 80 : 40))
        }
    }

    private func optionRow(_ option: VocabularyCard, question: Question) -> some View {
        let isSelected = selectedId == option.id
        let isDimmed = selectedId != nil && !isSelected
        return HStack(spacing: 16) {
            if isSelected {
                imageView(option).frame(width: 62, height: 62)
                VStack(alignment: .leading, spacing: 2) {
                    Text(option.word).font(.display(20))
                    Text(option.translation).font(.body(12)).foregroundStyle(Palette.ink.opacity(0.55))
                }
                Spacer(minLength: 0)
                Image(systemName: "star.fill").foregroundStyle(.yellow).font(.system(size: 22))
            } else {
                Spacer(minLength: 0)
                imageView(option).frame(width: 62, height: 62)
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, 18)
        .frame(minHeight: DesignTokens.minTapTarget)
        .background {
            RoundedRectangle(cornerRadius: DesignTokens.radiusLg, style: .continuous)
                .fill(isSelected ? Palette.sageTint : Palette.surface)
            if isSelected {
                RoundedRectangle(cornerRadius: DesignTokens.radiusLg, style: .continuous)
                    .strokeBorder(Palette.sage, lineWidth: 3)
            }
        }
        .shadow(color: Color(hex: "#2E2B25").opacity(isSelected ? 0 : 0.1), radius: 6, y: 3)
        .opacity(isDimmed ? 0.4 : 1)
        .contentShape(RoundedRectangle(cornerRadius: DesignTokens.radiusLg))
        .modifier(ShakeEffect(animatableData: shakeTokens[option.id] ?? 0))
        .onTapGesture { handleTap(option, question: question) }
        .animation(.easeOut(duration: 0.2), value: selectedId)
    }

    // MARK: - Logic

    private func buildRound() {
        let pool = VocabularyContent.cards(for: "animals")
        let picks = Array(pool.shuffled().prefix(Self.totalQuestions))
        questions = picks.map { answer in
            let distractors = Array(pool.filter { $0.id != answer.id }.shuffled().prefix(optionCount - 1))
            return Question(answer: answer, options: ([answer] + distractors).shuffled())
        }
        currentIndex = 0
        selectedId = nil
        correctCount = 0
        shakeTokens = [:]
        isRoundComplete = false
        speakCurrent()
    }

    private func speakCurrent() {
        guard let question = currentQuestion else { return }
        SpeechService.shared.speak(question.answer.word)
    }

    private func handleTap(_ option: VocabularyCard, question: Question) {
        guard selectedId == nil else { return }
        if option.id == question.answer.id {
            selectedId = option.id
            correctCount += 1
            progressStore.addStar(for: Self.progressKey)
            SpeechService.shared.speak(question.answer.word)
        } else {
            withAnimation(.default) { shakeTokens[option.id, default: 0] += 1 }
        }
    }

    private func advance() {
        if currentIndex + 1 < questions.count {
            currentIndex += 1
            selectedId = nil
            speakCurrent()
        } else {
            isRoundComplete = true
        }
    }
}

/// Hiệu ứng lắc nhẹ khi bé chạm sai — không mất điểm, chỉ báo hiệu để thử lại.
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
