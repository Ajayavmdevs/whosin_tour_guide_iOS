import UIKit

class CompleteProfileTableCell: UITableViewCell {
    
    @IBOutlet weak var _memberShipView: GradientView!
    @IBOutlet weak var _copleteProfileView: GradientView!
    @IBOutlet weak var _userImage: UIImageView!
    @IBOutlet weak var _membershipTitle: UILabel!
    @IBOutlet weak var _membershipSubTitle: UILabel!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
    }

    public func setup(_ title: String, subTitle: String) {
        _membershipTitle.text = title
        _membershipSubTitle.text = subTitle
    }
}
