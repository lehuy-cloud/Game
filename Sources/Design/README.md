# File SwiftUI đã sửa — thả vào repo lehuy-cloud/Game@main

Copy đè theo đúng đường dẫn dưới đây rồi build. Không cần sửa gì thêm.

| File ở đây | Đè lên |
| --- | --- |
| `Palette.swift` | `Sources/LittleLearner/Shared/Palette.swift` |
| `OddOneOutGameView.swift` | `Sources/LittleLearner/GameModules/OddOneOutGame/OddOneOutGameView.swift` |
| `ListenChooseGameView.swift` | `Sources/LittleLearner/GameModules/ListenChooseGame/ListenChooseGameView.swift` |
| `CountingGameView.swift` | `Sources/LittleLearner/GameModules/CountingGame/CountingGameView.swift` |
| `MatchingHomeView.swift` | `Sources/LittleLearner/GameModules/MatchingGame/MatchingHomeView.swift` |
| `FlashcardView.swift` | `Sources/LittleLearner/VocabularyModule/FlashcardView.swift` |
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

12. **Ảnh bìa làm phình thẻ (lỗi thấy trong 4 ảnh chụp iPad).** Trên màn Học,
   thẻ chủ đề có ảnh (Story Words) rộng/cao hơn ba thẻ kia, đè lên tiêu đề và
   che huy hiệu sao; màn Truyện thẻ ăn hết màn, chữ dồn xuống đáy; danh sách
   chương ba cột rộng khác nhau, hàng 2 lệch. Nguyên nhân chung: 
   `Image().resizable().scaledToFill()` vẫn khai kích thước gốc với layout —
   `.clipped()` chỉ cắt lúc VẼ, không sửa layout. Nay dùng `CoverFill`
   (ảnh nằm trong `overlay` của `Color.clear`) ở cả 3 màn → ô lưới bằng nhau.
13. **Truyện chỉ có 1 truyện, thẻ cao bằng cả màn** — trần chiều cao hàng 560pt,
   hàng căn lên đỉnh.
14. **Header truyện tên 2 dòng đẩy nút back lệch** — `HStack(alignment: .top)`.

15. **Tìm bạn khác loài: 4 ô bé xíu dồn đáy, giữa màn trống.** `optionTile` bọc
   `.aspectRatio(1, .fit)` quanh HStack nên ô co đúng bằng cỡ ảnh 140pt, còn
   dòng "Ai không cùng nhóm?" chiếm hết chỗ trống. Nay câu hỏi + lưới 2×2 cùng
   nằm trong vùng chơi, lưới đo `GeometryReader` chia đều, ô có tên thẻ dưới
   ảnh (thiết kế P13).
16. **Ba ô hiện SỐ 4·5·6 cạnh một ảnh koala** — nhóm bốc trúng category
   "numbers"/"colors". Nay nhóm 3 thẻ luôn lấy từ category CÓ ẢNH, số/màu chỉ
   làm ô lạc → "4 ô lớn cùng bộ ảnh" đúng thiết kế.
17. **Nghe rồi chọn trên iPad xếp dọc như iPhone** — loa nhỏ giữa màn, 3 thanh
   ngang mỏng, trống nửa màn. Nay đúng P10: cột trái 272pt (loa 172pt, câu hỏi
   30pt, gợi ý) + lưới đáp án 2×2 ảnh lớn bên phải, iPad chơi 4 ảnh.
18. **Icon loa hai kiểu** — màn đọc truyện dùng `speaker.wave.2.fill`, game dùng
   `speaker.wave.3.fill`. Nay thống nhất `speaker.wave.3.fill`.

19. **Đếm cùng bé: khung đếm co bằng nội dung, trống nửa màn dưới.** Thiết kế P9
   cho khung đếm `flex:1` (nền accent, câu hỏi nằm TRONG khung). Nay khung ăn
   hết vùng chơi, ảnh con vật 150pt (trước 96pt) và bỏ ô nền thừa quanh mỗi con.
20. **Ô số thiếu tên tiếng Anh** — thiết kế là số 76pt + "Three/Four/Five", ô cao
   170pt. Nay đúng vậy (iPhone 40pt/88pt).

21. **Thẻ "BỘ THẺ ĐANG CHỌN" là một mảng xanh gắt.** Nó tô nguyên khối
   `theme.base`; với buddy màu lam thành mảng xanh chọi nền kem, khác hẳn thẻ
   "Chơi tiếp" ở màn Chơi (dùng `theme.tint`). Nay nền tint nhạt + chữ ink, chỉ
   nút "Chơi ngay" dùng màu đậm.
22. **Ô xem trước bộ "Màu sắc"** là chấm emoji trên nền trắng → nay ô màu tràn
   viền (`colorHex`). Màn này cũng lên cỡ chữ/lề iPad như các màn khác.

23. **Ngọn đèn: bảng 3×3 méo, có thanh xám mảnh xen giữa, mỗi ô là một hình
   vuông đen xấu.** `Grid` + `.aspectRatio(1, .fill)` trên từng ô cho ba cột
   rộng khác nhau và kéo vài ô thành thanh; ô chưa sáng vẽ bằng emoji "⬛".
   Nay bảng đo bằng `GeometryReader`, ô vuông cố định chia đều; ô chưa sáng là
   chấm mờ, ô sáng là ảnh chương (`CoverFill`) hoặc biểu tượng đèn.

24. **Màn Chơi: thẻ "Lật Hình" dính vào hàng "Ô cửa bí mật / Tìm bạn khác loài".**
   Ngân sách chiều cao coi hàng cuối ("Ghép chữ với hình") là 96pt, nhưng thẻ đó
   cao hơn (lề 20 + nội dung 58) nên tổng vượt chiều cao thật → VStack ép khoảng
   cách về 0. Nay hàng cuối cố định 104pt, trừ đủ 3 khoảng cách rồi mới chia
   phần còn lại cho thẻ Chơi tiếp (34%, kẹp 200–320pt) và 2 hàng game.

25. **Thẻ xem trước bộ "Màu sắc" hiện chấm emoji 🔴🟢 (icon cũ).** `peekTile`
   thiếu nhánh `colorHex` nên rơi xuống nhánh emoji. Nay ô màu tràn viền, số thì
   vẽ chữ số — giống `MatchingHomeView` (mục 22).

26. **Icon loa không theo design.** Design doc vẽ nút nghe là glyph 🔊 trong vòng
   tròn accent; app dùng SF Symbol `speaker.wave.2/3.fill` và mỗi màn một cỡ.
   Nay có `SpeakGlyph` trong `Palette.swift`, dùng ở: nút nghe lớn của "Nghe rồi
   chọn", hai nút nghe màn đọc truyện, chip "Nghe lại" của "Đếm cùng bé", nút
   nghe thẻ từ (`FlashcardView`).
   (Giữ SF Symbol ở icon ô game trên màn Chơi và dòng cài đặt trong
   `LevelPickerView` — chỗ đó là icon danh mục, không phải nút nghe.)

## Kiểm tra sau khi build

- Font: nếu chữ vẫn mảnh/nhỏ hơn thiết kế, `UIAppFonts` trong Info.plist chưa khai
  Baloo 2 + Be Vietnam Pro (tên PostScript `Baloo2-ExtraBold`, `BeVietnamPro-Regular/SemiBold/Bold`).
- `gameContentWidth()` (maxWidth 420) chỉ dùng cho màn chơi game, không dùng cho
  màn danh sách — nếu thấy màn nào kẹt cột hẹp giữa iPad, kiểm tra chỗ này.
