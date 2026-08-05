# Project Setup (Phase 0)

**Trạng thái:** ☐ Chưa làm · ☐ Đang làm · ☐ Xong

## Checklist môi trường

- [ ] Cài **Xcode** đầy đủ từ Mac App Store (máy hiện chỉ có Command Line Tools — đã xác nhận `xcodebuild -version` báo lỗi thiếu Xcode).
- [ ] Mở Xcode lần đầu, cho cài "additional components".
- [ ] Xcode → Settings → Accounts → thêm Apple ID → tạo Personal Team.
- [ ] Chuẩn bị iPhone/iPad gia đình để test; lần đầu Run lên máy thật cần bật **Developer Mode** (Settings → Privacy & Security), máy sẽ khởi động lại.

## Checklist tạo project

- [ ] File → New → Project → iOS → App
- [ ] Product Name: `LittleLearner`
- [ ] Interface: SwiftUI, Language: Swift, Storage: None
- [ ] Bỏ chọn "Include Tests"
- [ ] Lưu vào `/Users/lehuy/DEV/Game/` → tạo `/Users/lehuy/DEV/Game/LittleLearner/LittleLearner.xcodeproj` (sống cạnh thư mục `docs/`)
- [ ] General → Deployment: Min iOS 17.0
- [ ] Khoá Portrait cho iPhone (Device Orientation)
- [ ] Ép Light mode ở root view: `.preferredColorScheme(.light)`

## Ghi chú

Không cần Core Data/SwiftData, không cần bộ test tự động — app quy mô cá nhân, kiểm thử thủ công theo từng phase (xem `13-testing.md`).
