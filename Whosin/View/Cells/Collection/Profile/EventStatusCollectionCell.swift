import UIKit

class EventStatusCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var _textLabel: UILabel!
    @IBOutlet weak var _bgView: GradientBorderView!
    
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

    public func setUpdata(_ data: String, isSelected: Bool = false) {
        _bgView.cornerRadius = 8
        _bgView.borderWidth = 1
        _textLabel.font = isSelected ? FontBrand.SFsemiboldFont(size: 14) : FontBrand.SFregularFont(size: 14)
        _bgView.backgroundColor = isSelected ? ColorBrand.brandPink : UIColor(hexString: "#232323")
        _bgView.borderColor = isSelected ? ColorBrand.brandPink : ColorBrand.white
        _textLabel.textColor = isSelected ? ColorBrand.white : ColorBrand.white
        _textLabel.text = data
        layoutIfNeeded()
    }

}
