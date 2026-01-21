import UIKit

class OptionsAmountTableCell: UITableViewCell {
    
    @IBOutlet weak var _totalAmountTitle: CustomLabel!
    @IBOutlet weak var _discountTitle: CustomLabel!
    @IBOutlet private weak var _totalPrice: CustomLabel!
    @IBOutlet private weak var _discountPrice: CustomLabel!
    @IBOutlet private weak var _finalPrice: CustomLabel!
    @IBOutlet private weak var _discountStack: UIStackView!
    @IBOutlet private weak var _finalAmountStack: UIStackView!
    @IBOutlet private weak var _vatPercentage: UIStackView!
    @IBOutlet private weak var _vatTitle: CustomLabel!
    @IBOutlet private weak var _vatAmmount: CustomLabel!
    @IBOutlet private weak var _promoCodeStack: UIStackView!
    @IBOutlet private weak var _promoCodePrice: CustomLabel!
    @IBOutlet weak var _pricePerTrip: UIStackView!
    @IBOutlet weak var _addonPrice: UIStackView!
    @IBOutlet weak var _pricePerTripText: CustomLabel!
    @IBOutlet weak var _addonPriceTxt: CustomLabel!
    
    private var _tourOption: TourOptionsModel?

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ dataList: [TourOptionDetailModel], discount: Int = 0, promo: PromoBaseModel?) {
        let priceModel = BOOKINGMANAGER.calculateTourTotals(promo: promo)
        
        _vatPercentage.isHidden = true
        _promoCodeStack.isHidden = promo == nil
        _addonPrice.isHidden = priceModel.totalAddOnAmout <= 0
        _addonPriceTxt.attributedText = "\(Utils.getCurrentCurrencySymbol())\(priceModel.totalAddOnAmout)".withCurrencyFont(14)
        _promoCodePrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(promo?.promoDiscount.formattedDecimal() ?? "")".withCurrencyFont(14, false)
        _totalPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(priceModel.totalAmount.formattedDecimal())".withCurrencyFont(14, false)
        _discountPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(priceModel.discountPrice.formattedDecimal())".withCurrencyFont(14, false)
        _finalPrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(priceModel.priceWithPromo.formattedDecimal())".withCurrencyFont(14)
        _discountStack.isHidden = priceModel.discountPrice <= 0
        _pricePerTrip.isHidden = BOOKINGMANAGER.ticketModel?.bookingType != "travel-desk"
        _pricePerTripText.attributedText = "\(Utils.getCurrentCurrencySymbol())\(priceModel.pricePerTrip)".withCurrencyFont(14, false)

    }
    
    public func setupData(_ dataList: JPPriceModel, discount: Int = 0, promo: PromoBaseModel?) {
        let priceModel = HOTELBOOKINGMANAGER.calculateTourTotals(promo: promo)

        _totalAmountTitle.text = "base_price".localized()
        _discountTitle.text = "service_fees".localized()
        _vatPercentage.isHidden = true
        _addonPrice.isHidden = priceModel.totalAddOnAmout <= 0
        _addonPriceTxt.attributedText = "\(Utils.getCurrentCurrencySymbol())\(priceModel.totalAddOnAmout)".withCurrencyFont(14)
        _promoCodeStack.isHidden = promo == nil
        _promoCodePrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(promo?.promoDiscount.formattedDecimal() ?? "")".withCurrencyFont(14)
        _discountPrice.text = dataList.serviceTaxes?.amount
        _discountStack.isHidden =  Utils.stringIsNullOrEmpty(dataList.serviceTaxes?.amount)
        _totalPrice.text = dataList.amount
        _finalPrice.text = "\(priceModel.priceWithPromo)"
        _pricePerTrip.isHidden = true
    }
}
