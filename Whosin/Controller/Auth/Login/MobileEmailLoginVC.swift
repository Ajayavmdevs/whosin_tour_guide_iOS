import UIKit
import AuthenticationServices
import GoogleSignIn
//import FBSDKLoginKit
import PanModal
import DialCountries
import libPhoneNumber_iOS
import CoreTelephony

class MobileEmailLoginVC: NavigationBarViewController {
    
    @IBOutlet private weak var _phoneEmailTextField: CustomTextField!
    @IBOutlet private weak var _PhoneCodeExtView: UIView!
    @IBOutlet private weak var _lblPhoneExt: UILabel!
    @IBOutlet private weak var _lblCountryName: UILabel!
    @IBOutlet private weak var _nextButton: CustomGradientBorderButton!
    private var _selectedCountry: Country?
    private var _defaultCountrycode: String = "UAE"
    private var _defaultDialCode: String = "+971"
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func setupUi() {
        _PhoneCodeExtView.isHidden = true
        _selectedCountry = Country.getCurrentCountry()
        _lblPhoneExt.text = _selectedCountry?.dialCode
        _lblCountryName.text = _selectedCountry?.flag
        _phoneEmailTextField.delegate = self
        _nextButton.buttonImage = UIImage(named: "icon_btnNext")
        view.endEditing(true)
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func moveToHome() {
        APPSESSION.moveToHome()
    }

    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestPhoneLogin(param: [String: Any]) {
        showHUD()
        APPSESSION.loginWithPhone(params: param) { [weak self] isSuccess, error in
            guard let self = self else { return }
            self.hideHUD()
            guard isSuccess else {
                self.showError(error)
                return
            }
            self.view.makeToast("OTP sent successfully")
            DISPATCH_ASYNC_MAIN_AFTER(0.1) {
                let presentedViewController = INIT_CONTROLLER_XIB(AccountCreatedBottomSheet.self)
                presentedViewController.phoneNumber = self._phoneEmailTextField.text!
                presentedViewController.countryCode = self._lblPhoneExt.text!
                presentedViewController.delegate = self
                presentedViewController.titleString = error?.localizedDescription ?? kEmptyString
                self.presentAsPanModal(controller: presentedViewController)
            }
        }
    }
    
    private func _requestNewLogin(param: [String: Any], isEmailLogin: Bool = false) {
        showHUD()
        APPSESSION.newLoginUser(params: param) { [weak self] isSuccess, error in
            guard let self = self else { return }
            self.hideHUD()
            guard isSuccess else {
                self.showError(error)
                return
            }
            self.view.makeToast("otp_sent_successfully".localized())
            DISPATCH_ASYNC_MAIN_AFTER(0.1) {
                let presentedViewController = INIT_CONTROLLER_XIB(AccountCreatedBottomSheet.self)
                presentedViewController.isEmailLogin = isEmailLogin
                presentedViewController.phoneNumber = self._phoneEmailTextField.text!
                presentedViewController.countryCode = self._lblPhoneExt.text!
                presentedViewController.delegate = self
                presentedViewController.titleString = error?.localizedDescription ?? kEmptyString
                self.presentAsPanModal(controller: presentedViewController)
            }
        }
    }
    
    private func _requestGetToken() {
        showHUD()
        WhosinServices.getToken { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let token = container?.data else {
                alert(message: "token_is_empty".localized())
                return
            }
            
            guard let key = Utils.getHashSha256("whosin", length: 32) else {
                alert(message: "somthing_wrong_fetching_device_key".localized())
                return
            }
            
            let cryptLib = CryptLib()
            let cipherToken = cryptLib.decryptCipherTextRandomIV(withCipherText: token, key: key) ?? kEmptyString
            
            let phoneNumber = "\(_lblPhoneExt.text ?? kEmptyString) \(_phoneEmailTextField.text ?? kEmptyString)"
            if Utils.isValidEmail(_phoneEmailTextField.text) {
                let params: [String: Any] = ["phone": _phoneEmailTextField.text!,"platform": "ios", "deviceId": Utils.getDeviceID(), "token" : cipherToken]
                self._requestNewLogin(param: params, isEmailLogin: true)
            }
            else if Utils.isValidNumber(phoneNumber, _selectedCountry?.code ?? _defaultCountrycode) {
                if let countryCode = _lblPhoneExt.text?.replacingOccurrences(of: "+", with: "") {
                    let params: [String: Any] = ["phone": _phoneEmailTextField.text!,"platform": "ios","countryCode": countryCode, "deviceId": Utils.getDeviceID(), "token" : cipherToken]
                    self._requestNewLogin(param: params)
                }
            }
            else {
                alert(title: kAppName, message: "valid_email_or_phone_number".localized())
            }
        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handlePhoneEvent(_ sender: CustomGradientBorderButton) {
        if Utils.stringIsNullOrEmpty(_phoneEmailTextField.text) {
            alert(title: kAppName, message: "please_enter_email_or_phone_number".localized())
            return
        }
        _requestGetToken()
//        let phoneNumber = "\(_lblPhoneExt.text ?? kEmptyString) \(_phoneEmailTextField.text ?? kEmptyString)"
//        if Utils.isValidEmail(_phoneEmailTextField.text) {
//            let params: [String: Any] = ["phone": _phoneEmailTextField.text!,"platform": "ios"]
//            _requestPhoneLogin(param: params)
//        }
//        else if Utils.isValidNumber(phoneNumber, _selectedCountry?.code ?? _defaultCountrycode) {
//            if let countryCode = _lblPhoneExt.text?.replacingOccurrences(of: "+", with: "") {
//                let params: [String: Any] = ["phone": _phoneEmailTextField.text!,"platform": "ios","countryCode": countryCode]
//                _requestPhoneLogin(param: params)
//            }
//        }
//        else {
//            alert(title: kAppName, message: "Please enter valid email or phone number")
//        }
    }
    
    @IBAction private func _handelContrycodeEvent(_ sender: UIControl) {
        let controller = DialCountriesController(locale: Locale(identifier: "en"))
        controller.delegate = self
        controller.show(vc: self)
    }
    
    @IBAction private func handleTerms( sender: UIButton) {
        _openURL(urlString: "https://www.whosin.me/terms-conditions/")
    }
    
    @IBAction private func handlePrivacyPolicy( sender: UIButton) {
        _openURL(urlString: "https://www.whosin.me/privacy-policy/")
    }
    
    @IBAction func _handleBackEvent(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    private func _openURL(urlString: String) {
        if let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? kEmptyString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            alert(title: kAppName, message: "Somthing Wrong!")
        }
    }
}

extension MobileEmailLoginVC: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomBottomSheet(presentedViewController: presented, presenting: presenting)
    }
    
}

// --------------------------------------
// MARK: TextField Delegate
// --------------------------------------

extension MobileEmailLoginVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        _ = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
//        if newText.count > 3 {
//            if let number = Int(newText) {
//                _PhoneCodeExtView.isHidden = false
//            } else {
//                if Utils.isEmail(emailString: newText) {
//                    _PhoneCodeExtView.isHidden = true
//                } else {
//                    _PhoneCodeExtView.isHidden = true
//                }
//            }
//        }else {
            _PhoneCodeExtView.isHidden = true
//        }
        return true
    }
}

// --------------------------------------
// MARK: Conttry code extention
// --------------------------------------

extension MobileEmailLoginVC: DialCountriesControllerDelegate {
    func didSelected(with country: Country) {
        _lblPhoneExt.text = country.dialCode
        _lblCountryName.text = country.flag
        _selectedCountry = country
    }
}

// --------------------------------------
// MARK: Action Button Delagate
// --------------------------------------


extension MobileEmailLoginVC: ActionButtonDelegate {
    func buttonClicked(_ tag: Int) {
        if APPSESSION.isAuthenticationPending == true {
            guard let window = APP.window else { return }
            let controller = INIT_CONTROLLER_XIB(TwoStepVarificationVC.self)
            let navController = NavigationController(rootViewController: controller)
            navController.setNavigationBarHidden(true, animated: false)
            window.setRootViewController(navController, options: UIWindow.TransitionOptions(direction:.fade, style: .easeInOut))
        } else {
            if Utils.stringIsNullOrEmpty(APPSESSION.userDetail?.firstName) && Utils.stringIsNullOrEmpty(APPSESSION.userDetail?.lastName) {
                let vc = INIT_CONTROLLER_XIB(SignInNameVC.self)
                navigationController?.pushViewController(vc, animated: true)
            } else {
                if Preferences.isFromGuest {
                    Preferences.isGuest = false
                    Preferences.isFromGuest = false
                    if let nav = navigationController {
                        if let ticketVC = nav.viewControllers.first(where: { $0 is TicketPreviewVC }) {
                            nav.popToViewController(ticketVC, animated: true)
                        } else {
                            let vc = INIT_CONTROLLER_XIB(TicketPreviewVC.self)
                            nav.pushViewController(vc, animated: true)
                        }
                    }
                } else {
                    APPSESSION.moveToHome()
                }
            }
        }
    }
}

