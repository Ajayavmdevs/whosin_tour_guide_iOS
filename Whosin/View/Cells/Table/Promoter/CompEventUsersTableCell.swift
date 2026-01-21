import UIKit

class CompEventUsersTableCell: UITableViewCell {

    @IBOutlet weak var _outStackView: UIStackView!
    @IBOutlet weak var _completeBtn: CustomActivityButton!
    @IBOutlet weak var _cancelledText: CustomLabel!
    @IBOutlet weak var _deleteEventBtn: CustomActivityButton!
    @IBOutlet weak var _editEventBtn: CustomActivityButton!
    @IBOutlet weak var _complementaryButtonStack: UIStackView!
    @IBOutlet weak var _promoterStackView: UIStackView!
    @IBOutlet weak var _imOutButton: CustomActivityButton!
    @IBOutlet weak var _onMyListButton: CustomActivityButton!
    @IBOutlet weak var _imInButton: CustomActivityButton!
    @IBOutlet weak var _eventIsFullButton: CustomActivityButton!
    private var eventModel: PromoterEventsModel?
    
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

    public func setupData(_ model: PromoterEventsModel, isComplementary: Bool = false) {
        eventModel = model
        if model.isConfirmationRequired {
            _imOutButton.setTitle(model.invite?.promoterStatus == "accepted" ? "cancel_confirmation".localized() : "not_interested".localized())
            _imInButton.setTitle("interested".localized())
        } else {
            _imOutButton.setTitle("im_out".localized())
            _imInButton.setTitle("im_in".localized())
        }
        if model.status == "cancelled" {
            _complementaryButtonStack.isHidden = true
            _promoterStackView.isHidden = true
            _cancelledText.isHidden = true
            _eventIsFullButton.isHidden = false
            _cancelledText.text = model.invite?.promoterStatus == "rejected" ? "rejected".localized() : "cancelled".localized()
        } else if model.invite?.promoterStatus == "rejected" {
            _complementaryButtonStack.isHidden = false
            _promoterStackView.isHidden = true
            _outStackView.isHidden = true
            _completeBtn.isHidden = true
            _cancelledText.isHidden = true
            _eventIsFullButton.isHidden = false
            _eventIsFullButton.setTitle("sorry_event_is_full".localized())
        } else {
            _cancelledText.isHidden = true
            if isComplementary {
                if model.invite?.inviteStatus == "in" {
                    _imOutButton.isHidden = false
                    _imInButton.isHidden = true
                } else if model.invite?.inviteStatus == "out" {
                    _imOutButton.isHidden = true
                    _imInButton.isHidden = false
                } else if model.invite?.inviteStatus == "pending" {
                    _imOutButton.isHidden = true
                    _imInButton.isHidden = false
                }
                _complementaryButtonStack.isHidden = false
                _promoterStackView.isHidden = true
            } else {
                _complementaryButtonStack.isHidden = true
                _promoterStackView.isHidden = false
            }
        }
        _onMyListButton.setTitle(model.isWishlisted ? "remove_from_list".localized() : "add_to_my_list".localized())
        if model.isEventFull || model.maxInvitee < 1 {
            _eventIsFullButton.isHidden = false
            _imInButton.isHidden = true
        } else {
            _eventIsFullButton.isHidden = true
        }
        if model.invite?.inviteStatus == "in", model.status == "in-progress", isComplementary {
            _cancelledText.isHidden = false
            _cancelledText.text = "event_started".localized()
            _cancelledText.textColor = ColorBrand.brandGreen
            _complementaryButtonStack.isHidden = true
            _promoterStackView.isHidden = true
            _completeBtn.isHidden = true
        } else if model.status == "in-progress", model.status != "completed", !isComplementary {
            _cancelledText.isHidden = true
            _complementaryButtonStack.isHidden = false
            _promoterStackView.isHidden = true
            _imInButton.isHidden = true
            _eventIsFullButton.isHidden = true
            _outStackView.isHidden = true
            _completeBtn.isHidden = false
        } else if model.invite?.inviteStatus != "in", model.status == "in-progress", isComplementary {
            _cancelledText.isHidden = false
            _cancelledText.text = "event_started".localized()
            _cancelledText.textColor = ColorBrand.brandGreen
            _complementaryButtonStack.isHidden = true
            _promoterStackView.isHidden = true
            _completeBtn.isHidden = true
        } else if model.status == "completed" {
            _cancelledText.isHidden = false
            _cancelledText.text = "event_completed".localized()
            _complementaryButtonStack.isHidden = true
            _outStackView.isHidden = true
            _promoterStackView.isHidden = true
            _completeBtn.isHidden = true
        } else if model.status == "cancelled" {
            _cancelledText.isHidden = false
            _cancelledText.text = "event_cancelled".localized()
            _complementaryButtonStack.isHidden = true
            _outStackView.isHidden = true
            _promoterStackView.isHidden = true
            _completeBtn.isHidden = true
            
        } else if model.invite?.promoterStatus == "rejected", isComplementary {
            _complementaryButtonStack.isHidden = false
            _promoterStackView.isHidden = true
            _outStackView.isHidden = true
            _completeBtn.isHidden = true
            _cancelledText.isHidden = true
            _eventIsFullButton.isHidden = false
            _eventIsFullButton.setTitle("sorry_event_is_full".localized())
        }
    }
    
    private func _requestCancelEvent(_ eventId: String) {
        _deleteEventBtn.setTitle("")
        _deleteEventBtn.showActivity()
        WhosinServices.cancelMyEvent(id: eventId) { [weak self] container, error in
            guard let self = self else { return }
            self._deleteEventBtn.hideActivity()
            self._deleteEventBtn.setTitle("cancel_event".localized())
            guard let data = container else { return }
            if data.code == 1 {
                self.parentBaseController?.showToast(data.message)
                NotificationCenter.default.post(name: .reloadMyEventsNotifier   , object: nil)
            }
        }
    }
    
    private func _requestCompleteEvent() {
        _completeBtn.showActivity()
        guard let id = eventModel?.id else { return }
        WhosinServices.promoterEventComplete(id: id) { [weak self] contaienr, error in
            guard let self = self else { return }
            self.parentBaseController?.hideHUD(error: error)
            self._completeBtn.hideActivity()
            self._completeBtn.setTitle("cancel".localized())
            guard let data = contaienr else { return }
            if data.code == 1 {
                self.parentBaseController?.showToast(data.message)
                NotificationCenter.default.post(name: .reloadMyEventsNotifier   , object: nil)
            }
        }
    }
    
    @IBAction func _handleEditEvent(_ sender: CustomActivityButton) {
        let vc = INIT_CONTROLLER_XIB(CreateEventVC.self)
        vc.isEditEvent = true
        vc.params = eventModel?.toEventJSON() ?? [:]
        vc.eventModel = self.eventModel
        vc.socialAccounts = eventModel?.socialAccountsToMention.toArrayDetached(ofType: SocialAccountsModel.self) ?? []
        vc.hidesBottomBarWhenPushed = true
        self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func _handleCancelEvent(_ sender: CustomActivityButton) {
                
        if eventModel?.isTwoHourRemaining == true {
            self.parentBaseController?.showCustomAlert(title: "cancellation_not_allowed".localized(), message: "cannot_cancel_within_2_hours_warning".localized(), yesButtonTitle: "yes".localized(), noButtonTitle: "no".localized(), okHandler: { UIAlertAction in
                self._requestCancelEvent(self.eventModel?.id ?? kEmptyString)
            }, noHandler:  { UIAlertAction in
            })

        } else {
            self.parentBaseController?.showCustomAlert(title: kAppName, message: "are_you_sure_cancel".localized(), yesButtonTitle: "yes".localized(), noButtonTitle: "no".localized(), okHandler: { UIAlertAction in
                self._requestCancelEvent(self.eventModel?.id ?? kEmptyString)
            }, noHandler:  { UIAlertAction in
            })
        }
    }
    
    @IBAction func _handleImOutEvent(_ sender: UIButton) {
        let updateTime = Utils.stringToDate(eventModel?.invite?.updatedAt, format: kStanderdDate) ?? Date()
        let differenceInSeconds = Date().timeIntervalSince(updateTime)
        if eventModel?.invite?.inviteStatus != "pending" {
            if differenceInSeconds < 60 {
                parentBaseController?.alert(title: "please_wait".localized, message: "wait_before_changing_response".localized())
                return
            }
        }
        
//        guard eventModel?.isSameTimeEvent == false else {
//            parentBaseController?.alert(title: kAppName, message: "You cannot be in different events at the same time.")
//            return
//        }

        if eventModel?.isConfirmationRequired == false {
            if eventModel?.isTwoHourRemaining == true {
                let eventName = eventModel?.venueType == "venue" ? eventModel?.venue?.name : eventModel?.customVenue?.name
                parentBaseController?.alert(title: "cancellation_not_allowed".localized(), message: LANGMANAGER.localizedString(forKey: "cannot_cancel_value_less_than_2_hours", arguments: ["value": eventName ?? kEmptyString]))
                return
            }
        }
        
        let alertMessage = eventModel?.isConfirmationRequired == true ? eventModel?.invite?.promoterStatus == "accepted" ? "are_you_sure_cancel_confirmation".localized() : "are_you_sure_mark_not_interested".localized() : "are_you_sure_out_from_event".localized()
        
        parentBaseController?.alert(title: kAppName, message: alertMessage, okActionTitle: "yes".localized(), okHandler: { _ in
            
            guard let invite = self.eventModel?.invite else { return }
            self._imOutButton.setTitle(kEmptyString)
            self._imOutButton.showActivity()
            WhosinServices.updateInviteStatus(inviteId: invite.id, inviteStatus: "out") { [weak self] container, error in
                guard let self = self else { return }
                self._imOutButton.hideActivity()
                self.parentBaseController?.showError(error)
                guard let data = container else { return }
                self.parentBaseController?.showSuccessMessage(data.message, subtitle: kEmptyString)
                NotificationCenter.default.post(name: .reloadMyEventsNotifier   , object: nil)
            }
        })
    }
    
    @IBAction func _handleOnMyListEvent(_ sender: UIButton) {
        guard let eventModel = eventModel else { return }
        self._onMyListButton.showActivity()
        WhosinServices.toggleWishlist(type: "event", typeId: eventModel.id) { [weak self] container, error in
            guard let self = self else { return }
            self._onMyListButton.hideActivity()
            self.parentBaseController?.showError(error)
            guard let data = container else { return }
            self.parentBaseController?.showSuccessMessage(data.message, subtitle: kEmptyString)
            NotificationCenter.default.post(name: .reloadMyEventsNotifier   , object: nil)
        }
    }
    
    @IBAction func _handleImInEvent(_ sender: UIButton) {

        guard let invite = eventModel?.invite else { return }
        guard eventModel?.isSameTimeEvent == false else {
            parentBaseController?.alert(title: kAppName, message: "cannot_be_in_different_events".localized())
            return
        }

        let updateTime = Utils.stringToDate(invite.updatedAt, format: kStanderdDate) ?? Date()
        let differenceInSeconds = Date().timeIntervalSince(updateTime)
        if eventModel?.invite?.inviteStatus != "pending" {
            if differenceInSeconds < 60 {
                parentBaseController?.alert(title: "please_wait".localized(), message: "wait_before_changing_response".localized())
                return
            }
        }
        _imInButton.setTitle(kEmptyString)
        _imInButton.showActivity()
        WhosinServices.updateInviteStatus(inviteId: invite.id, inviteStatus: "in") { [weak self] container, error in
            guard let self = self else { return }
            self.parentBaseController?.showError(error)
            self._imInButton.hideActivity()
            guard let data = container else { return }
            if data.message == "cancellation-penalty" {
                NotificationCenter.default.post(name: .openPenaltyPaymenPopup   , object: nil, userInfo: ["data" : data.data, "event": eventModel])
            } else {
                let titleMsg = eventModel?.isConfirmationRequired == true ? "thank_you_for_showing_interest".localized() : "thank_you_for_joining".localized()
                let subtitleMsg = eventModel?.isConfirmationRequired == true ? "admin_will_review_request".localized() : "check_details_and_be_on_time".localized()
                self.parentBaseController?.showSuccessMessage(titleMsg, subtitle: subtitleMsg)
                NotificationCenter.default.post(name: .reloadMyEventsNotifier   , object: nil)
            }
        }
    }
    
    @IBAction func _handleCompleteEvent(_ sender: CustomActivityButton) {
        _requestCompleteEvent()
    }
    
    @IBAction func _handleEventFullEvent(_ sender: UIButton) {
    }
    
}
