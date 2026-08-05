# LittleLearner — Tổng quan

App iOS cho bé 3–5 tuổi, kết hợp học tiếng Anh + rèn tư duy + chơi. Dùng riêng cho gia đình, không đăng App Store.

## Ý tưởng cốt lõi

Bé mở app → chọn 1 nhân vật yêu thích (Elsa, nàng tiên cá, người nhện, khủng long, tiên bướm) → cả giao diện app đổi màu theo nhân vật đó → học từ vựng tiếng Anh qua flashcard có giọng đọc → chơi game trí nhớ Matching Pairs để ôn lại từ đã học → nhận sao thưởng.

## Quyết định đã chốt

| Quyết định | Giá trị |
|---|---|
| Tên app (tạm) | **LittleLearner** — đổi tên bất cứ lúc nào trong Xcode |
| Bundle ID | `com.antonlehuy.littlelearner` |
| Ngôn ngữ | **Swift + SwiftUI** (native) |
| Kiến trúc | **MV đơn giản** (Model + View, không MVVM/Redux/TCA) — 2 store dùng chung (`ProfileStore`, `ProgressStore`) qua `@Environment`, còn lại `@State` cục bộ |
| Min deployment target | iOS 17.0 (`@Observable`, `NavigationStack`, `.sensoryFeedback`, `#Preview`) |
| Chữ ký / phân phối | Free "Personal Team" bằng Apple ID — không cần tài khoản Developer $99/năm |
| Ngôn ngữ nội dung | Thuần tiếng Anh — không phụ đề/đọc tiếng Việt |
| MVP scope | Chọn nhân vật + đổi theme màu, Flashcard từ vựng (2 chủ đề: Animals + Colors), 1 game trí nhớ Matching Pairs |
| Nhân vật v1 | Elsa, Mermaid, Spider Hero, Dinosaur, Butterfly Fairy — dùng emoji/SF Symbol, chưa vẽ asset riêng |

## Bản quyền nhân vật

Elsa, Spider-Man... là nhân vật có bản quyền (Disney/Marvel). App chỉ dùng riêng gia đình nên rủi ro rất thấp; v1 dùng emoji/SF Symbol gợi ý (❄️, 🕷️...) thay vì hình vẽ/ảnh thật — né hoàn toàn vấn đề bản quyền. Model đã để sẵn `imageName` để tự thêm hình ảnh riêng sau này nếu muốn.

## Cách đọc bộ tài liệu này

- `01-project-setup.md` — checklist cài môi trường, tạo project Xcode.
- `02-app-entry/` → `11-resources/` — 1 file `.md` cho mỗi file Swift dự kiến, đối chiếu 1-1 với cấu trúc code thật trong `LittleLearner/LittleLearner/`.
- `12-roadmap/` — 1 file cho mỗi phase xây dựng, tick "Xong" độc lập theo tiến độ thực tế.
- `13-testing.md` — chiến lược kiểm thử thủ công.

Khi plan "to dần" (thêm chủ đề, thêm game, thêm nhân vật...), chỉ thêm file markdown mới vào đúng thư mục con — không sửa các file cũ.
