import UIKit
import ObjectMapper
import CountdownLabel

class CompititorTicketCell: UITableViewCell {
    
    @IBOutlet private weak var _badgeView: UIView!
    @IBOutlet private weak var _descriptionText: CustomLabel!
    @IBOutlet private weak var _titleText: CustomLabel!
    @IBOutlet private weak var _startingAtPrice: UILabel!
    @IBOutlet private weak var _gallaryView: TicketListGallaryView!
    @IBOutlet weak var _badgePrice: UILabel!
    @IBOutlet weak var _discountView: UIView!
    @IBOutlet weak var _discountText: UILabel!
    private var _ticketModel: TicketModel?
    @IBOutlet weak var _msgTime: UILabel!
    @IBOutlet weak var _senderName: UILabel!
    private var messageModel: MessageModel?
    
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
        DISPATCH_ASYNC_MAIN_AFTER(0.02) {
            self._gallaryView.cornerRadius = 10
            self._gallaryView.clipsToBounds = true
            self._gallaryView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            self._badgeView.layer.maskedCorners = [.layerMinXMaxYCorner]
            self._badgeView.layer.cornerRadius = 8
        }

    }

    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    func setup(_ message: MessageModel?) {
        guard let _msg = message else { return }
        messageModel = _msg
        let timeStamp = Double(message?.date ?? "")
        let date = timeStamp?.getDateStringFromUTC()
        _senderName.text = _msg.authorName
        _msgTime.text = date
        
        guard let model = Mapper<TicketModel>().map(JSONString: _msg.msg) else { return }
        
        _ticketModel = model
        _discountText.text = "\(model.discount)%"
        _discountView.isHidden = model.discount == 0
        _titleText.text = model.title
        _descriptionText.text = model.city
        _startingAtPrice.text = "from".localized() + "\(Utils.getCurrentCurrencySymbol())" + "\(model.startingAmount)"
        _gallaryView.setupHeader(model.images.toArray(ofType: String.self).filter({ !Utils.isVideo($0)}))
        _badgePrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(model.startingAmount)".withCurrencyFont(18)

    }
    
    @IBAction func _handleForwordEvent(_ sender: UIButton) {
        let navController = INIT_CONTROLLER_XIB(ShareBottomSheet.self)
        navController.isForword = true
        navController.messageModel = self.messageModel
        navController.modalPresentationStyle = .overFullScreen
        parentBaseController?.present(navController, animated: true)
    }
    
    
}
