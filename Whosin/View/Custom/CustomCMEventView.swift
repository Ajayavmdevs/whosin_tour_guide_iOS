import UIKit
import SnapKit
import CountdownLabel

class CustomCMEventView: UIView {
    
    @IBOutlet private weak var _remainingView: UIView!
    @IBOutlet private weak var _remainingText: UILabel!
    @IBOutlet private weak var _repeattype: CustomLabel!
    @IBOutlet private weak var _eventCategoryType: CustomLabel!
    @IBOutlet private weak var _newBadge: UIView!
    @IBOutlet weak var _confirmationText: CustomLabel!
    @IBOutlet weak var _interestedView: UIView!
    @IBOutlet private weak var _eventExpiredLabel: CustomLabel!
    @IBOutlet private weak var _countDownLabel: CountdownLabel!
    @IBOutlet private weak var _userImage: UIImageView!
    @IBOutlet private weak var _userName: CustomLabel!
    @IBOutlet private weak var _promotertext: CustomLabel!
    @IBOutlet private weak var _venueImg: UIImageView!
    @IBOutlet private weak var _venueName: CustomLabel!
    @IBOutlet private weak var _venueAddress: CustomLabel!
    @IBOutlet private weak var _timeLbl: CustomLabel!
    @IBOutlet private weak var _eventDate: CustomLabel!
    @IBOutlet private weak var _eventDesc: CustomLabel!
    @IBOutlet private weak var _startTime: CustomLabel!
    @IBOutlet private weak var _endTime: CustomLabel!
    @IBOutlet private weak var _eventImg: UIImageView!
    private var _promoterId: String = kEmptyString

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupUi()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _setupUi()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
        if var view = Bundle.main.loadNibNamed("CustomCMEventView", owner: self, options: nil)?.first as? UIView {
            addSubview(view)
            view.snp.makeConstraints { make in
                make.leading.trailing.top.bottom.equalToSuperview()
            }
        }
        DISPATCH_ASYNC_MAIN_AFTER(0.1) {
            self._interestedView.layer.maskedCorners = [.layerMinXMaxYCorner]
            self._interestedView.layer.cornerRadius = 8

        }
    }
    
    public func setupData(_ data: PromoterEventsModel, isIn: Bool = false, isWishList: Bool = false) {
        _interestedView.isHidden = true
        if let invite = data.invite {
            let reaminingSeats = data.maxInvitee - data.totalInMembers
            _remainingView.isHidden = !(invite.promoterStatus == "accepted" && (reaminingSeats) <= 5)
            _remainingText.text = reaminingSeats < 1 ? "no_seats_reamining".localized() : LANGMANAGER.localizedString(forKey: "seats_remaining", arguments: ["value": String(reaminingSeats)])
            if data.isConfirmationRequired && invite.inviteStatus == "in" && (invite.promoterStatus == "accepted" || invite.promoterStatus == "pending"){
                _interestedView.isHidden = false
                _confirmationText.text = data.invite?.promoterStatus == "accepted" ? "confirmed".localized() : "pending".localized()
                _interestedView.backgroundColor = data.invite?.promoterStatus == "accepted" ? UIColor(hexString: "#00AD2E") : ColorBrand.yellowColor
            } else if !data.isConfirmationRequired && invite.inviteStatus == "in", invite.promoterStatus == "accepted" {
                _interestedView.isHidden = false
                _confirmationText.text = "im_in".localized()
                _interestedView.backgroundColor = UIColor(hexString: "#0B62B4")
            } else {
                _interestedView.isHidden = true
            }
        }
//        _confirmationText.text = data.invite?.inviteStatus == "in" && data.invite?.promoterStatus == "accepted" ? "confirmed" : "interested"
        _promoterId = data.user?.id ?? kEmptyString
        let time = Utils.stringDateLocal(data.invite?.createdAt, format: kStanderdDate)
        let localTime = Utils.dateToStringUTC(time, format: kStanderdDate)
        _timeLbl.text = localTime.toDateUae(format: kStanderdDate).timeAgoSince
        _timeLbl.isHidden = true

        _userName.text = data.user?.fullName
        _userImage.loadWebImage(data.user?.image ?? kEmptyString,name:  data.user?.fullName ?? kEmptyString)
        _venueName.text = data.venueType == "venue" ? data.venue?.name : data.customVenue?.name
        _venueAddress.text = data.venueType == "venue" ? data.venue?.address : data.customVenue?.address
        _venueImg.loadWebImage(data.venueType == "venue" ? data.venue?.slogo ?? kEmptyString : data.customVenue?.image ?? kEmptyString, name: (data.venueType == "venue" ? data.venue?.name ?? kEmptyString : data.customVenue?.name) ?? kEmptyString)
        _eventDesc.text = data.descriptions

        _startTime.text = "\(data.startTime)"
        _endTime.text = "\(data.endTime)"
        _eventImg.loadWebImage(data.venueType == "venue" ? data.image.isEmpty ? data.venue?.venueCover ?? kEmptyString : data.image : data.customVenue?.image ?? kEmptyString)
        let eventdt = Utils.stringToDate(data.date, format: kFormatDate)
        _eventDate.text  = Utils.dateToString(eventdt, format: kFormatDateMonthShort)
        if !Utils.stringIsNullOrEmpty(data.date) {
            _countDownLabel.font = FontBrand.SFboldFont(size: 24)
            let currentTime = Utils.getCurrentDate(withFormat: kFormatDateStandard)
            let tmpEndDate = "\(data.date) \(data.startTime)".toDateUae(format: kFormatDateTimeLocal)
            _countDownLabel.animationType = .Evaporate
            _countDownLabel.timeFormat = "dd:HH:mm:ss"
            _countDownLabel.setCountDownDate(targetDate: tmpEndDate as NSDate)
            DISPATCH_ASYNC_MAIN_AFTER(0.015) {
                self._countDownLabel.start()
            }
        }
        if data.status == "in-progress", data.invite?.inviteStatus == "in" {
            _eventExpiredLabel.isHidden = false
            _countDownLabel.isHidden = true
            _eventExpiredLabel.text = "event_started".localized()
            _eventExpiredLabel.textColor = ColorBrand.brandGreen
        } else if data.status == "in-progress", data.invite?.inviteStatus != "in" {
            _eventExpiredLabel.isHidden = false
            _countDownLabel.isHidden = true
            _eventExpiredLabel.text = "event_started".localized()
            _eventExpiredLabel.textColor = ColorBrand.brandGreen
        } else if data.status == "cancelled" {
            _eventExpiredLabel.isHidden = false
            _countDownLabel.isHidden = true
            _eventExpiredLabel.text = data.status == "cancelled" ? "cancelled".localized() : "Event Expired"
            _eventExpiredLabel.textColor = ColorBrand.buyNowColor
        } else if data.status == "upcoming" {
            _eventExpiredLabel.isHidden = true
            _countDownLabel.isHidden = false
        }
        if data.invite?.promoterStatus == "rejected" {
            _countDownLabel.pause()
            _countDownLabel.cancel()
            _eventExpiredLabel.isHidden = false
            _countDownLabel.isHidden = true
            _eventExpiredLabel.text = "event_full".localized()
            _eventExpiredLabel.textColor = UIColor(hexString: "#B86D00")
            _interestedView.isHidden = true
        }
        if _interestedView.isHidden {
            DISPATCH_ASYNC_MAIN_AFTER(0.1) {
                self._newBadge.layer.maskedCorners = [.layerMinXMaxYCorner]
                self._newBadge.layer.cornerRadius = 8
            }
        } else {
            self._newBadge.layer.cornerRadius = 0
        }
        _newBadge.isHidden = !data.isNew
        _repeattype.text = "repeat" +
        "\(data.repeatEvent == "specific-date" ? data.repeatDate : data.repeatEvent)"
        _eventCategoryType.text = data.category
        _repeattype.isHidden = data.repeatEvent == "none"
        _eventCategoryType.isHidden = true
    }

    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
    @IBAction func _handleOpenPromoterDetail(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(PromoterPublicProfileVc.self)
        vc.promoterId = _promoterId
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
}


