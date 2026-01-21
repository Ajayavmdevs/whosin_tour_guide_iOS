import UIKit

class CancellationDescTableCell: UITableViewCell {

    @IBOutlet weak var _descLabel: CustomLabel!
    @IBOutlet weak var _titleLbl: CustomLabel!
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
    }
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat { UITableView.automaticDimension }

    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    
}
