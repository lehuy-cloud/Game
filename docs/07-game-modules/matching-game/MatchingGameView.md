# MatchingGameView

**Mục đích:** Game trí nhớ "lật thẻ tìm cặp" — chọn 1 chủ đề từ vựng, lật 2 thẻ mỗi lượt để tìm cặp giống nhau.
**Loại:** View
**Phụ thuộc:** nhận `categoryId`, đọc `VocabularyContent.cards(for:)` để dựng `[MatchTile]`; gọi `SpeechService.shared.speak(...)` khi lật thẻ; gọi `progressStore.addStar(for:)` khi tìm đúng cặp; dựng từ `RewardStarsView` (màn thắng).
**Trạng thái:** ☐ Chưa code · ☐ Đang code · ☐ Xong
**Ghi chú:** Xem luồng chi tiết ở plan §8. Điểm cần cẩn thận: guard clause chặn chạm tile thứ 3 khi đang có 2 tile lật, và so khớp theo `card.id` (không phải `tile.id`, vì mỗi cặp có 2 `MatchTile.id` khác nhau).

```swift
@State private var tiles: [MatchTile] = []
@State private var faceUpIndices: [Int] = []
```

Luồng: `buildBoard()` (4 thẻ × 2 = 8 tile, xáo trộn) → chạm tile → lật + đọc từ → đủ 2 tile lật → `Task.sleep` ngắn → so khớp `card.id` → đúng: matched + cộng sao; sai: lật úp lại → thắng khi `tiles.allSatisfy(\.isMatched)`.
