# VocabularyCard

**Mục đích:** Struct dữ liệu mô tả 1 thẻ từ vựng (1 từ tiếng Anh + hình minh hoạ).
**Loại:** Model
**Phụ thuộc:** dùng bởi `VocabularyContent` (nguồn dữ liệu), `FlashcardView`/`FlashcardDeckView` (hiển thị), `MatchTile` (bọc trong game Matching Pairs).
**Trạng thái:** ☐ Chưa code · ☐ Đang code · ☐ Xong
**Ghi chú:** `id` phải ổn định và duy nhất — dùng làm khoá so khớp cặp trong game.

```swift
struct VocabularyCard: Identifiable, Codable, Hashable {
    let id: String            // "animal_dog" — dùng làm khoá ghép cặp trong game matching
    let word: String          // "Dog"
    let emoji: String         // "🐶"
    let symbolName: String?   // "dog.fill" — fallback SF Symbol
    let imageName: String?    // nil ở v1, sau này trỏ vào ảnh trong Assets.xcassets
    let categoryId: String    // "animals"
}
```
