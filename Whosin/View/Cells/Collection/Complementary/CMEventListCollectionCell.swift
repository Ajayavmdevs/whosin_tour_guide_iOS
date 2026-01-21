import UIKit
import CountdownLabel

class CMEventListCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var _eventStartedTimeExtedText: CustomLabel!
    @IBOutlet weak var _seatesTitleLabel: CustomLabel!
    @IBOutlet weak var _seatCountView: UIView!
    @IBOutlet weak var _eventExpiredLabel: CustomLabel!
    @IBOutlet weak var _countDownView: CountDownView!
    @IBOutlet weak var _containerView: UIView!
    @IBOutlet weak var _cusomEventVeiw: UIView!
    @IBOutlet private weak var _remainingView: UIView!
    @IBOutlet private weak var _remainingText: UILabel!
    @IBOutlet private weak var _eventCategoryType: UIView!
    @IBOutlet private weak var _eventType: UILabel!
    @IBOutlet private weak var _newBadge: UIView!
    @IBOutlet weak var _confirmationText: CustomLabel!
    @IBOutlet weak var _interestedView: UIView!
    @IBOutlet weak var _interestedViewWidth: NSLayoutConstraint!
    @IBOutlet private weak var _userImage: UIImageView!
    @IBOutlet private weak var _userName: CustomLabel!
    @IBOutlet private weak var _promotertext: CustomLabel!
    @IBOutlet private weak var _venueImg: UIImageView!
    @IBOutlet private weak var _venueName: CustomLabel!
    @IBOutlet private weak var _venueAddress: CustomLabel!
    @IBOutlet private weak var _eventDate: CustomLabel!
    @IBOutlet private weak var _startTime: CustomLabel!
    @IBOutlet private weak var _eventImg: UIImageView!
    @IBOutlet weak var _plusOneView: UIView!
    @IBOutlet weak var _collectionView: CustomNoKeyboardCollectionView!
    @IBOutlet weak var _detailsStack: UIStackView!
    @IBOutlet weak var _eventFullView: UIView!
    private var _promoterId: String = kEmptyString
    private let kCellIdentifierShareWith = String(describing: SharedUsersCollectionCell.self)

    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat { 320 }

    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    override func awakeFromNib() {
        _setupCollectionView()
        super.awakeFromNib()
        DISPATCH_ASYNC_MAIN_AFTER(0.1) {
            self._interestedView.layer.maskedCorners = [.layerMinXMaxYCorner]
            self._interestedView.layer.cornerRadius = 8

        }
    }
    
    private func _setupCollectionView() {
        let spacing = 0
        _collectionView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 5,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              emptyDataDescription: "",
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }
    
    private func _loadData(users: [UserDetailModel]) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        users.forEach({ model in
            cellData.append([
                kCellIdentifierKey: kCellIdentifierShareWith,
                kCellTagKey: kCellIdentifierShareWith,
                kCellDifferenceContentKey: model.id,
                kCellObjectDataKey: model,
                kCellClassKey: SharedUsersCollectionCell.self,
                kCellHeightKey: SharedUsersCollectionCell.height
            ])
        })

        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
        
    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: String(describing: SharedUsersCollectionCell.self), kCellNibNameKey: String(describing: SharedUsersCollectionCell.self), kCellClassKey: SharedUsersCollectionCell.self, kCellHeightKey: SharedUsersCollectionCell.height]]
    }

    public func setupData(_ data: PromoterEventsModel, isIn: Bool = false, isWishList: Bool = false) {
        _interestedView.isHidden = true
        _containerView.borderWidth = 3
        _remainingView.isHidden = true
        _eventFullView.borderColor = ColorBrand.clear
        if let invite = data.invite {
            _seatCountView.isHidden = false
            _remainingText.text = "\(data.maxInvitee - data.totalInMembers)"
            if data.isConfirmationRequired && invite.inviteStatus == "in" && (invite.promoterStatus == "accepted" || invite.promoterStatus == "pending"){
                _interestedView.isHidden = false
                _confirmationText.text = data.invite?.promoterStatus == "accepted" ? "confirmed".localized() : "pending".localized()
                _interestedViewWidth.constant = 90
                _interestedView.backgroundColor = data.invite?.promoterStatus == "accepted" ? UIColor(hexString: "#0B62B4") : ColorBrand.yellowColor
                _containerView.borderColor = data.invite?.promoterStatus == "accepted" ? UIColor(hexString: "#0B62B4") : ColorBrand.yellowColor
            } else if !data.isConfirmationRequired && invite.inviteStatus == "in", invite.promoterStatus == "accepted" {
                _interestedView.isHidden = false
                _confirmationText.text = "confirmed".localized()
                _interestedViewWidth.constant = 90
                _interestedView.backgroundColor = UIColor(hexString: "#0B62B4")
                _containerView.borderColor = UIColor(hexString: "#0B62B4")
            } else {
                _interestedView.isHidden = data.isNew || !((data.maxInvitee - data.totalInMembers) <= 5)
                _confirmationText.text = LANGMANAGER.localizedString(forKey: "seats_remaining", arguments: ["value": "\(data.remainingSeats)"])
                _interestedViewWidth.constant = 140
                _interestedView.backgroundColor = ColorBrand.brandPink//data.isNew ? UIColor(hexString: "#FF3B30") : ColorBrand.brandPink
                _containerView.borderColor = ColorBrand.brandPink//data.isNew ? UIColor(hexString: "#FF3B30") : ColorBrand.brandPink
            }
        }
        if !Utils.stringIsNullOrEmpty(data.date) {
            _countDownView.setupCountdown("\(data.date) \(data.startTime)")
        }
        _promoterId = data.user?.id ?? kEmptyString
        let time = Utils.stringDateLocal(data.invite?.createdAt, format: kStanderdDate)
        let localTime = Utils.dateToStringUTC(time, format: kStanderdDate)
        
        _userName.text = data.user?.fullName
        _userImage.loadWebImage(data.user?.image ?? kEmptyString,name:  data.user?.fullName ?? kEmptyString)
        _venueName.text = data.venueType == "venue" ? data.venue?.name : data.customVenue?.name
        _venueAddress.text = data.venueType == "venue" ? data.venue?.address : data.customVenue?.address
        _venueImg.loadWebImage(data.venueType == "venue" ? data.venue?.slogo ?? kEmptyString : data.customVenue?.image ?? kEmptyString, name: (data.venueType == "venue" ? data.venue?.name ?? kEmptyString : data.customVenue?.name) ?? kEmptyString)
        _plusOneView.isHidden = data.plusOneMembers.isEmpty
        _loadData(users: data.plusOneMembers.toArrayDetached(ofType: UserDetailModel.self))
        
        _startTime.text = "\(data.startTime) - \(data.endTime)"
        _eventImg.loadWebImage(data.venueType == "venue" ? data.image.isEmpty ? data.venue?.venueCover ?? kEmptyString : data.image : data.customVenue?.image ?? kEmptyString)
        let eventdt = Utils.stringToDate(data.date, format: kFormatDate)
        _eventDate.text  = Utils.dateToString(eventdt, format: "EEEE dd - MMM") // befor change format is E, dd/MM/yyyy
        if _interestedView.isHidden {
            DISPATCH_ASYNC_MAIN_AFTER(0.1) {
                self._newBadge.layer.maskedCorners = [.layerMinXMaxYCorner]
                self._newBadge.layer.cornerRadius = 8
            }
        } else {
            self._newBadge.layer.cornerRadius = 0
        }
        _newBadge.isHidden = !data.isNew
        _eventType.text = data.category
        _eventCategoryType.isHidden = Utils.stringIsNullOrEmpty(data.category) || data.category.lowercased() == "none"
        if data.plusOneMembers.isEmpty {
            if Utils.stringIsNullOrEmpty(data.category) || data.category.lowercased() == "none" {
                _detailsStack.spacing = 40
            } else {
                _detailsStack.spacing = 20
            }
        } else if Utils.stringIsNullOrEmpty(data.category) || data.category.lowercased() == "none" {
            if !data.plusOneMembers.isEmpty {
                _detailsStack.spacing = 20
            } else {
                _detailsStack.spacing = 40
            }
        } else {
            _detailsStack.spacing = 5
        }
        if data.status == "in-progress", data.invite?.inviteStatus == "in" {
            _eventExpiredLabel.isHidden = false
            _countDownView.isHidden = true
            _eventExpiredLabel.text = "event_started".localized()
            _eventExpiredLabel.textColor = ColorBrand.brandGreen
            _containerView.borderColor = ColorBrand.brandGreen
            _interestedView.isHidden = true
            _newBadge.isHidden = true
        } else if data.status == "in-progress", data.invite?.inviteStatus != "in", !data.isSpotClosed {
            _eventExpiredLabel.isHidden = false
            _countDownView.isHidden = true
            _eventExpiredLabel.text = "event_started".localized()
            _eventExpiredLabel.textColor = ColorBrand.brandGreen
            _containerView.borderColor = ColorBrand.brandGreen
            _newBadge.isHidden = true
            _interestedView.isHidden = true
        } else if data.status == "cancelled" {
            _eventExpiredLabel.isHidden = false
            _countDownView.isHidden = true
            _eventExpiredLabel.text = data.status == "cancelled" ? "cancelled".localized() : "event_expired".localized()
            _eventExpiredLabel.textColor = ColorBrand.buyNowColor
            _containerView.borderColor = ColorBrand.buyNowColor
            _interestedView.isHidden = true
            _newBadge.isHidden = true
        } else if data.status == "upcoming" {
            _eventExpiredLabel.isHidden = true
            _countDownView.isHidden = false
        }
        if data.invite?.promoterStatus == "rejected" || (data.isSpotClosed && data.invite?.inviteStatus != "in") {
            _eventExpiredLabel.isHidden = false
            _countDownView.isHidden = true
            _eventExpiredLabel.text = "sorry_event_is_full".localized()
            _eventExpiredLabel.textColor = UIColor(hexString: "#B86D00")
            _containerView.borderColor = UIColor(hexString: "#B86D00")
            _eventFullView.borderColor = UIColor(hexString: "#B86D00")
            _interestedView.isHidden = true
            _newBadge.isHidden = true
        }

        if data.status == "completed" {
            _eventExpiredLabel.isHidden = false
            _countDownView.isHidden = true
            _interestedView.isHidden = true
            _eventExpiredLabel.text = "event_completed".localized()
            _eventExpiredLabel.textColor = ColorBrand.brandGreen
            _containerView.borderColor = ColorBrand.brandGreen
            _newBadge.isHidden = true
        }
        _eventStartedTimeExtedText.isHidden = true
        let eventSpotCloseTime = "\(data.date) \(data.spotCloseAt)".toDateUae(format: kFormatDateTimeLocal)
        let currentTime = "\(Date())".toDateUae(format: kFormatDateTimeLocal)
        if !data.isSpotClosed && data.spotCloseType == "manual" && data.invite?.promoterStatus != "accepted" && data.status == "in-progress" && currentTime < eventSpotCloseTime {
            if !Utils.stringIsNullOrEmpty(data.date) {
                _countDownView.setupCountdown("\(data.date) \(data.spotCloseAt)")
            }
            _eventStartedTimeExtedText.isHidden = false
            _eventExpiredLabel.isHidden = true
            _countDownView.isHidden = false
            _eventExpiredLabel.text = "event_started_limited_seats".localized()
            _eventExpiredLabel.textColor = ColorBrand.brandGreen
            _containerView.borderColor = ColorBrand.brandGreen
            _interestedView.isHidden = true
            _newBadge.isHidden = true
        }
        if data.isEventFull, data.invite?.inviteStatus != "in" || (data.isSpotClosed && data.invite?.inviteStatus != "in")  {
            _eventExpiredLabel.isHidden = false
            _countDownView.isHidden = true
            _eventExpiredLabel.text = "event_full".localized()
            _eventExpiredLabel.textColor = UIColor(hexString: "#B86D00")
            _containerView.borderColor = UIColor(hexString: "#B86D00")
            _eventFullView.borderColor = UIColor(hexString: "#B86D00")
            _interestedView.isHidden = true
            _newBadge.isHidden = true
        }
        
    }
    
    public func setupPlusData(_ data: PromoterEventsModel, isIn: Bool = false, isWishList: Bool = false) {
        _interestedView.isHidden = true
        _containerView.borderWidth = 3
        _remainingView.isHidden = true
        _eventFullView.borderColor = ColorBrand.clear
        if let invite = data.invite {
            _seatCountView.isHidden = false
            _remainingText.text = "\(data.maxInvitee - data.totalInMembers)"
            if invite.inviteStatus == "in", invite.promoterStatus == "accepted" {
                _interestedView.isHidden = false
                _confirmationText.text = "confirmed".localized()
                _interestedView.backgroundColor = UIColor(hexString: "#0B62B4")
                _containerView.borderColor = UIColor(hexString: "#0B62B4")
            } else if invite.inviteStatus == "in", invite.promoterStatus == "pending" {
                _interestedView.isHidden = true
                _interestedView.backgroundColor = ColorBrand.yellowColor
                _containerView.borderColor = ColorBrand.yellowColor
            } else {
                _interestedView.isHidden = true
                _interestedView.backgroundColor = ColorBrand.brandPink//data.isNew ? UIColor(hexString: "#FF3B30") : ColorBrand.brandPink
                _containerView.borderColor = ColorBrand.brandPink//data.isNew ? UIColor(hexString: "#FF3B30") : ColorBrand.brandPink
            }
        }
        if !Utils.stringIsNullOrEmpty(data.date) {
            _countDownView.setupCountdown("\(data.date) \(data.startTime)")
        }
        _promoterId = data.user?.id ?? kEmptyString
        let time = Utils.stringDateLocal(data.invite?.createdAt, format: kStanderdDate)
        let localTime = Utils.dateToStringUTC(time, format: kStanderdDate)
        
        _userName.text = data.user?.fullName
        _userImage.loadWebImage(data.user?.image ?? kEmptyString,name:  data.user?.fullName ?? kEmptyString)
        _venueName.text = data.venueType == "venue" ? data.venue?.name : data.customVenue?.name
        _venueAddress.text = data.venueType == "venue" ? data.venue?.address : data.customVenue?.address
        _venueImg.loadWebImage(data.venueType == "venue" ? data.venue?.slogo ?? kEmptyString : data.customVenue?.image ?? kEmptyString, name: (data.venueType == "venue" ? data.venue?.name ?? kEmptyString : data.customVenue?.name) ?? kEmptyString)
        _plusOneView.isHidden = data.plusOneMembers.isEmpty
        _loadData(users: data.plusOneMembers.toArrayDetached(ofType: UserDetailModel.self))
        
        _startTime.text = "\(data.startTime) - \(data.endTime)"
        _eventImg.loadWebImage(data.venueType == "venue" ? data.image.isEmpty ? data.venue?.venueCover ?? kEmptyString : data.image : data.customVenue?.image ?? kEmptyString)
        let eventdt = Utils.stringToDate(data.date, format: kFormatDate)
        _eventDate.text  = Utils.dateToString(eventdt, format: "EEEE dd - MMM") // befor change format is E, dd/MM/yyyy
        if _interestedView.isHidden {
            DISPATCH_ASYNC_MAIN_AFTER(0.1) {
                self._newBadge.layer.maskedCorners = [.layerMinXMaxYCorner]
                self._newBadge.layer.cornerRadius = 8
            }
        } else {
            self._newBadge.layer.cornerRadius = 0
        }
        _newBadge.isHidden = !data.isNew
        _eventType.text = data.category
        _eventCategoryType.isHidden = Utils.stringIsNullOrEmpty(data.category) || data.category.lowercased() == "none"
        if data.plusOneMembers.isEmpty {
            if Utils.stringIsNullOrEmpty(data.category) || data.category.lowercased() == "none" {
                _detailsStack.spacing = 40
            } else {
                _detailsStack.spacing = 20
            }
        } else if Utils.stringIsNullOrEmpty(data.category) || data.category.lowercased() == "none" {
            if !data.plusOneMembers.isEmpty {
                _detailsStack.spacing = 20
            } else {
                _detailsStack.spacing = 40
            }
        } else {
            _detailsStack.spacing = 5
        }
        if data.status == "in-progress", data.invite?.inviteStatus == "in" {
            _eventExpiredLabel.isHidden = false
            _countDownView.isHidden = true
            _eventExpiredLabel.text = "event_started".localized()
            _eventExpiredLabel.textColor = ColorBrand.brandGreen
            _containerView.borderColor = ColorBrand.brandGreen
            _interestedView.isHidden = true
            _newBadge.isHidden = true
        } else if data.status == "in-progress", data.invite?.inviteStatus != "in", !data.isSpotClosed {
            _eventExpiredLabel.isHidden = false
            _countDownView.isHidden = true
            _eventExpiredLabel.text = "event_started".localized()
            _eventExpiredLabel.textColor = ColorBrand.brandGreen
            _containerView.borderColor = ColorBrand.brandGreen
            _newBadge.isHidden = true
            _interestedView.isHidden = true
        } else if data.status == "cancelled" {
            _eventExpiredLabel.isHidden = false
            _countDownView.isHidden = true
            _eventExpiredLabel.text = data.status == "cancelled" ? "cancelled".localized() : "event_expired".localized()
            _eventExpiredLabel.textColor = ColorBrand.buyNowColor
            _containerView.borderColor = ColorBrand.buyNowColor
            _interestedView.isHidden = true
            _newBadge.isHidden = true
        } else if data.status == "upcoming" {
            _eventExpiredLabel.isHidden = true
            _countDownView.isHidden = false
        }
        if data.invite?.promoterStatus == "rejected" || (data.isSpotClosed && data.invite?.inviteStatus != "in") {
            _eventExpiredLabel.isHidden = false
            _countDownView.isHidden = true
            _eventExpiredLabel.text = "sorry_event_is_full"
            _eventExpiredLabel.textColor = UIColor(hexString: "#B86D00")
            _containerView.borderColor = UIColor(hexString: "#B86D00")
            _eventFullView.borderColor = UIColor(hexString: "#B86D00")
            _interestedView.isHidden = true
            _newBadge.isHidden = true
        }

        if data.status == "completed" {
            _eventExpiredLabel.isHidden = false
            _countDownView.isHidden = true
            _interestedView.isHidden = true
            _eventExpiredLabel.text = "event_completed".localized()
            _eventExpiredLabel.textColor = ColorBrand.brandGreen
            _containerView.borderColor = ColorBrand.brandGreen
            _newBadge.isHidden = true
        }
        _eventStartedTimeExtedText.isHidden = true
        let eventSpotCloseTime = "\(data.date) \(data.spotCloseAt)".toDateUae(format: kFormatDateTimeLocal)
        let currentTime = "\(Date())".toDateUae(format: kFormatDateTimeLocal)
        if !data.isSpotClosed && data.spotCloseType == "manual" && data.invite?.promoterStatus != "accepted" && data.status == "in-progress" && currentTime < eventSpotCloseTime {
            if !Utils.stringIsNullOrEmpty(data.date) {
                _countDownView.setupCountdown("\(data.date) \(data.spotCloseAt)")
            }
            _eventStartedTimeExtedText.isHidden = false
            _eventExpiredLabel.isHidden = true
            _countDownView.isHidden = false
            _eventExpiredLabel.text = "event_started_limited_seats".localized()
            _eventExpiredLabel.textColor = ColorBrand.brandGreen
            _containerView.borderColor = ColorBrand.brandGreen
            _interestedView.isHidden = true
            _newBadge.isHidden = true
        }
        if data.isEventFull, data.invite?.inviteStatus != "in" || (data.isSpotClosed && data.invite?.inviteStatus != "in")  {
            _eventExpiredLabel.isHidden = false
            _countDownView.isHidden = true
            _eventExpiredLabel.text = "event_full".localized()
            _eventExpiredLabel.textColor = UIColor(hexString: "#B86D00")
            _containerView.borderColor = UIColor(hexString: "#B86D00")
            _eventFullView.borderColor = UIColor(hexString: "#B86D00")
            _interestedView.isHidden = true
            _newBadge.isHidden = true
        }
        
    }
    
    
    @IBAction func _handleOpenPromoterDetail(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(PromoterPublicProfileVc.self)
        vc.promoterId = _promoterId
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }

}

extension CMEventListCollectionCell:  CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? SharedUsersCollectionCell, let object = cellDict?[kCellObjectDataKey] as? UserDetailModel {
            cell.setupData(object, inviteStatus: true)
            cell._button.isEnabled = false
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: SharedUsersCollectionCell.height)
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
        let controller = INIT_CONTROLLER_XIB(UsersProfileVC.self)
        controller.contactId = object.userId
        self.parentViewController?.navigationController?.pushViewController(controller, animated: true)

    }
    
}
