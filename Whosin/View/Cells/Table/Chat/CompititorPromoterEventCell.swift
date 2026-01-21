import UIKit
import ObjectMapper
import CountdownLabel

class CompititorPromoterEventCell: UITableViewCell {
    
    @IBOutlet weak var _eventImage: UIImageView!
    @IBOutlet weak var _dateLabel: CustomLabel!
    @IBOutlet weak var _venueImage: UIImageView!
    @IBOutlet weak var _venueName: CustomLabel!
    @IBOutlet weak var _venueAddress: CustomLabel!
    @IBOutlet weak var _startTime: CustomLabel!
    @IBOutlet weak var _endTime: CustomLabel!
    @IBOutlet weak var _countdownLabel: CountdownLabel!
    @IBOutlet weak var _eventExpiredLabel: CustomLabel!
    @IBOutlet weak var _confirmationText: CustomLabel!
    @IBOutlet weak var _confirmationView: UIView!
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
        
        guard let model = Mapper<PromoterEventsModel>().map(JSONString: _msg.msg) else { return }
        
        _eventImage.loadWebImage(model.customVenue?.image ?? kEmptyString)
        _venueName.text = model.customVenue?.name
        _venueAddress.text = model.customVenue?.address
        _venueImage.loadWebImage(model.venueType == "venue" ? (model.customVenue?.slogo ?? kEmptyString) : model.customVenue?.image ?? kEmptyString, name: model.customVenue?.name ?? kEmptyString)
        let eventdt = Utils.stringToDate(model.date, format: kFormatDate)
        _dateLabel.text  = Utils.dateToString(eventdt, format: kFormatDateMonthShort)

        _startTime.text = "\(model.startTime)"
        _endTime.text = "\(model.endTime)"
    }
    
}
