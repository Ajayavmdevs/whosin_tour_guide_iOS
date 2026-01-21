import UIKit

class RequirementCollectionCell: UICollectionViewCell {

    @IBOutlet weak var _deleteBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet private weak var _textLabel: CustomLabel!
    @IBOutlet private weak var _iconView: UIImageView!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life-Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    public func setup(_ text: String, isAllow: Bool = false) {
        _iconView.image = UIImage(named: isAllow ? "icon_allow" : "icon_notAllow")
        _textLabel.text = text
    }
    
}
