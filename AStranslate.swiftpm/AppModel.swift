import SwiftUI
import UIKit
import AVFoundation
import MLKitTranslate  // 使用 ML Kit 翻譯模組

final class AppModel: ObservableObject {
    static let shared = AppModel()
    
    @Published var immediatePrediction: String = "..."
    @Published var stablePrediction: String = "..."
    @Published var handKeypoints: [CGPoint] = []
    @Published var viewfinderImage: UIImage? = nil
    @Published var sentence: String = ""             // 從手語拼湊出的原始句子
    @Published var translatedSentence: String = ""     // 翻譯後的結果
    @Published var selectedLanguage: String = "en"       // 使用的語言代碼，例如 "en", "zh", "ja", "es", "fr", "de"
    
    // 使用 MLCamera 子類別進行 Vision + Core ML 處理
    let camera: Camera = MLCamera()
    
    // 用於追蹤目前字母及計時
    private var currentHeldLetter: String = "..."
    private var holdStartTime: Date? = nil
    private var holdTimer: Timer?
    private let defaultHoldDuration: TimeInterval = 3.0  // 一般字母保持 3 秒
    private let spaceHoldDuration: TimeInterval = 1.0    // "space" 與 "del" 手勢保持 1 秒
    
    init() {
        // 每 0.1 秒檢查一次是否達到加入字母的時間
        holdTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.checkHoldDuration()
        }
    }
    
    private func checkHoldDuration() {
        if stablePrediction != currentHeldLetter {
            currentHeldLetter = stablePrediction
            holdStartTime = Date()
        } else {
            if let start = holdStartTime, currentHeldLetter != "..." {
                let elapsed = Date().timeIntervalSince(start)
                let lowercasedPrediction = currentHeldLetter.lowercased()
                let requiredDuration = (lowercasedPrediction == "space" || lowercasedPrediction == "del") ? spaceHoldDuration : defaultHoldDuration
                if elapsed >= requiredDuration {
                    DispatchQueue.main.async {
                        if lowercasedPrediction == "del" {
                            if !self.sentence.isEmpty {
                                self.sentence.removeLast()
                            }
                        } else {
                            let letterToAppend = (lowercasedPrediction == "space") ? " " : self.currentHeldLetter
                            self.sentence.append(letterToAppend)
                        }
                        self.holdStartTime = nil
                        self.immediatePrediction = "..."
                        self.stablePrediction = "..."
                    }
                }
            }
        }
    }
    
    // 使用 ML Kit 進行翻譯（採用 callback 寫法）
    func translateSentence() {
        let targetLanguage: TranslateLanguage
        switch selectedLanguage {
        case "zh":
            targetLanguage = .chinese
        case "ja":
            targetLanguage = .japanese
        case "es":
            targetLanguage = .spanish
        case "fr":
            targetLanguage = .french
        case "de":
            targetLanguage = .german
        default:
            targetLanguage = .english
        }
        
        let options = TranslatorOptions(sourceLanguage: .english, targetLanguage: targetLanguage)
        let translator = Translator.translator(options: options)
        let conditions = ModelDownloadConditions(allowsCellularAccess: false, allowsBackgroundDownloading: true)
        
        translator.downloadModelIfNeeded(with: conditions) { error in
            if let error = error {
                DispatchQueue.main.async {
                    self.translatedSentence = "模型下載失敗：\(error.localizedDescription)"
                }
                return
            }
            translator.translate(self.sentence) { translatedText, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.translatedSentence = "翻譯錯誤：\(error.localizedDescription)"
                    } else if let translatedText = translatedText {
                        self.translatedSentence = translatedText
                    }
                }
            }
        }
    }
    
    // 使用 AVSpeechSynthesizer 朗讀文字
    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: selectedLanguage)
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
    // 清除句子與重置相關狀態
    func clearSentence() {
        DispatchQueue.main.async {
            self.sentence = ""
            self.translatedSentence = ""
            self.currentHeldLetter = "..."
            self.holdStartTime = nil
            self.immediatePrediction = "..."
            self.stablePrediction = "..."
        }
    }
}
