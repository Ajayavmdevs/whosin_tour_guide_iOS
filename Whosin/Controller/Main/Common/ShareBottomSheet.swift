import UIKit
import MessageUI
import MHLoadingButton

class ShareBottomSheet: BaseViewController {
    
    @IBOutlet private weak var _sendViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var _sendView: UIView!
    @IBOutlet private weak var _copylinkBtn: UIButton!
    @IBOutlet private weak var _shareButton: UIButton!
    @IBOutlet private weak var _title: UILabel!
    @IBOutlet private weak var _tableView: CustomTableView!
    @IBOutlet private weak var _searchBar: UISearchBar!
    @IBOutlet private weak var _btnBgView: UIView!
    private let kCellIdentifier = String(describing: SelectContactTableCell.self)
    public var filteredDataContact: [UserDetailModel] = []
    private var _selectedContacts: [UserDetailModel] = []
    private var contactList: [UserDetailModel] = []
    public var messageModel: MessageModel?
    public var ticketModel: TicketModel?
    public var isSearching = false
    public var isMultiSelect: Bool = true
    private var shareMessage: String = kEmptyString
    private var _venueJSON: String = kEmptyString
    private var _userJSON: String = kEmptyString
    private var _offerJSON: String = kEmptyString
    private var _clubJSON: String = kEmptyString
    private var _promoterEventJOSN: String = kEmptyString
    private var _ticketJOSN: String = kEmptyString
    public var isUser: Bool = false
    public var isOffer: Bool = false
    public var isForword: Bool = false
    public var isYachClub: Bool = false
    public var isPromoter: Bool = false
    public var isComplementary: Bool = false
    public var isFromTicket: Bool = false
    public var currentStoryId: String = kEmptyString
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _title.text = "share".localized()
        _setupUi()
        _btnBgView.isHidden = isForword
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _shareButton.isEnabled = false
        _copylinkBtn.isEnabled = false
        _requestFollowersList()
        _requestShareLink(isUser)
    }
    
    // --------------------------------------
    // MARK: SetUp method
    // --------------------------------------
    
    public func _setupUi() {
        _tableView.setup(
            cellPrototypes: _prototypes,
            hasHeaderSection: true,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            emptyDataText: "no_following_users".localized(),
            emptyDataIconImage: UIImage(named: "empty_follower"),
            emptyDataDescription: kEmptyString,
            delegate: self)
        _tableView.showsVerticalScrollIndicator = false
        _tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 50, right: 0)
        _searchBar.searchTextField.backgroundColor = UIColor(white: 1, alpha: 0.08)
        _searchBar.searchTextField.layer.cornerRadius = 18
        _searchBar.searchTextField.layer.masksToBounds = true
        _searchBar.searchTextField.textColor = .white
        _searchBar.delegate = self
        _ticketJOSN = _jsonStringTicketObject() ?? kEmptyString
    }
    
    // --------------------------------------
    // MARK: Private method
    // --------------------------------------
    
    
    
    private func _jsonStringTicketObject() -> String? {
        guard let ticket = ticketModel else { return kEmptyString}
        let model =  ChatTicketModel(model: ticket)
        return model.toJSONString()
    }
        
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: SelectContactTableCell.self, kCellHeightKey: SelectContactTableCell.height] ]
    }
    
    private func _loadData(_ isUpdate: Bool = false) {
        toggleBottomSheet(!_selectedContacts.isEmpty)
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        if isSearching {
            filteredDataContact.forEach { contact in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: contact.id,
                    kCellObjectDataKey: contact,
                    kCellClassKey: SelectContactTableCell.self,
                    kCellHeightKey: SelectContactTableCell.height
                ])
            }
            if cellData.count != .zero {
                cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
            }
        } else {
            contactList.forEach { contact in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: contact.id,
                    kCellObjectDataKey: contact,
                    kCellClassKey: SelectContactTableCell.self,
                    kCellHeightKey: SelectContactTableCell.height
                ])
            }
            if cellData.count != .zero {
                cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
            }        }
        _tableView.loadData(cellSectionData)
    }
    
    // --------------------------------------
    // MARK: Service method
    // --------------------------------------
    
    private func _requestFollowersList() {
        WhosinServices.getFollowingList(id: APPSESSION.userDetail?.id ?? kEmptyString) { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container?.data else { return }
            self.didLoad = true
            self.hideHUD(error: error)
            self.contactList = isComplementary ? data.filter({ $0.isRingMember }) : data
            self._loadData()
        }
    }
    
    
    private func _requestShareLink(_ isUser: Bool) {
        if let ticketModel = ticketModel {
            Utils.generateDynamicLinksTicket(ticketModel: ticketModel) { [weak self] message, error in
                guard let self = self else { return }
                guard let message = message else { return }
                if !Utils.stringIsNullOrEmpty(message) {
                    _shareButton.isEnabled = true
                    _copylinkBtn.isEnabled = true
                    self.shareMessage = message
                }
            }

        }
    }
            
    private func _sendTicketEventHandle() {
        guard let id = APPSESSION.userDetail?.id else { return }
        let chatRepository = ChatRepository()
        if !Utils.stringIsNullOrEmpty(_ticketJOSN) {
            _selectedContacts.forEach { user in
                let chatModel = ChatModel()
                chatModel.image = user.image
                chatModel.title = user.fullName
                chatModel.chatType = "friend"
                chatModel.members.append(user.id)
                chatModel.members.append(id)
                let chatIds = [user.id, id].sorted()
                chatModel.chatId = chatIds.joined(separator: ",")
                let msgModel = MessageModel(msg: _ticketJOSN, chatModel: chatModel, type: MessageType.ticket.rawValue)
                chatRepository.addChatMessage(messageData: msgModel.detached()) {[weak self] error in
                    SOCKETMANAGER.sendMessage(model: msgModel.detached())
                    self?.dismiss(animated: true)
                }
            }
        }
    }
    
    private func _sendForwordEventHandle() {
        guard let id = APPSESSION.userDetail?.id else { return }
        guard let message = messageModel else { return }
        let chatRepository = ChatRepository()
        _selectedContacts.forEach { user in
            let chatModel = ChatModel()
            chatModel.image = user.image
            chatModel.title = user.fullName
            chatModel.chatType = "friend"
            chatModel.members.append(user.id)
            chatModel.members.append(id)
            let chatIds = [user.id, id].sorted()
            chatModel.chatId = chatIds.joined(separator: ",")
            let msgModel = MessageModel(msg: message.msg, chatModel: chatModel, type: message.type)
            chatRepository.addChatMessage(messageData: msgModel.detached()) {[weak self] error in
                SOCKETMANAGER.sendMessage(model: msgModel.detached())
                self?.dismiss(animated: true)
            }
        }
    }
    
    private func _sendStoryEventHandle() {
        guard let id = APPSESSION.userDetail?.id else { return }
        let chatRepository = ChatRepository()
        if !Utils.stringIsNullOrEmpty(_venueJSON) {
            _selectedContacts.forEach { user in
                let chatModel = ChatModel()
                chatModel.image = user.image
                chatModel.title = user.fullName
                chatModel.chatType = "friend"
                chatModel.members.append(user.id)
                chatModel.members.append(id)
                let chatIds = [user.id, id].sorted()
                chatModel.chatId = chatIds.joined(separator: ",")
                let msgModel = MessageModel(msg: _venueJSON, chatModel: chatModel, type: MessageType.story.rawValue)
                chatRepository.addChatMessage(messageData: msgModel.detached()) {[weak self] error in
                    SOCKETMANAGER.sendMessage(model: msgModel.detached())
                    self?.dismiss(animated: true)
                }
            }
        }
    }
        
    private func toggleBottomSheet(_ isShow: Bool = false) {
        if isShow {
            _sendViewHeight.constant = 90
        } else {
            _sendViewHeight.constant = 0
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    // --------------------------------------
    // MARK: IBActions Event
    // --------------------------------------
    
    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        self.view.endEditing(true)
        dismiss(animated: true)
    }
    
    @IBAction func _handleCopyEvent(_ sender: UIButton) {
        if !Utils.stringIsNullOrEmpty(shareMessage) {
            UIPasteboard.general.string = shareMessage
            showToast("link_copied".localized())
        }
    }
    
    @IBAction private func _handleShaeEvent(_ sender: UIButton) {
        if !Utils.stringIsNullOrEmpty(shareMessage) {
            let items = [shareMessage]
            let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
            activityController.setValue(kAppName, forKey: "subject")
            activityController.popoverPresentationController?.sourceView = self.view
            activityController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToTwitter]
            self.present(activityController, animated: true, completion: nil)
        }
    }
    
    @IBAction private func _handleSendEvent(_ sender: UIButton) {
        if _selectedContacts.isEmpty {
            alert(title: kAppName, message: "select_contact_to_share".localized())
            return
        } else {
            if isForword {
                _sendForwordEventHandle()
            } else if isFromTicket {
                _sendTicketEventHandle()
            } else {
                _sendStoryEventHandle()
            }
        }
    }
    
}

extension ShareBottomSheet: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            _loadData()
        } else {
            isSearching = true
            filteredDataContact = contactList.filter({ $0.firstName.localizedCaseInsensitiveContains(searchText) || $0.lastName.localizedCaseInsensitiveContains(searchText) || $0.phone.localizedCaseInsensitiveContains(searchText) })
            _loadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}


// --------------------------------------
// MARK: CustomCollectionViewDelegate
// --------------------------------------

extension ShareBottomSheet: CustomTableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? SelectContactTableCell,
              let model = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
        let isFirstRow = indexPath.row == 0
        let lastRow = _tableView.numberOfRows(inSection: indexPath.section) - 1
        let isLastRow = indexPath.row == lastRow
        cell.setPrifileConstraint(lastRow: isLastRow, firstRow: isFirstRow)
        cell.setup(model)
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        self.view.endEditing(true)
        guard let cell = cell as? SelectContactTableCell else { return }
        let selectedContact = isSearching ? filteredDataContact[indexPath.row] : contactList[indexPath.row]
        if _selectedContacts.contains(selectedContact) {
            if let index = _selectedContacts.firstIndex(of: selectedContact) {
                _selectedContacts.remove(at: index)
            }
        } else {
            _selectedContacts.append(selectedContact)
        }
        let isSelected = _selectedContacts.contains(selectedContact)
        cell.setSelected(isSelected, animated: false)
        toggleBottomSheet(!_selectedContacts.isEmpty)
    }
}
