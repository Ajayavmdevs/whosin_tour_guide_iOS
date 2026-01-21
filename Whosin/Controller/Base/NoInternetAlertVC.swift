import UIKit

class NoInternetAlertVC: BaseViewController {
    
    // -------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        hideHUD()
    }

    // -------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleTryAgainEvent(_ sender: UIButton) {
        guard NETWORKMANAGER.isConnectionAvailable else { return }
        hideHUD()
        NETWORKMANAGER.dismissAlert()
    }
}
