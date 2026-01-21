import OneSignal
import UIKit

let ONESIGNALMANAGER = OnesingalManager.shared

class OnesingalManager: NSObject {
    
    // -------------------------------------
    // MARK: Singleton
    // --------------------------------------

    class var shared: OnesingalManager {
        struct Static {
            static let instance = OnesingalManager()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
    }

    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    func setup(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        // Logging (optional)
        OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)

        // Initialize with launch options
        OneSignal.initWithLaunchOptions(launchOptions)
        OneSignal.setAppId("91f4e93d-6787-4a21-abcb-04f5b8d71bc8")

        // Prompt user for notification permission
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })

        // Handle notification in foreground
        OneSignal.setNotificationWillShowInForegroundHandler { notification, completion in
//            print("Foreground notification received: \(notification.notification.title ?? "")")
            completion(notification) // Show the notification
        }

        // Handle notification opened
        OneSignal.setNotificationOpenedHandler { result in
            print("Notification opened with data: \(result.notification.additionalData ?? [:])")
        }
        
        getPlayerId()
    }
    
    func getPlayerId() {
        let state = OneSignal.getDeviceState()
        let playerId = state?.userId
        print("Player ID: \(playerId ?? "nil")")
        guard let playerId = playerId else { return }
        WhosinServices.registerPlayer(plyerId: playerId){ model , error in
            print(error ?? "")
        }
    }



}
