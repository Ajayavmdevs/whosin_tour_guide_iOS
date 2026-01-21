import UIKit
import ObjectMapper
import CountdownLabel

class OwnTicketCell: UITableViewCell {

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
    @IBOutlet weak var _msgStatusImage: UIImageView!
    @IBOutlet weak var _replyByName: CustomLabel!
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
        _gallaryView.cornerRadius = 10
        self._gallaryView.clipsToBounds = true
        self._gallaryView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        setupUi()
        disableSelectEffect()
    }
    
    private func setupUi() {
        DISPATCH_ASYNC_MAIN_AFTER(0.02) {
            self._badgeView.layer.maskedCorners = [.layerMinXMaxYCorner]
            self._badgeView.layer.cornerRadius = 8
        }
    }

    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setup(_ message: MessageModel?) {
        guard let _msg = message else { return }
        messageModel = _msg
        let timeStamp = Double(_msg.date )
        let date = timeStamp?.getDateStringFromUTC()
        _msgTime.text = date
        if _msg.seenBy.count >= _msg.members.count - 1 {
            _msgStatusImage.image = #imageLiteral(resourceName: "icon_double_check")
            _msgStatusImage.tintColor = .green
        }
        else if _msg.receivers.count >= _msg.members.count {
            _msgStatusImage.image = #imageLiteral(resourceName: "icon_double_check")
            _msgStatusImage.tintColor = .white
        }
        else if _msg.receivers.contains(Preferences.isSubAdmin ? APPSESSION.userDetail?.promoterId ?? kEmptyString : APPSESSION.userDetail?.id ?? kEmptyString) {
            _msgStatusImage.image = #imageLiteral(resourceName: "icon_single_check")
            _msgStatusImage.tintColor = .white
        }
        else {
            _msgStatusImage.image = #imageLiteral(resourceName: "icon_sending")
            _msgStatusImage.tintColor = .white
            _msgTime.text = "sending...".localized()
        }
        
        guard let jsonString = message?.msg else { return }
        guard let model = Mapper<TicketModel>().map(JSONString: jsonString) else { return }
        _ticketModel = model
        _discountText.text = "\(model.discount)%"
        _discountView.isHidden = model.discount == 0
        _titleText.text = model.title
        _descriptionText.text = model.city
        _startingAtPrice.attributedText = "\("from".localized()) \(Utils.getCurrentCurrencySymbol()) \(model.startingAmount)".withCurrencyFont(18)
        _gallaryView.setupHeader(model.images.toArray(ofType: String.self).filter({ !Utils.isVideo($0)}))
        _badgePrice.attributedText = "\(Utils.getCurrentCurrencySymbol())\(model.startingAmount)".withCurrencyFont(18)

        if let user = APPSESSION.userDetail {
            guard user.isPromoter, user.id != message?.replyBy, !Utils.stringIsNullOrEmpty(message?.replyBy) else {
                _replyByName.text = kEmptyString
                return
            }
            let replyUser = APPSETTING.subAdmins.first(where: { $0.id == message?.replyBy })
            _replyByName.text = "~ " + (replyUser?.fullName ?? kEmptyString)
        }
    }
    
    
    @IBAction func _handleForwordEvent(_ sender: UIButton) {
        let navController = INIT_CONTROLLER_XIB(ShareBottomSheet.self)
        navController.isForword = true
        navController.messageModel = self.messageModel
        navController.modalPresentationStyle = .overFullScreen
        parentBaseController?.present(navController, animated: true)
    }
    
    
}
