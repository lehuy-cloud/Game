import SwiftUI

/// LỖI ĐÃ SỬA: MainTabBar trước đây nằm trong VStack BAO NGOÀI TabView, nên nó
/// hiện trên MỌI màn — kể cả màn đọc truyện và màn chơi game đã push lên.
/// `.toolbar(.hidden, for: .tabBar)` không có tác dụng vì đây là thanh tự vẽ,
/// không phải tab bar hệ thống.
///
/// Cách sửa: thanh tab thuộc về 3 màn GỐC. Mỗi màn gốc tự gắn nó qua
/// `.mainTabBar()`; màn push lên phủ kín nên thanh tự biến mất.
@Observable final class TabRouter {
    var tab: RootTabView.Tab = .hoc
}

struct RootTabView: View {
    enum Tab: Hashable { case hoc, choi, truyen }

    @State private var router = TabRouter()
    @State private var storyPath = NavigationPath()

    static let items: [MainTabBar<Tab>.Item] = [
        .init(tab: .hoc, title: "Học"),
        .init(tab: .choi, title: "Chơi"),
        .init(tab: .truyen, title: "Truyện")
    ]

    var body: some View {
        TabView(selection: Binding(get: { router.tab }, set: { router.tab = $0 })) {
            NavigationStack { VocabularyHomeView() }
                .toolbar(.hidden, for: .tabBar)
                .tag(Tab.hoc)

            NavigationStack { GamesHomeView() }
                .toolbar(.hidden, for: .tabBar)
                .tag(Tab.choi)

            NavigationStack(path: $storyPath) { StoryListView(path: $storyPath) }
                .toolbar(.hidden, for: .tabBar)
                .tag(Tab.truyen)
        }
        .toolbar(.hidden, for: .tabBar)
        .environment(router)
        .organicBackground()
    }
}

extension View {
    /// Gắn thanh Học·Chơi·Truyện lên trên một MÀN GỐC. Không dùng ở màn con.
    func mainTabBar(_ router: TabRouter) -> some View {
        VStack(spacing: 0) {
            MainTabBar(selection: Binding(get: { router.tab }, set: { router.tab = $0 }),
                       items: RootTabView.items)
                .padding(.top, 12)
            self
        }
    }
}
