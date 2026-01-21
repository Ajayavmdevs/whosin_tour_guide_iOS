import UIKit

class FilterCollectionCell: UICollectionViewCell {
    
    weak var delegate: DaysCollectionCellDelegate?
    @IBOutlet weak var _textLabel: UILabel!
    @IBOutlet weak var _bgView: GradientBorderView!
    @IBOutlet weak var _radioBtn: UIButton!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat {
        28
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    public func setUpdata(_ data: String, isSelected: Bool = false) {
        _bgView.cornerRadius = 14
        _bgView.borderWidth = 1
        _textLabel.font = isSelected ? FontBrand.SFsemiboldFont(size: 12) : FontBrand.SFregularFont(size: 12)
        _bgView.backgroundColor = isSelected ? .clear : UIColor(hexString: "#232323")
        _bgView.borderColor = isSelected ? ColorBrand.brandPink : .clear
        _textLabel.textColor = isSelected ? ColorBrand.brandPink : ColorBrand.white
        _textLabel.text = data
        layoutIfNeeded()
    }
    
    public func setUpFilterdata(_ data: String, isSelected: Bool = false) {
        _radioBtn.isHidden = false
        _textLabel.textAlignment = .center
        _radioBtn.isUserInteractionEnabled = false
        _radioBtn.isSelected = isSelected
            if isSelected {
               _radioBtn.setImage(UIImage(named: "icon_selcetCode"), for: .selected)
           } else {
               _radioBtn.setImage(UIImage(named: "icon_deselcetCode"), for: .normal)
           }
        _bgView.cornerRadius = 8
        _bgView.borderWidth = 0
        _textLabel.font = isSelected ? FontBrand.SFsemiboldFont(size: 12) : FontBrand.SFregularFont(size: 12)
        _bgView.backgroundColor = .clear
        _bgView.borderWidth = 1
        _bgView.borderColor = isSelected ? ColorBrand.brandPink : .lightGray
        _textLabel.textColor = isSelected ? ColorBrand.brandPink : ColorBrand.white
        _textLabel.text = data
        layoutIfNeeded()
    }

}
