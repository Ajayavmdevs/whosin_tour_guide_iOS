import UIKit

class MoreInfoDetailsTableCell: UITableViewCell {

    @IBOutlet weak var _infoTitle: CustomLabel!
    @IBOutlet weak var _refundText: CustomLabel!
    @IBOutlet weak var _infoDetails: LinkDetectingLabel!
    @IBOutlet weak var _nonRefundable: UIView!
    @IBOutlet weak var _container: UIView!
    @IBOutlet weak var leadingStack: NSLayoutConstraint!
    @IBOutlet weak var trailingStack: NSLayoutConstraint!
    
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
        _infoDetails.isUserInteractionEnabled = true
    }

    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ data: InfoModel) {
        _infoTitle.text = data.key.capitalizedSentence
        if data.days != nil , let days = data.days {
            _container.isHidden = false
            _nonRefundable.isHidden = true
            _infoDetails.text = Utils.getActiveDays(from: days)
            _infoTitle.isHidden = Utils.stringIsNullOrEmpty(Utils.getActiveDays(from: days))
        } else if data.key == "Cancellation Policy" && data.value == "Non Refundable" {
            _refundText.text = data.value
            _container.isHidden = true
            _nonRefundable.isHidden = false
            _infoDetails.text = data.value
        } else {
            _nonRefundable.isHidden = true
            _container.isHidden = false
            _infoDetails.setHTML(data.value)
        }
    }
    
}
