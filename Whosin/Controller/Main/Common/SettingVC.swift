import UIKit
import Contacts
import FAPanels
import Hero

class SettingVC: ChildViewController {

    @IBOutlet private weak var _tableView: CustomTableView!
    
    private let kCellIdentifier = String(describing: ProfileSettingCell.self)
    var _menuList = [[String: Any]]()
    var _permissionList = [[String: Any]]()
    var heroId: String = String(describing: SettingVC.self)
    private var _isSwitchOn: Bool = false

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _addMenuData()
       _setupUi()
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func appWillEnterForeground() {
        _loadData()
    }

    deinit {
        // Remove observer when deinitializing
        NotificationCenter.default.removeObserver(self)
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
        view.hero.id = heroId
        view.hero.modifiers = HeroAnimationModifier.stories

        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "something_wrong".localized(),
            emptyDataIconImage: UIImage(named: "icon_empty_data"),
            emptyDataDescription: nil,
            delegate: self)
        _loadData()
    }
    
    private func _addMenuData() {
        
        if Preferences.isGuest == false {
            _menuList.append(["title" : "update_your_profile".localized(),"icon": "icon_updateProfile", "color": "#2E6EBA"])
            _menuList.append(["title" : "blocked_users_list".localized(),"icon": "icon_privacy", "color": "#781136"])
            _menuList.append(["title" : "reported_users_list".localized(),"icon": "icon_privacy", "color": "#781136"])
            _menuList.append(["title" : "my_reviews".localized(),"icon": "icon_privacy", "color": "#2E6EBA"])
        }
//        if !APPSETTING.currencies.isEmpty {
//            _menuList.append(["title" : "change_currency".localized(),"icon": "ic_currency", "color": "#2E6EBA"])
//        }
//        if !APPSETTING.languages.isEmpty {
//            _menuList.append(["title" : "change_language".localized(),"icon": "ic_language", "color": "#2E6EBA"])
//        }
        if Preferences.isGuest == false {
            _permissionList.append(["title" : "two_factor_authentication".localized(),"icon": "icon_privacy", "color": "#DC3C31"])
            _permissionList.append(["title" : "private_account".localized(),"icon": "profile_privacy", "color": "#2E6EBA"])
        }
        _permissionList.append(["title" : "allow_notification".localized(),"icon": "profile_notify", "color": "#781136"])
//        _permissionList.append(["title" : "Allow contacts","icon": "profile_permission", "color": "#781136"])
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        var id = 0
        _menuList.forEach { menuList in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: id,
                kCellObjectDataKey: menuList,
                kCellTitleKey: "Settings",
                kCellClassKey: ProfileSettingCell.self,
                kCellHeightKey: ProfileSettingCell.height
            ])
            id += 1
        }
        
        cellSectionData.append([kSectionTitleKey: "\n", kSectionDataKey: cellData])
        cellData.removeAll()
        
        _permissionList.forEach { permission in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: permission,
                kCellTitleKey: "permission",
                kCellClassKey: ProfileSettingCell.self,
                kCellHeightKey: ProfileSettingCell.height
            ])
        }
        
        cellSectionData.append([kSectionTitleKey: "\n", kSectionDataKey: cellData])

        _tableView.loadData(cellSectionData)
    }
    
    private var _prototype: [[String: Any]]? {
        return [
                [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: ProfileSettingCell.self, kCellHeightKey: ProfileSettingCell.height]
        ]
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}

// --------------------------------------
// MARK: Custom TableView
// --------------------------------------
extension SettingVC: CustomTableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? ProfileSettingCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [String : Any]  else { return }
            guard let title = cellDict?[kCellTitleKey] as? String  else { return }
            if object["title"] as? String == "allow_notification".localized() {
                _isSwitchOn = Utils.isAllowNotification()
            } else if object["title"] as? String == "allow_contacts".localized() {
                _isSwitchOn = !Utils.isAllowContactAccess()
            } else if object["title"] as? String == "private_account".localized() {
                guard let isPrivate = APPSESSION.userDetail?.isProfilePrivate else { return}
                _isSwitchOn = isPrivate
            } else if object["title"] as? String == "two_factor_authentication".localized() {
               guard let isEnable = APPSESSION.userDetail?.isTwoFactorActive else { return }
                _isSwitchOn = isEnable
            }
            cell.setupData(object, switchText: title, isSwitchOn: _isSwitchOn)
            cell.contentView.backgroundColor = ColorBrand.brandBSColor
            
            var corners: UIRectCorner = []
            if indexPath.row == 0 {
                corners.insert(.topLeft)
                corners.insert(.topRight)
                if APPSETTING.subscription != nil {
                    cell._buttonIcon.badgeNumber = 1
                }
            }
            
            let rows = _tableView.numberOfRows(inSection: indexPath.section)
            if rows == indexPath.row + 1 {
                corners.insert(.bottomLeft)
                corners.insert(.bottomRight)
            }
            cell.roundCorners(corners: corners, radius: 10)
            
        }
    }
    

    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellTitleKey] as? String  else { return }
        if object == "Settings" {
            if Preferences.isGuest {
                if indexPath.row == 0 {
                    let controller = INIT_CONTROLLER_XIB(CurrencySheet.self)
                    controller.isCurrency = true
                    self.presentAsPanModal(controller: controller)
                } else {
                    let controller = INIT_CONTROLLER_XIB(CurrencySheet.self)
                    controller.isCurrency = false
                    self.presentAsPanModal(controller: controller)
                }
            }
            else {
                if indexPath.row == 0 {
                    let vc = INIT_CONTROLLER_XIB(EditProfileVC.self)
                    vc.modalPresentationStyle = .overFullScreen
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else if indexPath.row == 1 {
                    let vc = INIT_CONTROLLER_XIB(BlockListVC.self)
                    vc.modalPresentationStyle = .overFullScreen
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else if indexPath.row == 2 {
                    let vc = INIT_CONTROLLER_XIB(ReportedUsersListVC.self)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else if indexPath.row == 3 {
                    let vc = INIT_CONTROLLER_XIB(MyReviewsListVC.self)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else if indexPath.row == 4 {
                    let controller = INIT_CONTROLLER_XIB(CurrencySheet.self)
                    controller.isCurrency = true
                    self.presentAsPanModal(controller: controller)
                }
                else if indexPath.row == 5 {
                    let controller = INIT_CONTROLLER_XIB(CurrencySheet.self)
                    controller.isCurrency = false
                    self.presentAsPanModal(controller: controller)
                }
            }
        }
    }
    
    private func _checkAuthorizationNotification() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized:
                    print("Notification access granted.")
                case .denied, .provisional:
                    self.presentPermissionAlert(true)
                case .notDetermined:
                    self.presentPermissionAlert(true)
                case .ephemeral:
                    self.presentPermissionAlert(true)
                @unknown default:
                    print("Unknown authorization status")
                }
            }
        }
    }
    
    private func _checkAuthorization() {
        let contactStore = CNContactStore()
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        
        switch authorizationStatus {
        case .authorized:
            print("Notification access granted.")
        case .denied, .restricted:
            presentPermissionAlert()
        case .notDetermined:
            contactStore.requestAccess(for: .contacts) { [weak self] success, error in
                guard let self = self else { return }
                if !success {
                    self.presentPermissionAlert()
                }
            }
        @unknown default:
            print("Unknown authorization status")
        }
    }

    private func presentPermissionAlert(_ isNotification: Bool = false) {
        self.showCustomAlert(title: isNotification ? "notification_access".localized() : "access_contacts".localized(), message: isNotification ? "allow_notifications_text".localized() : contactsPermissionMessage, yesButtonTitle: "open_settings".localized(), noButtonTitle: "cancel".localized()) { UIAlertAction in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
                self.dismiss(animated: true)
            }
        } noHandler: { UIAlertAction in
        }
    }

    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

}

