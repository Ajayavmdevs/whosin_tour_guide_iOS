import UIKit
import Parchment
import Hero

class SeeAllOutingListVC: ChildViewController {

    @IBOutlet private weak var _containerView: UIView!
    private var _currentVC: OutingListVC?
    private var _outingList: [OutingListModel] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
        _setupPager()
        _requestOutingList(false)
        NotificationCenter.default.addObserver(self, selector: #selector(handleReload), name: kReloadBucketList, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func getVcForType (_ type: OutingType) -> OutingListVC {
        let vc = INIT_CONTROLLER_XIB(OutingListVC.self)
        vc.title = type.rawValue
        vc.type = type
        return vc
    }

    private func _setupPager() {
        
        let allVc = getVcForType(.all)
        _currentVC = allVc

        let insets = UIEdgeInsets(top: .zero, left: .zero, bottom: 0.0, right: .zero)
        let spacing = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
        let pagingVC = PagingViewController(viewControllers: [allVc, getVcForType(.createdByMe), getVcForType(.invited), getVcForType(.history)])
        pagingVC.indicatorColor = ColorBrand.white.withAlphaComponent(0.6)
        pagingVC.textColor = ColorBrand.white.withAlphaComponent(0.6)
        pagingVC.selectedTextColor = ColorBrand.white
        pagingVC.indicatorOptions = .visible(height: 1, zIndex: 0, spacing: spacing, insets: insets)
        pagingVC.borderColor = ColorBrand.brandLightGray
        pagingVC.borderOptions = .visible(height: 0.3, zIndex: 0, insets: insets)
        pagingVC.menuBackgroundColor = ColorBrand.paigerBgColor
        pagingVC.menuItemSize = .selfSizing(estimatedWidth: 120, height: 50)
        pagingVC.delegate = self
        
        
        addChild(pagingVC)
        _containerView.addSubview(pagingVC.view)
        pagingVC.view.snp.makeConstraints { make in make.edges.equalToSuperview() }
        pagingVC.didMove(toParent: self)
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestOutingList(_ shouldRefresh: Bool = false) {
        if shouldRefresh { showHUD() }
        WhosinServices.requestOutingList { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self._outingList = data.filter({ $0.owner != nil })
            self._currentVC?.outingList = self._outingList
        }
    }

    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleReload() {
        _requestOutingList()
    }
}

extension SeeAllOutingListVC: PagingViewControllerDelegate {
    
    func pagingViewController(_ pagingViewController: PagingViewController, didScrollToItem pagingItem: PagingItem, startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) {
        guard transitionSuccessful else { return }
        _currentVC = destinationViewController as? OutingListVC
        _currentVC?.outingList = _outingList
    }
    
}
