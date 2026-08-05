# FlashcardDeckView

**Mục đích:** Cho bé lướt qua từng thẻ từ vựng trong 1 chủ đề đã chọn (nút prev/next hoặc vuốt).
**Loại:** View
**Phụ thuộc:** nhận `categoryId`, đọc `VocabularyContent.cards(for:)`; giữ `@State private var currentIndex`; dựng từ `FlashcardView`.
**Trạng thái:** ☐ Chưa code · ☐ Đang code · ☐ Xong
**Ghi chú:** State cục bộ, không cần persist — vị trí thẻ đang xem không cần nhớ giữa các lần vào.
