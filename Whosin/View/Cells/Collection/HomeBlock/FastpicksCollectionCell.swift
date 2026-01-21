import UIKit

class FastpicksCollectionCell: UICollectionViewCell {

    @IBOutlet private weak var _imageView: UIImageView!
    @IBOutlet private weak var _nameLabel: UILabel!
    @IBOutlet private weak var _offersLabel: UILabel!
    @IBOutlet private weak var _nextButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat { 55 }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setUpdata(_ data: VenueDetailModel) {
    }

}
