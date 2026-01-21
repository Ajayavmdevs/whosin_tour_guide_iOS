import UIKit

class VenueSpecialOffersCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var _bgImageView: UIImageView!
    @IBOutlet private weak var _discountLabel: UILabel!
    @IBOutlet private weak var _discountInfo: UILabel!
    @IBOutlet weak var _discriptionLabel: UILabel!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        87
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
    
    public func setUpdata(_ model: SpecialOffersModel) {
        _bgImageView.image = UIImage(named: "icon_bgOffers1")
        if !Utils.stringIsNullOrEmpty(model.descriptions) {
            _discriptionLabel.isHidden = false
            _discriptionLabel.text = model.descriptions
        }
        _discountLabel.text = ("\(model.discount) % OFF")
        _discountInfo.text = model.title
    }
    
}
