import UIKit

struct Preferences {

    @propertyWrapper
    struct UserDefault<T> {
        let key: String
        let defaultValue: T

        init(_ key: String, defaultValue: T) {
            self.key = key
            self.defaultValue = defaultValue
        }

        var wrappedValue: T {
            get {
                UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
            }
            set {
                UserDefaults.standard.set(newValue, forKey: key)
            }
        }
    }

    @propertyWrapper
    struct UserDefaultURL {
        let key: String
        let defaultValue: String

        init(_ key: String, defaultValue: String) {
            self.key = key
            self.defaultValue = defaultValue
        }

        var wrappedValue: String {
            get {
                guard let localUrl = UserDefaults.standard.string(forKey: key) else { return defaultValue }
                let trimmedUri = uriWithoutTrailingSlashes(localUrl).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                if !validateUrl(trimmedUri) { return defaultValue }
                return trimmedUri
            }
            set {
                UserDefaults.standard.set(newValue, forKey: key)
            }
        }
    }

    @propertyWrapper
    struct UserDefaultEnum<T: RawRepresentable> where T.RawValue: Any {
        let key: String
        let defaultValue: T

        init(_ key: String, defaultValue: T) {
            self.key = key
            self.defaultValue = defaultValue
        }

        var wrappedValue: T {
            get {
                if let rawValue = UserDefaults.standard.object(forKey: key) as? T.RawValue, let value = T(rawValue: rawValue) {
                    return value
                }
                return defaultValue
            }
            set {
                UserDefaults.standard.set(newValue.rawValue, forKey: key)
            }
        }
    }
    
    private static let defaults = UserDefaults.standard
    @UserDefault("isPrivacyAgree", defaultValue: false) static var isPrivacyAgree: Bool
    @UserDefault("didlogin", defaultValue: false) static var didLogin: Bool
    @UserDefault("isGuest", defaultValue: false) static var isGuest: Bool
    @UserDefault("userId", defaultValue: kEmptyString) static var userId: String
    @UserDefault("type", defaultValue: kEmptyString) static var type: String
    @UserDefault("userDetailModel", defaultValue: kEmptyString) static var userDetailModel: String
    @UserDefault("preferences", defaultValue: kEmptyString) static var preferencesModel: String
    @UserDefault("token", defaultValue: kEmptyString) static var token: String
    @UserDefault("home-block", defaultValue: kEmptyString) static var homeBlock: String
    @UserDefault("vouchersModel", defaultValue: []) static var vouchersModel: [String]
    @UserDefault("searchHistory", defaultValue: kEmptyString) static var searchHistory: String
    @UserDefault("searchText", defaultValue: []) static var searchText: [String]
    @UserDefault("addCartCount", defaultValue: 0) static var addedToCart: Int
    @UserDefault("lastMsgSynced", defaultValue: kEmptyString) static var lastMsgSynced: String
    @UserDefault("chatWallpapers", defaultValue: []) static var chatWallpapers: [[String:Any]]
    @UserDefault("deepLink", defaultValue: kEmptyString) static var deepLink: String
    @UserDefault("chatNotificationClickData", defaultValue: [:]) static var chatNotificationData: [AnyHashable : Any]
    @UserDefault("isAuthenticationPending", defaultValue: false) static var isAuthenticationPending: Bool
    @UserDefaultEnum("profileType", defaultValue: .profile) static var profileType: ProfileType
    @UserDefault("promoterProfile", defaultValue: kEmptyString) static var promoterProfile: String
    @UserDefault("CMProfile", defaultValue: kEmptyString) static var cmProfile: String
    @UserDefault("saveEventDraft", defaultValue: []) static var saveEventDraft: [[String: Any]]
    @UserDefault("isSubAdmin", defaultValue: false) static var isSubAdmin: Bool
    @UserDefault("promoterId", defaultValue: kEmptyString) static var promoterId: String
    @UserDefault("currency", defaultValue: "AED") static var currency: String
    @UserDefault("blockedUsers", defaultValue: []) static var blockedUsers: [String]
    @UserDefault("selectedLanguage", defaultValue: "en") static var selectedLanguage: String
    @UserDefault("isFromGuest", defaultValue: false) static var isFromGuest: Bool



    private static func validateUrl(_ stringURL: String) -> Bool {
        let url: URL? = URL(string: stringURL)
        return url != nil
    }

    static func uriWithoutTrailingSlashes(_ hostUri: String) -> String {
        if !hostUri.hasSuffix("/") {
            return hostUri
        }
        return String(hostUri[..<hostUri.index(before: hostUri.endIndex)])
    }
    
    static func clearConnectedData() {
        defaults.removeObject(forKey: "promoterId")
        defaults.removeObject(forKey: "isSubAdmin")
        defaults.removeObject(forKey: "isPrivacyAgree")
        defaults.removeObject(forKey: "didlogin")
        defaults.removeObject(forKey: "userId")
        defaults.removeObject(forKey: "type")
        defaults.removeObject(forKey: "userDetailModel")
        defaults.removeObject(forKey: "preferences")
        defaults.removeObject(forKey: "token")
        defaults.removeObject(forKey: "home-block")
        defaults.removeObject(forKey: "vouchersModel")
        defaults.removeObject(forKey: "searchHistory")
        defaults.removeObject(forKey: "searchText")
        defaults.removeObject(forKey: "addCartCount")
        defaults.removeObject(forKey: "lastMsgSynced")
        defaults.removeObject(forKey: "chatWallpapers")
        defaults.removeObject(forKey: "chatNotificationClickData")
        defaults.removeObject(forKey: "isAuthenticationPending")
        defaults.removeObject(forKey: "home-block")
        defaults.removeObject(forKey: "isGuest")
        defaults.removeObject(forKey: "selectedLanguage")
        defaults.synchronize()
    }
    
    static func restartClearConnectedData() {
        defaults.removeObject(forKey: "promoterId")
        defaults.removeObject(forKey: "isSubAdmin")
        defaults.removeObject(forKey: "lastMsgSynced")
        defaults.synchronize()
    }
}
