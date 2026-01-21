import UIKit
import Parchment
import Hero

struct TabLaunchConfig {
    static var walletDefaultPageIndex: Int = 0
}

class MyWalletVC: ChildViewController {

    @IBOutlet private weak var _containerView: UIView!
    @IBOutlet private weak var _backButton: UIButton!
    public var isFromProfile: Bool = false
    public var defaultSelectedIndex: Int = 0
    private var _currentVC: ChildViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        defaultSelectedIndex = TabLaunchConfig.walletDefaultPageIndex
        TabLaunchConfig.walletDefaultPageIndex = 0
        _backButton.isHidden = !isFromProfile
        _setupPager()
        _setupUi()
        APPSESSION.readUpdate(type: "wallet")
        APPSESSION.getUpdateModel?.wallet = false
    }
    
    private func _setupUi() {
        hideNavigationBar()
    }

    private func _setupPager() {
        let myItemsVC = INIT_CONTROLLER_XIB(MyItemsVC.self)
        myItemsVC.title = "my_items".localized()
        _currentVC = myItemsVC
        
//        let wishlistVC = INIT_CONTROLLER_XIB(GiftsVC.self)
//        wishlistVC.title = "Gifts"
        
        let contactVC = INIT_CONTROLLER_XIB(HistoryVC.self)
        contactVC.title = "history".localized()

        let insets = UIEdgeInsets(top: .zero, left: .zero, bottom: 5.0, right: .zero)
        let spacing = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 10.0)
        let pagingVC = PagingViewController(viewControllers: [myItemsVC, contactVC])
        pagingVC.indicatorColor = ColorBrand.white.withAlphaComponent(0.7)
        pagingVC.textColor = ColorBrand.white.withAlphaComponent(0.7)
        pagingVC.selectedTextColor = ColorBrand.white
        pagingVC.indicatorOptions = .visible(height: 4.0, zIndex: 0, spacing: spacing, insets: insets)
        pagingVC.borderColor = .clear
        pagingVC.menuBackgroundColor = ColorBrand.clear
        pagingVC.menuItemSize = PagingMenuItemSize.sizeToFit(minWidth: 100, height: 50)
        pagingVC.delegate = self
        self.view.clipsToBounds = false
        addChild(pagingVC)
        _containerView.addSubview(pagingVC.view)
        pagingVC.view.snp.makeConstraints { make in make.edges.equalToSuperview() }
        pagingVC.view.clipsToBounds = false
        pagingVC.select(index: defaultSelectedIndex, animated: false)
        _currentVC = defaultSelectedIndex == 0 ? myItemsVC : contactVC
        pagingVC.didMove(toParent: self)
    }
    
    @IBAction private func _handleBackEvent(_ sender: UIButton) {
        dismissOrBack()
//        navigationController?.popViewController(animated: true)
    }
}

extension MyWalletVC: PagingViewControllerDelegate {
    
    func pagingViewController(_ pagingViewController: PagingViewController, didScrollToItem pagingItem: PagingItem, startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) {
        guard transitionSuccessful else { return }
        _currentVC = destinationViewController as? ChildViewController

    }
}

