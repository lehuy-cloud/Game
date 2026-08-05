import SwiftUI

struct RootTabView: View {
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
        }
    }
}
