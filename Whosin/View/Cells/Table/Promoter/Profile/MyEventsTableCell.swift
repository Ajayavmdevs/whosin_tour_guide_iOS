import UIKit

class MyEventsTableCell: UITableViewCell {

    @IBOutlet private weak var _intrestedUsers: CustomUserListView!
    @IBOutlet private weak var _bottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var _completeBtn: CustomActivityButton!
    @IBOutlet private weak var _cancelButton: CustomActivityButton!
    @IBOutlet private weak var _imageView: UIImageView!
    @IBOutlet private weak var _venueName: CustomLabel!
    @IBOutlet private weak var _venueTime: CustomLabel!
    @IBOutlet private weak var _seats: CustomLabel!
    @IBOutlet private weak var _invitedUsersList: CustomUserListView!
    @IBOutlet private weak var _circleInvitedList: CustomUserListView!
    @IBOutlet private weak var _seatsUsersList: CustomUserListView!
    @IBOutlet private weak var _plusOneMembersList: CustomUserListView!
    @IBOutlet private weak var _cancelledLabel: CustomLabel!
    @IBOutlet private weak var _dotMenuButton: CustomButton!
    @IBOutlet private weak var _confirmationText: CustomLabel!
    @IBOutlet private weak var _btnsBgView: UIView!
    private var _eventId: String = kEmptyString
    private var eventModel: PromoterEventsModel?
    private var isFromHistory: Bool = false
    public var callback: (() -> Void)?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height : CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life-cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
    }

    public func setupData(_ model: PromoterEventsModel) {
        isFromHistory = false
        _bottomConstraint.constant = isFromHistory ? 10 : 0
        _btnsBgView.isHidden = false
        eventModel = model
        _eventId = model.id
        if model.venueType == "venue" {
            _imageView.loadWebImage(model.venue?.slogo ?? kEmptyString, name: model.venue?.name ?? kEmptyString)
            _venueName.text = model.venue?.name
        } else {
            _imageView.loadWebImage(model.customVenue?.image ?? kEmptyString)
            _venueName.text = model.customVenue?.name
        }
        let date = Utils.stringToDate(model.date, format: "yyyy-MM-dd")
        _venueTime.text = "\(Utils.dateToString(date, format: kFormatEventDate)) | \(model.startTime) - \(model.endTime)"
        _seats.text = "\(model.maxInvitee) " + "seats".localized()
        _invitedUsersList.setupData(model.invitedUsers.toArrayDetached(ofType: UserDetailModel.self), title: "users_invited".localized(), counts: "(\(model.totalInvitedUsers))", isshowCount: true)
        _circleInvitedList.setupData(model.invitedCircles.toArrayDetached(ofType: UserDetailModel.self), title: "circles_invited".localized())
        _seatsUsersList.setupData(model.inMembers.toArrayDetached(ofType: UserDetailModel.self), title: "\(model.maxInvitee) " + "seats".localized(), counts: LANGMANAGER.localizedString(forKey: "remaining", arguments: ["value": "(\(model.maxInvitee - model.totalInMembers))"]), isshowCount: true)
        _intrestedUsers.setupData(model.interestedMembers.toArrayDetached(ofType: UserDetailModel.self), title: "user_interested".localized(), counts: "(\(model.totalInterestedMembers))", isshowCount: true)
        _plusOneMembersList.setupData(model.plusOneMembers.toArrayDetached(ofType: UserDetailModel.self), title: "plus_one_members".localized(), counts: "(\(model.plusOneMembers.count))", isshowCount: true)
        _invitedUsersList.isHidden = model.invitedUsers.isEmpty
        _circleInvitedList.isHidden = model.invitedCircles.isEmpty
        _seatsUsersList.isHidden = model.inMembers.isEmpty
        _intrestedUsers.isHidden = model.interestedMembers.isEmpty
        _plusOneMembersList.isHidden = model.plusOneMembers.isEmpty
        _cancelledLabel.text = "cancelled".localized()
        _confirmationText.isHidden = false
        _confirmationText.text = model.isConfirmationRequired ? "show_interest".localized() : "confirmed".localized()
        _confirmationText.textColor = model.isConfirmationRequired ? ColorBrand.amberColor : ColorBrand.brandGreen
        if model.status == "complete" || model.status == "cancelled" {
            _cancelledLabel.isHidden = false
            _cancelButton.isHidden = true
        }
        if model.status == "in-progress" {
            _cancelButton.isHidden = true
            _cancelledLabel.isHidden = true
            _completeBtn.isHidden = false
            _completeBtn.setTitle("complete".localized())
        } else {
            _completeBtn.isHidden = true
            _cancelledLabel.isHidden = model.status != "cancelled"
            _cancelButton.isHidden = model.status == "cancelled"
        }
    }
    
    public func setupHistoryData(_ model: PromoterEventsModel) {
        isFromHistory = true
        _bottomConstraint.constant = isFromHistory ? 10 : 0
        _btnsBgView.isHidden = true
        eventModel = model
        _cancelledLabel.isHidden = true
        _confirmationText.isHidden = true
        _cancelButton.isHidden = true
        _dotMenuButton.isHidden = false
        _completeBtn.isHidden = true
        _eventId = model.id
        if model.venueType == "venue" {
            _imageView.loadWebImage(model.venue?.slogo ?? kEmptyString, name: model.venue?.name ?? kEmptyString)
            _venueName.text = model.venue?.name
        } else {
            _imageView.loadWebImage(model.customVenue?.image ?? kEmptyString)
            _venueName.text = model.customVenue?.name
        }
        let date = Utils.stringToDate(model.date, format: "yyyy-MM-dd")
        _venueTime.text = "\(Utils.dateToString(date, format: kFormatEventDate)) | \(model.startTime) - \(model.endTime)"
        _seats.text = "\(model.maxInvitee) " + "seats".localized()
        _invitedUsersList.setupData(model.invitedUsers.toArrayDetached(ofType: UserDetailModel.self), title: "users_invited".localized(), counts: "(\(model.totalInvitedUsers))", isshowCount: true)
        _intrestedUsers.setupData(model.interestedMembers.toArrayDetached(ofType: UserDetailModel.self), title: "user_interested".localized(), counts: "(\(model.totalInterestedMembers))", isshowCount: true)
        _circleInvitedList.setupData(model.invitedCircles.toArrayDetached(ofType: UserDetailModel.self), title: "circles_invited".localized())
        _seatsUsersList.setupData(model.inMembers.toArrayDetached(ofType: UserDetailModel.self), title: "\(model.maxInvitee) seats", counts: LANGMANAGER.localizedString(forKey: "remaining", arguments: ["value": "(\(model.maxInvitee - model.totalInMembers)"]), isshowCount: true)
        _plusOneMembersList.setupData(model.plusOneMembers.toArrayDetached(ofType: UserDetailModel.self), title: "plus_one_members".localized(), counts: "(\(model.plusOneMembers.count))", isshowCount: true)
        _invitedUsersList.isHidden = model.invitedUsers.isEmpty
        _circleInvitedList.isHidden = model.invitedCircles.isEmpty
        _seatsUsersList.isHidden = model.inMembers.isEmpty
        _intrestedUsers.isHidden = model.interestedMembers.isEmpty
        _plusOneMembersList.isHidden = model.plusOneMembers.isEmpty
    }
    
    private func _requestCancelEvent(_ eventId: String, deleteAllEvent: Bool) {
        _cancelButton.setTitle("")
        _cancelButton.showActivity()
        WhosinServices.cancelMyEvent(id: eventId, deleteAll: deleteAllEvent) { [weak self] container, error in
            guard let self = self else { return }
            self.parentBaseController?.hideHUD(error: error)
            self._cancelButton.hideActivity()
            self._cancelButton.setTitle("cancel".localized())
            guard let data = container else { return }
            if data.code == 1 {
                self.parentBaseController?.showToast(data.message)
                NotificationCenter.default.post(name: .reloadMyEventsNotifier   , object: nil)
            }
        }
    }
    
    private func _requestDeleteEvent() {
        guard let id = eventModel?.id else { return }
        WhosinServices.promoterEventDelete(id: id) { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container else { return }
            if data.code == 1 {
                self.callback?()
                self.parentBaseController?.showSuccessMessage("event_deleted_successfully".localized(), subtitle: kEmptyString)
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
    
    @IBAction private func _handleMenuEvent(_ sender: CustomButton) {
        isFromHistory ? _openoptionsforHistory() :  _openoptions()
    }
    
    private func _openoptions() {
        let alert = UIAlertController(title: kAppName, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "edit".localized(), style: .default, handler: { action in
            let vc = INIT_CONTROLLER_XIB(CreateEventVC.self)
            vc.isEditEvent = true
            vc.params = self.eventModel?.toEventJSON() ?? [:]
            vc.eventModel = self.eventModel
            vc.socialAccounts = self.eventModel?.socialAccountsToMention.toArrayDetached(ofType: SocialAccountsModel.self) ?? []
            vc.hidesBottomBarWhenPushed = true
            self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
        }))

        alert.addAction(UIAlertAction(title: "share".localized(), style: .default, handler: {action in
            if APPSESSION.userDetail?.isPromoter == true {
                let navController = INIT_CONTROLLER_XIB(ShareBottomSheet.self)
                navController.promoterEvent = self.eventModel
                navController.isPromoter = true
                navController.modalPresentationStyle = .overFullScreen
                self.parentViewController?.present(navController, animated: true)
            } else {
                Utils.generateDynamicLinksForPromoterEvent(controller: self.parentViewController, model: self.eventModel)
            }
        }))

        alert.addAction(UIAlertAction(title: "close".localized(), style: .destructive, handler: { _ in }))
        parentViewController?.present(alert, animated: true, completion:{
            alert.view.superview?.subviews[0].isUserInteractionEnabled = true
            alert.view.superview?.subviews[0].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
    }
    
    private func _openoptionsforHistory() {
        let alert = UIAlertController(title: kAppName, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "delete".localized(), style: .default, handler: { action in
            self.parentBaseController?.confirmAlert(message: "delete_the_event_alert".localized(), okHandler: { action in
                self._requestDeleteEvent()
            })
        }))
        
        alert.addAction(UIAlertAction(title: "repost".localized(), style: .default, handler: { action in
            let vc = INIT_CONTROLLER_XIB(CreateEventVC.self)
            vc.isEditEvent = true
            vc.isRepost = true
            vc.params = self.eventModel?.toEventJSON() ?? [:]
            vc.eventModel = self.eventModel
            vc.socialAccounts = self.eventModel?.socialAccountsToMention.toArrayDetached(ofType: SocialAccountsModel.self) ?? []
            vc.hidesBottomBarWhenPushed = true
            self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
        }))

        alert.addAction(UIAlertAction(title: "close".localized(), style: .destructive, handler: { _ in }))
        parentViewController?.present(alert, animated: true, completion:{
            alert.view.superview?.subviews[0].isUserInteractionEnabled = true
            alert.view.superview?.subviews[0].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
    }
    
    @objc func alertControllerBackgroundTapped() {
        self.parentViewController?.dismiss(animated: true, completion: nil)
    }

    @IBAction private func _handleCancelEvent(_ sender: CustomButton) {
        showDeleteOptions()
    }
    
    private func showDeleteOptions() {
        let alertController = UIAlertController(title: "cancel_event".localized(), message: "event_cancellation_confirm_alert".localized(), preferredStyle: .alert)
        
        let deleteCurrentAction = UIAlertAction(title: "cancel_current_event".localized(), style: .default) { _ in
            self.showConfirmationAlert(forAllEvents: false)
        }
        
        let deleteAllAction = UIAlertAction(title: "cancel_all_event".localized(), style: .destructive) { _ in
            self.showConfirmationAlert(forAllEvents: true)
        }
        
        let cancelAction = UIAlertAction(title: "close".localized(), style: .cancel, handler: nil)
        
        alertController.addAction(deleteCurrentAction)
        alertController.addAction(deleteAllAction)
        alertController.addAction(cancelAction)
        
        parentViewController?.present(alertController, animated: true, completion: nil)
    }

    func showConfirmationAlert(forAllEvents: Bool) {
        let message = forAllEvents ? "are_you_sure_cancel_all_recurring_events".localized() : "are_you_sure_cancel_this_event".localized()
        self.parentBaseController?.showCustomAlert(title: "confirm_cancel".localized(), message: message, yesButtonTitle: "yes".localized(), noButtonTitle: "no".localized(), okHandler: { UIAlertAction in
            self._requestCancelEvent(self.eventModel?.id ?? kEmptyString, deleteAllEvent: forAllEvents)
        }, noHandler:  { UIAlertAction in
        })
    }

    
    @IBAction private func _handleCompleteEvent(_ sender: CustomButton) {
        _requestCompleteEvent()
    }
    
}


