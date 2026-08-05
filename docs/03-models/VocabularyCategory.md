# VocabularyCategory

**Mục đích:** Struct dữ liệu mô tả 1 chủ đề từ vựng (Animals, Colors...), dùng làm mục trong lưới chủ đề.
**Loại:** Model
**Phụ thuộc:** dùng bởi `VocabularyContent` (nguồn dữ liệu), `VocabularyHomeView` (lưới chủ đề để chọn).
**Trạng thái:** ☐ Chưa code · ☐ Đang code · ☐ Xong
**Ghi chú:**

```swift
struct VocabularyCategory: Identifiable, Codable, Hashable {
    let id: String          // "animals"
    let title: String       // "Animals"
    let symbolName: String  // "pawprint.fill" — icon cho ô chủ đề
    let colorHex: String    // "#FF9F43" — dùng Color+Hex, nhất quán với CharacterAvatar (không dùng Asset Catalog)
}
```
