import UIKit

class CancelBookingVC: ChildViewController {

    @IBOutlet weak var _msgTextView: CustomTextView!
    @IBOutlet weak var _refundAmount: CustomLabel!
    public var submitCallback: ((_ text: String)->Void)?
    public var refundAmount: Double = 0.0
    public var isOctotype: Bool = false
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let formattedRefundAmount = Double(round(100 * refundAmount) / 100)
        if isOctotype {
            _refundAmount.text = "refund_full_message".localized()
        } else {
            if formattedRefundAmount == 0 {
                _refundAmount.text = "noRefundText".localized()
            } else {
                _refundAmount.attributedText = LANGMANAGER.localizedString(forKey: "refundText", arguments: ["value1": "\(Utils.getCurrentCurrencySymbol())", "value2": "\(formattedRefundAmount)"]).withCurrencyFont()
            }
        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction func _closeEvent(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func _submitEvent(_ sender: Any) {
        if Utils.stringIsNullOrEmpty(_msgTextView.text) {
            alert(message: "give_some_reson_for_cancel_ticket".localized())
        }
        
        self.dismiss(animated: true) {
            self.submitCallback?(self._msgTextView.text)
        }
        
    }
    
}
