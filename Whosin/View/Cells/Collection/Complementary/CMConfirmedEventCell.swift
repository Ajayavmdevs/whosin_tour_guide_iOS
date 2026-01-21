import UIKit
import CountdownLabel

class CMConfirmedEventCell: UICollectionViewCell {
    
    @IBOutlet weak var _eventImage: UIImageView!
    @IBOutlet weak var _eventName: CustomLabel!
    @IBOutlet weak var _eventDesc: CustomLabel!
    @IBOutlet weak var _eventDateTime: CustomLabel!
    @IBOutlet weak var _timerLabel: CountdownLabel!
    @IBOutlet weak var _timeView: UIView!
    @IBOutlet weak var _remainingText: CustomLabel!
    
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat { 80 }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ data: PromoterEventsModel) {
        _eventName.text = data.venueType == "venue" ? data.venue?.name : data.customVenue?.name
        _eventDesc.text = data.venueType == "venue" ? data.venue?.address : data.customVenue?.address
        _eventImage.loadWebImage(data.venueType == "venue" ? data.image.isEmpty ? data.venue?.venueCover ?? kEmptyString : data.image : data.customVenue?.image ?? kEmptyString)
        let eventdt = Utils.stringToDate(data.date, format: kFormatDate)
        _eventDateTime.text  = "\(Utils.dateToString(eventdt, format: "EEEE dd - MMM")), \(data.startTime) - \(data.endTime)"
        
        if data.status == "in-progress", data.invite?.inviteStatus != "in" {
            _timerLabel.text = "started".localized()
            _timeView.backgroundColor = UIColor(hexString: "#0B62B4")
            _remainingText.isHidden = true
        } else {
            if let eventDate = data.startingSoon {
                let timeInterval = eventDate.timeIntervalSince(Utils.localTimeZoneDate())
                if timeInterval < 24 * 60 * 60 {
                    _timerLabel.text = data.startTime
                    _remainingText.isHidden = true
                } else {
                    let days = Int(timeInterval / (24 * 60 * 60))
                    _timerLabel.text = "\(days) day\(days > 1 ? "s" : "")"
                    _remainingText.text = LANGMANAGER.localizedString(forKey: "remaining", arguments: ["value": "\(data.remainingSeats)"])
                    _remainingText.isHidden = false
                }
            }
            _timeView.backgroundColor = UIColor(hexString: "#6F6F71")
        }
        

//        if !Utils.stringIsNullOrEmpty(data.date) {
//            _timerLabel.font = FontBrand.SFboldFont(size: 16)
//            let currentTime = Utils.getCurrentDate(withFormat: kFormatDateStandard)
//            let tmpEndDate = "\(data.date) \(data.startTime)".toDateUae(format: kFormatDateTimeLocal)
//            _timerLabel.animationType = .Evaporate
//            _timerLabel.timeFormat = "HH:mm"
//            _timerLabel.setCountDownDate(targetDate: tmpEndDate as NSDate)
//            DISPATCH_ASYNC_MAIN_AFTER(0.015) {
//                self._timerLabel.start()
//            }
//        }

    }

}
