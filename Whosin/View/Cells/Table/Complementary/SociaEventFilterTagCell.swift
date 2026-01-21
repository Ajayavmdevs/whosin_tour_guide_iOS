import UIKit

class SociaEventFilterTagCell: UICollectionViewCell {
    
    @IBOutlet weak var _counterText: UILabel!
    @IBOutlet weak var _counterView: UIView!
    @IBOutlet weak var _bgView: UIView!
    @IBOutlet private weak var _title: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        _counterView.cornerRadius = 8//_counterView.frame.width / 2
        _bgView.cornerRadius = 17
    }
    
    class var height: CGFloat {
        50
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
        
    public func setupFilter(_ value: String, _ count: Int = 0) {
        _counterView.isHidden = count <= 0
        _counterText.text = "\(count)"
        _title.text = value
        _title.textColor = .white
        _title.font = FontBrand.SFsemiboldFont(size: 14)
        _bgView.backgroundColor = UIColor(hexString: "#212121")
        _bgView.cornerRadius = 17
    }
    
}
