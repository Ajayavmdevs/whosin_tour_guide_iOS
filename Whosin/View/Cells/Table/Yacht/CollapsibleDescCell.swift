import UIKit

class CollapsibleDescCell: UITableViewCell {

    @IBOutlet weak var _customView: CustomCollapsibleView!
    var reloadCallback: ((_ isExpand: Bool) -> Void)?
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }

    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // --------------------------------------
    // MARK: public
    // --------------------------------------

    public func setupData(_ description: String, type: String) {
        _customView.setUp(type, subTitle: description)
        _customView.callback = { isExpand in
            self.reloadCallback?(isExpand)
        }

    }
    
}
