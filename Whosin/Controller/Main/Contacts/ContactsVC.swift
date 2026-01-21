import UIKit
import MessageUI

class ContactsVC: ProfileBaseMainVC {
    
    @IBOutlet private weak var _tableView: CustomNoKeyboardTableView!
    @IBOutlet private weak var _searchBar: UISearchBar!
    private let kCellIdentifier = String(describing: ContactsTableCell.self)
    var filteredDataInvite: [UserDetailModel] = []
    var filteredDataContact: [UserDetailModel] = []
    private var _selectedContacts: [UserDetailModel] = []
    private var _selectedIndexpath: [Int] = []
    var isSearching = false
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            if !self.didLoad { self.showHUD() }
            self._requestContactList()
        }
    }
    
    override func setupUi() {
        hideNavigationBar()
//        hideLeftBarButton(true)
//        setTitle(title: "Contacts")
        _tableView.setup(
            cellPrototypes: _prototypes,
            hasHeaderSection: true,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            emptyDataText: kEmptyString,
            emptyDataIconImage: UIImage(named: "empty_following"),
            emptyDataDescription: "your_friends_list".localized(),
            delegate: self)
        _tableView.showsVerticalScrollIndicator = false
        _tableView.isScrollEnabled = false
        _tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: kCollectionDefaultMargin, right: 0)
        _searchBar.delegate = self
        _searchBar.searchTextField.backgroundColor = UIColor(white: 1, alpha: 0.08)
        _searchBar.searchTextField.layer.cornerRadius = 18
        _searchBar.searchTextField.layer.masksToBounds = true
        _searchBar.searchTextField.textColor = .white

        NotificationCenter.default.addObserver(self, selector:  #selector(handleContacts), name: kReloadContacts, object: nil)
    }
    
    
//    override var customTableView: CustomNoKeyboardTableView? { _tableView }
    
    // --------------------------------------
    // MARK: Services
    // --------------------------------------
    
    private func _requestContactList() {
//        WHOSINCONTACT.sync { [weak self] error in
//            guard let self = self else { return }
//            self.didLoad = true
//            self.hideHUD(error: error)
//            self._loadData()
//        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        if isSearching {
            filteredDataContact.forEach { contact in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: contact.id,
                    kCellObjectDataKey: contact,
                    kCellStatusKey: false,
                    kCellClassKey: ContactsTableCell.self,
                    kCellHeightKey: ContactsTableCell.height
                ])
            }
            if cellData.count != .zero {
                cellSectionData.append([kSectionTitleKey: "Friends on WhosIN", kSectionDataKey: cellData])
            }
            
            cellData.removeAll()
            filteredDataInvite.forEach { contact in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: contact.id,
                    kCellObjectDataKey: contact,
                    kCellStatusKey: true,
                    kCellClassKey: ContactsTableCell.self,
                    kCellHeightKey: ContactsTableCell.height
                ])
            }
            
            if cellData.count != .zero {
                cellSectionData.append([kSectionIdentifierKey :1,kSectionTitleKey: "Invite your friends",kSectionShowRightInforAsActionButtonKey: true,kSectionRightTextBgColor: ColorBrand.brandGreen, kSectionRightInfoKey :"Invite(\(_selectedContacts.count))", kSectionDataKey: cellData])
            }
            
        } else {
            WHOSINCONTACT.contactList.forEach { contact in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey:  contact.id,
                    kCellObjectDataKey: contact,
                    kCellStatusKey: false,
                    kCellClassKey: ContactsTableCell.self,
                    kCellHeightKey: ContactsTableCell.height
                ])
            }
            
            if cellData.count != .zero {
                cellSectionData.append([kSectionTitleKey: "Friends on WhosIN", kSectionDataKey: cellData])
            }
            
            cellData.removeAll()
            WHOSINCONTACT.inviteContactList.forEach { contact in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: contact.id,
                    kCellObjectDataKey: contact,
                    kCellStatusKey: true,
                    kCellClassKey: ContactsTableCell.self,
                    kCellHeightKey: ContactsTableCell.height
                ])
            }
            cellSectionData.append([kSectionIdentifierKey :1,kSectionTitleKey: "Invite your friends",kSectionShowRightInforAsActionButtonKey: true,kSectionRightTextBgColor: ColorBrand.brandGreen, kSectionRightInfoKey :"Invite(\(_selectedContacts.count))", kSectionDataKey: cellData])
        }
        
        self._tableView.loadData(cellSectionData)
        
        
    }
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: String(describing: ContactsTableCell.self), kCellClassKey: ContactsTableCell.self, kCellHeightKey: ContactsTableCell.height] ]
    }
    
    @objc func handleContacts() {
        _requestContactList()
    }
    
}


extension ContactsVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            _loadData()
        } else {
            isSearching = true
            filteredDataContact = WHOSINCONTACT.contactList.filter({ $0.firstName.localizedCaseInsensitiveContains(searchText) || $0.lastName.localizedCaseInsensitiveContains(searchText) || $0.phone.localizedCaseInsensitiveContains(searchText) })
            filteredDataInvite = WHOSINCONTACT.inviteContactList.filter({ $0.firstName.localizedCaseInsensitiveContains(searchText) || $0.lastName.localizedCaseInsensitiveContains(searchText) || $0.phone.localizedCaseInsensitiveContains(searchText) })
            _loadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}

extension ContactsVC: CustomNoKeyboardTableViewDelegate {
    
    // --------------------------------------
    // MARK: <CustomTableViewDelegate>
    // --------------------------------------
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? ContactsTableCell,
              let model = cellDict?[kCellObjectDataKey] as? UserDetailModel,
              let isInvite = cellDict?[kCellStatusKey] as? Bool else { return }
        let selectedContact = isSearching ? filteredDataInvite[indexPath.row] : WHOSINCONTACT.inviteContactList[indexPath.row]
        let isSelected = _selectedContacts.contains(selectedContact)
        cell.setupData(model, isInvite: isInvite, isSelected: isSelected)
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String: Any]?, indexPath: IndexPath) {
        if sectionTitle == "Invite your friends"  {
            let selectedContact = isSearching ? filteredDataInvite[indexPath.row] : WHOSINCONTACT.inviteContactList[indexPath.row]
            if _selectedContacts.contains(selectedContact) {
                if let index = _selectedContacts.firstIndex(of: selectedContact) {
                    _selectedContacts.remove(at: index)
                }
            } else {
                _selectedContacts.append(selectedContact)
            }
            _loadData()
        } else {
            let user = WHOSINCONTACT.contactList[indexPath.row]
            guard let userDetail = APPSESSION.userDetail, user.id != userDetail.id else { return }
            if user.isPromoter, userDetail.isRingMember {
                let vc = INIT_CONTROLLER_XIB(PromoterPublicProfileVc.self)
                vc.promoterId = user.id
                vc.isFromPersonal = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else if user.isRingMember, userDetail.isPromoter {
                let vc = INIT_CONTROLLER_XIB(ComplementaryPublicProfileVC.self)
                vc.complimentryId = user.id
                vc.isFromPersonal = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = INIT_CONTROLLER_XIB(UsersProfileVC.self)
                vc.contactId = user.id
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func handleHeaderActionEvent(section: Int, identifier: Int) {
        var contact = WHOSINCONTACT.inviteContactList.filter { whosinContact in
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScroll(scrollView)
    }
    
}

extension ContactsVC : MFMessageComposeViewControllerDelegate{
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
