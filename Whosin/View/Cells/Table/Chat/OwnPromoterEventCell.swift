import UIKit
import ObjectMapper
import CountdownLabel

class OwnPromoterEventCell: UITableViewCell {

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
        disableSelectEffect()
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
        guard let model = Mapper<PromoterEventsModel>().map(JSONString: jsonString) else { return }
        
        _eventImage.loadWebImage(model.customVenue?.image ?? kEmptyString)
        _venueName.text = model.customVenue?.name
        _venueAddress.text = model.customVenue?.address
        _venueImage.loadWebImage(model.venueType == "venue" ? (model.customVenue?.slogo ?? kEmptyString) : model.customVenue?.image ?? kEmptyString, name: model.customVenue?.name ?? kEmptyString)
        let eventdt = Utils.stringToDate(model.date, format: kFormatDate)
        _dateLabel.text  = Utils.dateToString(eventdt, format: kFormatDateMonthShort)

        _startTime.text = "\(model.startTime)"
        _endTime.text = "\(model.endTime)"
        
        if !Utils.stringIsNullOrEmpty(model.date) {
            _countdownLabel.font = FontBrand.SFboldFont(size: 24)
            let currentTime = Utils.getCurrentDate(withFormat: kFormatDateStandard)
            let startTime = Date(timeInterval: "\(currentTime)".toDate(format: kStanderdDate).timeIntervalSince(currentTime), since: currentTime)
            let tmpEndDate = "\(model.date) \(model.startTime)".toDateUae(format: kFormatDateTimeLocal)
            _countdownLabel.animationType = .Evaporate
            _countdownLabel.timeFormat = "dd:HH:mm:ss"
            _countdownLabel.setCountDownDate(targetDate: tmpEndDate as NSDate)
            DISPATCH_ASYNC_MAIN_AFTER(0.015) {
                self._countdownLabel.start()
            }
        }
        if let user = APPSESSION.userDetail {
            guard user.isPromoter, user.id != message?.replyBy, !Utils.stringIsNullOrEmpty(message?.replyBy) else {
                _replyByName.text = kEmptyString
                return
            }
            let replyUser = APPSETTING.subAdmins.first(where: { $0.id == message?.replyBy })
            _replyByName.text = "~ " + (replyUser?.fullName ?? kEmptyString)
        }
    }

    
}
