import UIKit
import Hero

class CategoriesCollectionCell: UICollectionViewCell {

    @IBOutlet weak var _bgImageView: GradientImageView!
    @IBOutlet weak var _bgView: UIView!
    @IBOutlet private weak var _catagoryLabel: UILabel!
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        _catagoryLabel.layer.shadowColor = ColorBrand.black.cgColor
        _catagoryLabel.layer.shadowOffset = CGSize(width: 0, height: 0) 
        _catagoryLabel.layer.shadowRadius = 3
        _catagoryLabel.layer.shadowOpacity = 0.8
        _catagoryLabel.layer.masksToBounds = false

    }
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat { 80 }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setUpdata(_ data: CategoryDetailModel, isboldText: Bool = false) {
        _catagoryLabel.font = isboldText ? FontBrand.SFheavyFont(size: 15) : FontBrand.SFsemiboldFont(size: 15)
        if data.offers == 0 {
            _catagoryLabel.text = data.title
        } else {
            _catagoryLabel.text = "\(data.title) (\(data.offers))"
        }
        if !data.image.isEmpty {
            _bgImageView.loadWebImage(data.image)
        } else {
            _bgImageView.image = nil
            if let startColor = data.color?.startColor, let endColor = data.color?.endColor {
                _bgImageView.startColor = UIColor(hexString: startColor)
                _bgImageView.endColor = UIColor(hexString: endColor)
            }
        }
    }
    
    public func setupExploredata(_ data: CategoryDetailModel) {
        _catagoryLabel.text = data.name
        if let startColor = data.color?.startColor, let endColor = data.color?.endColor {
            _bgImageView.startColor = UIColor(hexString: startColor)
            _bgImageView.endColor = UIColor(hexString: endColor)
        } else {
            _bgImageView.loadWebImage(data.image)
        }
    }

}
