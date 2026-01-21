import UIKit

class SeeAllUsersBottomSheet: PanBaseViewController {
    
    @IBOutlet weak var _venueImg: UIImageView!
    @IBOutlet weak var _venueName: CustomLabel!
    @IBOutlet weak var _venueTime: CustomLabel!
    @IBOutlet private weak var _tableView: CustomTableView!
    @IBOutlet weak var _availableSeats: CustomLabel!
    private let kCellIdentifier = String(describing: UserRequestTableCell.self)
    private let kCellIdentifierInvite = String(describing: InvitedUserRequestTableCell.self)
    private let kLoadingCell = String(describing: LoadingCell.self)
    public var notificationModel: NotificationModel?
    public var chatListModel: PromoterChatListModel?
    public var openProfile: ((_ id: String, _ isRingMember: Bool)-> Void)?
    public var openChat: ((_ model: ChatModel)-> Void)?
    public var event: PromoterEventsModel?
    public var userType: String = "invited"
    public var isFromEvent: Bool = false
    private var isEventFull: Bool = false
    private var _eventModel: PromoterEventsModel?
    private var _invitedUsers: [InvitedUserModel] = []
    private var _inMembers: [InvitedUserModel] = []
    private var _interestedMembers: [InvitedUserModel] = []
    private var _inviteCancelList: [InvitedUserModel] = []
    private var _plusOneMembers: [UserDetailModel] = []
    private var _page : Int = 1
    private var isPaginating = false
    private var footerView: LoadingFooterView?
    @IBOutlet weak var _searchBar: UISearchBar!
    private var filteredUserListModel: [InvitedUserModel] = []
    private var filteredNotificationListModel: [NotificationModel] = []
    private var isSearching = false
    public static var allUsersList: [UserDetailModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        _searchBar.delegate = self
    }
    
    private func setupUI() {
        _tableView.setup(
            cellPrototypes: _prototypes,
            hasHeaderSection: true,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            emptyDataText: kEmptyString,
            emptyDataIconImage: UIImage(named: "empty_following"),
            emptyDataDescription: "There is no users available",
            delegate: self)
        _tableView.proxyDelegate = self
        footerView = LoadingFooterView(frame: CGRect(x: 0, y: 0, width: _tableView.bounds.width, height: 44))
        _tableView.tableFooterView = footerView
        _searchBar.placeholder = "find_users".localized()
        _searchBar.searchTextField.backgroundColor = UIColor(white: 1, alpha: 0.08)
        _searchBar.searchTextField.layer.cornerRadius = 18
        _searchBar.searchTextField.layer.masksToBounds = true
        _searchBar.searchTextField.textColor = .white

        if isFromEvent {
            guard let event = event else {
                dismissOrBack()
                return
            }
            _venueImg.loadWebImage(event.venueType == "venue" ? event.venue?.slogo ?? kEmtpyJsonString : event.customVenue?.image ?? kEmptyString, name: event.venueType == "venue" ? event.venue?.name ?? kEmptyString : event.customVenue?.name ?? kEmptyString)
            _venueName.text = event.venueType == "venue" ? event.venue?.name : event.customVenue?.name
            _venueTime.text = "\(Utils.dateToString(Utils.stringToDate(event.date, format: kFormatDate), format: kFormatEventDate))  |  \(event.startTime) - \(event.endTime)"
            _availableSeats.text = "\(event.maxInvitee) " + "seats".localized()
            isEventFull = event.isEventFull
            _loadData(true)
            _requestUserInviteList()
        } else {
            if notificationModel == nil {
                _venueImg.loadWebImage(chatListModel?.venueImage ?? kEmptyString, name: chatListModel?.venueName ?? kEmptyString)
                _venueName.text = chatListModel?.venueName
                _venueTime.text = "\(Utils.dateToString(Utils.stringToDate(chatListModel?.date ?? kEmptyString, format: kFormatDate), format: kFormatEventDate))  |  \(chatListModel?.startTime  ?? kEmptyString) - \(chatListModel?.endTime  ?? kEmptyString)"
                _availableSeats.text = "\(chatListModel?.maxInvitee ?? 0) " + "seats".localized()
                _loadData()

            } else {
                _venueImg.loadWebImage((notificationModel?.event?.venueType == "venue" ? notificationModel?.event?.venue?.slogo ?? kEmtpyJsonString : notificationModel?.event?.customVenue?.image) ?? kEmptyString, name: notificationModel?.event?.venueType == "venue" ? notificationModel?.event?.venue?.name ?? kEmptyString : notificationModel?.event?.customVenue?.name ?? kEmptyString)
                _venueName.text = notificationModel?.event?.venueType == "venue" ? notificationModel?.event?.venue?.name : notificationModel?.event?.customVenue?.name
                _venueTime.text = "\(Utils.dateToString(Utils.stringToDate(notificationModel?.event?.date ?? kEmptyString, format: kFormatDate), format: kFormatEventDate))  |  \(notificationModel?.event?.startTime  ?? kEmptyString) - \(notificationModel?.event?.endTime  ?? kEmptyString)"
                _availableSeats.text = "\(notificationModel?.event?.maxInvitee ?? 0) " + "seats".localized()
                _loadData(true)
                _requestUserInviteList()
            }
        }
    }
    
    private func _requestUserInviteList() {
        WhosinServices.promoterEventInviteListNew(eventId: event?.id ?? kEmptyString, page: _page) { [weak self] container, error in
            guard let self = self else { return }
            self.footerView?.stopAnimating()
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            if self.isPaginating {
                self.isPaginating = false
                SeeAllUsersBottomSheet.allUsersList.append(contentsOf:data.usersList.toArrayDetached(ofType: UserDetailModel.self))
                self._invitedUsers.append(contentsOf: data.invitedUsers.toArrayDetached(ofType: InvitedUserModel.self))
                self._inMembers.append(contentsOf: data.inMembers.toArrayDetached(ofType: InvitedUserModel.self))
                self._interestedMembers.append(contentsOf: data.interestedMembers.toArrayDetached(ofType: InvitedUserModel.self))
                self._inviteCancelList.append(contentsOf: data.inviteCancelList.toArrayDetached(ofType: InvitedUserModel.self))
//                self._plusOneMembers.append(contentsOf: data.plusOneInvites.toArrayDetached(ofType: UserDetailModel.self))
            } else {
                SeeAllUsersBottomSheet.allUsersList = data.usersList.toArrayDetached(ofType: UserDetailModel.self)
                self._invitedUsers = data.invitedUsers.toArrayDetached(ofType: InvitedUserModel.self)
                self._inMembers = data.inMembers.toArrayDetached(ofType: InvitedUserModel.self)
                self._interestedMembers = data.interestedMembers.toArrayDetached(ofType: InvitedUserModel.self)
                self._inviteCancelList = data.inviteCancelList.toArrayDetached(ofType: InvitedUserModel.self)
//                self._plusOneMembers = data.plusOneInvites.toArrayDetached(ofType: UserDetailModel.self)
            }
            self._loadData()
        }
    }
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: UserRequestTableCell.self, kCellHeightKey: UserRequestTableCell.height],
                 [kCellIdentifierKey: kLoadingCell, kCellNibNameKey: kLoadingCell, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height],
                 [kCellIdentifierKey: kCellIdentifierInvite, kCellNibNameKey: kCellIdentifierInvite, kCellClassKey: InvitedUserRequestTableCell.self, kCellHeightKey: InvitedUserRequestTableCell.height]
        ]
    }
        
    
    private func _loadData(_ isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        if isSearching {
            if isFromEvent {
                filteredUserListModel.forEach { model in
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifierInvite,
                        kCellTagKey: kCellIdentifierInvite,
                        kCellObjectDataKey: model,
                        kCellClassKey: InvitedUserRequestTableCell.self,
                        kCellHeightKey: InvitedUserRequestTableCell.height
                    ])
                }
            } else {
                filteredUserListModel.forEach { model in
                    if model.inviteStatus == "in", model.promoterStatus != "rejected" {
                        cellData.append([
                            kCellIdentifierKey: kCellIdentifierInvite,
                            kCellTagKey: kCellIdentifierInvite,
                            kCellObjectDataKey: model,
                            kCellClassKey: InvitedUserRequestTableCell.self,
                            kCellHeightKey: InvitedUserRequestTableCell.height
                        ])
                    }
                }
//                filteredNotificationListModel.forEach { model in
//                    if model.inviteStatus == "in", model.promoterStatus != "rejected" {
//                        cellData.append([
//                            kCellIdentifierKey: kCellIdentifier,
//                            kCellTagKey: kCellIdentifier,
//                            kCellObjectDataKey: model,
//                            kCellClassKey: UserRequestTableCell.self,
//                            kCellHeightKey: UserRequestTableCell.height
//                        ])
//                    }
//                }
            }
        } else {
            if isFromEvent {
                if isLoading {
                    cellData.append([
                        kCellIdentifierKey: kLoadingCell,
                        kCellTagKey: kEmptyString,
                        kCellObjectDataKey: "Loading...",
                        kCellClassKey: LoadingCell.self,
                        kCellHeightKey: LoadingCell.height
                    ])
                } else {
                    if userType == "invited" {
                        _invitedUsers.forEach { model in
                            model.user = model.getUser(SeeAllUsersBottomSheet.allUsersList)
                            cellData.append([
                                kCellIdentifierKey: kCellIdentifierInvite,
                                kCellTagKey: kCellIdentifierInvite,
                                kCellObjectDataKey: model,
                                kCellClassKey: InvitedUserRequestTableCell.self,
                                kCellHeightKey: InvitedUserRequestTableCell.height
                            ])
                        }
                    } else if userType == "in" {
                        _inMembers.forEach { model in
                            if model.inviteStatus == "in", model.promoterStatus != "rejected", model.promoterStatus == "accepted" {
                                model.user = model.getUser(SeeAllUsersBottomSheet.allUsersList)
                                cellData.append([
                                    kCellIdentifierKey: kCellIdentifierInvite,
                                    kCellTagKey: kCellIdentifierInvite,
                                    kCellObjectDataKey: model,
                                    kCellClassKey: InvitedUserRequestTableCell.self,
                                    kCellHeightKey: InvitedUserRequestTableCell.height
                                ])
                            }
                        }
                    } else if userType == "intreseted" {
                        _interestedMembers.forEach { model in
                            if model.inviteStatus == "in", model.promoterStatus == "pending" {
                                model.user = model.getUser(SeeAllUsersBottomSheet.allUsersList)
                                cellData.append([
                                    kCellIdentifierKey: kCellIdentifierInvite,
                                    kCellTagKey: kCellIdentifierInvite,
                                    kCellObjectDataKey: model,
                                    kCellClassKey: InvitedUserRequestTableCell.self,
                                    kCellHeightKey: InvitedUserRequestTableCell.height
                                ])
                            }
                        }
                    } else if userType == "plusOne" {
                        _invitedUsers.forEach { model in
                            if model.inviteStatus == "in", model.plusOneInvite.count != 0 {
                                model.user = model.getUser(SeeAllUsersBottomSheet.allUsersList)
                                cellData.append([
                                    kCellIdentifierKey: kCellIdentifierInvite,
                                    kCellTagKey: kCellIdentifierInvite,
                                    kCellObjectDataKey: model,
                                    kCellClassKey: InvitedUserRequestTableCell.self,
                                    kCellHeightKey: InvitedUserRequestTableCell.height
                                ])
                            }
                        }
                    } else if userType == "cancelled" {
                        _inviteCancelList.forEach { model in
                            model.user = model.getUser(SeeAllUsersBottomSheet.allUsersList)
                            cellData.append([
                                kCellIdentifierKey: kCellIdentifierInvite,
                                kCellTagKey: kCellIdentifierInvite,
                                kCellObjectDataKey: model,
                                kCellClassKey: InvitedUserRequestTableCell.self,
                                kCellHeightKey: InvitedUserRequestTableCell.height
                            ])
                        }
                    }
                }
            } else {
                if notificationModel == nil {
                    if let invitedCount = chatListModel?.users.toArrayDetached(ofType: UserDetailModel.self).filter({ $0.promoterStatus == "accepted" }).count, let max = chatListModel?.maxInvitee, invitedCount >= max   {
                        isEventFull = true
                    }
                    chatListModel?.users.forEach { model in
                        if model.inviteStatus == "in", model.promoterStatus != "rejected", model.promoterStatus == "accepted" {
                            cellData.append([
                                kCellIdentifierKey: kCellIdentifier,
                                kCellTagKey: kCellIdentifier,
                                kCellObjectDataKey: model,
                                kCellClassKey: UserRequestTableCell.self,
                                kCellHeightKey: UserRequestTableCell.height
                            ])
                        }
                    }
                } else {
                    if let invitedCount = notificationModel?.list.toArrayDetached(ofType: NotificationModel.self).filter({ $0.promoterStatus == "accepted" }).count, let max = notificationModel?.event?.maxInvitee, invitedCount >= max {
                        isEventFull = true
                    }
                    
                    if userType == "invited" {
                        if notificationModel == nil {
                            _invitedUsers.forEach { model in
                                if model.inviteStatus == "in", model.promoterStatus != "rejected", model.promoterStatus == "accepted" {
                                    model.user = model.getUser(SeeAllUsersBottomSheet.allUsersList)
                                    cellData.append([
                                        kCellIdentifierKey: kCellIdentifierInvite,
                                        kCellTagKey: kCellIdentifierInvite,
                                        kCellObjectDataKey: model,
                                        kCellClassKey: InvitedUserRequestTableCell.self,
                                        kCellHeightKey: InvitedUserRequestTableCell.height
                                    ])
                                }
                            }
                        } else {
                            _invitedUsers.forEach { model in
                                if model.inviteStatus == "in", model.promoterStatus != "rejected" {
                                    model.user = model.getUser(SeeAllUsersBottomSheet.allUsersList)
                                    cellData.append([
                                        kCellIdentifierKey: kCellIdentifierInvite,
                                        kCellTagKey: kCellIdentifierInvite,
                                        kCellObjectDataKey: model,
                                        kCellClassKey: InvitedUserRequestTableCell.self,
                                        kCellHeightKey: InvitedUserRequestTableCell.height
                                    ])
                                }
                            }
                        }
                    }
                }
                

            }
                
//                if notificationModel == nil {
//                    chatListModel?.users.forEach { model in
//                        if model.inviteStatus == "in", model.promoterStatus != "rejected", model.promoterStatus == "accepted" {
//                            cellData.append([
//                                kCellIdentifierKey: kCellIdentifier,
//                                kCellTagKey: kCellIdentifier,
//                                kCellObjectDataKey: model,
//                                kCellClassKey: UserRequestTableCell.self,
//                                kCellHeightKey: UserRequestTableCell.height
//                            ])
//                        }
//                    }
//                } else {
//                    notificationModel?.list.forEach { model in
//                        if model.inviteStatus == "in", model.promoterStatus != "rejected" {
//                            cellData.append([
//                                kCellIdentifierKey: kCellIdentifier,
//                                kCellTagKey: kCellIdentifier,
//                                kCellObjectDataKey: model,
//                                kCellClassKey: UserRequestTableCell.self,
//                                kCellHeightKey: UserRequestTableCell.height
//                            ])
//                        }
//                    }
//                }
            }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

extension SeeAllUsersBottomSheet:CustomTableViewDelegate,UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollViewContentHeight = scrollView.contentSize.height
        let scrollOffsetThreshold = scrollViewContentHeight - scrollView.bounds.height
        if scrollView.contentOffset.y > scrollOffsetThreshold && !isRequesting && !isSearching {
            if isFromEvent {
                performPagination()
            }
        }
    }
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
        if let cell = cell as? UserRequestTableCell {
            if  let data = cellDict?[kCellObjectDataKey] as? NotificationModel {
                cell.setupData(data, isEvent: true, isEventFull: isEventFull, isConfirmation: notificationModel?.event?.isConfirmationRequired ?? false)
                cell.openCallback = { chatModel in
                    self.dismiss(animated: true) {
                        self.openChat?(chatModel)
                    }
                }
                cell.updateStatusCallback = { status in
                    if let list = self.notificationModel?.list {
                        if let index = list.firstIndex(where: { $0.id == data.id }) {
                            data.promoterStatus = status
                            self.notificationModel?.list[index] = data
                            self._loadData()
                        }
                    }
                }
            } else if let object = cellDict?[kCellObjectDataKey] as? InvitedUserModel {
                if isFromEvent {
                    let NoButtons = userType == "invited" ||  userType == "cancelled" || event?.status == "cancelled" || event?.status == "completed"
                    cell.setupEventData(object, isEventFull: isEventFull, isConfirmation: event?.isConfirmationRequired ?? false, isNoAction: NoButtons, type: userType)
                    cell.openCallback = { chatModel in
                        self.dismiss(animated: true) {
                            self.openChat?(chatModel)
                        }
                    }
                    cell.updateStatusCallback = { status in
                        if let list = self.event {
                            object.promoterStatus = status
                            if self.userType == "invited" {
                                if let index = list.invitedUsers.firstIndex(where: { $0.id == object.id }) {
                                    //                                self.event?.invitedUsers[index] = object.user
                                }
                            } else if self.userType == "in" {
                                if let index = list.inMembers.firstIndex(where: { $0.id == object.id }) {
                                    //                                self.event?.inMembers[index] = object
                                }
                            } else if self.userType == "intreseted" {
                                if let index = list.interestedMembers.firstIndex(where: { $0.id == object.id }) {
                                    //                                self.event?.interestedMembers[index] = object
                                }
                            }
                            self._loadData()
                        }
                    }
                }
            } else if let object = cellDict?[kCellObjectDataKey] as? UserDetailModel {
                cell.setupUserData(object)
                cell.openCallback = { chatModel in
                    self.dismiss(animated: true) {
                        self.openChat?(chatModel)
                    }
                }
                cell.updateStatusCallback = { status in
                    if let list = self.chatListModel?.users {
                        if let index = list.firstIndex(where: { $0.id == object.id }) {
                            object.promoterStatus = status
                            self.chatListModel?.users[index] = object
                            self._loadData()
                        }
                    }
                }
            }
        } else if let cell = cell as? InvitedUserRequestTableCell, let object = cellDict?[kCellObjectDataKey] as? InvitedUserModel {
            let NoButtons = userType == "invited" ||  userType == "cancelled" || event?.status == "cancelled" || event?.status == "completed"
            cell.setUpData(object, isEventFull: isEventFull, isConfirmation: event?.isConfirmationRequired ?? false, isNoAction: isFromEvent ? NoButtons : false, type: isFromEvent ? userType : "intreseted")
            cell.openCallback = { chatModel in
                self.dismiss(animated: true) {
                    self.openChat?(chatModel)
                }
            }
            cell.updateStatusCallback = { status in
                self._requestUserInviteList()
            }
            cell.openProfile = { [weak self] id, isRingMember in
                guard let self = self else { return }
                dismiss(animated: true) {
                    self.openProfile?(id, isRingMember)
                }
            }
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? UserRequestTableCell {
            if let data = cellDict?[kCellObjectDataKey] as? NotificationModel {
                dismiss(animated: true) {
                    self.openProfile?(data.userId, data.isRingMember)
                }
            } else if let object = cellDict?[kCellObjectDataKey] as? InvitedUserModel {
                dismiss(animated: true) {
                    self.openProfile?(object.userId, object.user?.isRingMember ?? false)
                }
            }
        } else if let cell = cell as? InvitedUserRequestTableCell, let object = cellDict?[kCellObjectDataKey] as? InvitedUserModel {
            dismiss(animated: true) {
                self.openProfile?(object.userId, object.user?.isRingMember ?? false)
            }
        }
    }
    
    private func performPagination() {
        guard !isPaginating else { return }
        
        if userType == "invited" {
            if !_invitedUsers.isEmpty && _invitedUsers.count % 50 == 0 {
                isPaginating = true
                _page += 1
                footerView?.startAnimating()
                _requestUserInviteList()
            }
        } else if  userType == "in" {
            if !_inMembers.isEmpty && _inMembers.count % 50 == 0 {
                isPaginating = true
                _page += 1
                footerView?.startAnimating()
                _requestUserInviteList()
            }
        } else if userType == "intreseted" {
            if !_interestedMembers.isEmpty && _interestedMembers.count % 50 == 0 {
                isPaginating = true
                _page += 1
                footerView?.startAnimating()
                _requestUserInviteList()
            }
        } else if userType == "plusOne" {
            if !_plusOneMembers.isEmpty && _plusOneMembers.count % 50 == 0 {
                isPaginating = true
                _page += 1
                footerView?.startAnimating()
                _requestUserInviteList()
            }
        }
    }
}

// --------------------------------------
// MARK: Search Delegate
// --------------------------------------

extension SeeAllUsersBottomSheet: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            _loadData()
        } else {
            isSearching = true
            if isFromEvent {
                if userType == "invited" {
                    filteredUserListModel = _invitedUsers.filter { model in
                        return model.user?.fullName.localizedCaseInsensitiveContains(searchText) ?? false
                    }
                } else if userType == "in" {
                    filteredUserListModel = _inMembers.filter { model in
                        return model.user?.fullName.localizedCaseInsensitiveContains(searchText) ?? false
                    }
                } else if userType == "intreseted" {
                    filteredUserListModel = _interestedMembers.filter { model in
                        return model.user?.fullName.localizedCaseInsensitiveContains(searchText) ?? false
                    }
                } else if userType == "cancelled" {
                    filteredUserListModel = _invitedUsers.filter { model in
                        return model.user?.fullName.localizedCaseInsensitiveContains(searchText) ?? false
                    }
                }
//                else if userType == "plusOne" {
//                    filteredUserListModel = _plusOneMembers.filter { model in
//                        return model.user?.fullName.localizedCaseInsensitiveContains(searchText)
//                    }
//                }
            } else {
//                filteredNotificationListModel = notificationModel?.list.toArrayDetached(ofType: NotificationModel.self).filter { model in
//                    return model.descriptions.localizedCaseInsensitiveContains(searchText)
//                } ?? []
                filteredUserListModel = _invitedUsers.filter { model in
                    return model.user?.fullName.localizedCaseInsensitiveContains(searchText) ?? false
                }
            }
            _loadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}
