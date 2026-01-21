import UIKit

class SubAdminNotification: ChildViewController {
    
    @IBOutlet weak var _userImg: UIImageView!
    @IBOutlet private weak var _tableView: CustomTableView!
    @IBOutlet private weak var _promoterName: UILabel!
    @IBOutlet private weak var _visualEffectView: UIVisualEffectView!
    private let kCellIdentifierUserRequest = String(describing: UserRequestTableCell.self)
    private let kEmptyCellIdentifier = String(describing: EmptyDataCell.self)
    private let kCellIdentifierLoading = String(describing: LoadingCell.self)
    private var _promoterModel: PromoterProfileModel? = APPSESSION.promoterProfile
    private var _page: Int = 1
    private var isPaginating = false
    private var footerView: LoadingFooterView?
    private var _userNotifications: [UserDetailModel] = []
    private var refreshControl = UIRefreshControl()
    private var isLoadingNotification: Bool = false
    
    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
        if _promoterModel != nil { _loadData() }
//        _tableView.contentInset = UIEdgeInsets.init(top: -70, left: 0, bottom: 70, right: 0)
        setupUi()
        NotificationCenter.default.addObserver(self, selector: #selector(handleReloadProfile(_:)), name: .reloadPromoterProfileNotifier, object: nil)
        NotificationCenter.default.addObserver(self, selector:  #selector(handleReloadProfile(_:)), name: kRelaodActivitInfo, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
    }
    
    override func setupUi() {
        _visualEffectView.alpha =  1
        _promoterName.alpha = 1
        _userImg.alpha = 1
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "empty_promoter_detail".localized(),
            emptyDataIconImage: UIImage(named: "empty_explore"),
            emptyDataDescription: nil,
            delegate: self)
        footerView = LoadingFooterView(frame: CGRect(x: 0, y: 0, width: _tableView.bounds.width, height: 44))
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        refreshControl.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        _tableView.refreshControl = refreshControl
        _tableView.tableFooterView = footerView
        _tableView.proxyDelegate = self
        _requestRingsbyPromoter()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierUserRequest, kCellNibNameKey: kCellIdentifierUserRequest, kCellClassKey: UserRequestTableCell.self, kCellHeightKey: UserRequestTableCell.height],
            [kCellIdentifierKey: kEmptyCellIdentifier, kCellNibNameKey: kEmptyCellIdentifier, kCellClassKey: EmptyDataCell.self, kCellHeightKey: EmptyDataCell.height],
            [kCellIdentifierKey: kCellIdentifierLoading, kCellNibNameKey: kCellIdentifierLoading, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height],
        ]
    }
    
    private func _loadData(isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        _promoterName.text = _promoterModel?.profile?.fullName
        _userImg.loadWebImage(_promoterModel?.profile?.image  ?? kEmptyString, name: _promoterModel?.profile?.fullName ?? kEmptyString)
        
        if isLoadingNotification {
            cellData.append([
                kCellIdentifierKey: kCellIdentifierLoading,
                kCellTagKey: kCellIdentifierLoading,
                kCellObjectDataKey: true,
                kCellClassKey: LoadingCell.self,
                kCellHeightKey: LoadingCell.height
            ])
        } else {
            if _userNotifications.isEmpty {
                cellData.append([
                    kCellIdentifierKey: kEmptyCellIdentifier,
                    kCellTagKey: kEmptyCellIdentifier,
                    kCellObjectDataKey: ["title" : "empty_user_requests".localized(), "icon": "empty_notification"],
                    kCellClassKey: EmptyDataCell.self,
                    kCellHeightKey: EmptyDataCell.height
                ])
            } else {
                _userNotifications.forEach { model in
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifierUserRequest,
                        kCellTagKey: kCellIdentifierUserRequest,
                        kCellObjectDataKey: model,
                        kCellClassKey: UserRequestTableCell.self,
                        kCellHeightKey: UserRequestTableCell.height
                    ])
                }
            }
            
        }
        
        cellSectionData.append([kSectionTitleKey: " ", kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
        
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestRingsbyPromoter(_ isReload: Bool = false) {
        guard let id = APPSESSION.userDetail?.promoterId else { return }
        isLoadingNotification = true
        WhosinServices.requestRingByPromoter(id: id) { [weak self] container, error in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
            self.hideHUD(error: error)
            self.isLoadingNotification = false
            guard let data = container?.data else { return }
            self._userNotifications = data
            self._loadData()
        }
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
    private func fetchData(completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            completion()
        }
    }
    
    @objc private func refreshData(_ sender: Any) {
        fetchData {
            DispatchQueue.main.async {
                self._requestRingsbyPromoter(true)
            }
        }
    }
    
    @objc func handleReloadProfile(_ notification: Notification) {
        _requestRingsbyPromoter()
    }
    
    @IBAction private func _handleShareEvent(_ sender: Any) {
        _logout()
    }
    
    private func _logout() {
        alert(title: kAppName, message: "logout_confirmation", option: "yes".localized()) { UIAlertAction in
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

}

// --------------------------------------
// MARK: Delegate methods
// --------------------------------------

extension SubAdminNotification: CustomTableViewDelegate, UIScrollViewDelegate, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        let threshold: CGFloat = 70
        if yOffset > threshold {
            UIView.animate(withDuration: 0.50, animations: { [weak self] in
                guard let self = self else { return }
                self._visualEffectView.alpha = 1.0
                self._promoterName.alpha = 1.0
                self._userImg.alpha = 1.0
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.50, animations: { [weak self] in
                guard let self = self else { return }
                self._visualEffectView.alpha = 1.0
                self._promoterName.alpha = 1.0
                self._userImg.alpha = 1.0
            }, completion: nil)
        }
        let scrollViewContentHeight = scrollView.contentSize.height
        let scrollOffsetThreshold = scrollViewContentHeight - scrollView.bounds.height * 0.8
        if scrollView.contentOffset.y > scrollOffsetThreshold && !isPaginating {
            performPagination()
        }
        
    }
    
    private func performPagination() {
        guard !isPaginating else { return }
        isPaginating = true
        _page += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.isPaginating = false
        }
    }
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? EmptyDataCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [String:Any] else { return }
            cell.setupData(object)
        } else if let cell = cell as? UserRequestTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
            cell.setupSubAdminData(object)
            cell.updateStatusCallback = { status in
                self._requestRingsbyPromoter(true)
            }
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? UserRequestTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return}
            let vc = INIT_CONTROLLER_XIB(ComplementaryPublicProfileVC.self)
            vc.complimentryId = object.userId
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
