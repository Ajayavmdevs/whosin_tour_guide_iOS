import UIKit
import IQKeyboardManagerSwift

class RequirementsBottomSheet: PanBaseViewController {

    @IBOutlet weak var _title: CustomLabel!
    @IBOutlet weak var _textField: LeftSpaceTextField!
    @IBOutlet weak var _button: CustomButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    public var requireTitle: String = "Requirements"
    public var requirementText: String = kEmptyString
    public var callback: ((_ text: String) -> Void)?
    public var isEdit: Bool = false
    public var keyboardType: UIKeyboardType = .default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        DISPATCH_ASYNC_MAIN_AFTER(0.2) {
            self._textField.becomeFirstResponder()
        }
        _title.text = requireTitle
        _textField.text = requirementText
        _textField.keyboardType = keyboardType
        _button.setTitle(isEdit ? "edit".localized() : "create".localized() , for: .normal)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        bottomConstraint.constant = keyboardHeight
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        bottomConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }


    
    @IBAction func _handleSendEvent(_ sender: UIButton) {
        if Utils.stringIsNullOrEmpty(_textField.text) {
            alert(message: "enter_your_text".localized())
            return
        }
        
        guard let text = self._textField.text else {
            self._textField.text = kEmptyString
            alert(message: "enter_your_text".localized())
            return
        }
        
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.callback?(text)
        }
    }
    
}
 
