import UIKit

class SpecificationsCollectionCell: UICollectionViewCell {

    @IBOutlet weak var _title: UILabel!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        31
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

    public func setupData(_ model: SpecificationsModel) {
        _title.attributedText = model.attributedString
    }
    
}
