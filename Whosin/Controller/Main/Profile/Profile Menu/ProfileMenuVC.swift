import UIKit
import FAPanels
import GradientProgress
import Hero
import Lightbox

class ProfileMenuVC: ChildViewController {
    
    @IBOutlet weak var _premiumeView: UIView!
    @IBOutlet private weak var _vipView: UIView!
    @IBOutlet private weak var _profileImgBgView: UIView!
    @IBOutlet weak var _closeBtn: UIButton!
    @IBOutlet private weak var _profileImg: UIImageView!
    @IBOutlet private weak var _userName: UILabel!
    @IBOutlet private weak var _followerCount: UILabel!
    @IBOutlet private weak var _followingCount: UILabel!
    @IBOutlet private weak var _tableView: CustomTableView!
    @IBOutlet private weak var _progressBar: GradientProgressBar!
    @IBOutlet private weak var _subscriptionView: GradientView!
    
    private let kCellIdentifier = String(describing: ProfileSettingCell.self)
    private let kCellIdentifierPrimium = String(describing: PrimiumViewCell.self)
    var _menuList = [[String: Any]]()
    var _privacyList = [[String: Any]]()
    var _logoutList = [[String: Any]]()
    var heroId: String = String(describing: ProfileMenuVC.self)
    private var subscription: SubscriptionModel?
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _addMenuData()
        hideNavigationBar()
        _setupUi()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        _profileImg.isUserInteractionEnabled = true
        _profileImg.addGestureRecognizer(tapGesture)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserUpdateState(_:)), name: .changeUserUpdateState, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleOpenWebView(_:)), name: kOpenWebViewPackagePayment, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSubscriptionState(_:)), name: .changeSubscriptionState, object: nil)
    }
    
    @objc func imageTapped(sender: UITapGestureRecognizer) {
        guard let image = APPSESSION.userDetail?.image else { return }
        var images: [LightboxImage] = []
        if sender.state == .ended, let image = _profileImg.image {
            images.append(LightboxImage(image: image))
        } else if sender.state == .ended{
            images.append(LightboxImage(imageURL: URL(string: image)!))
        }
        let controller = LightboxController(images: images)
        controller.dynamicBackground = true
        present(controller, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        APPSETTING.configureSubscrition()
        _premiumeView.cornerRadius = _premiumeView.frame.height / 2
        if APPSESSION.userDetail?.isVip == true {
            _vipView.isHidden = false
            _premiumeView.isHidden = true
        } else if APPSESSION.userDetail?.isMembershipActive == true {
            _premiumeView.isHidden = false
            _vipView.isHidden = true
        } else {
            _premiumeView.isHidden = true
            _vipView.isHidden = true
        }
//        self._vipView.isHidden = APPSESSION.userDetail?.isVip == true ? false : true
        self._followerCount.text = "\(APPSESSION.userDetail?.follower ?? 0)"
        self._followingCount.text = "\(APPSESSION.userDetail?.following ?? 0)"
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: kOpenWebViewPackagePayment, object: nil)
        NotificationCenter.default.removeObserver(self, name: .changeSubscriptionState, object: nil)
    }

    private func _reloadData() {
        if APPSETTING.subscription?.userId == APPSESSION.userDetail?.id {
            if let VoucherName = APPSETTING.subscription?.package?.title {
                let words = VoucherName.components(separatedBy: " ")
                let shortName = words.compactMap { $0.first }
            }
        }

        _userName.text = LANGMANAGER.localizedString(forKey: "greeting_user", arguments: ["value": APPSESSION.userDetail?.firstName ?? ""])
        _followerCount.text = "\(APPSESSION.userDetail?.follower ?? 0)"
        _followingCount.text = "\(APPSESSION.userDetail?.following ?? 0)"
        _profileImg.loadWebImage(APPSESSION.userDetail?.image ?? kEmptyString, name: APPSESSION.userDetail?.fullName ?? kEmptyString)
        _progressBar.setProgress(0.5, animated: true)
        _progressBar.progress = 0.5
        _progressBar.gradientColors = [UIColor.systemPink.cgColor, UIColor.purple.cgColor]
    }

    private func _setupUi() {
        view.hero.id = heroId
        view.hero.modifiers = HeroAnimationModifier.stories
        _reloadData()
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: true,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: nil,
            emptyDataIconImage: nil,
            emptyDataDescription: nil,
            delegate: self)

        let tap = UITapGestureRecognizer(target: self, action: #selector(openMembershipPackages(_:)))
        _subscriptionView.addGestureRecognizer(tap)
        _loadData()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    @objc private func handleSubscriptionState(_ notification: Notification) {
        if APPSETTING.subscription?.userId == APPSESSION.userDetail?.id {
            guard let VoucherName = APPSETTING.subscription?.package?.title else { return }
            let words = VoucherName.components(separatedBy: " ")
            let shortName = words.compactMap { $0.first }
            _loadData()                                                                                                                                                                       }
    }
    
    @objc private func handleUserUpdateState(_ notification: Notification) {
        APPSESSION.getProfile(isFromMenu: true) { isSuccess, error in }
        _reloadData()
    }
    
    @objc func handleOpenWebView(_ notification: Notification) {
        DISPATCH_ASYNC_MAIN_AFTER(0.5) {
            if let userInfo = notification.userInfo,
               let url = userInfo["url"] as? URL {
                let vc = INIT_CONTROLLER_XIB(WebViewController.self)
                vc.url = url
                vc.delegate = self
                self.view.parentViewController?.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    private func _addMenuData() {
        _menuList.append(["title" : "settings".localized(), "icon": "profile_setting"])
        _menuList.append(["title" : "Transaction History", "icon": "profile_claim"])
        _menuList.append(["title" : "wallet".localized(), "icon": "profile_wallet"])
        if APPSESSION.userDetail?.isMembershipActive == true {
            _menuList.append(["title" : "my_subscription".localized(), "icon": "icon_member"])
        }
        _menuList.append(["title" : "invite_a_friend".localized(), "icon": "profile_invite"])
        _menuList.append(["title" : "contact_us".localized(), "icon": "profile_contact"])
        _privacyList.append(["title" : "privacy_policy".localized(), "icon": "profile_privacy"])
        _privacyList.append(["title" : "terms_condition".localized(), "icon": "profile_terms"])
        _logoutList.append(["title" : "logout".localized(), "icon": "profile_logout"])
    }
    
    private func _addPrivacyData() {
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
                kCellTitleKey: "setting",
                kCellClassKey: ProfileSettingCell.self,
                kCellHeightKey: ProfileSettingCell.height
            ])
            id += 1
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        cellData.removeAll()
        
        _privacyList.forEach { privacy in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: privacy,
                kCellTitleKey: "privacy",
                kCellClassKey: ProfileSettingCell.self,
                kCellHeightKey: ProfileSettingCell.height
            ])
        }
        
        cellSectionData.append([kSectionTitleKey: "\n", kSectionDataKey: cellData])
        cellData.removeAll()
        
        _logoutList.forEach { privacy in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: privacy,
                kCellTitleKey: "logout",
                kCellClassKey: ProfileSettingCell.self,
                kCellHeightKey: ProfileSettingCell.height
            ])
        }
        
        cellSectionData.append([kSectionTitleKey: "\n", kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: ProfileSettingCell.self, kCellHeightKey: ProfileSettingCell.height],
            [kCellIdentifierKey: kCellIdentifierPrimium, kCellNibNameKey: kCellIdentifierPrimium, kCellClassKey: PrimiumViewCell.self, kCellHeightKey: PrimiumViewCell.height]
            
        ]
    }
    
    private func _logout() {
        alert(title: kAppName, message: "logout_confirmation".localized(), option: "yes".localized()) { UIAlertAction in
            self.showHUD()
            APPSESSION.logout { [weak self] success, error in
                guard let self = self else { return }
                self.hideHUD(error: error)
                guard success else { return }
                self._moveToLogin()
            }
        } cancelHandler: { UIAlertAction in
        }
    }
    
    private func _moveToLogin() {
        guard let window = APP.window else { return }
        let navController = NavigationController(rootViewController: INIT_CONTROLLER_XIB(LoginVC.self))
        navController.setNavigationBarHidden(true, animated: false)
        window.setRootViewController(navController, options: UIWindow.TransitionOptions(direction:.fade, style: .easeInOut))
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func openMembershipPackages(_ g: UITapGestureRecognizer) -> Void {
        if APPSETTING.subscription?.userId == APPSESSION.userDetail?.id {
            let destinationViewController = MembershipVC()
            let navigationController = UINavigationController(rootViewController: destinationViewController)
            navigationController.modalPresentationStyle = .overFullScreen
            self.present(navigationController, animated: true, completion: nil)
        } else {
            let destinationViewController = MembershipDetailVC()
            let navigationController = UINavigationController(rootViewController: destinationViewController)
            navigationController.modalPresentationStyle = .overFullScreen
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    @IBAction private func _handleFollowerListEvent(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(FollowListVC.self)
        vc.isFollowerList = true
        vc.followId = APPSESSION.userDetail?.id ?? kEmptyString
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func _handleFollowingListEvent(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(FollowListVC.self)
        vc.isFollowerList = false
        vc.delegate = self
        vc.followId = APPSESSION.userDetail?.id ?? kEmptyString
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func _handleAVMEvent(_ sender: UIButton) {
        _openURL(urlString: "https://avmdevs.com/")
    }
    
    private func _dismissVc() {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromRight
        self.view.window?.layer.add(transition, forKey: kCATransition)
        dismiss(animated: false)
    }

}

// --------------------------------------
// MARK: Custom TableView
// --------------------------------------
extension ProfileMenuVC: CustomTableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? ProfileSettingCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [String : Any] else { return }
            cell.setupData(object)
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
        } else if let cell = cell as? PrimiumViewCell {
            guard let object = cellDict?[kCellObjectDataKey] as? String else { return }
            cell.setup(object)
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellTitleKey] as? String  else { return }
        if object == "primium" {
            if APPSETTING.userModel?.isMembershipActive == true {
                var destinationViewController = BundlePlanDetailsVC()
                destinationViewController.subscription = APPSETTING.membershipPackage?.first
                let navigationController = UINavigationController(rootViewController: destinationViewController)
                navigationController.modalPresentationStyle = .overFullScreen
                self.present(navigationController, animated: true, completion: nil)
            }
        } else if object == "logout" {
            _logout()
        } else if object == "setting" {
            switch indexPath.row {
            case 0:
                let controller = INIT_CONTROLLER_XIB(SettingVC.self)
                controller.modalPresentationStyle = .overFullScreen
                self.navigationController?.pushViewController(controller, animated: true)
            case 1:
                let controller = INIT_CONTROLLER_XIB(ClaimHistoryVC.self)
                controller.modalPresentationStyle = .overFullScreen
                self.navigationController?.pushViewController(controller, animated: true)
            case 2:
                let destinationViewController = MyWalletVC()
                destinationViewController.isFromProfile = true
                self.navigationController?.pushViewController(destinationViewController, animated: true)
            case 3:
                if APPSESSION.userDetail?.isMembershipActive == true {
                    let vc = INIT_CONTROLLER_XIB(MembershipVC.self)
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    shareAppLink()
                }
            case 4:
                if APPSESSION.userDetail?.isMembershipActive == true {
                    shareAppLink()
                } else {
                    let vc = INIT_CONTROLLER_XIB(ContactUsVC.self)
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            case 5:
                let vc = INIT_CONTROLLER_XIB(ContactUsVC.self)
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                break
            }
        
        } else if object == "privacy" {
            switch indexPath.row {
            case 0:
                let vc = INIT_CONTROLLER_XIB(WebViewController.self)
                //vc.htmlTxt = APPSETTING.appSetiings?.pages.filter({ $0.title == "Privacy Policy" }).first?.descriptions
                vc.url = URL(string: "https://whosin.me/privacy-policy/")
                vc.viewTitle = "privacy_policy".localized()
                self.navigationController?.pushViewController(vc, animated: true)
            case 1:
                let vc = INIT_CONTROLLER_XIB(WebViewController.self)
//                vc.htmlTxt = APPSETTING.appSetiings?.pages.filter({ $0.title == "Terms & Condition" }).first?.descriptions
                vc.url = URL(string: "https://whosin.me/terms-conditions/")
                vc.viewTitle = "terms_condition".localized()
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                break
            }
            
        }
    }
    
    private func _openURL(urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension ProfileMenuVC: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomBottomSheet(presentedViewController: presented, presenting: presenting)
    }
}

extension ProfileMenuVC: ReloadProfileDelegate {
    func didRequestReload() {
        APPSESSION.getProfile { success, error in
            if success {
                self._reloadData()
            }
        }
    }
}

extension ProfileMenuVC: purchaseSuccessDelegate {
    func purchaseSuccess() {
        WhosinServices.subscriptionDetail { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container?.data else { return }
//            self.subscription = data
//            APPSETTING.subscription = data
            let vc = INIT_CONTROLLER_XIB(PurchasePlanPopUpVC.self)
            let navController = NavigationController(rootViewController: vc)
            navController.modalPresentationStyle = .overFullScreen
            self.present(navController, animated: true)
            NotificationCenter.default.post(name: .changeSubscriptionState, object: nil)
        }
    }
}

extension ProfileMenuVC: ActionButtonDelegate {
    func buttonClicked(_ tag: Int) {
        APPSESSION.getProfile { success, error in
            if success {
                self._reloadData()
            }
        }
    }
}
