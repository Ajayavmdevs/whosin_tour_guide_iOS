import UIKit
import IQKeyboardManagerSwift

class PromoterProfileVC: ChildViewController {
    
    @IBOutlet weak var _userImg: UIImageView!
    @IBOutlet private weak var _tableView: CustomNoKeyboardTableView!
    @IBOutlet private weak var _promoterName: UILabel!
    @IBOutlet private weak var _visualEffectView: UIVisualEffectView!
    @IBOutlet weak var _tabView: UIView!
    @IBOutlet weak var _searchHeight: NSLayoutConstraint!
    public var _selectedIndex: Int = 0
    private let kCellIdentifierHeader = String(describing: PrivateProfileHeaderCell.self)
    private let kCellIdentifierEventRequest = String(describing: EventRequestTableCell.self)
    private let kCellIdentifierUserRequest = String(describing: PromoterUserRequestTableCell.self)
    private let kCellIdentifierMyRings = String(describing: MyRingsTableViewCell.self)
    private let kCellIdentifierMyVenues = String(describing: MyVenuesTableCell.self)
    private let kCellIdentifierMyEvents = String(describing: MyEventsTableCell.self)
    private let kCellIdentifierMyCircles = String(describing: MyCirclesTableCell.self)
    private let kCellIdentifierReview = String(describing: RatingTableCell.self)
    private let kEmptyCellIdentifier = String(describing: EmptyDataCell.self)
    private let kCellIdentifierDraft = String(describing: SavedInDraftTableCell.self)
    private let kCellIdentifierLoading = String(describing: LoadingCell.self)
    private var _notificationType: String = "users"
    private var _promoterModel: PromoterProfileModel? = APPSESSION.promoterProfile
    private var _myEventsList: [PromoterEventsModel] = []
    private var _eventHistory: [PromoterEventsModel] = []
    private var _page: Int = 1
    private var isPaginating = false
    private var footerView: LoadingFooterView?
    private var _userNotifications: [NotificationModel] = []
    private var _eventNotification: [NotificationModel] = []
    private var _chatList: [PromoterChatListModel] = []
    private var refreshControl = UIRefreshControl()
    private var isLoadingMyEvent: Bool = false
    private var isLoadingEventHistory: Bool = false
    private var isLoadingChat: Bool = false
    private var isLoadingNotification: Bool = false
    private var tabView = CustomPromoterHeaderView()
    var filteredNotifications: [NotificationModel] = []
    private var isSearching: Bool = false
    private var isEventSearching: Bool = false
    private var shouldAllowSearchBarToEndEditing: Bool = true
    private var isApplyFilter: Bool = false
    private var _selectedFilter: String = "All"
    var searchTimer: Timer?
    private var promoterNotificationHeaderView = CustomNotificationHeaderView()
    private var filterType: Int = 0
    @IBOutlet weak var _eventHisSearchBarView: UIView!
    @IBOutlet weak var _eventHisSearchBar: UISearchBar!
    private var _filteredEventHistory: [PromoterEventsModel] = []
    private var _filteredMyEventList: [PromoterEventsModel] = []

    
    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
        DISPATCH_ASYNC_MAIN {
            let headerView = CustomPromoterHeaderView(frame: self._tabView.frame.standardized)
            headerView.setupData(self._selectedIndex, selectedType: self._notificationType)
            headerView.delegate = self
            self.tabView = headerView
            self._tabView.addSubview(self.tabView)
            self.tabView.translatesAutoresizingMaskIntoConstraints = false
            self.tabView.snp.makeConstraints { make in
                make.edges.equalTo(self._tabView)
            }
        }

        if _promoterModel != nil { _loadData() }
        setupUi()
        NotificationCenter.default.addObserver(self, selector: #selector(handleReloadMyEvent(_:)), name: .reloadMyEventsNotifier, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleReloadProfile(_:)), name: .reloadPromoterProfileNotifier, object: nil)
        NotificationCenter.default.addObserver(self, selector:  #selector(handleReloadProfile(_:)), name: kRelaodActivitInfo, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleReloadEventNotification(_:)), name: .reloadEventNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleReloadUserNotification(_:)), name: .reloadUsersNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleReloadEventDraftNotification(_:)), name: .reloadEventDraftNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePushReload), name: .changereloadNotificationUpdateState, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
        IQKeyboardManager.shared.enable = true
    }
    
    override func setupUi() {
        _visualEffectView.alpha = _selectedIndex != 0 ? 1 : 0
        _promoterName.alpha = _selectedIndex != 0 ? 1 : 0
        _userImg.alpha = _selectedIndex != 0 ? 1 : 0
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
        _eventHisSearchBar.searchTextField.backgroundColor = UIColor(white: 1, alpha: 0.08)
        _eventHisSearchBar.searchTextField.layer.cornerRadius = 18
        _eventHisSearchBar.searchTextField.layer.masksToBounds = true
        _eventHisSearchBar.searchTextField.textColor = .white

        _tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        footerView = LoadingFooterView(frame: CGRect(x: 0, y: 0, width: _tableView.bounds.width, height: 44))
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        refreshControl.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        _tableView.refreshControl = refreshControl
        _tableView.tableFooterView = footerView
        PromoterApplicationVC.reloadOnBack = { self._requestGetProfile() }
        _tableView.proxyDelegate = self
        _requestGetProfile()
        _requestMyEvents()
        _requestEventHistory()
        _requestUserNoftification()
        _requestEventNoftification()
        _requestChatList()
    }
    
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierHeader, kCellNibNameKey: kCellIdentifierHeader, kCellClassKey: PrivateProfileHeaderCell.self, kCellHeightKey: PrivateProfileHeaderCell.height],
            [kCellIdentifierKey: kCellIdentifierEventRequest, kCellNibNameKey: kCellIdentifierEventRequest, kCellClassKey: EventRequestTableCell.self, kCellHeightKey: EventRequestTableCell.height],
            [kCellIdentifierKey: kCellIdentifierUserRequest, kCellNibNameKey: kCellIdentifierUserRequest, kCellClassKey: PromoterUserRequestTableCell.self, kCellHeightKey: PromoterUserRequestTableCell.height],
            [kCellIdentifierKey: kCellIdentifierMyRings, kCellNibNameKey: kCellIdentifierMyRings, kCellClassKey: MyRingsTableViewCell.self, kCellHeightKey: MyRingsTableViewCell.height],
            [kCellIdentifierKey: kCellIdentifierMyVenues, kCellNibNameKey: kCellIdentifierMyVenues, kCellClassKey: MyVenuesTableCell.self, kCellHeightKey: MyVenuesTableCell.height],
            [kCellIdentifierKey: kCellIdentifierMyEvents, kCellNibNameKey: kCellIdentifierMyEvents, kCellClassKey: MyEventsTableCell.self, kCellHeightKey: MyEventsTableCell.height],
            [kCellIdentifierKey: kCellIdentifierMyCircles, kCellNibNameKey: kCellIdentifierMyCircles, kCellClassKey: MyCirclesTableCell.self, kCellHeightKey: MyCirclesTableCell.height],
            [kCellIdentifierKey: kCellIdentifierReview, kCellNibNameKey: kCellIdentifierReview, kCellClassKey: RatingTableCell.self, kCellHeightKey: RatingTableCell.height],
            [kCellIdentifierKey: kEmptyCellIdentifier, kCellNibNameKey: kEmptyCellIdentifier, kCellClassKey: EmptyDataCell.self, kCellHeightKey: EmptyDataCell.height],
            [kCellIdentifierKey: kCellIdentifierDraft, kCellNibNameKey: kCellIdentifierDraft, kCellClassKey: SavedInDraftTableCell.self, kCellHeightKey: SavedInDraftTableCell.height],
            [kCellIdentifierKey: kCellIdentifierLoading, kCellNibNameKey: kCellIdentifierLoading, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height],

        ]
    }
    
    private func _loadData(isLoading: Bool = false,selectedIndex: Int = 0) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        _promoterName.text = _promoterModel?.profile?.fullName
        _userImg.loadWebImage(APPSESSION.userDetail?.image  ?? kEmptyString, name: _promoterModel?.profile?.fullName ?? kEmptyString)
        
        switch selectedIndex {
        case 0:
            _eventHisSearchBarView.isHidden = true
            _searchHeight.constant = 0
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
        case 1:
            _eventHisSearchBarView.isHidden = false
            _searchHeight.constant = 60
            _eventHisSearchBar.delegate = self
            _eventHisSearchBar.placeholder = "find my event"
            
            if isEventSearching {
                if _filteredMyEventList.isEmpty {
                    cellData.append([
                        kCellIdentifierKey: kEmptyCellIdentifier,
                        kCellTagKey: kEmptyCellIdentifier,
                        kCellObjectDataKey: ["title" : "empty_event_list".localized(), "icon": "empty_event"],
                        kCellClassKey: EmptyDataCell.self,
                        kCellHeightKey: EmptyDataCell.height
                    ])
                } else {
                    _filteredMyEventList.forEach { model in
                        cellData.append([
                            kCellIdentifierKey: kCellIdentifierMyEvents,
                            kCellTagKey: kEmptyCellIdentifier,
                            kCellObjectDataKey: model,
                            kCellClassKey: MyEventsTableCell.self,
                            kCellHeightKey: MyEventsTableCell.height
                        ])
                    }
                }
            } else {
                if isLoadingMyEvent {
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifierLoading,
                        kCellTagKey: kCellIdentifierLoading,
                        kCellObjectDataKey: true,
                        kCellClassKey: LoadingCell.self,
                        kCellHeightKey: LoadingCell.height
                    ])
                } else {
                    if _myEventsList.isEmpty {
                        cellData.append([
                            kCellIdentifierKey: kEmptyCellIdentifier,
                            kCellTagKey: kEmptyCellIdentifier,
                            kCellObjectDataKey: ["title" : "empty_event_list".localized(), "icon": "empty_event"],
                            kCellClassKey: EmptyDataCell.self,
                            kCellHeightKey: EmptyDataCell.height
                        ])
                    } else {
                        if filterType == 1 {
                            let sortedEvents = _myEventsList.sorted {
                                guard let firstDate = $0.startingSoon, let secondDate = $1.startingSoon else {
                                    return false
                                }
                                return firstDate < secondDate
                            }
                            sortedEvents.forEach({ model in
                                if model.status != "cancelled" && model.status != "completed" {
                                    cellData.append([
                                        kCellIdentifierKey: kCellIdentifierMyEvents,
                                        kCellTagKey: kCellIdentifierMyEvents,
                                        kCellObjectDataKey: model,
                                        kCellClassKey: MyEventsTableCell.self,
                                        kCellHeightKey: MyEventsTableCell.height
                                    ])
                                }
                            })
                        }  else {
                            _myEventsList.forEach({ model in
                                if model.status != "cancelled" && model.status != "completed" {
                                    cellData.append([
                                        kCellIdentifierKey: kCellIdentifierMyEvents,
                                        kCellTagKey: kCellIdentifierMyEvents,
                                        kCellObjectDataKey: model,
                                        kCellClassKey: MyEventsTableCell.self,
                                        kCellHeightKey: MyEventsTableCell.height
                                    ])
                                }
                            })
                        }
                    }
                }
            }
        case 2:
            _eventHisSearchBarView.isHidden = false
            _searchHeight.constant = 60
            _eventHisSearchBar.delegate = self
            _eventHisSearchBar.placeholder = "find event"
            if isEventSearching {
                if _filteredEventHistory.isEmpty {
                    cellData.append([
                        kCellIdentifierKey: kEmptyCellIdentifier,
                        kCellTagKey: "history",
                        kCellObjectDataKey: ["title" : "empty_event_history_vc".localized(), "icon": "empty_history"],
                        kCellClassKey: EmptyDataCell.self,
                        kCellHeightKey: EmptyDataCell.height
                    ])
                } else {
                    let sortedEventHistory = _filteredEventHistory.sorted {
                        guard let firstDate = $0.lastExpiredEvents, let secondDate = $1.lastExpiredEvents else {
                            return false
                        }
                        return firstDate > secondDate
                    }
                    sortedEventHistory.forEach({ model in
                        if model.status == "cancelled" || model.status == "completed" {
                            cellData.append([
                                kCellIdentifierKey: kCellIdentifierMyEvents,
                                kCellTagKey: "history",
                                kCellObjectDataKey: model,
                                kCellClassKey: MyEventsTableCell.self,
                                kCellHeightKey: MyEventsTableCell.height
                            ])
                        }
                    })
                }
            } else {
                if isLoadingEventHistory {
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifierLoading,
                        kCellTagKey: kCellIdentifierLoading,
                        kCellObjectDataKey: true,
                        kCellClassKey: LoadingCell.self,
                        kCellHeightKey: LoadingCell.height
                    ])
                } else {
                    if _eventHistory.isEmpty {
                        cellData.append([
                            kCellIdentifierKey: kEmptyCellIdentifier,
                            kCellTagKey: "history",
                            kCellObjectDataKey: ["title" : "empty_event_history_vc".localized(), "icon": "empty_history"],
                            kCellClassKey: EmptyDataCell.self,
                            kCellHeightKey: EmptyDataCell.height
                        ])
                    } else {
                        let sortedEventHistory = _eventHistory.sorted {
                            guard let firstDate = $0.lastExpiredEvents, let secondDate = $1.lastExpiredEvents else {
                                return false
                            }
                            return firstDate > secondDate
                        }
                        sortedEventHistory.forEach({ model in
                            if model.status == "cancelled" || model.status == "completed" {
                                cellData.append([
                                    kCellIdentifierKey: kCellIdentifierMyEvents,
                                    kCellTagKey: "history",
                                    kCellObjectDataKey: model,
                                    kCellClassKey: MyEventsTableCell.self,
                                    kCellHeightKey: MyEventsTableCell.height
                                ])
                            }
                        })
                    }
                }
            }
        case 3:
            _eventHisSearchBarView.isHidden = true
            _searchHeight.constant = 0
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
                        kCellObjectDataKey: ["title" : "chat_list_looking_a_bit_empty".localized(), "icon": "empty_chat"],
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
        case 4:
            _eventHisSearchBarView.isHidden = true
            _searchHeight.constant = 0
            if isLoadingNotification {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierLoading,
                    kCellTagKey: kCellIdentifierLoading,
                    kCellObjectDataKey: true,
                    kCellClassKey: LoadingCell.self,
                    kCellHeightKey: LoadingCell.height
                ])
            } else {
                if _notificationType == "users" {
                    if isSearching {
                        if filteredNotifications.isEmpty == true || filteredNotifications.count == 0 {
                            cellData.append([
                                kCellIdentifierKey: kEmptyCellIdentifier,
                                kCellTagKey: kEmptyCellIdentifier,
                                kCellObjectDataKey: ["title" : "empty_user_requests".localized(), "icon": "empty_notification"],
                                kCellClassKey: EmptyDataCell.self,
                                kCellHeightKey: EmptyDataCell.height
                            ])
                        } else {
                            filteredNotifications.forEach { model in
                                cellData.append([
                                    kCellIdentifierKey: kCellIdentifierUserRequest,
                                    kCellTagKey: kCellIdentifierUserRequest,
                                    kCellObjectDataKey: model,
                                    kCellClassKey: PromoterUserRequestTableCell.self,
                                    kCellHeightKey: PromoterUserRequestTableCell.height
                                ])
                            }
                        }
                    } else {
                        if _userNotifications.isEmpty == true || _userNotifications == nil {
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
                                    kCellClassKey: PromoterUserRequestTableCell.self,
                                    kCellHeightKey: PromoterUserRequestTableCell.height
                                ])
                            }
                        }
                    }
                } else {
                    if _eventNotification.isEmpty == true || _eventNotification == nil {
                        cellData.append([
                            kCellIdentifierKey: kEmptyCellIdentifier,
                            kCellTagKey: kEmptyCellIdentifier,
                            kCellObjectDataKey: ["title" : "empty_event_requests".localized(), "icon": "empty_notification"],
                            kCellClassKey: EmptyDataCell.self,
                            kCellHeightKey: EmptyDataCell.height
                        ])
                    } else {
                        _eventNotification.forEach({ model in
                            if model.event?.status != "cancelled" && model.event?.status != "completed" {
                                cellData.append([
                                    kCellIdentifierKey: kCellIdentifierEventRequest,
                                    kCellTagKey: kCellIdentifierEventRequest,
                                    kCellObjectDataKey: model,
                                    kCellClassKey: EventRequestTableCell.self,
                                    kCellHeightKey: EventRequestTableCell.height
                                ])
                            }
                        })
                    }
                }
            }
        default:
            _eventHisSearchBarView.isHidden = true
            break
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
            self._loadData(selectedIndex: _selectedIndex)
        }
    }
    
    private func _requestMyEvents(_ isLoadData: Bool = false) {
        isLoadingMyEvent = !isLoadData
        WhosinServices.getMyEventsList(page: _page) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            self.refreshControl.endRefreshing()
            self.isLoadingMyEvent = false
            guard let data = container?.data else { return }
            self.isPaginating = data.isEmpty
            self.footerView?.stopAnimating()
            if self._page == 1 {
                self._myEventsList = data
            } else {
                self._myEventsList.append(contentsOf: data)
            }
            if isLoadData || self._selectedIndex == 1 {
                self._loadData(selectedIndex: _selectedIndex)
            }
        }
    }
    
    private func _requestEventHistory(_ isLoadData: Bool = false) {
        isLoadingEventHistory = !isLoadData
        WhosinServices.getEventsHistory(page: _page) { [weak self] container, error in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
            self.hideHUD(error: error)
            self.isLoadingEventHistory = false
            guard let data = container?.data else { return }
            self.isPaginating = data.isEmpty
            self.footerView?.stopAnimating()
            if self._page == 1 {
                self._eventHistory = data
            } else {
                self._eventHistory.append(contentsOf: data)
            }
            if isLoadData || _selectedIndex == 2 {
                self._loadData(selectedIndex: _selectedIndex)
            }
        }
    }
    
    private func _requestUserNoftification(_ isReload: Bool = false) {
        isLoadingNotification = !isReload
        WhosinServices.promoterUserNotification(page: _page) { [weak self] container, error in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
            self.hideHUD(error: error)
            self.isLoadingNotification = false
            guard let data = container?.data else { return }
            self.isPaginating = data.notification.isEmpty
            self.footerView?.stopAnimating()
            if self._page == 1 {
                self._userNotifications = data.notification.toArrayDetached(ofType: NotificationModel.self)
            } else {
                self._userNotifications.append(contentsOf: data.notification)
                self.refreshControl.endRefreshing()
            }
            
            if isReload || self._selectedIndex == 4 {
                _loadData(selectedIndex: _selectedIndex)
            }
        }
    }
    
    private func _requestEventNoftification(_ isReload: Bool = false) {
        isLoadingNotification = !isReload
        WhosinServices.promoterEventNotification(page: _page) { [weak self] container, error in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
            self.hideHUD(error: error)
            self.isLoadingNotification = false
            guard let data = container?.data else { return }
            self.isPaginating = data.notification.isEmpty
            self.footerView?.stopAnimating()
            if self._page == 1 {
                self._eventNotification = data.notification.toArrayDetached(ofType: NotificationModel.self)
            } else {
                self._eventNotification.append(contentsOf: data.notification)
                self.refreshControl.endRefreshing()
            }
            if isReload || _selectedIndex == 4 {
                _loadData(selectedIndex: _selectedIndex)
            }
        }
    }
    
    private func _requestChatList(_ isReload: Bool = false) {
        isLoadingChat = !isReload
        WhosinServices.chatList() { [weak self] container, error in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
            self.hideHUD(error: error)
            self.isLoadingChat = false
            guard let data = container?.data else { return }
            self._chatList = data
            if isReload || _selectedIndex == 3 {
                _loadData(selectedIndex: _selectedIndex)
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
                switch self._selectedIndex {
                case 0:
                    self._requestGetProfile()
                case 1:
                    self._page = 1
                    self._requestMyEvents(true)
                case 2:
                    self._page = 1
                    self._requestEventHistory(true)
                case 3:
                    self._requestChatList(true)
                case 4:
                    self._page = 1
                    self._notificationType == "users" ? self._requestUserNoftification(true) : self._requestEventNoftification(true)
                default:
                    print("Somthing wrong....")
                }
            }
        }
    }
    
    @objc func handleReloadMyEvent(_ notification: Notification) {
        self._page = 1
        _requestMyEvents(true)
        _requestEventHistory()
    }
    
    @objc func handleReloadProfile(_ notification: Notification) {
        _requestGetProfile()
    }
    
    @objc func handleReloadEventNotification(_ notification: Notification) {
        if _selectedIndex == 3 {
            _requestEventNoftification()
            _requestChatList(true)
        } else {
            _requestEventNoftification(true)
            _requestChatList()
        }
    }
    
    @objc func handleReloadUserNotification(_ notification: Notification) {
        _requestUserNoftification(true)
    }
    
    @objc func handleReloadEventDraftNotification(_ notification: Notification) {
        _loadData(selectedIndex: _selectedIndex)
    }
    
    @objc func handlePushReload() {
       _requestGetProfile()
        _requestChatList(_selectedIndex == 3)
        _requestMyEvents(_selectedIndex == 1)
        _requestEventNoftification(_selectedIndex == 4)
    }
    
    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 0
        }

        if self.isBeingPresented {
            self.dismiss(animated: true, completion: nil)
        } else if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
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

extension PromoterProfileVC: CustomNoKeyboardTableViewDelegate, UIScrollViewDelegate, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        let threshold: CGFloat = 100
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
                self._visualEffectView.alpha = self._selectedIndex != 0 ? 1.0 : 0.0
                self._promoterName.alpha = self._selectedIndex != 0 ? 1.0 : 0.0
                self._userImg.alpha = self._selectedIndex != 0 ? 1.0 : 0.0
            }, completion: nil)
        }
        let scrollViewContentHeight = scrollView.contentSize.height
        let scrollOffsetThreshold = scrollViewContentHeight - scrollView.bounds.height * 0.8
        if scrollView.contentOffset.y > scrollOffsetThreshold && !isPaginating {
            if _selectedIndex == 1 || _selectedIndex == 2 || _selectedIndex == 4 {
                performPagination()
            }
        }
        
    }
    
    private func performPagination() {
        guard !isPaginating else { return }
        if _selectedIndex == 1 {
            guard _myEventsList.count % 20 == 0 else { return }
            isPaginating = true
            _page += 1
            footerView?.startAnimating()
            _requestMyEvents(true)
            _selectedIndex = 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.isPaginating = false
            }
        } else if _selectedIndex == 2 {
            guard _eventHistory.count % 20 == 0 else { return }
            isPaginating = true
            _page += 1
            footerView?.startAnimating()
            _requestEventHistory(true)
            _selectedIndex = 2
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.isPaginating = false
            }
        } else if _selectedIndex == 4 {
            if _notificationType == "users" {
                let count = _userNotifications.count
                guard count % 20 == 0 else { return }
                isPaginating = true
                _page += 1
                footerView?.startAnimating()
                _requestUserNoftification(true)
                _selectedIndex = 4
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    self?.isPaginating = false
                }
            } else {
                let count = _eventNotification.count
                guard count % 20 == 0 else { return }
                isPaginating = true
                _page += 1
                footerView?.startAnimating()
                _requestEventNoftification(true)
                _selectedIndex = 4
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    self?.isPaginating = false
                }
            }
        }
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
        } else if let cell = cell as? MyEventsTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? PromoterEventsModel, let type = cellDict?[kCellTagKey] as? String else { return}
            if type == "history" {
                cell.setupHistoryData(object)
                cell.callback = {
                    self._requestEventHistory(true)
                }
            } else {
                cell.setupData(object)
            }
        } else  if let cell = cell as? MyCirclesTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [UserDetailModel] else { return}
            cell.setupData(object)
        } else if let cell = cell as? RatingTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? RatingListModel else { return }
            cell.setupRattings(object,id: _promoterModel?.profile?.userId ?? kEmptyString ,isFromPromoter: true)
        } else if let cell = cell as? EventRequestTableCell {
            if let object = cellDict?[kCellObjectDataKey] as? NotificationModel {
                cell.setUpData(object, isNotification: true)
            } else if let object = cellDict?[kCellObjectDataKey] as? PromoterChatListModel {
                cell.setUpChatData(object, isPromoter: true)
            }
        } else if let cell = cell as? PromoterUserRequestTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? NotificationModel else { return }
            cell.setupData(object)
            cell.updateStatusCallback = { status in
                self._requestUserNoftification(true)
                self._requestGetProfile()
            }
        } else if let cell = cell as? SavedInDraftTableCell {
            cell.setup()
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? MyEventsTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? PromoterEventsModel else { return}
            let vc = INIT_CONTROLLER_XIB(PromoterEventDetailVC.self)
            vc.eventModel = object
            vc.id = object.id
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        } else if let cell = cell as? PromoterUserRequestTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? NotificationModel else { return}
            let vc = INIT_CONTROLLER_XIB(ComplementaryPublicProfileVC.self)
            vc.complimentryId = object.typeId
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)

        }
        if let cell = cell as? EventRequestTableCell {
            if let object = cellDict?[kCellObjectDataKey] as? NotificationModel {
                let vc = INIT_CONTROLLER_XIB(PromoterEventDetailVC.self)
                vc.id = object.event?.id ?? ""
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
            } else if let object = cellDict?[kCellObjectDataKey] as? PromoterChatListModel {
                let vc = INIT_CONTROLLER_XIB(PromoterEventDetailVC.self)
                vc.id = object.id
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if _selectedIndex == 4 {
            return section == 0 ? _notificationType == "users" ? 100 : 40 : 0
        } else if _selectedIndex == 1 {
            return 40
        } else {
            isApplyFilter = false
            isSearching = false
            promoterNotificationHeaderView.removeFromSuperview()
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if _selectedIndex == 1 {
            let headerView = CustomHeaderView(buttonTitles: ["Last Added", "Starting Soon"])
            headerView.translatesAutoresizingMaskIntoConstraints = false
            headerView.setUpSelected(filterType)
            headerView.delegate = self
            return headerView

        } else {
            promoterNotificationHeaderView = CustomNotificationHeaderView(frame: CGRect(x: 0, y: 0, width: _tableView.bounds.width, height:  _notificationType == "users" ? 100 : 40))
            promoterNotificationHeaderView.setupData(selectedType: _notificationType, filter: isApplyFilter)
            promoterNotificationHeaderView.delegate = self
            promoterNotificationHeaderView.searchBar.delegate = self
            promoterNotificationHeaderView.filterBtn.addTarget(self, action: #selector(handleFilterOption), for: .touchUpInside)
            return promoterNotificationHeaderView
        }
    }
    
    @objc func handleFilterOption() {
        let actionSheet = UIAlertController(title: "filter".localized(), message: nil, preferredStyle: .actionSheet)
        let allAction = UIAlertAction(title: "all".localized(), style: .default) { _ in
            self.applyFilter("All")
        }
        let acceptedAction = UIAlertAction(title: "accepted".localized(), style: .default) { _ in
            self.applyFilter("Accepted")
        }
        let rejectedAction = UIAlertAction(title: "rejected".localized(), style: .default) { _ in
            self.applyFilter("Rejected")
        }
        let pendingAction = UIAlertAction(title: "pending".localized(), style: .default) { _ in
            self.applyFilter("Pending")
        }
        let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil)
        actionSheet.addAction(allAction)
        actionSheet.addAction(acceptedAction)
        actionSheet.addAction(rejectedAction)
        actionSheet.addAction(pendingAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }

    func applyFilter(_ option: String) {
        _selectedFilter = option
        switch option {
        case "All":
            isApplyFilter = false
            isSearching = false
            _loadData(selectedIndex: _selectedIndex)
            
        default:
            filteredNotifications = _userNotifications
                .filter { notification in
                    notification.requestStatus.lowercased() == option.lowercased()
                }
            isLoadingNotification = false
            isSearching = true
            isApplyFilter = true
            _loadData(isLoading: false, selectedIndex: self._selectedIndex)
//            _tableView.reload()
        }
    }

}


extension PromoterProfileVC: CustomHeaderViewDelegate {
    
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

extension PromoterProfileVC: CustomPromoterEventDelegate {
    func didTapButton(at index: Int) {
        filterType = index
        _loadData(isLoading: false, selectedIndex: 1)
    }
}



extension PromoterProfileVC: NotificationHeaderViewDelegate {
    func didSelectType(_ type: String) {
        _notificationType = type
        _loadData(isLoading: false, selectedIndex: _selectedIndex)
    }
}

extension PromoterProfileVC: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        if isSearching {
            isSearching = false
            isLoadingNotification = false
            _loadData(isLoading: false, selectedIndex: self._selectedIndex)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if _eventHisSearchBarView.isHidden == false {
            if _selectedIndex == 1 {
                if !searchText.isEmpty {
                    isEventSearching = true
                    _filteredMyEventList = _myEventsList.filter { model in
                        return (model.venueType == "venue" ? model.venue?.name : model.customVenue?.name)?.localizedCaseInsensitiveContains(searchText) ?? false
                    }
                    _loadData(selectedIndex: _selectedIndex)
                } else {
                    isEventSearching = false
                    _loadData(selectedIndex: _selectedIndex)
                }

            } else if _selectedIndex == 2 {
                if !searchText.isEmpty {
                    isEventSearching = true
                    _filteredEventHistory = _eventHistory.filter { model in
                        return (model.venueType == "venue" ? model.venue?.name : model.customVenue?.name)?.localizedCaseInsensitiveContains(searchText) ?? false
                    }
                    _loadData(selectedIndex: _selectedIndex)
                } else {
                    isEventSearching = false
                    _loadData(selectedIndex: _selectedIndex)
                }
            }
        } else {
            searchTimer?.invalidate()
            if !searchText.isEmpty {
                isSearching = true
                isLoadingNotification = true
                _loadData(isLoading: true, selectedIndex: _selectedIndex)
                searchTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(performSearchWithTimer), userInfo: searchText, repeats: false)
            } else {
                isSearching = false
                isLoadingNotification = false
                if _selectedFilter != "All" {
                    filteredNotifications = _userNotifications
                        .filter { notification in
                            notification.requestStatus.lowercased() == _selectedFilter.lowercased()
                        }
                }
    //            isSearching = true
                isApplyFilter = true
                _loadData(isLoading: false, selectedIndex: self._selectedIndex)
            }
        }
    }
    
    @objc private func performSearchWithTimer(timer: Timer) {
        guard let searchText = timer.userInfo as? String else { return }
        performSearch(with: searchText)
    }

    func performSearch(with searchText: String) {
        if searchText.isEmpty {
            isLoadingNotification = false
            if _selectedFilter != "All" {
                filteredNotifications = _userNotifications
                    .filter { notification in
                        notification.requestStatus.lowercased() == _selectedFilter.lowercased()
                    }
                isSearching = true
                isApplyFilter = true
            }
            _loadData(isLoading: false, selectedIndex: self._selectedIndex)
        } else {
            filterResults(for: searchText)
        }
    }
    
    private func filterResults(for query: String) {
        filteredNotifications = _userNotifications
            .filter { notification in
                let titleMatches = notification.title.lowercased().contains(query.lowercased())
                
                if _selectedFilter != "All" {
                    return titleMatches && notification.requestStatus.lowercased() == _selectedFilter.lowercased()
                } else {
                    return titleMatches
                }
            }
        isLoadingNotification = false
        isSearching = true
        _loadData(isLoading: false, selectedIndex: self._selectedIndex)
    }

}
