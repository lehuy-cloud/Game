# ProfileStore

**Mục đích:** Lưu nhân vật mà bé đã chọn, persist qua `UserDefaults` để nhớ giữa các lần mở app.
**Loại:** Store (`@Observable`)
**Phụ thuộc:** đọc `CharacterContent.all` để tra `selectedCharacter` từ `selectedCharacterId`; được inject vào môi trường từ `LittleLearnerApp`; đọc bởi `LittleLearnerApp` (chọn root view + tint màu), `ThemedBackground`, `CharacterSelectionView`.
**Trạng thái:** ☐ Chưa code · ☐ Đang code · ☐ Xong
**Ghi chú:** Store đơn giản nhất trong app (chỉ lưu 1 chuỗi) — làm mẫu ở Phase 2 trước khi áp dụng lại pattern này (phức tạp hơn) cho `ProgressStore`.

```swift
@Observable
final class ProfileStore {
    private let key = "selectedCharacterId"

    var selectedCharacterId: String? {
        didSet { UserDefaults.standard.set(selectedCharacterId, forKey: key) }
    }

    var selectedCharacter: CharacterAvatar? {
        CharacterContent.all.first { $0.id == selectedCharacterId }
    }

    init() {
        selectedCharacterId = UserDefaults.standard.string(forKey: key)
    }
}
```
