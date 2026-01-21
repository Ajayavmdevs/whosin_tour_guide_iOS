import UIKit

public let URLMANAGER = UrlManager.shared

public class UrlManager: NSObject {
    
    /// Development server
//    private var _baseUrl: String = "https://devapi.whosin.me/"
//    private var _baseUrl: String = "http://40.172.74.243:8443/"
//    public let kScoketIoUrl: URL = URL(string: "http://64.227.131.3:2096")!
    
    // Live server
    private var _baseUrl: String = "https://api.whosin.me/"
    public let kScoketIoUrl: URL = URL(string: "https://websocket.whosin.me")!
    
    // Live AWS server
//    private var _baseUrl: String = "https://apiv2.whosin.me/"
//    public let kScoketIoUrl: URL = URL(string: "https://websocket.whosin.me")!

    // --------------------------------------
    // MARK: Singleton
    // --------------------------------------
    

    class var shared: UrlManager {
        struct Static {
            static let instance = UrlManager()
        }
        return Static.instance
    }

    override init() {
        super.init()
    }

    // --------------------------------------
    // MARK: Public Getters
    // --------------------------------------

    var baseServiceUrl: String {
        return _baseUrl
    }
    
    // --------------------------------------
    // MARK: Public Functions
    // --------------------------------------

    public func baseUrl(endPoint: String) -> String {
        var newUrl = kEmptyString
        if baseServiceUrl.hasSuffix("/") {
            newUrl = String(format: "%@%@", baseServiceUrl, "v1/" + endPoint)
        } else {
            if endPoint.hasPrefix("/") {
                newUrl = String(format: "%@%@", baseServiceUrl, "v1/" + endPoint)
            } else {
                newUrl = String(format: "%@/%@", baseServiceUrl, "v1/" + endPoint)
            }
        }
        return newUrl
    }
    
    public func baseUrlV2(endPoint: String) -> String {
        var newUrl = kEmptyString
        if baseServiceUrl.hasSuffix("/") {
            newUrl = String(format: "%@%@", baseServiceUrl, "v2/" + endPoint)
        } else {
            if endPoint.hasPrefix("/") {
                newUrl = String(format: "%@%@", baseServiceUrl,"v2/" +  endPoint)
            } else {
                newUrl = String(format: "%@/%@", baseServiceUrl, "v2/" + endPoint)
            }
        }
        return newUrl
    }
} 
