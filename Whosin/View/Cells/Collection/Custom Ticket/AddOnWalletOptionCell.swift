import UIKit

class AddOnWalletOptionCell: UICollectionViewCell {


    @IBOutlet weak var _bgView: UIView!
    @IBOutlet weak var _title: CustomLabel!
    @IBOutlet weak var _description: CustomLabel!
    @IBOutlet weak var _price: CustomLabel!
    @IBOutlet weak var _adultTimeStack: UIStackView!
    @IBOutlet weak var _adultLabel: CustomLabel!
    @IBOutlet weak var _timeSlot: CustomLabel!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { 100 }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: TourDetailsModel) {
        
        _title.text = data.addonOption?.title ?? ""
        _description.text = data.addonOption?.sortDescription ?? ""
        
        let adultCount = data.adult
        let childCount = data.child
        let timeSlot = data.timeSlot
        let adultTitle = Utils.stringIsNullOrEmpty(data.adultTitle) ? "Adults" : data.adultTitle
        let childTitle = Utils.stringIsNullOrEmpty(data.childTitle) ? "Child" : data.childTitle
        
        let selectedTotal = ((adultCount + childCount + (data.infant)) > 0 ) ? data.whosinTotal : data.serviceTotal
        let currencySymbol = NSAttributedString(
            string: " \(Utils.getCurrentCurrencySymbol())",
            attributes: [.foregroundColor: UIColor.white, .font: APPSESSION.userDetail?.currency == "AED" || APPSESSION.userDetail?.currency == "D" ? FontBrand.dirhamText(size: 13) : FontBrand.SFboldFont(size: 13)]
        )
        let priceText = NSAttributedString(
            string: "\(selectedTotal)",
            attributes: [.foregroundColor: UIColor.white, .font: FontBrand.SFmediumFont(size: 14)]
        )
        let finalText = NSMutableAttributedString()
        finalText.append(currencySymbol)
        finalText.append(priceText)
        _price.attributedText = finalText
        
        let infantCount = data.infant
        var paxParts: [String] = []
        if adultCount > 0 {
            paxParts.append("\(adultCount)x \(adultTitle)")
        }
        if childCount > 0 {
            paxParts.append("\(childCount)x \(childTitle)")
        }
        if infantCount > 0 {
            let infantTitle = Utils.stringIsNullOrEmpty(data.infantTitle) ? "Infant" : data.infantTitle
            paxParts.append("\(infantCount)x \(infantTitle)")
        }
        _adultLabel.text = paxParts.joined(separator: ", ")
        _timeSlot.text = timeSlot
        
        let hasPax = (adultCount + childCount + infantCount) > 0
        _adultTimeStack.isHidden = !(hasPax || !Utils.stringIsNullOrEmpty(timeSlot))
        
        _bgView.layer.borderWidth = 0.5
        _bgView.borderColor = ColorBrand.brandGray
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------



    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
 

}
