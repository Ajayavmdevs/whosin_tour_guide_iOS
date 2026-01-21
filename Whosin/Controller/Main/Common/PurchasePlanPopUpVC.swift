
import UIKit


class PurchasePlanPopUpVC: ChildViewController {

    @IBOutlet weak var _titleMsg: UILabel!
    public var subscription: MembershipPackageModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
        _titleMsg.text = "You have successfully purchased \(subscription?.title ?? kEmptyString)"
    }

    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func _handleViewEvent(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(BundlePlanDetailsVC.self)
        vc.subscription = subscription
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
}
