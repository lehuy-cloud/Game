# VocabularyHomeView

**Mục đích:** Màn hình gốc của tab Vocabulary — lưới các chủ đề từ vựng (Animals, Colors) để bé chọn.
**Loại:** View
**Phụ thuộc:** đọc `VocabularyContent.categories`; điều hướng (`NavigationLink`) sang `FlashcardDeckView` khi chọn 1 chủ đề; áp `.themedBackground()`.
**Trạng thái:** ☐ Chưa code · ☐ Đang code · ☐ Xong
**Ghi chú:** Layout `LazyVGrid`, mỗi ô chủ đề dùng `symbolName`/`colorName` từ `VocabularyCategory`.
