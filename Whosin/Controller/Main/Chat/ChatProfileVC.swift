import UIKit

class ChatProfileVC: ChildViewController {
    
    @IBOutlet private weak var _tableView: CustomTableView!
    private let kCellIdentifier = String(describing: ProfileDetailTableCell.self)
    private let kBGCellIdentifier = String(describing: ChangeChatBgTableCell.self)
    private let kMediaCellIdentifier = String(describing: ProfileMediaTableCell.self)
    private let kBlockCellIdentifier = String(describing: BlockTableCell.self)
    private let kBucketCellIdentifier = String(describing: BucketListTableCell.self)
    private let kContactCellIdentifier = String(describing: ContactsTableCell.self)
    public var userId: String?
    public var chatModel: ChatModel?
    public var chatType: ChatType = .user
    private var userModel: UserDetailModel?
    private var _bucketList: [BucketDetailModel]?
    private var _userList: [UserDetailModel]? = []
    private var _bucketDetail: BucketDetailModel?
    private var _eventModel: EventModel?
    public var _outingModel: OutingListModel?
    private var _mediaCount: Int = 0
    private var footerView: LoadingFooterView?
    // Event releted variables
    private var _invitationList: [InvitationModel] = []
    private var _page : Int = 1
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
        let chatRepo = ChatRepository()
        if chatType == .user || chatType == .promoterEvent {
            let userRepo = UserRepository()
            if  let userId = chatModel?.members.first(where: { $0 != APPSESSION.userDetail?.id}) {
                if let userModel = userRepo.getUserById(userId: userId) {
                    self.userModel = userModel.detached()
                    self._loadData()
                    _requestUserProfile()
                    _requestBucketList()
                } else {
                    _tableView.isHidden = true
                    _requestUserProfile(isShowHud: true)
                    _requestBucketList()
                }
            } else {
                _requestUserProfile(isShowHud: true)
                _requestBucketList()
            }
        } 
        else if let allChatModel = chatRepo.getAllGroupChatListOffline() {
            if chatType == .event {
                if let event = allChatModel.events.first(where: { $0.id == self.chatModel?.chatId ?? kEmptyString }) {
                    isRequesting = true
                    _eventModel = event
                    _loadEventData()
                    _requestEventDetails()
                    _eventGuestListData()
                } else {
                    _requestEventDetails(isShowHud: true)
                    _eventGuestListData()
                }
            } else if chatType == .outing {
                _mediaCount = chatRepo.getMediaMessagesCount(chatId: _outingModel?.id ?? kEmptyString)
                _loadOutingData()
            } else if chatType == .bucket {
                if let bucket = allChatModel.bucketList.first(where: { $0.id == self.chatModel?.chatId ?? kEmptyString }) {
                    self._bucketDetail = bucket
                    self._loadBucketData()
                    _requestBucketDetails()
                } else {
                    _requestBucketDetails(isShowHud: true)
                }
            }
        } else {
            if chatType == .event {
                _requestEventDetails(isShowHud: true)
                _eventGuestListData()
            } else if chatType == .outing {
                _mediaCount = chatRepo.getMediaMessagesCount(chatId: _outingModel?.id ?? kEmptyString)
                _loadOutingData()
            } else {
                _requestBucketDetails(isShowHud: true)
            }
        }

        _mediaCount = chatRepo.getMediaMessagesCount(chatId: chatModel?.chatId ?? kEmptyString)


    }
    
    override func setupUi() {
        hideNavigationBar()
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: true,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "There is no profile detail",
            emptyDataIconImage: UIImage(named: "empty_follower"),
            emptyDataDescription: nil,
            delegate: self)
        footerView = LoadingFooterView(frame: CGRect(x: 0, y: 0, width: _tableView.bounds.width, height: 44))
        _tableView.tableFooterView = footerView
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _fillBucketList() -> [[String: Any]] {
        var cellData = [[String: Any]]()
        let userRepo = UserRepository()
        _bucketList?.forEach{ bucket in
            _userList?.removeAll()
            if let user = userRepo.getUserById(userId: bucket.userId) {
                _userList?.append(user)
            }
            bucket.sharedUser.forEach {  userId in
                if let user = userRepo.getUserById(userId: userId) {
                    _userList?.append(user)
                }
            }
            if bucket.userId == userId || bucket.sharedUser.contains(where: { String in
                String == userId
            }){
                cellData.append([
                    kCellIdentifierKey: kBucketCellIdentifier,
                    kCellTagKey: kBucketCellIdentifier,
                    kCellObjectDataKey: bucket,
                    kCellClassKey: BucketListTableCell.self,
                    kCellHeightKey: BucketListTableCell.height
                ])
            }
        }
        
        return cellData
    }
    
    private func _fillBucketDetail() -> [[String: Any]] {
        var cellData = [[String: Any]]()
        
        _bucketDetail?.sharedWith.forEach({ contact in
            cellData.append([
                kCellIdentifierKey: kContactCellIdentifier,
                kCellTagKey: contact.id,
                kCellObjectDataKey: contact,
                kCellClassKey: ContactsTableCell.self,
                kCellHeightKey: ContactsTableCell.height
            ])
        })
        
        return cellData
    }

    private func _fillEventUsers() -> [[String: Any]] {
        var cellData = [[String: Any]]()
        self._invitationList.forEach { guestList in
            if let user = _userList?.first(where: { $0.id == guestList.userId}) {
                cellData.append([
                    kCellIdentifierKey: kContactCellIdentifier,
                    kCellTagKey: user.id,
                    kCellObjectDataKey: user,
                    kCellClassKey: ContactsTableCell.self,
                    kCellHeightKey: ContactsTableCell.height
                ])
            }
        }
        return cellData
    }

    
    private func _fillOutingDetail() -> [[String: Any]] {
        var cellData = [[String: Any]]()
        _outingModel?.invitedUser.forEach({ contact in
            cellData.append([
                kCellIdentifierKey: kContactCellIdentifier,
                kCellTagKey: contact.id,
                kCellObjectDataKey: contact,
                kCellClassKey: ContactsTableCell.self,
                kCellHeightKey: ContactsTableCell.height
            ])
        })
        
        return cellData
    }
    
    private func _loadData(isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        _tableView.isHidden = false
        if let _userModel = userModel {
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: _userModel.id,
                kCellObjectDataKey: _userModel,
                kCellClassKey: ProfileDetailTableCell.self,
                kCellHeightKey: ProfileDetailTableCell.height
            ])
            cellData.append([
                kCellIdentifierKey: kBGCellIdentifier,
                kCellTagKey: kBGCellIdentifier,
                kCellObjectDataKey: chatModel?.chatId ?? kEmptyString,
                kCellClassKey: ChangeChatBgTableCell.self,
                kCellHeightKey: ChangeChatBgTableCell.height
            ])
            if _mediaCount > 0 {
                cellData.append([
                    kCellIdentifierKey: kMediaCellIdentifier,
                    kCellTagKey: kMediaCellIdentifier,
                    kCellObjectDataKey: chatModel?.chatId ?? kEmptyString,
                    kCellClassKey: ProfileMediaTableCell.self,
                    kCellHeightKey: ProfileMediaTableCell.height
                ])
            }

            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
            let bucketListDict = _fillBucketList()
            if !bucketListDict.isEmpty {
                cellSectionData.append([kSectionTitleKey: "bucketlist_in_common".localized(), kSectionDataKey: bucketListDict])
            }
            cellData.removeAll()
            cellData.append([
                kCellIdentifierKey: kBlockCellIdentifier,
                kCellTagKey: kBlockCellIdentifier,
                kCellObjectDataKey: "block".localized() +  " \(_userModel.fullName)",
                kCellButtonTitleKey: "Block",
                kCellClassKey: BlockTableCell.self,
                kCellHeightKey: BlockTableCell.height
            ])
            cellData.append([
                kCellIdentifierKey: kBlockCellIdentifier,
                kCellTagKey: kBlockCellIdentifier,
                kCellObjectDataKey: "report".localized() + " \(_userModel.fullName)",
                kCellButtonTitleKey: "Report",
                kCellClassKey: BlockTableCell.self,
                kCellHeightKey: BlockTableCell.height
            ])
            cellSectionData.append([kSectionTitleKey: " ", kSectionDataKey: cellData])
        }
        _tableView.loadData(cellSectionData)
    }
    
    private func _loadBucketData(isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        if let bucketDetail = _bucketDetail {
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: bucketDetail,
                kCellClassKey: ProfileDetailTableCell.self,
                kCellHeightKey: ProfileDetailTableCell.height
            ])
            
            cellData.append([
                kCellIdentifierKey: kBGCellIdentifier,
                kCellTagKey: kBGCellIdentifier,
                kCellObjectDataKey: chatModel?.chatId ?? kEmptyString,
                kCellClassKey: ChangeChatBgTableCell.self,
                kCellHeightKey: ChangeChatBgTableCell.height
            ])
            if _mediaCount > 0 {
                cellData.append([
                    kCellIdentifierKey: kMediaCellIdentifier,
                    kCellTagKey: kMediaCellIdentifier,
                    kCellObjectDataKey: chatModel?.chatId ?? kEmptyString,
                    kCellClassKey: ProfileMediaTableCell.self,
                    kCellHeightKey: ProfileMediaTableCell.height
                ])
            }

            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
            
            let bucketDetailDict = _fillBucketDetail()
            cellSectionData.append([kSectionTitleKey: "members".localized(), kSectionDataKey: bucketDetailDict])
            
            cellData.removeAll()
            cellData.append([
                kCellIdentifierKey: kBlockCellIdentifier,
                kCellTagKey: kBlockCellIdentifier,
                kCellObjectDataKey: "clear_chat".localized(),
                kCellButtonTitleKey: "Clear",
                kCellClassKey: BlockTableCell.self,
                kCellHeightKey: BlockTableCell.height
            ])
            
            cellData.append([
                kCellIdentifierKey: kBlockCellIdentifier,
                kCellTagKey: kBlockCellIdentifier,
                kCellObjectDataKey: "exit_group".localized(),
                kCellButtonTitleKey: "Exit",
                kCellClassKey: BlockTableCell.self,
                kCellHeightKey: BlockTableCell.height
            ])
            cellSectionData.append([kSectionTitleKey: " ", kSectionDataKey: cellData])
            
        }
        
        _tableView.loadData(cellSectionData)
    }
    
    private func _loadEventData(isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        if let _eventModel = _eventModel {
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: _eventModel,
                kCellClassKey: ProfileDetailTableCell.self,
                kCellHeightKey: ProfileDetailTableCell.height
            ])
            if _eventModel.admins.contains(APPSESSION.userDetail?.id ?? kEmptyString) {
                cellData.append([
                    kCellIdentifierKey: kBGCellIdentifier,
                    kCellTagKey: kBGCellIdentifier,
                    kCellObjectDataKey: chatModel?.chatId ?? kEmptyString,
                    kCellClassKey: ChangeChatBgTableCell.self,
                    kCellHeightKey: ChangeChatBgTableCell.height
                ])
            }
            
            if _mediaCount > 0 {
                cellData.append([
                    kCellIdentifierKey: kMediaCellIdentifier,
                    kCellTagKey: kMediaCellIdentifier,
                    kCellObjectDataKey: chatModel?.chatId ?? kEmptyString,
                    kCellClassKey: ProfileMediaTableCell.self,
                    kCellHeightKey: ProfileMediaTableCell.height
                ])
            }

            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
            
            let bucketDetailDict = _fillEventUsers() //_fillEventDetail()
            cellSectionData.append([kSectionTitleKey: "members".localized(), kSectionDataKey: bucketDetailDict])
            
            cellData.removeAll()
            cellData.append([
                kCellIdentifierKey: kBlockCellIdentifier,
                kCellTagKey: kBlockCellIdentifier,
                kCellObjectDataKey: "clear_chat".localized(),
                kCellButtonTitleKey: "Clear",
                kCellClassKey: BlockTableCell.self,
                kCellHeightKey: BlockTableCell.height
            ])
            
            cellSectionData.append([kSectionTitleKey: "", kSectionDataKey: cellData])
            
        }
        
        _tableView.loadData(cellSectionData)
    }
    
    private func _loadOutingData(isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        if let _outingModel = _outingModel {
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: _outingModel,
                kCellClassKey: ProfileDetailTableCell.self,
                kCellHeightKey: ProfileDetailTableCell.height
            ])
            
            cellData.append([
                kCellIdentifierKey: kBGCellIdentifier,
                kCellTagKey: kBGCellIdentifier,
                kCellObjectDataKey: _outingModel.id,
                kCellClassKey: ChangeChatBgTableCell.self,
                kCellHeightKey: ChangeChatBgTableCell.height
            ])
            if _mediaCount > 0 {
                cellData.append([
                    kCellIdentifierKey: kMediaCellIdentifier,
                    kCellTagKey: kMediaCellIdentifier,
                    kCellObjectDataKey: _outingModel.id,
                    kCellClassKey: ProfileMediaTableCell.self,
                    kCellHeightKey: ProfileMediaTableCell.height
                ])
            }

            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
            
            let bucketDetailDict = _fillOutingDetail()
            cellSectionData.append([kSectionTitleKey: "Members", kSectionDataKey: bucketDetailDict])
            
            cellData.removeAll()
            cellData.append([
                kCellIdentifierKey: kBlockCellIdentifier,
                kCellTagKey: kBlockCellIdentifier,
                kCellObjectDataKey: "clear_chat".localized(),
                kCellButtonTitleKey: "Clear",
                kCellClassKey: BlockTableCell.self,
                kCellHeightKey: BlockTableCell.height
            ])
            
            cellSectionData.append([kSectionTitleKey: "", kSectionDataKey: cellData])
            
        }
        
        _tableView.loadData(cellSectionData)
    }
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: ProfileDetailTableCell.self, kCellHeightKey: ProfileDetailTableCell.height],
            [kCellIdentifierKey: kBGCellIdentifier, kCellNibNameKey: kBGCellIdentifier, kCellClassKey: ChangeChatBgTableCell.self, kCellHeightKey: ChangeChatBgTableCell.height],
            [kCellIdentifierKey: kMediaCellIdentifier, kCellNibNameKey: kMediaCellIdentifier, kCellClassKey: ProfileMediaTableCell.self, kCellHeightKey: ProfileMediaTableCell.height],
            [kCellIdentifierKey: kBlockCellIdentifier, kCellNibNameKey: kBlockCellIdentifier, kCellClassKey: BlockTableCell.self, kCellHeightKey: BlockTableCell.height],
            [kCellIdentifierKey: kBucketCellIdentifier, kCellNibNameKey: kBucketCellIdentifier, kCellClassKey: BucketListTableCell.self, kCellHeightKey: BucketListTableCell.height],
            [kCellIdentifierKey: kContactCellIdentifier, kCellNibNameKey: kContactCellIdentifier, kCellClassKey: ContactsTableCell.self, kCellHeightKey: ContactsTableCell.height]]
        
    }
    
    // --------------------------------------
    // MARK: Services
    // --------------------------------------
    
    private func _requestDeleteChat(chatId: String) {
        WhosinServices.deleteChatById(chatId: chatId) { [weak self]container, error in
            guard let self = self else { return }
            self.showToast(container?.message ?? kEmptyString)
        }
    }
    
    private func _requestUserProfile(isShowHud: Bool = false) {
        guard let _userId = userId else {return}
        if isShowHud { showHUD() }
        WhosinServices.getUserProfile(userId: _userId) {  [weak self] container , error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let model = container, model.isSuccess, let data = model.data else {
                _tableView.isHidden = false
                return
            }
            self.userModel = data
            self._loadData()
        }
    }
    
    private func _requestBlockUser(blockId: String) {
        WhosinServices.userBlock(id: blockId) { [weak self] container, error in
            guard let self = self else { return }
            if !Preferences.blockedUsers.contains(blockId) {
                Preferences.blockedUsers.append(blockId)
            }
            self.showSuccessMessage("oh_snap".localized(), subtitle: "you_have_blocked" + "\(self.userModel?.fullName ?? kEmptyString)")
            if let viewController = self.navigationController?.viewControllers.first {
                self.navigationController?.popToViewController(viewController, animated: true)
            }
        }
    }
    
    private func _requestReportUser(userId: String, reason: String, msg: String) {
        let params: [String: Any] = [
            "userId": userId,
            "message": msg,
            "reason": reason,
            "type": "chat",
            "typeId": self.chatModel?.lastMsg?.id ?? ""
        ]
        WhosinServices.addReportUser(params: params) { [weak self] container, error in
            guard let self = self else { return }
            if !Preferences.blockedUsers.contains(userId) {
                Preferences.blockedUsers.append(userId)
            }
            self.showSuccessMessage("oh_snap".localized(), subtitle: "you_have_reported" + "\(self.userModel?.fullName ?? kEmptyString)")
            if let viewController = self.navigationController?.viewControllers.first {
                NotificationCenter.default.post(name: .openReportSuccessCard, object: nil)
                self.navigationController?.popToViewController(viewController, animated: true)
                
            }
        }
    }
    
    private func _requestClearChat(chatId: String) {
        let chatRepo = ChatRepository()
        alert(title: kAppName, message: "clear_chat_confirmation".localized(), okActionTitle: "yes".localized()) { UIAlertAction in
            chatRepo.removeChatWithID(id: chatId) { model in
                self._requestDeleteChat(chatId: chatId)
            }
            if let viewController = self.navigationController?.viewControllers.first {
                self.navigationController?.popToViewController(viewController, animated: true)
            }
        } cancelHandler: { UIAlertAction in
            self.dismiss(animated: true)
        }
    }
    
    private func _requestExitChat() {
        guard let bucketId = _bucketDetail?.id else { return }
        WhosinServices.exitFromBucket(id: bucketId ) { [weak self] container, error in
            guard let self = self else { return }
            self.view.makeToast(container?.message)
            if let viewController = self.navigationController?.viewControllers.first {
                self.navigationController?.popToViewController(viewController, animated: true)
            }
        }
    }
    
    private func _requestBucketList() {
        let chatRepo = ChatRepository()
        chatRepo.getBucketListList { [weak self] model, error in
            guard let self = self else { return }
            guard let _buckets = model?.toArrayDetached(ofType: BucketDetailModel.self) else {
                self._loadData()
                return
            }
            self._bucketList = _buckets
            DISPATCH_ASYNC_MAIN {
                self._loadData()
            }
        }
    }
    
    private func _requestBucketDetails(isShowHud: Bool = false) {
        guard let _bucketId = chatModel?.chatId else { return }
        if isShowHud { showHUD() }
        WhosinServices.getBucketDetail(bucketId: _bucketId) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self._bucketDetail = data
            self._loadBucketData()
        }
    }

    private func _requestEventDetails(isShowHud: Bool = false) {
        guard let _eventId = chatModel?.chatId else { return }
        if isShowHud { showHUD() }
        self.isRequesting = true
        WhosinServices.getEventDetail(eventId: _eventId) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self._eventModel = data.event
            self._loadEventData()
        }
    }

    private func _eventGuestListData() {

        guard let _eventId = chatModel?.chatId else { return }
        self.isRequesting = true
        WhosinServices.getEventGuestList(eventId: _eventId, inviteStatus: "", page: _page) { [weak self] container, error in
            guard let self = self else { return }
            self.footerView?.stopAnimating()
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            if self._invitationList.isEmpty {
                self._invitationList = data.invitation.toArrayDetached(ofType: InvitationModel.self)
                self._userList = data.user.toArrayDetached(ofType: UserDetailModel.self)
            } else {
                self._invitationList.append(contentsOf: data.invitation.toArrayDetached(ofType: InvitationModel.self))
                self._userList?.append(contentsOf:data.user.toArrayDetached(ofType: UserDetailModel.self))
            }

            self._loadEventData()
            self.isRequesting = false
        }
    }

    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        if let _ = self.presentingViewController {
            dismiss(animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}

extension ChatProfileVC: CustomTableViewDelegate, UIScrollViewDelegate, UITableViewDelegate {

    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if chatType == .user || chatType == .promoterEvent{
            if let cell = cell as? ProfileDetailTableCell {
                guard let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
                cell.setup(object)
                cell._followStack.superview?.isHidden = false
            } else if cell is ChangeChatBgTableCell {
                guard cellDict?[kCellObjectDataKey] is [UserModel] else { return }
            } else if let cell = cell as? ProfileMediaTableCell {
                guard let object = cellDict?[kCellObjectDataKey] as? String else { return }
                cell.setupData(object)
            } else if let cell = cell as? BlockTableCell {
                guard let object = cellDict?[kCellObjectDataKey] as? String else { return }
                cell.setup(object)
            } else if let cell = cell as? BucketListTableCell {
                guard let object = cellDict?[kCellObjectDataKey] as? BucketDetailModel else { return }
                cell.setupData(object, userModel: _userList ?? [], isFromSheet: true)
            }
        } else if chatType == .bucket {
            if let cell = cell as? ProfileDetailTableCell {
                guard let object = cellDict?[kCellObjectDataKey] as? BucketDetailModel else { return }
                cell.setupBucket(object)
                cell._followStack.superview?.isHidden = true
            } else if let cell = cell as? ContactsTableCell {
                guard let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
                cell.setupData(object)
            } else if let cell = cell as? ProfileMediaTableCell {
                guard let object = cellDict?[kCellObjectDataKey] as? String else { return }
                cell.setupData(object)
            } else if let cell = cell as? BlockTableCell {
                guard let object = cellDict?[kCellObjectDataKey] as? String else { return }
                cell.setup(object)
            }
        } else if chatType == .event {
            if let cell = cell as? ProfileDetailTableCell {
                guard let object = cellDict?[kCellObjectDataKey] as? EventModel else { return }
                cell.setupEvent(object)
                cell._followStack.superview?.isHidden = true
            } else if let cell = cell as? ContactsTableCell {
                guard let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
                cell.setupData(object)
            } else if let cell = cell as? ProfileMediaTableCell {
                guard let object = cellDict?[kCellObjectDataKey] as? String else { return }
                cell.setupData(object)
            } else if let cell = cell as? BlockTableCell {
                guard let object = cellDict?[kCellObjectDataKey] as? String else { return }
                cell.setup(object)
            }
            
        } else if chatType == .outing {
            if let cell = cell as? ProfileDetailTableCell {
                guard let object = cellDict?[kCellObjectDataKey] as? OutingListModel else { return }
                cell.setupOuting(object)
                cell._followStack.superview?.isHidden = true
            } else if let cell = cell as? ContactsTableCell {
                guard let user = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
                cell.setupData(user)
            } else if let cell = cell as? ProfileMediaTableCell {
                guard let object = cellDict?[kCellObjectDataKey] as? String else { return }
                cell.setupData(object)
            } else if let cell = cell as? BlockTableCell {
                guard let object = cellDict?[kCellObjectDataKey] as? String else { return }
                cell.setup(object)
            }
        }
        
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if cell is ChangeChatBgTableCell {
            guard let _chatModel = self.chatModel else { return }
            let controller = INIT_CONTROLLER_XIB(ChatWallpaperVc.self)
            controller.chatId = _chatModel.chatId
            self.navigationController?.pushViewController(controller, animated: true)
        }
        else if cell is BucketListTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? BucketDetailModel else { return }
            let destinationViewController = INIT_CONTROLLER_XIB(BucketDetailVC.self)
            destinationViewController.bucketDetail = object
            destinationViewController.bucketId = object.id
            self.navigationController?.pushViewController(destinationViewController, animated: true)
        } else if cell is ContactsTableCell {
            guard let userDetail = APPSESSION.userDetail else { return }
            if let object = cellDict?[kCellObjectDataKey] as? UserDetailModel {
                if object.id != userDetail.id {
                    _openUserDetail(object.id)
                }
            } else if let object = cellDict?[kCellObjectDataKey] as? InvitationModel {
                if object.id != userDetail.id {
                    _openUserDetail(object.userId)
                }
            }
        } else if cell is BlockTableCell {
            if let action = cellDict?[kCellButtonTitleKey] as? String {
                if action == "Block" {
                    _optionsBottomSheet()
                } else if action == "Report" {
                    _optionsBottomSheet()
                } else if action == "Exit" {
                    alert(title: kAppName, message: "exit_the_chat".localized(), okActionTitle: "yes".localized()) { UIAlertAction in
                        self._requestExitChat()
                    } cancelHandler: { UIAlertAction in
                        self.dismiss(animated: true)
                    }
                } else if action == "Clear" {
                    if let chatID = chatModel?.chatId {
                        _requestClearChat(chatId: chatID)
                    }
                }
            }
        }
    }
    
    private func _optionsBottomSheet() {
        guard let _chatModel = self.chatModel else { return }
        guard let userDetail = APPSESSION.userDetail else { return }
        let id = Preferences.isSubAdmin ? userDetail.promoterId : userDetail.id
        let userId = _chatModel.detached().members.first(where: { $0 != id})
        let controller = INIT_CONTROLLER_XIB(ReportOptionsSheet.self)
        controller.isUserBlocked = Preferences.blockedUsers.contains(userId ?? "")
        controller.didUpdateCallback = { [weak self] type in
            guard let self = self else { return }
            switch type {
            case "report" :
                openReport(type)
            case "block":
                alert(title: kAppName, message: LANGMANAGER.localizedString(forKey: "block_user_alert", arguments: ["value": _chatModel.title]), okActionTitle: "yes".localized()) { UIAlertAction in
                    self._requestBlockUser(blockId: userId ?? "")
                } cancelHandler: { UIAlertAction in
                    self.dismiss(animated: true)
                }
            case "both":
                openReport(type)
            default :
                return
            }
        }
        self.presentAsPanModal(controller: controller)
    }
    
    private func openReport(_ type: String) {
        guard let _chatModel = self.chatModel else { return }
        guard let userDetail = APPSESSION.userDetail else { return }
        let id = Preferences.isSubAdmin ? userDetail.promoterId : userDetail.id
        let userId = _chatModel.detached().members.first(where: { $0 != id})
        let vc = INIT_CONTROLLER_XIB(ReportBottomSheet.self)
        vc.type = type
        vc.didUpdateCallback = { [weak self] type, reason, msg in
            guard let self = self else { return }
            if type == "both" {
                _requestBlockUser(blockId: userId ?? "")
                _requestReportUser(userId: userId ?? "", reason: reason, msg: msg)
            } else {
                self._requestReportUser(userId: userId ?? "", reason: reason, msg: msg)
            }
        }
        self.presentAsPanModal(controller: vc)

    }
    
    private func _openUserDetail(_ id: String) {
        let vc = INIT_CONTROLLER_XIB(UsersProfileVC.self)
        vc.contactId = id
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if chatType == .event {
            let scrollViewContentHeight = scrollView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - scrollView.bounds.height * 0.8

            if scrollView.contentOffset.y > scrollOffsetThreshold && !isRequesting {
                performPagination()
            }
        }
    }

    private func performPagination() {
        if !isRequesting, (_invitationList.count) % 30 == 0 {
            _page += 1
            footerView?.startAnimating()
            _eventGuestListData()
        }
    }
}
