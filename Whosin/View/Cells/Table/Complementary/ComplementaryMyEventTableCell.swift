import UIKit

class ComplementaryMyEventTableCell: UITableViewCell {
    
    @IBOutlet weak var _customEventView: CustomCMEventView!
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { 370 }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func setupData(_ data: PromoterEventsModel) {
        _customEventView.setupData(data, isIn: true)
    }
    
}
