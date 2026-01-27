import Foundation

let SEARCHSUGGESTION = SearchSuggestionStore.shared
final class SearchSuggestionStore {
    static let shared = SearchSuggestionStore()

    private let baseKey = "com.whosin.business.searchSuggestion"

    private init() {}

    // Save [String] suggestions for a key
    func save(_ suggestions: [String], for key: String) {
        if key.isEmpty { return }
        let normalizedKey = storageKey(for: key)
        UserDefaults.standard.set(suggestions, forKey: normalizedKey)
    }

    // Retrieve [String] suggestions for a key
    func get(for key: String) -> [String] {
        if key.isEmpty { return [] }
        let normalizedKey = storageKey(for: key)
        let suggestions = UserDefaults.standard.stringArray(forKey: normalizedKey) ?? []
        if !suggestions.isEmpty {
            return suggestions
        }
        let allSuggestions = getAllSuggestions()
        return allSuggestions.filter { $0.lowercased().contains(key.lowercased()) }
    }

    // Remove suggestions for a specific key
    func remove(for key: String) {
        let normalizedKey = storageKey(for: key)
        UserDefaults.standard.removeObject(forKey: normalizedKey)
    }

    // Clear all stored suggestions (optional use)
    func clearAll() {
        let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
        for key in allKeys where key.starts(with: baseKey) {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
    
    func getAllSuggestions() -> [String] {
        let all = UserDefaults.standard.dictionaryRepresentation()
        var allSuggestions: Set<String> = []

        for (key, value) in all {
            if key.starts(with: baseKey), let array = value as? [String] {
                allSuggestions.formUnion(array)
            }
        }

        return Array(allSuggestions)
    }

    
//    func getAllSuggestions() -> [String] {
//        let all = UserDefaults.standard.dictionaryRepresentation()
//        var allSuggestions: [String] = []
//
//        for (key, value) in all {
//            if key.starts(with: baseKey), let array = value as? [String] {
//                allSuggestions.append(contentsOf: array)
//            }
//        }
//
//        return allSuggestions
//    }



    // MARK: - Private
    private func storageKey(for key: String) -> String {
        return "\(baseKey).\(key.lowercased())"
    }
}

