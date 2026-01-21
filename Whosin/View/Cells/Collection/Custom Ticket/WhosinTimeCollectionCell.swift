import UIKit

class WhosinTimeCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var _bgView: UIView!
    @IBOutlet weak var _timeLable: CustomLabel!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { 40 }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setup(_ data: String, isSelected: Bool = false) {
        _timeLable.text = data
        _bgView.backgroundColor = isSelected ? ColorBrand.brandPink.withAlphaComponent(0.2) : ColorBrand.brandGray.withAlphaComponent(0.2)
        _bgView.borderColor = isSelected ? ColorBrand.brandPink : ColorBrand.brandGray
        _bgView.borderWidth = isSelected ? 1 : 0.5
    }

}
