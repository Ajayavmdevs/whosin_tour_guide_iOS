import UIKit
import StripePaymentSheet
import StripeCore

class PenaltyPopupVC: ChildViewController {
    
    @IBOutlet weak var _msgLbl: CustomLabel!
    @IBOutlet weak var _titleText: CustomLabel!
    var _msg = ""
    var _title = ""
    public var paymentSheet: PaymentSheet?
    public var model: BaseModel?
    var event: PromoterEventsModel?

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
        _msgLbl.text = _msg
        _titleText.text = _title
//        setupDismissOnTap()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func setupDismissOnTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissPopup() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    @IBAction func _handleCloseEvent(_ sender: Any) {
        dismissPopup()
    }
    
    @IBAction func _restartEvent(_ sender: Any) {
        showHUD()
        _paymentCreate()
    }
    
    @IBAction func _handleFAQEvent(_ sender: Any) {
        let vc = INIT_CONTROLLER_XIB(FaqVC.self)
        vc.faqText = event?.faq ?? kEmptyString
        present(vc, animated: true)
    }
    
    private func _paymentCreate() {
        guard let model = model else { return }
        let params: [String: Any] = ["amount": model.amount, "currency": model.currency, "type": model.type]
        PAYMENTMANAGER.showPaymentOptions(in: self, params: params,isTabbyDisable: model.amount < 10, purchaseType: .penalty) { result in
            switch result {
            case .success:
                self.hideHUD()
                self._handleInEvent()
                NotificationCenter.default.post(name: .reloadMyEventsNotifier   , object: nil)
            case .cancelled:
                self.hideHUD()
            case.failure(let error):
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
                let vc = INIT_CONTROLLER_XIB(CustomMultiOptionAlertVC.self)
                vc.firstButtonTitle = "event_pass".localized()
                vc.secButtonTitle = "cancel".localized()
                vc._title = "time_sensitive".localized()
                vc._msg = msg
                vc._handleFirstEvent = { [weak self] in
                    guard let self = self else { return }
                    let vc = INIT_CONTROLLER_XIB(PaidPassPopupVC.self)
                    vc.event = event
                    self.presentDailogueBox(vc)
                }
                vc._handleSecEvent = { [weak self] in
                }
                self.presentDailogueBox(vc)

            } else {
                self.showError(error)
            }
            guard let data = container else { return }
            if data.message == "cancellation-penalty" {
                NotificationCenter.default.post(name: .openPenaltyPaymenPopup   , object: nil, userInfo: ["data" : data.data, "inviteId": id])
            } else {
                self.dismissPopup()
                let titleMsg = event.isConfirmationRequired == true ? "thank_you_for_showing_interest".localized() : "thank_you_for_joining".localized()
                let subtitleMsg = event.isConfirmationRequired == true ? "admin_will_review_request".localized() : "pcheck_details_and_be_on_time".localized()
                self.showSuccessMessage(titleMsg, subtitle: subtitleMsg)
                NotificationCenter.default.post(name: .reloadMyEventsNotifier   , object: nil)
            }
        }
    }
}
