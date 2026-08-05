# VocabularyContent

**Mục đích:** Nguồn dữ liệu tĩnh cho các chủ đề + thẻ từ vựng v1 (Animals, Colors).
**Loại:** Static data (enum + static let/func)
**Phụ thuộc:** dùng bởi `VocabularyHomeView` (danh sách chủ đề), `FlashcardDeckView`/`MatchingGameView` (thẻ theo chủ đề, qua `cards(for:)`).
**Trạng thái:** ☐ Chưa code · ☐ Đang code · ☐ Xong
**Ghi chú:** File hay sửa nhất khi thêm nội dung — chỉ cần append vào mảng, không cần build-system ceremony. v2 sẽ chuyển sang JSON (xem plan §4) mà không đổi chỗ gọi.

```swift
enum VocabularyContent {
    static let categories: [VocabularyCategory] = [
        VocabularyCategory(id: "animals", title: "Animals", symbolName: "pawprint.fill", colorName: "categoryAnimals"),
        VocabularyCategory(id: "colors", title: "Colors", symbolName: "paintpalette.fill", colorName: "categoryColors"),
    ]

    static let cards: [VocabularyCard] = [
        VocabularyCard(id: "animal_dog", word: "Dog", emoji: "🐶", symbolName: "dog.fill", imageName: nil, categoryId: "animals"),
        // ... 7 animal khác, 8 color
    ]

    static func cards(for categoryId: String) -> [VocabularyCard] {
        cards.filter { $0.categoryId == categoryId }
    }
}
```
