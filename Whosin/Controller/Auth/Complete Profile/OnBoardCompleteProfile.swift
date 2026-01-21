import UIKit

class OnBoardCompleteProfile: ChildViewController {

    @IBOutlet private weak var _nextButton: CustomGradientBorderButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }
    
    override func setupUi() {
        _nextButton.buttonImage = UIImage(named: "icon_btnNext")
    }

    @IBAction private func _handleSkipEvent(_ sender: Any) {
        APPSESSION.moveToHome()
    }
    
    @IBAction private func _handleNextButton(_ sender: CustomGradientBorderButton) {
        let vc = INIT_CONTROLLER_XIB(UploadProfilePictureVC.self)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
