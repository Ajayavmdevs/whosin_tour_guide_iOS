import UIKit
import StripePaymentSheet
import SwiftUI

class ClaimBrunchVC: ChildViewController {
    
    @IBOutlet private weak var _claimCharge: UILabel!
    @IBOutlet private weak var _badgeButton: UIButton!
    @IBOutlet private weak var _totalAmmount: UILabel!
    @IBOutlet private weak var _discounted: UILabel!
    @IBOutlet private weak var _totalPackage: UILabel!
    @IBOutlet private weak var _listTable: CustomNoKeyboardTableView!
    @IBOutlet private weak var _titleLabel: UILabel!
    @IBOutlet private weak var _subtitle: UILabel!
    @IBOutlet private weak var _imageView: UIImageView!
    @IBOutlet private weak var _dicountTitle: UILabel!
    @IBOutlet private weak var _messageLbl: UILabel!
    @IBOutlet private weak var _messageTitleLbl: UILabel!
    @IBOutlet private weak var _hightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var _textFieldFour: OTPTextField!
    @IBOutlet private weak var _textFieldThree: OTPTextField!
    @IBOutlet private weak var _textFieldTwo: OTPTextField!
    @IBOutlet private weak var _textFieldOne: OTPTextField!
    @IBOutlet private weak var _upDownButton: UIButton!
    public var venueModel: VenueDetailModel?
    public var specialOffer: SpecialOffersModel?
    private let kCellIdentifier = String(describing: ClaimItemCell.self)
    private var _otpCodeList: [UITextField] = []
    private var _otpTxt: String = kEmptyString
    private var brunchs: [[String:Any]] = [[:]]
    private var _totalPrice: Int = 0
    public var selectedOffer: OffersModel?
    var paymentSheet: PaymentSheet?
    private var perPersionAmount: Int = 0
    var height = 0.0
    // --------------------------------------
    // MARK: Life-Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DISPATCH_ASYNC_MAIN_AFTER(0.05) {
            self._badgeButton.roundCorners(corners: [.bottomLeft, .topRight], radius: 10)
        }
        DISPATCH_ASYNC_MAIN_AFTER(0.2) {
            self._requestBrunchOffersList()
            self.setupUi()
        }
    }
    
    override func setupUi() {
        hideNavigationBar()
        self._badgeButton.isHidden = (specialOffer?.discount ?? 0) == 0
        _badgeButton.setTitle("\(specialOffer?.discount ?? 0)%")
        _titleLabel.text = venueModel?.name ?? kEmptyString
        _subtitle.text = venueModel?.address ?? kEmptyString
        _dicountTitle.text = Utils.stringIsNullOrEmpty(selectedOffer?.title) ? "select_offer".localized() : selectedOffer?.title
        _otpCodeList = [
            _textFieldOne, _textFieldTwo, _textFieldThree, _textFieldFour
        ]
        _messageTitleLbl.text = APPSETTING.appSetiings?.pages.filter({ $0.title == "claim-title" }).first?.descriptions
        _messageLbl.text = Utils.convertHTMLToPlainText(from: APPSETTING.appSetiings?.pages.filter({ $0.title == "claim-message" }).first?.descriptions ?? kEmptyString)
        for field in _otpCodeList {
            field.text = ""
            field.textAlignment = .center
            field.delegate = self
            field.keyboardType = .numberPad
        }
        _imageView.loadWebImage(venueModel?.logo ?? "", placeholder: UIImage(named: "icon_user_avatar_default"))
        _claimCharge.text = APPSESSION.userDetail?.isVip == true ? "free" : "D0"
        _totalAmmount.text = APPSESSION.userDetail?.isVip == true ? "free" : "D0"
        _totalPackage.text = "D0"
        _discounted.text = "D0"
        _listTable.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: true,
            isShowRefreshing: true,
            emptyDataText: nil,
            emptyDataIconImage: nil,
            emptyDataDescription: nil,
            delegate: self)
        brunchs.removeAll()
        _loadData()
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
                _otpTxt = code
            }
        } else { _otpTxt = kEmptyString }
    }
    
    private func _reset() {
        for field in self._otpCodeList { field.text = kEmptyString }
        _validateVerifyButton()
    }
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: ClaimItemCell.self, kCellHeightKey: ClaimItemCell.height]]
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        _dicountTitle.text = Utils.stringIsNullOrEmpty(selectedOffer?.title) ? "select_offer".localized() : selectedOffer?.title
        selectedOffer?.packages.forEach { model in
            if model.isAllowClaim == true {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: model.id,
                    kCellObjectDataKey: model,
                    kCellTitleKey: specialOffer?.discount,
                    kCellClassKey: ClaimItemCell.self,
                    kCellHeightKey: ClaimItemCell.height
                ])
            }
        }
        
        if cellData.count < 4 {
            height = CGFloat(cellData.count * 65)
            _hightConstraint.constant = height
        } else {
            height = CGFloat(3 * 65)
            _hightConstraint.constant = height
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _listTable.loadData(cellSectionData)
        
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
                    let successData: [String: Any] = ["data": historyModel, "isFromBrunch" : true, "specialOffer": specialoffer, "venue": venue]
                    NotificationCenter.default.post(name: .openClaimSuccessCard, object: nil, userInfo: successData)
                }
            case .canceled:
                print("Canceled!")
            case .failed(let error):
                print("Payment failed: \(error)")
            }
        }
    }
    
    private func _requestClaimOffer(_ params: [String: Any], _ isTabby: Bool = false) {
        showHUD()
        WhosinServices.claimOffer(params: params) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self.showToast(container?.message ?? "")
            if container?.message == "Vip User Order Successfully Created!" {
                self.dismiss(animated: true) {
                    guard let specialoffer = self.specialOffer, let claimHistory = data.response, let venue = self.venueModel else { return }
                    let successData: [String: Any] = ["data": claimHistory, "isFromBrunch" : true, "specialOffer": specialoffer, "venue": venue]
                    NotificationCenter.default.post(name: .openClaimSuccessCard, object: nil, userInfo: successData)
                }
            } else {
                if let amount = params["amount"] as? Int, amount == 0 {
                    self.dismiss(animated: true) {
                        guard let specialoffer = self.specialOffer, let claimHistory = data.response, let venue = self.venueModel else { return }
                        let successData: [String: Any] = ["data": claimHistory, "isFromBrunch" : true, "specialOffer": specialoffer, "venue": venue]
                        NotificationCenter.default.post(name: .openClaimSuccessCard, object: nil, userInfo: successData)
                    }
                } else {
                    if let object = data.objToSend, let claimHistory = data.response {
                        self._startCheckOut(data: object, historyModel: claimHistory)
                    } else if let tabby = data.tabby, let claimHistory = data.response {
                        self._startTabbyCheckOut(data: tabby, historyModel: claimHistory)
                    } else {
                        self.showToast("somthing went wrong....!")
                        self.dismiss(animated: true)
                    }
                }
            }
        }
    }
    
    private func _requestBrunchOffersList() {
        showHUD()
        WhosinServices.getBrunchBySpecialOffer(specialOfferId: specialOffer?.id ?? kEmptyString, callback:  { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            if let data = container?.data {
                self.specialOffer = data
                if let offer = data.offers {
                    if !offer.isAllowedClaim && offer.venueId == self.venueModel?.id {
                        self.selectedOffer = offer
                    } else {
                        self.showAlert()
                    }
                }
                else {
                    self.showAlert()
                }
                self._loadData()
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    private func showAlert() {
        alert(title: kAppName, message: "no_offer_available_for_branch".localized()) { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }
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
    
    @IBAction func _handleOpenBottomSheet(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            UIView.animate(withDuration: 1) {
                self._hightConstraint.constant = self.height
            }
        } else {
            sender.isSelected = true
            UIView.animate(withDuration: 1) {
                self._hightConstraint.constant = 0
            }
        }
        self.view.layoutIfNeeded()
    }
    
    @IBAction private func _handleClaimNowEvent(_ sender: UIButton) {
        
        let totalAmount = brunchs.compactMap { ($0["pricePerBrunch"] as? Int ?? 0) * ($0["qty"] as? Int ?? 0) }.reduce(0, +)

        if (brunchs.compactMap { $0["qty"] as? Int }.reduce(0, +) == 0)  {
            alert(title: kAppName, message: "please_enter_add_item_to_claim".localized())
            return
        }

        if brunchs.isEmpty {
            alert(title: kAppName, message: "please_enter_add_item_to_claim".localized())
            return
        }
        if Utils.stringIsNullOrEmpty(_totalAmmount.text) {
            alert(title: kAppName, message: "please_enter_add_item_to_claim".localized())
            return
        }
        if Utils.stringIsNullOrEmpty(_otpTxt) {
            alert(title: kAppName, message: "please_enter_claim_code".localized())
            return
        }
        
//        var updatedBrunchs = brunchs
//         for index in updatedBrunchs.indices {
//             var brunch = updatedBrunchs[index]
//             if let discountPercent = brunch["discountPercent"] as? String, discountPercent == "50" {
//                 let qty = brunch["qty"] as? Int ?? 0
//                 brunch["qty"] = qty * 2
//                 brunch.removeValue(forKey: "discountPercent")
//             }
//             updatedBrunchs[index] = brunch
//         }


        confirmAlert(message: LANGMANAGER.localizedString(forKey: "special_discount_payment_alert", arguments: ["value": "\(totalAmount)"]) , okHandler: { [weak self] action in
            guard let self = self else { return }
            var params: [String: Any] = [:]
            params["claimCode"] = self._otpTxt
            params["totalPerson"] = ""
            params["specialOfferId"] = self.specialOffer?.id
            params["venueId"] = self.specialOffer?.venueId
            params["type"] = "brunch"
            params["brunch"] = self.brunchs
            params["currency"] = "aed"
            params["billAmount"] = ""
            params["amount"] = totalAmount
            if totalAmount == 0 {
                _requestClaimOffer(params)
            } else {
                self._openPaymentOptions(data: params)
            }
        })
    }
    
    private func _openPaymentOptions(data: [String: Any]) {
        var params = data
        let bottomSheet = PaymentBottomSheet()
        bottomSheet.tabbyAction = {
            params["paymentMethod"] = "tabby"
            self._requestClaimOffer(params, true)
        }
        bottomSheet.applePayAction = {
            params["paymentMethod"] = "stripe"
            self._requestClaimOffer(params, false)
        }
        bottomSheet.creditCardAction = {
            params["paymentMethod"] = "stripe"
            self._requestClaimOffer(params, false)
        }
        bottomSheet.viaLinkAction = {
            params["paymentMethod"] = "stripe"
            self._requestClaimOffer(params, false)
        }
        bottomSheet.show(in: self)
    }
    
    @IBAction private func _handleBackEvent(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

extension ClaimBrunchVC: CustomNoKeyboardTableViewDelegate, UITableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? ClaimItemCell {
            guard let object = cellDict?[kCellObjectDataKey] as? PackageModel,
                  let specialDiscount = cellDict?[kCellTitleKey] as? Int  else { return }
            cell.setupData(object,specialDiscount: specialDiscount,isFromSucces: false, callback: { (data, error) in
                if let qty = data?["qty"] as? Int {
                    let amount = object.amount * qty
                    let totalAmount = amount
                    let discountPrice = Utils.calculateDiscountValue(originalPrice: Int(object.amount), discountPercentage: Int(object.discount))
                    self._totalAmmount.text = APPSESSION.userDetail?.isVip == true ? "free" : "D\(discountPrice)"
                    self._totalPackage.text = "D\(totalAmount)"
                    self._claimCharge.text = APPSESSION.userDetail?.isVip == true ? "free" : "D\(qty * object.pricePerBrunch)"
//                    let discountPrice = Utils.calculateDiscountValue(originalPrice: Int(object.amount), discountPercentage: Int(object.discount))
                    if let price = Int(discountPrice) {
                        let discount = price * qty
                        self.perPersionAmount = qty * object.pricePerBrunch
                        self._discounted.text = "D\(totalAmount - discount)"
                        self._totalAmmount.text = APPSESSION.userDetail?.isVip == true ? "free" : /*object.discount == "50" ? "D\(totalAmount)" :*/ "D\(discount)"
                        self._totalPrice = discount
//                        if object.discount == "50" {
//                            let item: [String: Any] = ["itemId": object.id, "item": object.title, "discount": totalAmount - discount, "qty": qty, "pricePerBrunch": object.pricePerBrunch, "amount": totalAmount, "discountPercent": object.discount]
//                            self.updateOrAppendBrunchs(item: item)
//                        } else {
                            let item: [String: Any] = ["itemId": object.id, "item": object.title, "discount": totalAmount - discount, "qty": qty, "pricePerBrunch": object.pricePerBrunch, "amount": totalAmount]
                            self.updateOrAppendBrunchs(item: item)
//                        }
//                        self.updateOrAppendBrunchs(item: item)
                        self.updateTotalUI(object)
                    }
                }
                
            })
        }
        
    }
    
    private func updateTotalUI(_ model: PackageModel) {
        let discountedAmount = brunchs.compactMap { $0["discount"] as? Int }.reduce(0, +)
        let totalAmount = brunchs.compactMap { $0["amount"] as? Int }.reduce(0, +)
        let claimCharge = brunchs.compactMap { ($0["pricePerBrunch"] as? Int ?? 0) * ($0["qty"] as? Int ?? 0) }.reduce(0, +)
        let totalPackage = totalAmount - discountedAmount

        self._discounted.text = "D\(discountedAmount)"
        self._totalAmmount.text = APPSESSION.userDetail?.isVip == true ? "free" : "D\(totalPackage)"
        self._claimCharge.text = APPSESSION.userDetail?.isVip == true ? "free" : "D\(claimCharge)"
        self._totalPackage.text = "D\(totalAmount)"
    }
    
    private func updateOrAppendBrunchs(item: [String: Any]) {
        if let itemId = item["itemId"] as? String {
            if let existingIndex = brunchs.firstIndex(where: { ($0["itemId"] as? String) == itemId }) {
                if item["qty"] as? Int == 0 {
                    brunchs.remove(at: existingIndex)
                } else {
                    brunchs[existingIndex] = item
                }
            } else {
                brunchs.append(item)
            }
        }
    }
    
    
}

// --------------------------------------
// MARK: TextField Delegate
// --------------------------------------

extension ClaimBrunchVC: UITextFieldDelegate {
    
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

extension ClaimBrunchVC: GetSelectedOfferDelegate {
    func didSelectedOffer(_ model: OffersModel) {
        selectedOffer = model
        setupUi()
    }
}
