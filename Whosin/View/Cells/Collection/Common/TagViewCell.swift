import UIKit

class TagViewCell: UICollectionViewCell {
    
    @IBOutlet weak var _bgView: UIView!
    @IBOutlet private weak var _title: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
//        _bgView.addGradientBorder(cornerRadius: 15, 1, false)
    }
    
    class var height: CGFloat {
        30
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ setting: CommonSettingsModel?, isSelected: Bool = false) {
        _title.text = setting?.title
        _title.textColor = .white
        _bgView.backgroundColor = isSelected ? ColorBrand.brandPink : ColorBrand.white.withAlphaComponent(0.13)
    }
    
    public func setupDataTime(_ setting: TourTimeSlotModel?, isSelected: Bool = false) {
        _title.text = setting?.timeSlot
        _title.textColor = .white
        _bgView.backgroundColor = isSelected ? ColorBrand.brandPink : ColorBrand.white.withAlphaComponent(0.13)
    }
    
    public func setupPrefrenceData(_ setting: CommonSettingsModel?, isSelected: Bool = false) {
        _title.font = FontBrand.SFmediumFont(size: 12)
        _bgView.borderColor = UIColor(hexString: "#111111")
        _bgView.borderWidth = 1
        _title.text = setting?.title
        _title.textColor = .white
        _bgView.backgroundColor = isSelected ? UIColor(hexString: "#D80074") : UIColor(hexString: "#1E1E1E")
    }
    
    public func setup(_ value: String) {
        _title.text = value
        _title.textColor = .white
        _title.font = FontBrand.SFregularFont(size: 11)
        _bgView.backgroundColor = UIColor(hexString: "#212121")
        _bgView.cornerRadius = _bgView.frame.height / 2
    }
    
    public func setupFilter(_ value: String) {
        _title.text = value
        _title.textColor = .white
        _title.font = FontBrand.SFsemiboldFont(size: 14)
        _bgView.backgroundColor = UIColor(hexString: "#212121")
        _bgView.cornerRadius = _bgView.frame.height / 2
    }
    
    public func setupExploreFilter(_ data: CategoryDetailModel?, isSelected: Bool = false, isFromCity: Bool = false) {
        _title.text = isFromCity ? data?.name : data?.title
        _title.textColor = .white
        _bgView.backgroundColor = isSelected ? ColorBrand.brandPink : ColorBrand.white.withAlphaComponent(0.13)
    }
    
    public func select() {
        _bgView.backgroundColor = ColorBrand.brandPink
    }

    public func deselect() {
        _bgView.backgroundColor = ColorBrand.white.withAlphaComponent(0.13)
    }
}
