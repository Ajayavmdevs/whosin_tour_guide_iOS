import UIKit
import IQKeyboardManagerSwift

class ViewAllHighlightsVC: ChildViewController {

    @IBOutlet weak var bottomConatraint: NSLayoutConstraint!
    @IBOutlet private weak var _tableView: CustomTableView!
    @IBOutlet weak var _visualEffectView: UIVisualEffectView!
    @IBOutlet private weak var _orgAddress: UILabel!
    @IBOutlet private weak var _orgName: UILabel!
    @IBOutlet private weak var _orgLogoView: UIImageView!
    @IBOutlet private weak var _msgTextField: LeftSpaceTextField!
    private let kLoadingCellIdentifire = String(describing: LoadingCell.self)
    private let kCellIdentifierHighlights = String(describing: HighlightsCell.self)
    public var eventModel: EventModel?
    public var userModel: [UserDetailModel]?
    private var highLightsList: HighlightsListModel?
    public var chatModel: ChatModel?
    private let chatRepository = ChatRepository()
    private var _page: Int = 1
    private var _msgList: [MessageModel] = []

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        getChatMessage()
        setupUi()
    }

    override func setupUi() {
        _orgName.text = eventModel?.orgData?.name
        _orgAddress.text = eventModel?.orgData?.address
        _orgLogoView.loadWebImage(eventModel?.orgData?.logo ?? kEmptyString)
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: kEmptyString,
            emptyDataIconImage: UIImage(named: "empty_bucketChat"),
            emptyDataDescription: nil,
            delegate: self)
        _tableView.proxyDelegate = self
        _tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 70, right: 0)
        _visualEffectView.alpha = 0
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------

    private func _requestAddHighlights() {
        guard let _chatModel = chatModel else { return }
        if !Utils.stringIsNullOrEmpty(_msgTextField.text) { return }
        guard let msgText = _msgTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        let msgModel = MessageModel(msg: msgText, chatModel: _chatModel)
        chatRepository.addChatMessage(messageData: msgModel.detached()) { error in
            SOCKETMANAGER.sendMessage(model: msgModel.detached())
            self._msgList.insert(msgModel.detached(), at: 0)
            let newRowIndexPath = IndexPath(row: 0, section: 0)
            self._tableView.beginUpdates()
            self._tableView.insertRows(at: [newRowIndexPath], with: .automatic)
            self._tableView.endUpdates()
        }
        _msgTextField.text = kEmptyString
        getChatMessage()
    }
    
    private func getChatMessage() {
        guard let chatId = eventModel?.id else { return }
        chatRepository.getChatMessages(chatId: chatId, page: _page, limit: 30) { [weak self] container,unReadMsg  in
            guard let self = self else { return }
            guard let data = container else { return }
            self._msgList.removeAll()
            data.forEach { o in
                let tmp = o.detached()
                self._msgList.append(tmp)
            }
            if self._tableView.contentOffset.y <= 10 {
                self._tableView.reloadData()
            }
            self._loadData()
        }
    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _loadData(isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        if isLoading {
            cellData.append([
                kCellIdentifierKey: kLoadingCellIdentifire,
                kCellTagKey: kLoadingCellIdentifire,
                kCellObjectDataKey: "",
                kCellClassKey: LoadingCell.self,
                kCellHeightKey: LoadingCell.height
            ])
        } else {
            _msgList.forEach({ model in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierHighlights,
                    kCellTagKey: kCellIdentifierHighlights,
                    kCellObjectDataKey: model,
                    kCellClassKey: HighlightsCell.self,
                    kCellHeightKey: HighlightsCell.height
                ])
            })
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
        
    }

    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kLoadingCellIdentifire, kCellNibNameKey: kLoadingCellIdentifire, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height],
            [kCellIdentifierKey: kCellIdentifierHighlights, kCellNibNameKey: kCellIdentifierHighlights, kCellClassKey: HighlightsCell.self, kCellHeightKey: HighlightsCell.height]
        ]
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            self.bottomConatraint.constant = keyboardHeight
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        self.bottomConatraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    
    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func _handleOpenEventOrganizer(_ sender: UIButton) {
        let controller = INIT_CONTROLLER_XIB(EventOrganisierVC.self)
        controller.orgId = eventModel?.orgId ?? kEmptyString
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction private func _handleSendHighlightsEvent(_ sender: UIButton) {
        if Utils.stringIsNullOrEmpty(_msgTextField.text) {
            showCustomAlert(title: kAppName,message:"please type highlights for send.",yesButtonTitle: "ok".localized(),noButtonTitle: kEmtpyJsonString) { UIAlertAction in
            }
            return
        }
        _requestAddHighlights()
    }


}

extension ViewAllHighlightsVC: CustomTableViewDelegate, UIScrollViewDelegate, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        let threshold: CGFloat = 20
        if yOffset > threshold {
            UIView.animate(withDuration: 0.50, animations: { [weak self] in
                guard let self = self else { return }
                self._visualEffectView.alpha = 1.0
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.50, animations: { [weak self] in
                guard let self = self else { return }
                self._visualEffectView.alpha = 0.0
            }, completion: nil)
        }
    }
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? HighlightsCell {
            guard let object = cellDict?[kCellObjectDataKey] as? MessageModel else { return }
            cell.setupMessageData(object)
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
    }
    
}
