import UIKit
import GrowingTextView
import IQKeyboardManagerSwift

class InboxDetailVC: ChildViewController {

    @IBOutlet private weak var _textContainer: UIView!
    @IBOutlet private weak var _messageView: UIView!
    @IBOutlet private weak var _sendButton: UIButton!
    @IBOutlet private weak var _textView: GrowingTextView!
    @IBOutlet private weak var _sendMsgUsrImage: UIImageView!
    @IBOutlet private weak var _titleLabel: UILabel!
    @IBOutlet private weak var _tableView: CustomTableView!
    @IBOutlet private weak var bottomConatraint: NSLayoutConstraint!
    public var titleText: String = kEmptyString
    public var contactUsId: String = kEmptyString
    private let kCoptitorMessageCellIdentifire = String(describing: CompititorMessageCell.self)
    private let kOwnMessageCellIdentifire = String(describing: OwnMessageCell.self)
    public var repliesList:[RepliesModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
        _titleLabel.text = titleText
        DISPATCH_ASYNC_MAIN_AFTER(0.1) {
            self._sendMsgUsrImage.loadWebImage(APPSESSION.userDetail?.image ?? kEmptyString)
            self._sendMsgUsrImage.cornerRadius = self._sendMsgUsrImage.frame.height / 2
            self._messageView.addGradientBorderWithColor(cornerRadius: 20, 2, [UIColor.init(hexString: "4865FF").cgColor,UIColor.init(hexString: "F048FF").cgColor])
        }
        _textView.delegate = self
        _sendButton.isEnabled = !_textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _tableView.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi));
        IQKeyboardManager.shared.enableAutoToolbar = false
        scrollToLastRow()
        _tableView.reload()
        IQKeyboardManager.shared.enable = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    override func setupUi() {
        _requestRead()
        if #available(iOS 15.0, *) { _tableView.sectionHeaderTopPadding = 0 }
        _tableView.delegate = self
        _tableView.dataSource = self
        _tableView.register(UINib(nibName: kCoptitorMessageCellIdentifire, bundle: nil), forCellReuseIdentifier: kCoptitorMessageCellIdentifire)
        _tableView.register(UINib(nibName: kOwnMessageCellIdentifire, bundle: nil), forCellReuseIdentifier: kOwnMessageCellIdentifire)
    }
    
    private func _requestReplyQuery(_ id: String, _ reply: String) {
        _sendButton.isEnabled = false
        WhosinServices.replyContactQuery(reply: reply, conctactUsId: id) { [weak self] model, error in
            guard let self = self else { return }
            guard let data = model else { return }
            if let replies = data.data {
                self.repliesList.insert(replies, at: 0)
                self._tableView.reload()
            }
            self._textView.text = ""
            self._sendButton.isEnabled = false
            self._requestInboxList()
            self.showToast("reply_sent".localized())
            self.scrollToLastRow()
            DISPATCH_ASYNC_MAIN_AFTER(0.05) {
                self._messageView.addGradientBorderWithColor(cornerRadius: 20, 2, [UIColor.init(hexString: "4865FF").cgColor,UIColor.init(hexString: "F048FF").cgColor])
            }
            NotificationCenter.default.post(name: Notification.Name("reoadReply"), object: nil, userInfo: nil)
        }
    }
    
    private func _requestInboxList(){
        WhosinServices.inboxList {
            [weak self] model, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let model = model?.data else { return }
            guard let replies = model.first(where: {$0.id == self.contactUsId})?.replies.toArrayDetached(ofType: RepliesModel.self) else { return }
            self.repliesList = replies.reversed()
            self._tableView.reload()
        }
    }
    
    private func _requestRead() {
        let ids = repliesList.filter { !$0.isRead }.map { $0.id }
        WhosinServices.readContactUs(replyIds: ids) {
            [weak self] model, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            self._tableView.reload()
            NotificationCenter.default.post(name: Notification.Name("reoadReply"), object: nil, userInfo: nil)
        }
    }
    
    private func scrollToLastRow() {
        if !repliesList.isEmpty {
            let indexPath = IndexPath(row: 0, section: 0)
            if self.hasRowAtIndexPath(indexPath: indexPath) { self._tableView.scrollToRow(at: indexPath, at: .top, animated: true) }
        }
    }
    
    func hasRowAtIndexPath(indexPath: IndexPath) -> Bool {
        return indexPath.row < _tableView.numberOfRows(inSection: indexPath.section)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            self.bottomConatraint.constant = keyboardHeight
            let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
            UIView.animate(withDuration: 0.03) {
                self.view.layoutIfNeeded()
            }
            scrollToLastRow()
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        self.bottomConatraint.constant = 0
        let contentInset = UIEdgeInsets.zero
        UIView.animate(withDuration: 0.03) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        dismiss(animated: true)
    }
    
    @IBAction private func _handleSendReplyEvent(_ sender: Any) {
//        if Utils.stringIsNullOrEmpty(_textView.text) {
//            alert(message: "please enter message for reply")
//            return
//        }
        if _textView.text.trim.isEmpty { return }
        let msgText = _textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if msgText.isEmpty { return }
        _requestReplyQuery(repliesList.last?.conctactUsId ?? "", msgText)
    }
}

extension InboxDetailVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repliesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = repliesList[indexPath.row]
        if object.replyBy == "admin" {
            let cell = tableView.dequeueReusableCell(withIdentifier: kCoptitorMessageCellIdentifire, for: indexPath) as! CompititorMessageCell
            cell.setupContactUs(object)
            cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: kOwnMessageCellIdentifire, for: indexPath) as! OwnMessageCell
            cell.setupContactUs(object)
            cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
            return cell
        }
       
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

extension InboxDetailVC : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        DISPATCH_ASYNC_MAIN_AFTER(0.05) {
            self._sendButton.isEnabled = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            self._messageView.addGradientBorderWithColor(cornerRadius: 20, 2, [UIColor.init(hexString: "4865FF").cgColor,UIColor.init(hexString: "F048FF").cgColor])
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        DISPATCH_ASYNC_MAIN_AFTER(0.05) {
            self._messageView.addGradientBorderWithColor(cornerRadius: 22, 2, [UIColor.init(hexString: "4865FF").cgColor,UIColor.init(hexString: "F048FF").cgColor])
        }
    }
    
}
