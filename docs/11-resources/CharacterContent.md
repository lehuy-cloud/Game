# CharacterContent

**Mục đích:** Nguồn dữ liệu tĩnh cho 5 nhân vật v1.
**Loại:** Static data (enum + static let)
**Phụ thuộc:** dùng bởi `ProfileStore` (tra cứu theo id), `CharacterSelectionView` (hiển thị danh sách).
**Trạng thái:** ☐ Chưa code · ☐ Đang code · ☐ Xong
**Ghi chú:** Thêm/sửa/bớt nhân vật sau này chỉ cần sửa mảng này — không đụng đến `CharacterSelectionView`/`ProfileStore`.

```swift
enum CharacterContent {
    static let all: [CharacterAvatar] = [
        CharacterAvatar(id: "elsa", name: "Elsa", emoji: "❄️", symbolName: "snowflake", imageName: nil, primaryHex: "#4FC3F7", secondaryHex: "#E1F5FE"),
        CharacterAvatar(id: "mermaid", name: "Mermaid", emoji: "🧜‍♀️", symbolName: nil, imageName: nil, primaryHex: "#26C6DA", secondaryHex: "#E0F7FA"),
        CharacterAvatar(id: "spiderman", name: "Spider Hero", emoji: "🕷️", symbolName: nil, imageName: nil, primaryHex: "#E53935", secondaryHex: "#E3F2FD"),
        CharacterAvatar(id: "dinosaur", name: "Dinosaur", emoji: "🦕", symbolName: nil, imageName: nil, primaryHex: "#66BB6A", secondaryHex: "#E8F5E9"),
        CharacterAvatar(id: "fairy", name: "Butterfly Fairy", emoji: "🦋", symbolName: nil, imageName: nil, primaryHex: "#AB47BC", secondaryHex: "#F3E5F5"),
    ]
}
```
