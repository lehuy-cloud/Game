import SwiftUI

struct VocabularyHomeView: View {
    private let columns = [GridItem(.adaptive(minimum: 150))]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: DesignTokens.spacing) {
                ForEach(VocabularyContent.categories) { category in
                    NavigationLink {
                        FlashcardDeckView(categoryId: category.id)
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: category.symbolName)
                                .font(.system(size: 40))
                            Text(category.title)
                                .font(.title3.bold())
                        }
                        .frame(maxWidth: .infinity, minHeight: DesignTokens.minTapTarget)
                        .padding()
                        .background(Color(hex: category.colorHex), in: RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
                        .foregroundStyle(.white)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Vocabulary")
        .themedBackground()
    }
}
