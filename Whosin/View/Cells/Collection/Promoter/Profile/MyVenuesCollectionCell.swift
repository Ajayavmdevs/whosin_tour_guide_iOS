import UIKit

class MyVenuesCollectionCell: UICollectionViewCell {

    @IBOutlet weak var _countLbl: CustomLabel!
    @IBOutlet weak var _circleCountView: UIView!
    @IBOutlet weak var venueImg: UIImageView!
    @IBOutlet weak var venueLbl: CustomLabel!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    
    class var height : CGFloat { 96 }
    // --------------------------------------
    // MARK: life Cycle
    // --------------------------------------

    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func setup(_ model:VenueDetailModel) {
        DISPATCH_ASYNC_MAIN_AFTER(0.01) {
            self.venueImg.cornerRadius = 10
        }
        venueImg.loadWebImage(model.slogo, name: model.name)
        venueLbl.text = model.name
    }
    
    public func setUpRings(_ model: UserDetailModel) {
        DISPATCH_ASYNC_MAIN_AFTER(0.01) {
            self.venueImg.cornerRadius = 28
        }
        venueLbl.font = FontBrand.SFlightFont(size: 14, isItalic: true)
        if Utils.stringIsNullOrEmpty(model.image) && Utils.stringIsNullOrEmpty(model.fullName) {
            venueImg.image = UIImage(named: "icon_coverRound")
            venueLbl.text = ""
        } else {
            venueImg.loadWebImage(model.image, name: model.fullName)
            venueLbl.text = model.firstName
        }
    }
    
    public func setupCircle(_ model: UserDetailModel, isSelected: Bool = false) {
        DISPATCH_ASYNC_MAIN_AFTER(0.01) {
            self.venueImg.cornerRadius = self.venueImg.frame.height / 2
        }
        venueImg.borderWidth = isSelected ? 2 : 0
        venueImg.borderColor = ColorBrand.brandPink
        _circleCountView.isHidden = false
        _countLbl.text = "\(model.totalMembers)"
        venueLbl.font = FontBrand.SFlightFont(size: 14, isItalic: true)
        venueImg.loadWebImage(model.avatar, name: model.title)
        venueLbl.text = model.title
    }
    
    public func setUpUser(_ model: UserDetailModel) {
        DISPATCH_ASYNC_MAIN_AFTER(0.01) {
            self.venueImg.cornerRadius = self.venueImg.frame.standardized.height / 2
        }
        venueLbl.font = FontBrand.SFlightFont(size: 10, isItalic: true)
        if Utils.stringIsNullOrEmpty(model.avatar), Utils.stringIsNullOrEmpty(model.title) {
            venueImg.loadWebImage(model.image, name: model.fullName)
            venueLbl.text = model.firstName
        } else {
            venueImg.loadWebImage(model.avatar, name: model.title)
            venueLbl.text = model.title
        }
    }
}
