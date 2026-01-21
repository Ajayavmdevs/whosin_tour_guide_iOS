import UIKit
import Device

protocol CloseTabbarDelegate: AnyObject {
    func close()
}

class PromoterTabbarVC: RaisedTabBarController, UITabBarControllerDelegate  {
    
    var controllers: [UIViewController] = []
    
    private enum ModuleType: Int {
        case profile = 0
        case events  = 1
        case eventhistory = 2
        case message = 3
        case notification = 4
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setTabBarTheme()
        _setupController()
    }
    
    private func _setTabBarTheme() {
        let tabBarAppearance = UITabBar.appearance()
        let tabBarItemAppearance = UITabBarItem.appearance()

        tabBarAppearance.tintColor = ColorBrand.tabBarTintColor
        tabBarAppearance.unselectedItemTintColor = ColorBrand.tabBarUnselectedColor
        
        // Make tabbar translucent so background image shows through
        tabBarAppearance.isTranslucent = true
        tabBarAppearance.barTintColor = .clear
        tabBarAppearance.backgroundColor = .clear
        tabBarAppearance.backgroundImage = UIImage(named: "tab_bg")
        tabBarAppearance.shadowImage = UIImage() // remove default shadow line

        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()

            // Apply your custom image as background
            if let bg = UIImage(named: "tab_bg") {
                appearance.backgroundImage = bg
            }
            appearance.backgroundColor = .clear
            appearance.shadowColor = .clear

            // Normal state
            appearance.stackedLayoutAppearance.normal.iconColor = ColorBrand.tabBarUnselectedColor
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: ColorBrand.tabBarUnselectedColor,
                .font: FontBrand.tabbarTitleFont
            ]

            // Selected state
            appearance.stackedLayoutAppearance.selected.iconColor = ColorBrand.tabBarSeltectedColor
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: ColorBrand.tabBarSeltectedColor,
                .font: FontBrand.tabbarSelectedTitleFont
            ]

            tabBarAppearance.standardAppearance = appearance
            if #available(iOS 15.0, *) {
                tabBarAppearance.scrollEdgeAppearance = appearance
            }
        } else {
            tabBarItemAppearance.setTitleTextAttributes([
                .foregroundColor: ColorBrand.tabBarUnselectedColor,
                .font: FontBrand.tabbarTitleFont
            ], for: .normal)
            tabBarItemAppearance.setTitleTextAttributes([
                .foregroundColor: ColorBrand.tabBarSeltectedColor,
                .font: FontBrand.tabbarSelectedTitleFont
            ], for: .selected)
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupController() {
        let profileVC = INIT_CONTROLLER_XIB(PromoterVC.self)
        profileVC.tabBarItem.title = "my_profile".localized()
        profileVC.tabBarItem.image = UIImage(named: "profile")
        profileVC.tabBarItem.selectedImage = UIImage(named: "profile_selected")
        profileVC.tabBarItem.tag = ModuleType.profile.rawValue
        profileVC.hideNavigationBar()
        profileVC.delegate = self
        controllers.append(profileVC)
        
        let eventsVC = INIT_CONTROLLER_XIB(PromoterEventListVC.self)
        eventsVC.tabBarItem.title = "my_event".localized()
        eventsVC.tabBarItem.image = UIImage(named: "event")
        eventsVC.tabBarItem.selectedImage = UIImage(named: "event_selected")
        eventsVC.tabBarItem.tag = ModuleType.events.rawValue
        eventsVC.hideNavigationBar()
        eventsVC.delegate = self
        controllers.append(eventsVC)
        
        let eventhistoryVC = INIT_CONTROLLER_XIB(PromoterEventHistoryVC.self)
        eventhistoryVC.tabBarItem.title = "event_history".localized()
        eventhistoryVC.tabBarItem.image = UIImage(named: "event_history")
        eventhistoryVC.tabBarItem.selectedImage = UIImage(named: "event_history_selected")
        eventhistoryVC.tabBarItem.tag = ModuleType.eventhistory.rawValue
        eventhistoryVC.hideNavigationBar()
        eventhistoryVC.delegate = self
        controllers.append(eventhistoryVC)
        
        let messageVC = INIT_CONTROLLER_XIB(PromoterChatsVC.self)
        messageVC.tabBarItem.title = "promoter_message".localized()
        messageVC.tabBarItem.image = UIImage(named: "message")
        messageVC.tabBarItem.selectedImage = UIImage(named: "message_selected")
        messageVC.tabBarItem.tag = ModuleType.message.rawValue
        messageVC.hideNavigationBar()
        messageVC.delegate = self
        controllers.append(messageVC)
        
        let notificationVC = INIT_CONTROLLER_XIB(PromoterNotificationsVC.self)
        notificationVC.tabBarItem.title = "notifications".localized()
        notificationVC.tabBarItem.image = UIImage(named: "notification")
        notificationVC.tabBarItem.selectedImage = UIImage(named: "notification_selected")
        notificationVC.tabBarItem.tag = ModuleType.notification.rawValue
        notificationVC.hideNavigationBar()
        notificationVC.delegate = self
        controllers.append(notificationVC)
        
        viewControllers = controllers
        delegate = self

        tabBar.items?.forEach({ item in
            if Device.size() <= .screen5_5Inch {
                item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -6, right: 0)
                item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -2.5)
            } else {
                item.imageInsets = UIEdgeInsets(top: 2, left: 0, bottom: -3, right: 0)
                item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 5)
            }
        })

        
        
        func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
            let selectedIndex = tabBarController.selectedIndex
            if  selectedIndex == tabBarController.viewControllers?.firstIndex(of: viewController) {
                guard let navigationController = viewController as? UINavigationController else {
                    return true
                }
            }
            return true
        }
        
        func dismissVC() {
            navigationController?.popToRootViewController(animated: true)
        }
        
        func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
            
        }
    }
}

extension PromoterTabbarVC: CloseTabbarDelegate {
    func close() {
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 0
        }

        if self.isBeingPresented {
            self.dismiss(animated: true, completion: nil)
        } else if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
}

