import UIKit

class TicketSearchTableCell: UITableViewCell {

    @IBOutlet weak var _gallaryView: TicketListGallaryView!
    @IBOutlet weak var _startingFrom: UILabel!
    @IBOutlet weak var _titleText: CustomLabel!
    @IBOutlet weak var _badgeView: UIView!
    @IBOutlet weak var _subTitleText: CustomLabel!
    @IBOutlet weak var _discountView: UIView!
    @IBOutlet weak var _discountPercentage: UILabel!
    private var _ticketDetail: TicketModel?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        UITableView.automaticDimension
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        DISPATCH_ASYNC_MAIN_AFTER(0.02) {
            self._badgeView.layer.maskedCorners = [.layerMinXMaxYCorner]
            self._badgeView.layer.cornerRadius = 8
            self._gallaryView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            self._gallaryView.layer.cornerRadius = 10
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: TicketModel) {
        _ticketDetail = data
        _startingFrom.attributedText = "\(Utils.getCurrentCurrencySymbol())\(data.startingAmount.formattedDecimal())".withCurrencyFont(18)
        _titleText.text = data.title
        _subTitleText.text = Utils.convertHTMLToPlainText(from: data.descriptions)
        _gallaryView.setupHeader(data.images.toArray(ofType: String.self).filter({ !Utils.isVideo($0)} ))
        _discountView.isHidden = data.discount == 0
        _discountPercentage.text = "\(data.discount)%"
        
    }

    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    
    @IBAction func _handleGetTicketEvent(_ sender: CustomActivityButton) {
        let vc = INIT_CONTROLLER_XIB(CustomTicketDetailVC.self)
        vc.ticketID = _ticketDetail?._id ?? kEmptyString
        vc.hidesBottomBarWhenPushed = true
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
}
