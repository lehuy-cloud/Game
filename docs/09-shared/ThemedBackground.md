# ThemedBackground

**Mục đích:** `ViewModifier` vẽ nền gradient nhạt (`secondaryHex` → trắng) theo nhân vật đã chọn — cùng với `.tint()` ở `LittleLearnerApp`, tạo cảm giác "đổi toàn bộ giao diện" theo nhân vật.
**Loại:** ViewModifier
**Phụ thuộc:** đọc `@Environment(ProfileStore.self)`; dùng `Color+Hex`; expose qua `View` extension `.themedBackground()`.
**Trạng thái:** ☐ Chưa code · ☐ Đang code · ☐ Xong
**Ghi chú:** Áp dụng ở `VocabularyHomeView`, `GamesHomeView`, `StarsSummaryView` (các màn hình gốc của từng tab).

```swift
extension View {
    func themedBackground() -> some View {
        modifier(ThemedBackgroundModifier())
    }
}
```
