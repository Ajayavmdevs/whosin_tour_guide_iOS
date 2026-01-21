import UIKit

class ComplementaryEventImInCollecionCell: UICollectionViewCell {
    
    @IBOutlet weak var _customEventView: ComplementaryEventView!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { 370 }
    
    // --------------------------------------
    // MARK: Life-Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func setupData(_ data: PromoterEventsModel, isWishList: Bool = false) {
        _customEventView.setupData(data, isWishList: isWishList)
    }

}
