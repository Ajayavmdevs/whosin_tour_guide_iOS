import UIKit

class CommonTitleCell: UITableViewCell {

    @IBOutlet private weak var _titleLabel: UILabel!
    @IBOutlet private weak var _subtitleLabel: UILabel!
    @IBOutlet weak var _seperatorView: UIView!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }

    // --------------------------------------
    // MARK: LifeCycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setup(_ title: String, subTitle: String) {
        _titleLabel.text = title
        _subtitleLabel.text = subTitle
    }


    
}
