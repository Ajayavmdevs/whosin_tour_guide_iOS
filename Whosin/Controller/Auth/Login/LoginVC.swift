import UIKit
import AuthenticationServices
import GoogleSignIn
//import FBSDKLoginKit
import PanModal
import DialCountries
import libPhoneNumber_iOS
import CoreTelephony

class LoginVC: NavigationBarViewController {

    //    let signInConfig = GIDConfiguration.init(clientID: GOOGLE_CLIENT_ID, serverClientID: GOOGLE_SERVER_ID)
    @IBOutlet weak var _backBtn: CustomButton!
    @IBOutlet weak var _guestView: UIView!
    @IBOutlet weak var _contactUsText: CustomLabel!
    
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
        view.endEditing(true)
        let contactUsText = "contact_us_button".localized() + ": "
        let emailText = "info@whosin.me"
        if Preferences.isGuest {
            _guestView.isHidden = true
            _backBtn.isHidden = false
        } else {
            _guestView.isHidden = false
            _backBtn.isHidden = true
        }
        let contactUsAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white
        ]
        
        // Attributes for the email part
        let emailAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        // Combine both parts into a single attributed string
        let attributedString = NSMutableAttributedString(string: contactUsText, attributes: contactUsAttributes)
        let emailAttributedString = NSAttributedString(string: emailText, attributes: emailAttributes)
        attributedString.append(emailAttributedString)
        
        // Set the attributed text to the label
        _contactUsText.attributedText = attributedString

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
    
    private func _requestGoogleLogin() {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { user, error in
            guard let token = user?.user.idToken?.tokenString else { return }
            self.showHUD()
            APPSESSION.loginWithGoogle(token: token) { [weak self] success, error in
                guard let self = self else { return }
                self.hideHUD(error: error)
                guard success else { return }
                if Preferences.isGuest {
                    Preferences.isGuest = false
                    navigationController?.popViewController(animated: true)
                } else {
                    self.moveToHome()
                }
            }
        }
    }


    private func _requestAppleLogin() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    private func _requestGuestLogin() {
        self.showHUD()
        let params = ["deviceId" : Utils.getDeviceID()]
        APPSESSION.loginGuest(params: params) { [weak self] success, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard success else { return }
            self.moveToHome()
        }
    }

//    private func _requestFacebookLogin() {
//        let fbLoginManager : LoginManager = LoginManager()
//        fbLoginManager.logIn(permissions: ["email"], from: self) { result, error in
//            if error == nil {
//                if let token = result?.token?.tokenString {
//                    self.showHUD()
//                    APPSESSION.loginWithFacebook(token: token) { [weak self] success, error in
//                        guard let self = self else { return }
//                        self.hideHUD(error: error)
//                        guard success else { return }
//                        self.moveToHome()
//                    }
//                }
//            } else {
//                self.hideHUD(error: error as NSError?)
//            }
//        }
//    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    @IBAction func _handleBackEvent(_ sender: CustomButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func _handleFacebookEvent(_ sender: UIButton) {
//        _requestFacebookLogin()
    }
    
    @IBAction private func _handleGoogleEvent(_ sender: UIButton) {
        _requestGoogleLogin()
    }
    
    @IBAction private func _handleAppleEvent(_ sender: UIButton) {
        _requestAppleLogin()
    }
    
    @IBAction func _handleGuestLogin(_ sender: UIButton) {
        _requestGuestLogin()
    }
    
        
    @IBAction func _handlePhoneEmailLoginEvent(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(MobileEmailLoginVC.self)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func handleTerms( sender: UIButton) {
        _openURL(urlString: "https://whosin.me/terms-conditions/")
    }
    
    @IBAction private func handlePrivacyPolicy( sender: UIButton) {
        _openURL(urlString: "https://whosin.me/privacy-policy/")
    }
    
    private func _openURL(urlString: String) {
        if let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? kEmptyString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            alert(title: kAppName, message: "Somthing Wrong!")
        }
    }
    
    @IBAction func _handleContactUsEvent(_ sender: CustomButton) {
        contactUsTapped()
    }
    
    @objc func contactUsTapped() {
        let email = "info@whosin.me"
        if let emailURL = URL(string: "mailto:\(email)") {
            if UIApplication.shared.canOpenURL(emailURL) {
                UIApplication.shared.open(emailURL, options: [:], completionHandler: nil)
            } else {
                showCustomAlert(title: "Error", message: "email_app_is_available_on_your_device".localized(),yesButtonTitle: "ok".localized(), noButtonTitle: kEmptyString) { UIAlertAction in
                }
            }
        }
    }

}

extension LoginVC: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomBottomSheet(presentedViewController: presented, presenting: presenting)
    }
    
}

// --------------------------------------
// MARK: ASAuthirization delegate
// --------------------------------------

extension LoginVC: ASAuthorizationControllerDelegate {

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {

        if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
            if let data = appleIDCredential.identityToken {
                let token = String(decoding: data, as: UTF8.self)
                let firstName = appleIDCredential.fullName?.givenName ?? kEmptyString
                let lastName = appleIDCredential.fullName?.familyName ?? kEmptyString
                self.showHUD()
                APPSESSION.loginWithApple(token: token, firstName: firstName, lastName: lastName) { [weak self] success, error in
                    guard let self = self else { return }
                    self.hideHUD(error: error)
                    guard success else { return }
                    if Preferences.isGuest {
                        Preferences.isGuest = false
                        navigationController?.popViewController(animated: true)
                    } else {
                        self.moveToHome()
                    }
                }
            }
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            print("User id is \(userIdentifier) \n Full Name is \(String(describing: fullName)) \n Email id is \(String(describing: email))") }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {

    }
}

// --------------------------------------
// MARK: Action Button Delagate
// --------------------------------------


extension LoginVC: ActionButtonDelegate {
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
                APPSESSION.moveToHome()
            }
        }
    }
}

