import UIKit
import SnapKit

class ComplementaryEventView: UIView {
    
    @IBOutlet weak var _newBadgeView: UIView!
    @IBOutlet weak var _confirmationText: CustomLabel!
    @IBOutlet weak var _confiemedView: UIView!
    @IBOutlet weak var _userImage: UIImageView!
    @IBOutlet weak var _promoterText: CustomLabel!
    @IBOutlet weak var _userName: CustomLabel!
    @IBOutlet weak var _timeLabel: CustomLabel!
    @IBOutlet weak var _venueImage: UIImageView!
    @IBOutlet weak var _venueName: CustomLabel!
    @IBOutlet weak var _venueAddress: CustomLabel!
    @IBOutlet weak var _eventDate: CustomLabel!
    @IBOutlet weak var _eventTime: CustomLabel!
    @IBOutlet weak var _spots: CustomLabel!
    @IBOutlet weak var _eventDesc: CustomLabel!
    @IBOutlet weak var _eventImage: UIImageView!
    @IBOutlet weak var _dateStack: UIStackView!
    @IBOutlet weak var _timeStack: UIStackView!
    @IBOutlet weak var _spotsStack: UIStackView!
    @IBOutlet weak var _collectionView: CustomNoKeyboardCollectionView!
    @IBOutlet weak var _requirementView: UIView!
    @IBOutlet weak var _outButton: CustomActivityButton!
    @IBOutlet weak var _outButtonView: UIView!
    @IBOutlet weak var _chatButton: CustomButton!
    @IBOutlet weak var _onMyListButton: CustomButton!
    @IBOutlet weak var _iMinButton: CustomActivityButton!
    @IBOutlet weak var _iMinButtonView: UIView!
    @IBOutlet weak var _eventFullButton: CustomButton!
    @IBOutlet weak var _cancelledText: CustomLabel!
    private let kCellIdentifier = String(describing: RequirementCollectionCell.self)
    private var _eventModel: PromoterEventsModel?
    
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
        _setupCollectionView()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
        if var view = Bundle.main.loadNibNamed("ComplementaryEventView", owner: self, options: nil)?.first as? UIView {
            addSubview(view)
            view.snp.makeConstraints { make in
                make.leading.trailing.top.bottom.equalToSuperview()
            }
            DISPATCH_ASYNC_MAIN_AFTER(0.1) {
//                self._confiemedView.roundCorners(corners: [.bottomLeft], radius: 8)
                self._confiemedView.layer.maskedCorners = [.layerMinXMaxYCorner]
                self._confiemedView.layer.cornerRadius = 8
            }
        }
    }
    
    private func _setupCollectionView() {
        _collectionView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1,
                              rows: 1,
                              scrollDirection: .vertical,
                              emptyDataText: "no_date".localized(),
                              emptyDataIconImage: UIImage(named: "empty_following"),
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }
    
    private func _loadData(_ list: [String], isAllow: Bool) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        list.forEach({ string in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: isAllow,
                kCellObjectDataKey: string,
                kCellClassKey: RequirementCollectionCell.self,
                kCellHeightKey: RequirementCollectionCell.height
            ])
        })
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
        
    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: RequirementCollectionCell.self, kCellHeightKey: RequirementCollectionCell.height]]
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ data: PromoterEventsModel, isWishList: Bool = false, isCMNotification: Bool = false) {
        _eventModel = data
        let time = Utils.stringDateLocal(data.createdAt, format: kStanderdDate)
        let localTime = Utils.dateToStringUTC(time, format: kStanderdDate)
        _userImage.loadWebImage(data.user?.image ?? kEmptyString,name:  data.user?.fullName ?? kEmptyString)
        _userName.text = data.user?.fullName
        _timeLabel.text = localTime.toDate(format: kStanderdDate).timeAgoSince
        _timeLabel.isHidden = true
        _venueName.text = data.venueType == "venue" ? data.venue?.name : data.customVenue?.name
        _venueAddress.text = data.venueType == "venue" ? data.venue?.address : data.customVenue?.address
        _venueImage.loadWebImage(data.venueType == "venue" ? data.venue?.slogo ?? kEmptyString : data.customVenue?.image ?? kEmptyString, name: (data.venueType == "venue" ? data.venue?.name ?? kEmptyString : data.customVenue?.name) ?? kEmptyString)
        _eventImage.loadWebImage(data.venueType == "venue" ? data.image.isEmpty ? data.venue?.venueCover ?? kEmptyString : data.image : data.customVenue?.image ?? kEmptyString)
        _eventDate.text = Utils.dateToString(Utils.stringToDate(data.date, format: kFormatDate), format: kFormatEventDate)
        _eventTime.text = "\(data.startTime) - \(data.endTime)"
        _eventDesc.text = data.descriptions
        _spots.text = LANGMANAGER.localizedString(forKey: "spots", arguments: ["value": "\(data.maxInvitee)"])
        _loadData(data.requirementsAllowed.toArray(ofType: String.self), isAllow: true)
        _onMyListButton.setTitle(data.isWishlisted ? "remove_from_list".localized() : "add_to_my_list".localized())
        if let invite = data.invite {
            if data.isConfirmationRequired && invite.inviteStatus == "in" && (invite.promoterStatus == "accepted" || invite.promoterStatus == "pending"){
                _confiemedView.isHidden = false
                _confirmationText.text = data.invite?.promoterStatus == "accepted" ? "confirmed" .localized(): "pending".localized()
                _confiemedView.backgroundColor = data.invite?.promoterStatus == "accepted" ? UIColor(hexString: "#0B62B4") : ColorBrand.yellowColor
            } else if !data.isConfirmationRequired && invite.inviteStatus == "in", invite.promoterStatus == "accepted" {
                _confiemedView.isHidden = false
                _confirmationText.text = "im_in".localized()
                _confiemedView.backgroundColor = UIColor(hexString: "#0B62B4")
            } else {
                _confiemedView.isHidden = true
            }
        }
//        _confiemedView.backgroundColor = data.invite?.inviteStatus == "in" && data.invite?.promoterStatus == "accepted" ? UIColor(hexString: "#0B62B4") : UIColor(hexString: "#00AD2E")
        if isWishList {
            if data.status == "cancelled" {
                _cancelledText.isHidden = false
                _outButtonView.isHidden = true
                _chatButton.isHidden = true
                _iMinButtonView.isHidden = true
                _eventFullButton.isHidden = true
                _onMyListButton.isHidden = true
            } else if data.status == "in-progress", data.invite?.inviteStatus == "in" {
                _cancelledText.isHidden = false
                _cancelledText.text = "event_started".localized()
                _cancelledText.textColor = ColorBrand.brandGreen
                _outButtonView.isHidden = true
                _chatButton.isHidden = true
                _iMinButtonView.isHidden = true
                _eventFullButton.isHidden = true
                _onMyListButton.isHidden = true
            } else if data.status == "in-progress", data.invite?.inviteStatus != "in" {
                _cancelledText.isHidden = false
                _cancelledText.text = "event_started".localized()
                _cancelledText.textColor = ColorBrand.brandGreen
                _outButtonView.isHidden = true
                _chatButton.isHidden = true
                _iMinButtonView.isHidden = true
                _eventFullButton.isHidden = true
                _onMyListButton.isHidden = true
            } else if data.invite?.promoterStatus == "rejected" {
                _cancelledText.isHidden = false
                _outButtonView.isHidden = true
                _chatButton.isHidden = true
                _iMinButtonView.isHidden = true
                _onMyListButton.isHidden = false
                _confirmationText.isHidden = true
                _eventFullButton.isHidden = false
                _iMinButtonView.isHidden = true
                _eventFullButton.setTitle("sorry_event_is_full".localized())
            } else {
                _cancelledText.isHidden = true
                if data.invite?.inviteStatus == "in" {
                    _outButtonView.isHidden = false
                    _iMinButtonView.isHidden = true
                } else if data.invite?.inviteStatus == "out" {
                    _outButtonView.isHidden = true
                    _iMinButtonView.isHidden = false
                } else if data.invite?.inviteStatus == "pending" {
                    _outButtonView.isHidden = true
                    _iMinButtonView.isHidden = false
                }
                _eventFullButton.isHidden = true
                if data.isEventFull || data.remainingSeats < 1 && data.invite?.inviteStatus != "in" {
                    _confirmationText.isHidden = true
                    _eventFullButton.isHidden = false
                    _iMinButtonView.isHidden = true
                    _outButtonView.isHidden = true
                }
                _chatButton.isHidden = true
                _onMyListButton.isHidden = false
                _onMyListButton.setTitle("remove_from_list".localized())
            }
            _requirementView.isHidden = true
            _eventImage.isHidden = true
            _spotsStack.isHidden = true
        }
        else if isCMNotification {
            if data.spotCloseType == "manual" && data.invite?.promoterStatus == "accepted" && data.status == "in-progress" {
                _cancelledText.isHidden = true
                if data.invite?.inviteStatus == "in" {
                    _outButtonView.isHidden = false
                    _iMinButtonView.isHidden = true
                } else if data.invite?.inviteStatus == "out" {
                    _outButtonView.isHidden = true
                    _iMinButtonView.isHidden = false
                } else if data.invite?.inviteStatus == "pending" {
                    _outButtonView.isHidden = true
                    _iMinButtonView.isHidden = false
                }
                _chatButton.isHidden = true
                _eventFullButton.isHidden = true
                _onMyListButton.isHidden = false
            } else if data.status == "cancelled" {
                _cancelledText.isHidden = true
                _outButtonView.isHidden = true
                _chatButton.isHidden = true
                _iMinButtonView.isHidden = true
                _onMyListButton.isHidden = true
                _confirmationText.isHidden = true
                _eventFullButton.isHidden = true
                _cancelledText.text = "event_cancelled".localized()
            } else if data.invite?.promoterStatus == "rejected" {
                _cancelledText.isHidden = true
                _outButtonView.isHidden = true
                _chatButton.isHidden = true
                _iMinButtonView.isHidden = true
                _onMyListButton.isHidden = true
                _confirmationText.isHidden = true
                _eventFullButton.isHidden = false
                _eventFullButton.setTitle("sorry_event_is_full".localized())
            } else if data.status == "in-progress" , data.invite?.inviteStatus == "in" {
                _cancelledText.isHidden = false
                _outButtonView.isHidden = true
                _chatButton.isHidden = true
                _iMinButtonView.isHidden = true
                _eventFullButton.isHidden = true
                _onMyListButton.isHidden = true
                _cancelledText.textColor = ColorBrand.brandGreen
                _cancelledText.text = "event_started".localized()
            } else if data.status == "in-progress" , data.invite?.inviteStatus == "in" {
                _cancelledText.isHidden = false
                _outButtonView.isHidden = true
                _chatButton.isHidden = true
                _iMinButtonView.isHidden = true
                _eventFullButton.isHidden = true
                _onMyListButton.isHidden = true
                _cancelledText.textColor = ColorBrand.brandGreen
                _cancelledText.text = "event_started".localized()
            } else {
                _cancelledText.isHidden = true
                if data.invite?.inviteStatus == "in" {
                    _outButtonView.isHidden = false
                    _iMinButtonView.isHidden = true
                } else if data.invite?.inviteStatus == "out" {
                    _outButtonView.isHidden = true
                    _iMinButtonView.isHidden = false
                } else if data.invite?.inviteStatus == "pending" {
                    _outButtonView.isHidden = true
                    _iMinButtonView.isHidden = false
                }
                _chatButton.isHidden = true
                _eventFullButton.isHidden = true
                _onMyListButton.isHidden = false
            }
            _requirementView.isHidden = true
            _eventImage.isHidden = false
            _spotsStack.isHidden = true
        }
        if data.invite?.inviteStatus != "in" && data.isEventFull || data.remainingSeats < 0 {
            _cancelledText.isHidden = true
            _outButtonView.isHidden = true
            _chatButton.isHidden = true
            _iMinButtonView.isHidden = true
            _onMyListButton.isHidden = true
            _confirmationText.isHidden = true
            _eventFullButton.isHidden = false
            _eventFullButton.setTitle("event_full".localized())
        }
        if data.invite?.promoterStatus == "rejected" {
            _confiemedView.isHidden = true
            _confirmationText.isHidden = true
            _eventFullButton.isHidden = false
            _cancelledText.isHidden = true
            _outButtonView.isHidden = true
            _chatButton.isHidden = true
            _iMinButtonView.isHidden = true
            _eventFullButton.setTitle("sorry_event_is_full".localized())
            _onMyListButton.isHidden = !isWishList
        }
        _iMinButton.setTitle(data.isConfirmationRequired ? "interested".localized() : "im_in".localized())
        _iMinButton.backgroundColor = data.isConfirmationRequired ? UIColor(hexString: "B309AC") : UIColor(hexString: "0B62B4")
        _iMinButtonView.backgroundColor = data.isConfirmationRequired ? UIColor(hexString: "B309AC") : UIColor(hexString: "0B62B4")
        _outButton.setTitle(data.isConfirmationRequired ? data.invite?.promoterStatus == "accepted" ? "Confirmed" : "Pending" : "Confirmed")
        _outButtonView.backgroundColor = data.isConfirmationRequired ? data.invite?.promoterStatus == "accepted" ? UIColor(hexString: "#0B62B4")  : UIColor(hexString: "#FFBF00") :  UIColor(hexString: "#0B62B4")
        if _confiemedView.isHidden {
            DISPATCH_ASYNC_MAIN_AFTER(0.1) {
                self._newBadgeView.layer.maskedCorners = [.layerMinXMaxYCorner]
                self._newBadgeView.layer.cornerRadius = 8
            }
        } else {
            self._newBadgeView.layer.cornerRadius = 0
        }
        _newBadgeView.isHidden = !data.isNew
    }
    
    private func _requestInStatus(inviteId: String) {
        self._iMinButton.setTitle(kEmptyString)
        self._iMinButton.showActivity()
        WhosinServices.updateInviteStatus(inviteId: inviteId, inviteStatus: "in") { [weak self] container, error in
            guard let self = self else { return }
            self.parentBaseController?.showError(error)
            self._iMinButton.hideActivity()
            guard let data = container else { return }
            if data.message == "cancellation-penalty" {
                NotificationCenter.default.post(name: .openPenaltyPaymenPopup   , object: nil, userInfo: ["data" : data.data, "event": _eventModel])
            } else {
                let titleMsg = _eventModel?.isConfirmationRequired == true ? "thank_you_for_showing_interest".localized() : "thank_you_for_joining".localized()
                let subtitleMsg = _eventModel?.isConfirmationRequired == true ? "please_wait_for_admin_aproval".localized() : "check_details_and_be_on_time".localized()
                self.parentBaseController?.showSuccessMessage(titleMsg, subtitle: subtitleMsg)
                NotificationCenter.default.post(name: .reloadMyEventsNotifier   , object: nil)
            }
        }
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
    @IBAction func _handleImOutEvent(_ sender: UIButton) {
        let updateTime = Utils.stringToDate(_eventModel?.invite?.updatedAt, format: kStanderdDate) ?? Date()
        let differenceInSeconds = Date().timeIntervalSince(updateTime)
        if _eventModel?.invite?.inviteStatus != "pending" {
            if differenceInSeconds < 60 {
                parentBaseController?.alert(title: "please_wait".localized(), message: "wait_before_changing_response".localized())
                return
            }
        }
        
        if _eventModel?.isConfirmationRequired == false {
            if _eventModel?.isTwoHourRemaining == true {
                let eventName = _eventModel?.venueType == "venue" ? _eventModel?.venue?.name : _eventModel?.customVenue?.name
                parentBaseController?.alert(title: "cancellation_not_allowed".localized(), message: LANGMANAGER.localizedString(forKey: "cannot_cancel_value_less_than_2_hours", arguments: ["value": eventName ?? kEmptyString]))
                return
            }
        }
        
        let alertMessage = _eventModel?.isConfirmationRequired == true ? _eventModel?.invite?.promoterStatus == "accepted" ? "are_you_sure_cancel_confirmation".localized() : "are_you_sure_mark_not_interested".localized() : "are_you_sure_out_from_event".localized()

        
        parentBaseController?.alert(title: kAppName, message: alertMessage, okActionTitle: "yes".localized(), okHandler: { _ in
            guard let invite = self._eventModel?.invite else { return }
            self._outButton.setTitle(kEmptyString)
            self._outButton.showActivity()
            WhosinServices.updateInviteStatus(inviteId: invite.id, inviteStatus: "out") { [weak self] container, error in
                guard let self = self else { return }
                self.parentBaseController?.showError(error)
                self._outButton.hideActivity()
                guard let data = container else { return }
                self.parentBaseController?.showSuccessMessage(data.message, subtitle: kEmptyString)
                NotificationCenter.default.post(name: .reloadMyEventsNotifier, object: nil)
            }
        })
  
    }
    
    @IBAction func _handleChatEvent(_ sender: UIButton) {
        guard let userDetail = APPSESSION.userDetail else { return }
        guard let event = _eventModel else { return }
        let chatModel = ChatModel()
        chatModel.image = event.venueType == "venue" ? event.venue?.logo ?? kEmptyString : event.customVenue?.image ?? kEmptyString
        chatModel.title = event.venueType == "venue" ? event.venue?.name ?? kEmptyString : event.customVenue?.name ?? kEmptyString
        chatModel.chatId = event.id
        chatModel.chatType = ChatType.promoterEvent.rawValue
        DISPATCH_ASYNC_MAIN_AFTER(0.01) {
            let vc = INIT_CONTROLLER_XIB(ChatDetailVC.self)
            vc.chatModel = chatModel
            vc.isPromoter = false
            vc.isComplementry = true
            if let navController = self.parentViewController?.navigationController {
                vc.hidesBottomBarWhenPushed = true
                navController.pushViewController(vc, animated: true)
            } else {
                let nav = NavigationController(rootViewController: vc)
                nav.modalPresentationStyle =  .overFullScreen
                self.parentViewController?.present(nav, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func _handleOnMyListEvent(_ sender: UIButton) {
        guard let eventModel = _eventModel else { return }
        WhosinServices.toggleWishlist(type: "event", typeId: eventModel.id) { [weak self] container, error in
            guard let self = self else { return }
            self.parentBaseController?.showError(error)
            guard let data = container else { return }
            self.parentBaseController?.showSuccessMessage(data.message, subtitle: kEmptyString)
            NotificationCenter.default.post(name: .reloadMyEventsNotifier, object: nil)
        }
    }
    
    @IBAction func _handeImInEvent(_ sender: UIButton) {
        guard let invite = _eventModel?.invite else { return }
        guard _eventModel?.isSameTimeEvent == false else {
            parentBaseController?.alert(title: kAppName, message: "cannot_be_in_different_events".localized())
            return
        }
        let updateTime = Utils.stringToDate(invite.updatedAt, format: kStanderdDate) ?? Date()
        let differenceInSeconds = Date().timeIntervalSince(updateTime)
        if _eventModel?.invite?.inviteStatus != "pending" {
            if differenceInSeconds < 60 {
                parentBaseController?.alert(title: "please_wait".localized(), message: "wait_before_changing_response".localized())
                return
            }
        }
        
        let alertMessage = _eventModel?.isConfirmationRequired == true ?  "confirm_mark_interested_event".localized() : "confirm_mark_in_event".localized()
        
        parentBaseController?.alert(title: kAppName, message: alertMessage, okActionTitle: "yes".localized(), okHandler: { _ in
            if self._eventModel?.plusOneMandatory == true {
                let vc = INIT_CONTROLLER_XIB(PlusOneInivteBottomSheet.self)
                vc.modalPresentationStyle = .overFullScreen
                vc.isEventPlusOne = true
                vc.event = self._eventModel
                vc.groupMembers = self._eventModel?.plusOneMembers.toArrayDetached(ofType: UserDetailModel.self) ?? []
                vc.isMultiSelect = true
                vc.isMandatoryInvite = true
                vc.inviteSuccessCallback = {
                    self._requestInStatus(inviteId: invite.id)
                }
                self.parentViewController?.present(vc, animated: true)
            } else {
                self._requestInStatus(inviteId: invite.id)
            }
        })

    }
    
    @IBAction func _handleEventIsFullEvent(_ sender: UIButton) {
    }
    
    @IBAction func _handlePromoterProfileOpen(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(PromoterPublicProfileVc.self)
        vc.promoterId = _eventModel?.user?.id
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ComplementaryEventView: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? RequirementCollectionCell {
            guard let isAllow = cellDict?[kCellTagKey] as? Bool, let object = cellDict?[kCellObjectDataKey] as? String else { return }
            cell.setup(object, isAllow: isAllow)
            cell._deleteBtn.isHidden = true
            cell.editBtn.isHidden = true
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 28, height: 28)
    }

}



