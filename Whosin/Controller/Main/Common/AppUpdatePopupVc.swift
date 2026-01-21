import UIKit

class AppUpdatePopupVc: ChildViewController {
    
    @IBOutlet private weak var cancelBtn: UIButton!
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func setupUI() {
        cancelBtn.isHidden = APPSETTING.appSetiings?.forceUpdate == true
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------

    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        dismiss(animated: true)
    }

    @IBAction func _handleUpdateNowEvent(_ sender: UIButton) {
        if let url = URL(string: "itms-apps://itunes.apple.com/app/\(kAppId)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        dismiss(animated: true)


    }
}

