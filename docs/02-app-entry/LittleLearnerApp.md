# LittleLearnerApp

**Mục đích:** Điểm vào (`@main`) của app; quyết định hiển thị `CharacterSelectionView` (chưa chọn nhân vật) hay `RootTabView` (đã chọn), khởi tạo 2 store dùng chung và inject vào môi trường.
**Loại:** App entry (`App` protocol)
**Phụ thuộc:** tạo `ProgressStore`, `ProfileStore` (inject qua `.environment`); đọc `profileStore.selectedCharacter` để quyết định view gốc; gọi `SpeechService.shared.configureAudioSession()` trong `.onAppear`; dùng `Color(hex:)` để áp `.tint()`.
**Trạng thái:** ☐ Chưa code · ☐ Đang code · ☐ Xong
**Ghi chú:**

```swift
@main
struct LittleLearnerApp: App {
    @State private var progressStore = ProgressStore()
    @State private var profileStore = ProfileStore()

    var body: some Scene {
        WindowGroup {
            Group {
                if let character = profileStore.selectedCharacter {
                    RootTabView()
                        .tint(Color(hex: character.primaryHex))
                } else {
                    CharacterSelectionView()
                }
            }
            .environment(progressStore)
            .environment(profileStore)
            .preferredColorScheme(.light)
            .onAppear { SpeechService.shared.configureAudioSession() }
        }
    }
}
```
