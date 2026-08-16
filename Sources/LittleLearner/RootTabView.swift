import SwiftUI

struct RootTabView: View {
    enum Tab: Hashable {
        case hoc, choi, truyen
    }

    @State private var selectedTab: Tab = .hoc
    @State private var storyPath = NavigationPath()

    private static let items: [MainTabBar<Tab>.Item] = [
        .init(tab: .hoc, title: "Học"),
        .init(tab: .choi, title: "Chơi"),
        .init(tab: .truyen, title: "Truyện")
    ]

    var body: some View {
        VStack(spacing: 0) {
            MainTabBar(selection: $selectedTab, items: Self.items)
                .padding(.top, DesignTokens.spacing)

            TabView(selection: $selectedTab) {
                NavigationStack {
                    VocabularyHomeView()
                }
                .toolbar(.hidden, for: .tabBar)
                .tag(Tab.hoc)

                NavigationStack {
                    GamesHomeView()
                }
                .toolbar(.hidden, for: .tabBar)
                .tag(Tab.choi)

                NavigationStack(path: $storyPath) {
                    StoryListView(path: $storyPath)
                }
                .toolbar(.hidden, for: .tabBar)
                .tag(Tab.truyen)
            }
            .toolbar(.hidden, for: .tabBar)
        }
        .organicBackground()
    }
}
