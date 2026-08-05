# Phase 4 — Lưu tiến độ + sao thưởng

**Trạng thái:** ☐ Chưa làm · ☐ Đang làm · ☐ Xong

## Mục tiêu
Lưu số sao theo chủ đề, hiển thị ở tab Stars; thêm lối tắt đổi nhân vật từ tab Stars.

## File liên quan
- `../08-progress/ProgressStore.md`
- `../09-shared/RewardStarsView.md`
- `../08-progress/StarsSummaryView.md`

## Khái niệm học
`@Observable` áp dụng lại cho trường hợp phức tạp hơn (dictionary thay vì 1 chuỗi), `.sheet`, `didSet`, `withAnimation`.

## Kiểm tra
- [ ] Trigger 1 sao (tạm thời có thể gắn vào hành động "xem hết thẻ trong chủ đề"), kiểm tra Stars tab cập nhật
- [ ] Tắt hẳn app rồi mở lại — xác nhận số sao **và** nhân vật đã chọn đều được lưu
- [ ] Thử đổi nhân vật từ nút trong Stars tab — xác nhận theme đổi ngay lập tức
