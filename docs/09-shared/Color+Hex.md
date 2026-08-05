# Color+Hex

**Mục đích:** Extension nhỏ khởi tạo `Color` từ chuỗi hex (ví dụ `Color(hex: "#4FC3F7")`) — cần thiết vì `Color` không decode trực tiếp từ hex.
**Loại:** Extension (utility)
**Phụ thuộc:** dùng bởi `LittleLearnerApp` (`.tint()`), `CharacterCardView`, `ThemedBackground`.
**Trạng thái:** ☐ Chưa code · ☐ Đang code · ☐ Xong
**Ghi chú:** Cách này đơn giản hơn cho người mới học so với việc tạo Color Set trong Asset Catalog — màu định nghĩa thẳng trong Swift, dễ chỉnh sửa.
