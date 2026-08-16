# File SwiftUI đã sửa — thả vào repo lehuy-cloud/Game@main

Copy đè theo đúng đường dẫn dưới đây rồi build. Không cần sửa gì thêm.

| File ở đây | Đè lên |
| --- | --- |
| `Palette.swift` | `Sources/LittleLearner/Shared/Palette.swift` |
| `RootTabView.swift` | `Sources/LittleLearner/RootTabView.swift` |
| `AppHeaderView.swift` | `Sources/LittleLearner/Profile/AppHeaderView.swift` |
| `VocabularyHomeView.swift` | `Sources/LittleLearner/VocabularyModule/VocabularyHomeView.swift` |
| `GamesHomeView.swift` | `Sources/LittleLearner/GameModules/GamesHomeView.swift` |
| `StoryListView.swift` | `Sources/LittleLearner/StoryModule/StoryListView.swift` |
| `StoryHomeView.swift` | `Sources/LittleLearner/StoryModule/StoryHomeView.swift` |
| `StoryChapterView.swift` | `Sources/LittleLearner/StoryModule/StoryChapterView.swift` |
| `StoryCompletionOverlay.swift` | `Sources/LittleLearner/StoryModule/StoryCompletionOverlay.swift` |
| `MiniGameScaffold.swift` | **file mới** → `Sources/LittleLearner/StoryModule/MiniGames/MiniGameScaffold.swift` |
| `IceMeltGameView.swift` | `Sources/LittleLearner/StoryModule/MiniGames/IceMeltGameView.swift` |
| `LaughChaseGameView.swift` | `Sources/LittleLearner/StoryModule/MiniGames/LaughChaseGameView.swift` |
| `LanternPathGameView.swift` | `Sources/LittleLearner/StoryModule/MiniGames/LanternPathGameView.swift` |
| `StormBattleGameView.swift` | `Sources/LittleLearner/StoryModule/MiniGames/StormBattleGameView.swift` |

(Các file `GameScreenScaffold.swift`, `MatchTileView.swift`, `MatchingGameView.swift`,
`NumberCardView.swift`, `LevelPickerView.swift`, `WinSheetView.swift` là bản mẫu cũ,
không liên quan lần sửa này.)

## 7 lỗi giao diện đã sửa

1. **Thanh Học·Chơi·Truyện hiện trên mọi màn.** `RootTabView` đặt `MainTabBar` trong
   VStack bao ngoài `TabView` → nó nổi cả khi đang đọc truyện/chơi game.
   Nay thanh thuộc 3 màn gốc qua `.mainTabBar(router)`; màn push lên phủ kín nó.
   → cần `TabRouter` trong environment (đã có trong `RootTabView.swift`).
2. **Nửa dưới màn Học trống trơn.** `ScrollView` + `LazyVGrid` cho chiều cao bằng
   nội dung; thiết kế là `flex:1` + `rows: 1fr 1fr`. Nay đo bằng `GeometryReader`
   và chia `(H - gap)/2`.
3. **Ảnh trong thẻ cao cố định 240pt** → `maxHeight: .infinity`, thẻ tự cân.
4. **Lề iPad 16pt** (`DesignTokens.spacing` là số của iPhone). Thêm `Layout.side/gap`
   = 44/24 cho iPad, dùng ở cả 3 màn gốc.
5. **Cỡ chữ khoá cứng cỡ iPhone.** Tiêu đề màn 26→44, tên chủ đề 17→26, số thẻ
   12→16, tên chương 17→30, nút back 44→56, ô game 170pt→chia đều chiều cao.
6. **Header chương dính vào tranh** — thiếu lớp phủ tối. Thêm `TopScrim`.
7. **Danh sách truyện dùng `.adaptive(minimum: 160)`** → 4-5 cột tí hon trên iPad.
   Nay 2 cột, thẻ cao bằng nhau. Thanh tiến độ đọc dày 9pt trên iPad và chia đều
   hết bề ngang (`ReadingProgressBar.thickness`, `frame(maxWidth: .infinity)`).

8. **Danh sách chương xếp thành một hàng thẻ tí hon**, tên chương bị cắt
   ("Người bạn đ…"), nửa dưới màn trống — cũng do `.adaptive(minimum: 150)`.
   Nay lưới 3 cột chia hết chiều cao, tên chương tách "Chương N" ra dòng nhãn
   riêng nên còn 2 dòng đầy đủ cho tên. Tiêu đề truyện dùng header tự vẽ
   (back 56 + tên 40pt) thay cho `navigationTitle` mặc định căn giữa.

9. **4 mini-game của truyện bị nhốt trong cột 420pt, hai bên màn trắng bốc.**
   Hai lỗi cùng lúc: `.organicBackground()` đặt TRƯỚC `.gameContentWidth()` nên
   nền chỉ vẽ trong cột hẹp, và `gameContentWidth()` bọc cả màn thay vì chỉ vùng
   chơi. Nay dùng `MiniGameShell` — nền là modifier ngoài cùng, header/câu hỏi
   full bề ngang, vùng chơi mới giới hạn 560pt (game toạ độ tự do thì lấy hết).
   Toạ độ mục tiêu bay/mây rơi cũng tính trong vùng chơi, không còn nhảy ra
   ngoài phần thấy được.
10. **Thẻ chúc mừng "Về danh sách chương"** nổi trần không có lớp làm mờ phía sau,
   chữ cỡ iPhone. Nay có scrim, rộng tối đa 620pt, chữ 30pt trên iPad.
11. **Danh sách truyện chỉ có 1 hàng vẫn chừa nửa màn trống** — bỏ trần 420pt để
   hàng thẻ ăn hết chiều cao; chấm màu căn theo dòng chữ đầu thay vì giữa thẻ.

## Kiểm tra sau khi build

- Font: nếu chữ vẫn mảnh/nhỏ hơn thiết kế, `UIAppFonts` trong Info.plist chưa khai
  Baloo 2 + Be Vietnam Pro (tên PostScript `Baloo2-ExtraBold`, `BeVietnamPro-Regular/SemiBold/Bold`).
- `gameContentWidth()` (maxWidth 420) chỉ dùng cho màn chơi game, không dùng cho
  màn danh sách — nếu thấy màn nào kẹt cột hẹp giữa iPad, kiểm tra chỗ này.
