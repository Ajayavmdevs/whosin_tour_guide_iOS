import UIKit

class ResetPasswordVC: BaseViewController {
    
    @IBOutlet private weak var _buttonBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var _subtitleLabel: UILabel!
    @IBOutlet private weak var _titleLabel: UILabel!
    @IBOutlet private weak var _confirmPasswdTextField: CustomTextField!
    @IBOutlet  private weak var _enterPasswdTextField: CustomTextField!
    @IBOutlet private weak var _nextButton: CustomGradientBorderButton!
    @IBOutlet private weak var _backButton: CustomGradientBorderButton!
    public var isFromResetPassWord: Bool = false
    private var params: [String: Any] = [:]
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }
    
    // --------------------------------------
    // MARK: Puclic Methods
    // --------------------------------------
    
    override func setupUi() {
        _backButton.buttonImage = UIImage(named: "icon_backArrow")
        _nextButton.buttonImage = UIImage(named: "icon_disableNext")
        _nextButton.isEnabled = false
        enableBackgroundImage = true
        _enterPasswdTextField.becomeFirstResponder()
        if isFromResetPassWord {
            _titleLabel.text = "reset_your_password".localized()
            _subtitleLabel.text = "enter_your_new_password".localized()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    // --------------------------------------
    // MARK: Private Mathods
    // --------------------------------------
    
    @objc func keyboardDidShow(notification: Notification) {
        if let frame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let height = frame.cgRectValue.height
            self._buttonBottomConstraint.constant = height
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        self._buttonBottomConstraint.constant = 81
    }
    
    // --------------------------------------
    // MARK: Services
    // --------------------------------------
    
    private func _requestUpdateProfile() {
        showHUD()
        APPSESSION.updateProfile(param: params) { [weak self] isSuccess, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard isSuccess else { return }
            let vc = INIT_CONTROLLER_XIB(SignInNameVC.self)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleHideShowPasswdEvent(_ sender: UIButton) {
        if sender.tag == 1 {
            if _confirmPasswdTextField.isSecureTextEntry {
                _confirmPasswdTextField.isSecureTextEntry = false
                sender.setImage(UIImage(named: "icon_hide"))
            }else {
                _confirmPasswdTextField.isSecureTextEntry = true
                sender.setImage(UIImage(named: "icon_show"))
            }
        }else {
            if _enterPasswdTextField.isSecureTextEntry {
                _enterPasswdTextField.isSecureTextEntry = false
                sender.setImage(UIImage(named: "icon_hide"))
            }else {
                _enterPasswdTextField.isSecureTextEntry = true
                sender.setImage(UIImage(named: "icon_show"))
            }
        }
    }
    
    @IBAction private func _handleConfirmPasswdEvent(_ sender: CustomTextField) {
        if _enterPasswdTextField.text == _confirmPasswdTextField.text {
            _nextButton.buttonImage = UIImage(named: "icon_btnNext")
            _nextButton.isEnabled = true
        } else {
            _nextButton.buttonImage = UIImage(named: "icon_disableNext")
            _nextButton.isEnabled = false
        }
    }
    
    @IBAction private func _backButtonEvent(_ sender: CustomGradientBorderButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func _handleNextButtonEvent(_ sender: CustomGradientBorderButton) {
        if Utils.stringIsNullOrEmpty(_enterPasswdTextField.text!) {
            alert(title: kAppName, message: "please_enter_password".localized())
            return
        }
        
        if Utils.stringIsNullOrEmpty(_confirmPasswdTextField.text!) {
            alert(title: kAppName, message: "enter_confirm_password".localized())
            return
        }
        
        if _enterPasswdTextField.text == _confirmPasswdTextField.text {
            params = ["password": _confirmPasswdTextField.text!]
            if isFromResetPassWord {
                navigationController?.popViewController(animated: true)
            }else {
                _requestUpdateProfile()
            }
        }else {
            alert(title: kAppName, message: "confirm_password_should_same".localized())
            return
        }
    }
    
}
