import UIKit

class PackageOfferTableCell: UITableViewCell {
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var discountBgView: GradientView!
    @IBOutlet private weak var _totalQty: UILabel!
    @IBOutlet private weak var _widthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var _descriptionTxt: UILabel!
    @IBOutlet private weak var _plushBtn: UIButton!
    @IBOutlet private weak var _minusBtn: UIButton!
    @IBOutlet private weak var _badgeView: CustomBadgeView!
    @IBOutlet private weak var _packageValue: UILabel!
    @IBOutlet private weak var _packageName: UILabel!
    @IBOutlet private weak var _stepperLabel: UILabel!
    @IBOutlet weak var _stepperStack: UIStackView!
    @IBOutlet weak var _soldOutText: UILabel!
    @IBOutlet weak var _promoDiscountValue: CustomLabel!
    @IBOutlet weak var _promoBgView: UIView!
    private var stepperValue: Int = 0
    private var _packageModel: PackageModel?
    private var _venueModel: VenueDetailModel?
    private var _eventModel: EventModel?
    public var isEvent: Bool = false
    
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
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleStepMinusEvennt(_ sender: Any) {
        if stepperValue != 0 {
            stepperValue -= 1
        }
        updateLabel()
    }
    
    @IBAction private func _handelStepperPlushEvent(_ sender: Any) {
        if stepperValue < _packageModel?.remainingQty ?? 0 {
            stepperValue += 1
            updateLabel()
        }
    }
    
    func updateLabel() {
        _stepperLabel.text = "\(stepperValue)"
        guard let _venueModel = _venueModel, let _vouchersModel = _packageModel else { return }
        NotificationCenter.default.post(name: Notification.Name("addtoCartCount"), object: nil, userInfo: nil)
        
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ model: PackageModel, venueModel: VenueDetailModel?, isOfferDetail: Bool = false, promoModel: PromoBaseModel?) {
        _stepperLabel.isHidden = isOfferDetail
        _minusBtn.isHidden = isOfferDetail
        _plushBtn.isHidden = isOfferDetail
        _descriptionTxt.text = model.descriptions
        _totalQty.text = "remaining_quantity".localized() + "\(model.remainingQty)"
        _totalQty.isHidden = !model.isShowLeftQtyAlert
        if model.remainingQty <= 3 {
            _totalQty.textColor = .red
        } else {
            _totalQty.textColor = ColorBrand.amberColor
        }
        _stepperStack.isHidden = model.remainingQty <= 0 || !model.isAllowSale
        _soldOutText.isHidden = model.remainingQty > 0 || !model.isAllowSale
        _venueModel = venueModel
        _packageModel = model
        if let metadata = promoModel?.metadata.first(where: { $0.packageId == model.id }), promoModel?.promoDiscountType != "flat" {
            _promoBgView.isHidden = false
            let amount = Int(round(metadata.finalAmount))
            let discount = Int(round(metadata.finalDiscountInPercent))
            let promoDiscount = Int(round(metadata.promoDiscountInPercent))
            let discountedValue = Utils.calculateDiscountValueFloat(originalPrice: model.actualPrice, discountPercentage: discount)
            let price = Int(metadata.finalAmount) / metadata.qty
            _promoDiscountValue.text = LANGMANAGER.localizedString(forKey: "promo_code_applied_discount_added", arguments: ["value": "\(promoDiscount)"])
            _promoBgView.isHidden = false
            DISPATCH_ASYNC_MAIN_AFTER(0.02) {
                self._badgeView.setupData(originalPrice: model.actualPrice, discountedPrice: "\(price)", isNoDiscount: metadata.finalDiscountInPercent == 0)
            }
            if metadata.promoDiscountInPercent == 0 {
                if model.discount == "0%" || model.discount == "0" {
                    _widthConstraint.constant = 0
                    leadingConstraint.constant = 0
                } else {
                    _widthConstraint.constant = 44
                    leadingConstraint.constant = 8
                }
                if model.discount.hasSuffix("%") {
                    _packageValue.text = model.discount
                } else {
                    _packageValue.text = model.discount + "%"
                }
            } else {
                _widthConstraint.constant = 44
                leadingConstraint.constant = 8
                _packageValue.text = "\(discount)%"
            }
        } else {
            _promoBgView.isHidden = true
            _badgeView.setupData(originalPrice: model.actualPrice, discountedPrice: Utils.formatDiscountValue(model._flootdiscountedPrice), isNoDiscount: model._isNoDiscount)
            if model.discount == "0%" || model.discount == "0" {
                _widthConstraint.constant = 0
                leadingConstraint.constant = 0
            } else {
                _widthConstraint.constant = 44
                leadingConstraint.constant = 8
            }
            if model.discount.hasSuffix("%") {
                _packageValue.text = model.discount
            } else {
                _packageValue.text = model.discount + "%"
            }
        }
        _packageName.text = model.title

    }
    
    public func setupEventData(_ model: PackageModel,event: EventModel?, venueModel: VenueDetailModel?, promoModel: PromoBaseModel?) {
        isEvent = true
        _stepperLabel.isHidden = false
        _minusBtn.isHidden = false
        _plushBtn.isHidden = false
        _descriptionTxt.text = model.descriptions
        _totalQty.text = "remaining_quantity".localized() + "\(model.remainingQty)"
        _totalQty.isHidden = !model.isShowLeftQtyAlert
        if model.remainingQty <= 3 {
            _totalQty.textColor = .red
        } else {
            _totalQty.textColor = ColorBrand.amberColor
        }
        _stepperStack.isHidden = model.remainingQty <= 0 || !model.isAllowSale
        _soldOutText.isHidden = model.remainingQty > 0 || !model.isAllowSale
        _venueModel = venueModel
        _packageModel = model
        _eventModel = event
        if let metadata = promoModel?.metadata.first(where: { $0.packageId == model.id }), promoModel?.promoDiscountType != "flat" {
            _promoBgView.isHidden = false
            let amount = Int(round(metadata.finalAmount)) / stepperValue
            let discount = Int(round(metadata.finalDiscountInPercent))
            let promoDiscount = Int(round(metadata.promoDiscountInPercent))
            let discountedValue = Utils.calculateDiscountValueFloat(originalPrice: model.actualPrice, discountPercentage: discount)
            let price = Int(metadata.finalAmount) / metadata.qty
            _promoDiscountValue.text = LANGMANAGER.localizedString(forKey: "promo_code_applied_discount_added", arguments: ["value": "\(promoDiscount)"])
            _promoBgView.isHidden = false
            _badgeView.setupData(originalPrice: model.actualPrice, discountedPrice: "\(price)", isNoDiscount: metadata.finalDiscountInPercent == 0)
            if metadata.finalDiscountInPercent == 0 {
                let discout = "\(model.discounts)"
                if discout == "0%" || discout == "0" {
                    _widthConstraint.constant = 0
                } else {
                    _widthConstraint.constant = 44
                }
                if discout.hasSuffix("%") {
                    _packageValue.text = discout
                } else {
                    _packageValue.text = discout + "%"
                }
            } else {
                _widthConstraint.constant = 44
                leadingConstraint.constant = 8
                _packageValue.text = "\(discount)%"
            }
        } else {
            _promoBgView.isHidden = true
            _badgeView.setupData(originalPrice: model.actualPrice, discountedPrice: Utils.formatDiscountValue(model._flootdiscountedPrice), isNoDiscount: model._isNoDiscount)
            let discout = "\(model.discounts)"
            if discout == "0%" || discout == "0" {
                _widthConstraint.constant = 0
            } else {
                _widthConstraint.constant = 44
            }
            if discout.hasSuffix("%") {
                _packageValue.text = discout
            } else {
                _packageValue.text = discout + "%"
            }
        }
        _packageName.text = model.title
    }
    
}
