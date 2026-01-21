import UIKit
import StripePaymentSheet

class ActivityConfirmationAlertVC: ChildViewController {

    @IBOutlet private weak var _priceLabel: UILabel!
    @IBOutlet private weak var _activityTitle: UILabel!
    @IBOutlet private weak var _activityProvider: UILabel!
    @IBOutlet private weak var _dateLabel: UILabel!
    @IBOutlet private weak var _timeLabel: UILabel!
    @IBOutlet private weak var _itemCount: UILabel!
    public var activityModel: ActivitiesModel?
    public var itemCount: Int = 0
    public var date: String = kEmptyString
    public var time: String = kEmptyString
    public var paymentSheet: PaymentSheet?
    
    var dataCallback: ((String) -> Void)?
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        _setupUi()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func _setupUi() {
        _timeLabel.text = time
        _priceLabel.text = "D\(itemCount * (Int(activityModel?._disocuntedPrice ?? "0") ?? 0))"
        _activityProvider.text = activityModel?.provider?.name
        _activityTitle.text = activityModel?.name
        _itemCount.text = "\(itemCount)"
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @IBAction private func _hndleCloseEvent(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func _handleConfirmEvent(_ sender: UIButton) {
        self.dismiss(animated: true) { [self] in
            self.dataCallback?("confirmed")
        }
    }
    
    @IBAction private func _handleEditEvent(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
