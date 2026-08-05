# ProgressStore

**Mục đích:** Lưu số sao bé đạt được theo từng chủ đề, persist qua `UserDefaults`.
**Loại:** Store (`@Observable`)
**Phụ thuộc:** ghi bởi `MatchingGameView` (`addStar(for:)` khi tìm đúng cặp); đọc bởi `StarsSummaryView`; inject vào môi trường từ `LittleLearnerApp`.
**Trạng thái:** ☐ Chưa code · ☐ Đang code · ☐ Xong
**Ghi chú:** Phức tạp hơn `ProfileStore` một chút (dictionary thay vì 1 chuỗi) — dùng lại đúng pattern `@Observable` + `UserDefaults` đã học ở Phase 2.

```swift
@Observable
final class ProgressStore {
    private let defaultsKey = "starsByCategory"

    var starsByCategory: [String: Int] = [:] {
        didSet { persist() }
    }

    init() { load() }

    func addStar(for categoryId: String) {
        starsByCategory[categoryId, default: 0] += 1
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(starsByCategory) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey),
              let decoded = try? JSONDecoder().decode([String: Int].self, from: data)
        else { return }
        starsByCategory = decoded
    }
}
```
