import UIKit

class CuisineCollectionCell: UICollectionViewCell {

    @IBOutlet private weak var _cuisineName: UILabel!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat {
        30
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
    
    public func setUpdata(_ data: CommonSettingsModel) {
        _cuisineName.text = data.title
        layoutIfNeeded()
    }
    
}
