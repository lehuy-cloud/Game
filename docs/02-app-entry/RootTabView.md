# RootTabView

**Mục đích:** Khung điều hướng chính sau khi bé đã chọn nhân vật — `TabView` 3 tab: Vocabulary, Games, Stars, mỗi tab có `NavigationStack` riêng.
**Loại:** View (navigation shell)
**Phụ thuộc:** chứa `VocabularyHomeView`, `GamesHomeView`, `StarsSummaryView`; kế thừa `.tint()` đã áp từ `LittleLearnerApp`.
**Trạng thái:** ☐ Chưa code · ☐ Đang code · ☐ Xong
**Ghi chú:** Phase 1 dựng 3 tab với `Text` placeholder trước; Phase 3–5 mới nối view thật vào từng tab.

```swift
struct RootTabView: View {
    var body: some View {
        TabView {
            NavigationStack { VocabularyHomeView() }
                .tabItem { Label("Vocabulary", systemImage: "textformat.abc") }
            NavigationStack { GamesHomeView() }
                .tabItem { Label("Games", systemImage: "puzzlepiece.fill") }
            NavigationStack { StarsSummaryView() }
                .tabItem { Label("Stars", systemImage: "star.fill") }
        }
    }
}
```
