import UIKit
import Contacts
import DeviceKit
import Device

class SubAdminTabbar: RaisedTabBarController, UITabBarControllerDelegate {
    
    var controllers: [NavigationController] = []
    
    private enum ModuleType: Int {
        case profile = 0
        case chat  = 1
        case notification = 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        BrandManager.setDefaultTabTheam()
        if Utils.stringIsNullOrEmpty(Preferences.lastMsgSynced) { SOCKETMANAGER.syncUnReceivedMsg() }
        _setupController()
        NotificationCenter.default.addObserver(self, selector: #selector(handelOpenSuccessVC(_:)), name: .openPurchaseSuccessCard, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleInAppNotification(_:)), name: kInAppNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: kMessageNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: kUpdateMessageNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: kMessageCountNotification, object: nil)
        checkPushNotificationPermission()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .updateWhoIsInBadge, object: nil)
        NotificationCenter.default.removeObserver(self, name: kInAppNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .openPurchaseSuccessCard, object: nil)
        NotificationCenter.default.removeObserver(self, name: kMessageNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .readUpdatesState, object: nil)
        NotificationCenter.default.removeObserver(self, name: .switchToPersonalProfile, object: nil)
        NotificationCenter.default.removeObserver(self, name: .switchToPromoterProfile, object: nil)
        NotificationCenter.default.removeObserver(self, name: .switchToComplementaryProfile, object: nil)
        NotificationCenter.default.removeObserver(self, name: .changeUserProfileTypeUpdateState, object: nil)
        NotificationCenter.default.removeObserver(self, name: kMessageCountNotification, object: nil)
    }
    
    func checkPushNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self._requestPushNotificationPermission()
            case .authorized:
                NOTIFICATION.sync()
                //                self._requestContactList()
                
            default:
                print("")
                //                self._requestContactList()
            }
        }
    }
    
    private func _requestPushNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
            NOTIFICATION.sync()
            //            self._requestContactList()
        }
    }
    
    private func _requestContactList() {
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        switch authorizationStatus {
        case .notDetermined:
            print("")
            //            WHOSINCONTACT.sync()
        default:
            print("Contact permission not available")
        }
    }
    
    private func _syncContacts() {
        //        if !WHOSINCONTACT.didSync {
        //            WHOSINCONTACT.syncContactApi()
        //        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateChatMessageCount()
        APPSETTING._requestAppSetting { data in
            if APPSETTING.loginRequests.isEmpty { return }
            if let approvalModel = APPSETTING.loginRequests.first {
                guard let currentController = APP.window?.rootViewController else { return }
                if let visibleVc = Utils.getVisibleViewController(from: currentController) {
                    if visibleVc is SignInVerificationVC {
                        return
                    }
                }
                if approvalModel.metadata?.deviceId != Utils.getDeviceID() {
                    let vc = INIT_CONTROLLER_XIB(SignInVerificationVC.self)
                    vc.modalPresentationStyle = .overFullScreen
                    vc.approvalModel = approvalModel
                    Utils.openViewController(vc)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !Preferences.chatNotificationData.isEmpty {
            NOTIFICATION.handleFcmEvent(Preferences.chatNotificationData)
        } else if !Preferences.deepLink.isEmpty, let url = URL(string: Preferences.deepLink) {
            NOTIFICATION.handleDynamicLinkEvent(url)
        }
    }
    
    @objc func appDidBecomeActive() {
        if !APPSESSION.didLogin {
            return
        }
        if !Preferences.chatNotificationData.isEmpty {
            NOTIFICATION.handleFcmEvent(Preferences.chatNotificationData)
        } else if !Preferences.deepLink.isEmpty, let url = URL(string: Preferences.deepLink) {
            NOTIFICATION.handleDynamicLinkEvent(url)
        }
        updateChatMessageCount()
        APPSESSION.getUpdate()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupController() {
        let profileVC = INIT_CONTROLLER_XIB(SubAdminProfileVC.self)
        profileVC.tabBarItem.title = "profile".localized()
        profileVC.tabBarItem.image = UIImage(named: "tab_profile")
        profileVC.tabBarItem.selectedImage = UIImage(named: "tab_profile_selected")
        profileVC.tabBarItem.tag = ModuleType.profile.rawValue
        controllers.append(NavigationController(rootViewController: profileVC))
        
        let chatVC = INIT_CONTROLLER_XIB(SubAdminChatHomeVC.self)
        chatVC.tabBarItem.title = "chat".localized()
        chatVC.tabBarItem.image = UIImage(named: "tab_chat")
        chatVC.tabBarItem.selectedImage = UIImage(named: "tab_chat_selected")
        ChatRepository().getAllUnReadMessagesCount(callback: { counts in
            if counts > 0 {
                chatVC.tabBarItem.badgeValue = "\(counts)"
            } else {
                chatVC.tabBarItem.badgeValue = nil
            }
        })
        chatVC.tabBarItem.tag = ModuleType.chat.rawValue
        controllers.append(NavigationController(rootViewController: chatVC))
        
        let exploreVC = INIT_CONTROLLER_XIB(SubAdminNotification.self)
        exploreVC.tabBarItem.title = "notification".localized()
        exploreVC.tabBarItem.image = UIImage(named: "icon_notification")
        exploreVC.tabBarItem.selectedImage = UIImage(named: "icon_notification")
        exploreVC.tabBarItem.tag = ModuleType.notification.rawValue
        controllers.append(NavigationController(rootViewController: exploreVC))
        
        viewControllers = controllers
        delegate = self
        
        tabBar.items?.forEach({ item in
            if Device.size() <= .screen5_5Inch {
                item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -5, right: 0)
                item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -2.5)
            } else {
                item.imageInsets = UIEdgeInsets(top: .zero, left: .zero, bottom: -5, right: .zero)
                item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 5)
            }
        })
        
    }
    
    private func updateChatMessageCount() {
        ChatRepository().getAllUnReadMessagesCount(callback: { count in
            DispatchQueue.main.async {
                if count > 0 {
                    self.controllers[1].tabBarItem.badgeValue = "\(count)"
                } else {
                    self.controllers[1].tabBarItem.badgeValue = nil
                }
            }
        })
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @objc private func handelOpenSuccessVC(_ notification: Notification) {
        DISPATCH_ASYNC_MAIN_AFTER(0.001) {
            let destinationViewController = PurchaseSuccessVC()
            let navigationController = UINavigationController(rootViewController: destinationViewController)
            navigationController.modalPresentationStyle = .overFullScreen
            guard let rootVc = APP.window?.rootViewController else { return }
            if let visibleVc = Utils.getVisibleViewController(from: rootVc) {
                if visibleVc is PurchaseSuccessVC {
                    return
                }
                visibleVc.present(navigationController, animated: true)
            } else {
                self.present(navigationController, animated: true)
            }
        }
    }
    
    @objc func handleNotification(_ notification: Notification) {
        updateChatMessageCount()
    }
    
    @objc func handleInAppNotification(_ notification: Notification) {
        guard let model = notification.object as? InAppNotificationModel, APPSESSION.didLogin else { return }
        let vc = INIT_CONTROLLER_XIB(InAppNotificationVc.self)
        vc.modalPresentationStyle = .overFullScreen
        vc.inAppData = model
        
        if let presented = self.selectedViewController?.presentedViewController {
            presented.present(vc, animated: true)
        } else {
            self.selectedViewController?.present(vc, animated: true)
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let selectedIndex = tabBarController.selectedIndex
        if  selectedIndex == tabBarController.viewControllers?.firstIndex(of: viewController) {
            guard let navigationController = viewController as? UINavigationController else {
                return true
            }
            
            if let homeVc = navigationController.viewControllers.first as? HomeVC {
                let tableView = homeVc._tableView
                tableView?.setContentOffset(CGPoint.zero, animated: true)
            } else if let exploreVc = navigationController.viewControllers.first as? ExploreVC {
                let tableView = exploreVc._tableView
                let contentOffset = CGPoint(x: 0, y: 0)
                tableView?.setContentOffset(contentOffset, animated: true)
            }
        }
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
    }
    
}
