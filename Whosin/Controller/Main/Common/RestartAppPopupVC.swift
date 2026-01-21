import UIKit

class RestartAppPopupVC: UIViewController {
    
    @IBOutlet weak var _msgLbl: CustomLabel!
    var _msg = ""
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if _msg == "complimentary" {
            _msgLbl.text = "account_upgraded_complimentary".localized()
        } else if _msg == "promoter" {
            _msgLbl.text = "account_upgraded_promoter".localized()
        } else if _msg == "subadmin-remove" {
            _msgLbl.text = "account_revoked_subadmin".localized()
        } else if _msg == "subadmin-approve" {
            _msgLbl.text = "account_upgraded_subadmin".localized()
        } else {
            _msgLbl.text = "account_updated".localized()
        }
        APPSETTING._getProfile()
//        setupDismissOnTap()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func setupDismissOnTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissPopup() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
    @IBAction func _restartEvent(_ sender: Any) {
        Preferences.restartClearConnectedData()
        let chatRepository = ChatRepository()
        chatRepository.resetRealm()
        if APP.window == nil { APP.window = UIWindow(frame: UIScreen.main.bounds) }
        guard let window = APP.window else { return }
        window.backgroundColor = ColorBrand.brandAppBgColor
        window.setRootViewController(INIT_CONTROLLER_XIB(SplashViewController.self), options: UIWindow.TransitionOptions(direction:.fade, style: .easeInOut))
        
    }
}
