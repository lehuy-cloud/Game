# Chuyển design Lật Hình vào LittleLearner (SwiftUI)

5 file trong thư mục này dán thẳng vào Xcode được. Font phải cài trước, nếu không mọi `Font.display(_:)` sẽ rơi về font hệ thống.

## 1. Cài font

1. Tải **Baloo 2** và **Be Vietnam Pro** (Google Fonts) — cả hai có bảng dấu tiếng Việt đầy đủ, khác với Caprasimo/Figtree. Kéo `.ttf` vào `LittleLearner/Resources/Fonts/`, tick *Add to target*.
2. Info.plist → `UIAppFonts`: `Baloo2-ExtraBold.ttf`, `BeVietnamPro-Regular.ttf`, `BeVietnamPro-SemiBold.ttf`, `BeVietnamPro-Bold.ttf`.

## 2. Chép file vào project

| File | Đặt vào |
| --- | --- |
| `Palette.swift` | `Sources/LittleLearner/Shared/` |
| `MatchTileView.swift` | `Sources/LittleLearner/GameModules/MatchingGame/` |
| `LevelPickerView.swift` | `Sources/LittleLearner/GameModules/MatchingGame/` |
| `MatchingGameView.swift` | `Sources/LittleLearner/GameModules/MatchingGame/` — **thay file cũ** |
| `WinSheetView.swift` | `Sources/LittleLearner/GameModules/MatchingGame/` |

`MatchTile.swift`, `RewardStarsView.swift`, `SpeechService.swift`, `Color+Hex.swift`, `ProgressStore.swift` giữ nguyên.

## 3. Sửa 3 chỗ ở code cũ

**`DesignTokens.swift`** — `Palette.swift` mở rộng enum này nên chỉ cần giữ nguyên `spacing`, `cornerRadius`, `minTapTarget`.

**`GamesHomeView.swift`** — điều hướng sang màn chọn độ khó thay vì vào thẳng game:
```swift
NavigationLink { LevelPickerView(categoryId: category.id) } label: { … }
```

**`LittleLearnerApp.swift`** — bơm theme xuống toàn app:
```swift
WindowGroup {
    RootTabView()
        .environment(profileStore)
        .environment(progressStore)
        .environment(\.theme, Theme.named(profileStore.themeId))
}
```

## 4. Bộ màu hồng / xanh

Thêm vào `ProfileStore`:
```swift
var themeId: String = "terracotta" { didSet { persist() } }
```
(lưu cùng chỗ với `selectedCharacter` trong `UserDefaults`).

Ô chọn màu — đặt trong `CharacterSelectionView` hoặc màn Cài đặt:
```swift
HStack(spacing: 12) {
    ForEach(Theme.all) { t in
        Button { profileStore.themeId = t.id } label: {
            Circle().fill(t.base).frame(width: 44, height: 44)
                .overlay(Circle().strokeBorder(Palette.ink.opacity(profileStore.themeId == t.id ? 0.5 : 0), lineWidth: 3))
                .padding(3)
        }
    }
}
```

## 5. Lưu ý

- `ThemedBackground` cũ (gradient theo `secondaryHex` của nhân vật) đã được `organicBackground()` thay thế — màu nhân vật giờ chỉ dùng làm viền avatar, giữ nền kem của Organic.
- `speakOnFlip` dùng `@AppStorage` nên công tắc ở màn chọn độ khó và trong game tự đồng bộ.
- Emoji vẫn là asset tạm như v1 của repo; khi có ảnh riêng thì đổi `Text(tile.card.emoji)` trong `MatchTileView` sang `Image(card.imageName)`, phần còn lại không phải sửa.
