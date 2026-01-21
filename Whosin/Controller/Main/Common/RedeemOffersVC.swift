import UIKit
import StripePaymentSheet
import SwiftUI

class RedeemOffersVC: ChildViewController {
    
    @IBOutlet weak var maxQtyLabel: UILabel!
    @IBOutlet weak var _badgebtn: UIButton!
    @IBOutlet weak var _stepperCount: UILabel!
    @IBOutlet weak var _packageDesc: UILabel!
    @IBOutlet weak var _packageName: UILabel!
    @IBOutlet weak var _titleLabel: UILabel!
    @IBOutlet weak var _subtitle: UILabel!
    @IBOutlet weak var _imageView: UIImageView!
    @IBOutlet weak var _offersTitle: UILabel!
    @IBOutlet weak var _offerDiscription: UILabel!
    @IBOutlet private weak var _textFieldFour: OTPTextField!
    @IBOutlet private weak var _textFieldThree: OTPTextField!
    @IBOutlet private weak var _textFieldTwo: OTPTextField!
    @IBOutlet private weak var _textFieldOne: OTPTextField!
    private var _otpCodeList: [UITextField] = []
    private var _otpTxt: String = kEmptyString
    private var params: [String: Any] = [:]
    public var voucherModel: VouchersListModel?
    public var package: PackageModel?
    private var stepperValue: Int = 0
    private var stepperMaxValue: Int = 1
    private var _packageId: String = kEmptyString
    public var callback: ((NSMutableAttributedString) -> Void)?
    // --------------------------------------
    // MARK: Life-Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DISPATCH_ASYNC_MAIN_AFTER(0.5) {
            self._badgebtn.roundCorners(corners: [.bottomLeft, .topRight], radius: 10)
        }
        setupUi()
    }
    
    override func setupUi() {
        hideNavigationBar()
        _otpCodeList = [
            _textFieldOne, _textFieldTwo, _textFieldThree, _textFieldFour
        ]
        for field in _otpCodeList {
            field.text = ""
            field.textAlignment = .center
            field.delegate = self
            field.keyboardType = .numberPad
        }
        if voucherModel?.type == "event" {
            guard let event = voucherModel?.event else { return }
            guard let item = voucherModel?.items.first(where: {$0.packageId == package?.id }) else { return }
            stepperMaxValue = item.remainingQty
            _offersTitle.text = event.title
            _offerDiscription.text = event.descriptions
            maxQtyLabel.text = "Remaining quantity: \(item.remainingQty)"
            updateLabel()
            if let package = self.package {
                _badgebtn.setTitle(package._discounts)
                _badgebtn.isHidden = package._discounts == "0%"
                _packageName.text = package.title
                _packageDesc.text = package.descriptions
                _packageId = package.id
            }
            if let venue = event.eventsOrganizer {
                _imageView.loadWebImage(venue.logo , placeholder: UIImage(named: "icon_user_avatar_default"))
                _titleLabel.text = venue.name
                _subtitle.text = venue.descriptions
            }
        } else {
            guard let offers = voucherModel?.offer else { return }
            guard let item = voucherModel?.items.first(where: {$0.packageId == package?.id }) else { return }
            stepperMaxValue = item.remainingQty
            _offersTitle.text = offers.title
            _offerDiscription.text = offers.descriptions
            maxQtyLabel.text = "remaining_quantity".localized() + "\(item.remainingQty)"
            updateLabel()
            if let package = self.package {
                _badgebtn.setTitle(package._discount)
                _badgebtn.isHidden = package._discount == "0%"
                _packageDesc.text = package.descriptions
                _packageName.text = package.title
                _packageId = package.id
            }
            if let venue = offers.venue {
                _imageView.loadWebImage(venue.logo , placeholder: UIImage(named: "icon_user_avatar_default"))
                _titleLabel.text = venue.name
                _subtitle.text = venue.address

            }
        }
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------

    private func _requestRedeem() {
        showHUD()
        WhosinServices.requestRedeemOffer(packageId: _packageId, qty: stepperValue, claimCode: _otpTxt, type: voucherModel?.type ?? "") { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container else { return }
            let attributedText = NSMutableAttributedString()
            attributedText.append(self.getBoldAttributedString(str: "\(self.stepperValue) \(self.package?.title ?? kEmptyString)"))
            attributedText.append(self.getRegularAttributedString(str: " at "))
            attributedText.append(self.getBoldAttributedString(str: self.voucherModel?.type == "event" ? "\(self.voucherModel?.event?.eventsOrganizer?.name ?? kEmptyString)" : "\(self.voucherModel?.offer?.venue?.name ?? kEmptyString)"))
            attributedText.append(self.getRegularAttributedString(str: "has_been_redeemed_successfully".localized()))

            NotificationCenter.default.post(name: Notification.Name("reloadMyWallet"), object: nil, userInfo: nil)
            DISPATCH_ASYNC_MAIN_AFTER(0.6) {
                self.dismiss(animated: true) {
                    self.callback?(attributedText)
                }
            }
        }
    }

    func getBoldAttributedString(str: String) -> NSAttributedString {
        let firstAttributedString = NSAttributedString(string: str, attributes: [NSAttributedString.Key.font: FontBrand.SFboldFont(size: 15), NSAttributedString.Key.foregroundColor: ColorBrand.white])
        return firstAttributedString
    }

    func getRegularAttributedString(str: String) -> NSAttributedString {
        let firstAttributedString = NSAttributedString(string: str, attributes: [NSAttributedString.Key.font: FontBrand.SFregularFont(size: 15, isItalic: false), NSAttributedString.Key.foregroundColor: ColorBrand.white.withAlphaComponent(0.7)])
        return firstAttributedString
    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func updateLabel() {
        _stepperCount.text = "\(stepperValue)"
    }

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
    
    @IBAction private func _handlePlushEvent(_ sender: UIButton) {
        if stepperValue < stepperMaxValue {
            stepperValue += 1
        }
        updateLabel()
    }
    
    @IBAction private func _handleMinusEvent(_ sender: UIButton) {
        if stepperValue != 0 { stepperValue -= 1 }
        updateLabel()
    }
    
    @IBAction private func _handleClaimNowEvent(_ sender: UIButton) {
        
        if Utils.stringIsNullOrEmpty(_stepperCount.text) || _stepperCount.text == "0" {
            alert(title: kAppName, message: "please_enter_quantity".localized())
            return
        }
        
        if Utils.stringIsNullOrEmpty(_otpTxt) {
            alert(title: kAppName, message: "please_enter_claim_code".localized())
            return
        }

        _requestRedeem()
    }
    
    @IBAction private func _handleBackEvent(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

// --------------------------------------
// MARK: TextField Delegate
// --------------------------------------

extension RedeemOffersVC: UITextFieldDelegate {
    
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
