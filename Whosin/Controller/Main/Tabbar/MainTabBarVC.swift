import UIKit
import Contacts
import Device
import AppTrackingTransparency

class MainTabBarVC: RaisedTabBarController, UITabBarControllerDelegate {
        
    var controllers: [NavigationController] = []
    public var containerView: UIView?
    private let cornerMargin: CGFloat = 5
    private var isMiniPlayerLoading: Bool = false
    
    private enum ModuleType: Int {
        case home = 0
        case chat  = 1
        case profile = 2
        case explore = 3
        case wallet = 4
    }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        BrandManager.setDefaultTabTheam()
        if Utils.stringIsNullOrEmpty(Preferences.lastMsgSynced) { SOCKETMANAGER.syncUnReceivedMsg() }
        _setupController()
        NotificationCenter.default.addObserver(self, selector: #selector(handelOpenSuccessVC(_:)), name: .openPurchaseSuccessCard, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handelOpenReviewVC(_:)), name: .openTicketReview, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handelOpenReportSuccessVC(_:)), name: .openReportSuccessCard, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleInAppNotification(_:)), name: kInAppNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: kMessageNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: kUpdateMessageNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserUpdateState(_:)), name: .changeUserProfileTypeUpdateState, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: kMessageCountNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleShowAlert(_:)), name: .showAlertForUpgradeProfile, object: nil)
        checkPushNotificationPermission()
        DISPATCH_ASYNC_MAIN_AFTER(0.1) {
            if APPSETTING.inAppModel != nil, let model = APPSETTING.inAppModel {
                self.handleOpenDetailByType(model)
            }
        }
        requestTrackingPermission()
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
        NotificationCenter.default.removeObserver(self, name: .revokeSubAdminAccess, object: nil)
    }
    
    func requestTrackingPermission() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized:
                        print("Tracking authorized")
                    case .denied:
                        print("Tracking denied")
                    case .restricted:
                        print("Tracking restricted")
                    case .notDetermined:
                        print("Tracking not determined")
                    @unknown default:
                        break
                    }
                }
            }
        }
    }
    
    func checkPushNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self._requestPushNotificationPermission()
            case .authorized:
                NOTIFICATION.sync()
            default:
                print("")
            }
        }
    }
    
    private func _requestPushNotificationPermission() {
            NOTIFICATION.sync()
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
        controllers = []
        let homeVC = INIT_CONTROLLER_XIB(HomeVC.self)
        homeVC.tabBarItem.title = "home".localized()
        homeVC.tabBarItem.image = UIImage(named: "tab_home")
        homeVC.tabBarItem.selectedImage = UIImage(named: "tab_home_selected")
        homeVC.tabBarItem.tag = ModuleType.home.rawValue
        controllers.append(NavigationController(rootViewController: homeVC))
        
        let searchVC = INIT_CONTROLLER_XIB(NewSearchVC.self)
        searchVC.tabBarItem.title = "search".localized()
        searchVC.tabBarItem.image = UIImage(named: "search_tab")
        searchVC.tabBarItem.selectedImage = UIImage(named: "search_selected")
        searchVC.tabBarItem.tag = ModuleType.explore.rawValue
        controllers.append(NavigationController(rootViewController: searchVC))

        let profileVC: UIViewController
        profileVC = INIT_CONTROLLER_XIB(ProfileMenuVC.self)
        profileVC.tabBarItem.title = ""
        profileVC.tabBarItem.image = UIImage(named: "tab_homeprofile")
        profileVC.tabBarItem.selectedImage = UIImage(named: "tab_homeprofile_selected")
        profileVC.tabBarItem.tag = ModuleType.profile.rawValue
        controllers.append(NavigationController(rootViewController: profileVC))

        let exploreVC = INIT_CONTROLLER_XIB(NewExploreVC.self)
        exploreVC.tabBarItem.title = "explore".localized()
        exploreVC.tabBarItem.image = UIImage(named: "tab_explore")
        exploreVC.tabBarItem.selectedImage = UIImage(named: "tab_explore_selected")
        exploreVC.tabBarItem.tag = ModuleType.explore.rawValue
        controllers.append(NavigationController(rootViewController: exploreVC))

        let walletVC = INIT_CONTROLLER_XIB(MyWalletVC.self)
        walletVC.tabBarItem.title = "home_tab_wallet".localized()
        walletVC.isFromProfile = false
        walletVC.tabBarItem.image = UIImage(named: "tab_wallet")
        walletVC.tabBarItem.selectedImage = UIImage(named: "tab_wallet_selected")
        walletVC.tabBarItem.tag = ModuleType.wallet.rawValue
        walletVC.tabBarItem.badgeValue = nil
        controllers.append(NavigationController(rootViewController: walletVC))
        controllers.forEach { $0.delegate = self }

        


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
        guard controllers.count > 1 else { return }
    }
        
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
        
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let container = containerView else { return }
        let translation = gesture.translation(in: view)

        let tabBarHeight = tabBar.frame.height
        let margin: CGFloat = 5

        // Updated: Get safeAreaInsets from window!
        let windowSafeAreaTop: CGFloat
        if let window = UIApplication.shared.windows.first(where: \.isKeyWindow) {
            windowSafeAreaTop = window.safeAreaInsets.top
        } else {
            windowSafeAreaTop = 0
        }

        var newCenter = container.center
        newCenter.x += translation.x
        newCenter.y += translation.y

        let halfWidth = container.bounds.width / 2
        let halfHeight = container.bounds.height / 2

        let leftLimit = margin + halfWidth
        let rightLimit = view.bounds.width - margin - halfWidth
        let topLimit = windowSafeAreaTop + margin + halfHeight
        let bottomLimit = view.bounds.height - tabBarHeight - margin - halfHeight

        newCenter.x = max(leftLimit, min(newCenter.x, rightLimit))
        newCenter.y = max(topLimit, min(newCenter.y, bottomLimit))

        container.center = newCenter
        gesture.setTranslation(.zero, in: view)

        if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
            snapContainerToNearestCorner()
        }
    }

    private func snapContainerToNearestCorner() {
        guard let container = containerView else { return }
        let margin: CGFloat = 5
        let tabBarHeight = tabBar.frame.height
        let screenWidth = view.bounds.width
        let screenHeight = view.bounds.height

        let halfWidth = container.bounds.width / 2
        let halfHeight = container.bounds.height / 2

        let bottomY = screenHeight - tabBarHeight - margin - halfHeight
        let windowSafeAreaTop: CGFloat
        if let window = UIApplication.shared.windows.first(where: \.isKeyWindow) {
            windowSafeAreaTop = window.safeAreaInsets.top
        } else {
            windowSafeAreaTop = 0
        }
        let topY = windowSafeAreaTop + margin + halfHeight


        let possibleCorners = [
            CGPoint(x: margin + halfWidth, y: bottomY),          // Bottom Left
            CGPoint(x: screenWidth - margin - halfWidth, y: bottomY),  // Bottom Right
            CGPoint(x: margin + halfWidth, y: topY),             // Top Left
            CGPoint(x: screenWidth - margin - halfWidth, y: topY)     // Top Right
        ]

        let containerCenter = container.center
        let closestCorner = possibleCorners.min(by: {
            containerCenter.distance(to: $0) < containerCenter.distance(to: $1)
        }) ?? possibleCorners[1]

        UIView.animate(withDuration: 0.3) {
            container.center = closestCorner
        }
    }
    
    override func onRaisedButton(_ sender: UIButton) {
        if selectedIndex == 0, let navigationController = self.selectedViewController as? UINavigationController {
            if let homeVc = navigationController.viewControllers.first as? HomeVC {
                homeVc.pauseVideoWhenDisappear()
            }
        }
    }
    
    
    @objc private func handleUserUpdateState(_ notification: Notification) {
        APPSESSION.getProfile { isSuccess, error in }
        APPSESSION.userDetail?.isRingMember = true
        Preferences.profileType = ProfileType.complementaryProfile
        DISPATCH_ASYNC_MAIN_AFTER(0.3) {
            self._setupController()
        }
    }

    @objc private func handelOpenReportSuccessVC(_ notification: Notification) {
        DISPATCH_ASYNC_MAIN_AFTER(0.001) {
            let destinationViewController = ReportSuccessVC()
            let navigationController = UINavigationController(rootViewController: destinationViewController)
            navigationController.modalPresentationStyle = .overFullScreen
            guard let rootVc = APP.window?.rootViewController else { return }
            if let visibleVc = Utils.getVisibleViewController(from: rootVc) {
                if visibleVc is ReportSuccessVC {
                    return
                }
                visibleVc.present(navigationController, animated: true)
            } else {
                self.present(navigationController, animated: true)
            }
        }
    }
    
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
    
    @objc private func handelOpenReviewVC(_ notification: Notification) {
        let ticketId = notification.userInfo?["ticketId"] as? String

        DISPATCH_ASYNC_MAIN_AFTER(0.001) {
            let destinationViewController = WriteTicketReview()
            destinationViewController._ticketId = ticketId ?? ""
            destinationViewController.showToast = { [weak self] msg in
                guard let self = self else { return }
                self.showToast(msg)
            }
            let navigationController = UINavigationController(rootViewController: destinationViewController)
            navigationController.modalPresentationStyle = .overFullScreen
            guard let rootVc = APP.window?.rootViewController else { return }
            if let visibleVc = Utils.getVisibleViewController(from: rootVc) {
                if visibleVc is WriteTicketReview {
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
    
    @objc func handleShowAlert(_ notification: Notification) {
        let message = notification.userInfo?["type"] as? String ?? "complimentary"
        let vc = INIT_CONTROLLER_XIB(RestartAppPopupVC.self)
        vc._msg = message
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true)
    }

    private func restartApp() {
        if APP.window == nil { APP.window = UIWindow(frame: UIScreen.main.bounds) }
        guard let window = APP.window else { return }
        window.backgroundColor = ColorBrand.brandAppBgColor
        window.setRootViewController(INIT_CONTROLLER_XIB(SplashViewController.self), options: UIWindow.TransitionOptions(direction:.fade, style: .easeInOut))
    }
    
    @objc func handleInAppNotification(_ notification: Notification) {
        guard let model = notification.object as? InAppNotificationModel, APPSESSION.didLogin else { return }
        let vc = INIT_CONTROLLER_XIB(InAppNotificationVc.self)
        vc.modalPresentationStyle = .overFullScreen
        vc.inAppData = model
        vc.openDetailScreen = { [weak self] view in
            guard let self = self else { return }
            self.handleOpenDetailByType(view)
        }
        guard let rootVc = APP.window?.rootViewController else { return }
        if let visibleVc = Utils.getVisibleViewController(from: rootVc) {
            if visibleVc is InAppNotificationVc {
                return
            }
            visibleVc.modalPresentationStyle = .overFullScreen
            visibleVc.present(vc, animated: true)
        } else {
            self.selectedViewController?.present(vc, animated: true)
        }
    }
    
    private func handleOpenDetailByType(_ view: IANComponentModel) {
        guard let rootVc = APP.window?.rootViewController else { return }
        switch view.action {
        case "link":
            guard let url = URL(string: view.data) else { return }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case "ticket":
            let vc = INIT_CONTROLLER_XIB(CustomTicketDetailVC.self)
            vc.ticketID = view.data
            vc.hidesBottomBarWhenPushed = true
            self.navigationViewController(rootVc, vc: vc)
        case "ticket-booking":
            guard let window = APP.window  else { return }
            if let navController = window.rootViewController as? UINavigationController,
               let tabBarController = navController.viewControllers.first as? MainTabBarVC,
               tabBarController.selectedIndex == 4 {
                return
            }
            let controller = INIT_CONTROLLER_XIB(MainTabBarVC.self)
            controller.selectedIndex = 4
            let navController = NavigationController(rootViewController: controller)
            navController.setNavigationBarHidden(true, animated: false)
            window.setRootViewController(navController, options: UIWindow.TransitionOptions(direction:.fade, style: .easeInOut))
        default:
            break
        }
    }
    
    private func navigationViewController(_ rootVc: UIViewController, vc: UIViewController) {
        if let visibleVc = Utils.getVisibleViewController(from: rootVc) {
            if visibleVc is InAppNotificationVc {
                return
            }
            visibleVc.modalPresentationStyle = .overFullScreen
            visibleVc.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.selectedViewController?.navigationController?.pushViewController(vc, animated: true)
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
            }
        }
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let nav = viewController as? UINavigationController else { return }

    }


}

extension MainTabBarVC: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if navigationController.viewControllers.first != viewController {
        }
    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let idx = controllers.firstIndex(of: navigationController as? NavigationController ?? NavigationController()),
              idx == selectedIndex else { return }
    }
}

fileprivate extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return hypot(self.x - point.x, self.y - point.y)
    }
}
