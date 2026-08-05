# Phase 5 — Game Matching Pairs

**Trạng thái:** ☐ Chưa làm · ☐ Đang làm · ☐ Xong

## Mục tiêu
Game trí nhớ hoàn chỉnh: lật thẻ, tìm cặp, cộng sao khi thắng.

## File liên quan
- `../07-game-modules/matching-game/MatchTile.md`
- `../07-game-modules/matching-game/MatchingGameView.md`
- `../07-game-modules/GamesHomeView.md`

## Khái niệm học
Mảng struct trong `@State`, `Task`/async delay, overlay toàn màn hình (`.overlay`/`.fullScreenCover`), kết hợp `SpeechService` + `ProgressStore` trong cùng 1 luồng.

## Kiểm tra
- [ ] Chơi vài ván trong Simulator
- [ ] Chạm nhanh liên tiếp nhiều tile để test guard-clause (không cho lật tile thứ 3 khi đang có 2 tile lật)
- [ ] Trên máy thật: xác nhận audio-on-flip hoạt động, thời gian chờ (delay) trước khi so khớp cảm giác hợp lý
- [ ] Tắt/mở lại app — xác nhận sao từ game này đã được lưu
