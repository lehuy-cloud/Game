# BigButtonStyle

**Mục đích:** `ButtonStyle` dùng chung đảm bảo vùng chạm tối thiểu ~100×100pt, bo góc, hiệu ứng nhấn — áp dụng thống nhất cho mọi nút bấm trong app (phù hợp tay bé 3-5 tuổi).
**Loại:** ViewModifier / ButtonStyle
**Phụ thuộc:** không đọc store; tự động ăn theo `.tint()` hiện tại của view cha (nên đổi màu theo nhân vật mà không cần tham số riêng).
**Trạng thái:** ☐ Chưa code · ☐ Đang code · ☐ Xong
**Ghi chú:** Dùng ở `CharacterCardView`, `FlashcardView`, các nút trong game và Stars tab.
