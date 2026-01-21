import Foundation
import DeviceCheck

let APPINTIGRITY = AppIntegrityManager.shared

class AppIntegrityManager: NSObject {
    
    class var shared: AppIntegrityManager {
        struct Static {
            static let instance = AppIntegrityManager()
        }
        return Static.instance
    }

    override init() {
        super.init()
    }
    
    
    func generateDeviceToken(completion: @escaping (String?, Error?) -> Void) {
        let device = DCDevice.current
        
        guard device.isSupported else {
            completion(nil, NSError(domain: "DeviceCheck", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to generate device token."]))
            return
        }
        
        device.generateToken { token, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let token = token else {
                completion(nil, NSError(domain: "DeviceCheck", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to generate device token."]))
                return
            }
            
            let tokenString = token.base64EncodedString()
            completion(tokenString, nil)
        }
    }

}
