import UIKit

class FeaturesTableCell: UITableViewCell {


    @IBOutlet private weak var _iconImage: UIImageView!
    @IBOutlet private weak var _titleText: UILabel!
    

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    static var height: CGFloat { UITableView.automaticDimension }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setup(_ icon: String, title: String) {
        _iconImage.loadWebImage(icon)
        _titleText.text = title
    }
}
