# Kiểm thử

App quy mô cá nhân, không cần bộ test tự động — mỗi phase trong `12-roadmap/` kết thúc bằng bước kiểm thử thủ công riêng.

## Simulator vs thiết bị thật

- **Simulator**: đủ cho layout, điều hướng, logic game, theme màu — kể cả TTS (`AVSpeechSynthesizer` route qua loa Mac).
- **Bắt buộc thiết bị thật** cho:
  - Haptics (`.sensoryFeedback`) — Simulator không hỗ trợ hoàn toàn.
  - Cảm giác chạm/kéo thật, để kiểm tra vùng chạm có phù hợp tay bé 3-5 tuổi không.
  - Âm thanh khi máy ở chế độ im lặng (silent switch).

## Vòng lặp kết nối thiết bị

USB hoặc wireless debugging → chọn thiết bị làm run destination → trust computer lần đầu → bật Developer Mode trên thiết bị (1 lần) → Run.

Lưu ý: Personal Team free khiến app hết hạn sau 7 ngày — chỉ cần Run lại từ Xcode để làm mới trong lúc phát triển.

## Checklist tổng theo phase

Xem checklist chi tiết trong từng file `12-roadmap/phase-*.md`. Tổng quan:

| Phase | Trọng tâm kiểm thử |
|---|---|
| 0 | Môi trường: `xcodebuild -version`, Simulator boot |
| 1 | Điều hướng 3 tab, 1 lần chạy thật để xử lý ký app |
| 2 | Theme đổi đúng theo nhân vật, nhân vật được nhớ sau khi tắt/mở app |
| 3 | Giọng đọc rõ trên máy thật kể cả khi im lặng, theme vẫn đúng |
| 4 | Sao + nhân vật được lưu, đổi nhân vật từ Stars tab hoạt động |
| 5 | Guard-clause game không bug khi chạm nhanh, sao được lưu |
| 6 | Haptics, confetti, icon, portrait lock trên máy thật |
