import UIKit

class PromoterEventDetailVC: ChildViewController {
    
    @IBOutlet weak var _venueAddress: CustomLabel!
    @IBOutlet weak var _venueName: CustomLabel!
    @IBOutlet weak var _venueLogo: UIImageView!
    @IBOutlet weak var _visualEffectView: UIVisualEffectView!
    @IBOutlet weak var _tableView: CustomTableView!
    @IBOutlet weak var _buttonView: CustomEventButtonView!
    private let kCellIdentifierVenue = String(describing: CompEventDetailHeaderCell.self)
    private let kCellIdentifierUserinfo = String(describing: CompEventUsersTableCell.self)
    private let kCellIdentifierReqirement = String(describing: CompEventReqirementsCell.self)
    private let kCellEventUsers = String(String(describing: EventInvitedUserListCell.self))
    private let kCellIdentifierSocail = String(describing: SocialAccountsCell.self)
    private let kCellIdentifierOffers = String(describing: OutingOfferTableCell.self)
    private let kCellIdentifierPlusOne = String(describing: PlusOneDetailViewCell.self)
    private let kLoadingCell = String(describing: LoadingCell.self)
    public var eventModel: PromoterEventsModel?
    private var refreshControl = UIRefreshControl()
    public var isComplementary: Bool = false
    public var isplusOne: Bool = false
    public var id: String = kEmptyString
    public var openViewTicket:(()-> Void)?
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _loadData(true)
        setupUi()
        hideNavigationBar()
        if isplusOne {
            _requestPlusOneEventDetail(eventModel == nil)
        } else {
        isComplementary ? _requestComplementaryEventDetail() : _reqEventDetail()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(handleReloadMyEvent(_:)), name: .reloadMyEventsNotifier, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleReloadMyEvent(_:)), name: .reloadEventNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleReloadMyEvent(_:)), name: .changereloadNotificationUpdateState, object: nil)
        _buttonView.openViewTicket = {
            self.openViewTicket?()
        }
    }
    
    override func setupUi() {
        _visualEffectView.alpha = 0
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "There is no members available",
            emptyDataIconImage: UIImage(named: "empty_explore"),
            emptyDataDescription: nil,
            delegate: self)
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        refreshControl.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        _tableView.refreshControl = refreshControl
        _tableView.proxyDelegate = self
        _tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self._tableView == nil { return }
        self._tableView.setContentOffset(_tableView.contentOffset, animated: false)
        DISPATCH_ASYNC_MAIN {
            self._tableView.visibleCells.forEach { cell in
                if cell is CompEventDetailHeaderCell {
                    (cell as? CompEventDetailHeaderCell)?._eventGalleryView.pauseVideos()
                }
            }
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierVenue, kCellNibNameKey: kCellIdentifierVenue, kCellClassKey: CompEventDetailHeaderCell.self, kCellHeightKey: CompEventDetailHeaderCell.height],
            [kCellIdentifierKey: kCellIdentifierUserinfo, kCellNibNameKey: kCellIdentifierUserinfo, kCellClassKey: CompEventUsersTableCell.self, kCellHeightKey: CompEventUsersTableCell.height],
            [kCellIdentifierKey: kCellIdentifierReqirement, kCellNibNameKey: kCellIdentifierReqirement, kCellClassKey: CompEventReqirementsCell.self, kCellHeightKey: CompEventReqirementsCell.height],
            [kCellIdentifierKey: kCellIdentifierSocail, kCellNibNameKey: kCellIdentifierSocail, kCellClassKey: SocialAccountsCell.self, kCellHeightKey: SocialAccountsCell.height],
            [kCellIdentifierKey: kCellIdentifierOffers, kCellNibNameKey: kCellIdentifierOffers, kCellClassKey: OutingOfferTableCell.self, kCellHeightKey: OutingOfferTableCell.height],
            [kCellIdentifierKey: kCellIdentifierPlusOne, kCellNibNameKey: kCellIdentifierPlusOne, kCellClassKey: PlusOneDetailViewCell.self, kCellHeightKey: PlusOneDetailViewCell.height],
            [kCellIdentifierKey: kCellEventUsers, kCellNibNameKey: kCellEventUsers, kCellClassKey: EventInvitedUserListCell.self, kCellHeightKey: EventInvitedUserListCell.height],
            [kCellIdentifierKey: kLoadingCell, kCellNibNameKey: kLoadingCell, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height]
        ]
    }
    
    private func _loadData(_ isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        _venueLogo.loadWebImage((eventModel?.venueType == "venue" ? eventModel?.venue?.slogo ?? kEmptyString : eventModel?.customVenue?.image) ?? "", name: eventModel?.venue?.name ?? kEmptyString)
        _venueName.text = eventModel?.venueType == "venue" ? eventModel?.venue?.name : eventModel?.customVenue?.name
        _venueAddress.text = eventModel?.venueType == "venue" ? eventModel?.venue?.address : eventModel?.customVenue?.address
        if isLoading {
            cellData.append([
                kCellIdentifierKey: kLoadingCell,
                kCellTagKey: kLoadingCell,
                kCellObjectDataKey: "loading",
                kCellClassKey: LoadingCell.self,
                kCellHeightKey: LoadingCell.height
            ])
        } else {
            cellData.append([
                kCellIdentifierKey: kCellIdentifierVenue,
                kCellTagKey: kCellIdentifierVenue,
                kCellObjectDataKey: eventModel,
                kCellClassKey: CompEventDetailHeaderCell.self,
                kCellHeightKey: CompEventDetailHeaderCell.height
            ])
            
            if eventModel?.offer != nil {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierOffers,
                    kCellTagKey: kCellIdentifierOffers,
                    kCellObjectDataKey: eventModel?.offer,
                    kCellClassKey: OutingOfferTableCell.self,
                    kCellHeightKey: OutingOfferTableCell.height
                ])
            }
            
            cellData.append([
                kCellIdentifierKey: kCellEventUsers,
                kCellTagKey: kCellEventUsers,
                kCellObjectDataKey: eventModel,
                kCellClassKey: EventInvitedUserListCell.self,
                kCellHeightKey: EventInvitedUserListCell.height
            ])
            
            if eventModel?.requirementsAllowed.isEmpty == false || eventModel?.requirementsNotAllowed.isEmpty == false {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierReqirement,
                    kCellTagKey: true,
                    kCellTitleKey: "Requirements",
                    kCellObjectDataKey: eventModel,
                    kCellClassKey: CompEventReqirementsCell.self,
                    kCellHeightKey: CompEventReqirementsCell.height
                ])
            }
            
            if eventModel?.benefitsIncluded.isEmpty == false || eventModel?.benefitsNotIncluded.isEmpty == false {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierReqirement,
                    kCellTagKey: true,
                    kCellTitleKey: "Benefits",
                    kCellObjectDataKey: eventModel,
                    kCellClassKey: CompEventReqirementsCell.self,
                    kCellHeightKey: CompEventReqirementsCell.height
                ])
            }
            
            if eventModel?.plusOneAccepted == true, !isplusOne  {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierPlusOne,
                    kCellTagKey: kCellIdentifierPlusOne,
                    kCellObjectDataKey: eventModel,
                    kCellClassKey: PlusOneDetailViewCell.self,
                    kCellHeightKey: PlusOneDetailViewCell.height
                ])
            }
            
            cellData.append([
                kCellIdentifierKey: kCellIdentifierSocail,
                kCellObjectDataKey: eventModel?.socialAccountsToMention.toArrayDetached(ofType: SocialAccountsModel.self) ?? [],
                kCellClassKey: SocialAccountsCell.self,
                kCellHeightKey: SocialAccountsCell.height
            ])
            
//            cellData.append([
//                kCellIdentifierKey: kCellIdentifierUserinfo,
//                kCellTagKey: kCellIdentifierUserinfo,
//                kCellObjectDataKey: eventModel,
//                kCellClassKey: CompEventUsersTableCell.self,
//                kCellHeightKey: CompEventUsersTableCell.height
//            ])
        }
        
        if cellData.count != .zero {
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        }
        
        _tableView.loadData(cellSectionData)
    }
    
    // --------------------------------------
    // MARK: service
    // --------------------------------------
    
    private func _reqEventDetail(_ isLoading: Bool = false) {
        guard APPSESSION.userDetail?.isPromoter == true else { return }
        if isLoading { showHUD() }
        WhosinServices.getMyEventDetail(id: id) { [weak self] container, error in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self.eventModel = data
            self._buttonView.isHidden = false
            self._buttonView.setupData(data, isComplementary: isplusOne ? true : isComplementary, isPlusOne: isplusOne)
            self._loadData()
        }
    }
    
    private func _requestComplementaryEventDetail(_ isLoading: Bool = false) {
        guard APPSESSION.userDetail?.isRingMember == true else { return }
        if isLoading { showHUD() }
        WhosinServices.getComplementaryEventDetail(eventId: id) { [weak self] container, error in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self.eventModel = data
            self._buttonView.isHidden = false
            self._buttonView.setupData(data, isComplementary: isplusOne ? true : isComplementary, isPlusOne: isplusOne)
            self._loadData()
        }
    }
    
    private func _requestPlusOneEventDetail(_ isLoading: Bool = false) {
        if isLoading { showHUD() }
        WhosinServices.getPlusOneEventDetail(eventId: id) { [weak self] container, error in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self.eventModel = data
            self._buttonView.isHidden = false
            self._buttonView.setupData(data, isComplementary: isplusOne ? true : isComplementary, isPlusOne: isplusOne)
            self._loadData()
        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    private func fetchData(completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            completion()
        }
    }

    @objc private func refreshData(_ sender: Any) {
        fetchData {
            DispatchQueue.main.async {
                if self.isplusOne {
                    self._requestPlusOneEventDetail()
                } else {
                    self.isComplementary ? self._requestComplementaryEventDetail() : self._reqEventDetail()
                }
            }
        }
    }
    
    @objc func handleReloadMyEvent(_ notification: Notification) {
        if self.isplusOne {
            self._requestPlusOneEventDetail()
        } else {
            isComplementary ? _requestComplementaryEventDetail() : _reqEventDetail()
        }
    }
    
    @IBAction func _handleMenuEvent(_ sender: UIButton) {
        guard let _event = eventModel else { return }

        let alert = UIAlertController(title: _event.venueType == "venue" ? _event.venue?.name : _event.customVenue?.name, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "share".localized(), style: .default, handler: {action in
            if APPSESSION.userDetail?.isPromoter == true {
                let navController = INIT_CONTROLLER_XIB(ShareBottomSheet.self)
                navController.promoterEvent = _event
                navController.isPromoter = true
                navController.modalPresentationStyle = .overFullScreen
                self.present(navController, animated: true)
            } else {
                Utils.generateDynamicLinksForPromoterEvent(controller: self, model: _event)
            }
        }))

        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .destructive, handler: { _ in }))
        present(alert, animated: true, completion:{
            alert.view.superview?.subviews[0].isUserInteractionEnabled = true
            alert.view.superview?.subviews[0].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })

    }
    
    @objc func alertControllerBackgroundTapped() {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func _handleBackEvent(_ sender: UIButton) {
        dismissOrBack()
    }
    
}

// --------------------------------------
// MARK: TableView delegate
// --------------------------------------

extension PromoterEventDetailVC: CustomTableViewDelegate ,UIScrollViewDelegate, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        let threshold: CGFloat = 30
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
        if let cell = cell as? CompEventDetailHeaderCell {
            guard let object = cellDict?[kCellObjectDataKey] as? PromoterEventsModel else { return }
            cell.setupData(object,isCM: isComplementary, isPlusOne: isplusOne)
        } else if let cell = cell as? EventInvitedUserListCell {
            guard let object = cellDict?[kCellObjectDataKey] as? PromoterEventsModel else { return }
            cell.setupData(object, isComplementary: isComplementary || isplusOne)
        } else if let cell = cell as? CompEventUsersTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? PromoterEventsModel else { return }
            cell.setupData(object, isComplementary: self.isComplementary || isplusOne)
        } else if let cell = cell as? CompEventReqirementsCell {
            guard let object = cellDict?[kCellObjectDataKey] as? PromoterEventsModel, let isAllow = cellDict?[kCellTagKey] as? Bool, let title = cellDict?[kCellTitleKey] as? String else { return }
            cell.setupData(object, titleText: title)
        } else if let cell = cell as? SocialAccountsCell {
            cell.eventNm = eventModel?.venue?.name ?? ""
            cell.height = 60
            guard let object = cellDict?[kCellObjectDataKey] as? [SocialAccountsModel] else { return }
            cell.setUpSocialTag(object)
        } else if let cell = cell as? OutingOfferTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? OffersModel else { return }
            cell.setupEventData(object)
        } else if let cell = cell as? PlusOneDetailViewCell {
            guard let object = cellDict?[kCellObjectDataKey] as? PromoterEventsModel else { return }
            cell.setupData(object, isPlusOne: isplusOne)
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let compEventCell = cell as? CompEventDetailHeaderCell {
            compEventCell._eventGalleryView.pauseVideos()
        }
    }
    
}

