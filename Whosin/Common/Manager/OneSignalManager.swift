//import OneSignal
import OneSignalFramework
import OneSignalCore
import OneSignalUser
import UIKit
import SwiftyJSON

let ONESIGNALMANAGER = OnesingalManager.shared

class OnesingalManager: NSObject, OSNotificationPermissionObserver, OSUserStateObserver, OSNotificationClickListener, OSNotificationLifecycleListener {
    
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
        OneSignal.Debug.setLogLevel(.LL_VERBOSE)

        // Initialize with launch options
        OneSignal.init()
        OneSignal.initialize("91f4e93d-6787-4a21-abcb-04f5b8d71bc8", withLaunchOptions: launchOptions)
        // Prompt user for notification permission
        OneSignal.Notifications.requestPermission({ accepted in
          print("User accepted notifications: \(accepted)")
            if (accepted) {
                OneSignal.User.pushSubscription.optIn()
            }
        }, fallbackToSettings: false)

        OneSignal.Notifications.addPermissionObserver(self)
        OneSignal.Notifications.addClickListener(self)
        OneSignal.Notifications.addForegroundLifecycleListener(self)
        
        OneSignal.User.addObserver(self)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.getPlayerId()
        }
    }
    
    func getPlayerId() {
        guard let id = OneSignal.User.onesignalId else {
            print("Device state is nil")
            return
        }

        print("Player ID: \(id)")


        WhosinServices.registerPlayer(plyerId: id) { model, error in
            print(error ?? "")
        }
    }
    
    func onNotificationPermissionDidChange(_ permission: Bool) {
        print("Permission state changed: \(permission)")
    }
    
    func onUserStateDidChange(state: OneSignalUser.OSUserChangedState) {
        print("Push Enabled: \(state)")
    }
    
    private func _onNotificaitonReloadData(_ userInfo: [AnyHashable: Any]) {
        let data = JSON(userInfo)
        print(data)
        guard let dictionary = data.dictionaryObject else { return }

        if let custom = dictionary["custom"] as? [String: Any],
           let a = custom["a"] as? [String: Any],
           let type = a["type"] as? String,
           let id = a["id"] as? String {

            print("🔔 Notification type: \(type), id: \(id)")

            switch type {
                
            case "invite", "promoter-event", "invite_rejected", "promoter-event-cancel", "promoter-event-invite":
                NotificationCenter.default.post(name: .changereloadNotificationUpdateState, object: nil)
                
            case "add-to-ring":
                NotificationCenter.default.post(name: .changereloadNotificationUpdateState, object: nil)
                
            case "join-my-ring":
                NotificationCenter.default.post(name: .reloadUsersNotification, object: nil)
                
            case "ring-request-accepted":
                NotificationCenter.default.post(name: .changeUserProfileTypeUpdateState, object: nil)
                NotificationCenter.default.post(name: .showAlertForUpgradeProfile, object: nil, userInfo: ["type": "complimentary"])
                
            case "ring-accepted", "ring-declined":
                NotificationCenter.default.post(name: .reloadUsersNotification, object: nil)
                NotificationCenter.default.post(name: .changereloadNotificationUpdateState, object: nil)
                                
            case "promoter-request", "promoter-request-accepted":
                NotificationCenter.default.post(name: .showAlertForUpgradeProfile, object: nil, userInfo: ["type": "promoter"])
                
            case "promoter-subadmin-remove":
                NotificationCenter.default.post(name: .showAlertForUpgradeProfile, object: nil, userInfo: ["type": "subadmin-remove"])
                
            case "add-to-plusone", "plusone-accepted":
                NotificationCenter.default.post(name: .reloadUsersNotification, object: nil)
                NotificationCenter.default.post(name: .changereloadNotificationUpdateState, object: nil)
                
            case "plusone-remove", "circle-remove", "ring-remove":
                NotificationCenter.default.post(name: .showAlertForUpgradeProfile, object: nil, userInfo: ["type": type])
                NotificationCenter.default.post(name: .reloadMyEventsNotifier, object: nil)
                
            case "plusone-leave", "cm-leave-ring":
                NotificationCenter.default.post(name: .changereloadNotificationUpdateState, object: nil)
                NotificationCenter.default.post(name: .reloadMyEventsNotifier, object: nil)
                
            case "ticket":
                NotificationCenter.default.post(name: Notification.Name("reloadMyWallet"), object: nil)

            case "review-ticket":
                NotificationCenter.default.post(name: .openTicketReview, object: nil, userInfo: ["ticketId": id])

            default:
                break
            }
        }
    }

    func onWillDisplay(event: OSNotificationWillDisplayEvent) {
        _onNotificaitonReloadData(event.notification.rawPayload)
    }

    
    func onClick(event: OSNotificationClickEvent) {
        NOTIFICATION.handleFcmEvent(event.notification.rawPayload)
    }
    


}
