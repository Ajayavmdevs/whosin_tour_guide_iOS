import UIKit

protocol DaysCollectionCellDelegate: AnyObject {
    func closeButtonTapped(_ day: String )
}
    

class DaysCollectionCell: UICollectionViewCell {
    
    weak var delegate: DaysCollectionCellDelegate?
    @IBOutlet weak var _closeBtn: UIButton!
    @IBOutlet private weak var _dayLabel: UILabel!
    @IBOutlet weak var _bgView: GradientBorderView!
    @IBOutlet weak var _hegihtConstraint: NSLayoutConstraint!
    
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
        layoutIfNeeded()
    }
    
    public func setupTags(_ data: String) {
        _hegihtConstraint.constant = 20
        _bgView.backgroundColor = UIColor(hexString: "#57FD9D")
        _dayLabel.font = FontBrand.SFmediumFont(size: 11)
        _dayLabel.textColor = ColorBrand.black
        _closeBtn.isHidden = true
        _bgView.cornerRadius = 0
        _dayLabel.text = data
        layoutIfNeeded()
    }
    
    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        delegate?.closeButtonTapped(_dayLabel.text ?? kEmptyString)
    }
    

}
