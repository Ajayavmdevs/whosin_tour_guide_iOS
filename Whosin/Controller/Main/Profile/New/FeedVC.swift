import UIKit

class FeedVC: ProfileBaseMainVC {
    
    @IBOutlet weak var _tableView: CustomNoKeyboardTableView!
    private var _feedData: [UserFeedModel] = []
    private let kEmptyCellIdentifier = String(describing: EmptyDataCell.self)
    private let kLoadingCell = String(describing: LoadingCell.self)
    private let kCellIdentifierUserActivity = String(describing: UserActivityCell.self)
    private let kCellIdentifierOffer = String(describing: CommanOffersTableCell.self)
    private let kCellIdentifierEvent = String(describing: FeedEventCell.self)
    private var isPaginating = false
    private var _page: Int = 1
    private var footerView: LoadingFooterView?
    private var _callback: ((Bool) -> Void)?

//    override var customTableView: CustomNoKeyboardTableView? { _tableView }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
        _feedData.append(UserFeedModel())
        _setupUi()
        _loadingChat()
        _requestFeedData(true)
    }
    
    override func _refresh(_ callback: @escaping (Bool) -> Void) {
        self._callback = callback
        _requestFeedData(false)
    }
    
    private func _setupUi() {
        hideNavigationBar()
        NotificationCenter.default.addObserver(self, selector: #selector(handleVenueFollowState(_:)), name: .changeVenueFollowState, object: nil)
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: true,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: kEmptyString,
            emptyDataIconImage: nil,
            delegate: self)
        _tableView.proxyDelegate = self
        _tableView.delegate = self
        footerView = LoadingFooterView(frame: CGRect(x: 0, y: 0, width: _tableView.bounds.width, height: 44))
        _tableView.tableFooterView = footerView
        _tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
    }
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierUserActivity, kCellNibNameKey: kCellIdentifierUserActivity, kCellClassKey: UserActivityCell.self, kCellHeightKey: UserActivityCell.height],
            [kCellIdentifierKey: kCellIdentifierOffer, kCellNibNameKey: kCellIdentifierOffer, kCellClassKey: CommanOffersTableCell.self, kCellHeightKey: CommanOffersTableCell.height],
            [kCellIdentifierKey: kEmptyCellIdentifier, kCellNibNameKey: kEmptyCellIdentifier, kCellClassKey: EmptyDataCell.self, kCellHeightKey: EmptyDataCell.height],
            [kCellIdentifierKey: kLoadingCell, kCellNibNameKey: kLoadingCell, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height],
            [kCellIdentifierKey: kCellIdentifierEvent, kCellNibNameKey: kCellIdentifierEvent, kCellClassKey: FeedEventCell.self, kCellHeightKey: FeedEventCell.height]
        ]
    }
    
    private func _loadingChat() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        cellData.append([
            kCellIdentifierKey: kLoadingCell,
            kCellTagKey: self.kLoadingCell,
            kCellObjectDataKey: "loading",
            kCellClassKey: LoadingCell.self,
            kCellHeightKey: LoadingCell.height
        ])
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        self._tableView.loadData(cellSectionData)
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        if _feedData.count == 1 && _feedData[0].type.isEmpty {
            cellData.append([
                kCellIdentifierKey: kLoadingCell,
                kCellTagKey: kEmptyString,
                kCellObjectDataKey: "Loading...",
                kCellClassKey: LoadingCell.self,
                kCellHeightKey: LoadingCell.height
            ])
        } else if _feedData.isEmpty {
            cellData.append([
                kCellIdentifierKey: kEmptyCellIdentifier,
                kCellTagKey: kEmptyCellIdentifier,
                kCellObjectDataKey: ["type": "Feed","title" : "feed_fragment_empty_message".localized(), "icon": "empty_feed"],
                kCellClassKey: EmptyDataCell.self,
                kCellHeightKey: EmptyDataCell.height
            ])
        } else {
            _feedData.forEach { feeds in
                if feeds.type == "friend_updates" {
                    if feeds.user != nil {
                        cellData.append([
                            kCellIdentifierKey: kCellIdentifierUserActivity,
                            kCellTagKey: kCellIdentifierUserActivity,
                            kCellObjectDataKey: feeds,
                            kCellClassKey: UserActivityCell.self,
                            kCellHeightKey: UserActivityCell.height
                        ])
                    }
                } else if feeds.type == "venue_updates" {
                    if feeds.venue != nil {
                        cellData.append([
                            kCellIdentifierKey: kCellIdentifierOffer,
                            kCellTagKey: kCellIdentifierOffer,
                            kCellObjectDataKey: feeds,
                            kCellClassKey: CommanOffersTableCell.self,
                            kCellHeightKey: CommanOffersTableCell.height
                        ])
                    }
                } else if feeds.type == "event_checkin" {
                    if feeds.user != nil {
                        if !Utils.isVenueDetailEmpty(feeds.event?.venueDetail) {
                            cellData.append([
                                kCellIdentifierKey: kCellIdentifierEvent,
                                kCellTagKey: kCellIdentifierEvent,
                                kCellObjectDataKey: feeds,
                                kCellClassKey: FeedEventCell.self,
                                kCellHeightKey: FeedEventCell.height
                            ])
                        }
                    }
                }
            }
        }
        if cellData.count != .zero {
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        }
        _tableView.loadData(cellSectionData)
    }
    
    @objc private func handleVenueFollowState(_ notification: Notification) {
        _feedData.removeAll()
        _requestFeedData()
    }
    
    private func _requestFeedData(_ shouldRefresh: Bool = false) {
//        if shouldRefresh { showHUD() }
        WhosinServices.getFeedList(page: _page, limit: 30) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            self.footerView?.stopAnimating()
            guard let data = container?.data else {
                self._loadData()
                self._callback?(true)
                return
            }
            self.isPaginating = false
            if !data.isEmpty {
                self._feedData.append(contentsOf: data)
                self._loadData()
            } else if _feedData.count == 1 && _feedData[0].type.isEmpty {
                self._feedData.removeAll()
                self._loadData()
            }
            self._callback?(true)
        }
    }
}

extension FeedVC: CustomNoKeyboardTableViewDelegate, UITableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? UserActivityCell {
            guard let object = cellDict?[kCellObjectDataKey] as? UserFeedModel else { return }
            cell.setupData(object)
        } else if let cell = cell as? CommanOffersTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? UserFeedModel else { return }
            cell.setup(object.offer ?? OffersModel(), type: .feed, object)
            cell._feedInfoView.isHidden = false
        } else if let cell = cell as? FeedEventCell {
            guard let object = cellDict?[kCellObjectDataKey] as? UserFeedModel else { return }
            cell.setupData(object)
        } else if let cell = cell as? EmptyDataCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [String:Any] else { return }
            cell.setupData(object)
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if cell is CommanOffersTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? UserFeedModel else { return }
            let vc = INIT_CONTROLLER_XIB(OfferPackageDetailVC.self)
            vc.modalPresentationStyle = .overFullScreen
            vc.offerId = object.offer?.id ?? ""
            vc.venueModel = object.offer?.venue
            vc.timingModel = object.offer?.venue?.timing.toArrayDetached(ofType: TimingModel.self)
            vc.vanueOpenCallBack = { venueId, venueModel in
                let vc = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
                vc.venueId = venueId
                vc.venueDetailModel = venueModel
                self.navigationController?.pushViewController(vc, animated: true)
            }
            vc.buyNowOpenCallBack = { offer, venue, timing in
                let vc = INIT_CONTROLLER_XIB(BuyPackgeVC.self)
                vc.isFromActivity = false
                vc.type = "offers"
                vc.timingModel = timing
                vc.offerModel = offer
                vc.venue = venue
                vc.setCallback {
                    let controller = INIT_CONTROLLER_XIB(MyCartVC.self)
                    controller.modalPresentationStyle = .overFullScreen
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
            presentAsPanModal(controller: vc)
        } else if cell is UserActivityCell {
            guard let object = cellDict?[kCellObjectDataKey] as? UserFeedModel else { return }
            let controller = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
            controller.venueDetailModel = object.venue
            controller.venueId = object.venue?.id ?? ""
            navigationController?.pushViewController(controller, animated: true)
        } else if cell is FeedEventCell {
            guard let object = cellDict?[kCellObjectDataKey] as? UserFeedModel else { return }
            let controller = INIT_CONTROLLER_XIB(EventDetailVC.self)
            controller.eventId = object.event?.id ?? ""
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScroll(scrollView)
        let scrollOffsetThreshold = scrollView.contentSize.height - scrollView.bounds.height
        if scrollOffsetThreshold > 0 && scrollView.contentOffset.y > scrollOffsetThreshold && !isPaginating {
            performPagination()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        didEndDecelerating(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        didEndDragging(scrollView, willDecelerate: decelerate)
    }

    
    private func performPagination() {
        guard !isPaginating else { return }
        if _feedData.count % 30 == 0 {
            isPaginating = true
            _page += 1
            footerView?.startAnimating()
            _requestFeedData(false)
        }
    }
    
}
