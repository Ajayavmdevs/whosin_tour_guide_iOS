import UIKit
import NISdk
import Contacts
import IQKeyboardManagerSwift
//import GoogleSignIn
//import FBSDKCoreKit
import Firebase
//import FirebaseMessaging
//import AppTrackingTransparency
import RealmSwift
import SwiftyJSON
import Tabby
import Amplitude
import OneSignalCore
import OneSignalFramework
import OneSignalLiveActivities
import OneSignalNotifications
import FirebaseCrashlytics


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let amplitudeApiKey = "9cf47a10efd1f2cfbac59d9ed62a345c"


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        print("\n/////////////////////////////////////////////////////////////////////////////////////")
        print("* API WEBSERVICE BASE URL: \(URLMANAGER.baseUrl(endPoint: kEmptyString))")
        print("\n/////////////////////////////////////////////////////////////////////////////////////")
        
        // ===============================
        // INITIALIZATIONS
        // ===============================
//        UIApplication.shared.registerForRemoteNotifications()
        LANGMANAGER.getLocalizeFile()
        _ = NISdk.sharedInstance
        Log.setup()
        
        Amplitude.instance().initializeApiKey(amplitudeApiKey)
        Amplitude.instance().trackingSessionEvents = true
        Amplitude.instance().setUserId(APPSESSION.userId) // Set user ID if available
        _ = ScreenshotShareManager.shared
        BrandManager.setDefaultTheme()
        IQKeyboardManager.shared.enable = true
        
        // ===============================
        // ScocketIO Connection
        // ===============================
        
        Repository.configRealm()
        
        // ===============================
        // Firebase & Push Notification
        // ===============================
        
        _configureFirebaseSafely()
        ONESIGNALMANAGER.setup(launchOptions: launchOptions)


        // ===============================
        // Facebook
        // ===============================
        
//        FBSDKCoreKit.ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        UNUserNotificationCenter.current().delegate = self
//        application.registerUserNotificationSettings(UIUserNotificationSettings())
        
        // ===============================
        // ROOT CONTROLLER
        // ===============================
        
        if APP.window == nil { APP.window = UIWindow(frame: UIScreen.main.bounds) }
        guard let window = APP.window else { return true }
        window.backgroundColor = ColorBrand.brandAppBgColor
        window.setRootViewController(INIT_CONTROLLER_XIB(SplashViewController.self), options: UIWindow.TransitionOptions(direction:.fade, style: .easeInOut))
        
        // ===============================
        // Network manager
        // ===============================
        
        StatusBarOverlay.host = "https://google.com"
        StatusBarOverlay.defaultBackgroundColor = .red
        
        // ===============================
        // APP SETTING
        // ===============================
        APPSETTING.configoreLocation()
        if APPSESSION.didLogin {
            APPSETTING.configure()
//            ADSETTING.requestAdSetting()
            NOTIFICATION.getUnreadCount()
            APPSESSION.getUpdate()
            APPSESSION.didCloseMiniPlayer = false
            SOCKETMANAGER.establishConnection()
        }
//        _syncContacts()
        if let url = launchOptions?[.url] as? URL {
            NOTIFICATION.handleDynamicLinkEvent(url)
        }
        
        if let remoteNotif = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                NOTIFICATION.handleFcmEvent(remoteNotif)
            }
        }

        
        return true
    }
    
    private func _configureFirebaseSafely() {
        guard let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
            print("Firebase configuration skipped: GoogleService-Info.plist not found")
            return
        }
        guard let options = FirebaseOptions(contentsOfFile: filePath) else {
            print("Firebase configuration skipped: Invalid options from GoogleService-Info.plist")
            return
        }
        let mainBundleId = Bundle.main.bundleIdentifier ?? ""
        if options.bundleID == mainBundleId {
            FirebaseApp.configure(options: options)
            print("Firebase configured for bundle id: \(mainBundleId)")
        } else {
            print("Firebase configuration skipped: bundle id mismatch. GoogleService bundleID=\(options.bundleID), app bundleID=\(mainBundleId)")
        }
    }
    
//    private func _syncContacts() {
//        _requestContactList { isAuthorize in
//            if isAuthorize {
//                DispatchQueue.global(qos: .background).async {
//                    WHOSINCONTACT.sync()
//                }
//            }
//        }
//    }
    
//    private func _requestContactList(completion: @escaping (Bool) -> Void) {
//        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
//        switch authorizationStatus {
//        case .authorized:
//            completion(true)
//        default:
//            completion(false)
//        }
//    }
    
//    private func _checkPushNotificationPermission(completion: @escaping (Bool) -> Void) {
//        UNUserNotificationCenter.current().getNotificationSettings { settings in
//            switch settings.authorizationStatus {
//            case .authorized:
//                completion(true)
//            default:
//                completion(false)
//            }
//        }
//    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        resetBadgeCount()
        APPSETTING.configure()
//        _syncContacts()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme?.lowercased() == "whosinapp" {
            let state = UIApplication.shared.applicationState
            if state == .active {
                NOTIFICATION.handleDynamicLinkEvent(url)
            } else {
                Preferences.deepLink = url.toString
            }
            return true
        }
        return false
    }
    
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if let topVC = window?.rootViewController?.presentedViewController, topVC is LandscapeVideoVC {
            return .all
        }
        return .portrait
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let url = userActivity.webpageURL {
            var parameters: [String: String] = [:]
            URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
                parameters[$0.name] = $0.value
            }
        }
        if let url = userActivity.webpageURL {
            let state = UIApplication.shared.applicationState
            if state == .active {
                NOTIFICATION.handleDynamicLinkEvent(url)
            } else {
                Preferences.deepLink = url.toString
            }
        }
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Log.debug("FCM message =\(userInfo)")
//        NOTIFICATION.handleFcmEvent(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Log.error(error.localizedDescription)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce(kEmptyString) {
            $0 + String(format: "%02X", $1)
        }
        Log.debug("APNS token retrieved: \(deviceTokenString)")
//        Messaging.messaging().apnsToken = deviceToken
//        NOTIFICATION.configure()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
//        resetBadgeCount()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        resetBadgeCount()
    }

    
    private func resetBadgeCount() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        UserDefaults(suiteName: "group.com.whosin.business.onesignal")?.set(0, forKey: "badgeCount")
        UserDefaults(suiteName: "group.com.whosin.business.onesignal")?.synchronize()
        print("Badge count reset to 0")
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
//    
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        let userInfo = response.notification.request.content.userInfo
//        print("FCM message =\(userInfo)")
//        let state = UIApplication.shared.applicationState
//        if state == .active {
//            NOTIFICATION.handleFcmEvent(userInfo)
//        } else {
//            Preferences.chatNotificationData = userInfo
//        }
//        let customID = userInfo["identifier"] as? String
//        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
//            let matching = notifications.filter { notify in
//                let existingUserInfo = notify.request.content.userInfo
//                let id = existingUserInfo["identifier"] as? String
//                return id == customID
//            }
//            let identifier = matching.map( {$0.request.identifier})
//            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifier)
//        }
//        completionHandler()
//    }
  
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        NOTIFICATION.getUnreadCount()
//        _onNotificaitonReloadData(userInfo)
        let chatId = NOTIFICATION.getChatId(userInfo)
        if chatId.isEmpty {
            APPSESSION.getUpdate()
        }
        if let visibleNavController = Utils.getVisibleViewController(from: APP.window?.rootViewController) as? UINavigationController {
            if let chatDetailVC = visibleNavController.topViewController as? ChatDetailVC {
                if chatDetailVC.chatModel?.chatId == chatId {
                    completionHandler([.sound])
                    return
                }
            }
            let chatDetailVC = ChatDetailVC()
            visibleNavController.pushViewController(chatDetailVC, animated: true)
            completionHandler([.sound])
        }
        completionHandler([.alert, .badge, .sound])
    }
 
//    private func _onNotificaitonReloadData(_ userInfo: [AnyHashable: Any]) {
//        let data = JSON(userInfo)
//        guard let dictionary = data.dictionaryObject else { return }
//
//        if let custom = dictionary["custom"] as? [String: Any],
//           let a = custom["a"] as? [String: Any],
//           let type = a["type"] as? String,
//           let id = a["id"] as? String {
//
//            print("🔔 Notification type: \(type), id: \(id)")
//
//            switch type {                
//                
//            case "invite", "promoter-event", "invite_rejected", "promoter-event-cancel", "promoter-event-invite":
//                NotificationCenter.default.post(name: .changereloadNotificationUpdateState, object: nil)
//                
//            case "add-to-ring":
//                NotificationCenter.default.post(name: .changereloadNotificationUpdateState, object: nil)
//                
//            case "join-my-ring":
//                NotificationCenter.default.post(name: .reloadUsersNotification, object: nil)
//                
//            case "ring-request-accepted":
//                NotificationCenter.default.post(name: .changeUserProfileTypeUpdateState, object: nil)
//                NotificationCenter.default.post(name: .showAlertForUpgradeProfile, object: nil, userInfo: ["type": "complimentary"])
//                
//            case "ring-accepted", "ring-declined":
//                NotificationCenter.default.post(name: .reloadUsersNotification, object: nil)
//                NotificationCenter.default.post(name: .changereloadNotificationUpdateState, object: nil)
//                
//            case "plusone-accepted":
//                NotificationCenter.default.post(name: .changereloadNotificationUpdateState, object: nil)
//                
//            case "promoter-request", "promoter-request-accepted":
//                NotificationCenter.default.post(name: .showAlertForUpgradeProfile, object: nil, userInfo: ["type": "promoter"])
//                
//            case "promoter-subadmin-remove":
//                NotificationCenter.default.post(name: .showAlertForUpgradeProfile, object: nil, userInfo: ["type": "subadmin-remove"])
//                
//            case "add-to-plusone", "plusone-accepted":
//                NotificationCenter.default.post(name: .reloadUsersNotification, object: nil)
//                NotificationCenter.default.post(name: .changereloadNotificationUpdateState, object: nil)
//                
//            case "plusone-remove", "circle-remove", "ring-remove":
//                NotificationCenter.default.post(name: .showAlertForUpgradeProfile, object: nil, userInfo: ["type": type])
//                NotificationCenter.default.post(name: .reloadMyEventsNotifier, object: nil)
//                
//            case "plusone-leave", "cm-leave-ring":
//                NotificationCenter.default.post(name: .changereloadNotificationUpdateState, object: nil)
//                NotificationCenter.default.post(name: .reloadMyEventsNotifier, object: nil)
//                
//            case "ticket":
//                NotificationCenter.default.post(name: Notification.Name("reloadMyWallet"), object: nil)
//
//            case "review-ticket":
//                NotificationCenter.default.post(name: .openTicketReview, object: nil, userInfo: ["ticketId": id])
//
//            default:
//                break
//            }
//        }
//    }
}
