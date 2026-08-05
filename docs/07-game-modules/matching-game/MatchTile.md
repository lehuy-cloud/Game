# MatchTile

**Mục đích:** Struct trạng thái 1 ô trong bàn chơi Matching Pairs (bọc 1 `VocabularyCard` + trạng thái lật/matched).
**Loại:** Model (chỉ dùng trong game, không phải nội dung tĩnh)
**Phụ thuộc:** bọc `VocabularyCard`; dùng bởi `MatchingGameView`.
**Trạng thái:** ☐ Chưa code · ☐ Đang code · ☐ Xong
**Ghi chú:**

```swift
struct MatchTile: Identifiable {
    let id: UUID = UUID()
    let card: VocabularyCard
    var isFaceUp = false
    var isMatched = false
}
```
