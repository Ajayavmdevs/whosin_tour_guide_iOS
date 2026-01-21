import UIKit

class ClaimItemCell: UITableViewCell {
    
    @IBOutlet private weak var _discountChagerWidth: NSLayoutConstraint!
    @IBOutlet private weak var _chargesPerPersion: UILabel!
    @IBOutlet private weak var _plushBtn: UIButton!
    @IBOutlet private weak var _minusBtn: UIButton!
    @IBOutlet private weak var _packageName: UILabel!
    @IBOutlet private weak var _priceLabel: UILabel!
    @IBOutlet private weak var _orignalPrice: UILabel!
    @IBOutlet private weak var _stepperLabel: UILabel!
    private var stepperValue: Int = 0
    private var stepperMaxValue: Int = 8
    private var _callback: JsonResult?
    private var _discount: String = kEmptyString
    private var _packageModel: PackageModel?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ model: PackageModel,specialDiscount: Int = 0,isFromSucces: Bool, callback: JsonResult?) {
        _callback = callback
        _packageModel = model
        if isFromSucces {
            stepperValue = model.remainingQty
            _minusBtn.isHidden = true
            _plushBtn.isHidden = true
            
            _orignalPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(model.amount)".strikethrough().withCurrencyFont(11)
            _packageName.text = model.title
            let discount = Utils.calculateDiscountValue(originalPrice: Int(model.amount), discountPercentage: Int(model.discount))
            _discount = discount
            _priceLabel.attributedText = "\(Utils.getCurrentCurrencySymbol())\(discount)".withCurrencyFont(11)
            _orignalPrice.isHidden = model._isNoDiscount
            _discount = model._isNoDiscount ? "0" : discount
        } else {
            stepperValue = 0
            _orignalPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(model.amount)".strikethrough().withCurrencyFont(11)
            _chargesPerPersion.attributedText = makeChargesText(price: model.pricePerBrunch, defaultFont: _chargesPerPersion.font, dirhamFont: FontBrand.dirhamText(size: 14))
            _packageName.text = model.title
            let discount = Utils.calculateDiscountValue(originalPrice: Int(model.amount), discountPercentage: Int(model.discount))
            _discount = discount
            _priceLabel.attributedText = "\(Utils.getCurrentCurrencySymbol())\(discount)".withCurrencyFont(11)
            _orignalPrice.isHidden = model._isNoDiscount
            _discount = model._isNoDiscount ? "0" : discount
//            if model.discount == "50" {
//                _orignalPrice.isHidden = true
//                _priceLabel.text = "D\(model.amount)"
//            }
        }
    }
    
    func makeChargesText(price: Int, defaultFont: UIFont, dirhamFont: UIFont) -> NSAttributedString {
        let fullText = "charges_per_claim".localized() + "(\(Utils.getCurrentCurrencySymbol())\(price))"
        let attributed = NSMutableAttributedString(string: fullText, attributes: [.font: defaultFont])

        if let dRange = fullText.range(of: "D") {
            let nsRange = NSRange(dRange, in: fullText)
            attributed.addAttribute(.font, value: dirhamFont, range: nsRange)
        }

        return attributed
    }

    
    public func setupBruncData(_ model: BrunchModel) {
        _chargesPerPersion.isHidden = true
        _discountChagerWidth.constant = 0
        stepperValue = model.qty
        updateLabel()
        _minusBtn.isHidden = true
        _plushBtn.isHidden = true
        _orignalPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(model.amount + model.discount)".strikethrough().withCurrencyFont(11)
        _packageName.text = model.item
        _discount = String(model.discount)
        _priceLabel.attributedText = "\(Utils.getCurrentCurrencySymbol())\(model.amount)".withCurrencyFont(11)
        _stepperLabel.text = "\(model.qty)"
        _orignalPrice.isHidden = model.amount == model.discount || model.amount == 0
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func updateLabel() {
        _stepperLabel.text = "\(stepperValue)"
        _updateCallBack()
    }
    
    private func _updateCallBack() {
        var dict: [String : Any] = [:]
        dict["qty"] = stepperValue
        dict["discount"] = _discount
        _callback?(dict, nil)
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @IBAction private func _handleStepMinusEvennt(_ sender: Any) {
        if stepperValue != 0 { stepperValue -= 1 }
        updateLabel()
    }
    
    @IBAction private func _handelStepperPlushEvent(_ sender: Any) {
        if stepperValue < stepperMaxValue {
            stepperValue += 1
            
        }
        updateLabel()
    }

}


