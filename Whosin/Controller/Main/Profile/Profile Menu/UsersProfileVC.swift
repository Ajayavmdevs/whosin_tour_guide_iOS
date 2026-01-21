import UIKit
import Parchment
import SnapKit
import ExpandableLabel

class UsersProfileVC: ChildViewController {

    @IBOutlet weak var _switchProfileBtn: CustomActivityButton!
    @IBOutlet private weak var _tableView: CustomTableView!
    @IBOutlet private weak var _visualEffectView: UIVisualEffectView!
    public var contactId: String = kEmptyString
    public var userDetail: UserDetailModel?
    private var suggestedUsers: [UserDetailModel] = []
    private var _feedData: [UserFeedModel] = []
    private let kCellIdentifier = String(describing: UserInfoTableCell.self)
    private let kCellIdentifierVenue = String(describing: UserActivityCell.self)
    private let kCellIdentifierOffer = String(describing: CommanOffersTableCell.self)
    private let kCellIdentifierEvent = String(describing: FeedEventCell.self)
    private let kCellIdentifierActivity = String(describing: FeedActivityCell.self)
    private let kSuggestedUserIdentifier = String(describing: SuggestedFriendsTableCell.self)
    private let kEmptyCellIdentifier = String(describing: EmptyDataCell.self)
    private var _page: Int = 1
    private var _emptyData = [[String:Any]]()
    private var isPaginating = false
    private var footerView: LoadingFooterView?
    public var followStateCallBack: ((_ id: String, _ follow: String) -> Void)?
    public var isSwitchProfile: Bool = false

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        showHUD()
        _setupUi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        _feedData.removeAll()
    }
    
    private func _setupUi() {
        hideNavigationBar()
        _tableView.setup(
            cellPrototypes: _prototypes,
            hasHeaderSection: true,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            emptyDataText: "There is no follow list available",
            emptyDataIconImage: UIImage(named: "empty_follower"),
            emptyDataDescription: kEmptyString,
            delegate: self)
        _visualEffectView.alpha = 0.0
        footerView = LoadingFooterView(frame: CGRect(x: 0, y: 0, width: _tableView.bounds.width, height: 44))
        _tableView.tableFooterView = footerView
        _requestProfileDetail()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototypes: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: UserInfoTableCell.self, kCellHeightKey: UserInfoTableCell.height],
                [kCellIdentifierKey: kCellIdentifierVenue, kCellNibNameKey: kCellIdentifierVenue, kCellClassKey: UserActivityCell.self, kCellHeightKey: UserActivityCell.height],
                [kCellIdentifierKey: kCellIdentifierOffer, kCellNibNameKey: kCellIdentifierOffer, kCellClassKey: CommanOffersTableCell.self, kCellHeightKey: CommanOffersTableCell.height],
                [kCellIdentifierKey: kCellIdentifierEvent, kCellNibNameKey: kCellIdentifierEvent, kCellClassKey: FeedEventCell.self, kCellHeightKey: FeedEventCell.height],
                [kCellIdentifierKey: kCellIdentifierActivity, kCellNibNameKey: kCellIdentifierActivity, kCellClassKey: FeedActivityCell.self, kCellHeightKey: FeedActivityCell.height],
                [kCellIdentifierKey: kEmptyCellIdentifier, kCellNibNameKey: kEmptyCellIdentifier, kCellClassKey: EmptyDataCell.self, kCellHeightKey: EmptyDataCell.height],
                [kCellIdentifierKey: kSuggestedUserIdentifier, kCellNibNameKey: kSuggestedUserIdentifier, kCellClassKey: SuggestedFriendsTableCell.self, kCellHeightKey: SuggestedFriendsTableCell.height]

        ]
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestProfileDetail(_ isRloadProfile: Bool = false) {
        WhosinServices.getUserProfile(userId: contactId) { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container?.data else {
                self.hideHUD(error: error)
                return
            }
            self.userDetail = data
            if APPSESSION.userDetail?.isRingMember == true, data.isPromoter {
                if !isSwitchProfile {
                    let vc = INIT_CONTROLLER_XIB(PromoterPublicProfileVc.self)
                    vc.promoterId = data.id
                    vc.isFromPersonal = true
                    navigationController?.pushViewController(vc, animated: false)
                }
                self._switchProfileBtn.isHidden = !(data.isPromoter)
            } else if APPSESSION.userDetail?.isPromoter == true, data.isRingMember {
                if !isSwitchProfile {
                    self._switchProfileBtn.setTitle("switch_to_complimentary".localized())
                    let vc = INIT_CONTROLLER_XIB(ComplementaryPublicProfileVC.self)
                    vc.complimentryId = data.id
                    vc.isFromPersonal = true
                    navigationController?.pushViewController(vc, animated: false)
                }
                self._switchProfileBtn.isHidden = !(data.isRingMember)
            } else {
                self._switchProfileBtn.isHidden = true
            }
            self._switchProfileBtn.setTitle(data.isPromoter ? "switch_to_promoter".localized() : "switch_to_complimentary".localized())
            self._emptyData.removeAll()
            self._emptyData.append(["title" : "\(data.fullName) feed's looking a little too quiet", "icon": "empty_feed"])
            if !isRloadProfile {
                self._requestSuggestedFriend(data.id)
                self._requestFeedData()
            }
        }
    }
    
    private func _requestFeedData() {
        WhosinServices.getFreindFeedList(page: _page, limit: 30, friendId: contactId) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            self.footerView?.stopAnimating()
            guard let data = container?.data else { return }
            if !data.isEmpty {
                self.isPaginating = false
                self._feedData.append(contentsOf: data)
                self._loadData()
            }
        }
    }
    
    private func _requestSuggestedFriend(_ id: String) {
        WhosinServices.getSuggestedUserById(userId: id) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self.suggestedUsers = data
            self._loadData()
        }
    }

    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        if let userDetail = userDetail {
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: userDetail,
                kCellClassKey: UserInfoTableCell.self,
                kCellHeightKey: UserInfoTableCell.height
            ])
        }
        
        if !suggestedUsers.isEmpty {
            cellData.append([
                kCellIdentifierKey: kSuggestedUserIdentifier,
                kCellTagKey: kSuggestedUserIdentifier,
                kCellObjectDataKey: suggestedUsers,
                kCellTitleKey: false,
                kCellClassKey: SuggestedFriendsTableCell.self,
                kCellHeightKey: SuggestedFriendsTableCell.height
            ])
        }
        
        if _feedData.isEmpty {
            _emptyData.forEach { emptyData in
                cellData.append([
                    kCellIdentifierKey: kEmptyCellIdentifier,
                    kCellTagKey: kEmptyCellIdentifier,
                    kCellObjectDataKey: emptyData,
                    kCellClassKey: EmptyDataCell.self,
                    kCellHeightKey: EmptyDataCell.height
                ])
            }
        }
        else {
            _feedData.forEach { feeds in
                if feeds.type == "friend_updates" {
                    if feeds.user != nil {
                        cellData.append([
                            kCellIdentifierKey: kCellIdentifierVenue,
                            kCellTagKey: kCellIdentifierVenue,
                            kCellObjectDataKey: feeds,
                            kCellTitleKey: false,
                            kCellClassKey: UserActivityCell.self,
                            kCellHeightKey: UserActivityCell.height
                        ])
                    }
                }  else if feeds.type == "venue_updates" {
                    if feeds.venue != nil {
                        cellData.append([
                            kCellIdentifierKey: kCellIdentifierOffer,
                            kCellTagKey: kCellIdentifierOffer,
                            kCellObjectDataKey: feeds,
                            kCellTitleKey: false,
                            kCellClassKey: CommanOffersTableCell.self,
                            kCellHeightKey: CommanOffersTableCell.height
                        ])
                    }
                } else if feeds.type == "event_checkin" {
                    if feeds.event != nil {
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
                } else if feeds.type == "activity_recommendation" {
                    if feeds.activity != nil {
                        cellData.append([
                            kCellIdentifierKey: kCellIdentifierActivity,
                            kCellTagKey: kCellIdentifierActivity,
                            kCellObjectDataKey: feeds,
                            kCellClassKey: FeedActivityCell.self,
                            kCellHeightKey: FeedActivityCell.height
                        ])
                    }
                } else if feeds.type == "venue_recommendation" {
                    if feeds.venue != nil {
                        print("feed data ========== \(feeds.venue?.name) -- \(feeds.venue?.isFollowing)")
                        cellData.append([
                            kCellIdentifierKey: kCellIdentifierVenue,
                            kCellTagKey: kCellIdentifierVenue,
                            kCellObjectDataKey: feeds,
                            kCellTitleKey: true,
                            kCellClassKey: UserActivityCell.self,
                            kCellHeightKey: UserActivityCell.height
                        ])
                    }
                } else if feeds.type == "offer_recommendation" {
                    if feeds.offer != nil {
                        cellData.append([
                            kCellIdentifierKey: kCellIdentifierOffer,
                            kCellTagKey: kCellIdentifierOffer,
                            kCellObjectDataKey: feeds,
                            kCellTitleKey: true,
                            kCellClassKey: CommanOffersTableCell.self,
                            kCellHeightKey: CommanOffersTableCell.height
                        ])
                    }
                }
            }
        }
        
        if cellData.count != .zero {
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        }
        DISPATCH_ASYNC_MAIN {
            self._tableView.loadData(cellSectionData)
        }
    }

    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @IBAction func _handleSwitchProfile(_ sender: CustomActivityButton) {
        guard let id = userDetail?.id else { return }
        if userDetail?.isPromoter == true {
            let vc = INIT_CONTROLLER_XIB(PromoterPublicProfileVc.self)
            vc.promoterId = id
            vc.isFromPersonal = true
            navigationController?.pushViewController(vc, animated: false)
        } else  if userDetail?.isRingMember == true {
            let vc = INIT_CONTROLLER_XIB(ComplementaryPublicProfileVC.self)
            vc.complimentryId = id
            vc.isFromPersonal = true
            navigationController?.pushViewController(vc, animated: false)
        }
    }
    

    @IBAction private func _handleHomeEvent(_ sender: UIButton) {
        if let rootVC = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count ?? 0) - 2] {
            if rootVC is ComplementaryPublicProfileVC || rootVC is PromoterPublicProfileVc {
                if let parentVC = self.navigationController?.viewControllers.dropLast().dropLast().last {
                    self.navigationController?.popToViewController(parentVC, animated: true)
                } else {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

// --------------------------------------
// MARK: <CustomTableViewDelegate>
// --------------------------------------

extension UsersProfileVC: CustomTableViewDelegate,UIScrollViewDelegate, UITableViewDelegate  {
        
    private func performPagination() {
        guard !isPaginating else { return }
        if _feedData.count % 30 == 0 {
            isPaginating = true
            _page += 1
            footerView?.startAnimating()
            _requestFeedData()
        }
//        isPaginating = true
//        _page += 1
//        footerView?.startAnimating()
//        _requestFeedData()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollOffsetThreshold = scrollView.contentSize.height - scrollView.bounds.height
        if scrollOffsetThreshold > 0 && scrollView.contentOffset.y > scrollOffsetThreshold && !isPaginating {
            performPagination()
        }
        let yOffset = scrollView.contentOffset.y
        let threshold: CGFloat = 20
        if yOffset > threshold {
            UIView.animate(withDuration: 0.50, animations: { [weak self] in
                guard let self = self else { return }
                self._visualEffectView.alpha = 1.0
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.50, animations: { [weak self] in
                guard let self = self else { return }
                self._visualEffectView.alpha = 0.0
            }, completion: nil)
        }
    }

    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? UserInfoTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
            cell.setupData(object)
            cell.delegate = self
            cell.followStateCallBack = { isFollow in
                self.followStateCallBack?(object.id, isFollow)
                self._requestProfileDetail(true)
            }
        } else if let cell = cell as? SuggestedFriendsTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [UserDetailModel] else { return }
            cell.setupData(object,title: "suggested_friends".localized(), isBlock: false)
        }
        else if let cell = cell as? UserActivityCell {
            guard let object = cellDict?[kCellObjectDataKey] as? UserFeedModel,
                  let isRecommended = cellDict?[kCellTitleKey] as? Bool else { return }
            guard let user = userDetail else { return }
            cell.setupData(object, isRecommended: isRecommended, user: user, isOtherProfile: true)
        }
        else if let cell = cell as? CommanOffersTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? UserFeedModel,
                  let isRecommended = cellDict?[kCellTitleKey] as? Bool else { return }
            guard let user = userDetail else { return }
            cell.setup(object.offer ?? OffersModel(), type: .feed, object, isRecommended, user: user)
            cell._feedInfoView.isHidden = false
        }
        else if let cell = cell as? FeedEventCell {
            guard let object = cellDict?[kCellObjectDataKey] as? UserFeedModel else { return }
            guard let user = userDetail else { return }
            cell.setupData(object, user: user, isOtherProfile: true)
        }
        else if let cell = cell as? FeedActivityCell {
            guard let object = cellDict?[kCellObjectDataKey] as? UserFeedModel else { return }
            guard let user = userDetail else { return }
            cell.setupData(object, user: user)
        }
        else if let cell = cell as? EmptyDataCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [String: Any] else { return }
            cell.setupData(object)
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String: Any]?, indexPath: IndexPath) {
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
            controller.venueId = object.venue?.id ?? kEmptyString
            controller.followStateCallBack = { id, follow in
                self._feedData.removeAll()
                self._requestFeedData()
            }
            navigationController?.pushViewController(controller, animated: true)
        } else if cell is FeedEventCell {
            guard let object = cellDict?[kCellObjectDataKey] as? UserFeedModel else { return }
            let controller = INIT_CONTROLLER_XIB(EventDetailVC.self)
            controller.eventId = object.event?.id ?? kEmptyString
            self.navigationController?.pushViewController(controller, animated: true)
        } else if cell is FeedActivityCell {
            guard let object = cellDict?[kCellObjectDataKey] as? UserFeedModel else { return }
            let controller = INIT_CONTROLLER_XIB(ActivityInfoVC.self)
            controller.activityId = object.activity?.id ?? kEmptyString
            controller.activityName = object.activity?.name ?? kEmptyString
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
}

extension UsersProfileVC: userInfoDelegate {
    func bioReload(isRequest: Bool) {
        if isRequest {
            _requestProfileDetail(true)
        }
        _tableView.reload()
    }
}
