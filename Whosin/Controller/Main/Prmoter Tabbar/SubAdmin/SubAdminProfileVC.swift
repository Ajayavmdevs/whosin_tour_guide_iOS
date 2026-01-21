import UIKit

class SubAdminProfileVC: ChildViewController {
    
    @IBOutlet weak var _userImg: UIImageView!
    @IBOutlet private weak var _tableView: CustomTableView!
    @IBOutlet private weak var _promoterName: UILabel!
    @IBOutlet private weak var _visualEffectView: UIVisualEffectView!
    public var _selectedIndex: Int = 0
    private let kCellIdentifierHeader = String(describing: PromoterProfileHeaderCell.self)
    private let kCellIdentifierMyRings = String(describing: MyRingsTableViewCell.self)
    private let kCellIdentifierMyVenues = String(describing: MyVenuesTableCell.self)
    private let kCellIdentifierMyCircles = String(describing: MyCirclesTableCell.self)
    private let kEmptyCellIdentifier = String(describing: EmptyDataCell.self)
    private let kCellIdentifierLoading = String(describing: LoadingCell.self)
    private var _promoterModel: PromoterProfileModel? = APPSESSION.promoterProfile
    private var _userNotifications: [UserDetailModel] = []
    private var refreshControl = UIRefreshControl()
    
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
        _visualEffectView.alpha = _selectedIndex == 1 ? 1 : 0
        _promoterName.alpha = _selectedIndex == 1 ? 1 : 0
        _userImg.alpha = _selectedIndex == 1 ? 1 : 0
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
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        refreshControl.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        _tableView.refreshControl = refreshControl
        _tableView.proxyDelegate = self
        _requestGetProfile()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierHeader, kCellNibNameKey: kCellIdentifierHeader, kCellClassKey: PromoterProfileHeaderCell.self, kCellHeightKey: PromoterProfileHeaderCell.height],
            [kCellIdentifierKey: kCellIdentifierMyRings, kCellNibNameKey: kCellIdentifierMyRings, kCellClassKey: MyRingsTableViewCell.self, kCellHeightKey: MyRingsTableViewCell.height],
            [kCellIdentifierKey: kCellIdentifierMyVenues, kCellNibNameKey: kCellIdentifierMyVenues, kCellClassKey: MyVenuesTableCell.self, kCellHeightKey: MyVenuesTableCell.height],
            [kCellIdentifierKey: kCellIdentifierMyCircles, kCellNibNameKey: kCellIdentifierMyCircles, kCellClassKey: MyCirclesTableCell.self, kCellHeightKey: MyCirclesTableCell.height],
            [kCellIdentifierKey: kEmptyCellIdentifier, kCellNibNameKey: kEmptyCellIdentifier, kCellClassKey: EmptyDataCell.self, kCellHeightKey: EmptyDataCell.height],
            [kCellIdentifierKey: kCellIdentifierLoading, kCellNibNameKey: kCellIdentifierLoading, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height],
        ]
    }
    
    private func _loadData(isLoading: Bool = false,selectedIndex: Int = 0) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        _promoterName.text = _promoterModel?.profile?.fullName
        _userImg.loadWebImage(_promoterModel?.profile?.image  ?? kEmptyString, name: _promoterModel?.profile?.fullName ?? kEmptyString)
        
        cellData.append([
            kCellIdentifierKey: kCellIdentifierHeader,
            kCellTagKey: kCellIdentifierHeader,
            kCellObjectDataKey: _promoterModel,
            kCellClassKey: PromoterProfileHeaderCell.self,
            kCellHeightKey: PromoterProfileHeaderCell.height
        ])
        
        guard let model = _promoterModel else { return }
        cellData.append([
            kCellIdentifierKey: kCellIdentifierMyRings,
            kCellTagKey: kCellIdentifierMyRings,
            kCellObjectDataKey: model.rings,
            kCellClassKey: MyRingsTableViewCell.self,
            kCellHeightKey: MyRingsTableViewCell.height
        ])
        
        cellData.append([
            kCellIdentifierKey: kCellIdentifierMyCircles,
            kCellTagKey: kCellIdentifierMyCircles,
            kCellObjectDataKey: model.circles.toArrayDetached(ofType: UserDetailModel.self),
            kCellClassKey: MyCirclesTableCell.self,
            kCellHeightKey: MyCirclesTableCell.height
        ])
        cellData.append([
            kCellIdentifierKey: kCellIdentifierMyVenues,
            kCellTagKey: kCellIdentifierMyVenues,
            kCellObjectDataKey: model.venues,
            kCellClassKey: MyVenuesTableCell.self,
            kCellHeightKey: MyVenuesTableCell.height
        ])
        
        cellSectionData.append([kSectionTitleKey: " ", kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
        
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestGetProfile() {
        guard let id = APPSESSION.userDetail?.promoterId else { return }
        WhosinServices.getPromoterProfiel(id) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            self.refreshControl.endRefreshing()
            guard let data = container?.data else { return}
            self._promoterModel = data
            if let josnData = data.toJSONString() {
                Preferences.promoterProfile = josnData
            }
            self._loadData(selectedIndex: _selectedIndex)
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
                self._requestGetProfile()
            }
        }
    }
    
    @objc func handleReloadProfile(_ notification: Notification) {
        _selectedIndex = 0
        _requestGetProfile()
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

extension SubAdminProfileVC: CustomTableViewDelegate, UIScrollViewDelegate, UITableViewDelegate {
    
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
                self._visualEffectView.alpha = _selectedIndex == 1  ? 1.0 : 0.0
                self._promoterName.alpha = _selectedIndex == 1  ? 1.0 : 0.0
                self._userImg.alpha = _selectedIndex == 1  ? 1.0 : 0.0
            }, completion: nil)
        }
        let scrollViewContentHeight = scrollView.contentSize.height
        let scrollOffsetThreshold = scrollViewContentHeight - scrollView.bounds.height * 0.8
    }
    
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? EmptyDataCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [String:Any] else { return }
            cell.setupData(object)
        } else if let cell = cell as? PromoterProfileHeaderCell {
            guard let object = cellDict?[kCellObjectDataKey] as?  PromoterProfileModel else { return }
            cell.setupData(object, isSubAdmin: true)
        } else if let cell = cell as? MyRingsTableViewCell {
            guard let object = cellDict?[kCellObjectDataKey] as? CommanPromoterRingModel else { return }
            cell.setupData(object)
        } else if let cell = cell as? MyVenuesTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? CommanPromoterVenueModel else { return }
            cell.setupData(object)
        } else  if let cell = cell as? MyCirclesTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [UserDetailModel] else { return}
            cell.setupData(object)
        } else if let cell = cell as? RatingTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? RatingListModel else { return }
            cell.setupRattings(object,id: _promoterModel?.profile?.userId ?? kEmptyString ,isFromPromoter: true)
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
