# CharacterSelectionView

**Mục đích:** Màn hình cho bé chọn 1 trong 5 nhân vật; hiển thị khi chưa có nhân vật nào được chọn, và có thể mở lại dạng `.sheet` từ Stars tab để đổi nhân vật.
**Loại:** View
**Phụ thuộc:** đọc `CharacterContent.all`; ghi `profileStore.selectedCharacterId` (qua `@Environment(ProfileStore.self)`); gọi `SpeechService` để phát âm thanh vui khi chọn; dựng từ nhiều `CharacterCardView`.
**Trạng thái:** ☐ Chưa code · ☐ Đang code · ☐ Xong
**Ghi chú:** Layout `LazyVGrid` 5 thẻ nhân vật, mỗi thẻ to, dễ chạm cho tay bé.

Luồng: chạm 1 thẻ → `profileStore.selectedCharacterId = character.id` → `LittleLearnerApp` tự chuyển sang `RootTabView` (vì đọc `selectedCharacter` qua `@Observable`).
