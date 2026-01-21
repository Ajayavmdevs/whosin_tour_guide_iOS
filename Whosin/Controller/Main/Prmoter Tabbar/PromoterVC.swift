import UIKit
import IQKeyboardManagerSwift

class PromoterVC: NavigationBarViewController {
    
    @IBOutlet weak var _userImg: UIImageView!
    @IBOutlet weak var _promoterName: CustomLabel!
    @IBOutlet weak var _visualEffectView: UIVisualEffectView!
    @IBOutlet weak var _tableView: CustomTableView!
    private let kCellIdentifierHeader = String(describing: PrivateProfileHeaderCell.self)
    private let kCellIdentifierMyRings = String(describing: MyRingsTableViewCell.self)
    private let kCellIdentifierMyVenues = String(describing: MyVenuesTableCell.self)
    private let kCellIdentifierMyCircles = String(describing: MyCirclesTableCell.self)
    private let kCellIdentifierReview = String(describing: RatingTableCell.self)
    private let kEmptyCellIdentifier = String(describing: EmptyDataCell.self)
    private let kCellIdentifierDraft = String(describing: SavedInDraftTableCell.self)
    private let kCellIdentifierLoading = String(describing: LoadingCell.self)
    private var _promoterModel: PromoterProfileModel? = APPSESSION.promoterProfile
    private var _page: Int = 1
    private var refreshControl = UIRefreshControl()
    public var delegate: CloseTabbarDelegate?
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
        view.bringSubviewToFront(_visualEffectView)
        showHUD()
        if _promoterModel != nil { _loadData() }
        setupUi()
        NotificationCenter.default.addObserver(self, selector: #selector(handleReloadProfile(_:)), name: .reloadPromoterProfileNotifier, object: nil)
        NotificationCenter.default.addObserver(self, selector:  #selector(handleReloadProfile(_:)), name: kRelaodActivitInfo, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleReloadEventDraftNotification(_:)), name: .reloadEventDraftNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePushReload), name: .changereloadNotificationUpdateState, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleReloadEventDraftNotification(_:)), name: .reloadMyEventsNotifier, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
        IQKeyboardManager.shared.enable = true
    }
    
    override func setupUi() {
        _visualEffectView.alpha = 0
        _promoterName.alpha = 0
        _userImg.alpha = 0
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
        _tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        refreshControl.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        _tableView.refreshControl = refreshControl
        PromoterApplicationVC.reloadOnBack = { self._requestGetProfile() }
        _tableView.proxyDelegate = self
        _requestGetProfile()
    }
    
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierHeader, kCellNibNameKey: kCellIdentifierHeader, kCellClassKey: PrivateProfileHeaderCell.self, kCellHeightKey: PrivateProfileHeaderCell.height],
            [kCellIdentifierKey: kCellIdentifierMyRings, kCellNibNameKey: kCellIdentifierMyRings, kCellClassKey: MyRingsTableViewCell.self, kCellHeightKey: MyRingsTableViewCell.height],
            [kCellIdentifierKey: kCellIdentifierMyVenues, kCellNibNameKey: kCellIdentifierMyVenues, kCellClassKey: MyVenuesTableCell.self, kCellHeightKey: MyVenuesTableCell.height],
            [kCellIdentifierKey: kCellIdentifierMyCircles, kCellNibNameKey: kCellIdentifierMyCircles, kCellClassKey: MyCirclesTableCell.self, kCellHeightKey: MyCirclesTableCell.height],
            [kCellIdentifierKey: kCellIdentifierReview, kCellNibNameKey: kCellIdentifierReview, kCellClassKey: RatingTableCell.self, kCellHeightKey: RatingTableCell.height],
            [kCellIdentifierKey: kEmptyCellIdentifier, kCellNibNameKey: kEmptyCellIdentifier, kCellClassKey: EmptyDataCell.self, kCellHeightKey: EmptyDataCell.height],
            [kCellIdentifierKey: kCellIdentifierDraft, kCellNibNameKey: kCellIdentifierDraft, kCellClassKey: SavedInDraftTableCell.self, kCellHeightKey: SavedInDraftTableCell.height],
            [kCellIdentifierKey: kCellIdentifierLoading, kCellNibNameKey: kCellIdentifierLoading, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height],
        ]
    }
    
    private func _loadData(isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        _promoterName.text = _promoterModel?.profile?.fullName
        _userImg.loadWebImage(_promoterModel?.profile?.image  ?? kEmptyString, name: _promoterModel?.profile?.fullName ?? kEmptyString)
       
            cellData.append([
                kCellIdentifierKey: kCellIdentifierHeader,
                kCellTagKey: kCellIdentifierHeader,
                kCellObjectDataKey: _promoterModel,
                kCellClassKey: PrivateProfileHeaderCell.self,
                kCellHeightKey: PrivateProfileHeaderCell.height
            ])
            
            if !Preferences.saveEventDraft.isEmpty {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierDraft,
                    kCellTagKey: kCellIdentifierDraft,
                    kCellObjectDataKey: "Draft",
                    kCellClassKey: SavedInDraftTableCell.self,
                    kCellHeightKey: SavedInDraftTableCell.height
                ])
            }
            
            guard let model = _promoterModel else { return }
            cellData.append([
                kCellIdentifierKey: kCellIdentifierMyRings,
                kCellTagKey: kCellIdentifierMyRings,
                kCellObjectDataKey: model.rings?.detached(),
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
            
            if model.venues?.venueList.isEmpty == false {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierMyVenues,
                    kCellTagKey: kCellIdentifierMyVenues,
                    kCellObjectDataKey: model.venues,
                    kCellClassKey: MyVenuesTableCell.self,
                    kCellHeightKey: MyVenuesTableCell.height
                ])
            }
    
        cellSectionData.append([kSectionTitleKey: " ", kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestGetProfile() {
        WhosinServices.getPromoterProfiel { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            self.refreshControl.endRefreshing()
            guard let data = container?.data else { return}
            self._promoterModel = data
            if let josnData = data.toJSONString() {
                Preferences.promoterProfile = josnData
            }
            DISPATCH_ASYNC_MAIN {
                self._loadData()
            }
            
        }
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
    private func fetchData(completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
        _requestGetProfile()
    }
        
    @objc func handleReloadEventDraftNotification(_ notification: Notification) {
        _loadData()
    }
    
    @objc func handlePushReload() {
       _requestGetProfile()
    }
    
    @IBAction private func _handleCloseEvent(_ sender: Any) {
        delegate?.close()
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

extension PromoterVC: CustomTableViewDelegate, UIScrollViewDelegate, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        let threshold: CGFloat = 100
        
        UIView.animate(withDuration: 0.50, animations: { [weak self] in
            guard let self = self else { return }
            if yOffset > threshold {
                self._visualEffectView.alpha = 1.0
                self._promoterName.alpha = 1.0
                self._userImg.alpha = 1.0
            } else {
                self._visualEffectView.alpha = 0.0
                self._promoterName.alpha = 0.0
                self._userImg.alpha = 0.0
            }
        }, completion: nil)        
    }
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? EmptyDataCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [String:Any] else { return }
            cell.setupData(object)
        } else if let cell = cell as? PrivateProfileHeaderCell {
            guard let object = cellDict?[kCellObjectDataKey] as?  PromoterProfileModel else { return }
            cell.setupData(object)
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
        } else if let cell = cell as? SavedInDraftTableCell {
            cell.setup()
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
    }
}
