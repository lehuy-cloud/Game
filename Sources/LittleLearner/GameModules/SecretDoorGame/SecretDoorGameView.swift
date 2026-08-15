import SwiftUI

/// Ô cửa bí mật — bé nhìn một góc ảnh phóng to qua "ô cửa" tròn rồi đoán con
/// vật là gì trong ba lựa chọn. Không cần asset mới — độ khó đến từ mức
/// phóng to `.scaleEffect(3)` trên chính ảnh gốc (ảnh trong Assets.xcassets
/// nền trắng đặc nên không dùng được bóng đổ).
struct SecretDoorGameView: View {
    private static let totalQuestions = 8
    private static let progressKey = "game_secretdoor"
    // Ảnh trong Assets.xcassets là icon phẳng với nhiều khoảng trắng quanh
    // con vật (không tràn viền như minh hoạ trong design doc), nên phóng to
    // 3× lệch tâm dễ rơi vào vùng trắng. Phóng vừa phải quanh tâm để vẫn
    // thấy được con vật, chỉ to hơn bình thường.
    private static let peepholeZoom: CGFloat = 1.7

    @Environment(ProgressStore.self) private var progressStore
    @Environment(ProfileStore.self) private var profileStore
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss

    @State private var questions: [Question] = []
    @State private var currentIndex = 0
    @State private var selectedId: String?
    @State private var wrongIds: Set<String> = []
    @State private var correctCount = 0
    @State private var shakeToken: CGFloat = 0
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
                Text("Ô cửa bí mật").font(.display(17))
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
            Text("Nhìn kỹ ô cửa nhé")
                .font(.body(14, weight: .semibold))
                .foregroundStyle(Palette.ink.opacity(0.62))
        }
    }

    // MARK: - Content

    private func content(for question: Question) -> some View {
        VStack(spacing: 22) {
            peephole(for: question)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 11), count: 3), spacing: 11) {
                ForEach(question.options) { option in
                    optionTile(option, question: question)
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
    private func peephole(for question: Question) -> some View {
        if selectedId != nil {
            // Đoán đúng: ô cửa mở rộng thành ảnh đầy đủ.
            VStack(spacing: 4) {
                imageView(question.answer).frame(width: 150, height: 150)
                Text(question.answer.word).font(.display(30))
                Text(question.answer.translation).font(.body(13)).foregroundStyle(Palette.ink.opacity(0.55))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background {
                RoundedRectangle(cornerRadius: DesignTokens.radiusLg, style: .continuous)
                    .fill(Palette.sageTint)
                RoundedRectangle(cornerRadius: DesignTokens.radiusLg, style: .continuous)
                    .strokeBorder(Palette.sage, lineWidth: 3)
            }
            .overlay(alignment: .topTrailing) {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .font(.system(size: 22))
                    .padding(14)
            }
        } else {
            VStack(spacing: 12) {
                ZStack {
                    Circle().fill(Palette.surfaceAlt)
                    imageView(question.answer)
                        .scaleEffect(Self.peepholeZoom)
                        .clipShape(Circle())
                    Circle().strokeBorder(theme.tint, lineWidth: 4)
                }
                .frame(width: 160, height: 160)
                .modifier(ShakeEffect(animatableData: shakeToken))
                Text("Ô cửa này là con gì?")
                    .font(.body(14.5, weight: .semibold))
                    .foregroundStyle(Palette.ink.opacity(0.62))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(RoundedRectangle(cornerRadius: DesignTokens.radiusLg, style: .continuous).fill(Palette.surface))
        }
    }

    @ViewBuilder
    private func imageView(_ card: VocabularyCard) -> some View {
        if let imageName = card.imageName {
            Image(imageName).resizable().scaledToFill()
        } else {
            Text(card.emoji).font(.system(size: 60))
        }
    }

    private func optionTile(_ option: VocabularyCard, question: Question) -> some View {
        let isCorrectSelected = selectedId == option.id
        let isWrong = wrongIds.contains(option.id)
        return imageView(option)
            .padding(12)
            .aspectRatio(1, contentMode: .fit)
            .background {
                RoundedRectangle(cornerRadius: DesignTokens.radiusLg, style: .continuous)
                    .fill(isCorrectSelected ? Palette.sageTint : Palette.surface)
                if isCorrectSelected {
                    RoundedRectangle(cornerRadius: DesignTokens.radiusLg, style: .continuous)
                        .strokeBorder(Palette.sage, lineWidth: 3)
                }
            }
            .opacity(isWrong ? 0.35 : 1)
            .contentShape(RoundedRectangle(cornerRadius: DesignTokens.radiusLg))
            .onTapGesture { handleTap(option, question: question) }
            .animation(.easeOut(duration: 0.2), value: selectedId)
            .animation(.easeOut(duration: 0.2), value: wrongIds)
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
        wrongIds = []
        correctCount = 0
        isRoundComplete = false
    }

    private func handleTap(_ option: VocabularyCard, question: Question) {
        guard selectedId == nil, !wrongIds.contains(option.id) else { return }
        if option.id == question.answer.id {
            selectedId = option.id
            correctCount += 1
            progressStore.addStar(for: Self.progressKey)
            SpeechService.shared.speak(question.answer.word)
        } else {
            wrongIds.insert(option.id)
            withAnimation(.default) { shakeToken += 1 }
        }
    }

    private func advance() {
        if currentIndex + 1 < questions.count {
            currentIndex += 1
            selectedId = nil
            wrongIds = []
        } else {
            isRoundComplete = true
        }
    }
}

/// Hiệu ứng lắc nhẹ ô cửa khi bé đoán sai — không mất điểm, chỉ báo hiệu để thử lại.
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
