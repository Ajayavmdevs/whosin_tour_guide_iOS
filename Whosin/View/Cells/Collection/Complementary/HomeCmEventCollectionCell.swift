import UIKit

class HomeCmEventCollectionCell: UICollectionViewCell {

    @IBOutlet private weak var _newBadgeView: UIView!
    @IBOutlet private weak var _tagView: UIView!
    @IBOutlet private weak var _tagTitileLbl: CustomLabel!
    @IBOutlet private weak var _eventImage: UIImageView!
    @IBOutlet private weak var _eventName: CustomLabel!
    @IBOutlet private weak var _eventTime: CustomLabel!
    @IBOutlet private weak var _eventDate: CustomLabel!
    @IBOutlet private weak var _categoryTypeLabel: CustomLabel!
    @IBOutlet weak var _repeatTextLbl: CustomLabel!
    @IBOutlet weak var _remainingSeatsView: UIView!
    @IBOutlet weak var _remainingSeatText: CustomLabel!
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat { 180 }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        DISPATCH_ASYNC_MAIN_AFTER(0.1) {
//            self._tagView.layer.maskedCorners = [.layerMaxXMaxYCorner]
            self._tagView.layer.cornerRadius = 8
            self._newBadgeView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
            self._newBadgeView.layer.cornerRadius = 8
        }
    }

    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setUpdata(_ data: PromoterEventsModel) {
        _eventImage.loadWebImage(data.venueType == "venue" ? data.venue?.venueCover ?? kEmptyString : data.customVenue?.image ?? kEmptyString)
        let date = Utils.stringToDate(data.date, format: kFormatDate)
        _eventDate.text = Utils.dateToString(date, format: kFormatEventDate)
        _eventName.text = data.venueType == "venue" ? data.venue?.name : data.customVenue?.name
        _categoryTypeLabel.text = data.category
        _eventTime.text = "\(data.startTime) - \(data.endTime)"
        if let invite = data.invite {
            if data.isConfirmationRequired && invite.inviteStatus == "in" && (invite.promoterStatus == "accepted" || invite.promoterStatus == "pending"){
                _tagView.isHidden = false
                _tagTitileLbl.text = data.invite?.promoterStatus == "accepted" ? "confirmed".localized() : "pending".localized()
                _tagView.backgroundColor = data.invite?.promoterStatus == "accepted" ? UIColor(hexString: "#00AD2E") : ColorBrand.yellowColor
            } else if !data.isConfirmationRequired && invite.inviteStatus == "in", invite.promoterStatus == "accepted" {
                _tagView.isHidden = false
                _tagTitileLbl.text = "im_in".localized()
                _tagView.backgroundColor = UIColor(hexString: "#0B62B4")
            } else {
                _tagView.isHidden = true
            }

        }
        _remainingSeatsView.isHidden = !(data.invite?.promoterStatus == "accepted" && (data.maxInvitee - data.totalInMembers) <= 5)
        _repeatTextLbl.text = data.repeatEvent == "specific-date" ? data.repeatDate : data.repeatEvent.capitalizedSentence
        _remainingSeatText.text = (data.maxInvitee - data.totalInMembers) == 0 ? "no_remaining_seats".localized() : LANGMANAGER.localizedString(forKey: "seats_remaining", arguments: ["value": "\((data.maxInvitee - data.totalInMembers))"])
        _repeatTextLbl.isHidden = data.repeatEvent == "none"
//        if _tagView.isHidden {
//            DISPATCH_ASYNC_MAIN_AFTER(0.1) {
//                self._newBadgeView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
//                self._newBadgeView.layer.cornerRadius = 8
//            }
//        } else {
//            _newBadgeView.cornerRadius = 0
//        }
        _newBadgeView.isHidden = !data.isNew
    }

}
