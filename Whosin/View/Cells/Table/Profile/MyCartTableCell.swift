import UIKit

class MyCartTableCell: UITableViewCell {

    @IBOutlet private weak var _discountedPrice: UILabel!
    @IBOutlet private weak var _orignalprice: UILabel!
    @IBOutlet private weak var _countValue: UILabel!
    @IBOutlet private weak var _packageDesc: UILabel!
    @IBOutlet private weak var _packageName: UILabel!
    @IBOutlet private weak var _discountView: GradientView!
    @IBOutlet private weak var _discountBadge: UILabel!
    @IBOutlet private weak var _venueAddress: UILabel!
    @IBOutlet private weak var _venueName: UILabel!
    @IBOutlet private weak var _logoImageVew: UIImageView!
    @IBOutlet weak var _dateTime: UILabel!
    @IBOutlet weak var _type: UILabel!
    @IBOutlet weak var _promoDiscountValue: CustomLabel!
    @IBOutlet weak var _promoBgView: UIView!
    @IBOutlet weak var _badgeView: UIView!
    private var stepperValue: Int = 0
    private var _cartModel: CartModel?

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
        self._badgeView.roundCorners(corners: [.topLeft, .bottomRight], radius: 8)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func updateLabel() {
        _countValue.text = "\(stepperValue)"
        guard let cartModel = _cartModel?.detached() else { return }
        cartModel.quantity = stepperValue
        if cartModel.type == "activity" {
            cartModel.activityDate = _cartModel?.activityDate ?? kEmptyString
            cartModel.activityTime = _cartModel?.activityTime ?? kEmptyString
        }
        let repo = CartRepository()
        repo.addToCartItem(model: cartModel ) { updated in
            NotificationCenter.default.post(name: Notification.Name("addtoCartCount"), object: nil, userInfo: nil)
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ model: CartModel, promoModel: PromoBaseModel?) {
        _cartModel = model
        let repo = CartRepository()
        let data = repo.getCountById(id: model.id)
        
        // Stepper Setup
        if let firstData = data.first {
            _countValue.text = "\(firstData.quantity)"
            stepperValue = firstData.quantity
        } else {
            _countValue.text = "0"
            stepperValue = 0
        }
        
        // Venue Details
        _logoImageVew.loadWebImage(model.venueLogo)
        _venueName.text = model.venueName
        _venueAddress.text = model.venueAddress
        
        // Discount Handling
        let discountValue = model.type == "deal" ? "\(model.discount)" : model.discountValue
        let hasDiscount = discountValue != "0" && discountValue != kEmptyString
        _discountBadge.text = discountValue.hasSuffix("%") ? discountValue : "\(discountValue)%"
        _discountView.isHidden = !hasDiscount
        
        // Package/Deal Info
        _packageName.text = model.title
        _packageDesc.text = model.descriptions
        
        // Date & Time Formatting
        if model.type == "deal" {
            _dateTime.text = model.endTime
        } else {
            _dateTime.text = model.type == "activity"
                ? "activity_date".localized() + "\(model.activityDate)\n" + "activity_time".localized() + "\(model.activityTime)"
                : "valid_till".localized() + "\(Utils.dateToString(model.endDate, format: kFormatDateDOB))"
        }
        
        _type.text = model.type.capitalized
        
        // Price Handling
        _orignalprice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(model.originalPrice)".strikethrough().withCurrencyFont(17)
        _orignalprice.isHidden = model.originalPrice == 0 || Float(model.originalPrice) == model.floatDiscountedPrice
        _discountedPrice.attributedText = String(format: "\(Utils.getCurrentCurrencySymbol()) %.0f", model.floatDiscountedPrice).withCurrencyFont(16)
        
        // Promo Code Handling
        guard promoModel?.promoDiscountType != "flat" else { return }
        if let metadata = promoModel?.metadata.first(where: { $0.packageId == model.id && $0.type != "deal" }) {
            let discount = Int(round(metadata.finalDiscountInPercent))
            let promoDiscount = Int(round(metadata.promoDiscountInPercent))
            let price = Int(metadata.finalAmount) / metadata.qty
            _promoDiscountValue.text = LANGMANAGER.localizedString(forKey: "promo_code_applied_discount_added", arguments: ["value": "\(promoDiscount)"])
            _promoBgView.isHidden = false
            _discountedPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(Int(round(Double(price))))".withCurrencyFont(16)
            _discountBadge.text = "\(discount)%"
            _discountView.isHidden = discount == 0
        } else if let metadata = promoModel?.metadata.first(where: { $0.dealId == model.dealId }) {
            let discount = Int(round(metadata.finalDiscountInPercent))
            let promoDiscount = Int(round(metadata.promoDiscountInPercent))
            let price = Int(metadata.finalAmount) / metadata.qty
            _promoDiscountValue.text = LANGMANAGER.localizedString(forKey: "promo_code_applied_discount_added", arguments: ["value": "\(promoDiscount)"])
            _promoBgView.isHidden = false
            _discountedPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(Int(round(Double(price))))".withCurrencyFont(16)
            _discountBadge.text = "\(discount)%"
            _discountView.isHidden = discount == 0
        }else {
            _promoBgView.isHidden = true
        }
    }

    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @IBAction private func _handleCounterMinusEvent(_ sender: UIButton) {
        if stepperValue != 0 { stepperValue -= 1 }
        self.parentBaseController?.feedbackGenerator?.impactOccurred()
        updateLabel()
    }
    
    @IBAction private func _handleCounterPlushEvent(_ sender: UIButton) {
        if _cartModel?.type == "offer" || _cartModel?.type == "event" {
            if stepperValue < _cartModel?.maxQty ?? 0 {
                stepperValue += 1
                self.parentBaseController?.feedbackGenerator?.impactOccurred()
                updateLabel()
            }
        } else {
            stepperValue += 1
            self.parentBaseController?.feedbackGenerator?.impactOccurred()
            updateLabel()
        }
    }
    
}
