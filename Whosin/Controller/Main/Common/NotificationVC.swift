import UIKit

class NotificationVC: ChildViewController {
    
    @IBOutlet weak var _deleteBtn: CustomButton!
    @IBOutlet weak var _promoterView: CustomNotificationHeaderView!
    @IBOutlet weak var _promoterTypeHeaderView: UIView!
    @IBOutlet weak var _headerMainBgView: UIView!
    @IBOutlet private weak var _headerBgView: UIView!
    @IBOutlet private weak var _tableView: CustomNoKeyboardTableView!
    @IBOutlet weak var _visualEffectView: UIVisualEffectView!
    private let kCellIdentifier = String(describing: NotificationTableCell.self)
    private let kCellIdentifierEventRequest = String(describing: EventRequestTableCell.self)
    private let kCellIdentifierRequest = String(describing: PendingRequestTableCell.self)
    private let kCellIdentifierUserRequest = String(describing: UserRequestTableCell.self)
    private let kCellIdentifierPromoterRequest = String(describing: PromoterUserRequestTableCell.self)
    private let kCellNotificationEvent = String(describing: CMNotificationEventTableCell.self)
    private let kCellPlusOneRequest = String(describing: PlusOneRequestTableCell.self)
    private let kCellSubAdminRequest = String(describing: SubAdminRequestTableCell.self)
    private let kEmptyCellIdentifier = String(describing: EmptyDataCell.self)
    private let kCellIdentifierLoading = String(describing: LoadingCell.self)
    private var _notificationData: NotificationListModel?
    private var footerView: LoadingFooterView?
    private var _page : Int = 1
    private var isPaginating = false
    private var _selectedIndex: Int = 0 {
        didSet {
            _promoterTypeHeaderView.isHidden = APPSESSION.userDetail?.isPromoter == true && _selectedIndex == 1 ? false : true
        }
    }
    private var _selectedType: String = "users"
    private var _userNotifications: [NotificationModel] = []
    private var _eventNotification: NotificationListModel?
    private var _promoterUserNotifications: NotificationListModel?
    private var headerView = ChatTableHeaderView()
    private var isLoadingNotification: Bool = false
    private var refreshControl = UIRefreshControl()

    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _page = 1
        setUpheaderViews()
        setupUi()
        _requestNotificationData()
        _requestPendingFollowRequest()
        showHUD()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setUpheaderViews() {
        _promoterTypeHeaderView.isHidden = true
        let headerView = ChatTableHeaderView(frame: _headerBgView.frame.standardized)
        headerView.delegate = self
        if APPSESSION.userDetail?.isPromoter == true {
            headerView.setupTabLabels(["normal".localized(), "promoter".localized()])
            _requestUserNoftification()
            _requestEventNoftification()
        } else  if APPSESSION.userDetail?.isRingMember == true {
            headerView.setupTabLabels(["normal".localized(), "complimentary".localized()])
            _requestSocialUserNoftification()
        } else {
            _headerMainBgView.isHidden = true
        }
        self.headerView = headerView
        _headerBgView.addSubview(self.headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.snp.makeConstraints { make in
            make.edges.equalTo(_headerBgView)
        }
        
        let promoterHeaderView = CustomNotificationHeaderView(frame: _promoterView.frame.standardized)
        promoterHeaderView.isNotification = true
        promoterHeaderView.delegate = self
        promoterHeaderView.setupData(selectedType: _selectedType)
        self._promoterView = promoterHeaderView
        _promoterTypeHeaderView.addSubview(self._promoterView)
        promoterHeaderView.translatesAutoresizingMaskIntoConstraints = false
        self._promoterView.snp.makeConstraints { make in
            make.leading.equalTo(_promoterTypeHeaderView)
            make.trailing.equalTo(_promoterTypeHeaderView)
            make.height.equalTo(40)
        }
        _setupHeader()
    }
    
    override func setupUi() {
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: kEmptyString,
            emptyDataIconImage: UIImage(named: "empty_notification"),
            emptyDataDescription: "no_active_notifications".localized(),
            delegate: self)
        _visualEffectView.alpha = 0.0
        footerView = LoadingFooterView(frame: CGRect(x: 0, y: 0, width: _tableView.bounds.width, height: 44))
        _tableView.tableFooterView = footerView
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        refreshControl.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        _tableView.refreshControl = refreshControl
        NotificationCenter.default.addObserver(self, selector: #selector(handleReloadMyEvent(_:)), name: .reloadMyEventsNotifier, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleReloadMyEvent(_:)), name: .changereloadNotificationUpdateState, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleReloadMyEvent(_:)), name: .reloadUsersNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleShowAlert(_:)), name: .showAlertForUpgradeProfile, object: nil)
        _setupHeader()
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestPendingFollowRequest() {
        
        _tableView.startRefreshing()
        WhosinServices.followRequestList { [weak self]container, error in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
            self.showError(error)
            guard let data = container?.data else { return }
            APPSETTING.pendingRequestList = data
            if !data.isEmpty, data.count > 0 {
                _loadData()
            }
        }
    }
    
    private func _requestNotificationData() {
        _tableView.startRefreshing()
        WhosinServices.notificationList(page: _page, limit: 30) { [weak self] container, error in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
            self.footerView?.stopAnimating()
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            if self.isPaginating {
                self.isPaginating = false
                self._notificationData?.notification.append(objectsIn: data.notification)
                self._notificationData?.user.append(objectsIn: data.user)
                self._notificationData?.category.append(objectsIn: data.category)
                self._notificationData?.offer.append(objectsIn: data.offer)
                self._notificationData?.venue.append(objectsIn: data.venue)
            } else {
                self._notificationData = data
            }
            self._loadData()
        }
    }
    
    private func _requestSocialUserNoftification(_ isReload: Bool = false) {
        isLoadingNotification = true
        _tableView.startRefreshing()
        WhosinServices.complementaryUserNotification { [weak self] container, error in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
            self.showError(error)
            self.isLoadingNotification = false
            guard let data = container?.data else { return}
            self._userNotifications = data.notification.toArrayDetached(ofType: NotificationModel.self)
            if isReload || _selectedIndex == 1 {
                _loadData()
            }
        }
    }
    
    private func _requestUserNoftification(_ isReload: Bool = false) {
        isLoadingNotification = true
        _tableView.startRefreshing()
        WhosinServices.promoterUserNotification() { [weak self] container, error in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
            self.showError(error)
            self.isLoadingNotification = false
            guard let data = container?.data else { return }
            self._promoterUserNotifications = data
            if isReload || _selectedIndex == 1 {
                _loadData()
            }
        }
    }
    
    private func _requestEventNoftification(_ isReload: Bool = false) {
        isLoadingNotification = true
        _tableView.startRefreshing()
        WhosinServices.promoterEventNotification() { [weak self] container, error in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
            self.showError(error)
            self.isLoadingNotification = false
            guard let data = container?.data else { return }
            self._eventNotification = data
            if isReload || _selectedIndex == 1 {
                _loadData()
            }
        }
    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        if APPSESSION.userDetail?.isPromoter == true, _selectedIndex == 1 {
            _deleteBtn.isHidden = true
            if isLoadingNotification {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierLoading,
                    kCellTagKey: kCellIdentifierLoading,
                    kCellObjectDataKey: true,
                    kCellClassKey: LoadingCell.self,
                    kCellHeightKey: LoadingCell.height
                ])
            } else {
                if _selectedType == "users" {
                    if _promoterUserNotifications?.notification.isEmpty == true || _promoterUserNotifications?.notification == nil {
                        cellData.append([
                            kCellIdentifierKey: kEmptyCellIdentifier,
                            kCellTagKey: kEmptyCellIdentifier,
                            kCellObjectDataKey: ["title" : "empty_user_requests".localized(), "icon": "empty_notification"],
                            kCellClassKey: EmptyDataCell.self,
                            kCellHeightKey: EmptyDataCell.height
                        ])
                    } else {
                        _promoterUserNotifications?.notification.forEach { model in
                            cellData.append([
                                kCellIdentifierKey: kCellIdentifierPromoterRequest,
                                kCellTagKey: kCellIdentifierPromoterRequest,
                                kCellObjectDataKey: model,
                                kCellClassKey: PromoterUserRequestTableCell.self,
                                kCellHeightKey: PromoterUserRequestTableCell.height
                            ])
                        }
                    }
                } else {
                    if _eventNotification?.notification.isEmpty == true || _eventNotification?.notification == nil {
                        cellData.append([
                            kCellIdentifierKey: kEmptyCellIdentifier,
                            kCellTagKey: kEmptyCellIdentifier,
                            kCellObjectDataKey: ["title" : "empty_event_requests".localized(), "icon": "empty_notification"],
                            kCellClassKey: EmptyDataCell.self,
                            kCellHeightKey: EmptyDataCell.height
                        ])
                    } else {
                        _eventNotification?.notification.forEach({ model in
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
        }
        else if APPSESSION.userDetail?.isRingMember == true, _selectedIndex == 1 {
            _deleteBtn.isHidden = true
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
        }
        else {
            _deleteBtn.isHidden = _notificationData?.notification.isEmpty == true
            _notificationData?.notification.sort { $0.updatedAt > $1.updatedAt }
            
            if APPSESSION.userDetail?.isProfilePrivate == true {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierRequest,
                    kCellTagKey: kCellIdentifierRequest,
                    kCellObjectDataKey: APPSETTING.pendingRequestList,
                    kCellClassKey: PendingRequestTableCell.self,
                    kCellHeightKey: PendingRequestTableCell.height
                ])
            }
            
            _notificationData?.notification.forEach { notification in
                if notification.type == "ring-request-rejected" || notification.type == "ring-request-accepted" || notification.type == "promoter-request-accepted" || notification.type == "promoter-request-rejected", APPSESSION.userDetail?.isPromoter == false {
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifierRequest,
                        kCellTagKey: kCellIdentifierRequest,
                        kCellObjectDataKey: notification,
                        kCellClassKey: PendingRequestTableCell.self,
                        kCellHeightKey: PendingRequestTableCell.height
                    ])
                } else if notification.type == "add-to-plusone" {
                    cellData.append([
                        kCellIdentifierKey: kCellPlusOneRequest,
                        kCellTagKey: kCellPlusOneRequest,
                        kCellObjectDataKey: notification,
                        kCellClassKey: PlusOneRequestTableCell.self,
                        kCellHeightKey: PlusOneRequestTableCell.height
                    ])
                } else if notification.type == "promoter-subadmin" {
                    cellData.append([
                        kCellIdentifierKey: kCellSubAdminRequest,
                        kCellTagKey: kCellSubAdminRequest,
                        kCellObjectDataKey: notification,
                        kCellClassKey: SubAdminRequestTableCell.self,
                        kCellHeightKey: SubAdminRequestTableCell.height
                    ])
                } else {
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifier,
                        kCellTagKey: kCellIdentifier,
                        kCellObjectDataKey: notification,
                        kCellClassKey: NotificationTableCell.self,
                        kCellHeightKey: NotificationTableCell.height
                    ])
                }
            }
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: NotificationTableCell.self, kCellHeightKey: NotificationTableCell.height],
            [kCellIdentifierKey: kCellIdentifierRequest, kCellNibNameKey: kCellIdentifierRequest, kCellClassKey: PendingRequestTableCell.self, kCellHeightKey: PendingRequestTableCell.height],
            [kCellIdentifierKey: kCellIdentifierLoading, kCellNibNameKey: kCellIdentifierLoading, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height],
            [kCellIdentifierKey: kCellIdentifierEventRequest, kCellNibNameKey: kCellIdentifierEventRequest, kCellClassKey: EventRequestTableCell.self, kCellHeightKey: EventRequestTableCell.height],
            [kCellIdentifierKey: kCellIdentifierUserRequest, kCellNibNameKey: kCellIdentifierUserRequest, kCellClassKey: UserRequestTableCell.self, kCellHeightKey: UserRequestTableCell.height],
            [kCellIdentifierKey: kEmptyCellIdentifier, kCellNibNameKey: kEmptyCellIdentifier, kCellClassKey: EmptyDataCell.self, kCellHeightKey: EmptyDataCell.height],
            [kCellIdentifierKey: kCellNotificationEvent, kCellNibNameKey: kCellNotificationEvent, kCellClassKey: CMNotificationEventTableCell.self, kCellHeightKey: CMNotificationEventTableCell.height],
            [kCellIdentifierKey: kCellIdentifierPromoterRequest, kCellNibNameKey: kCellIdentifierPromoterRequest, kCellClassKey: PromoterUserRequestTableCell.self, kCellHeightKey: PromoterUserRequestTableCell.height],
            [kCellIdentifierKey: kCellPlusOneRequest, kCellNibNameKey: kCellPlusOneRequest, kCellClassKey: PlusOneRequestTableCell.self, kCellHeightKey: PlusOneRequestTableCell.height],
            [kCellIdentifierKey: kCellSubAdminRequest, kCellNibNameKey: kCellSubAdminRequest, kCellClassKey: SubAdminRequestTableCell.self, kCellHeightKey: SubAdminRequestTableCell.height]

        ]
    }
    
    private func _setupHeader() {
        headerView.setupData(_selectedIndex)
        _promoterView.setupData(selectedType: _selectedType)
        if APPSESSION.userDetail?.isPromoter == true, _selectedIndex == 1 {
            _promoterTypeHeaderView.isHidden = false
        }
    }
    
    private func fetchData(completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            completion()
        }
    }
    
    @objc private func refreshData(_ sender: Any) {
        fetchData {
            DispatchQueue.main.async {
                if APPSESSION.userDetail?.isPromoter == true {
                    if self._selectedIndex == 0 {
                        self._requestPendingFollowRequest()
                        self._requestNotificationData()
                    } else {
                        self._requestUserNoftification()
                        self._requestEventNoftification()
                    }
                } else  if APPSESSION.userDetail?.isRingMember == true {
                    if self._selectedIndex == 0 {
                        self._requestPendingFollowRequest()
                        self._requestNotificationData()
                    } else {
                        self._requestSocialUserNoftification()
                    }
                } else {
                    self._requestNotificationData()
                    self._requestPendingFollowRequest()
                }
            }
        }
    }
    
    private func _requestDeleteNotification(_ ids: [String], index: IndexPath) {
        showHUD()
        WhosinServices.notificationDelete(ids: ids) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container else { return}
            self.showToast(data.message)
            self._requestNotificationData()
        }
        
    }
    
    private func _requestDeleteNotification(_ ids: [String]) {
        showHUD()
        WhosinServices.notificationDelete(ids: ids) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container else { return}
            self.showToast(data.message)
            self._requestNotificationData()
        }
        
    }
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    private func _deleteNotificationEvent(id: String, index: IndexPath) {
        confirmAlert(message: "delete_notification_confirmation".localized(),okHandler: { okAction in
            self._requestDeleteNotification([id], index: index)
        }, noHandler:  { action in
        })
    }
    
    
    @objc func handleReloadMyEvent(_ notification: Notification) {
        if APPSESSION.userDetail?.isPromoter == true {
            _requestUserNoftification(true)
            _requestEventNoftification(true)
        } else {
            _requestSocialUserNoftification(true)
        }
    }
    
    @objc func handleShowAlert(_ notification: Notification) {
        let message = notification.userInfo?["type"] as? String ?? "complimentary"
        let vc = INIT_CONTROLLER_XIB(RestartAppPopupVC.self)
        vc._msg = message
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true)
    }
    
    @IBAction func _handleDeleteAllNotifications(_ sender: CustomButton) {
        guard let ids = _notificationData?.notification.map({ $0.id }).map({ $0 }) else { return }
        let idArray = Array(ids)
        confirmAlert(message: "delete_all_notifications_confirmation".localized(),okHandler: { okAction in
            self._requestDeleteNotification(idArray)
        }, noHandler:  { action in
        })
    }
    
    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}


extension NotificationVC: CustomNoKeyboardTableViewDelegate {
        
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, cellDict: [String : Any]?, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let object = cellDict?[kCellObjectDataKey] as? NotificationModel  else { return nil}
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            self._deleteNotificationEvent(id: object.id, index: indexPath)
            completionHandler(true)
        }
        deleteAction.image = UIImage(named: "icon_delete")
        deleteAction.backgroundColor = ColorBrand.brandgradientPink
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.size.height {
            if !isPaginating {
                performPagination()
            }
        }
    }
    
    private func performPagination() {
        if (_notificationData?.notification.count ?? 0) % 30 == 0 {
            isPaginating = true
            _page += 1
            footerView?.startAnimating()
            _requestNotificationData()
        }
    }
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? NotificationTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? NotificationModel  else { return }
            cell.setupData(object, listData: _notificationData)
        } else if let cell = cell as? PendingRequestTableCell {
            if let object = cellDict?[kCellObjectDataKey] as? [UserDetailModel] {
                cell.setupData(object)
            } else if let object = cellDict?[kCellObjectDataKey] as? NotificationModel {
                cell.setupData(object)
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
        } else if let cell = cell as? UserRequestTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? NotificationModel else { return }
            cell.setupData(object, isPromoter: APPSESSION.userDetail?.isRingMember == true)
            cell.updateStatusCallback = { status in
                self._requestUserNoftification(true)
            }
        } else if let cell = cell as? EventRequestTableCell {
            if let object = cellDict?[kCellObjectDataKey] as? NotificationModel {
                cell.setUpData(object, isNotification: true)
            } else if let object = cellDict?[kCellObjectDataKey] as? PromoterChatListModel {
                cell.setUpChatData(object, isPromoter: true)
            }
        } else if let cell = cell as? PromoterUserRequestTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? NotificationModel else { return }
            cell.setupData(object, isPromoter: APPSESSION.userDetail?.isRingMember == true)
            cell.updateStatusCallback = { status in
                self._requestUserNoftification(true)
            }
        }
        else if let cell = cell as? PlusOneRequestTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? NotificationModel else { return }
            cell.setupData(object)
            cell.reloadCallback = {
                self._requestNotificationData()
            }
        }
        else if let cell = cell as? SubAdminRequestTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? NotificationModel else { return }
            cell.setupData(object)
            cell.reloadCallback = {
                self._requestNotificationData()
            }
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? PendingRequestTableCell {
            if let object = cellDict?[kCellObjectDataKey] as? NotificationModel {
                if  object.type == "ring-request-accepted" || object.type == "promoter-request-accepted"  {
                    if APPSESSION.userDetail?.isRingMember != true {
                        let vc = INIT_CONTROLLER_XIB(CompletePromoterProfileVC.self)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                } else if object.type == "ring-request-rejected" || object.type == "promoter-request-rejected" {
                    let vc = INIT_CONTROLLER_XIB(ApplicationRejectVC.self)
                    vc.remainingDays = Utils.remainingDays(from: object.updatedAt) ?? 15
                    vc.isRingType = object.type == "ring-request-rejected"
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else if !APPSETTING.pendingRequestList.isEmpty {
                let vc = INIT_CONTROLLER_XIB(FollowRequestListVC.self)
                navigationController?.pushViewController(vc, animated: true)
            }
        } else  if cell is UserRequestTableCell {
            if APPSESSION.userDetail?.isRingMember == true {
                guard let object = cellDict?[kCellObjectDataKey] as? NotificationModel else { return }
                let vc = INIT_CONTROLLER_XIB(PromoterPublicProfileVc.self)
                vc.promoterId = object.typeId
                navigationController?.pushViewController(vc, animated: true)
            } else {
                guard let object = cellDict?[kCellObjectDataKey] as? NotificationModel else { return }
                let vc = INIT_CONTROLLER_XIB(ComplementaryPublicProfileVC.self)
                vc.complimentryId = object.typeId
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
        } else if let cell = cell as? PromoterUserRequestTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? NotificationModel else { return}
            let vc = INIT_CONTROLLER_XIB(ComplementaryPublicProfileVC.self)
            vc.complimentryId = object.typeId
            navigationController?.pushViewController(vc, animated: true)
        } else {
            guard let object = cellDict?[kCellObjectDataKey] as? NotificationModel else { return }
            if object.type == "venue" {
                let vc = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
                vc.venueId = object.typeId
                self.navigationController?.pushViewController(vc, animated: true)
            } else if object.type == "offer" {
                let vc = INIT_CONTROLLER_XIB(OfferPackageDetailVC.self)
                vc.offerId = object.typeId
                vc.modalPresentationStyle = .overFullScreen
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
            } else if object.type == "category" {
                guard let categoryModel = _notificationData?.category.toArrayDetached(ofType: CategoryDetailModel.self) else { return }
                let vc = INIT_CONTROLLER_XIB(CategoryDetailVC.self)
                vc.categoryDetailModel = categoryModel.first(where: { $0.id == object.typeId })
                self.navigationController?.pushViewController(vc, animated: true)
            } else if object.type == "follows" {
                guard let userDetail = APPSESSION.userDetail else { return}
                if !object.typeId.isEmpty {
                    if object.isPromoter, userDetail.isRingMember {
                        let vc = INIT_CONTROLLER_XIB(PromoterPublicProfileVc.self)
                        vc.promoterId = object.id
                        vc.isFromPersonal = true
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else if object.isRingMember, userDetail.isPromoter {
                        let vc = INIT_CONTROLLER_XIB(ComplementaryPublicProfileVC.self)
                        vc.complimentryId = object.id
                        vc.isFromPersonal = true
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        let vc = INIT_CONTROLLER_XIB(UsersProfileVC.self)
                        vc.contactId = object.typeId
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            } else if object.type == "link" {
                if let url = URL(string: object.typeId) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            } else if object.type == "follow" {
                guard let userDetail = APPSESSION.userDetail else { return }
                if object.typeId != userDetail.id {
                    if object.isPromoter, userDetail.isRingMember {
                        let vc = INIT_CONTROLLER_XIB(PromoterPublicProfileVc.self)
                        vc.promoterId = object.id
                        vc.isFromPersonal = true
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else if object.isRingMember, userDetail.isPromoter {
                        let vc = INIT_CONTROLLER_XIB(ComplementaryPublicProfileVC.self)
                        vc.complimentryId = object.id
                        vc.isFromPersonal = true
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        let vc = INIT_CONTROLLER_XIB(UsersProfileVC.self)
                        vc.contactId = object.typeId
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            } else if object.type == "event" {
                let vc = INIT_CONTROLLER_XIB(EventDetailVC.self)
                vc.eventId = object.typeId
                self.navigationController?.pushViewController(vc, animated: true)
            } else if object.type == "outing" {
                if !object.typeId.isEmpty {
                    let vc = INIT_CONTROLLER_XIB(OutingDetailVC.self)
                    vc.outingId = object.typeId
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else if object.type == "deal" {
                if !object.typeId.isEmpty {
                    let vc = INIT_CONTROLLER_XIB(DealsDetailVC.self)
                    vc.dealId = object.typeId
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else if object.type == "activity" {
                if !object.typeId.isEmpty {
                    let vc = INIT_CONTROLLER_XIB(ActivityInfoVC.self)
                    vc.activityId = object.typeId
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else if object.type == "add-to-ring" {
                if APPSESSION.userDetail?.isPromoter == true { return }
                if APPSESSION.userDetail?.isRingMember != true {
                    let vc = INIT_CONTROLLER_XIB(PromoterApplicationVC.self)
                    vc.isComlementry = true
                    vc.referredById = object.typeId
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else if object.type == "ticket" {
                let vc = INIT_CONTROLLER_XIB(CustomTicketDetailVC.self)
                vc.ticketID = object.typeId
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else if object.type == "ticket-booking" {
                guard let window = APP.window  else { return }
                TabLaunchConfig.walletDefaultPageIndex = 0
                if let navController = window.rootViewController as? UINavigationController,
                   let tabBarController = navController.viewControllers.first as? MainTabBarVC,
                   tabBarController.selectedIndex == 4 {
                    return
                }
                let controller = INIT_CONTROLLER_XIB(MainTabBarVC.self)
                controller.selectedIndex = 4
                let navController = NavigationController(rootViewController: controller)
                navController.setNavigationBarHidden(true, animated: false)
                window.setRootViewController(navController, options: UIWindow.TransitionOptions(direction:.fade, style: .easeInOut))
            } else if object.type == "cancel-booking" {
                guard let window = APP.window  else { return }
                TabLaunchConfig.walletDefaultPageIndex = 1
                if let navController = window.rootViewController as? UINavigationController,
                   let tabBarController = navController.viewControllers.first as? MainTabBarVC,
                   tabBarController.selectedIndex == 4 {
                    return
                }
                let controller = INIT_CONTROLLER_XIB(MainTabBarVC.self)
                controller.selectedIndex = 4
                let navController = NavigationController(rootViewController: controller)
                navController.setNavigationBarHidden(true, animated: false)
                window.setRootViewController(navController, options: UIWindow.TransitionOptions(direction:.fade, style: .easeInOut))
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
            } else if let cell = cell as? PlusOneRequestTableCell {
                let vc = INIT_CONTROLLER_XIB(UsersProfileVC.self)
                vc.contactId = object.userId
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    

}

extension NotificationVC: ChatTableHeaderViewDelegate {
    
    func didSelectTab(at index: Int) {
        _selectedIndex = index
        _setupHeader()
        setupUi()
        _loadData()
    }
    
}

extension NotificationVC: NotificationHeaderViewDelegate {
    func didSelectType(_ type: String) {
        _selectedType = type
        _loadData()
    }
}
