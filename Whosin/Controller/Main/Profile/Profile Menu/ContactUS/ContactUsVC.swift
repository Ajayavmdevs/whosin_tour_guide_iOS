import UIKit
import DialCountries

class ContactUsVC: ChildViewController, CustomNoKeyboardTableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var _shareTitle: UILabel!
    @IBOutlet private weak var _submitBtn: CustomActivityButton!
    @IBOutlet private weak var _tabsBgView: UIView!
    @IBOutlet private weak var _subjectField: LeftSpaceTextField!
    @IBOutlet private weak var _emailField: UITextField!
    @IBOutlet weak var _editButton: UIButton!
    @IBOutlet weak var _verifyView: GradientView!
    @IBOutlet private weak var _messageFiled: UITextView!
    @IBOutlet private weak var _dailCodeFlag: UILabel!
    @IBOutlet private weak var _phoneNumberField: UITextField!
    @IBOutlet private weak var _phoneExtLable: UILabel!
    @IBOutlet private weak var _headerView: UIView!
    @IBOutlet private weak var _messageView: UIView!
    @IBOutlet private weak var _tableView: CustomNoKeyboardTableView!
    private let kCellIdentifierStoryView = String(describing: InboxCell.self)
    private var _inboxListModel: [InboxListModel] = []
    private var _defaultDialCode: String = "+971"
    private var _defaultCountryFlag: String = "🇦🇪"
    private var _defaultCountryIOS: String = "AE"
    private var _selectedIndex: Int = 0
    private let _imagePicker = UIImagePickerController()
    private var _imgUrl: String = kEmptyString
    private var headerView = ChatTableHeaderView()
    

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: true,
            isShowRefreshing: true,
            emptyDataText: kEmptyString,
            emptyDataIconImage: UIImage(named: "empty_chat"),
            emptyDataDescription: "empty_inbox".localized(),
            delegate: self)
        NotificationCenter.default.addObserver(self, selector: #selector(handleReload), name: Notification.Name("reoadReply"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
        _requestInboxList()
        let headerView = ChatTableHeaderView(frame: _tabsBgView.frame.standardized)
        headerView.delegate = self
        headerView.setupTabLabels(["send_message".localized(),"inbox".localized()])
        self.headerView = headerView
        _tabsBgView.addSubview(self.headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.snp.makeConstraints { make in
            make.edges.equalTo(_tabsBgView)
        }

    }
    
    override func setupUi() {
        setTitle(title: "contact_us".localized())
        _shareTitle.text = LANGMANAGER.localizedString(forKey: "contactusText",arguments: ["value": APPSESSION.userDetail?.firstName ?? ""])
        _phoneNumberField.text = APPSESSION.userDetail?.phone
        _emailField.text = APPSESSION.userDetail?.email
        _phoneExtLable.text = APPSESSION.userDetail?._countryCode
        let countryCode = Utils.getCountryCode(for: APPSESSION.userDetail?._countryCode ?? kEmptyString)
        _dailCodeFlag.text = Utils.getCountyFlag(code: countryCode ?? kEmptyString)
        _defaultCountryIOS = countryCode ?? "AE"
        _messageFiled.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        _messageFiled.delegate = self
        _messageFiled.text = "write_message_placeholder".localized()
        _messageFiled.textColor = UIColor.placeholderText
        
        if APPSESSION.userDetail?.isEmailVerified == 1 {
            _verifyView.isHidden = true
            _editButton.isHidden = false
            _emailField.isEnabled = false
        } else {
            _verifyView.isHidden = false
            _editButton.isHidden = true
            _emailField.isEnabled = true
        }
    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifierStoryView, kCellNibNameKey: kCellIdentifierStoryView, kCellClassKey: InboxCell.self, kCellHeightKey: InboxCell.height]]
    }
    
    private func _loadData() {
        setupUi()
        if _selectedIndex == 0 {
            _messageView.isHidden = false
            _messageFiled.resignFirstResponder()
            _tableView.isHidden = true
        } else {
            _messageView.isHidden = true
            _tableView.isHidden = false
            var cellSectionData = [[String: Any]]()
            var cellData = [[String: Any]]()
            
            _inboxListModel.forEach { replay in
                if let lastMsg = replay.replies.last {
                    replay.lastMessagecreatedAt = lastMsg.createdAt
                }
            }

            let sortedAllChats = _inboxListModel.sorted { Utils.stringToDate($0.lastMessagecreatedAt, format: kStanderdDate) ?? Date() > Utils.stringToDate($1.lastMessagecreatedAt, format: kStanderdDate) ?? Date() }
            
            sortedAllChats.forEach { model in
                cellData.append([
                        kCellIdentifierKey: kCellIdentifierStoryView,
                        kCellTagKey: kCellIdentifierStoryView,
                        kCellObjectDataKey: model,
                        kCellClassKey: InboxCell.self,
                        kCellHeightKey: InboxCell.height
                ])
            }
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
            _tableView.loadData(cellSectionData)

        }
    }
    
    @objc private func handleReload() {
        _requestInboxList()
    }
    
    private func _openEmailBottomSheet() {
        let controller = INIT_CONTROLLER_XIB(EmailVerifyVC.self)
        controller.isUpdateEmail = true
        controller.delegate = self
        self.presentAsPanModal(controller: controller)
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
        
    private func _requestConactUs(){
        _submitBtn.setTitle(kEmptyString)
        _submitBtn.showActivity()
        guard let userData = APPSESSION.userDetail else { return }
        WhosinServices.contactUs(image: userData.image , name: userData.fullName, email: _emailField.text ?? kEmptyString, phone: userData.phone, subject: _subjectField.text ?? kEmptyString, message: _messageFiled.text ?? kEmptyString) {
            [weak self] model, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let model = model else { return }
            self._submitBtn.setTitle("submit".localized())
            self._submitBtn.hideActivity()
            self.showToast(model.message)
            self._emailField.text = kEmptyString
            self._messageFiled.text = kEmptyString
            self._subjectField.text = kEmptyString
            self.headerView.moveSelectIndicator(to: 1)
            self._selectedIndex = 1
            self._loadData()
        }
    }
    
    private func _requestInboxList(_ shouldRefresh: Bool = false){
        WhosinServices.inboxList {
            [weak self] model, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            self._tableView.endRefreshing()
            guard let model = model?.data else { return }
            self._inboxListModel = model
            self._emailField.text = kEmptyString
            self._phoneNumberField.text = kEmptyString
            self._messageFiled.text = kEmptyString
            self._subjectField.text = kEmptyString
            self._loadData()
        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleSubmitRequest(_ sender: UIButton){

        if !Utils.validateEmail(_emailField.text) {
            alert(title: kAppName, message: "invalid_email".localized())
            return
        }
        
        if Utils.stringIsNullOrEmpty(_subjectField.text) {
            alert(title: kAppName, message: "enter_subject".localized())
            return
        }
        
        if Utils.stringIsNullOrEmpty(_messageFiled.text) {
            alert(title: kAppName, message: "enter_message".localized())
            return
        }
        
        if _messageFiled.text == "write_message_placeholder".localized() {
            alert(title: kAppName, message: "enter_message".localized())
            return
        }
        
        if APPSESSION.userDetail?.isEmailVerified == 0 {
            alert(title: kAppName, message: "verify_email_first".localized(), okActionTitle: "proceed".localized()) { UIAlertAction in
                self._openEmailBottomSheet()
            } cancelHandler: { UIAlertAction in
                self.dismiss(animated: true)
            }
            self._submitBtn.hideActivity()
            return
        }
        _requestConactUs()
    }
    
    @IBAction func _handleEditEmailEvent(_ sender: UIButton) {
        _openEmailBottomSheet()
    }
    
    @IBAction private func _handleCountryEvent(_ sender: UIControl) {
        let controller = DialCountriesController(locale: Locale(identifier: "en"))
        controller.delegate = self
        controller.show(vc: self)
    }

    @IBAction private func _handleBackEvent(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}


extension ContactUsVC: CustomTableViewDelegate {
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? InboxCell {
            guard let object = cellDict?[kCellObjectDataKey] as? InboxListModel else { return }
            cell.setupData(object)
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? InboxListModel else { return }
        let vc = INIT_CONTROLLER_XIB(InboxDetailVC.self)
        vc.modalPresentationStyle = .overFullScreen
        vc.titleText = object.subject
        vc.contactUsId = object.id
        vc.repliesList = object.replies.toArrayDetached(ofType: RepliesModel.self).reversed()
        present(vc, animated: true)
    }
    
    func refreshData() {
        _tableView.startRefreshing()
        _requestInboxList()
    }
}

extension ContactUsVC : UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.placeholderText {
            textView.text = ""
            textView.textColor = .white
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "write_message_placeholder".localized()
            textView.textColor = UIColor.placeholderText
        }
    }

}

//extension ContactsVC : UITextFieldDelegate {
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        if textField == _emailField && textField.text?.isEmpty == true {
//            alert(title: kAppName, message: "You need to Verify the Email First.", okActionTitle: "Procced") { UIAlertAction in
//                self._emailBottomSheet()
//            } cancelHandler: { UIAlertAction in
//                self.dismiss(animated: true)
//            }
//        }
//    }
//}

extension ContactUsVC: DialCountriesControllerDelegate {
    
    func didSelected(with country: Country) {
        _dailCodeFlag.text = country.flag
        _phoneExtLable.text = country.dialCode
        _defaultCountryIOS = country.code
    }
}

extension ContactUsVC: ChatTableHeaderViewDelegate {
    func didSelectTab(at index: Int) {
        _selectedIndex = index
        if index == 1 {
            if _inboxListModel.isEmpty {
                showHUD()
            }
            _requestInboxList()
        }
        _loadData()
    }
}

extension ContactUsVC: ActionButtonDelegate {
    func buttonClicked(_ tag: Int) {
        if tag == 1 {
            APPSESSION.getProfile { success, error in
                if success {
                    self.setupUi()
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
}
