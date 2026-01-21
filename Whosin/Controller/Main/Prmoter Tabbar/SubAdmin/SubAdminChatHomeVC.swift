import UIKit
import RealmSwift
import SDWebImage
import DifferenceKit
import SnapKit

class SubAdminChatHomeVC: ChildViewController {
    
    @IBOutlet private weak var _headerMenuBgView: UIView!
    @IBOutlet private weak var _confirmationView: GradientView!
    @IBOutlet private weak var _tableView: CustomTableView!
    @IBOutlet private weak var _addChatBtn: UIButton!
    @IBOutlet private weak var _deleteView: GradientView!
    @IBOutlet private weak var _visualEffectView: UIVisualEffectView!
    @IBOutlet private   weak var _cancelBtn: UIButton!
    @IBOutlet private weak var _searchBar: UISearchBar!
    private var _selectedIndex: Int = 0
    private let kCellIdentifierFriendChatList = String(describing: FriendsChatListTableCell.self)
    private let kCellIdentifierCMEventChatList = String(describing: EventPromoterChatListTableCell.self)
    private let kCellIdentifierLoading = String(describing: LoadingCell.self)
    private var homeModel: HomeModel?
    private var _chatList: [ChatModel]?
    private var headerView = ChatTableHeaderView()
    private var isSearching = false
    private var filteredChatList: [ChatModel] = []
    private var filteredEventList: [EventModel] = []
    private var _cmChatList: [PromoterChatListModel] = []
    private var _filteredCMChatList: [PromoterChatListModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _loadingChat()
        _tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        let headerView = ChatTableHeaderView(frame: _headerMenuBgView.frame.standardized)
        headerView.delegate = self
        headerView.setupTabLabels(["complimentary".localized(), "Events"])
        self.headerView = headerView
        _headerMenuBgView.addSubview(self.headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.snp.makeConstraints { make in
            make.edges.equalTo(_headerMenuBgView)
        }
        setupUi()
        _loadData()
        _requestFollowersList()
        _requestChatList()
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
        _addChatBtn.isHidden = _selectedIndex == 0 ? false : true
        _setupHeader()
        _loadData()
        _requestChatList()
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
        _addChatBtn.isHidden = _selectedIndex == 0 ? false : true
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
        
        chatRepo.getUnReadMessagesTypeCount(type: "promoter_event") { [weak self] count in
            guard let self = self else { return }
            self.headerView.hideShowUnreadIndicator(at: 1, isHide: count == 0 )
        }
    }
    
    private func _requestCreateChat(_ userModel: UserDetailModel) {
        guard let userDetail = APPSESSION.userDetail else { return }
        let chatModel = ChatModel()
        chatModel.image = userModel.image
        chatModel.title = userModel.fullName
        chatModel.members.append(userModel.userId)
        chatModel.members.append(userDetail.promoterId)
        let chatIds = [userModel.userId, userDetail.promoterId].sorted()
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
    
    private func _requestChatList(_ isReload: Bool = false) {
        if isReload { showHUD() }
        WhosinServices.chatList() { [weak self] container, error in
            guard let self = self else { return }
            self._tableView.endRefreshing()
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self._cmChatList = data
            if _selectedIndex == 1 {
                self._loadCMChatListData(eventList: data)
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
    
    private func _loadCMChatListData(eventList: [PromoterChatListModel]) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        let userRepo = UserRepository()
        
        if !eventList.isEmpty {
            eventList.forEach{ event in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierCMEventChatList,
                    kCellDifferenceIdentifierKey: event.id,
                    kCellDifferenceContentKey: event.hashValue,
                    kCellTagKey: event.id,
                    kCellObjectDataKey: event,
                    kCellClassKey: EventPromoterChatListTableCell.self,
                    kCellHeightKey: EventPromoterChatListTableCell.height
                ])
            }
            if cellData.count != .zero {
                cellSectionData.append([kSectionTitleKey: cellData.isEmpty ? "event_chats".localized() : LANGMANAGER.localizedString(forKey: "event_chat_item", arguments: ["value": "\(cellData.count)"]), kSectionDataKey: cellData, kSectionBgColor: ColorBrand.clear])
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
            guard let id = APPSESSION.userDetail?.promoterId else { return }
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
        if _selectedIndex == 1 {
            _loadCMChatListData(eventList: _cmChatList)
        } else {
            _loadChatList()
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _requestFollowersList() {
        WhosinServices.getFollowingList(id: APPSESSION.userDetail?.promoterId ?? kEmptyString) { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container?.data else { return }
            self.didLoad = true
            self.hideHUD(error: error)
            APPSETTING.followingList = data
        }
    }
    
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierFriendChatList, kCellNibNameKey: kCellIdentifierFriendChatList, kCellClassKey: FriendsChatListTableCell.self, kCellHeightKey: FriendsChatListTableCell.height],
            [kCellIdentifierKey: kCellIdentifierLoading, kCellNibNameKey: kCellIdentifierLoading, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height],
            [kCellIdentifierKey: kCellIdentifierCMEventChatList, kCellNibNameKey: kCellIdentifierCMEventChatList, kCellClassKey: EventPromoterChatListTableCell.self, kCellHeightKey: EventPromoterChatListTableCell.height]
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
                        self._requestChatList()
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
                        self._requestChatList()
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
        let vc = INIT_CONTROLLER_XIB(ContactShareBottomSheet.self)
        vc.onShareButtonTapped = { [weak self] selectedContacts in
            guard let self = self else { return }
            if let user = selectedContacts.first {
                self._requestCreateChat(user)
            }
        }
        vc.isMultiSelect = false
        vc.isFromCreateBucket = true
        vc.isFromChat = false
        vc.chatOpenCallBack = { chatModel in
            let vc = INIT_CONTROLLER_XIB(ChatDetailVC.self)
            vc.chatModel = chatModel
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vc.modalPresentationStyle = .overFullScreen
        navigationController?.present(vc, animated: true)
    }
    
    @objc func handleNotification(_ notification: Notification) {
        if _selectedIndex == 1 {
            _requestChatList()
        } else {
            _loadData()
        }
    }
    
    @objc func handleUpdateNotification(_ notification: Notification) {
        if _selectedIndex == 1 {
            _requestChatList()
        } else {
            if _searchBar.text?.isEmpty == true {
                self._loadChatListData(chat: _chatList)
            } else {
                filteredChatList = _chatList?.filter({ $0.user?.fullName.localizedCaseInsensitiveContains(_searchBar.text ?? "") ?? false }) ?? []
                self._loadChatListData(chat: filteredChatList)
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

extension SubAdminChatHomeVC: CustomTableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? FriendsChatListTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? ChatModel, let user = cellDict?[kCellItemsKey] as? UserDetailModel else { return }
            cell.setupChatData(object, user: user)
        } else if let cell = cell as? EventPromoterChatListTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? PromoterChatListModel else { return }
            cell.setupCMChatData(object)
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        
        if let _tmpChatModel = cellDict?[kCellObjectDataKey] as? ChatModel {
            guard let userDetail = APPSESSION.userDetail else { return }
            let userId = _tmpChatModel.members.first { $0 != userDetail.promoterId} ?? kEmptyString
            let userModel = UserRepository().getUserById(userId: userId)
            _tmpChatModel.title = userModel?.fullName ?? kEmptyString
            _tmpChatModel.image = userModel?.image ?? kEmptyString
            _openChat(_tmpChatModel, chatType: .user)
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
                vc.isComplementry = false
                vc.isPromoter = true
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
            self._requestChatList()
        }
    }
    
    func _openChat(_ chatModel: ChatModel, chatType: ChatType = .user) {
        let vc = INIT_CONTROLLER_XIB(ChatDetailVC.self)
        vc.chatModel = chatModel
        vc.chatType = chatType
        if let navController = self.navigationController {
            vc.hidesBottomBarWhenPushed = true
            navController.pushViewController(vc, animated: true)
        } else {
            vc.modalPresentationStyle =  .overFullScreen
            present(vc, animated: true, completion: nil)
        }
    }
}

extension SubAdminChatHomeVC: ChatTableHeaderViewDelegate {
    
    func didSelectTab(at index: Int) {
        _selectedIndex = index
        _addChatBtn.isHidden = index != 0
        _searchBar.searchTextField.placeholder = index == 0 ? "find_friends".localized() : "find_event".localized()
        _loadingChat()
        _loadData()
    }
    
}

extension SubAdminChatHomeVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            if _selectedIndex == 1 {
                _loadCMChatListData(eventList: _cmChatList)
            } else {
                _loadChatListData(chat: _chatList)
            }
        } else {
            isSearching = true
            if _selectedIndex == 1 {
                _filteredCMChatList = _cmChatList.filter({ $0.venueName.localizedCaseInsensitiveContains(searchText) })
                filteredChatList = _chatList?.filter({ ($0.user?.fullName.localizedCaseInsensitiveContains(searchText) ?? false) && $0.user?.isPromoter == true }) ?? []
                _loadCMChatListData(eventList: _filteredCMChatList)
            }  else {
                filteredChatList = _chatList?.filter({ $0.user?.fullName.localizedCaseInsensitiveContains(searchText) ?? false }) ?? []
                _loadChatListData(chat: filteredChatList)
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}
