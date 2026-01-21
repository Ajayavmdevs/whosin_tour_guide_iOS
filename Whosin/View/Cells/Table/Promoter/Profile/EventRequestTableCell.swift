import UIKit

class EventRequestTableCell: UITableViewCell {
    
    @IBOutlet weak var _customEventRequestView: CustomEventRequestView!
    
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
    
    // --------------------------------------
    // MARK: public
    // --------------------------------------
    
    public func setUpData(_ model: NotificationModel, isNotification: Bool) {
        _customEventRequestView.setUpData(model, isNotification: isNotification)
    }
    
    public func setUpChatData(_ model: PromoterChatListModel, isPromoter: Bool = false) {
        _customEventRequestView.setUpChatData(model, isPromoter: isPromoter)
    }


}
