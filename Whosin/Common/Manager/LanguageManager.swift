import Foundation
import UIKit

let LANGMANAGER = LanguageManager.shared

class LanguageManager {
    
    private var translations: [String: String] = [:]
    private var englishTranslations: [String: String] = [:]
    private var fallbackTranslations: [String: String] = [:]
    private let fileName = "localize.json"
    
    // MARK: - Singleton
    class var shared: LanguageManager {
        struct Static {
            static let instance = LanguageManager()
        }
        return Static.instance
    }
    
    // MARK: - Current Language
    var currentLanguage: String {
        get {
            return Preferences.selectedLanguage
        }
        set {
            Preferences.selectedLanguage = newValue
            loadLanguage(newValue)
            updateLayoutDirection()
        }
    }
    
    private init() {
        englishTranslations = loadFallbackFile("en")
        fallbackTranslations = loadFallbackFile(currentLanguage)
        loadLanguage(currentLanguage)
        updateLayoutDirection()
    }
    
    // MARK: - Load Language Files
    private func loadLanguageFile(_ langCode: String) -> [String: String] {
        let filePath = Utils.getDocumentsDirectory().appendingPathComponent(fileName)

        if Utils.isFileExist(atPath: filePath as String),
           let data = try? Data(contentsOf: URL(fileURLWithPath: filePath as String)),
           let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let langDict = json[langCode] as? [String: String] {
            
            return langDict
        }

        if let path = Bundle.main.path(forResource: langCode, ofType: "json"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
           let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
            return json
        }
        return [:]
    }
    
    private func loadFallbackFile(_ langCode: String) -> [String: String] {
        if let path = Bundle.main.path(forResource: langCode, ofType: "json"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
           let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
            return json
        }
        return [:]
    }
    
    private func loadLanguage(_ langCode: String) {
        translations = loadLanguageFile(langCode)
    }
    
    func localized(_ key: String) -> String {
        if let value = translations[key] {
            return value
        } else if let fallbackTranslations = fallbackTranslations[key] {
            return fallbackTranslations
        } else if let fallback = englishTranslations[key] {
            return fallback
        }
        return key
    }
    
    func localizedString(forKey key: String, arguments: [String: String]? = nil) -> String {
        var localized: String
        if let value = translations[key] {
            localized = value
        } else if let fallbackValue = fallbackTranslations[key] {
            localized = fallbackValue
        } else if let englishValue = englishTranslations[key] {
            localized = englishValue
        } else {
            localized = key
        }
        arguments?.forEach { placeholder, value in
            localized = localized.replacingOccurrences(of: "{\(placeholder)}", with: value)
        }
        return localized
    }
    
    private func updateLayoutDirection() {
        if currentLanguage == "ar" {
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        } else {
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
    }
    
    func getLocalizeFile() {
        WhosinServices.getLanguageFiles { [weak self] container, error in
            guard let self = self else { return }
            guard let model = container?.data else { return }

            if !model.isEmpty {
                let jsonString = model.toJSONPrettyPrintString

                guard let data = jsonString.data(using: .utf8) else { return }
                let fileURL = Utils.getDownloadedFileURL(fileName: self.fileName)

                if let fileURL = fileURL {
                    if FileManager.default.fileExists(atPath: fileURL.path) {
                        if let existingData = try? Data(contentsOf: fileURL),
                           let existingString = String(data: existingData, encoding: .utf8),
                           existingString == jsonString {
                            return
                        }

                        try? FileManager.default.removeItem(at: fileURL)
                    }

                    Utils.saveFileToLocal(data: data, fileName: self.fileName)
                    self.loadLanguage(self.currentLanguage)
                }
            }
        }
    }

    
    func reset() {
         Preferences.selectedLanguage = "en"
         translations = englishTranslations
         fallbackTranslations = [:]
         loadLanguage("en")
         UIView.appearance().semanticContentAttribute = .forceLeftToRight
     }

}

// MARK: - Extensions
extension String {
    func localized() -> String {
        return LANGMANAGER.localized(self)
    }
}

extension UILabel {
    @IBInspectable var localizedText: String {
        set(value) { self.text = value.localized() }
        get { return kEmptyString }
    }
}

extension UISearchBar {
    @IBInspectable var localizedPlaceholder: String {
        set(value) { self.placeholder = value.localized() }
        get { return kEmptyString }
    }
}

extension UIButton {
    @IBInspectable var localizedText: String {
        set(value) { self.setTitle(value.localized(), for: .normal) }
        get { return kEmptyString }
    }
}


