import UIKit

class TimeCollectionCell: UICollectionViewCell {

    @IBOutlet private weak var _dayLabel: UILabel!
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

    public func setUpdata(_ data: String, isActivity: Bool = false) {
        if isActivity {
            _dayLabel.font = FontBrand.SFsemiboldFont(size: 12)
            _bgView.cornerRadius = 12
        }
        _dayLabel.text = data
    }

}
