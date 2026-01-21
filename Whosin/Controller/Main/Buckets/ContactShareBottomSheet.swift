import UIKit
import MessageUI
import MHLoadingButton

class ContactShareBottomSheet: BaseViewController {
    
    @IBOutlet private weak var _title: UILabel!
    @IBOutlet private weak var _tableView: CustomTableView!
    @IBOutlet private weak var _shareView: GradientView!
    @IBOutlet private weak var _searchBar: UISearchBar!
    @IBOutlet private weak var _btnBgView: UIView!
    private let kCellIdentifier = String(describing: ContactsTableCell.self)
    public var bucketId: String = kEmptyString
    public var _bucketDetail: BucketDetailModel?
    public var sharedContactId: [String] = []
    public var isFromCreateBucket: Bool = false
    public var isFromSendGift: Bool = false
    public var onShareButtonTapped: (([UserDetailModel]) -> Void)?
    public var onSelectUserButtonTapped: ((UserDetailModel) -> Void)?
    public var isFromChat: Bool = false
    public var isFromRing: Bool = false
    public var isFromCircle: Bool = false
    public var filteredDataContact: [UserDetailModel] = []
    public var filteredDataFolower: [UserDetailModel] = []
    private var _selectedContacts: [UserDetailModel] = []
    private var contactList: [UserDetailModel] = []
    public var isSearching = false
    public var isMultiSelect: Bool = true
    public var isFromEventDetail = false
    public var eventModel: EventDetailModel?
    public var chatOpenCallBack: ((_ chatModel: ChatModel) -> Void)?
    private var alreadyAddedContactsInEvent: [String] = [APPSESSION.userDetail?.id ?? kEmptyString]
    public var alreadyInCircle: [String] = []
    public var isAddToRing: Bool = false
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _title.text = isFromRing || isFromCircle ? "add_user".localized() : "Contacts"
        if isFromEventDetail {
            if let event = eventModel?.event {
                alreadyAddedContactsInEvent.append(contentsOf: event.admins)
                let invitedGuest = event.invitedGuest.toArrayDetached(ofType: InvitationModel.self).map { $0.userId }
                let inGuest = event.inGuest.toArrayDetached(ofType: InvitationModel.self).map { $0.userId }
                alreadyAddedContactsInEvent.append(contentsOf: invitedGuest)
                alreadyAddedContactsInEvent.append(contentsOf: inGuest)
                alreadyAddedContactsInEvent = Array(Set(alreadyAddedContactsInEvent))
            }
        }
        _setupUi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isFromCreateBucket {
            if !isFromSendGift {
                sharedContactId.removeAll()
            }
            alreadyAddedContactsInEvent.append(_bucketDetail?.userId ?? kEmptyString)
        }
        if isFromCircle {
            _requestRingMember()
        } else {
            _requestContactList()
            _requestFollowersList()
        }
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
            emptyDataText: isFromCircle ? "no_ring_members_available".localized() : "no_users_available".localized(),
            emptyDataIconImage: UIImage(named: "empty_follower"),
            emptyDataDescription: kEmptyString,
            delegate: self)
        _tableView.showsVerticalScrollIndicator = false
        _tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 50, right: 0)
        _searchBar.delegate = self
        if isFromChat {
            _btnBgView.isHidden = true
        } else {
            _shareView.isHidden = isFromChat
            _btnBgView.isHidden = isFromSendGift
            _shareView.isHidden = isFromSendGift
        }
        _searchBar.searchTextField.backgroundColor = UIColor(white: 1, alpha: 0.08)
        _searchBar.searchTextField.layer.cornerRadius = 18
        _searchBar.searchTextField.layer.masksToBounds = true
        _searchBar.searchTextField.textColor = .white
        _btnBgView.isHidden = isFromRing
    }
    
    // --------------------------------------
    // MARK: Private method
    // --------------------------------------
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: String(describing: ContactsTableCell.self), kCellClassKey: ContactsTableCell.self, kCellHeightKey: ContactsTableCell.height] ]
    }
    
    private func _loadData(_ isUpdate: Bool = false) {
        if !isFromCreateBucket {
            if let sharedWith = _bucketDetail?.sharedWith {
                sharedContactId = Array(sharedWith.map { $0.id })
            }
        }
        
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        if isSearching {
//            if !isFromCircle {
                filteredDataFolower.forEach { contact in
                    if !alreadyAddedContactsInEvent.contains(contact.id), !contact.isNameEmpty {
                        cellData.append([
                            kCellIdentifierKey: kCellIdentifier,
                            kCellTagKey: isFromCircle ? contact.userId :contact.id,
                            kCellObjectDataKey: contact,
                            kCellStatusKey: false,
                            kCellClassKey: ContactsTableCell.self,
                            kCellHeightKey: ContactsTableCell.height
                        ])
                    }
                }
                if cellData.count != .zero {
                    cellSectionData.append([kSectionTitleKey: isFromCircle ? "" : "following".localized(), kSectionDataKey: cellData])
                }
//            }
            cellData.removeAll()
            
            filteredDataContact.forEach { contact in
                if !alreadyAddedContactsInEvent.contains(contact.id), !contact.isNameEmpty {
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifier,
                        kCellTagKey: isFromCircle ? contact.userId :contact.id,
                        kCellObjectDataKey: contact,
                        kCellStatusKey: false,
                        kCellClassKey: ContactsTableCell.self,
                        kCellHeightKey: ContactsTableCell.height
                    ])
                }
            }
            if cellData.count != .zero {
                cellSectionData.append([kSectionTitleKey: isFromCircle ? "" : "Friends on WhosIN", kSectionDataKey: cellData])
            }
            
//            cellData.removeAll()
//            filteredDataInvite.forEach { contact in
//                if !alreadyAddedContactsInEvent.contains(contact.id), !contact.isNameEmpty {
//                    cellData.append([
//                        kCellIdentifierKey: kCellIdentifier,
//                        kCellTagKey: contact.id,
//                        kCellObjectDataKey: contact,
//                        kCellStatusKey: true,
//                        kCellClassKey: ContactsTableCell.self,
//                        kCellHeightKey: ContactsTableCell.height
//                    ])
//                }
//            }
//
//            if cellData.count != .zero {
//                cellSectionData.append([kSectionIdentifierKey :1,kSectionTitleKey: "Invite your contacts",kSectionShowRightInforAsActionButtonKey: true,kSectionRightTextBgColor: ColorBrand.brandGreen, kSectionRightInfoKey :"Invite(\(_selectedContacts.count))", kSectionDataKey: cellData])
//            }
            
        } else {
            contactList.forEach { contact in
                if !alreadyAddedContactsInEvent.contains(contact.id), !contact.isNameEmpty {
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifier,
                        kCellTagKey: isFromCircle ? contact.userId :contact.id,
                        kCellObjectDataKey: contact,
                        kCellStatusKey: false,
                        kCellClassKey: ContactsTableCell.self,
                        kCellHeightKey: ContactsTableCell.height
                    ])
                }
            }
            if cellData.count != .zero {
                cellSectionData.append([kSectionTitleKey: isFromCircle ? "" : "following".localized(), kSectionDataKey: cellData])
            }
            
            if !isFromCircle {
                cellData.removeAll()
                
                WHOSINCONTACT.contactList.forEach { contact in
                    if !alreadyAddedContactsInEvent.contains(contact.id), !contact.isNameEmpty {
                        cellData.append([
                            kCellIdentifierKey: kCellIdentifier,
                            kCellTagKey: isFromCircle ? contact.userId : contact.id,
                            kCellObjectDataKey: contact,
                            kCellStatusKey: false,
                            kCellClassKey: ContactsTableCell.self,
                            kCellHeightKey: ContactsTableCell.height
                        ])
                    }
                }
                if cellData.count != .zero {
                    cellSectionData.append([kSectionTitleKey: "Friends on WhosIN", kSectionDataKey: cellData])
                }
            }
            
//            cellData.removeAll()
//            WHOSINCONTACT.inviteContactList.forEach { contact in
//                if !alreadyAddedContactsInEvent.contains(contact.id), !contact.isNameEmpty{
//                    cellData.append([
//                        kCellIdentifierKey: kCellIdentifier,
//                        kCellTagKey: contact.id,
//                        kCellObjectDataKey: contact,
//                        kCellStatusKey: true,
//                        kCellClassKey: ContactsTableCell.self,
//                        kCellHeightKey: ContactsTableCell.height
//                    ])
//                }
//            }
//            cellSectionData.append([kSectionIdentifierKey :1,kSectionTitleKey: "Invite your contacts",kSectionShowRightInforAsActionButtonKey: true,kSectionRightTextBgColor: ColorBrand.brandGreen, kSectionRightInfoKey :"Invite(\(_selectedContacts.count))", kSectionDataKey: cellData])
        }
       _tableView.loadData(cellSectionData)
            
    }
        
    // --------------------------------------
    // MARK: Service method
    // --------------------------------------
    
    private func _requestContactList() {
//        if WHOSINCONTACT.inviteContactList.isEmpty {
//            WHOSINCONTACT.sync { [weak self] error in
//                guard let self = self else { return }
//                self.didLoad = true
//                self.hideHUD(error: error)
//                self._loadData()
//            }
//        } else {
            _loadData()
//        }
        
    }
    
    private func _requestFollowersList() {
        let id = Preferences.isSubAdmin ? APPSESSION.userDetail?.promoterId ?? kEmptyString : APPSESSION.userDetail?.id ?? kEmptyString
        WhosinServices.getFollowingList(id: id) { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container?.data else { return }
            self.didLoad = true
            self.hideHUD(error: error)
            self.contactList = data
            self._loadData()
        }
    }
    
    private func _requestRingMember() {
        showHUD()
        WhosinServices.getMyRingMemberList { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self.contactList = data
            self._loadData()
        }
    }
    
    private func _requestAddToRing(_ id: String) {
        showHUD()
        WhosinServices.addToRingUser(id: id) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container else { return }
            if data.code == 1 {
                self.showSuccessMessage("request_sent_successfully".localized(), subtitle: kEmptyString)
                DISPATCH_ASYNC_MAIN_AFTER(0.2) {
                    self.dismissOrBack()
                }
            }
        }
    }
    
    private func _requestShareBucket(_ userIds: [String]) {
        let ids = userIds.joined(separator: ",")
        WhosinServices.updateBucket(id: bucketId, userIds: ids) { [weak self] container, error in
            guard let self = self else { return }
            if error != nil {
                self.alert(message: error?.localizedDescription)
                return
            }
            guard (container?.data) != nil else { return }
            NotificationCenter.default.post(name: kReloadBucketList, object: nil, userInfo: nil)
            self.dismiss(animated: true) {
                self.parent?.view.makeToast(container?.message)
            }
        }
    }
    
    // --------------------------------------
    // MARK: IBActions Event
    // --------------------------------------
    
    @IBAction private func _handleShareEvent(_ sender: UIButton) {
        self.view.endEditing(true)
        if isFromCircle {
            let selected = contactList.filter { sharedContactId.contains($0.userId) }
            onShareButtonTapped?(selected)
            dismiss(animated: true, completion: nil)
        } else {
            let selectedContactsFromFirstList = WHOSINCONTACT.contactList.filter { sharedContactId.contains($0.id) }
            let selectedContactsFromSecondList = contactList.filter { contact in
                if WHOSINCONTACT.contactList.contains(where: { $0.id == contact.id }) {
                    return false
                } else if sharedContactId.contains(contact.id) {
                    return true
                } else { return false }
            }
            let selectedContacts = selectedContactsFromFirstList + selectedContactsFromSecondList
            if isFromCreateBucket {
                onShareButtonTapped?(selectedContacts)
                dismiss(animated: true, completion: nil)
            } else {
                _requestShareBucket(sharedContactId)
            }
        }
        
    }
    
    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        if self.isVCPresented {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}

extension ContactShareBottomSheet: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            _loadData()
        } else {
            isSearching = true
            filteredDataContact = WHOSINCONTACT.contactList.filter({ $0.firstName.localizedCaseInsensitiveContains(searchText) || $0.lastName.localizedCaseInsensitiveContains(searchText) || $0.phone.localizedCaseInsensitiveContains(searchText) })
//            filteredDataInvite = WHOSINCONTACT.inviteContactList.filter({ $0.firstName.localizedCaseInsensitiveContains(searchText) || $0.lastName.localizedCaseInsensitiveContains(searchText) || $0.phone.localizedCaseInsensitiveContains(searchText) })
            filteredDataFolower = contactList.filter({ $0.firstName.localizedCaseInsensitiveContains(searchText) || $0.lastName.localizedCaseInsensitiveContains(searchText) || $0.phone.localizedCaseInsensitiveContains(searchText) })

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

extension ContactShareBottomSheet: CustomTableViewDelegate {
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? ContactsTableCell,
              let model = cellDict?[kCellObjectDataKey] as? UserDetailModel,
              let isInvite = cellDict?[kCellStatusKey] as? Bool,
              let contactId = cellDict?[kCellTagKey] as? String else { return }
        let isFirstRow = indexPath.row == 0
        let lastRow = _tableView.numberOfRows(inSection: indexPath.section) - 1
        let isLastRow = indexPath.row == lastRow
        cell.setPrifileConstraint(lastRow: isLastRow, firstRow: isFirstRow)
        if isInvite {
//            let selectedContact = isSearching ? filteredDataInvite[indexPath.row] : WHOSINCONTACT.inviteContactList[indexPath.row]
//            let isShared = _selectedContacts.contains(selectedContact)
//            cell.setupData(model, isInvite: isInvite, isSheet: true, isSelected: isShared)
        } else if isFromChat {
            let isShared = sharedContactId.contains(contactId)
            cell.setupData(model, isInvite: isInvite, isSheet: true, isSelected: isShared)
        } else {
            if isFromCircle {
                let isShared = alreadyInCircle.contains(contactId) || sharedContactId.contains(contactId)
                cell.setupData(model, isInvite: isInvite, isSheet: true, isSelected: isShared)
            } else {
                let isShared = sharedContactId.contains(contactId)
                cell.setupData(model, isInvite: isInvite, isSheet: true, isSelected: isShared)
            }
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        self.view.endEditing(true)
        guard let contactId = cellDict?[kCellTagKey] as? String,
              let isInvite = cellDict?[kCellStatusKey] as? Bool else { return }
        if isInvite {
//            let selectedContact = isSearching ? filteredDataInvite[indexPath.row] : WHOSINCONTACT.inviteContactList[indexPath.row]
//            if _selectedContacts.contains(selectedContact) {
//                if let index = _selectedContacts.firstIndex(of: selectedContact) {
//                    _selectedContacts.remove(at: index)
//                }
//            } else {
//                _selectedContacts.append(selectedContact)
//            }
            _loadData()
        } else if isFromSendGift  {
            sharedContactId.removeAll()
            sharedContactId.append(contactId)
            if let selectedContacts = WHOSINCONTACT.contactList.filter({ contactId.contains($0.id) }).first {
                onSelectUserButtonTapped?(selectedContacts)
            } else if let  selectedContacts = contactList.filter({ contactId.contains($0.id) }).first {
                print(selectedContacts)
                onSelectUserButtonTapped?(selectedContacts)
            }
            dismiss(animated: true, completion: nil)
        } else {
            if isMultiSelect {
                if isFromCircle {
                    guard !alreadyInCircle.contains(contactId) else { return }
                }
                if sharedContactId.contains(contactId) {
                    if let index = sharedContactId.firstIndex(of: contactId) {
                        sharedContactId.remove(at: index)
                    }
                } else {
                    sharedContactId.append(contactId)
                }
            } else {
                sharedContactId.removeAll()
                sharedContactId.append(contactId)
                if isFromChat {
                    var selectedContacts = WHOSINCONTACT.contactList.filter { contactId.contains($0.id) }
                    if selectedContacts.isEmpty {
                        selectedContacts = contactList.filter{ contactId.contains($0.id) }
                    }
                    dismiss(animated: true) {
                        self.onShareButtonTapped?(selectedContacts)
                    }
                } else if isFromRing {
                    var selectedContacts = WHOSINCONTACT.contactList.filter { contactId.contains($0.id) }
                    if selectedContacts.isEmpty {
                        selectedContacts = contactList.filter{ contactId.contains($0.id) }
                    }
                    if let id = selectedContacts.first?.id {
                        _requestAddToRing(id)
                    } else {
                        selectedContacts.removeAll()
                    }
                } else {
                    let selectedContactsFromFirstList = WHOSINCONTACT.contactList.filter { contact in
                        !contactList.contains { $0.id == contact.id }
                    }
                    let selectedContactsFromSecondList = contactList.filter { contact in
                        !WHOSINCONTACT.contactList.contains { $0.id == contact.id }
                    }
                    let selectedContacts = selectedContactsFromFirstList + selectedContactsFromSecondList
                    onShareButtonTapped?(selectedContacts)
                    dismiss(animated: true, completion: nil)
                }
            }
        }
        _tableView.reload()
    }
    
    func handleHeaderActionEvent(section: Int, identifier: Int) {
        self.view.endEditing(true)
        let contact = WHOSINCONTACT.inviteContactList.filter { whosinContact in
            return _selectedContacts.contains { selectedContact in
                return whosinContact.phone == selectedContact.phone
            }
        }
        
        let numbers = contact.map { $0.phone }
        if numbers.isEmpty { return }
        guard MFMessageComposeViewController.canSendText() else { return }
        let messageVC = MFMessageComposeViewController()
        messageVC.body = kInviteMessage;
        messageVC.recipients = numbers
        messageVC.messageComposeDelegate = self;
        self.present(messageVC, animated: false, completion: nil)
    }
    
}

extension ContactShareBottomSheet : MFMessageComposeViewControllerDelegate{
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            switch (result.rawValue) {
                case MessageComposeResult.cancelled.rawValue:
                print("Message was cancelled")
                self.dismiss(animated: true, completion: nil)
            case MessageComposeResult.failed.rawValue:
                print("Message failed")
                self.dismiss(animated: true, completion: nil)
            case MessageComposeResult.sent.rawValue:
                print("Message was sent")
                self.dismiss(animated: true, completion: nil)
            default:
                break;
            }
        }
}

