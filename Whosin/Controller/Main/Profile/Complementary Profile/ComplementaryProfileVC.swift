import UIKit

class ComplementaryProfileVC: ChildViewController {
    
    @IBOutlet weak var _userImg: UIImageView!
    @IBOutlet private weak var _tableView: CustomTableView!
    @IBOutlet private weak var _userName: UILabel!
    @IBOutlet private weak var _visualEffectView: UIVisualEffectView!
    @IBOutlet weak var _tabView: UIView!
    public var _selectedIndex: Int = 0
    private var _notificationType: String = "users"
    private let kCellIdentifierHeader = String(describing: PromoterProfileHeaderCell.self)
    private let KCelllProfileScore = String(describing: ProfileScoreTableCell.self)
    private let kCellIdentifierReview = String(describing: RatingTableCell.self)
    private let kCellRing = String(describing: ComplementaryRingTableCell.self)
    private let KCellEvent = String(describing: ComplementaryEventImInTableCell.self)
    private let kCellMyList = String(describing: ComplementaryMyListTableCell.self)
    private let kCellMyEvents = String(describing: ComplementaryMyEventTableCell.self)
    private let kCellIdentifierUserRequest = String(describing: UserRequestTableCell.self)
    private let kCellIdentifierEventRequest = String(describing: EventRequestTableCell.self)
    private let kCellNotificationEvent = String(describing: CMNotificationEventTableCell.self)
    private let kCellFilterEvent = String(describing: SocialEventFilterCell.self)
    private let kEmptyCellIdentifier = String(describing: EmptyDataCell.self)
    private let kCellIdentifierLoading = String(describing: LoadingCell.self)
    private var _complimentaryModel: PromoterProfileModel? = APPSESSION.CMProfile
    private var _eventList: [PromoterEventsModel] = []
    private var _userNotifications: [NotificationModel] = []
    private var _chatList: [PromoterChatListModel] = []
    private var refreshControl = UIRefreshControl()
    private var isLoadingMyEvent: Bool = false
    private var isLoadingChat: Bool = false
    private var isLoadingNotification: Bool = false
    private var tabView = CustomPromoterPublicHeaderView()
    private var filterType: Int = -1
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
        DISPATCH_ASYNC_MAIN {
            let headerView = CustomPromoterPublicHeaderView(frame: self._tabView.frame.standardized)
            headerView.setupData(self._selectedIndex, selectedType: self._notificationType)
            headerView.delegate = self
            self.tabView = headerView
            self._tabView.addSubview(self.tabView)
            self.tabView.translatesAutoresizingMaskIntoConstraints = false
            self.tabView.snp.makeConstraints { make in
                make.edges.equalTo(self._tabView)
            }
        }
//        if _complimentaryModel != nil { _loadData() }
        setupUi()
    }
    
    override func setupUi() {
        _visualEffectView.alpha = _selectedIndex != 3 ? 1.0 : 0.0
        _userName.alpha = _selectedIndex != 3 ? 1.0 : 0.0
        _userImg.alpha = _selectedIndex != 3 ? 1.0 : 0.0
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
        _tableView.proxyDelegate = self
        _requestEventList()
        _requestGetProfile()
        _requestInEventList()
        _requestUserNoftification()
        _requestChatList()
        PromoterApplicationVC.reloadOnBack = { self._requestGetProfile() }
        NotificationCenter.default.addObserver(self, selector: #selector(handleReloadMyEvent(_:)), name: .reloadMyEventsNotifier, object: nil)
        NotificationCenter.default.addObserver(self, selector:  #selector(handleReload), name: kRelaodActivitInfo, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePushReload), name: .changereloadNotificationUpdateState, object: nil)
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestGetProfile(isAnotherIndex: Bool = false) {
        WhosinServices.getComplementaryProfile { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            self.refreshControl.endRefreshing()
            guard let data = container?.data else { return}
            self._complimentaryModel = data
            Preferences.cmProfile = data.toJSONString() ?? "{}"
            if !isAnotherIndex {
                self._loadData(selectedIndex: _selectedIndex)
            }
        }
    }
    
    private func _requestEventList(_ isReload: Bool = false) {
        isLoadingMyEvent = !isReload
        WhosinServices.getEventList { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            self.refreshControl.endRefreshing()
            self.isLoadingMyEvent = false
            guard let data = container?.data else { return}
            self._eventList = data
            if isReload || _selectedIndex == 0 {
                self._loadData(selectedIndex: _selectedIndex)
            }
        }
    }
    
    private func _requestInEventList() {
        WhosinServices.promoterInEventsList { [weak self] container, error in
            guard let self = self else { return }
            self.showError(error)
            guard let data = container?.data else { return}
            APPSETTING.InEventsList = data
        }
    }
    
    private func _requestChatList(_ isReload: Bool = false) {
        isLoadingChat = !isReload
        WhosinServices.complementaryChatList() { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            self.refreshControl.endRefreshing()
            self.isLoadingChat = false
            guard let data = container?.data else { return }
            self._chatList = data
            if isReload || _selectedIndex == 2 {
                self._loadData(selectedIndex: _selectedIndex)
            }
        }
    }
    
    private func _requestUserNoftification(_ isReload: Bool = false) {
        isLoadingNotification = !isReload
        WhosinServices.complementaryUserNotification { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            self.refreshControl.endRefreshing()
            self.isLoadingNotification = false
            guard let data = container?.data else { return}
            self._userNotifications = data.notification.toArrayDetached(ofType: NotificationModel.self)
            if isReload || _selectedIndex == 1 {
                _loadData(selectedIndex: _selectedIndex)
            }
        }
    }
    
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierHeader, kCellNibNameKey: kCellIdentifierHeader, kCellClassKey: PromoterProfileHeaderCell.self, kCellHeightKey: PromoterProfileHeaderCell.height],
            [kCellIdentifierKey: KCelllProfileScore, kCellNibNameKey: KCelllProfileScore, kCellClassKey: ProfileScoreTableCell.self, kCellHeightKey: ProfileScoreTableCell.height],
            [kCellIdentifierKey: kCellIdentifierReview, kCellNibNameKey: kCellIdentifierReview, kCellClassKey: RatingTableCell.self, kCellHeightKey: RatingTableCell.height],
            [kCellIdentifierKey: kCellRing, kCellNibNameKey: kCellRing, kCellClassKey: ComplementaryRingTableCell.self, kCellHeightKey: ComplementaryRingTableCell.height],
            [kCellIdentifierKey: KCellEvent, kCellNibNameKey: KCellEvent, kCellClassKey: ComplementaryEventImInTableCell.self, kCellHeightKey: ComplementaryEventImInTableCell.height],
            [kCellIdentifierKey: kCellMyList, kCellNibNameKey: kCellMyList, kCellClassKey: ComplementaryMyListTableCell.self, kCellHeightKey: ComplementaryMyListTableCell.height],
            [kCellIdentifierKey: kCellMyEvents, kCellNibNameKey: kCellMyEvents, kCellClassKey: ComplementaryMyEventTableCell.self, kCellHeightKey: ComplementaryMyEventTableCell.height],
            [kCellIdentifierKey: kCellIdentifierUserRequest, kCellNibNameKey: kCellIdentifierUserRequest, kCellClassKey: UserRequestTableCell.self, kCellHeightKey: UserRequestTableCell.height],
            [kCellIdentifierKey: kEmptyCellIdentifier, kCellNibNameKey: kEmptyCellIdentifier, kCellClassKey: EmptyDataCell.self, kCellHeightKey: EmptyDataCell.height],
            [kCellIdentifierKey: kCellIdentifierLoading, kCellNibNameKey: kCellIdentifierLoading, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height],
            [kCellIdentifierKey: kCellIdentifierEventRequest, kCellNibNameKey: kCellIdentifierEventRequest, kCellClassKey: EventRequestTableCell.self, kCellHeightKey: EventRequestTableCell.height],
            [kCellIdentifierKey: kCellNotificationEvent, kCellNibNameKey: kCellNotificationEvent, kCellClassKey: CMNotificationEventTableCell.self, kCellHeightKey: CMNotificationEventTableCell.height],
            [kCellIdentifierKey: kCellFilterEvent, kCellNibNameKey: kCellFilterEvent, kCellClassKey: SocialEventFilterCell.self, kCellHeightKey: SocialEventFilterCell.height]
            
        ]
    }
    
    private func _loadData(isLoading: Bool = false,selectedIndex: Int = 0) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        _tableView.contentInset = _selectedIndex != 3 ? UIEdgeInsets(top: 120, left: 0, bottom: 100, right: 0) : UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        _userName.text = _complimentaryModel?.profile?.fullName
        _userImg.loadWebImage(_complimentaryModel?.profile?.image  ?? kEmptyString, name: _complimentaryModel?.profile?.fullName ?? kEmptyString)
        
        
        switch selectedIndex {
        case 3:
            guard let model = _complimentaryModel else { return }
            
            cellData.append([
                kCellIdentifierKey: kCellIdentifierHeader,
                kCellTagKey: kCellIdentifierHeader,
                kCellObjectDataKey: model,
                kCellClassKey: PromoterProfileHeaderCell.self,
                kCellHeightKey: PromoterProfileHeaderCell.height
            ])
            
            cellData.append([
                kCellIdentifierKey: kCellFilterEvent,
                kCellTagKey: kCellFilterEvent,
                kCellObjectDataKey: model,
                kCellClassKey: SocialEventFilterCell.self,
                kCellHeightKey: SocialEventFilterCell.height
            ])
            
            //            cellData.append([
            //                kCellIdentifierKey: KCelllProfileScore,
            //                kCellTagKey: KCelllProfileScore,
            //                kCellObjectDataKey: model.score,
            //                kCellClassKey: ProfileScoreTableCell.self,
            //                kCellHeightKey: ProfileScoreTableCell.height
            //            ])
            
            
            if !model.inEvents.filter({ $0.status != "cancelled" && $0.status != "completed" }).isEmpty {
                cellData.append([
                    kCellIdentifierKey: KCellEvent,
                    kCellTagKey: "Events I’m IN",
                    kCellObjectDataKey: model.inEvents.toArrayDetached(ofType: PromoterEventsModel.self),
                    kCellClassKey: ComplementaryEventImInTableCell.self,
                    kCellHeightKey: ComplementaryEventImInTableCell.height
                ])
            }
            
            if !model.wishlistEvents.filter({ $0.status != "cancelled" && $0.status != "completed" }).isEmpty {
                var wishLists = model.wishlistEvents.toArrayDetached(ofType: PromoterEventsModel.self)
                wishLists.forEach { p in
                    p.isWishlisted = true
                }
                cellData.append([
                    kCellIdentifierKey: kCellMyList,
                    kCellTagKey: "My List",
                    kCellObjectDataKey: wishLists,
                    kCellClassKey: ComplementaryMyListTableCell.self,
                    kCellHeightKey: ComplementaryMyListTableCell.height
                ])
            }
            
            if !model.speciallyForMe.filter({ $0.status != "cancelled" && $0.status != "completed" }).isEmpty {
                cellData.append([
                    kCellIdentifierKey: KCellEvent,
                    kCellTagKey: "Specially for me",
                    kCellObjectDataKey: model.speciallyForMe.toArrayDetached(ofType: PromoterEventsModel.self),
                    kCellClassKey: ComplementaryEventImInTableCell.self,
                    kCellHeightKey: ComplementaryEventImInTableCell.height
                ])
            }
            
            if !model.ImInterested.filter({ $0.status != "cancelled" && $0.status != "completed" }).isEmpty {
                cellData.append([
                    kCellIdentifierKey: KCellEvent,
                    kCellTagKey: "Im Interested",
                    kCellObjectDataKey: model.ImInterested.toArrayDetached(ofType: PromoterEventsModel.self),
                    kCellClassKey: ComplementaryEventImInTableCell.self,
                    kCellHeightKey: ComplementaryEventImInTableCell.height
                ])
            }
            
        case 0:
            if isLoadingMyEvent {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierLoading,
                    kCellTagKey: kCellIdentifierLoading,
                    kCellObjectDataKey: true,
                    kCellClassKey: LoadingCell.self,
                    kCellHeightKey: LoadingCell.height
                ])
            } else {
                if _eventList.isEmpty {
                    cellData.append([
                        kCellIdentifierKey: kEmptyCellIdentifier,
                        kCellTagKey: kEmptyCellIdentifier,
                        kCellObjectDataKey: ["title" : "My Events looking a bit empty? Toss in some vouchers and kickstart those adventures!", "icon": "empty_offers"],
                        kCellClassKey: EmptyDataCell.self,
                        kCellHeightKey: EmptyDataCell.height
                    ])
                } else {
                    
                    if filterType == 0 {
                        let sortedEvents = _eventList.sorted { $0.distance < $1.distance }
                        sortedEvents.forEach { event in
                            if event.status != "cancelled" && event.status != "completed" {
                                cellData.append([
                                    kCellIdentifierKey: kCellMyEvents,
                                    kCellTagKey: kCellMyEvents,
                                    kCellObjectDataKey: event,
                                    kCellClassKey: ComplementaryMyEventTableCell.self,
                                    kCellHeightKey: ComplementaryMyEventTableCell.height
                                ])
                            }
                        }
                    } else if filterType == 1 {
                        let sortedEvents = _eventList.sorted {
                            guard let firstDate = $0.startingSoon, let secondDate = $1.startingSoon else {
                                return false
                            }
                            return firstDate < secondDate
                        }
                        sortedEvents.forEach { event in
                            if event.status != "cancelled" && event.status != "completed" {
                                cellData.append([
                                    kCellIdentifierKey: kCellMyEvents,
                                    kCellTagKey: kCellMyEvents,
                                    kCellObjectDataKey: event,
                                    kCellClassKey: ComplementaryMyEventTableCell.self,
                                    kCellHeightKey: ComplementaryMyEventTableCell.height
                                ])
                            }
                        }
                    } else {
                        _eventList.forEach { event in
                            if event.status != "cancelled" && event.status != "completed" {
                                cellData.append([
                                    kCellIdentifierKey: kCellMyEvents,
                                    kCellTagKey: kCellMyEvents,
                                    kCellObjectDataKey: event,
                                    kCellClassKey: ComplementaryMyEventTableCell.self,
                                    kCellHeightKey: ComplementaryMyEventTableCell.height
                                ])
                            }
                        }
                    }
                }
            }
        case 2:
            if isLoadingChat {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierLoading,
                    kCellTagKey: kCellIdentifierLoading,
                    kCellObjectDataKey: true,
                    kCellClassKey: LoadingCell.self,
                    kCellHeightKey: LoadingCell.height
                ])
            } else {
                if _chatList.isEmpty {
                    cellData.append([
                        kCellIdentifierKey: kEmptyCellIdentifier,
                        kCellTagKey: kEmptyCellIdentifier,
                        kCellObjectDataKey: ["title" : "Chat looking a bit empty? Toss in some vouchers and kickstart those adventures!", "icon": "empty_chat"],
                        kCellClassKey: EmptyDataCell.self,
                        kCellHeightKey: EmptyDataCell.height
                    ])
                } else {
                    _chatList.forEach({ model in
                        cellData.append([
                            kCellIdentifierKey: kCellIdentifierEventRequest,
                            kCellTagKey: kCellIdentifierEventRequest,
                            kCellObjectDataKey: model,
                            kCellClassKey: EventRequestTableCell.self,
                            kCellHeightKey: EventRequestTableCell.height
                        ])
                    })
                }
            }
        case 1:
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
                        kCellObjectDataKey: ["title" : "empty_notifications".localized(), "icon": "empty_notification"],
                        kCellClassKey: EmptyDataCell.self,
                        kCellHeightKey: EmptyDataCell.height
                    ])
                } else {
                    _userNotifications.forEach { model in
                        if model.type == "add-to-ring" {
                            cellData.append([
                                kCellIdentifierKey: kCellIdentifierUserRequest,
                                kCellTagKey: kCellIdentifierUserRequest,
                                kCellObjectDataKey: model,
                                kCellClassKey: UserRequestTableCell.self,
                                kCellHeightKey: UserRequestTableCell.height
                            ])
                        } else {
                            cellData.append([
                                kCellIdentifierKey: kCellNotificationEvent,
                                kCellTagKey: kCellNotificationEvent,
                                kCellObjectDataKey: model.event,
                                kCellClassKey: CMNotificationEventTableCell.self,
                                kCellHeightKey: CMNotificationEventTableCell.height
                            ])
                        }
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
    // MARK: Events
    // --------------------------------------
    @objc private func refreshData(_ sender: Any) {
        fetchData {
            DispatchQueue.main.async {
                switch self._selectedIndex {
                case 0:
                    self._requestEventList()
                case 1:
                    self._requestUserNoftification()
                case 2:
                    self._requestChatList()
                case 3:
                    self._requestGetProfile()
                default:
                    self.hideHUD()
                }
            }
        }
    }
    
    private func fetchData(completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion()
        }
    }
    
    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        if self.isVCPresented {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func handleReloadMyEvent(_ notification: Notification) {
        _requestGetProfile(isAnotherIndex: _selectedIndex == 1 || _selectedIndex == 0)
        _requestEventList()
        _requestInEventList()
        _requestUserNoftification(true)
    }
    
    @objc func handleReload() {
        _requestGetProfile()
    }
    
    @objc func handlePushReload() {
        _requestGetProfile(isAnotherIndex: _selectedIndex == 1 || _selectedIndex == 0)
        _requestEventList(_selectedIndex == 0)
        _requestInEventList()
        _requestChatList(_selectedIndex == 2)
        _requestUserNoftification(_selectedIndex == 1)
    }
    
    @IBAction private func _handleShareEvent(_ sender: Any) {
        _generateDynamicLinks()
    }
    
    private func  _generateDynamicLinks() {
        guard let controller = parent else { return }
        guard let user = _complimentaryModel?.profile else {
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
// MARK: TableView Delegate
// --------------------------------------

extension ComplementaryProfileVC: CustomTableViewDelegate, UIScrollViewDelegate, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        let threshold: CGFloat = 70
        if yOffset > threshold {
            UIView.animate(withDuration: 0.50, animations: { [weak self] in
                guard let self = self else { return }
                self._visualEffectView.alpha = 1.0
                self._userName.alpha = 1.0
                self._userImg.alpha = 1.0
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.50, animations: { [weak self] in
                guard let self = self else { return }
                self._visualEffectView.alpha = _selectedIndex != 3 ? 1.0 : 0.0
                self._userName.alpha = _selectedIndex != 3 ? 1.0 : 0.0
                self._userImg.alpha = _selectedIndex != 3 ? 1.0 : 0.0
            }, completion: nil)
        }
    }
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? EmptyDataCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [String:Any] else { return }
            cell.setupData(object)
        } else if let cell = cell as? PromoterProfileHeaderCell {
            guard let object = cellDict?[kCellObjectDataKey] as?  PromoterProfileModel else { return }
            cell.setupData(object, isComplemenatary: true)
        } else if let cell = cell as? ProfileScoreTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? ProfileScoreModel else { return }
            cell.setupData(object)
        } else if let cell = cell as? RatingTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? RatingListModel else { return }
            cell.setupRattings(object,id: _complimentaryModel?.profile?.userId ?? kEmptyString, isFromComplementry: true)
        } else if let cell = cell as? ComplementaryRingTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [UserDetailModel] else { return }
            cell.setupData(object)
        } else if let cell = cell as? ComplementaryEventImInTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [PromoterEventsModel], let cellTitle = cellDict?[kCellTagKey] as? String else { return }
            cell.setupData(object, cellTitle: cellTitle)
        } else if let cell = cell as? ComplementaryMyListTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [PromoterEventsModel] else { return }
            cell.setupData(object)
        } else if let cell = cell as? ComplementaryMyEventTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? PromoterEventsModel else { return }
            cell.setupData(object)
        } else if let cell = cell as? UserRequestTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? NotificationModel else { return }
            cell.setupData(object, isPromoter: true)
            cell.updateStatusCallback = { status in
                self._requestUserNoftification(true)
            }
        } else if let cell = cell as? EventRequestTableCell {
            if let object = cellDict?[kCellObjectDataKey] as? PromoterChatListModel {
                cell.setUpChatData(object, isPromoter: false)
            }
        } else if let cell = cell as? CMNotificationEventTableCell {
            if let object = cellDict?[kCellObjectDataKey] as? PromoterEventsModel {
                cell.setupData(object)
            }
        } else if let cell = cell as? EmptyDataCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [String:Any] else { return }
            cell.setupData(object)
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        } else if let cell = cell as? SocialEventFilterCell {
            guard let object = cellDict?[kCellObjectDataKey] as? PromoterProfileModel else { return }
            cell.setupData(object)
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if cell is ComplementaryMyEventTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? PromoterEventsModel else { return}
            let vc = INIT_CONTROLLER_XIB(PromoterEventDetailVC.self)
            vc.eventModel = object
            vc.id = object.id
            vc.isComplementary = true
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        } else if cell is EventRequestTableCell {
            if let object = cellDict?[kCellObjectDataKey] as? PromoterChatListModel {
                let vc = INIT_CONTROLLER_XIB(PromoterEventDetailVC.self)
                vc.id = object.id
                vc.isComplementary = true
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
            }
        } else if cell is CMNotificationEventTableCell {
            if let object = cellDict?[kCellObjectDataKey] as? PromoterEventsModel {
                let vc = INIT_CONTROLLER_XIB(PromoterEventDetailVC.self)
                vc.eventModel = object
                vc.id = object.id
                vc.isComplementary = true
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
            }
        } else  if cell is UserRequestTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? NotificationModel else { return }
            let vc = INIT_CONTROLLER_XIB(PromoterPublicProfileVc.self)
            vc.promoterId = object.typeId
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return _selectedIndex == 0 ? 40 : 0
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = CustomHeaderView(buttonTitles: ["Near me", "Starting Soon"])
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.setUpSelected(filterType)
        headerView.delegate = self
        return headerView
    }
    
}


extension ComplementaryProfileVC: CustomHeaderViewDelegate {
    func notificationType(type: String) {
        _notificationType = type
        _loadData(isLoading: false, selectedIndex: _selectedIndex)
    }
    
    func didSelectTab(at index: Int) {
        _selectedIndex = index
        self._tableView.scrollToTop()
        refreshData(self)
        _loadData(isLoading: false, selectedIndex: index)
    }
}

extension ComplementaryProfileVC: CustomPromoterEventDelegate {
    func didTapButton(at index: Int) {
        filterType = index
        _loadData(isLoading: false, selectedIndex: 0)
    }
}
