import UIKit

class SelectVenueCollectionCell: UICollectionViewCell {
    
    @IBOutlet private weak var _customGallaryView: CustomGallaryView!
    @IBOutlet private weak var _addressLabel: UILabel!
    @IBOutlet private weak var _nameLabel: UILabel!
    @IBOutlet private weak var _imageView: UIImageView!
    @IBOutlet private weak var _imageBgView: UIView!
    private var _venueId: String = kEmptyString
    private var _logoHeroId: String = kEmptyString
    @IBOutlet weak var _button: UIButton!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height : CGFloat { 150 }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        self._customGallaryView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self._customGallaryView.cornerRadius = 10
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setUpdata(_ data: VenueDetailModel, isSelected: Bool) {
        _button.setImage( isSelected ? UIImage(named: "icon_radio_selected"): UIImage(named: "icon_radio"))
        _imageView.loadWebImage(data.slogo)
        if data.galleries.isEmpty {
            _customGallaryView.setupHeader([data.slogo], isPreview: false)
        } else {
            _customGallaryView.setupHeader(data.galleries, isPreview: false)
        }
//        _customGallaryView.isHidden = data.galleries.isEmpty
//        _customGallaryView.setupHeader(data.galleries, isPreview: false)
        _venueId = data.id
        _nameLabel.text = data.name
        _addressLabel.text = data.address
                
    }

}
