import SwiftUI

struct GamesHomeView: View {
    private let columns = [GridItem(.adaptive(minimum: 150))]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: DesignTokens.spacing) {
                ForEach(VocabularyContent.categories) { category in
                    NavigationLink {
                        LevelPickerView(categoryId: category.id)
                    } label: {
                        VStack(spacing: 8) {
                            if let imageName = category.imageName {
                                Image(imageName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 56, height: 56)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "square.grid.2x2.fill")
                                    .font(.system(size: 40))
                            }
                            Text("Matching: \(category.title)")
                                .font(.title3.bold())
                                .multilineTextAlignment(.center)
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
        .navigationTitle("Games")
        .themedBackground()
    }
}
