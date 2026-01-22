import UIKit

class YachtFeatureCollectionCell: UICollectionViewCell {

    @IBOutlet weak var _bgView: UIView!
    @IBOutlet private weak var _title: UILabel!
    @IBOutlet private weak var _icon: UIImageView!
    @IBOutlet weak var _iconBg: UIView!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat {
        27
    }

    // --------------------------------------
    // MARK: Life - cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------


    public func setup(_ value: CommonSettingsModel) {
        _title.text = value.feature
        _title.textColor = .white
        _title.font = FontBrand.SFregularFont(size: 11)
        if Utils.stringIsNullOrEmpty(value.icon) {
            _iconBg.isHidden = true
        } else {
            _iconBg.isHidden = false
            _icon.loadWebImage(value.icon)
            _icon.cornerRadius = _icon.frame.height / 2
        }
        _bgView.backgroundColor = UIColor(hexString: "#191919")
    }

}
