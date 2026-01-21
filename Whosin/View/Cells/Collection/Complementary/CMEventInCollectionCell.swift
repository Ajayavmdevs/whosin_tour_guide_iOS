import UIKit
import CountdownLabel

class CMEventInCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var _cusomEventVeiw: CustomCMEventView!

    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat { 350 }

    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    public func setupData(_ data: PromoterEventsModel, isIn: Bool = false, isWishList: Bool = false) {
        _cusomEventVeiw.setupData(data, isIn: isIn, isWishList: isWishList)
    }
}
