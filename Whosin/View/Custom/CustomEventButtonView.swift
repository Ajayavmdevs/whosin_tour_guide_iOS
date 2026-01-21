import UIKit
import Lottie
import SnapKit
import CountdownLabel

class CustomEventButtonView: UIView {
    
    @IBOutlet weak var _closeSpotButton: CustomActivityButton!
    @IBOutlet weak var _dropdownic: UIImageView!
    @IBOutlet weak var sapratiorLine: UILabel!
    @IBOutlet weak var _animationView: LottieAnimationView!
    @IBOutlet weak var _viewTicketView: UIView!
    @IBOutlet weak var _outStackView: UIStackView!
    @IBOutlet weak var _viewTicketButton: CustomButton!
    @IBOutlet weak var _completeBtn: CustomActivityButton!
    @IBOutlet weak var _completeBtnView: UIView!
    @IBOutlet weak var _cancelledText: CustomLabel!
    @IBOutlet weak var _deleteEventBtn: CustomActivityButton!
    @IBOutlet weak var _editEventBtn: CustomActivityButton!
    @IBOutlet weak var _complementaryButtonStack: UIStackView!
    @IBOutlet weak var _promoterStackView: UIStackView!
    @IBOutlet weak var _imOutButton: CustomActivityButton!
    @IBOutlet weak var _onMyListButton: CustomActivityButton!
    @IBOutlet weak var _imOutButtonView: UIView!
    @IBOutlet weak var _onMyListButtonView: UIView!
    @IBOutlet weak var _imInButton: CustomActivityButton!
    @IBOutlet weak var _imInButtonView: UIView!
    @IBOutlet weak var _eventIsFullButton: CustomActivityButton!
    @IBOutlet weak var _eventHideShowButton: CustomActivityButton!
    @IBOutlet weak var _plusOneOutView: UIView!
    @IBOutlet weak var _plusOneOutButton: CustomActivityButton!
    private var eventModel: PromoterEventsModel?
    private var isPlusOne: Bool = false
    public var openViewTicket:(()-> Void)?

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
        if var view = Bundle.main.loadNibNamed("CustomEventButtonView", owner: self, options: nil)?.first as? UIView {
            addSubview(view)
            view.snp.makeConstraints { make in
                make.leading.trailing.top.bottom.equalToSuperview()
            }
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ model: PromoterEventsModel, isComplementary: Bool = false, isPlusOne: Bool = false) {
        eventModel = model
        self.isPlusOne = isPlusOne
        if eventModel?.isEventFull == true, isComplementary, eventModel?.invite?.inviteStatus != "in" {
            _complementaryButtonStack.isHidden = true
            _promoterStackView.isHidden = true
            _outStackView.isHidden = true
            _imOutButtonView.isHidden = true
            _imInButtonView.isHidden = true
            _completeBtnView.isHidden = true
            _cancelledText.isHidden = true
            _eventIsFullButton.isHidden = false
            _eventIsFullButton.setTitle("event_full".localized())
        } else {
            if model.isConfirmationRequired {
                _imOutButton.setTitle(model.invite?.promoterStatus == "accepted" ? "confirmed".localized() : "pending".localized())
                _imOutButtonView.backgroundColor = model.invite?.promoterStatus == "accepted" ? UIColor(hexString: "#0b62b4") : UIColor(hexString: "#FFBF00")
                _dropdownic.isHidden = model.invite?.promoterStatus != "accepted" && model.invite?.inviteStatus != "in"
                sapratiorLine.isHidden = model.invite?.promoterStatus != "accepted" && model.invite?.inviteStatus != "in"
                sapratiorLine.textColor =  model.invite?.promoterStatus == "accepted" ? UIColor(hexString: "#0C73B4") : UIColor(hexString: "#F1E0AE")
                _imInButton.setTitle("interested".localized())
                _imInButton.backgroundColor = UIColor(hexString: "#B309AC")
                _imInButtonView.backgroundColor = UIColor(hexString: "#B309AC")
            } else {
                _imOutButton.setTitle("confirmed".localized())
                _dropdownic.isHidden = model.invite?.promoterStatus != "accepted" && model.invite?.inviteStatus != "in"
                sapratiorLine.isHidden = model.invite?.promoterStatus != "accepted" && model.invite?.inviteStatus != "in"
                sapratiorLine.textColor =  model.invite?.promoterStatus == "accepted" ? UIColor(hexString: "#0C73B4") : UIColor(hexString: "#F1E0AE")
                _imInButton.setTitle("im_in".localized())
                _imInButton.backgroundColor =  UIColor(hexString: "#0B62B4")
                _imOutButtonView.backgroundColor = UIColor(hexString: "#0B62B4")
                _imInButtonView.backgroundColor = UIColor(hexString: "#0B62B4")
            }
            _onMyListButton.setTitle("message_admin".localized())
            let eventSpotCloseTime = "\(model.date) \(model.spotCloseAt)".toDateUae(format: kFormatDateTimeLocal)
            let currentTime = "\(Date())".toDateUae(format: kFormatDateTimeLocal)
            _closeSpotButton.isHidden = true
            
            if !model.isSpotClosed && model.spotCloseType == "manual" && model.invite?.promoterStatus != "accepted" && model.status == "in-progress" && currentTime < eventSpotCloseTime  {
                _cancelledText.isHidden = true
                _closeSpotButton.isHidden = true
                if isComplementary {
                    if model.invite?.inviteStatus == "in" {
                        _imOutButtonView.isHidden = false
                        _imInButtonView.isHidden = true
                    } else if model.invite?.inviteStatus == "out" {
                        _imOutButtonView.isHidden = true
                        _imInButtonView.isHidden = false
                    } else if model.invite?.inviteStatus == "pending" {
                        _imOutButtonView.isHidden = true
                        _imInButtonView.isHidden = false
                    }
                    _complementaryButtonStack.isHidden = false
                    _promoterStackView.isHidden = true
                    _closeSpotButton.isHidden = true
                } else {
                    _complementaryButtonStack.isHidden = true
                    _promoterStackView.isHidden = false
                    _closeSpotButton.isHidden = model.isSpotClosed
                    if model.status == "in-progress" {
                        _closeSpotButton.isHidden = true
                        _cancelledText.isHidden = true
                        _complementaryButtonStack.isHidden = false
                        _promoterStackView.isHidden = false
                        _imInButtonView.isHidden = true
                        _imOutButtonView.isHidden = true
                        _eventIsFullButton.isHidden = true
                        _outStackView.isHidden = true
                        _completeBtnView.isHidden = false
                        _closeSpotButton.isHidden = !(model.spotCloseType == "manual" && !model.isEventFull && currentTime < eventSpotCloseTime)  || model.isSpotClosed
                    }
                }
            } else if model.invite?.inviteStatus == "in", model.status == "in-progress", isComplementary, model.invite?.promoterStatus != "rejected" {
                _cancelledText.isHidden = false
                _cancelledText.text = "event_started".localized()
                _cancelledText.textColor = ColorBrand.brandGreen
                _eventIsFullButton.isHidden = true
                _complementaryButtonStack.isHidden = true
                _promoterStackView.isHidden = true
                _completeBtnView.isHidden = true
                _closeSpotButton.isHidden = true
            } else if model.status == "in-progress", model.status != "completed", !isComplementary {
                _cancelledText.isHidden = true
                _complementaryButtonStack.isHidden = false
                _promoterStackView.isHidden = false
                _imInButtonView.isHidden = true
                _imOutButtonView.isHidden = true
                _eventIsFullButton.isHidden = true
                _outStackView.isHidden = true
                _completeBtnView.isHidden = false
            } else if model.invite?.inviteStatus != "in", model.status == "in-progress", isComplementary, model.invite?.promoterStatus != "rejected", !model.isSpotClosed {
                _cancelledText.isHidden = false
                _cancelledText.text = "event_started".localized()
                _cancelledText.textColor = ColorBrand.brandGreen
                _complementaryButtonStack.isHidden = true
                _promoterStackView.isHidden = true
                _completeBtnView.isHidden = true
                _closeSpotButton.isHidden = true
            } else if model.status == "completed" {
                _cancelledText.isHidden = false
                _cancelledText.text = "event_completed".localized()
                _eventHideShowButton.isHidden = isComplementary
                _eventHideShowButton.setTitle(model.isHidden ? "show_event".localized() : "hide_event".localized(), for: .normal)
                _eventIsFullButton.isHidden = true
                _complementaryButtonStack.isHidden = true
                _outStackView.isHidden = true
                _promoterStackView.isHidden = true
                _completeBtnView.isHidden = true
                _closeSpotButton.isHidden = true
            }  else if model.status == "cancelled" {
                if isComplementary {
                    _complementaryButtonStack.isHidden = false
                    _promoterStackView.isHidden = true
                    _outStackView.isHidden = true
                    _imOutButtonView.isHidden = true
                    _imInButtonView.isHidden = true
                    _completeBtnView.isHidden = true
                    _cancelledText.isHidden = true
                    _eventIsFullButton.isHidden = false
                } else {
                    _complementaryButtonStack.isHidden = true
                    _promoterStackView.isHidden = true
                    _cancelledText.isHidden = false
                    _cancelledText.text = model.invite?.promoterStatus == "rejected" ? "rejected".localized() : "cancelled".localized()
                }
            } else if model.invite?.promoterStatus == "rejected" && isComplementary || (model.isSpotClosed && model.invite?.inviteStatus != "in") && isComplementary  {
                if isComplementary {
                    _complementaryButtonStack.isHidden = false
                    _promoterStackView.isHidden = true
                    _outStackView.isHidden = true
                    _imOutButtonView.isHidden = true
                    _imInButtonView.isHidden = true
                    _completeBtnView.isHidden = true
                    _cancelledText.isHidden = true
                    _eventIsFullButton.isHidden = false
                    _eventIsFullButton.setTitle("event_full".localized())
                } else if model.status == "cancelled"  {
                    _complementaryButtonStack.isHidden = true
                    _promoterStackView.isHidden = true
                    _cancelledText.isHidden = false
                    _cancelledText.text = model.invite?.promoterStatus == "rejected" ? "rejected".localized() : "cancelled".localized()
                }
            } else if model.isEventFull || model.maxInvitee < 1, isComplementary, model.invite?.promoterStatus != "accepted", model.invite?.inviteStatus != "in" {
                _eventIsFullButton.isHidden = false
                _imInButtonView.isHidden = true
            } else {
                _cancelledText.isHidden = true
                _closeSpotButton.isHidden = true
                if isComplementary {
                    if model.invite?.inviteStatus == "in" {
                        _imOutButtonView.isHidden = false
                        _imInButtonView.isHidden = true
                    } else if model.invite?.inviteStatus == "out" {
                        _imOutButtonView.isHidden = true
                        _imInButtonView.isHidden = false
                    } else if model.invite?.inviteStatus == "pending" {
                        _imOutButtonView.isHidden = true
                        _imInButtonView.isHidden = false
                    }
                    _complementaryButtonStack.isHidden = false
                    _promoterStackView.isHidden = true
                } else {
                    _complementaryButtonStack.isHidden = true
                    _promoterStackView.isHidden = false
                    _closeSpotButton.isHidden = model.isSpotClosed
                    if model.status == "in-progress" {
                        _closeSpotButton.isHidden = true
                        _cancelledText.isHidden = true
                        _complementaryButtonStack.isHidden = false
                        _promoterStackView.isHidden = false
                        _imInButtonView.isHidden = true
                        _imOutButtonView.isHidden = true
                        _eventIsFullButton.isHidden = true
                        _outStackView.isHidden = true
                        _completeBtnView.isHidden = false
                        _closeSpotButton.isHidden = !(model.spotCloseType == "manual" && !model.isEventFull && currentTime < eventSpotCloseTime)  || model.isSpotClosed
                    }
                }
            }
            _animationView.isUserInteractionEnabled = false
            if model.invite?.promoterStatus == "accepted" && model.invite?.inviteStatus == "in" {
                _viewTicketView.isHidden = false
                _animationView.isHidden = false
                _animationView.loopMode = .loop
                _animationView.play()
            } else {
                _viewTicketView.isHidden = true
                _animationView.isHidden = true
            }
        }
        
        if isPlusOne {
            _imOutButtonView.isHidden = true
            _completeBtnView.isHidden = true
            _outStackView.isHidden = true
            _eventIsFullButton.isHidden = true
            _closeSpotButton.isHidden = true
            _promoterStackView.isHidden = true
            _complementaryButtonStack.isHidden = false
            _viewTicketView.isHidden = true
            _animationView.isHidden = true
            
            if model.invite?.inviteStatus == "in" {
                _plusOneOutView.isHidden = false
            } else if model.invite?.inviteStatus == "out" {
                _imInButton.setTitle("im_in".localized())
                _imInButton.backgroundColor =  UIColor(hexString: "#0B62B4")
                _imInButtonView.isHidden = false
                _plusOneOutView.isHidden = true
            } else if model.invite?.inviteStatus == "pending" {
                _imInButton.setTitle("im_in".localized())
                _imInButton.backgroundColor =  UIColor(hexString: "#0B62B4")
                _imInButtonView.isHidden = false
                _plusOneOutView.isHidden = false
            }
            
            if model.status == "in-progress" || model.status == "completed" {
                _imInButtonView.isHidden = true
                _plusOneOutView.isHidden = true
            }
            
            if (model.isSpotClosed && model.invite?.inviteStatus != "in") {
                _eventIsFullButton.isHidden = false
                _imInButtonView.isHidden = true
                _plusOneOutView.isHidden = true
                
            }
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _requestHideShowEvent(id: String, isHidden: Bool) {
        _eventHideShowButton.setTitle("")
        _eventHideShowButton.showActivity()
        WhosinServices.eventHideShow(eventId: id, isHidden: isHidden) {[weak self] container, error in
            guard let self = self else { return }
            self._eventHideShowButton.hideActivity()
            guard let data = container else { return }
            self.parentBaseController?.showSuccessMessage(data.message, subtitle: kEmptyString)
            NotificationCenter.default.post(name: .reloadMyEventsNotifier   , object: nil)
        }
    }

    private func _requestCancelEvent(_ eventId: String, deleteAllEvent: Bool) {
        _deleteEventBtn.setTitle("")
        _deleteEventBtn.showActivity()
        WhosinServices.cancelMyEvent(id: eventId, deleteAll: deleteAllEvent) { [weak self] container, error in
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
    
    
    private func plusOneRequestUpdateStatus(_ id:String, status: String) {
        WhosinServices.updatePlusOneInviteStatus(inviteId: id, inviteStatus: status) { [weak self] container, error in
            guard let self = self else { return }
            self._imOutButton.hideActivity()
            self._plusOneOutButton.hideActivity()
            self._imInButton.hideActivity()
            self.parentBaseController?.showError(error)
            guard let data = container else { return }
            self.parentBaseController?.showSuccessMessage(status == "out" ? "thank_you_for_joining".localized() : data.message, subtitle: kEmptyString)
            NotificationCenter.default.post(name: .reloadMyEventsNotifier   , object: nil)
        }
        
    }
    
    private func _requestInStatus(inviteId: String) {
        self._imInButton.setTitle(kEmptyString)
        self._imInButton.showActivity()
        WhosinServices.updateInviteStatus(inviteId: inviteId, inviteStatus: "in") { [weak self] container, error in
            guard let self = self else { return }
            let searchString = "You_recently_enjoyed_a_complimentary_visit_to_this_venue".localized()
            if let msg = error?.localizedDescription, msg.contains(searchString) {
                let vc = INIT_CONTROLLER_XIB(CustomMultiOptionAlertVC.self)
                vc.firstButtonTitle = "get_event_pass".localized()
                vc.secButtonTitle = "cancel".localized()
                vc._title = "time_sensitive".localized()
                vc._msg = msg
                vc._handleFirstEvent = { [weak self] in
                    guard let self = self else { return }
                    let vc = INIT_CONTROLLER_XIB(PaidPassPopupVC.self)
                    vc.event = eventModel
                    self.parentBaseController?.presentDailogueBox(vc)
                }
                vc._handleSecEvent = { [weak self] in
                }
                self.parentBaseController?.presentDailogueBox(vc)
            } else {
                self.parentBaseController?.showError(error)
            }
            self._imInButton.hideActivity()
            guard let data = container else { return }
            if data.message == "cancellation-penalty" {
                NotificationCenter.default.post(name: .openPenaltyPaymenPopup   , object: nil, userInfo: ["data" : data.data, "event": eventModel])
            } else {
                let titleMsg = eventModel?.isConfirmationRequired == true ? "thank_you_for_showing_interest".localized() : "thank_you_for_joining".localized()
                let subtitleMsg = eventModel?.isConfirmationRequired == true ? "please_wait_for_admin_aproval".localized() : "check_details_and_be_on_time".localized()
                self.parentBaseController?.showSuccessMessage(titleMsg, subtitle: subtitleMsg)
                NotificationCenter.default.post(name: .reloadMyEventsNotifier   , object: nil)
            }
        }
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------

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
        showDeleteOptions()
    }
    
    func showDeleteOptions() {
        let alertController = UIAlertController(title: "cancel_event".localized(), message: "cancel_all_event".localized(), preferredStyle: .alert)
        
        let deleteCurrentAction = UIAlertAction(title: "cancel_current_event".localized(), style: .default) { _ in
            self.showConfirmationAlert(forAllEvents: false)
        }
        
        let deleteAllAction = UIAlertAction(title: "cancel_all".localized(), style: .destructive) { _ in
            self.showConfirmationAlert(forAllEvents: true)
        }
        
        let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil)
        
        alertController.addAction(deleteCurrentAction)
        alertController.addAction(deleteAllAction)
        alertController.addAction(cancelAction)
        
        parentViewController?.present(alertController, animated: true, completion: nil)
    }
    
    func showConfirmationAlert(forAllEvents: Bool) {
        let message = forAllEvents ? "are_you_sure_cancel_all_recurring_events".localized() : "are_you_sure_cancel_this_event".localized()
        self.parentBaseController?.showCustomAlert(title: kAppName, message: message, yesButtonTitle: "confirm_cancel".localized(), noButtonTitle: "close".localized(), okHandler: { UIAlertAction in
            self._requestCancelEvent(self.eventModel?.id ?? kEmptyString, deleteAllEvent: forAllEvents)
        }, noHandler:  { UIAlertAction in
        })

    }
    
    @IBAction func _handleImOutEvent(_ sender: UIButton) {
//        if eventModel?.isConfirmationRequired == true {
            let alertController = UIAlertController(title: kAppName, message: nil, preferredStyle: .actionSheet)
        let otherAction = UIAlertAction(title: "cancel_confirmation".localized(), style: .default) { _ in
                self._handleOut()
            }
            otherAction.setValue(UIColor.red, forKey: "titleTextColor")
            alertController.addAction(otherAction)

        let cancelAction = UIAlertAction(title: "close".localized(), style: .destructive, handler: nil)
            alertController.addAction(cancelAction)

            self.parentBaseController?.present(alertController, animated: true, completion: nil)
//        } else {
//            _handleOut()
//        }

    }
    
    private func _handleOut() {
        if isPlusOne {
            let updateTime = Utils.stringToDate(eventModel?.invite?.updatedAt, format: kStanderdDate) ?? Date()
            let differenceInSeconds = Date().timeIntervalSince(updateTime)
            if eventModel?.invite?.inviteStatus != "pending" {
                if differenceInSeconds < 60 {
                    parentBaseController?.alert(title: "please_wait".localized(), message: "wait_before_changing_response".localized())
                    return
                }
            }
            let alertMessage = eventModel?.isConfirmationRequired == true ? eventModel?.invite?.promoterStatus == "accepted" ? "confirm_cancel_attendance_warning".localized() : "are_you_sure_mark_not_interested".localized() : "confirm_cancel_attendance_warning".localized()
            let showFaq = eventModel?.invite?.promoterStatus == "accepted"
            parentBaseController?.alert(title: "Time Sensitive", message: alertMessage,okActionTitle: "yes".localized(), showfaq: showFaq, faq: eventModel?.faq ?? kEmptyString, okHandler: { _ in
                guard let invite = self.eventModel?.invite else { return }
                self._imOutButton.setTitle(kEmptyString)
                self._imOutButton.showActivity()
                self.plusOneRequestUpdateStatus(invite.id, status: "out")
            })
        } else {
            let updateTime = Utils.stringToDate(eventModel?.invite?.updatedAt, format: kStanderdDate) ?? Date()
            let differenceInSeconds = Date().timeIntervalSince(updateTime)
            if eventModel?.invite?.inviteStatus != "pending" {
                if differenceInSeconds < 60 {
                    parentBaseController?.alert(title: "please_wait".localized(), message: "wait_before_changing_response".localized())
                    return
                }
            }
            
            if eventModel?.isConfirmationRequired == false {
                if eventModel?.isTwoHourRemaining == true {
                    let eventName = eventModel?.venueType == "venue" ? eventModel?.venue?.name : eventModel?.customVenue?.name
                    parentBaseController?.alert(title: "cancellation_not_allowed".localized(), message: LANGMANAGER.localizedString(forKey: "cannot_cancel_value_less_than_2_hours", arguments: ["value": eventName ?? kEmptyString]))
                    return
                }
            }
            
            let alertMessage = eventModel?.isConfirmationRequired == true ? eventModel?.invite?.promoterStatus == "accepted" ? "confirm_cancel_attendance_warning".localized() : "cancel_your_interest".localized() : "are_you_sure_mark_not_interested".localized()
            let showFaq = eventModel?.invite?.promoterStatus == "accepted"
            parentBaseController?.alert(title: kAppName, message: alertMessage,okActionTitle: "yes".localized(), showfaq: showFaq, faq: eventModel?.faq ?? kEmptyString, okHandler: { _ in
                guard let invite = self.eventModel?.invite else { return }
                self._imOutButton.setTitle(kEmptyString)
                self._imOutButton.showActivity()
                WhosinServices.updateInviteStatus(inviteId: invite.id, inviteStatus: "out") { [weak self] container, error in
                    guard let self = self else { return }
                    self._imOutButton.hideActivity()
                    self.parentBaseController?.showError(error)
                    guard let data = container else { return }
                    self.parentBaseController?.showSuccessMessage("invitation_cancel_successfully".localized(), subtitle: kEmptyString)
                    NotificationCenter.default.post(name: .reloadMyEventsNotifier   , object: nil)
                }
            })
        }
    }
    
    private func _jsonStringPromoterEventObject() -> String? {
        guard let event = eventModel else { return kEmptyString }
        let dict: [String: Any] = event.toEventJSONChat()
        return dict.toJSONString
    }
    
    @IBAction func _handleOnMyListEvent(_ sender: UIButton) {
        guard let userDetail = APPSESSION.userDetail, let event = eventModel?.user else { return }
        let chatModel = ChatModel()
        chatModel.image = event.image
        chatModel.title = event.fullName
        chatModel.members.append(event.id)
        chatModel.members.append(userDetail.id)
        let chatIds = [event.id, userDetail.id].sorted()
        chatModel.chatId = chatIds.joined(separator: ",")
        chatModel.chatType = "friend"
        DISPATCH_ASYNC_MAIN_AFTER(0.01) {
            let vc = INIT_CONTROLLER_XIB(ChatDetailVC.self)
            vc.chatModel = chatModel
            vc._eventChatJSON = self._jsonStringPromoterEventObject() ?? kEmptyString
            Utils.openViewController(vc)
        }
    }
    
    @IBAction func _handleImInEvent(_ sender: UIButton) {

        guard let invite = eventModel?.invite else { return }

        if isPlusOne {
            if let isfull = eventModel?.isEventFull {
                if isfull {
                    parentBaseController?.alert(message: "event_full".localized())
                    return
                }
            }

            let updateTime = Utils.stringToDate(invite.updatedAt, format: kStanderdDate) ?? Date()
            let differenceInSeconds = Date().timeIntervalSince(updateTime)
            if eventModel?.invite?.inviteStatus != "pending" {
                if differenceInSeconds < 60 {
                    parentBaseController?.alert(title: "please_wait".localized(), message: "wait_before_changing_response".localized())
                    return
                }
            }
            let alertMessage = eventModel?.isConfirmationRequired == true ? "confirm_mark_interested_event".localized() : "spot_reserved_alert".localized()
            parentBaseController?.alert(title: kAppName, message: "spot_reserved_alert".localized(), okActionTitle: "yes".localized(), okHandler: { _ in
                self._imInButton.setTitle(kEmptyString)
                self._imInButton.showActivity()
                self.plusOneRequestUpdateStatus(invite.id, status: "in")
            })
        } else {
            guard eventModel?.isSameTimeEvent == false else {
                parentBaseController?.alert(title: kAppName, message: "cannot_be_in_different_events".localized())
                return
            }
                        
            if let isfull = eventModel?.isEventFull, let totalIn = eventModel?.totalInMembers, let invitee = eventModel?.maxInvitee {
                let remaining = invitee - totalIn // Corrected invite to invitee
                if isfull || remaining < 1 {
                    parentBaseController?.alert(message: "event_full".localized())
                    return
                }
            }
            
            
            let updateTime = Utils.stringToDate(invite.updatedAt, format: kStanderdDate) ?? Date()
            let differenceInSeconds = Date().timeIntervalSince(updateTime)
            if eventModel?.invite?.inviteStatus != "pending" {
                if differenceInSeconds < 60 {
                    parentBaseController?.alert(title: "please_wait".localized(), message: "wait_before_changing_response".localized())
                    return
                }
            }
            let alertMessage = eventModel?.isConfirmationRequired == true ? "confirm_mark_interested_event".localized() : "spot_reserved_alert".localized()
            
            parentBaseController?.alert(title: kAppName, message: alertMessage, okActionTitle: "yes".localized(), okHandler: { _ in
                if self.eventModel?.plusOneMandatory == true {
                    let vc = INIT_CONTROLLER_XIB(PlusOneInivteBottomSheet.self)
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isEventPlusOne = true
                    vc.event = self.eventModel
                    vc.groupMembers = self.eventModel?.plusOneMembers.toArrayDetached(ofType: UserDetailModel.self) ?? []
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
    }
    
    @IBAction func _handleHideShowEvent(_ sender: UIButton) {
        guard let event = eventModel else { return }
        _requestHideShowEvent(id: event.id, isHidden: !event.isHidden)

    }
    
    @IBAction func _handleCompleteEvent(_ sender: CustomActivityButton) {
        _requestCompleteEvent()
    }
    
    @IBAction func _handleEventFullEvent(_ sender: UIButton) {
    }
    
    @IBAction func _handleViewTicketEvent(_ sender: CustomButton) {
        let vc = INIT_CONTROLLER_XIB(CMConfirmedEventVC.self)
        vc.eventModel = eventModel
        if self.parentBaseController?.isPresented == true {
            self.parentBaseController?.dismiss(animated: true) {
                self.openViewTicket?()
            }
        } else {
            if let parent = self.parentBaseController {
                parent.navigationController?.pushViewController(vc, animated: true)
            } else {
                Utils.openViewController(vc)
            }
        }
    }
    
    @IBAction private func _handleCloseSpotEvent(_ sender: CustomActivityButton) {
        guard let event = eventModel else { return }
        parentBaseController?.alert(title: kAppName, message: "close_entry_alert".localized(), okActionTitle: "yes".localized(), okHandler: { _ in
            WhosinServices.closeEventSpot(eventId: event.id) { [weak self] container, error in
                guard let self = self else { return }
                self._imOutButton.hideActivity()
                self.parentBaseController?.showError(error)
                guard let data = container else { return }
                self.parentBaseController?.showSuccessMessage("closed_entry_event".localized(), subtitle: kEmptyString)
                NotificationCenter.default.post(name: .reloadMyEventsNotifier   , object: nil)
            }
        })
    }
    
    @IBAction func _handlePlusOneOutEvent(_ sender: UIButton) {
        let updateTime = Utils.stringToDate(eventModel?.invite?.updatedAt, format: kStanderdDate) ?? Date()
        let differenceInSeconds = Date().timeIntervalSince(updateTime)
        if eventModel?.invite?.inviteStatus != "pending" {
            if differenceInSeconds < 60 {
                parentBaseController?.alert(title: "please_wait".localized(), message: "wait_before_changing_response".localized())
                return
            }
        }
        let alertMessage = eventModel?.isConfirmationRequired == true ? eventModel?.invite?.promoterStatus == "accepted" ? "confirm_cancel_attendance_warning".localized() : "are_you_sure_mark_not_interested".localized() : "confirm_cancel_attendance_warning".localized()
        let showFaq = eventModel?.invite?.promoterStatus == "accepted"
        parentBaseController?.alert(title: kAppName, message: alertMessage,okActionTitle: "yes".localized(), showfaq: showFaq, faq: eventModel?.faq ?? kEmptyString, okHandler: { _ in
            guard let invite = self.eventModel?.invite else { return }
            self._plusOneOutButton.setTitle(kEmptyString)
            self._plusOneOutButton.showActivity()
            self.plusOneRequestUpdateStatus(invite.id, status: "out")
        })
    }
}


