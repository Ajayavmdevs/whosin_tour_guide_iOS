import UIKit
import StripePaymentSheet
import SwiftUI

class ClaimTotalBillVC: ChildViewController {
    
    @IBOutlet private weak var _pxPerpersion: UILabel!
    @IBOutlet private weak var _claimChargeText: UILabel!
    @IBOutlet private weak var _maxValue: UILabel!
    @IBOutlet private weak var _discountTitle: UILabel!
    @IBOutlet private weak var _countLabel: UILabel!
    @IBOutlet private weak var _sliderBar: UISlider!
    @IBOutlet private weak var _discLabel: UILabel!
    @IBOutlet private weak var _nameLabel: UILabel!
    @IBOutlet private weak var _imageView: UIImageView!
    @IBOutlet private weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var sapratorView: UIView!
    @IBOutlet private weak var _textFieldFour: OTPTextField!
    @IBOutlet private weak var _textFieldThree: OTPTextField!
    @IBOutlet private weak var _textFieldTwo: OTPTextField!
    @IBOutlet private weak var _textFieldOne: OTPTextField!
    @IBOutlet private weak var _messageLbl: UILabel!
    @IBOutlet private weak var _messageTitleLbl: UILabel!
    public var venueModel: VenueDetailModel?
    public var specialOffer: SpecialOffersModel?
    private var _otpCodeList: [UITextField] = []
    private var _otpCode: String = kEmptyString
    private var params: [String: Any] = [:]
    @IBOutlet private weak var _badgeBtn: UIButton!
    var paymentSheet: PaymentSheet?

    // --------------------------------------
    // MARK: Life-Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }
    
    override func setupUi() {
        DISPATCH_ASYNC_MAIN_AFTER(0.2) {
            self._badgeBtn.roundCorners(corners: [.bottomLeft, .topRight], radius: 10)
        }
        _badgeBtn.setTitle("\(specialOffer?.discount ?? 0)%")
        
        _otpCodeList = [
            _textFieldOne, _textFieldTwo, _textFieldThree, _textFieldFour
        ]

        for field in _otpCodeList {
            field.text = ""
            field.textAlignment = .center
            field.delegate = self
            field.keyboardType = .numberPad
        }
        _sliderBar.minimumValue = 0
        if let maxPersonAllowed = specialOffer?.maxPersonAllowed, maxPersonAllowed != 0 {
            _sliderBar.maximumValue = Float(maxPersonAllowed)
            _maxValue.text = "\(maxPersonAllowed)"
        } else {
            _sliderBar.maximumValue = 8.0
            _maxValue.text = "8"
        }

        _messageTitleLbl.text = APPSETTING.appSetiings?.pages.filter({ $0.title == "claim-title" }).first?.descriptions
        _messageLbl.text = APPSETTING.appSetiings?.pages.filter({ $0.title == "claim-message" }).first?.descriptions
        _sliderBar.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        _countLabel.text = "0"
        _discountTitle.text = "\(specialOffer?.discount ?? 0)%" + "discount".localized()
        _imageView.loadWebImage(venueModel?.logo ?? "" , placeholder: UIImage(named: "icon_user_avatar_default"))
        _discLabel.text = venueModel?.address
        _nameLabel.text = venueModel?.name
        _pxPerpersion.text = APPSESSION.userDetail?.isVip == true ? "free" : "(D\(specialOffer?.pricePerPerson ?? 0)/px)"
        _claimChargeText.text = APPSESSION.userDetail?.isVip == true ? "free" : "D0"
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _startTabbyCheckOut(data: TabbyModel, historyModel: ClaimHistoryModel) {
        guard !Utils.stringIsNullOrEmpty(data.webUrl) else { return }
        let paymentVC = TabbyPaymentViewController()
        paymentVC.paymentURL = data.webUrl
        paymentVC.onPaymentResult = { status in
            switch status {
            case .success:
                self.dismiss(animated: true) {
                    guard let specialoffer = self.specialOffer, let venue = self.venueModel else { return }
                    let successData: [String: Any] = ["data": historyModel, "isFromBrunch" : false, "specialOffer": specialoffer as? SpecialOffersModel, "venue" : venue]
                    NotificationCenter.default.post(name: .openClaimSuccessCard, object: nil, userInfo: successData)
                }
            case .failure:
                self.hideHUD()
                print("❌ Payment failed! Handle failure logic here.")
            case .cancelled:
                self.hideHUD()
                print("🔙 User cancelled the payment.")
            }
        }
        let navController = UINavigationController(rootViewController: paymentVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)

    }

    
    private func _startCheckOut(data: PaymentCredentialModel, historyModel: ClaimHistoryModel) {
        if Utils.stringIsNullOrEmpty(data.publishableKey) {
            alert(title: kAppName, message: "payment_inti_try_again".localized())
            return
        }

        StripeAPI.defaultPublishableKey = data.publishableKey
        
        STPAPIClient.shared.publishableKey = data.publishableKey
        // MARK: Create a PaymentSheet instance
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = "Whosin, Inc."
        configuration.allowsDelayedPaymentMethods = true
        configuration.applePay = .init(
            merchantId: "merchant.com.whosin.me",
            merchantCountryCode: "AE"
        )
        self.paymentSheet = PaymentSheet(paymentIntentClientSecret: data.clientSecret, configuration: configuration)
        
        self.paymentSheet?.present(from: self) { paymentResult in
            // MARK: Handle the payment result
            switch paymentResult {
            case .completed:
                self.dismiss(animated: true) {
                    guard let specialoffer = self.specialOffer, let venue = self.venueModel else { return }
                    let successData: [String: Any] = ["data": historyModel, "isFromBrunch" : false, "specialOffer": specialoffer as? SpecialOffersModel, "venue" : venue]
                    NotificationCenter.default.post(name: .openClaimSuccessCard, object: nil, userInfo: successData)
                }
            case .canceled:
              print("Canceled!")
            case .failed(let error):
              print("Payment failed: \(error)")
            }
          }
    }
    
    private func _requestClaimOffer(_ isTabby: Bool = false) {
        showHUD()
        WhosinServices.claimOffer(params: params) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self.showToast(container?.message ?? "")
            if container?.message == "Vip User Order Successfully Created!" {
                self.dismiss(animated: true) {
                    guard let specialoffer = self.specialOffer, let claimHistory = data.response, let venue = self.venueModel else { return }
                    let successData: [String: Any] = ["data": claimHistory, "isFromBrunch" : false, "specialOffer": specialoffer, "venue": venue]
                    NotificationCenter.default.post(name: .openClaimSuccessCard, object: nil, userInfo: successData)
                }
            } else {
                if let object = data.objToSend,let claimHistory = data.response {
                    if let amount = self.params["amount"] as? Int {
                        if amount == 0 {
                            self.dismiss(animated: true) {
                                guard let specialoffer = self.specialOffer, let venue = self.venueModel else { return }
                                let successData: [String: Any] = ["data": claimHistory, "isFromBrunch" : false, "specialOffer": specialoffer, "venue": venue]
                                NotificationCenter.default.post(name: .openClaimSuccessCard, object: nil, userInfo: successData)
                            }
                        } else {
                            self._startCheckOut(data: object, historyModel: claimHistory)
                        }
                    } else {
                        self._startCheckOut(data: object, historyModel: claimHistory)
                    }
                } else if isTabby, let tabby = data.tabby, let claimHistory = data.response {
                    _startTabbyCheckOut(data: tabby, historyModel: claimHistory)
                } else {
                    self.showToast("Something went wrong....!")
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _validateVerifyButton() {
        let isValid = _otpCodeList.first(where: { Utils.stringIsNullOrEmpty($0.text) }) == nil
        if isValid {
            var otpCodes: [String] = []
            for txt in _otpCodeList { otpCodes.append(txt.text ?? kEmptyString) }
            if otpCodes.count == _otpCodeList.count {
                let code = otpCodes.joined()
                view.endEditing(true)
                _otpCode = code
            }
        } else {
            _otpCode = kEmptyString
        }
    }
    
    private func _reset() {
        for field in self._otpCodeList { field.text = kEmptyString }
        _validateVerifyButton()
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        self.view.frame.origin.y = keyboardSize.origin.y - self.view.frame.size.height
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = view.frame.size.height - self.view.frame.size.height
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleClaimEvent(_ sender: UIButton) {
        
        if Int(_sliderBar.value) == 0 {
            alert(title: kAppName, message: "please_select_number_of_person".localized())
            return
        }

        if Utils.stringIsNullOrEmpty(_otpCode) {
            alert(title: kAppName, message: "please_enter_claim_code".localized())
            return
        }
        
        if _otpCode.count != 4 {
            alert(title: kAppName, message: "somthing_wrong_in_claim_code".localized())
            return
        }
        
        
        
        params["specialOfferId"] = specialOffer?.id
        params["venueId"] = specialOffer?.venueId
        params["type"] = "total"
        params["totalPerson"] = Int(_sliderBar.value)
        params["billAmount"] = "0"
        params["claimCode"] = _otpCode
        params["amount"] = Int(_sliderBar.value) * (specialOffer?.pricePerPerson ?? 0)
        params["currency"] = "aed"
        if let amount = self.params["amount"] as? Int {
            _requestClaimOffer()
        } else {
            _openPaymentOptions()
        }
    }
    
    private func _openPaymentOptions() {
        let bottomSheet = PaymentBottomSheet()
        bottomSheet.tabbyAction = {
            self.params["paymentMethod"] = "tabby"
            self._requestClaimOffer(true)
        }
        bottomSheet.applePayAction = {
            self.params["paymentMethod"] = "stripe"
            self._requestClaimOffer(false)
        }
        bottomSheet.creditCardAction = {
            self.params["paymentMethod"] = "stripe"
            self._requestClaimOffer(false)
        }
        bottomSheet.viaLinkAction = {
            self.params["paymentMethod"] = "stripe"
            self._requestClaimOffer(false)
        }
        bottomSheet.show(in: self)
    }

    

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        sender.value = round(sender.value)
        let value = Int(sender.value)
        _countLabel.text = "\(value)"
        let maxLabelX = _sliderBar.bounds.width - _countLabel.frame.size.width
        let newX = maxLabelX * CGFloat(sender.value / sender.maximumValue)
        leadingConstraint.constant = newX
        _claimChargeText.attributedText = (APPSESSION.userDetail?.isVip == true)
            ? NSAttributedString(string: "free")
            : "\(Utils.getCurrentCurrencySymbol())\(value * (specialOffer?.pricePerPerson ?? 0))".withCurrencyFont(13, false)
    }
    
    @IBAction private func _handleBackEvent(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

// --------------------------------------
// MARK: TextField Delegate
// --------------------------------------

extension ClaimTotalBillVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (range.length == 0 && string.isEmpty) {
            self.textFieldDidDelete(textField)
            return false }
        
        if (range.length == 1 && string.isEmpty) {
            textField.text = kEmptyString
            _validateVerifyButton()
            return false
        }
        
        if string.count == 0 {
            _validateVerifyButton()
            return false
        }
        
        if !(string.rangeOfCharacter(from: NSCharacterSet.decimalDigits) != nil) {
            _validateVerifyButton()
            return false
        }
        
        textField.text = string
        self.textFieldDidChange(textField)
        return false
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        _validateVerifyButton()
        var index = 0
        for textField in _otpCodeList {
            index += 1
            if textField.isFirstResponder && index < _otpCodeList.count {
                _otpCodeList[index].becomeFirstResponder()
                break
            }
        }
    }
    
    func textFieldDidDelete(_ textField: UITextField) {
        guard var index = _otpCodeList.firstIndex(of: textField) else { return }
        index -= 1
        if index >= 0 {
            let textField = _otpCodeList[index]
            textField.becomeFirstResponder()
            textField.text = kEmptyString
            _validateVerifyButton()
        }
    }
}

