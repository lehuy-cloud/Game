import SwiftUI

struct StarsSummaryView: View {
    @Environment(ProgressStore.self) private var progressStore
    @State private var isChoosingCharacter = false

    var body: some View {
        List {
            Section("Stars by Category") {
                ForEach(VocabularyContent.categories) { category in
                    HStack {
                        Text(category.title)
                        Spacer()
                        RewardStarsView(count: progressStore.starsByCategory[category.id, default: 0])
                    }
                }
            }

            Section {
                Button("Change Character") {
                    isChoosingCharacter = true
                }
                .buttonStyle(.big)
            }
        }
        .navigationTitle("Stars")
        .themedBackground()
        .sheet(isPresented: $isChoosingCharacter) {
            CharacterSelectionView()
        }
    }
}
