import UIKit
import RealmSwift
import SDWebImage
import DifferenceKit
import SnapKit

class ChatHomeVC: ChildViewController {

    @IBOutlet private weak var _headerMenuBgView: UIView!
    @IBOutlet private weak var _confirmationView: GradientView!
    @IBOutlet private weak var _tableView: CustomTableView!
    @IBOutlet private weak var _addChatBtn: UIButton!
    @IBOutlet private weak var _deleteView: GradientView!
    @IBOutlet private weak var _visualEffectView: UIVisualEffectView!
    @IBOutlet private   weak var _cancelBtn: UIButton!
    @IBOutlet private weak var _searchBar: UISearchBar!
    private var _selectedIndex: Int = 0
    private let kCellIdentifierStoryView = String(describing: ChatStoryViewCell.self)
    private let kCellIdentifierFriendChatList = String(describing: FriendsChatListTableCell.self)
    private let kCellIdentifierBucketChatList = String(describing: BucketChatListTableCell.self)
    private let kCellIdentifierEventChatList = String(describing: EventChatListTableCell.self)
    private let kCellIdentifierLoading = String(describing: LoadingCell.self)
    private var homeModel: HomeModel?
    private var _chatList: [ChatModel]?
    private var _bucketList: [BucketDetailModel]?
    private var _eventList: [EventModel]?
    private var _outingList: [OutingListModel]?
    private var _eventChatList: [EventChatModel]?
    private var headerView = ChatTableHeaderView()
    private var isSearching = false
    private var filteredChatList: [ChatModel] = []
    private var filteredBucketList: [BucketDetailModel] = []
    private var filteredEventList: [EventModel] = []
    private var filteredOutingList: [OutingListModel] = []
    private var _cmChatList: [PromoterChatListModel] = []
    private var _filteredCMChatList: [PromoterChatListModel] = []
    private var isRingMember: Bool = APPSESSION.userDetail?.isRingMember ?? false
    private var isPromoter: Bool = APPSESSION.userDetail?.isPromoter ?? false
 
    override func viewDidLoad() {
        super.viewDidLoad()
        _loadingChat()
        checkSession()
        _tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        let headerView = ChatTableHeaderView(frame: _headerMenuBgView.frame.standardized)
        headerView.delegate = self
        headerView.setupTabLabels()
        self.headerView = headerView
        _headerMenuBgView.addSubview(self.headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.snp.makeConstraints { make in
            make.edges.equalTo(_headerMenuBgView)
        }
        setupUi()
        _loadData()
        _requestBucketList()
        _requestFollowersList()
        if isRingMember {
            _requestCMEventChatList()
        } else if isPromoter {
            _requestChatList()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: kMessageNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotificationCount(_:)), name: kMessageCountNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleReloadFollowingList(_:)), name: Notification.Name("reloadFollowingList"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateNotification(_:)), name: kUpdateMessageNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: kUpdateMessageNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: kMessageNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: kMessageCountNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("reloadFollowingList"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUnreadStatus()
        hideNavigationBar()
        _deleteView.isHidden = true
        _addChatBtn.isHidden = _selectedIndex != 0
        _setupHeader()
        _loadData()
        if isRingMember {
            _requestCMEventChatList()
        } else if isPromoter {
            _requestChatList()
        }
    }
    
    override func setupUi() {
        _tableView.isHidden = false
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: true,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: true,
            isShowRefreshing: true,
            emptyDataText: kEmptyString,
            emptyDataIconImage: _selectedIndex == 0 ?   UIImage(named: "empty_chat") : UIImage(named: "empty_event"),
            emptyDataDescription: _selectedIndex == 0 ? "empty_chat_list".localized() : "empty_group_chat_list".localized(),
            delegate: self)
        _addChatBtn.isHidden = _selectedIndex != 0
        _visualEffectView.alpha = 0
        _searchBar.delegate = self
        _searchBar.searchTextField.backgroundColor = UIColor(white: 1, alpha: 0.08)
        _searchBar.searchTextField.layer.cornerRadius = 18
        _searchBar.searchTextField.layer.masksToBounds = true
        _searchBar.searchTextField.textColor = .white

    }
    
    private func _setupHeader() {
        headerView.setupData(_selectedIndex)
    }
    
    // --------------------------------------
    // MARK: Services
    // --------------------------------------
    
    private func updateUnreadStatus() {
        let chatRepo = ChatRepository()
        chatRepo.getUnReadMessagesTypeCount(type: "friend") { [weak self] count in
            guard let self = self else { return }
            self.headerView.hideShowUnreadIndicator(at: 0, isHide: count == 0 )
        }
        
        if isRingMember || isPromoter {
            chatRepo.getAllUnReadMessagesCountForGroup() { [weak self] count in
                guard let self = self else { return }
                self.headerView.hideShowUnreadIndicator(at: 2, isHide: count == 0 )
            }

            chatRepo.getUnReadMessagesTypeCount(type: "promoter_event") { [weak self] count in
                guard let self = self else { return }
                self.headerView.hideShowUnreadIndicator(at: 1, isHide: count == 0 )
            }
        } else {
            chatRepo.getAllUnReadMessagesCountForGroup() { [weak self] count in
                guard let self = self else { return }
                self.headerView.hideShowUnreadIndicator(at: 1, isHide: count == 0 )
            }
        }
    }
    
    private func _requestCreateChat(_ userModel: UserDetailModel) {
        guard let userDetail = APPSESSION.userDetail else { return }
        let chatModel = ChatModel()
        chatModel.image = userModel.image
        chatModel.title = userModel.fullName
        chatModel.members.append(userModel.id)
        chatModel.members.append(userDetail.id)
        let chatIds = [userModel.id, Preferences.isSubAdmin ? userDetail.promoterId : userDetail.id].sorted()
        chatModel.chatId = chatIds.joined(separator: ",")
        chatModel.chatType = "friend"
        DISPATCH_ASYNC_MAIN_AFTER(0.01) {
            let vc = INIT_CONTROLLER_XIB(ChatDetailVC.self)
            vc.chatModel = chatModel
            if let navController = self.navigationController {
                vc.hidesBottomBarWhenPushed = true
                navController.pushViewController(vc, animated: true)
            } else {
                let nav = NavigationController(rootViewController: vc)
                nav.modalPresentationStyle =  .overFullScreen
                self.present(nav, animated: true, completion: nil)
            }
        }
        
    }
    
    private func _requestBucketList() {
        let chatRepo = ChatRepository()
        chatRepo.getGroupChatLit { [weak self] container, error in
            guard let self = self else { return }
            self._tableView.endRefreshing()
            self.hideHUD(error: error)
            guard let data = container else { return }
            self._bucketList = data.bucketList.toArrayDetached(ofType: BucketDetailModel.self)
            self._eventList = data.events.toArrayDetached(ofType: EventModel.self)
            self._outingList = data.outings.toArrayDetached(ofType: OutingListModel.self)
            if isRingMember || isPromoter {
                if _selectedIndex == 2 {
                    self._loadData()
                }
            } else {
                if _selectedIndex == 1 {
                    self._loadData()
                }
            }
        }
    }
    
    private func _requestCMEventChatList(_ isReload: Bool = false) {
        if isReload { showHUD() }
        WhosinServices.complementaryChatList { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            self._tableView.endRefreshing()
            guard let data = container?.data else { return }
            self._cmChatList = data
            if _selectedIndex == 1 {
                self._loadCMChatListData(eventList: data, chatList: _chatList)
            }
        }
    }
    
    private func _requestChatList(_ isReload: Bool = false) {
        if isReload { showHUD() }
        WhosinServices.chatList() { [weak self] container, error in
            guard let self = self else { return }
            self._tableView.endRefreshing()
            self.hideHUD()
            guard let data = container?.data else { return }
            self._cmChatList = data
            if _selectedIndex == 1 {
                self._loadCMChatListData(eventList: data, chatList: _chatList)
            }
        }
    }
     
    private func _requestDeleteChat(chatId: String) {
        WhosinServices.deleteChatById(chatId: chatId) { container, error in

        }
    }
    
    private func _loadingChat() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        cellData.append([
            kCellIdentifierKey: kCellIdentifierLoading,
            kCellTagKey: self.kCellIdentifierLoading,
            kCellObjectDataKey: "loading",
            kCellClassKey: LoadingCell.self,
            kCellHeightKey: LoadingCell.height
        ])
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        self._tableView.loadData(cellSectionData)
    }
    
    private func _loadChatListData(chat: [ChatModel]?) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        chat?.forEach{ chat in
            if let userModel = chat.user {
                if self.isRingMember && userModel.isPromoter || Preferences.blockedUsers.contains(userModel.id) { return }
                cellData.append([
                    kCellIdentifierKey: self.kCellIdentifierFriendChatList,
                    kCellTagKey: self.kCellIdentifierFriendChatList,
                    kCellDifferenceIdentifierKey: chat.diffId,
                    kCellDifferenceContentKey: chat.hashValue,
                    kCellItemsKey: userModel,
                    kCellObjectDataKey: chat,
                    kCellClassKey: FriendsChatListTableCell.self,
                    kCellHeightKey: FriendsChatListTableCell.height
                ])
            }
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        DispatchQueue.main.async {
            self._tableView.loadData(cellSectionData)
        }
    }
    
    private func _loadGroupChatListData(bucketList: [BucketDetailModel]?, eventList: [EventModel]?, outingList: [OutingListModel]?) {
        var cellSectionData = [[String: Any]]()

        let chatRepo = ChatRepository()
        var idsArray = bucketList?.map { $0.id}
        if let eventIds = eventList?.map({ $0.id}) {
            idsArray?.append(contentsOf: eventIds)
        }
        if let outingIds = outingList?.map({ $0.id}) {
            idsArray?.append(contentsOf: outingIds)
        }
        var messageList: [MessageModel] = []
        idsArray?.forEach { id in
            if let lastMsg = chatRepo.getLastMessages(chatId: id) {
                messageList.append(lastMsg)
            }
        }

        let sortedAllChats = messageList.sorted { $0.date > $1.date }
        var typeList: [String] = ["bucket", "event", "outing"]

        if !sortedAllChats.isEmpty {
            var tempList: [String] = []
            sortedAllChats.forEach { message in
                if !tempList.contains(message.chatType) {
                    tempList.append(message.chatType)
                }
            }

            typeList.forEach { type in
                if !tempList.contains(type) {
                    tempList.append(type)
                }
            }
            typeList = tempList
        }

        typeList.forEach { type in
            if type == "bucket" {
                let sortedBucketChats = bucketList?.compactMap { bucket in
                    bucket.lastMsg = sortedAllChats.first(where: { $0.chatId == bucket.id })
                    return bucket
                }
                let sortedChats = sortedBucketChats?.sorted { $0.lastMsg?.date ?? "0" > $1.lastMsg?.date ?? "0" }
                
                if let buckets = sortedChats, !buckets.isEmpty {
                    var cellData = [[String: Any]]()
                    buckets.forEach{ bucket in
                        cellData.append([
                            kCellIdentifierKey: kCellIdentifierBucketChatList,
                            kCellDifferenceIdentifierKey: bucket.id,
                            kCellDifferenceContentKey: bucket.hashValue,
                            kCellTagKey: bucket.id,
                            kCellObjectDataKey: bucket,
                            kCellClassKey: BucketChatListTableCell.self,
                            kCellHeightKey: BucketChatListTableCell.height
                        ])
                    }

                    if cellData.count != .zero {
                        cellSectionData.append([kSectionTitleKey: cellData.isEmpty ?  "bucket_chats".localized() : LANGMANAGER.localizedString(forKey: "bucket_chat_item", arguments: ["value": "\(cellData.count)"]), kSectionDataKey: cellData, kSectionBgColor: ColorBrand.clear])
                    }
                }
            }
            else if type == "event" {
                eventList?.forEach { event in
                    if !Utils.isDateExpired(dateString: event.eventTime, format: kStanderdDate) {
                        if let lastMsg = sortedAllChats.first(where: {$0.chatId == event.id}) {
                            event.lastMsg = lastMsg.detached()
                        }
                    }
                }

                let sortedEventChats = eventList?.sorted { $0.lastMsg?.date ?? "0" > $1.lastMsg?.date ?? "0" }
                if let events = sortedEventChats, !events.isEmpty {
                    var cellData = [[String: Any]]()
                    events.forEach{ event in
                        if !Utils.isDateExpired(dateString: event.eventTime, format: kStanderdDate) {
                            cellData.append([
                                kCellIdentifierKey: kCellIdentifierEventChatList,
                                kCellDifferenceIdentifierKey: event.id,
                                kCellDifferenceContentKey: event.hashValue,
                                kCellTagKey: event.id,
                                kCellObjectDataKey: event,
                                kCellClassKey: EventChatListTableCell.self,
                                kCellHeightKey: EventChatListTableCell.height
                            ])
                        } else {
                            chatRepo.removeChatWithID(id: event.id) { _ in
                            }
                        }
                    }
                    if cellData.count != .zero {
                        cellSectionData.append([kSectionTitleKey: cellData.isEmpty ? "event_chats".localized() : LANGMANAGER.localizedString(forKey: "event_chat_item", arguments: ["value": "\(cellData.count)"]), kSectionDataKey: cellData, kSectionBgColor: ColorBrand.clear])
                    }
                }
            }
            else if type == "outing" {
                let outingChats = outingList?.compactMap { outing in
                    outing.lastMsg = sortedAllChats.first(where: { $0.chatId == outing.id })
                    return outing
                }
                
                let sortedOutingChats = outingChats?.sorted { $0.lastMsg?.date ?? "0" > $1.lastMsg?.date ?? "0" }
                if let outings = sortedOutingChats, !outings.isEmpty {
                    var cellData = [[String: Any]]()
                    outings.forEach{ outing in
                        cellData.append([
                            kCellIdentifierKey: kCellIdentifierEventChatList,
                            kCellDifferenceIdentifierKey: outing.id,
                            kCellDifferenceContentKey: outing.hashValue,
                            kCellTagKey: outing.id,
                            kCellObjectDataKey: outing,
                            kCellClassKey: EventChatListTableCell.self,
                            kCellHeightKey: EventChatListTableCell.height
                        ])
                    }
                    if cellData.count != .zero {
                        cellSectionData.append([kSectionTitleKey: cellData.isEmpty ? "invitations_chats".localized() : LANGMANAGER.localizedString(forKey: "invite_chat_item", arguments: ["value": "\(cellData.count)"]), kSectionDataKey: cellData, kSectionBgColor: ColorBrand.clear])
                    }
                }
            }
        }
        DispatchQueue.main.async {
            self._tableView.loadData(cellSectionData)
        }
    }
    
    private func _loadCMChatListData(eventList: [PromoterChatListModel], chatList: [ChatModel]?) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        let userRepo = UserRepository()
        
        if isRingMember {
            chatList?.forEach({ chat in
                if let userModel = chat.user, userModel.isPromoter {
                    if Preferences.blockedUsers.contains(userModel.id) { return }
                    cellData.append([
                        kCellIdentifierKey: self.kCellIdentifierFriendChatList,
                        kCellTagKey: self.kCellIdentifierFriendChatList,
                        kCellDifferenceIdentifierKey: chat.id,
                        kCellDifferenceContentKey: chat.hashValue,
                        kCellItemsKey: userModel,
                        kCellObjectDataKey: chat,
                        kCellClassKey: FriendsChatListTableCell.self,
                        kCellHeightKey: FriendsChatListTableCell.height
                    ])
                }
            })
            
            if cellData.count != .zero {
                cellSectionData.append([kSectionTitleKey: "promoter".localized(), kSectionDataKey: cellData, kSectionBgColor: ColorBrand.clear])
                cellData.removeAll()
            }
        }
        
        DispatchQueue.main.async {
            self._tableView.loadData(cellSectionData)
        }
    }
    
    private func _loadChatList() {
        let userRepo = UserRepository()
        
        ChatRepository().fetchFriendChatList { [weak self]list, notFoundUser  in
            guard let self = self else { return }
            guard let id = APPSESSION.userDetail?.id else { return }
            self._chatList = list
            if _selectedIndex == 1 { return }
            self._loadChatListData(chat: list)
            DispatchQueue.global(qos: .userInitiated).async {
                if !notFoundUser.isEmpty {
                    var cellSectionData = [[String: Any]]()
                    userRepo.fatchUsers(notFoundUser) { model in
                        var cellData = [[String: Any]]()
                        list?.forEach{ chat in
                            let userId = chat.members.first { $0 != id } ?? kEmptyString
                            if !userId.isEmpty {
                                if let userModel = userRepo.getUserById(userId: userId), !userModel.fullName.isEmpty {
                                    if self.isRingMember && userModel.isPromoter || Preferences.blockedUsers.contains(userId) { return }
                                    cellData.append([
                                        kCellIdentifierKey: self.kCellIdentifierFriendChatList,
                                        kCellTagKey: self.kCellIdentifierFriendChatList,
                                        kCellDifferenceIdentifierKey: chat.id,
                                        kCellDifferenceContentKey: chat.hashValue,
                                        kCellItemsKey: userModel,
                                        kCellObjectDataKey: chat,
                                        kCellClassKey: FriendsChatListTableCell.self,
                                        kCellHeightKey: FriendsChatListTableCell.height
                                    ])
                                } else {
                                    ChatRepository().removeChatWithID(id: chat.chatId) { model in
                                        
                                    }
                                }
                            }
                        }
                        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
                        DispatchQueue.main.async {
                            if cellData.count != .zero {
                                self._tableView.loadData(cellSectionData)
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func _loadData() {
        self.updateUnreadStatus()
        if isRingMember || APPSESSION.userDetail?.isPromoter == true {
            if _selectedIndex == 2 {
                _loadGroupChatListData(bucketList: _bucketList, eventList: _eventList, outingList: _outingList)
            } else if _selectedIndex == 1 {
                _loadChatList()
                _loadCMChatListData(eventList: _cmChatList, chatList: _chatList)
            } else {
                _loadChatList()
            }
        } else {
            if _selectedIndex == 1 {
                _loadGroupChatListData(bucketList: _bucketList, eventList: _eventList, outingList: _outingList)
            } else {
                _loadChatList()
            }
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _requestFollowersList() {
        WhosinServices.getFollowingList(id: APPSESSION.userDetail?.id ?? kEmptyString) { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container?.data else { return }
            self.didLoad = true
            self.hideHUD(error: error)
            APPSETTING.followingList = data
        }
    }

    private var _prototype: [[String: Any]]? {
        return [
                [kCellIdentifierKey: kCellIdentifierStoryView, kCellNibNameKey: kCellIdentifierStoryView, kCellClassKey: ChatStoryViewCell.self, kCellHeightKey: ChatStoryViewCell.height],
                [kCellIdentifierKey: kCellIdentifierFriendChatList, kCellNibNameKey: kCellIdentifierFriendChatList, kCellClassKey: FriendsChatListTableCell.self, kCellHeightKey: FriendsChatListTableCell.height],
                [kCellIdentifierKey: kCellIdentifierBucketChatList, kCellNibNameKey: kCellIdentifierBucketChatList, kCellClassKey: BucketChatListTableCell.self, kCellHeightKey: BucketChatListTableCell.height],
                [kCellIdentifierKey: kCellIdentifierLoading, kCellNibNameKey: kCellIdentifierLoading, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height],
                [kCellIdentifierKey: kCellIdentifierEventChatList, kCellNibNameKey: kCellIdentifierEventChatList, kCellClassKey: EventChatListTableCell.self, kCellHeightKey: EventChatListTableCell.height],
        ]
    }
    
    private func _deleteChatEvent(chatId: String?) {
        guard let chatId = chatId else { return }
        confirmAlert(message: "delete_chat_confirmation".localized(),okHandler: { okAction in
            self._requestDeleteChat(chatId: chatId)
            let repo = ChatRepository()
            repo.removeChatWithID(id: chatId, callback: { model in
                DISPATCH_ASYNC_MAIN_AFTER(0.2) {
                    if self._selectedIndex == 0 {
                        self._loadData()
                    } else {
                        self._requestBucketList()
                    }
                }
                self._deleteView.isHidden = true
                self._confirmationView.isHidden = true
            })
        }, noHandler:  { action in
        })
        _confirmationView.isHidden = true
    }
    
    @IBAction private func _handleCancelEvent(_ sender: UIButton) {
    }
    
    @IBAction private func _handleDeleteEvent(_ sender: UIButton) {
        _confirmationView.isHidden = false
    }
    
    @IBAction func _handleConfirmDeleteEvent(_ sender: UIButton) {
        guard let indexs = _tableView.indexPathsForSelectedRows else { return }
        let repo = ChatRepository()
        indexs.forEach { IndexPath in
            repo.removeChatWithID(id: _chatList?[IndexPath.row].chatId ?? kEmptyString) { model in
                if model ?? false {
                    if self._selectedIndex == 0 {
                        self._loadData()
                    } else {
                        self._requestBucketList()
                    }
                    self._deleteView.isHidden = true
                    self._confirmationView.isHidden = true
                }
            }
        }
    }
            
    @IBAction private func _handleCloseDeleteView(_ sender: UIButton) {
        _confirmationView.isHidden = true
    }
    
    @IBAction private func _handleChatAddEvent(_ sender: UIButton) {
    }
    
    @objc func handleNotification(_ notification: Notification) {
        if isRingMember {
            if _selectedIndex == 1 {
                _requestCMEventChatList()
            } else if _selectedIndex == 2 {
                _requestBucketList()
            } else {
                _loadData()
            }
        } else if APPSESSION.userDetail?.isPromoter == true {
            if _selectedIndex == 1 {
                _requestChatList()
            } else if _selectedIndex == 2 {
                _requestBucketList()
            } else {
                _loadData()
            }
        } else {
            if _selectedIndex == 1 {
                _requestBucketList()
            } else {
                _loadData()
            }
        }
    }
    
    @objc func handleUpdateNotification(_ notification: Notification) {
        if isRingMember {
            if _selectedIndex == 1 {
                _requestCMEventChatList()
            } else if _selectedIndex == 2 {
                _requestBucketList()
            } else {
                if _searchBar.text?.isEmpty == true {
                    self._loadChatListData(chat: _chatList)
                } else {
                    filteredChatList = _chatList?.filter({ $0.user?.fullName.localizedCaseInsensitiveContains(_searchBar.text ?? "") ?? false }) ?? []
                    self._loadChatListData(chat: filteredChatList)
                }
            }
        } else if APPSESSION.userDetail?.isPromoter == true {
            if _selectedIndex == 1 {
                _requestChatList()
            } else if _selectedIndex == 2 {
                _requestBucketList()
            } else {
                if _searchBar.text?.isEmpty == true {
                    self._loadChatListData(chat: _chatList)
                } else {
                    filteredChatList = _chatList?.filter({ $0.user?.fullName.localizedCaseInsensitiveContains(_searchBar.text ?? "") ?? false }) ?? []
                    self._loadChatListData(chat: filteredChatList)
                }
            }
        } else {
            if _selectedIndex == 1 {
                _requestBucketList()
            } else {
                if _searchBar.text?.isEmpty == true {
                    self._loadChatListData(chat: _chatList)
                } else {
                    filteredChatList = _chatList?.filter({ $0.user?.fullName.localizedCaseInsensitiveContains(_searchBar.text ?? "") ?? false }) ?? []
                    self._loadChatListData(chat: filteredChatList)
                }
            }
        }

    }
    
    @objc func handleNotificationCount(_ notification: Notification) {
        self.updateUnreadStatus()
    }
    
    @objc func handleReloadFollowingList(_ notification: Notification) {
        _requestFollowersList()
    }
    
}

extension ChatHomeVC: CustomTableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? FriendsChatListTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? ChatModel, let user = cellDict?[kCellItemsKey] as? UserDetailModel else { return }
            cell.setupChatData(object, user: user)
        } else if let cell = cell as? BucketChatListTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? BucketDetailModel else { return }
            cell.setupData(object)
        } else if let cell = cell as? EventChatListTableCell {
            if let object = cellDict?[kCellObjectDataKey] as? EventModel {
                cell.setupData(object)
            } else if let object = cellDict?[kCellObjectDataKey] as? OutingListModel {
                cell.setupoutingData(object)
            }
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {

        if let _tmpChatModel = cellDict?[kCellObjectDataKey] as? ChatModel {
            guard let userDetail = APPSESSION.userDetail else { return }
            let id = Preferences.isSubAdmin ? userDetail.promoterId : userDetail.id
            let userId = _tmpChatModel.members.first { $0 != id } ?? kEmptyString
            let userModel = UserRepository().getUserById(userId: userId)
            _tmpChatModel.title = userModel?.fullName ?? kEmptyString
            _tmpChatModel.image = userModel?.image ?? kEmptyString
            _openChat(_tmpChatModel, chatType: .user)
        } else if let object = cellDict?[kCellObjectDataKey] as? BucketDetailModel {
            let _tmpChatModel = ChatModel()
            _tmpChatModel.chatId = object.id
            _tmpChatModel.chatType = "bucket"
            _tmpChatModel.title = object.name
            _tmpChatModel.image = object.coverImage
            let sharedUser = object.sharedWith.map({ $0.id })
            _tmpChatModel.members.append(objectsIn: sharedUser)
            if !_tmpChatModel.members.contains(where: {$0 == object.userId}) {
                _tmpChatModel.members.append(object.userId)
            }
            if let userDetail = APPSESSION.userDetail {
                if !_tmpChatModel.members.contains(where: { $0 == userDetail.id }) {
                    _tmpChatModel.members.append(userDetail.id)
                }
            }
            _openChat(_tmpChatModel, chatType: .bucket)
        } else if let object = cellDict?[kCellObjectDataKey] as? EventModel {
            let _tmpChatModel = ChatModel()
            _tmpChatModel.chatId = object.id
            _tmpChatModel.chatType = "event"
            _tmpChatModel.title = object.chatName
            _tmpChatModel.image = object.image
            let members = object.invitedUsers.map({ $0.userId })
            _tmpChatModel.members.append(objectsIn: members)
            if let userDetail = APPSESSION.userDetail {
                if !_tmpChatModel.members.contains(where: { $0 == userDetail.id }) {
                    _tmpChatModel.members.append(userDetail.id)
                }
            }
            _openChat(_tmpChatModel, chatType: .event)
        } else if let object = cellDict?[kCellObjectDataKey] as? OutingListModel {
            let _tmpChatModel = ChatModel()
            _tmpChatModel.chatId = object.id
            _tmpChatModel.chatType = "outing"
            _tmpChatModel.title = object.chatName
            _tmpChatModel.image = object.venue?.cover ?? kEmptyString
            let users = object.invitedUser.map({ $0.id })
            _tmpChatModel.members.append(objectsIn: users)
            if !_tmpChatModel.members.contains(where: {$0 == object.userId}) {
                _tmpChatModel.members.append(object.userId)
            }
            if let userDetail = APPSESSION.userDetail {
                if !_tmpChatModel.members.contains(where: { $0 == userDetail.id }) {
                    _tmpChatModel.members.append(userDetail.id)
                }
            }
            _openChat(_tmpChatModel, chatType: .outing, outing: object)
        } else if let object = cellDict?[kCellObjectDataKey] as? PromoterChatListModel {
            let chatModel = ChatModel()
            chatModel.image = object.owner?.image ?? kEmptyString
            chatModel.title = object.owner?.fullName ?? kEmptyString
            chatModel.chatId = object.id
            chatModel.chatType = ChatType.promoterEvent.rawValue
            let members = object.inUsers.map({ $0.userId })
            chatModel.members.append(objectsIn: members)
            if let userDetail = object.owner {
                if !chatModel.members.contains(where: { $0 == userDetail.id }) {
                    chatModel.members.append(userDetail.id)
                }
            }
            DISPATCH_ASYNC_MAIN_AFTER(0.01) {
                let vc = INIT_CONTROLLER_XIB(ChatDetailVC.self)
                vc.chatModel = chatModel
                vc.isComplementry = APPSESSION.userDetail?.isRingMember ?? false
                vc.isPromoter = APPSESSION.userDetail?.isPromoter ?? false
                vc.venueName = object.venueName
                vc.venueImage = object.venueImage
                if let navController = self.navigationController {
                    vc.hidesBottomBarWhenPushed = true
                    navController.pushViewController(vc, animated: true)
                } else {
                    vc.modalPresentationStyle =  .overFullScreen
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, cellDict: [String : Any]?, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if _selectedIndex == 0 {
            guard let object = cellDict?[kCellObjectDataKey] as? ChatModel else { return nil }
            let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (action, view, completionHandler) in
                guard let self = self else { return }
                self._deleteChatEvent(chatId: object.chatId)
                completionHandler(true)
            }
            deleteAction.image = UIImage(named: "icon_delete")
            deleteAction.backgroundColor = ColorBrand.brandgradientPink
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            configuration.performsFirstActionWithFullSwipe = false
            return configuration
        }
        return UISwipeActionsConfiguration()
    }
    
    
    func refreshData() {
        _tableView.startRefreshing()
        DISPATCH_ASYNC_MAIN_AFTER(0.3) {
            self._loadData()
            self._tableView.endRefreshing()
            if APPSESSION.userDetail?.isPromoter == true {
                self._requestChatList()
            } else if self.isRingMember {
                self._requestCMEventChatList()
            }
        }
    }
    
    func _openChat(_ chatModel: ChatModel, chatType: ChatType = .user, outing: OutingListModel? = nil) {
        let vc = INIT_CONTROLLER_XIB(ChatDetailVC.self)
        vc.chatModel = chatModel
        vc.chatType = chatType
        vc.outingmodel = outing
        if let navController = self.navigationController {
            vc.hidesBottomBarWhenPushed = true
            navController.pushViewController(vc, animated: true)
        } else {
            vc.modalPresentationStyle =  .overFullScreen
            present(vc, animated: true, completion: nil)
        }
    }
}

extension ChatHomeVC: ChatTableHeaderViewDelegate {
    
    func didSelectTab(at index: Int) {
        _selectedIndex = index
        _searchBar.searchTextField.placeholder = index == 0 ? "find_friends".localized() : "find_groups".localized()
        _addChatBtn.isHidden = index != 0
        _loadingChat()
        _loadData()
    }
    
}

extension ChatHomeVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            if isPromoter || isRingMember {
                if _selectedIndex == 1 {
                    _loadCMChatListData(eventList: _cmChatList, chatList: _chatList)
                } else if _selectedIndex == 2 {
                    _loadGroupChatListData(bucketList: _bucketList, eventList: _eventList, outingList: _outingList)
                } else {
                    _loadChatListData(chat: _chatList)
                }
            } else {
                if _selectedIndex == 1 {
                    _loadGroupChatListData(bucketList: _bucketList, eventList: _eventList, outingList: _outingList)
                } else {
                    _loadChatListData(chat: _chatList)
                }
            }
        } else {
            isSearching = true
            if _selectedIndex == 1 {
                if isRingMember || isPromoter {
                    _filteredCMChatList = _cmChatList.filter({ $0.venueName.localizedCaseInsensitiveContains(searchText) })
                    filteredChatList = _chatList?.filter({ ($0.user?.fullName.localizedCaseInsensitiveContains(searchText) ?? false) && $0.user?.isPromoter == true }) ?? []
                    _loadCMChatListData(eventList: _filteredCMChatList, chatList: filteredChatList)
                } else {
                    filteredBucketList = _bucketList?.filter({ $0.name.localizedCaseInsensitiveContains(searchText) }) ?? []
                    filteredEventList = _eventList?.filter({ $0.title.localizedCaseInsensitiveContains(searchText) }) ?? []
                    filteredOutingList = _outingList?.filter({ $0.title.localizedCaseInsensitiveContains(searchText) }) ?? []
                    _loadGroupChatListData(bucketList: filteredBucketList, eventList: filteredEventList, outingList: filteredOutingList)
                }
            } else if _selectedIndex == 2 {
                filteredBucketList = _bucketList?.filter({ $0.name.localizedCaseInsensitiveContains(searchText) }) ?? []
                filteredEventList = _eventList?.filter({ $0.title.localizedCaseInsensitiveContains(searchText) }) ?? []
                filteredOutingList = _outingList?.filter({ $0.title.localizedCaseInsensitiveContains(searchText) }) ?? []
                _loadGroupChatListData(bucketList: filteredBucketList, eventList: filteredEventList, outingList: filteredOutingList)
            } else {
                filteredChatList = _chatList?.filter({ $0.user?.fullName.localizedCaseInsensitiveContains(searchText) ?? false }) ?? []
                _loadChatListData(chat: filteredChatList)
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}
