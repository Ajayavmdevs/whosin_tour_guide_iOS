import UIKit

class CTACollectionCell: UICollectionViewCell {

    @IBOutlet weak var _bgView: UIView!
    @IBOutlet private weak var _titleText: CustomLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func setup(_ title: String, color: String) {
        _bgView.backgroundColor = UIColor(hexString: color)
        _titleText.text = title
    }

}
