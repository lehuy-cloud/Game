# Phase 7 — Chế độ Truyện: Hoàng tử Tuyết và Những Người Bạn

**Trạng thái:** ☐ Chưa làm · ☐ Đang làm · ☐ Xong

## Mục tiêu
Một tab mới "Truyện" kể câu chuyện 5 chương bằng tiếng Việt (giọng đọc `vi-VN`), mỗi chương có vài trang truyện rồi đến một mini-game nhỏ gắn với tình tiết chương đó (trừ chương 5 là màn ăn mừng kết thúc). Mỗi chương giới thiệu 1-2 từ vựng tiếng Anh mới, được thêm thẳng vào `VocabularyContent` dưới category `"story"` nên tự động có flashcard + game Matching Pairs + dòng sao riêng mà không cần sửa 3 màn hình đó.

## File liên quan
- `../../Models/StoryChapter.md`, `../../Models/StoryPage.md`
- `../../11-resources/StoryContent.md`
- `../../07-game-modules/StoryModule/StoryHomeView.md`, `StoryChapterView.md`, `StoryCompletionOverlay.md`
- `../../07-game-modules/StoryModule/MiniGames/` (IceMeltGameView, LaughChaseGameView, LanternPathGameView, StormBattleGameView)
- `../../10-services/SpeechService.md` (tham số `language`)
- `../../08-progress/ProgressStore.md` (`completedStoryChapterIds`)
- `../../11-resources/VocabularyContent.md` (category `"story"`)
- `../../02-app-entry/RootTabView.md` (tab thứ 4 + `NavigationPath` riêng cho tab Truyện)

## Khái niệm học
`NavigationStack(path:)` + `.navigationDestination(for:)` với `NavigationPath` dùng chung để quay thẳng về danh sách chương từ 2 cấp điều hướng sâu hơn (đọc truyện → mini-game). `DragGesture(minimumDistance: 0)` cho thao tác chạm-giữ. Vòng lặp `Task` + `Task.sleep` để tạo chuyển động/đếm giờ không chặn UI (nối tiếp cách `MatchingGameView` đã dùng). Mở rộng `ProgressStore` với thuộc tính lưu trữ thứ hai. Mở rộng `SpeechService.speak` bằng tham số ngôn ngữ có giá trị mặc định để không phá vỡ các lời gọi cũ.

## Kiểm tra
- [ ] Tab "Truyện" hiển thị đủ 5 chương, chương 2-5 khoá ban đầu
- [ ] Đọc hết chương 1, bấm "Nghe" phát đúng giọng tiếng Việt
- [ ] Hoàn thành mini-game chương 1 → mở khoá chương 2, cộng 1 sao mục "story"
- [ ] Tắt/mở lại app — chương đã hoàn thành và sao vẫn được lưu
- [ ] Mục "Story Words" xuất hiện đúng trong tab Vocabulary (flashcard), tab Games (Matching Pairs), tab Stars
- [ ] Chương 5 không có mini-game, chỉ có màn ăn mừng kết thúc truyện
