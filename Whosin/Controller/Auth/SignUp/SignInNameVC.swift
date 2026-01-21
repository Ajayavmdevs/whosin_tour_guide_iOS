import UIKit

class SignInNameVC: ChildViewController {
    
    @IBOutlet private weak var _nextButton: CustomGradientBorderButton!
    @IBOutlet private weak var _backButton: CustomGradientBorderButton!
    @IBOutlet private weak var _firstNameTextField: CustomTextField!
    @IBOutlet private weak var _lastNameTextField: CustomTextField!
    @IBOutlet private weak var bottomConatraint: NSLayoutConstraint!
    @IBOutlet weak var _maleButton: GradientBorderButton!
    @IBOutlet weak var _femaleButton: GradientBorderButton!
    @IBOutlet weak var _preferNotSayButton: GradientBorderButton!
    private var _genderButtons:[UIButton] = []
    private var _gender: String = kEmptyString

    
    
    private var params: [String:Any] = [:]
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
        setupUi()
    }
    
    override func setupUi() {
        _backButton.buttonImage = UIImage(named: "icon_backArrow")
        _nextButton.buttonImage = UIImage(named: "icon_btnNext")
//        _nextButton.isEnabled = false
        _firstNameTextField.delegate = self
        _lastNameTextField.delegate = self
        _firstNameTextField.becomeFirstResponder()
        _genderButtons = [_maleButton, _femaleButton, _preferNotSayButton]

//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

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
    // MARK: Private
    // --------------------------------------
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
//    @IBAction func _handleButtonEnableDisbleEvetn(_ sender: CustomTextField) {
//        if !Utils.stringIsNullOrEmpty(_firstNameTextField.text!) {
//            if Utils.stringIsNullOrEmpty(_lastNameTextField.text!) {
//                _nextButton.buttonImage = UIImage(named: "icon_disableNext")
//                _nextButton.isEnabled = false
//            }else {
//                _nextButton.buttonImage = UIImage(named: "icon_btnNext")
//                _nextButton.isEnabled = true
//            }
//        }
//    }
    
    @IBAction func _handleNextButtonEvent(_ sender: CustomGradientBorderButton) {
        if Utils.stringIsNullOrEmpty(_firstNameTextField.text!) {
            alert(title: kAppName, message: "enter_first_name".localized())
            return
        }
        
        if Utils.stringIsNullOrEmpty(_lastNameTextField.text!) {
            alert(title: kAppName, message: "enter_last_name")
            return
        }
        
        if Utils.stringIsNullOrEmpty(_gender) {
            alert(title: kAppName, message: "please_select_gender".localized())
            return
        }
        
        params["first_name"] = _firstNameTextField.text!
        params["last_name"] = _lastNameTextField.text!
        params["gender"] = _gender
        
        showHUD()
        APPSESSION.updateProfile(param: params) { [weak self] isSuccess, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard isSuccess else { return }
            APPSESSION.moveToHome()
        }
    
        
    }
    @IBAction func _handleSelectGenderEvent(_ sender: GradientBorderButton) {
        if sender.tag == 1 {
            _gender = GenderType.female.rawValue
        } else if sender.tag == 2 {
            _gender = GenderType.preferNotSay.rawValue
        }else {
            _gender = GenderType.male.rawValue
        }
        for button in _genderButtons {
            if sender.tag == button.tag{
                button.isSelected = true;
                button.titleLabel?.font = FontBrand.SFheavyFont(size: 16)
                button.backgroundColor = ColorBrand.brandPink
            }else{
                button.isSelected = false;
                button.titleLabel?.font = FontBrand.SFregularFont(size: 16)
                button.backgroundColor = ColorBrand.white.withAlphaComponent(0.13)
            }
        }
    }
    
    @IBAction func _handleBackEvent(_ sender: CustomGradientBorderButton) {
        guard let window = APP.window else { return }
        let navController = NavigationController(rootViewController: INIT_CONTROLLER_XIB(LoginVC.self))
        navController.setNavigationBarHidden(true, animated: false)
        window.setRootViewController(navController, options: UIWindow.TransitionOptions(direction:.fade, style: .easeInOut))
    }
    
}


extension SignInNameVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Hide the keyboard
        return true
    }
}
