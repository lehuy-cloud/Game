# Phase 6 — Hoàn thiện

**Trạng thái:** ☐ Chưa làm · ☐ Đang làm · ☐ Xong

## Mục tiêu
Đánh bóng trải nghiệm: animation, haptics, app icon; thiết lập sẵn chỗ để thay asset đẹp hơn sau này.

## File liên quan
- `../09-shared/BigButtonStyle.md` (thêm hiệu ứng nhấn `scaleEffect`)
- `../07-game-modules/matching-game/MatchingGameView.md` (thêm confetti khi thắng)
- `../04-character-selection/CharacterSelectionView.md` (thêm hiệu ứng chuyển động nhẹ khi chọn)
- Toàn bộ file có trường `imageName` (`CharacterAvatar`, `VocabularyCard`) — thiết lập fallback: ưu tiên `Image(imageName)` từ Assets.xcassets nếu có, else emoji/SF Symbol

## Khái niệm học
Tuỳ chỉnh `ButtonStyle`, haptics API (`.sensoryFeedback`), Asset Catalog image sets (@1x/@2x/@3x), pattern fallback dựa trên optional.

## Kiểm tra (trên máy thật — Simulator không hỗ trợ haptics)
- [ ] Haptics khi match/mismatch trong game cảm giác đúng
- [ ] Confetti khi thắng chạy mượt
- [ ] App icon hiển thị đúng trên màn hình chính
- [ ] Khoá Portrait hoạt động đúng như kỳ vọng
