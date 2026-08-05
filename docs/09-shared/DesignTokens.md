# DesignTokens

**Mục đích:** Hằng số dùng chung cho khoảng cách, bo góc, kích thước tối thiểu vùng chạm — tránh hard-code số rải rác khắp các view.
**Loại:** Enum/struct hằng số (utility)
**Phụ thuộc:** dùng bởi hầu hết các View (spacing, cornerRadius).
**Trạng thái:** ☐ Chưa code · ☐ Đang code · ☐ Xong
**Ghi chú:** Chỉ thêm khi thực sự có giá trị lặp lại ≥3 nơi — tránh tạo token cho những giá trị chỉ dùng 1 lần.
