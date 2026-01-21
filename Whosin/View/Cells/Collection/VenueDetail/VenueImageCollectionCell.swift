import UIKit

class VenueImageCollectionCell: UICollectionViewCell {

    @IBOutlet private weak var _imageView: UIImageView!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat {
        64
    }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setUpdata(_ data: String, isSelected: Bool) {
        _imageView.borderColor = isSelected ? ColorBrand.brandPink : ColorBrand.brandImageBorder
        _imageView.borderWidth = isSelected ? 2 : 1
        _imageView.loadWebImage(data)
    }

}
