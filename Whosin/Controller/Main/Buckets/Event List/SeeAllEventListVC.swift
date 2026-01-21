import UIKit
import Parchment
import Hero

class SeeAllEventListVC: ChildViewController {

    @IBOutlet private weak var _containerView: UIView!
    private var _currentVC: EventListVC?
    private var _upcomingList: [EventModel] = []
    private var _historyList: [EventModel] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
        _setupPager()
    }
    
    private func getVcForType (_ type: EventType) -> EventListVC {
        let vc = INIT_CONTROLLER_XIB(EventListVC.self)
        vc.title = type.rawValue
        vc.type = type
        return vc
    }

    private func _setupPager() {
        
        let allVc = getVcForType(.upcoming)
        _currentVC = allVc

        let insets = UIEdgeInsets(top: .zero, left: .zero, bottom: 0.0, right: .zero)
        let spacing = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
        let pagingVC = PagingViewController(viewControllers: [allVc, getVcForType(.history)])
        pagingVC.indicatorColor = ColorBrand.white.withAlphaComponent(0.6)
        pagingVC.textColor = ColorBrand.white.withAlphaComponent(0.6)
        pagingVC.selectedTextColor = ColorBrand.white
        pagingVC.indicatorOptions = .visible(height: 1, zIndex: 0, spacing: spacing, insets: insets)
        pagingVC.borderColor = ColorBrand.brandLightGray
        pagingVC.borderOptions = .visible(height: 0.3, zIndex: 0, insets: insets)
        pagingVC.menuBackgroundColor = ColorBrand.paigerBgColor
        pagingVC.menuItemSize = PagingMenuItemSize.sizeToFit(minWidth: 100, height: 50)
        pagingVC.delegate = self
        
        addChild(pagingVC)
        _containerView.addSubview(pagingVC.view)
        pagingVC.view.snp.makeConstraints { make in make.edges.equalToSuperview() }
        pagingVC.didMove(toParent: self)
    }

    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SeeAllEventListVC: PagingViewControllerDelegate {
    func pagingViewController(_ pagingViewController: PagingViewController, didScrollToItem pagingItem: PagingItem, startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) {
        guard transitionSuccessful else { return }
        _currentVC = destinationViewController as? EventListVC
    }
}
