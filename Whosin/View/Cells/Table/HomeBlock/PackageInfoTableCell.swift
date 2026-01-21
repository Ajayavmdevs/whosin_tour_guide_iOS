import UIKit

class PackageInfoTableCell: UITableViewCell {
    
    @IBOutlet private weak var _discountView: GradientView!
    @IBOutlet private weak var _coverImage: UIImageView!
    @IBOutlet private weak var _badgeView: CustomBadgeView!
    @IBOutlet private weak var _packageValue: UILabel!
    @IBOutlet private weak var _packageName: UILabel!
    @IBOutlet private weak var _discription: UILabel!
    @IBOutlet private weak var _validateDate: UILabel!
    @IBOutlet private weak var _stepperLabel: UILabel!
    @IBOutlet private weak var _expiredText: UILabel!
    @IBOutlet private weak var _stepperStack: UIStackView!
    @IBOutlet weak var _promoDiscountValue: CustomLabel!
    @IBOutlet weak var _promoBgView: UIView!
    private var stepperValue: Int = 0
    private var _vouchersModel: VoucharsModel?
    private var _dealsModel: DealsModel?
    private var _venueModel: VenueDetailModel?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        UITableView.automaticDimension
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        DISPATCH_ASYNC_MAIN_AFTER(0.2) {
            self._badgeView.roundCorners(corners: [.bottomLeft, .topRight], radius: 8)
            self._coverImage.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10)
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction func _handleStepMinusEvennt(_ sender: Any) {
        if stepperValue != 0 {
            stepperValue -= 1
        }
        updateLabel()
    }
    
    @IBAction func _handelStepperPlushEvent(_ sender: Any) {
        stepperValue += 1
        updateLabel()
    }
    
    func updateLabel() {
        _stepperLabel.text = "\(stepperValue)"
        let cartModel = BuyPackgeVC.tmpCart.first { $0.id == _dealsModel?.id }
        if cartModel != nil {
            cartModel?.quantity = stepperValue
        } else {
            guard let _dealsModel = _dealsModel else { return }
            guard let tmpModel = CartModel(dealsModel: _dealsModel) else { return }
            tmpModel.quantity = stepperValue
            BuyPackgeVC.tmpCart.append(tmpModel)
        }
        NotificationCenter.default.post(name: Notification.Name("addtoCartCount"), object: nil, userInfo: nil)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ model: VoucharsModel, venueModel: VenueDetailModel, promoModel: PromoBaseModel?) {
        _coverImage.cornerRadius = 10
        _coverImage.loadWebImage(venueModel.cover)
        if let qty = BuyPackgeVC.tmpCart.first(where: { $0.id == model.id })?.quantity {
            _stepperLabel.text = "\(qty)"
            stepperValue = qty
        } else {
            _stepperLabel.text = "0"
            stepperValue = 0
        }
        _venueModel = venueModel
        _vouchersModel = model
        if let metadata = promoModel?.metadata.first(where: { $0.packageId == model.id }), promoModel?.promoDiscountType != "flat" {
            let amount = Int(round(metadata.finalAmount))
            let discount = Int(round(metadata.finalDiscountInPercent))
            let promoDiscount = Int(round(metadata.promoDiscountInPercent))
            let discountedValue = Utils.calculateDiscountValueFloat(originalPrice: model.originalPrice, discountPercentage: discount)
            _promoDiscountValue.text = LANGMANAGER.localizedString(forKey: "promo_code_applied_discount_added", arguments: ["value": "\(promoDiscount)"])
            _promoBgView.isHidden = false
            _badgeView.setupData(originalPrice: model.originalPrice, discountedPrice: Utils.formatDiscountValue(discountedValue), isNoDiscount: metadata.finalDiscountInPercent == 0)
            _packageName.text = model.title
            if discount == 0 {
                if "\(model.discountValue)".hasSuffix("%") {
                    _packageValue.text = "\(model.discountValue)"
                } else {
                    _packageValue.text = "\(model.discountValue)%"
                }
            } else {
                _packageValue.text = "\(discount)%"
                _discountView.isHidden = discount == 0
            }
        } else {
            _badgeView.setupData(originalPrice: model.originalPrice, discountedPrice: "\(model.discountedPrice)", isNoDiscount: model.discountValue == "0")
            _packageName.text = model.title
            let discount = "\(model.discountValue)"
            if model.discountValue == "0" {
                if discount.hasSuffix("%") {
                    _packageValue.text = "\(model.discountValue)"
                } else {
                    _packageValue.text = "\(model.discountValue)%"
                }
            }
        }

        _discription.text = model.descriptions
        _validateDate.text = Utils.dateToString(model.endDate, format: "dd/MM/yyyy")
    }
    
    public func setupDealsData(_ model: DealsModel, promoModel: PromoBaseModel?) {
        _coverImage.cornerRadius = 10
        _coverImage.loadWebImage(model.image)
        if let qty = BuyPackgeVC.tmpCart.first(where: { $0.id == model.id })?.quantity {
            _stepperLabel.text = "\(qty)"
            stepperValue = qty
        } else {
            _stepperLabel.text = "0"
            stepperValue = 0
        }
        _venueModel = model.venueModel
        _dealsModel = model
        if let metadata = promoModel?.metadata.first(where: { $0.dealId == model.id }), promoModel?.promoDiscountType != "flat" {
            let amount = Int(round(metadata.finalAmount))
            let discount = Int(round(metadata.finalDiscountInPercent))
            let promoDiscount = Int(round(metadata.promoDiscountInPercent))
            let discountedValue = Utils.calculateDiscountValueFloat(originalPrice: model.actualPrice, discountPercentage: discount)
            let price = Int(metadata.finalAmount) / metadata.qty
            _promoDiscountValue.text = LANGMANAGER.localizedString(forKey: "promo_code_applied_discount_added", arguments: ["value": "\(promoDiscount)"])
            _promoBgView.isHidden = false
            _badgeView.setupData(originalPrice: model.actualPrice, discountedPrice: "\(price)", isNoDiscount: metadata.finalDiscountInPercent == 0)
            _packageName.text = model.title
            if discount == 0 {
                if model.discountValue == 0 {
                    if model.discountValues.hasSuffix("%") {
                        _packageValue.text = "\(model.discountValues)"
                    } else {
                        _packageValue.text = "\(model.discountValues)%"
                    }
                } else {
                    if "\(model.discountValue)".hasSuffix("%") {
                        _packageValue.text = "\(model.discountValue)"
                    } else {
                        _packageValue.text = "\(model.discountValue)%"
                    }
                }
            } else {
                _packageValue.text = "\(discount)%"
                _discountView.isHidden = discount == 0
            }
        } else {
            _promoBgView.isHidden = true
            _badgeView.setupData(originalPrice: model.actualPrice, discountedPrice: "\(model.discountedPrice)", isNoDiscount: model._isNoDiscount)
            _packageName.text = model.title
            let discount = "\(model.discountValue)"
            if model.discountValue == 0 {
                if model.discountValues.hasSuffix("%") {
                    _packageValue.text = "\(model.discountValues)"
                } else {
                    _packageValue.text = "\(model.discountValues)%"
                }
            } else {
                if discount.hasSuffix("%") {
                    _packageValue.text = "\(model.discountValue)"
                } else {
                    _packageValue.text = "\(model.discountValue)%"
                }
            }
        }
        _expiredText.isHidden = !model._isExpired
        _stepperStack.isHidden = model._isExpired 
        _discription.text = model.descriptions
        _validateDate.text = model.endDate
    }
    
}
