import UIKit
import StripePaymentSheet
import StripeCore

class PaidPassPopupVC: ChildViewController {
    
    @IBOutlet weak var _msgLbl: CustomLabel!
    @IBOutlet weak var _titleText: CustomLabel!
    @IBOutlet weak var _validityText: CustomLabel!
    public var paymentSheet: PaymentSheet?
    public var paidpass: PaidPassModel?
    var event: PromoterEventsModel?

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
        _paymentPassRequest()
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------

    private func _paymentPassRequest() {
        guard let eventId = event?.id else { return }
        showHUD()
        WhosinServices.paidPassByEventId(eventId: eventId) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD()
            guard let data = container?.data else { return }
            self.paidpass = data
            _msgLbl.text = data.descriptions
            _titleText.text = data.title
            _validityText.text = "\(data.validityInDays) Days"
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    @objc private func dismissPopup() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    @IBAction func _handleCloseEvent(_ sender: Any) {
        dismissPopup()
    }
    
    @IBAction func _paymentEvent(_ sender: Any) {
        showHUD()
        _paymentCreate()
    }
    
    private func _paymentCreate() {
        guard let model = paidpass else { return }
        let params: [String: Any] = ["amount": model.amount, "paidPassId": model.id, "type": "paid-pass", "venueId": event?.venueId ?? kEmptyString, "eventId": event?.id ?? kEmptyString]
        PAYMENTMANAGER.showPaymentOptions(in: self, params: params,isTabbyDisable: model.amount < 10, purchaseType: .paidPass) { result in
            switch result {
            case .success:
                self.hideHUD()
                self._handleInEvent()
                NotificationCenter.default.post(name: .reloadMyEventsNotifier   , object: nil)
            case .cancelled:
                self.hideHUD()
            case .failure(let error):
                self.hideHUD(error: error as NSError)
            }
        }
    }

    
    private func _handleInEvent() {
        guard let event = event, let id = event.invite?.id else { return }
        WhosinServices.updateInviteStatus(inviteId: id, inviteStatus: "in") { [weak self] container, error in
            guard let self = self else { return }
            let searchString = "You_recently_enjoyed_a_complimentary_visit_to_this_venue".localized()
            if let msg = error?.localizedDescription, msg.contains(searchString) {
                self.dismissPopup()
            } else {
                self.showError(error)
            }
            guard let data = container else { return }
            if data.message == "cancellation-penalty" {
                NotificationCenter.default.post(name: .openPenaltyPaymenPopup   , object: nil, userInfo: ["data" : data.data, "inviteId": id])
            } else {
                self.dismissPopup()
                let titleMsg = event.isConfirmationRequired == true ? "thank_you_for_showing_interest".localized() : "thank_you_for_joining".localized()
                let subtitleMsg = event.isConfirmationRequired == true ? "admin_will_review_request".localized() : "check_details_and_be_on_time".localized()
                self.showSuccessMessage(titleMsg, subtitle: subtitleMsg)
                NotificationCenter.default.post(name: .reloadMyEventsNotifier   , object: nil)
            }
        }
    }
}
