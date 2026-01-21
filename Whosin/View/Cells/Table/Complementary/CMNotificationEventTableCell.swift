import UIKit

class CMNotificationEventTableCell: UITableViewCell {

    @IBOutlet weak var _eventView: ComplementaryEventView!
    
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ data: PromoterEventsModel) {
        _eventView.setupData(data, isCMNotification: true)
    }
    
}
