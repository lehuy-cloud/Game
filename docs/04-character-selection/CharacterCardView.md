# CharacterCardView

**Mục đích:** Hiển thị 1 nhân vật dưới dạng thẻ to (emoji lớn + tên) trên nền màu `primaryHex` của nhân vật đó, dùng trong lưới của `CharacterSelectionView`.
**Loại:** View
**Phụ thuộc:** nhận 1 `CharacterAvatar` làm tham số; dùng `Color+Hex` để tô nền; dùng `BigButtonStyle` cho vùng chạm to.
**Trạng thái:** ☐ Chưa code · ☐ Đang code · ☐ Xong
**Ghi chú:** Thuần hiển thị (dumb view), không tự ghi vào `ProfileStore` — việc đó do `CharacterSelectionView` xử lý ở closure `onTap`.
