import UIKit

class TourOptionsCollectionCell: UICollectionViewCell {

    @IBOutlet private weak var _tourTitle: CustomLabel!
    @IBOutlet private weak var _tourDesc: CustomLabel!
    @IBOutlet private weak var _duration: CustomLabel!
    @IBOutlet private weak var _minPax: CustomLabel!
    @IBOutlet private weak var _maxPax: CustomLabel!
    @IBOutlet private weak var _cancellationPolcy: CustomLabel!
    @IBOutlet private weak var _startingPrice: CustomLabel!
    @IBOutlet private weak var _childAge: CustomLabel!
    @IBOutlet private weak var _infantAge: CustomLabel!
    @IBOutlet private weak var _transferName: CustomLabel!
    @IBOutlet private weak var _durationStack: UIStackView!
    @IBOutlet private weak var _childAgeStack: UIStackView!
    @IBOutlet private weak var _infantAgeStack: UIStackView!
    @IBOutlet private weak var _paxDetail: UIStackView!
    @IBOutlet private weak var _maxPaxStack: UIStackView!
    @IBOutlet private weak var _minPaxStack: UIStackView!
    @IBOutlet private weak var _cancellationPolicyStack: UIStackView!
    @IBOutlet weak var _discountValue: CustomLabel!
    @IBOutlet weak var _customGallaryView: CustomGallaryView!
    @IBOutlet weak var _transferNameView: UIStackView!
    
    var optionModel: TourOptionDataModel?

    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat { 418}
    class var heightForNotAllowPax: CGFloat { 395 }
    

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: TicketModel, option: TourOptionDataModel) {
        optionModel = option
        let images = option.images.toArray(ofType: String.self).isEmpty ? data.images.toArray(ofType: String.self) : option.images.toArray(ofType: String.self)
        _customGallaryView.setupHeader(images.filter({ !Utils.isVideo($0) } ), pageControl: true)
        _tourDesc.text = "\(option.optionDescription)";
        _transferName.text = option.transferName
        _tourTitle.text = option.optionName
        _duration.text = option.duration
        _minPax.text = option.minPax
        _maxPax.text = option.maxPax
        _cancellationPolcy.text = option.cancellationPolicy
        _transferNameView.isHidden = option.transferName.lowercased() == "without transfers" || Utils.stringIsNullOrEmpty(option.transferName)
        
        let currencySymbol = NSAttributedString(
            string: " \(Utils.getCurrentCurrencySymbol())",
            attributes: [.foregroundColor: UIColor.white, .font: APPSESSION.userDetail?.currency == "AED" || APPSESSION.userDetail?.currency == "D" ? FontBrand.dirhamText(size: 15) : FontBrand.SFboldFont(size: 15)]
        )
        let discountedPrice = NSAttributedString(
            string: "\(option.finalAmount.formattedDecimal())",
            attributes: [.foregroundColor: UIColor.white, .font: FontBrand.SFboldFont(size: 17)] // optional: make discounted price black
        )
        let finalText = NSMutableAttributedString()
        finalText.append(currencySymbol)
        finalText.append(discountedPrice)
        _startingPrice.attributedText = finalText
        
        _discountValue.attributedText = " \(Utils.getCurrentCurrencySymbol())\(option.withoutDiscountAmount.hideFloatingValue())".strikethrough().withCurrencyFont(15)
        _discountValue.isHidden = !option.hasDiscount
        _durationStack.isHidden = Utils.stringIsNullOrEmpty(option.duration)
        _minPaxStack.isHidden = option.minPax == "0"
        _maxPaxStack.isHidden = option.maxPax == "0"
        _paxDetail.isHidden = option.minPax == "0" && option.maxPax == "0"
        _infantAge.text = option.infantAge
        _childAge.text = option.childAge
        _childAgeStack.isHidden = !option.disableChild ? Utils.stringIsNullOrEmpty(option.childAge) : true
        _infantAgeStack.isHidden = !option.disableInfant ? Utils.stringIsNullOrEmpty(option.infantAge) : true
        _cancellationPolicyStack.isHidden = Utils.stringIsNullOrEmpty(option.cancellationPolicy)
    }
    
    @IBAction func _handleMoreinfoEvent(_ sender: CustomButton) {
        let vc = INIT_CONTROLLER_XIB(MoreInfoBottomSheet.self)
        vc.ticketId = BOOKINGMANAGER.ticketModel?._id ?? ""
        vc.optionID = optionModel?.tourOptionId ?? ""
        vc.tourId = optionModel?.tourId ?? ""
        self.parentBaseController?.navigationController?.present(vc, animated: true)
    }
    
}
