import UIKit

class MainPromoterVC: ChildViewController {
    
    @IBOutlet weak var _userImg: UIImageView!
    @IBOutlet private weak var _tableView: CustomTableView!
    @IBOutlet private weak var _promoterName: UILabel!
    @IBOutlet private weak var _visualEffectView: UIVisualEffectView!
    @IBOutlet weak var _tabView: UIView!
    public var _selectedIndex: Int = 0
    private let kCellIdentifierHeader = String(describing: PromoterProfileHeaderCell.self)
    private let kCellIdentifierUserRequest = String(describing: UserRequestTableCell.self)
    private let kCellIdentifierMyRings = String(describing: MyRingsTableViewCell.self)
    private let kCellIdentifierMyVenues = String(describing: MyVenuesTableCell.self)
    private let kCellIdentifierMyCircles = String(describing: MyCirclesTableCell.self)
    private let kEmptyCellIdentifier = String(describing: EmptyDataCell.self)
    private let kCellIdentifierLoading = String(describing: LoadingCell.self)
    private var _promoterModel: PromoterProfileModel? = APPSESSION.promoterProfile
    private var _page: Int = 1
    private var isPaginating = false
    private var footerView: LoadingFooterView?
    private var _userNotifications: [UserDetailModel] = []
    private var refreshControl = UIRefreshControl()
    private var isLoadingNotification: Bool = false
    private var tabView = MainPromoterHeaderView()
    
    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
        DISPATCH_ASYNC_MAIN {
            let headerView = MainPromoterHeaderView(frame: self._tabView.frame.standardized)
            headerView.setupData(self._selectedIndex, selectedType: "users")
            headerView.delegate = self
            self.tabView = headerView
            self._tabView.addSubview(self.tabView)
            self.tabView.translatesAutoresizingMaskIntoConstraints = false
            self.tabView.snp.makeConstraints { make in
                make.edges.equalTo(self._tabView)
            }
        }

        if _promoterModel != nil { _loadData() }
        _tableView.contentInset = UIEdgeInsets.init(top: -70, left: 0, bottom: 70, right: 0)
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
        footerView = LoadingFooterView(frame: CGRect(x: 0, y: 0, width: _tableView.bounds.width, height: 44))
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        refreshControl.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        _tableView.refreshControl = refreshControl
        _tableView.tableFooterView = footerView
        _tableView.proxyDelegate = self
        _requestGetProfile()
        _requestRingsbyPromoter()
    }
    
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierHeader, kCellNibNameKey: kCellIdentifierHeader, kCellClassKey: PromoterProfileHeaderCell.self, kCellHeightKey: PromoterProfileHeaderCell.height],
            [kCellIdentifierKey: kCellIdentifierUserRequest, kCellNibNameKey: kCellIdentifierUserRequest, kCellClassKey: UserRequestTableCell.self, kCellHeightKey: UserRequestTableCell.height],
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
        
        switch selectedIndex {
        case 0:
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
        case 1:
            self._promoterName.alpha = 1.0
            self._userImg.alpha = 1.0
            
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
        default:
            break
        }
        
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
            if isReload || _selectedIndex == 4 {
                _loadData(selectedIndex: _selectedIndex)
            }
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
                switch self._selectedIndex {
                case 0:
                    self._requestGetProfile()
                case 1:
                    self._requestRingsbyPromoter(true)
                default:
                    print("Somthing wrong....")
                }
            }
        }
    }
    
    @objc func handleReloadProfile(_ notification: Notification) {
        _selectedIndex = 0
        _requestGetProfile()
    }
    
    @IBAction private func _handleShareEvent(_ sender: Any) {
        _generateDynamicLinks()
    }
    
    private func  _generateDynamicLinks() {
        guard let controller = parent else { return }
        guard let user = _promoterModel?.profile else {
            return
        }
        let shareMessage = "\(user.fullName) \n\n\(user.bio) \n\n\("https://explore.whosin.me/u/\(user.userId)")"
        let items = [shareMessage]
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityController.setValue(kAppName, forKey: "subject")
        activityController.popoverPresentationController?.sourceView = controller.view
        activityController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToTwitter]
        controller.present(activityController, animated: true, completion: nil)
    }
}


// --------------------------------------
// MARK: Delegate methods
// --------------------------------------

extension MainPromoterVC: CustomTableViewDelegate, UIScrollViewDelegate, UITableViewDelegate {
    
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
        if scrollView.contentOffset.y > scrollOffsetThreshold && !isPaginating {
            if _selectedIndex == 1 {
                performPagination()
            }
        }
        
    }
    
    private func performPagination() {
        guard !isPaginating else { return }
        isPaginating = true
        _page += 1
        _selectedIndex = 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.isPaginating = false
        }
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

extension MainPromoterVC: CustomHeaderViewDelegate {
    func notificationType(type: String) {
    }
    
    func didSelectTab(at index: Int) {
        _selectedIndex = index
        self._tableView.contentInset = UIEdgeInsets.init(top: _selectedIndex == 0 ? -70 : 60, left: 0, bottom: 70, right: 0)
        self._tableView.scrollToTop()
        _loadData(isLoading: false, selectedIndex: index)
    }
}
