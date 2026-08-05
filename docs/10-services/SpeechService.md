# SpeechService

**Mục đích:** Bọc `AVSpeechSynthesizer` để đọc to từ tiếng Anh — thành phần quan trọng nhất cho app dành cho bé chưa biết đọc.
**Loại:** Service (singleton thường, không `@Observable`)
**Phụ thuộc:** dùng bởi `FlashcardView`, `MatchingGameView`, `CharacterSelectionView`.
**Trạng thái:** ☐ Chưa code · ☐ Đang code · ☐ Xong
**Ghi chú:** Không cần observable vì UI không phản ứng theo trạng thái "đang nói" ở v1.

```swift
final class SpeechService {
    static let shared = SpeechService()
    private let synthesizer = AVSpeechSynthesizer()
    private init() {}

    func configureAudioSession() {
        // Đảm bảo phát âm thanh kể cả khi máy đang ở chế độ im lặng —
        // nếu không, phụ huynh sẽ tưởng app bị lỗi vì không có tiếng.
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func speak(_ text: String) {
        synthesizer.stopSpeaking(at: .immediate)  // tránh chồng lấn utterance
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.85  // chậm hơn, rõ hơn cho bé
        synthesizer.speak(utterance)
    }
}
```
