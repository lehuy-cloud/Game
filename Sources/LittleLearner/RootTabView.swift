import SwiftUI

struct RootTabView: View {
    @State private var storyPath = NavigationPath()

    var body: some View {
        TabView {
            NavigationStack {
                VocabularyHomeView()
            }
            .tabItem { Label("Vocabulary", systemImage: "textformat.abc") }

            NavigationStack {
                GamesHomeView()
            }
            .tabItem { Label("Games", systemImage: "puzzlepiece.fill") }

            NavigationStack {
                StarsSummaryView()
            }
            .tabItem { Label("Stars", systemImage: "star.fill") }

            NavigationStack(path: $storyPath) {
                StoryListView(path: $storyPath)
            }
            .tabItem { Label("Truyện", systemImage: "book.fill") }
        }
    }
}
