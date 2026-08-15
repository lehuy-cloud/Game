import SwiftUI

/// Nghe rồi chọn — bé nghe một từ tiếng Anh rồi chạm vào đúng ảnh trong ba
/// ảnh. Dùng chung `VocabularyContent`/`SpeechService`/`ProgressStore` như
/// Lật Hình, không cần dữ liệu hay dịch vụ mới.
struct ListenChooseGameView: View {
    private static let totalQuestions = 8
    private static let progressKey = "game_listen"

    @Environment(ProgressStore.self) private var progressStore
    @Environment(ProfileStore.self) private var profileStore
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss

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
                Text("Nghe rồi chọn").font(.display(17))
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

    private var coach: some View {
        HStack(spacing: 10) {
            Text(buddyEmoji).font(.system(size: 19))
                .frame(width: 36, height: 36)
                .background(Circle().fill(Palette.onAccent))
            Text("Nghe kỹ nhé bé")
                .font(.body(14, weight: .semibold))
                .foregroundStyle(Palette.ink.opacity(0.62))
        }
    }

    // MARK: - Content

    private func content(for question: Question) -> some View {
        VStack(spacing: 22) {
            VStack(spacing: 14) {
                Button(action: speakCurrent) {
                    ZStack {
                        Circle().fill(theme.base)
                        Circle().strokeBorder(theme.tint, lineWidth: 3).padding(-6)
                        Image(systemName: "speaker.wave.3.fill")
                            .font(.system(size: 38))
                            .foregroundStyle(Palette.onAccent)
                    }
                    .frame(width: 112, height: 112)
                    .shadow(color: Palette.ink.opacity(0.15), radius: 8, y: 4)
                }
                .buttonStyle(.plain)

                if selectedId == nil {
                    Text("Con nào là \(question.answer.word)?")
                        .font(.body(15, weight: .semibold))
                        .foregroundStyle(Palette.ink.opacity(0.62))
                } else {
                    Text("Đúng rồi!").font(.display(26))
                }
            }
            .padding(.top, 10)

            VStack(spacing: 13) {
                ForEach(question.options) { option in
                    optionRow(option, question: question)
                }
            }

            if selectedId != nil {
                Button("Câu tiếp theo ▸", action: advance)
                    .buttonStyle(PillButtonStyle(theme: theme))
            } else {
                coach
            }
        }
    }

    @ViewBuilder
    private func imageView(_ card: VocabularyCard) -> some View {
        if let imageName = card.imageName {
            Image(imageName).resizable().scaledToFit().washed()
        } else {
            Text(card.emoji).font(.system(size: 40))
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
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .font(.system(size: 22))
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
            let distractors = Array(pool.filter { $0.id != answer.id }.shuffled().prefix(2))
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
