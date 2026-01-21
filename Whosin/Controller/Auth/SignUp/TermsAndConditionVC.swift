import UIKit

class TermsAndConditionVC: ChildViewController {

    @IBOutlet weak var _backButton: CustomGradientBorderButton!
    var delegate: ActionButtonDelegate?
    public var params: [String: Any] = [:]

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupUi() {
        _backButton.buttonImage = UIImage(named: "icon_backArrow")
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func _requestUpdateProfile() {
        showHUD()
        APPSESSION.updateProfile(param: params) { [weak self] isSuccess, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard isSuccess else { return }
            let vc = INIT_CONTROLLER_XIB(OnBoardCompleteProfile.self)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @IBAction func _handleBackButtonEvent(_ sender: CustomGradientBorderButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func _handleAcceptbuttonEvent(_ sender: UIButton) {
        _requestUpdateProfile()
    }
}

