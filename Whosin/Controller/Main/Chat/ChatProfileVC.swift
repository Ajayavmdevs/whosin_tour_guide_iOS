import UIKit

class ChatProfileVC: ChildViewController {
    
    @IBOutlet private weak var _tableView: CustomTableView!
    private let kBGCellIdentifier = String(describing: ChangeChatBgTableCell.self)
    private let kMediaCellIdentifier = String(describing: ProfileMediaTableCell.self)
    private let kBlockCellIdentifier = String(describing: BlockTableCell.self)
    public var userId: String?
    public var chatModel: ChatModel?
    public var chatType: ChatType = .user
    private var userModel: UserDetailModel?
    private var _userList: [UserDetailModel]? = []
    private var _mediaCount: Int = 0
    private var footerView: LoadingFooterView?
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
                } else {
                    _tableView.isHidden = true
                    _requestUserProfile(isShowHud: true)
                }
            } else {
                _requestUserProfile(isShowHud: true)
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
    
    private func _loadData(isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        _tableView.isHidden = false
        if let _userModel = userModel {
//            cellData.append([
//                kCellIdentifierKey: kCellIdentifier,
//                kCellTagKey: _userModel.id,
//                kCellObjectDataKey: _userModel,
//                kCellClassKey: ProfileDetailTableCell.self,
//                kCellHeightKey: ProfileDetailTableCell.height
//            ])
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
        
    private var _prototype: [[String: Any]]? {
        return [
//            [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: ProfileDetailTableCell.self, kCellHeightKey: ProfileDetailTableCell.height],
            [kCellIdentifierKey: kBGCellIdentifier, kCellNibNameKey: kBGCellIdentifier, kCellClassKey: ChangeChatBgTableCell.self, kCellHeightKey: ChangeChatBgTableCell.height],
            [kCellIdentifierKey: kMediaCellIdentifier, kCellNibNameKey: kMediaCellIdentifier, kCellClassKey: ProfileMediaTableCell.self, kCellHeightKey: ProfileMediaTableCell.height],
            [kCellIdentifierKey: kBlockCellIdentifier, kCellNibNameKey: kBlockCellIdentifier, kCellClassKey: BlockTableCell.self, kCellHeightKey: BlockTableCell.height]]
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
//            if let cell = cell as? ProfileDetailTableCell {
//                guard let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
//                cell.setup(object)
//                cell._followStack.superview?.isHidden = false
//            } else
            if cell is ChangeChatBgTableCell {
                guard cellDict?[kCellObjectDataKey] is [UserModel] else { return }
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
        } else if cell is BlockTableCell {
            if let action = cellDict?[kCellButtonTitleKey] as? String {
                if action == "Block" {
                    _optionsBottomSheet()
                } else if action == "Report" {
                    _optionsBottomSheet()
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
}
