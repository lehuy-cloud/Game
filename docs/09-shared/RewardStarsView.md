# RewardStarsView

**Mục đích:** Hàng icon sao + hiệu ứng phóng to khi số sao tăng; dùng lại ở cả `StarsSummaryView` và màn thắng của `MatchingGameView`.
**Loại:** View (reusable component)
**Phụ thuộc:** nhận số sao làm tham số; không tự đọc store (nhận data từ view cha).
**Trạng thái:** ☐ Chưa code · ☐ Đang code · ☐ Xong
**Ghi chú:** Dùng `withAnimation` khi số sao thay đổi để tạo cảm giác "được thưởng" rõ ràng cho bé.
