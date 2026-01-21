import UIKit
import StripePaymentSheet
import StripeCore
import IQKeyboardManagerSwift

protocol openSuccessDelegate {
    func openpurchaseSuccessDialogue()
}

class SubscriptionPurchaseVC: ChildViewController {

    @IBOutlet weak var _promoCodeView: UIView!
    @IBOutlet weak var _totalAmount: UILabel!
    @IBOutlet weak var _chekOutPrice: UILabel!
    @IBOutlet weak var _discountView: UIView!
    @IBOutlet weak var _errorText: UILabel!
    @IBOutlet weak var _discountPrice: UILabel!
    @IBOutlet weak var _discoun: UILabel!
    @IBOutlet weak var _imgView: UIImageView!
    @IBOutlet weak var bottomConatraint: NSLayoutConstraint!
    @IBOutlet weak var _promoCodeText: UITextField!
    @IBOutlet weak var _discountText: UILabel!
    @IBOutlet weak var _priceOfPackage: UILabel!
    @IBOutlet weak var _timeOfPackage: UILabel!
    @IBOutlet weak var _subtitleText: UILabel!
    @IBOutlet weak var _titleText: UILabel!
    var membershipDetail: MembershipPackageModel?
    public var paymentSheet: PaymentSheet?
    public var delegate: openSuccessDelegate?
    private var checkOutAmount: String = kEmptyString
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupUi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    private func _setupUi() {
        _discountText.text = membershipDetail?.discountText
        _titleText.text = membershipDetail?.title
        _subtitleText.text = membershipDetail?.subTitle
        _timeOfPackage.text = "validity".localized() + "\(membershipDetail?.time ?? kEmptyString)"
        _priceOfPackage.text = "D\(membershipDetail?.actualPrice ?? 0)"
        _promoCodeText.delegate = self
        _chekOutPrice.text =  "D\(membershipDetail?.actualPrice ?? 0)"
        checkOutAmount = "\(membershipDetail?.actualPrice ?? 0)"
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func applyPromoCode() {
        self.showHUD()
        guard let id = membershipDetail?.id else { return }
        WhosinServices.applyPromoCode(id: id, amount: checkOutAmount, promoCode: _promoCodeText.text ?? kEmptyString, type: .membershipPackage, apply: false) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD()
            if error != nil {
                self._errorText.text = error?.localizedDescription
                self._errorText.isHidden = false
                self._discountView.isHidden = true
                self._imgView.image = UIImage(named: "icon_invalidCode")
                _chekOutPrice.text =  "D\(membershipDetail?.actualPrice ?? 0)"
                self._promoCodeView.borderWidth = 0
                return
            }
            guard let data = container?.data else { return }
            self._discountView.isHidden = false
            self._errorText.isHidden = true
            self._discoun.text = "\(data.promoCodeInfo?.discountPercent ?? kEmptyString)"
            self._discountPrice.text = "D\(data.discountAmount)"
            self._chekOutPrice.text =  "D\(data.finalAmount)"
            self._totalAmount.text = "D\(data.finalAmount)"
            self.checkOutAmount = "\(data.finalAmount)"
            self._imgView.image = UIImage(named: "icon_selectedGreen")
            self._promoCodeView.borderWidth = 1
        }
    }

    @objc private func keyboardWillShow(notification: Notification) {
        
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            self.bottomConatraint.constant = keyboardHeight - 100
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        self.bottomConatraint.constant = 15
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func _handleBackEvent(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func _handleCheckOut(_ sender: UIButton) {
        guard let id = membershipDetail?.id, let ammount = membershipDetail?.actualPrice else { return }
        let params: [String: Any] = ["membershipPackageId" : id, "amount": ammount, "currency": "aed", "promoCode": _promoCodeText.text ?? kEmptyString]
        PAYMENTMANAGER.showPaymentOptions(in: self, params: params,isTabbyDisable: ammount < 10, purchaseType: .membership) { result in
            switch result {
            case .success:
                self.navigationController?.popViewController(animated: true)
                if let model = self.membershipDetail {
                    self.delegate?.openpurchaseSuccessDialogue()
                }
                APPSESSION.userDetail?.isMembershipActive = true
            case .cancelled:
                self.hideHUD()
            case .failure(let error):
                self.hideHUD()
            }
        }
    }
}

extension SubscriptionPurchaseVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text?.isEmpty == false {
            applyPromoCode()
        }
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        _promoCodeView.borderWidth = 1
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text,
              let stringRange = Range(range, in: currentText) else {
            return false
        }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if updatedText.isEmpty {
            _chekOutPrice.text =  "D\(membershipDetail?.actualPrice ?? 0)"
            self.checkOutAmount = "\(membershipDetail?.actualPrice ?? 0)"
            self._imgView.image = UIImage(named: "icon_deselcetCode")
            self._discountView.isHidden = true
            self._errorText.isHidden = true
            _promoCodeView.borderWidth = 0
        }
        return true
    }

}
