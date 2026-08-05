# CharacterAvatar

**Mục đích:** Struct dữ liệu mô tả 1 nhân vật mà bé có thể chọn (tên, emoji, màu theme).
**Loại:** Model
**Phụ thuộc:** dùng bởi `CharacterContent` (nguồn dữ liệu), `ProfileStore` (tra cứu theo id), `CharacterSelectionView`/`CharacterCardView` (hiển thị), `Color+Hex` (chuyển `primaryHex`/`secondaryHex` thành `Color`).
**Trạng thái:** ☐ Chưa code · ☐ Đang code · ☐ Xong
**Ghi chú:** `symbolName`/`imageName` để `nil` ở v1 (dùng emoji); để sẵn chỗ thay hình thật sau.

```swift
struct CharacterAvatar: Identifiable, Codable, Hashable {
    let id: String            // "elsa"
    let name: String          // "Elsa"
    let emoji: String         // "❄️"
    let symbolName: String?   // SF Symbol fallback, có thể nil
    let imageName: String?    // nil ở v1, sau này trỏ vào ảnh thật trong Assets.xcassets
    let primaryHex: String    // "#4FC3F7" — màu chủ đạo, dùng cho .tint() toàn app
    let secondaryHex: String  // "#E1F5FE" — màu nền nhạt cho gradient nền
}
```
