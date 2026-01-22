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
    private let kCellIdentifierLoading = String(describing: LoadingCell.self)
    private var homeModel: HomeModel?
    private var _chatList: [ChatModel]?
    private var headerView = ChatTableHeaderView()
    private var isSearching = false
    private var filteredChatList: [ChatModel] = []
    
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
        _requestFollowersList()
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
        _loadData()
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
    
    // --------------------------------------
    // MARK: Services
    // --------------------------------------
    
    private func updateUnreadStatus() {
        let chatRepo = ChatRepository()
        chatRepo.getUnReadMessagesTypeCount(type: "friend") { [weak self] count in
            guard let self = self else { return }
            self.headerView.hideShowUnreadIndicator(at: 0, isHide: count == 0 )
        }
        chatRepo.getAllUnReadMessagesCountForGroup() { [weak self] count in
            guard let self = self else { return }
            self.headerView.hideShowUnreadIndicator(at: 1, isHide: count == 0 )
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
                if Preferences.blockedUsers.contains(userModel.id) { return }
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
                                    if Preferences.blockedUsers.contains(userId) { return }
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
        _loadChatList()
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
            [kCellIdentifierKey: kCellIdentifierLoading, kCellNibNameKey: kCellIdentifierLoading, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height],
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
        _loadData()
    }
    
    @objc func handleUpdateNotification(_ notification: Notification) {
        if _searchBar.text?.isEmpty == true {
            self._loadChatListData(chat: _chatList)
        } else {
            filteredChatList = _chatList?.filter({ $0.user?.fullName.localizedCaseInsensitiveContains(_searchBar.text ?? "") ?? false }) ?? []
            self._loadChatListData(chat: filteredChatList)
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
            _loadChatListData(chat: _chatList)
        } else {
            isSearching = true
            filteredChatList = _chatList?.filter({ $0.user?.fullName.localizedCaseInsensitiveContains(searchText) ?? false }) ?? []
            _loadChatListData(chat: filteredChatList)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}
