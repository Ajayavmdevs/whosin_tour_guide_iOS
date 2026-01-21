import UIKit

class EnterPasswordVC: ChildViewController{
    
    @IBOutlet private weak var _passWdTextField: CustomTextField!
    @IBOutlet private weak var _nextButton: CustomGradientBorderButton!
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }
    
    override func setupUi() {
        _nextButton.buttonImage = UIImage(named: "icon_btnNext")
        _passWdTextField.becomeFirstResponder()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    

    
    // --------------------------------------
    // MARK: Services
    // --------------------------------------
    
    private func _requestPassWdLogin() {

    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
    @IBAction private func _handleForgotPassWdEvent(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(ResetPasswordVC.self)
        vc.isFromResetPassWord = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func _handleNextButtonClick(_ sender: CustomGradientBorderButton) {
        if Utils.stringIsNullOrEmpty(_passWdTextField.text!) {
            alert(title: kAppName, message: "Please enter Password")
            return
        }
        _requestPassWdLogin()
    }
    
}
