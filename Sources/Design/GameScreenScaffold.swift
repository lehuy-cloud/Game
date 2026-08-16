import SwiftUI

// MARK: - Nguyên nhân lỗi trong 4 ảnh chụp iPad
//
// 1. Nội dung kẹt trong cột hẹp giữa màn, hai bên trắng
//    → do đặt .frame(width: 390) / .frame(maxWidth: 390) cứng, hoặc dùng
//      NavigationSplitView mặc định. Trên iPad phải để nội dung ăn hết bề rộng
//      và chỉ giới hạn bằng lề (padding), không giới hạn bằng width cố định.
//
// 2. Nửa dưới màn trống
//    → do VStack không có Spacer/maxHeight: .infinity, nên tự co lại quanh
//      nội dung. Vùng câu hỏi phải .frame(maxHeight: .infinity) để giãn ra.
//
// 3. Ô đáp án bé xíu (~72px) trên iPad
//    → do hardcode kích thước ô. Phải dùng LazyVGrid với số cột đổi theo
//      horizontalSizeClass, ô tự giãn theo cột.
//
// GameScreen bên dưới là khung dùng chung cho cả 4 trò, xử lý sẵn cả ba điều đó.

/// Khung chung cho mọi màn chơi: header + thanh tiến trình + vùng câu hỏi (giãn)
/// + hàng đáp án + dòng gợi ý. iPhone và iPad dùng chung, chỉ khác số cột và cỡ chữ.
struct GameScreen<Question: View, Answers: View>: View {
    let title: String
    let index: Int
    let total: Int
    let correct: Int
    var hint: String? = nil
    @ViewBuilder var question: () -> Question
    @ViewBuilder var answers: () -> Answers

    @Environment(\.horizontalSizeClass) private var hSize
    @Environment(\.dismiss) private var dismiss

    private var isPad: Bool { hSize == .regular }
    private var sidePadding: CGFloat { isPad ? 44 : 20 }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, sidePadding)
                .padding(.top, isPad ? 22 : 8)

            VStack(spacing: isPad ? 26 : 18) {
                // Vùng câu hỏi: GIÃN hết chỗ trống — đây là chỗ sửa lỗi "nửa dưới trắng".
                question()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                answers()
                    .frame(maxWidth: .infinity)

                if let hint {
                    Label(hint, systemImage: "lightbulb.fill")
                        .font(.body(isPad ? 19 : 14, weight: .semibold))
                        .padding(.horizontal, 24).padding(.vertical, isPad ? 16 : 12)
                        .background(Capsule().fill(Palette.surfaceAlt))
                }
            }
            .padding(.horizontal, sidePadding)
            .padding(.top, isPad ? 26 : 18)
            .padding(.bottom, isPad ? 44 : 28)
        }
        // KHÔNG đặt .frame(width:) ở đây. Đây là chỗ sửa lỗi "cột hẹp giữa màn".
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .organicBackground()
        .navigationBarBackButtonHidden()
    }

    private var header: some View {
        HStack(spacing: isPad ? 18 : 12) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: isPad ? 22 : 17, weight: .semibold))
                    .frame(width: isPad ? 56 : 44, height: isPad ? 56 : 44)
                    .background(Circle().fill(Palette.surface))
                    .foregroundStyle(Palette.ink)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.display(isPad ? 34 : 20))
                Text("Câu \(index) / \(total) · \(correct) đúng")
                    .font(.body(isPad ? 16 : 12))
                    .foregroundStyle(Palette.ink.opacity(0.58))
            }
            Spacer(minLength: 0)
            if isPad { progressBar.frame(width: 300) }
        }
        .overlay(alignment: .bottom) {
            if !isPad { progressBar.offset(y: 22) }
        }
    }

    private var progressBar: some View {
        GeometryReader { geo in
            let w = geo.size.width * CGFloat(index) / CGFloat(total)
            HStack(spacing: 6) {
                Capsule().fill(Palette.accentDeep).frame(width: max(9, w - 3))
                Capsule().fill(Palette.ink.opacity(0.12))
            }
        }
        .frame(height: isPad ? 9 : 7)
    }
}

/// Lưới đáp án tự đổi số cột theo thiết bị. Ô luôn vuông vắn và giãn theo cột,
/// không hardcode 72px như bản đang lỗi.
struct AnswerGrid<Item: Identifiable, Cell: View>: View {
    let items: [Item]
    var padColumns: Int = 4
    var phoneColumns: Int = 2
    var height: CGFloat? = nil
    @ViewBuilder var cell: (Item) -> Cell

    @Environment(\.horizontalSizeClass) private var hSize
    private var isPad: Bool { hSize == .regular }

    var body: some View {
        let count = isPad ? padColumns : phoneColumns
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: isPad ? 24 : 14), count: count),
            spacing: isPad ? 24 : 14
        ) {
            ForEach(items) { item in
                cell(item)
                    .frame(maxWidth: .infinity)
                    .frame(height: height ?? (isPad ? 250 : 150))
                    .background(
                        RoundedRectangle(cornerRadius: DesignTokens.radiusLg, style: .continuous)
                            .fill(Palette.surface)
                    )
                    .shadow(color: Palette.ink.opacity(0.10), radius: 14, y: 6)
            }
        }
    }
}

// MARK: - Ví dụ: Tìm bạn khác loài
//
// Lỗi thứ tư trong ảnh chụp: màn này hiện con cua chung với các số 5 / 1 / 4.
// Đó là lỗi dữ liệu — bộ câu hỏi trộn hai loại đáp án. Một câu phải cùng một
// loại: 4 con vật, trong đó 3 con cùng nhóm và 1 con khác nhóm.

struct OddOneQuestion: Identifiable {
    let id = UUID()
    let prompt: String          // "Ai không cùng nhóm?"
    let hint: String            // "Ba bạn sống dưới nước, một bạn thì không"
    let options: [AnimalCard]   // đúng 4 phần tử, CÙNG loại
    let oddIndex: Int

    /// Chặn dữ liệu sai ngay khi dựng câu hỏi.
    init(prompt: String, hint: String, options: [AnimalCard], oddIndex: Int) {
        precondition(options.count == 4, "Mỗi câu phải có đúng 4 đáp án")
        precondition(options.indices.contains(oddIndex), "oddIndex nằm ngoài danh sách")
        self.prompt = prompt; self.hint = hint
        self.options = options; self.oddIndex = oddIndex
    }
}

struct OddOneOutView: View {
    let question: OddOneQuestion
    let index: Int, total: Int, correct: Int
    var onPick: (Int) -> Void = { _ in }

    @Environment(\.horizontalSizeClass) private var hSize
    private var isPad: Bool { hSize == .regular }

    var body: some View {
        GameScreen(title: "Tìm bạn khác loài", index: index, total: total,
                   correct: correct, hint: question.hint) {
            Text(question.prompt)
                .font(.display(isPad ? 40 : 26))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, isPad ? 8 : 4)
        } answers: {
            AnswerGrid(items: Array(question.options.enumerated().map(IndexedAnimal.init)),
                       padColumns: 2, phoneColumns: 2,
                       height: isPad ? 300 : 160) { item in
                VStack(spacing: 12) {
                    Image(item.animal.imageName)
                        .resizable().scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    Text(item.animal.english).font(.body(isPad ? 20 : 15, weight: .bold))
                }
                .padding(isPad ? 28 : 16)
                .contentShape(Rectangle())
                .onTapGesture { onPick(item.offset) }
            }
        }
    }

    private struct IndexedAnimal: Identifiable {
        let offset: Int
        let animal: AnimalCard
        var id: Int { offset }
        init(_ pair: (offset: Int, element: AnimalCard)) {
            offset = pair.offset; animal = pair.element
        }
    }
}
