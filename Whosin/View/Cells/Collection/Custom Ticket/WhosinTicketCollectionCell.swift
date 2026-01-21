import UIKit

class WhosinTicketCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var _imagesGallery: CustomGallaryView!
    @IBOutlet weak var _title: CustomLabel!
    @IBOutlet weak var _description: CustomLabel!
    @IBOutlet weak var _days: CustomLabel!
    @IBOutlet weak var _startDate: CustomLabel!
    @IBOutlet weak var _endDate: CustomLabel!
    @IBOutlet weak var _discountValue: CustomLabel!
    @IBOutlet weak var _availabilityTime: CustomLabel!
    @IBOutlet weak var _totalSeats: CustomLabel!
    @IBOutlet weak var seatTitle: CustomLabel!
    
    private var model: TourOptionsModel?
    private var travelDesk: TourOptionModel?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { 378 }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(option: TourOptionsModel) {
        model = option
        var images = option.images.toArray(ofType: String.self)
        if images.isEmpty { images = BOOKINGMANAGER.ticketModel?.images.toArray(ofType: String.self) ?? [] }
        _imagesGallery.setupHeader(images, pageControl: true)
        _title.text = option.title
        _description.text = option.descriptions
        _days.isHidden = true
        _startDate.text = Utils.dateToString(option.startDate, format: kFormatDateReview)
        _endDate.text = Utils.dateToString(option.endDate, format: kFormatDateReview)
        _availabilityTime.text = option.availabilityTime
        _totalSeats.text = String(option.totalSeats)
        
        let currencySymbol = NSAttributedString(
            string: " \(Utils.getCurrentCurrencySymbol())",
            attributes: [.foregroundColor: UIColor.white, .font: APPSESSION.userDetail?.currency == "AED" || APPSESSION.userDetail?.currency == "D" ? FontBrand.dirhamText(size: 15) : FontBrand.SFboldFont(size: 15)]
        )

        let discountedPrice = NSAttributedString(
            string: "\(option.finalAmount.formattedDecimal())",
            attributes: [.foregroundColor: UIColor.white, .font: FontBrand.SFboldFont(size: 17)]
        )
        
        // Original price with strikethrough
        let originalPriceString = "\(option.withoutDiscountAmount.formattedDecimal())"
        let originalPriceAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.6),
            .font: FontBrand.SFregularFont(size: 15),
            .strikethroughStyle: NSUnderlineStyle.single.rawValue,
            .baselineOffset: 0
        ]
        let originalPrice = NSAttributedString(string: originalPriceString + " ", attributes: originalPriceAttributes)

        let finalText = NSMutableAttributedString()
        finalText.append(currencySymbol)
        finalText.append(originalPrice)
        finalText.append(currencySymbol)
        finalText.append(discountedPrice)

        _discountValue.attributedText = finalText
    }
    
    public func setupData(option: TourOptionModel) {
        travelDesk = option
        var images: [String] = option.heroImage.compactMap { image in
            image.srcSet.compactMap { $0.sizes.first?.src }
        }.flatMap { $0 }

        if images.isEmpty {
            images = BOOKINGMANAGER.ticketModel?.travelDeskTourData.compactMap { model in
                model.heroImage?.srcSet.compactMap { $0.sizes.first?.src }
            }.flatMap { $0 } ?? []
        }

        if images.isEmpty {
            images = BOOKINGMANAGER.ticketModel?.images.toArray(ofType: String.self) ?? []
        }
        _title.text = option.name
        _imagesGallery.setupHeader(images, pageControl: true)
        _description.text = Utils.convertHTMLToPlainText(from: option.descriptionText)
        let model = option.pricingPeriods.first
        _days.isHidden = true
        _startDate.text = Utils.dateToString(Utils.stringToDate(model?.dateStart, format: "yyyy-MM-dd'T'HH:mm:ss"), format: kFormatDateReview)
        _endDate.text = Utils.dateToString(Utils.stringToDate(model?.dateEnd, format: "yyyy-MM-dd'T'HH:mm:ss"), format: kFormatDateReview)
        _availabilityTime.isHidden = true
        seatTitle.text = "Number of Hours :"
        _totalSeats.text = "\(option.numberOfHours)"
        let currencySymbol = NSAttributedString(
            string: " \(Utils.getCurrentCurrencySymbol())",
            attributes: [.foregroundColor: UIColor.white, .font: APPSESSION.userDetail?.currency == "AED" || APPSESSION.userDetail?.currency == "D" ? FontBrand.dirhamText(size: 13) : FontBrand.SFboldFont(size: 13)]
        )
        let discountedPrice = NSAttributedString(
            string: "\(model?.pricePerAdult.hideFloatingValue() ?? "")",
            attributes: [.foregroundColor: UIColor.white, .font: FontBrand.SFboldFont(size: 13)]
        )
        let finalText = NSMutableAttributedString()
        finalText.append(currencySymbol)
        finalText.append(discountedPrice)
        _discountValue.attributedText = finalText
    }
    
    @IBAction func _handleMoreinfoEvent(_ sender: CustomButton) {
        let vc = INIT_CONTROLLER_XIB(MoreInfoBottomSheet.self)
        vc.ticketId = Utils.stringIsNullOrEmpty(model?.customTicketId) ? BOOKINGMANAGER.ticketModel?._id ?? "" : model?.customTicketId ?? ""
        vc.optionID = Utils.stringIsNullOrEmpty(model?._id) ? "\(travelDesk?.id ?? 0)" : model?._id ?? ""
        vc.tourId = model?.tourIdString ?? ""
        self.parentBaseController?.navigationController?.present(vc, animated: true)
    }


}
