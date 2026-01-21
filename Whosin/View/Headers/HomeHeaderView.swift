import Foundation
import UIKit
import SnapKit
import FAPanels
import AudioToolbox
import FirebaseCrashlytics


class HomeHeaderView: UIView {
    
    @IBOutlet weak var _notificationIcon: BadgeButton!
    @IBOutlet private weak var _cartButton: BadgeButton!
    @IBOutlet private weak var _nameLabel: UILabel!
    @IBOutlet private weak var _contentView: UIView!
    @IBOutlet weak var _profileImage: UIImageView!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat {
        guard let statusBarHeight = APP.window?.windowScene?.statusBarManager?.statusBarFrame.height else {
            return kNavigationBarDefaultHeight
        }
        return statusBarHeight + 44
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupUi()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _setupUi()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserUpdateState(_:)), name: .changeUserUpdateState, object: nil)
    }
    
    public class func initFromNib() -> HomeHeaderView {
        UINib(nibName: "HomeHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! HomeHeaderView
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func _setupUi() {
        Bundle.main.loadNibNamed("HomeHeaderView", owner: self, options: nil)
        addSubview(_contentView)
        _nameLabel.text = getGreeting()
        _contentView.snp.makeConstraints { make in
            make.height.equalTo(HomeHeaderView.height)
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
//        _profileImage.isUserInteractionEnabled = true  Enable user interaction
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
//        _profileImage.addGestureRecognizer(tapGesture)

        _profileImage.loadWebImage(APPSESSION.userDetail?.image ?? kEmptyString, name: APPSESSION.userDetail?.fullName ?? kEmptyString, backgroundColor: ColorBrand.tabSelectColor)
        self.hero.modifiers = HeroAnimationModifier.stories
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateCartCount), name: Notification.Name("addtoCartCount"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateNotificationCount), name: Notification.Name("unReadCount"), object: nil)
        APPSETTING.oncartChange = {
            self.handleUpdateNotificationCount()
        }
        let repo = CartRepository()
        _cartButton.badgeNumber = repo.getCartListCount()
        _notificationIcon.badgeNumber = NOTIFICATION.unreadCount
    }
    

    
    private func _showProfile(_ sender: UIButton) {
        let controller = INIT_CONTROLLER_XIB(ProfileMenuVC.self)
        controller.modalPresentationStyle = .overFullScreen
        let transition = CATransition()
        transition.duration = 0.35
        transition.type = CATransitionType.moveIn
        transition.subtype = CATransitionSubtype.fromLeft
        parentViewController?.view.window?.layer.add(transition, forKey: kCATransition)
        parentViewController?.present(controller, animated: false)
    }
    
    private func _showSetting(_ sender: UIButton) {
        let controller = INIT_CONTROLLER_XIB(NewSearchVC.self)
        controller.hidesBottomBarWhenPushed = true
        parentViewController?.navigationController?.pushViewController(controller, animated: true)
    }
    
    private func _showCart(_ sender: UIButton) {
        sender.heroID = String(describing: MyTicketCartVC.self)
        let controller = INIT_CONTROLLER_XIB(MyTicketCartVC.self)
        controller.modalPresentationStyle = .overFullScreen
        controller.hidesBottomBarWhenPushed = true
        parentViewController?.navigationController?.pushViewController(controller, animated: true)
    }
    
    private func _showNotification(_ sender: UIButton) {
        let controller = INIT_CONTROLLER_XIB(NotificationVC.self)
        parentViewController?.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleUserUpdateState(_ notification: Notification) {
        _profileImage.loadWebImage(APPSESSION.userDetail?.image ?? kEmptyString, name: APPSESSION.userDetail?.fullName ?? kEmptyString, backgroundColor: ColorBrand.tabSelectColor)
        APPSESSION.getProfile(isFromMenu: true) { isSuccess, error in }
    }
    
    @objc private func handleUpdateNotificationCount() {
        _notificationIcon.badgeNumber = NOTIFICATION.unreadCount
    }
    
    @objc private func handleUpdateCartCount() {
        let repo = CartRepository()
        _cartButton.badgeNumber = APPSETTING.ticketCartModel?.items.count ?? 0
    }
    
    func getGreeting() -> String {
        let date = Date()
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        let hour = calendar.component(.hour, from: date)
        
        var greeting = ""
        
        switch hour {
        case 0..<6:
            greeting = "good_night" // Late night hours (12 AM – 6 AM)
        case 6..<12:
            greeting = "good_morning" // Early hours (6 AM – 12 PM)
        case 12..<17:
            greeting = "good_afternoon" // Midday to afternoon (12 PM – 5 PM).
        case 17..<24:
            greeting = "good_evening" // Evening time (5 PM – 12 PM)
        default:
            greeting = "good_night" // Default case if any of above case failed
        }
        
        return greeting.localized()
    }

    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    
    @IBAction private func _handleSettingEvent(_ sender: UIButton) {
        DISPATCH_ASYNC_MAIN {
            self.parentBaseController?.feedbackGenerator?.impactOccurred()
            self._showNotification(sender)
        }
    }

    @IBAction private func _handleSearchEvent(_ sender: UIButton) {
        let controller = INIT_CONTROLLER_XIB(NewSearchVC.self)
        controller.hidesBottomBarWhenPushed = false
        self.parentViewController?.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func _handleProfileClickEvent(_ sender: UIButton) {
        parentViewController?.tabBarController?.selectedIndex = 2
    }
    
    @IBAction func _handleAddToCartEvent(_ sender: BadgeButton) {
        DISPATCH_ASYNC_MAIN {
            self._showCart(sender)
        }
    }
    
}

