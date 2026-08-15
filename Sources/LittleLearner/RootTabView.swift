import SwiftUI

struct RootTabView: View {
    @State private var storyPath = NavigationPath()

    var body: some View {
        TabView {
            NavigationStack {
                VocabularyHomeView()
            }
            .tabItem { Label("Học", systemImage: "book.fill") }

            NavigationStack {
                GamesHomeView()
            }
            .tabItem { Label("Chơi", systemImage: "gamecontroller.fill") }

            NavigationStack(path: $storyPath) {
                StoryListView(path: $storyPath)
            }
            .tabItem { Label("Truyện", systemImage: "book.closed.fill") }
        }
    }
}
