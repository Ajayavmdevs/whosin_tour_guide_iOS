
import UIKit

class TicketPreviewHeaderTableCell: UITableViewCell {
    
    @IBOutlet weak var _ticketImage: UIImageView!
    @IBOutlet weak var _ticketTitle: CustomLabel!
    @IBOutlet weak var _ticketDesc: CustomLabel!
    @IBOutlet weak var _ticketDate: CustomLabel!
    
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
    // MARK: Public
    // --------------------------------------

    public func setupData(_ data: TicketModel) {
    }
}
