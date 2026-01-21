import UIKit

class EmailVerifyVC: PanBaseViewController {
    
    @IBOutlet private weak var _titleLabel: UILabel!
    @IBOutlet weak var _descText: UILabel!
    @IBOutlet private weak var _emailTextField: UITextField!
    @IBOutlet private weak var _nextButton: CustomGradientBorderButton!
    @IBOutlet private weak var _backButton: CustomGradientBorderButton!
    @IBOutlet private weak var bottomConatraint: NSLayoutConstraint!
    public var params: [String: Any] = [:]
    var delegate: ActionButtonDelegate?
    public var isUpdateEmail: Bool = false
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }
    
    // --------------------------------------
    // MARK: puclic
    // --------------------------------------
    
    override func setupUi() {
        _backButton.buttonImage = UIImage(named: "icon_backArrow")
        _nextButton.buttonImage = UIImage(named: "icon_disableNext")
        _nextButton.isEnabled = false
        _emailTextField.becomeFirstResponder()
        _titleLabel.text = "Hello \(params["first_name"] ?? ""),What’s your email address?"
        _descText.text = "email_to_unlock_access_to_many_features".localized()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        if isUpdateEmail {
            _titleLabel.text = "want_to_change_your_email_address".localized()
            _descText.text = "please_enter_your_new_email_address".localized()
            _emailTextField.text = APPSESSION.userDetail?.email
        }

    }
    
    @objc func keyboardDidShow(notification: Notification) {
        if let frame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let height = frame.cgRectValue.height
            self.bottomConatraint.constant = height
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        self.bottomConatraint.constant = 81
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------

    private func _requestLinkedEmailPhone(type: String, email: String ,phone: String, countryCode: String) {
        guard let userId = APPSESSION.userDetail?.id else { return }
        showHUD()
        WhosinServices.linkEmailPhone(type: type, phone: phone, email: email, UserId: userId, countryCode: countryCode) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container else { return }
            self.view.makeToast(data.message)
            DISPATCH_ASYNC_MAIN_AFTER(0.2) {
                self._openVeriftyBottomSheet(email: email)
            }
        }
    }

    private func _openVeriftyBottomSheet(email: String) {
        let vc = INIT_CONTROLLER_XIB(VerifyBottomSheet.self)
        vc.isFromEmailVerify = true
        vc.isUpdateUserPhone = true
        vc.email = email
        vc.delegate = self
        self.presentAsPanModal(controller: vc)
    }

    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    
    @IBAction func _handleEditingBegan(_ sender: CustomTextField) {
        _nextButton.buttonImage = UIImage(named: "icon_btnNext")
        _nextButton.isEnabled = true
    }
    
    @IBAction private func _handleBackButtonEvent(_ sender: CustomGradientBorderButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction private func _handleNextEvent(_ sender: CustomGradientBorderButton) {
        if Utils.stringIsNullOrEmpty(_emailTextField.text!) {
            alert(title: kAppName, message: "please_enter_email".localized())
            return
        }
        
        if !Utils.isEmail(emailString: _emailTextField.text!) {
            alert(title: kAppName, message: "invalid_email".localized())
            return
        }
        if isUpdateEmail {
            _requestLinkedEmailPhone(type: "email", email: _emailTextField.text ?? kEmptyString, phone: kEmptyString, countryCode: kEmptyString)
        } else {
            params["email"] = _emailTextField.text!
            let presentedViewController = INIT_CONTROLLER_XIB(AccountCreatedBottomSheet.self)
            presentedViewController.isFromEmailorMobileVerify = true
            presentedViewController.delegate = self
            self.presentAsPanModal(controller: presentedViewController)
        }
    }
    
    @IBAction func _handleSubmitEvent(_ sender: UIButton) {
        if Utils.stringIsNullOrEmpty(_emailTextField.text!) {
            alert(title: kAppName, message: "please_enter_email".localized())
            return
        }
        
        if !Utils.isEmail(emailString: _emailTextField.text!) {
            alert(title: kAppName, message: "invalid_email".localized())
            return
        }
        
        if isUpdateEmail {
            _requestLinkedEmailPhone(type: "email", email: _emailTextField.text ?? kEmptyString, phone: kEmptyString, countryCode: kEmptyString)
        }
    }
    
}

// --------------------------------------
// MARK: Button Action Delegate
// --------------------------------------

extension EmailVerifyVC: ActionButtonDelegate {
    func buttonClicked(_ tag: Int) {
        if tag == 1 {
            dismiss(animated: true) {
                self.delegate?.buttonClicked?(1)
            }
        } else {
            let vc = INIT_CONTROLLER_XIB(SelectDetailsVC.self)
            vc.params = params
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
