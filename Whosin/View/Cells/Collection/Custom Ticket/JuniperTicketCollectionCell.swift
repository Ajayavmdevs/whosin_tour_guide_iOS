import UIKit

class JuniperTicketCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var _imagesGallery: CustomGallaryView!
    @IBOutlet weak var _title: CustomLabel!
    @IBOutlet weak var _description: CustomLabel!
    @IBOutlet weak var _startTime: CustomLabel!
    @IBOutlet weak var _noOfDays: CustomLabel!
    @IBOutlet weak var _minimumPax: CustomLabel!
    @IBOutlet private weak var _startingPrice: CustomLabel!
    @IBOutlet weak var _discountValue: CustomLabel!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { 400 }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: ServiceModel, option: ServiceOptionModel) {
        var images: [String] = data.serviceContentInfo?.images.toArray(ofType: ImageModel.self).filter { $0.type == "BIG" }.compactMap { $0.fileName } ?? []
        if images.isEmpty {
            images = BOOKINGMANAGER.ticketModel?.images.toArray(ofType: String.self) ?? []
        }
        _imagesGallery.setupHeader(images, pageControl: true)
        _title.text = option.name
        _description.text = option.shortDescription
        _startTime.text = option.startTime
        _noOfDays.text = String(option.numberOfDays)
        _minimumPax.text = String(option.minimumPax)
        
        let currencySymbol = NSAttributedString(
            string: " \(Utils.getCurrentCurrencySymbol())",
            attributes: [.foregroundColor: UIColor.white, .font: APPSESSION.userDetail?.currency == "AED" || APPSESSION.userDetail?.currency == "D" ? FontBrand.dirhamText(size: 13) : FontBrand.SFboldFont(size: 13)]
        )
        let discountedPrice = NSAttributedString(
            string: "\(BOOKINGMANAGER.ticketModel?.startingAmount.formattedDecimal() ?? "")",
            attributes: [.foregroundColor: UIColor.white, .font: FontBrand.SFboldFont(size: 13)]
        )
        let finalText = NSMutableAttributedString()
        finalText.append(currencySymbol)
        finalText.append(discountedPrice)
        _discountValue.attributedText = finalText
        
        _startingPrice.isHidden = true
    }

}
