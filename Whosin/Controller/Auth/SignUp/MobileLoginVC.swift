import UIKit
import DialCountries
import libPhoneNumber_iOS

class MobileLoginVC: PanBaseViewController {
    
    @IBOutlet private weak var _titleLabel: UILabel!
    @IBOutlet private weak var _navTitleText: UILabel!
    @IBOutlet private weak var _backButton: CustomGradientBorderButton!
    @IBOutlet private weak var _continueButton: CustomGradientBorderButton!
    @IBOutlet private weak var _descText: UILabel!
    @IBOutlet private weak var _PhoneCodeExtView: UIView!
    @IBOutlet private weak var _lblPhoneExt: UILabel!
    @IBOutlet private weak var _lblCountryName: UILabel!
    @IBOutlet private weak var _txtFieldPhoneNumber: UITextField!
    @IBOutlet private weak var bottomConatraint: NSLayoutConstraint!
    @IBOutlet private weak var _closeButton: UIButton!
    private var _selectedCountry: Country?
    var delegate: ActionButtonDelegate?
    private var _defaultCountryCode: String = "🇦🇪"
    private var _defaultDialCode: String = "+971"
    public var params: [String: Any] = [:]
    public var isUpdatePhone: Bool = false
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
    }
    
    override func setupUi() {
        _selectedCountry = Country.getCurrentCountry()
        _backButton.buttonImage = UIImage(named: "icon_backArrow")
        _continueButton.buttonImage = UIImage(named: "icon_disableNext")
        _continueButton.isEnabled = false
        _txtFieldPhoneNumber.becomeFirstResponder()
        _titleLabel.text = LANGMANAGER.localizedString(forKey: "greeting_mobile_number", arguments: ["value": params["first_name"] as? String ?? ""])
        _lblPhoneExt.text = Utils.getCurrentDialCode()
        _lblCountryName.text = Utils.getcurrentFlag()
        
        if isUpdatePhone {
            _lblPhoneExt.text = Utils.getCurrentDialCode()
            _lblCountryName.text = Utils.getcurrentFlag()
            _txtFieldPhoneNumber.text = APPSESSION.userDetail?.phone
            _backButton.isHidden = true
            _navTitleText.isHidden = true
            _titleLabel.text = "change_your_mobile_number".localized()
            _descText.isHidden = false
            _descText.text = "please_enter_your_new_phone_number".localized()
            _closeButton.isHidden = false
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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
                self._openVeriftyBottomSheet(phone: phone, countryCode: countryCode)
            }
        }
    }

    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func _openVeriftyBottomSheet(phone: String, countryCode: String) {
        let vc = INIT_CONTROLLER_XIB(VerifyBottomSheet.self)
        vc.isFromEmailVerify = false
        vc.isUpdateUserPhone = true
        vc.phoneNumber = phone
        vc.countryCode = countryCode
        vc.delegate = self
        self.presentAsPanModal(controller: vc)
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    @IBAction func _handleBackButton(_ sender: CustomGradientBorderButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction private func _handleDidEditingEnd(_ sender: UITextField) {
        if !Utils.stringIsNullOrEmpty(_txtFieldPhoneNumber.text) {
        _continueButton.buttonImage = UIImage(named: "icon_btnNext")
        _continueButton.isEnabled = true
        }
    }
    
    @IBAction private func _handelContrycodeEvent(_ sender: UIControl) {
        let controller = DialCountriesController(locale: Locale(identifier: "en"))
        controller.delegate = self
        controller.show(vc: self)
    }
    
    @IBAction private func _handleContinueEvent(_ sender: UIButton) {
        if Utils.stringIsNullOrEmpty(_lblPhoneExt.text) {
            alert(title: kAppName, message: "please_select_country_code".localized())
            return
        }
        if Utils.stringIsNullOrEmpty(_txtFieldPhoneNumber.text) {
            alert(title: kAppName, message: "please_enter_phone".localized())
            return
        }
        
        let phoneNumber = "\(_lblPhoneExt.text ?? kEmptyString) \(_txtFieldPhoneNumber.text ?? kEmptyString)"

        if Utils.isValidNumber(phoneNumber, _selectedCountry?.code ?? "UAE") == false {
            alert(message: "phone_number_is_not_valid".localized())
            return
        }
        
        params["phone"] = "\(_lblPhoneExt.text!)\(_txtFieldPhoneNumber.text!)"
        if isUpdatePhone {
            _requestLinkedEmailPhone(type: "phone", email: kEmptyString, phone: _txtFieldPhoneNumber.text ?? kEmptyString, countryCode: _lblPhoneExt.text ?? kEmptyString)
        } else {
            let presentedViewController = INIT_CONTROLLER_XIB(AccountCreatedBottomSheet.self)
            presentedViewController.isFromEmailorMobileVerify = true
            presentedViewController.delegate = self
            self.presentAsPanModal(controller: presentedViewController)
        }
        
    }
    
    @IBAction func _handleSubmitEvent(_ sender: UIButton) {
        if _txtFieldPhoneNumber.text == APPSESSION.userDetail?.phone {
            alert(title: kAppName, message: "please_select_another_number_this_number_already_registered".localized())
            return
        }
        
        if Utils.stringIsNullOrEmpty(_lblPhoneExt.text) {
            alert(title: kAppName, message: "please_select_country_code".localized())
            return
        }
        if Utils.stringIsNullOrEmpty(_txtFieldPhoneNumber.text) {
            alert(title: kAppName, message: "please_enter_phone".localized())
            return
        }
        let phoneNumber = "\(_lblPhoneExt.text ?? kEmptyString) \(_txtFieldPhoneNumber.text ?? kEmptyString)"

        if Utils.stringIsNullOrEmpty(_selectedCountry?.code) {
            guard let userDetail = APPSESSION.userDetail else { return }
            guard let countryCode = Utils.getCountryCode(for: userDetail._countryCode) else { return }
            if Utils.isValidNumber(phoneNumber, countryCode) == false {
                alert(message: "phone_number_is_not_valid".localized())
                return
            }
        } else {
            if Utils.isValidNumber(phoneNumber, _selectedCountry?.code ?? "UAE") == false {
                alert(message: "phone_number_is_not_valid".localized())
                return
            }
        }
        
        
        params["phone"] = "\(_lblPhoneExt.text!)\(_txtFieldPhoneNumber.text!)"
        if isUpdatePhone {
            _requestLinkedEmailPhone(type: "phone", email: kEmptyString, phone: _txtFieldPhoneNumber.text ?? kEmptyString, countryCode: _lblPhoneExt.text ?? kEmptyString)
        } else {
            let presentedViewController = INIT_CONTROLLER_XIB(AccountCreatedBottomSheet.self)
            presentedViewController.isFromEmailorMobileVerify = true
            presentedViewController.delegate = self
            self.presentAsPanModal(controller: presentedViewController)
        }
    }
}

// --------------------------------------
// MARK: Conttry code extention
// --------------------------------------

extension MobileLoginVC: DialCountriesControllerDelegate {
    func didSelected(with country: Country) {
        _lblPhoneExt.text = country.dialCode
        _lblCountryName.text = country.flag
        _selectedCountry = country
    }
}

// --------------------------------------
// MARK: Button Action Delegate
// --------------------------------------

extension MobileLoginVC: ActionButtonDelegate {
    func buttonClicked(_ tag: Int) {
        if tag == 1 {
            dismiss(animated: true) {
                self.delegate?.buttonClicked?(1)
            }
        } else {
            let vc = INIT_CONTROLLER_XIB(EditProfileVC.self)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
