import AVFoundation
import Observation

@Observable
final class SpeechService: NSObject {
    static let shared = SpeechService()
    private let synthesizer = AVSpeechSynthesizer()

    private(set) var speakingText: String?
    private(set) var speakingRange: NSRange?

    private override init() {
        super.init()
        synthesizer.delegate = self
    }

    func configureAudioSession() {
        // Đảm bảo phát âm thanh kể cả khi máy đang ở chế độ im lặng —
        // nếu không, phụ huynh sẽ tưởng app bị lỗi vì không có tiếng.
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func speak(_ text: String, language: String = "en-US") {
        synthesizer.stopSpeaking(at: .immediate)
        enqueue(text, language: language)
    }

    /// Đọc từ tiếng Anh rồi nối tiếp chú thích tiếng Việt (và mô tả nếu có) —
    /// dùng cho thẻ từ vựng để bé nghe được cả hai thứ tiếng chỉ với một lần chạm.
    func speak(word: String, caption: String, description: String? = nil) {
        synthesizer.stopSpeaking(at: .immediate)
        enqueue(word, language: "en-US")
        enqueue(caption, language: "vi-VN")
        if let description {
            enqueue(description, language: "vi-VN")
        }
    }

    private func enqueue(_ text: String, language: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.85
        speakingText = text
        speakingRange = nil
        synthesizer.speak(utterance)
    }
}

extension SpeechService: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        speakingRange = characterRange
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        speakingText = nil
        speakingRange = nil
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        speakingText = nil
        speakingRange = nil
    }
}
