# Phase 2 — Chọn nhân vật & đổi theme màu

**Trạng thái:** ☐ Chưa làm · ☐ Đang làm · ☐ Xong

## Mục tiêu
Bé chọn 1 trong 5 nhân vật; cả app đổi màu (tint + nền) theo nhân vật đã chọn; nhớ lựa chọn giữa các lần mở app.

## File liên quan
- `../03-models/CharacterAvatar.md`
- `../11-resources/CharacterContent.md`
- `../09-shared/Color+Hex.md`
- `../05-profile/ProfileStore.md`
- `../04-character-selection/CharacterSelectionView.md`
- `../04-character-selection/CharacterCardView.md`
- `../09-shared/ThemedBackground.md`
- `../02-app-entry/LittleLearnerApp.md` (cập nhật: hiển thị có điều kiện + `.tint()`)

## Khái niệm học
struct/`Codable`, `@Observable` + `UserDefaults` (trường hợp đơn giản: 1 chuỗi), hiển thị view có điều kiện (`if let`), `ViewModifier` tuỳ chỉnh, `.tint()`/`LinearGradient`.

## Kiểm tra
- [ ] Chọn từng nhân vật trong 5 nhân vật, xác nhận màu nút + nền đổi đúng theo nhân vật
- [ ] Tắt hẳn app rồi mở lại — xác nhận nhân vật đã chọn được nhớ (vào thẳng `RootTabView` với đúng theme, không quay lại màn chọn)
