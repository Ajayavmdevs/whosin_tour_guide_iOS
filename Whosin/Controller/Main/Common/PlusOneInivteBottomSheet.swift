import UIKit
import Alamofire
import MessageUI
import MHLoadingButton

class PlusOneInivteBottomSheet: BaseViewController {
    
    @IBOutlet weak var _selectMinimum: CustomLabel!
    @IBOutlet private weak var _inviteBtn: CustomActivityButton!
    @IBOutlet private weak var _sendViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var _sendView: UIView!
    @IBOutlet private weak var _copylinkBtn: UIButton!
    @IBOutlet private weak var _shareButton: UIButton!
    @IBOutlet private weak var _title: UILabel!
    @IBOutlet private weak var _tableView: CustomTableView!
    @IBOutlet private weak var _searchBar: UISearchBar!
    @IBOutlet private weak var _btnBgView: UIView!
    private let kCellIdentifier = String(describing: PlusOneContactTableCell.self)
    public var filteredDataContact: [UserDetailModel] = []
    private var filteredDataInvite: [UserDetailModel] = []
    private var _selectedContacts: [UserDetailModel] = []
    private var contactList: [UserDetailModel] = []
    public var isSearching = false
    public var isMultiSelect: Bool = false
    private var shareMessage: String = kEmptyString
    public var updateInvite: ((_ users: [UserDetailModel]) -> Void)?
    private var _selectedContact: UserDetailModel?
    public var isEventPlusOne: Bool = false
    public var event: PromoterEventsModel?
    public var groupMembers: [UserDetailModel] = []
    public var inviteSuccessCallback: (() -> Void)?
    public var isMandatoryInvite: Bool = false
    var searchTimer: Timer?
    private var _dataRequest: DataRequest?
    private var searchText: String = kEmptyString
    private var searchActivityIndicator: UIActivityIndicatorView?

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _title.text = "Invite"
        _setupUi()
        shareDynamicLink()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _shareButton.isEnabled = false
        _copylinkBtn.isEnabled = false
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
            emptyDataText: "no_following_users",
            emptyDataIconImage: UIImage(named: "empty_follower"),
            emptyDataDescription: kEmptyString,
            delegate: self)
        _tableView.showsVerticalScrollIndicator = false
        _tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 150, right: 0)
        _searchBar.delegate = self
        _searchBar.searchTextField.backgroundColor = UIColor(white: 1, alpha: 0.08)
        _searchBar.searchTextField.layer.cornerRadius = 18
        _searchBar.searchTextField.layer.masksToBounds = true
        _searchBar.searchTextField.textColor = .white
        isEventPlusOne ? _requestMyGroup() : _requestFollowersList()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadContactData(_ :)), name: kReloadFollowStatus, object: nil)
        addActivityIndicatorToSearchBar()
        if isEventPlusOne {
            _selectMinimum.text = LANGMANAGER.localizedString(forKey: "min_friends_required", arguments: ["value": "\(event?.plusOneQty ?? 0)"])
            if !groupMembers.isEmpty {
                _selectedContacts = groupMembers
            }
            let canInvite = _selectedContacts.count >= (event?.plusOneQty ?? 0)
            _inviteBtn.backgroundColor = canInvite ? ColorBrand.brandPink : ColorBrand.brandGray
            _inviteBtn.isEnabled = canInvite
        }
    }
    
    private func addActivityIndicatorToSearchBar() {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true

        if #available(iOS 13.0, *), let searchTextField = _searchBar.searchTextField as? UIView {
            searchTextField.addSubview(indicator)
            
            NSLayoutConstraint.activate([
                indicator.centerYAnchor.constraint(equalTo: searchTextField.centerYAnchor),
                indicator.trailingAnchor.constraint(equalTo: searchTextField.trailingAnchor, constant: -30)
            ])
        } else {
            _searchBar.addSubview(indicator)

            NSLayoutConstraint.activate([
                indicator.centerYAnchor.constraint(equalTo: _searchBar.centerYAnchor),
                indicator.trailingAnchor.constraint(equalTo: _searchBar.trailingAnchor, constant: -30)
            ])
        }

        searchActivityIndicator = indicator
    }
    // --------------------------------------
    // MARK: Private method
    // --------------------------------------
    
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: PlusOneContactTableCell.self, kCellHeightKey: PlusOneContactTableCell.height] ]
    }
    
    private func _loadData(_ isUpdate: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        if isSearching {
            filteredDataContact.forEach { contact in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellDifferenceContentKey: contact.id,
                    kCellDifferenceIdentifierKey: contact.id.hashValue,
                    kCellTagKey: isEventPlusOne ? isValidUser(contact) : true,
                    kCellObjectDataKey: contact,
                    kCellValuesKey: contactList.contains(where: { $0.id == contact.id}),
                    kCellStatusKey: false,
                    kCellClassKey: PlusOneContactTableCell.self,
                    kCellHeightKey: PlusOneContactTableCell.height
                ])
                
            }
            if cellData.count != .zero {
                cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
            }
        } else {
            contactList.forEach { contact in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellDifferenceContentKey: contact.id,
                    kCellDifferenceIdentifierKey: contact.id.hashValue,
                    kCellTagKey: isEventPlusOne ? isValidUser(contact) : true,
                    kCellObjectDataKey: contact,
                    kCellValuesKey: true,
                    kCellStatusKey: false,
                    kCellClassKey: PlusOneContactTableCell.self,
                    kCellHeightKey: PlusOneContactTableCell.height
                ])
            }
            if cellData.count != .zero {
                cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
            }
            cellData.removeAll()
            
            if !isEventPlusOne {
                WHOSINCONTACT.inviteContactList.forEach { contact in
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifier,
                        kCellDifferenceContentKey: contact.id,
                        kCellDifferenceIdentifierKey: contact.id.hashValue,
                        kCellTagKey: contact.id,
                        kCellObjectDataKey: contact,
                        kCellValuesKey: false,
                        kCellStatusKey: true,
                        kCellClassKey: PlusOneContactTableCell.self,
                        kCellHeightKey: PlusOneContactTableCell.height
                    ])
                }
                if cellData.count != .zero {
                    cellSectionData.append([kSectionTitleKey: "invite_your_friends".localized(), kSectionDataKey: cellData])
                }
            }
        }
        _tableView.loadData(cellSectionData)
    }
    
    private func isValidUser(_ user: UserDetailModel) -> Bool {
        guard let promoterEventModel = event else {
            return false
        }
        
        var age = 0
        if !user.dateOfBirth.isEmpty {
            age = max(Utils.calculateAge(from: user.dateOfBirth) ?? 0, 0)
        }
        
        let genderCondition = promoterEventModel.extraGuestGender.lowercased() == "both" ||
                              promoterEventModel.extraGuestGender.lowercased() == user.gender.lowercased()
        
        var ageCondition = false
        let ageRange = promoterEventModel.extraGuestAge.split(separator: "-")
        if ageRange.count == 2,
           let minAge = Int(ageRange[0].trimmingCharacters(in: .whitespaces)),
           let maxAge = Int(ageRange[1].trimmingCharacters(in: .whitespaces)) {
            ageCondition = (minAge...maxAge).contains(age)
        }
        
        let nationalityCondition = promoterEventModel.extraGuestNationality.lowercased() == "not specified" ||
                                    promoterEventModel.extraGuestNationality.lowercased() == user.nationality.lowercased()
        
        return genderCondition && (
            promoterEventModel.extraGuestType.lowercased() == "anyone" ||
            (ageCondition && nationalityCondition)
        )
    }


    private func _requestSearch(_ text:String, showLoader: Bool = false) {
        searchText = text
        if let request = _dataRequest {
            if !request.isCancelled || !request.isFinished || !request.isSuspended {
                request.cancel()
            }
        }
        
        self._tableView.startRefreshing()
//        if showLoader { searchActivityIndicator?.startAnimating() }
        _dataRequest = WhosinServices.usersSearch(text) { [weak self]  containers, error in
            self?._tableView.endRefreshing()
            self?.hideHUD()
            self?.searchActivityIndicator?.stopAnimating()
            guard let self = self else { return }
            guard let data = containers?.data else { return }
            self.filteredDataContact = data.filter { !$0.isPromoter }
            self._loadData()
        }
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
            self.contactList = data.filter { !$0.isPromoter && ($0.adminStatusOnPlusOne != "accepted" || $0.plusOneStatus != "accepted") }
            self._loadData()
        }
    }
    
    private func _requestMyGroup() {
        WhosinServices.myPlusOneList { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else { return}
            self.contactList = data.filter({ $0.plusOneStatus == "accepted" &&  $0.adminStatusOnPlusOne == "accepted" })
            self._loadData()
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
    
    private func shareDynamicLink() {
        guard let user = APPSESSION.userDetail else { return }
        var params: [String: Any] = [:]
        params["title"] = user.fullName
        params["description"] = user.bio
        params["image"] = user.image
        params["itemId"] = user.id
        params["itemType"] = "PlusOne"

        Utils.generateDynamicLinksForJoinPlusOne(params: params) { [weak self] message, error in
            guard let self = self else { return }
            guard let message = message else { return }
            if !Utils.stringIsNullOrEmpty(message) {
                _shareButton.isEnabled = true
                _copylinkBtn.isEnabled = true
                self.shareMessage = message
            }
        }
    }
    
    private func _requestInvite() {
        guard let id = _selectedContact?.id else { return }
        _inviteBtn.showActivity()
        WhosinServices.invitePlusOneMember(id: id) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            self._inviteBtn.hideActivity()
            guard let data = container else { return }
            NotificationCenter.default.post(name: .reloadMyEventsNotifier, object: nil)
            if data.code == 1 {
                self.showSuccessMessage("invitation_sent".localized(), subtitle: LANGMANAGER.localizedString(forKey: "invitation_sent_subtitle", arguments: ["value":  _selectedContacts.first?.fullName ?? kEmptyString]))
                self._selectedContact = nil
                self.dismiss(animated: true)
            }
        }
    }
    
    private func _requestEventPlusOneInvite() {
        guard let eventId = event?.id else { return }
        let inviteIds = _selectedContacts.map { $0.id }
        _inviteBtn.showActivity()
        WhosinServices.eventInvitePlusOne(eventId: eventId, inviteIds: inviteIds) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            self._inviteBtn.hideActivity()
            guard let data = container else { return }
            NotificationCenter.default.post(name: .reloadMyEventsNotifier, object: nil)
            if data.code == 1 {
                self.showSuccessMessage("invitation_sent".localized(), subtitle: "invitation_sent_success".localized())
                self._selectedContacts.removeAll()
                self.dismiss(animated: true) {
                    self.inviteSuccessCallback?()
                }
            }
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
        if isEventPlusOne {
            if _selectedContacts.isEmpty {
                alert(title: kAppName, message: "please_select_contacts_to_invite".localized())
                return
            }
            if isMandatoryInvite {
                if _selectedContacts.count < event?.plusOneQty ?? 0 {
                    alert(title: kAppName, message: LANGMANAGER.localizedString(forKey: "please_invite_user_alert", arguments: ["value": "\(event?.plusOneQty ?? 0)"]))
                    return
                }
            }
            _requestEventPlusOneInvite()
        } else {
            if _selectedContact == nil {
                alert(title: kAppName, message: "please_select_contacts_to_invite".localized())
                return
            }
            _requestInvite()
        }
    }
    
    @objc func reloadContactData(_ notification: Notification) {
        if isSearching && !Utils.stringIsNullOrEmpty(searchText) {
            _requestSearch(searchText)
        }
    }
    
}

extension PlusOneInivteBottomSheet: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            _loadData()
        } else {
            isSearching = true
            if isEventPlusOne {
                filteredDataContact = contactList.filter({ $0.firstName.localizedCaseInsensitiveContains(searchText) || $0.lastName.localizedCaseInsensitiveContains(searchText) || $0.phone.localizedCaseInsensitiveContains(searchText) })
                filteredDataInvite = WHOSINCONTACT.inviteContactList.filter({ $0.firstName.localizedCaseInsensitiveContains(searchText) || $0.lastName.localizedCaseInsensitiveContains(searchText) || $0.phone.localizedCaseInsensitiveContains(searchText) })
                _loadData()
            } else {
                searchActivityIndicator?.startAnimating()
                _requestSearch(searchText, showLoader: true)
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}


// --------------------------------------
// MARK: CustomCollectionViewDelegate
// --------------------------------------

extension PlusOneInivteBottomSheet: CustomTableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? PlusOneContactTableCell,
              let model = cellDict?[kCellObjectDataKey] as? UserDetailModel,
              let isInvite = cellDict?[kCellStatusKey] as? Bool, let isRingMembers = cellDict?[kCellValuesKey] as? Bool else { return }
        let isFirstRow = indexPath.row == 0
        let lastRow = _tableView.numberOfRows(inSection: indexPath.section) - 1
        let isLastRow = indexPath.row == lastRow
        cell.setPrifileConstraint(lastRow: isLastRow, firstRow: isFirstRow)
        let isSelect = isMultiSelect ? _selectedContacts.contains(where: { $0.id == model.id || $0.userId == model.id }) : (_selectedContact?.id == model.id || _selectedContact?.userId == model.id)
        if let isClickble = cellDict?[kCellTagKey] as? Bool {
            cell._selectImage.alpha = isClickble ? 1.0 : 0.5
            cell._avatarImageView.alpha = isClickble ? 1.0 : 0.5
            cell._titleLabel.textColor = isClickble ? ColorBrand.white : ColorBrand.brandGray
            cell._subtitleLabel.textColor = isClickble ? ColorBrand.white : ColorBrand.brandGray
            cell._notEligibleText.isHidden = isClickble
            cell._btnStack.isHidden = !isClickble
        } else {
            cell._titleLabel.textColor = ColorBrand.white
            cell._subtitleLabel.textColor = ColorBrand.white
            cell._selectImage.alpha = 1.0
            cell._avatarImageView.alpha = 1.0
            cell._notEligibleText.isHidden = true
            cell._btnStack.isHidden = false
        }
        cell.setup(model,isSelected: isSelect, isInvite: isInvite, isRingMember: isRingMembers)
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String: Any]?, indexPath: IndexPath) {
        self.view.endEditing(true)
        guard let cell = cell as? PlusOneContactTableCell, let isClickable = cellDict?[kCellTagKey] as? Bool else { return }
        guard isClickable else { return }
        
        if sectionTitle != "Invite your Friends" {
            let selectedContact = isSearching ? filteredDataContact[indexPath.row] : contactList[indexPath.row]
            
            if isMultiSelect {
                if let index = _selectedContacts.firstIndex(where: { $0.id == selectedContact.id || $0.userId == selectedContact.id }) {
                    _selectedContacts.remove(at: index)
                } else {
                    _selectedContacts.append(selectedContact)
                }
//                _inviteBtn.setTitle(event?.plusOneAccepted == true ? "Invite (\(_selectedContacts.count)/\(event?.plusOneQty ?? 0))" : "Invite")
                let canInvite = _selectedContacts.count >= (event?.plusOneQty ?? 0)
                _inviteBtn.backgroundColor = canInvite ? ColorBrand.brandPink : ColorBrand.brandGray
                _inviteBtn.isEnabled = canInvite
            } else {
                if selectedContact.plusOneStatus == "none" || selectedContact.plusOneStatus.isEmpty {
                    if _selectedContact?.id == selectedContact.id || _selectedContact?.userId == selectedContact.userId {
                        _selectedContact = nil
                    } else {
                        _selectedContact = selectedContact
                    }
                }
            }
            _tableView.reload()
        }
    }

}
