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
