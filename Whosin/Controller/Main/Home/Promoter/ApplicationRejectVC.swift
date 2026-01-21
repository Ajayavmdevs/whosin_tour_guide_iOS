import UIKit

class ApplicationRejectVC: ChildViewController {
    
    @IBOutlet private weak var _applyAgainbtn: UIButton!
    @IBOutlet private weak var _remainingDays: CustomLabel!
    public var remainingDays: Int = 15
    public var isRingType: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if remainingDays < 1 {
            _applyAgainbtn.isHidden = false
            _remainingDays.text = kEmptyString
        } else {
            _applyAgainbtn.isHidden = true
            _remainingDays.text = LANGMANAGER.localizedString(forKey: "days_remaining", arguments: ["value": "\(remainingDays)"])
        }
    }
    
    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        dismissOrBack()
    }
    
    @IBAction func _handleApplyAgainEvent(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(PromoterApplicationVC.self)
        vc.isComlementry = isRingType
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
