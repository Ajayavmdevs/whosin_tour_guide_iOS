import UIKit

class SavedInDraftCollectionCell: UICollectionViewCell {

    @IBOutlet weak var _eventDiscription: CustomLabel!
    @IBOutlet weak var _eventName: CustomLabel!
    @IBOutlet weak var _eventImage: UIImageView!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height : CGFloat { 90 }

    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func setup(model: PromoterEventsModel) {
        if Utils.stringIsNullOrEmpty(model.venueType) {
            _eventName.text = "select_venue_event".localized()
            _eventImage.image = UIImage(named: "icon_draft")
            _eventDiscription.text = ""
        } else {
            _eventName.text = model.customVenue?.name
            _eventImage.loadWebImage(model.customVenue?.image ?? kEmptyString, name: model.customVenue?.name ?? kEmptyString)
            _eventDiscription.text = model.customVenue?.address
        }
    }

}
