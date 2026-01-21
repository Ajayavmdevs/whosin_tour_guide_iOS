import UIKit

class UserRequestTableCell: UITableViewCell {
    
    @IBOutlet weak var _mainView: UIView!
    @IBOutlet weak var _mainConstraintBottom: NSLayoutConstraint!
    @IBOutlet weak var _mainConstrainttop: NSLayoutConstraint!
    @IBOutlet weak var _mainConstraintRight: NSLayoutConstraint!
    @IBOutlet weak var _mainConstraintLeft: NSLayoutConstraint!
    @IBOutlet weak var _plusOneView: UIView!
    @IBOutlet weak var _statusBgView: UIView!
    @IBOutlet weak var _statusLabel: CustomLabel!
    @IBOutlet weak var _rejectedLable: CustomLabel!
    @IBOutlet weak var _btnsView: UIView!
    @IBOutlet weak var _viewProfileBtn: CustomButton!
    @IBOutlet private weak var _approveBtn: CustomActivityButton!
    @IBOutlet private weak var _rejectBtn: CustomActivityButton!
    @IBOutlet private weak var _subTitleText: UILabel!
    @IBOutlet private weak var _userName: UILabel!
    @IBOutlet private weak var _imageView: UIImageView!
    private var memberId:String = kEmptyString
    private var isEvent:Bool = false
    private var isPromoter: Bool = false
    private var _model: NotificationModel?
    private var _user: UserDetailModel?
    public var updateStatusCallback:(( _ status: String) -> Void)?
    public var openCallback:((_ model: ChatModel) -> Void)?
    private var isEventFull: Bool = false
    private var isFromChat: Bool = false
    private var isFromEventDetail: Bool = false
    private var isPlusOne: Bool = false
    
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
        DISPATCH_ASYNC_MAIN_AFTER(0.1) {
            self._plusOneView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
            self._plusOneView.layer.cornerRadius = 8
            self._plusOneView.layer.masksToBounds = true
        }
    }
    
    // --------------------------------------
    // MARK: setup
    // --------------------------------------
    
    public func setupData(_ model: NotificationModel, isEvent: Bool = false, isPromoter: Bool = false, isEventFull: Bool = false,isConfirmation: Bool = false) {
        self.isEventFull = isEventFull
        _statusBgView.isHidden = !isEvent
        _plusOneView.isHidden = true
        _stautsBadge(model.promoterStatus, inviteStatus: model.inviteStatus, isConfirmation: isConfirmation)
        _model = model
        _btnsView.isHidden = model.requestStatus == "rejected" || model.requestStatus == "accepted"
        self.isEvent = isEvent
        self.isPromoter =  isPromoter
        _approveBtn.isHidden = isEvent
        _viewProfileBtn.setTitle(isEvent ? "message".localized() : "view_profile".localized())
        _userName.text = model.title
        _subTitleText.text = model.requestStatus == "accepted" ? isPromoter ?  "added_their_ring".localized()  :"has_join_ring".localized() : model.descriptions
        _imageView.loadWebImage(model.image, name: model.title)
        memberId = isEvent ? model.userId : model.typeId
        if model.requestStatus == "rejected" {
            _viewProfileBtn.backgroundColor = .clear
            _viewProfileBtn.setTitleColor(UIColor(hexString: "#E32A2A"), for: .normal)
            _viewProfileBtn.isUserInteractionEnabled = false
            _viewProfileBtn.isEnabled = false
            _viewProfileBtn.setTitle("rejected".localized())
        } else {
            _viewProfileBtn.backgroundColor = ColorBrand.brandPink
            _viewProfileBtn.setTitleColor(ColorBrand.white, for: .normal)
            _viewProfileBtn.isUserInteractionEnabled = true
            _viewProfileBtn.isEnabled = true
            _viewProfileBtn.setTitle(isEvent ? "message".localized() : "view_profile".localized())
        }
        
        if isEvent {
            _approveBtn.isHidden = model.promoterStatus != "pending"
            _viewProfileBtn.isHidden = model.promoterStatus == "rejected"
            _rejectedLable.isHidden = model.promoterStatus != "rejected"
            _rejectBtn.isHidden = model.promoterStatus == "rejected"
        }
    }
    
    public func setupSubAdminData(_ model: UserDetailModel) {
        _statusBgView.isHidden = true
        _user = model
        _viewProfileBtn.setTitle("view_profile".localized())
        _userName.text = model.fullName
        _subTitleText.text = model.status == "accepted" ? "added_their_ring".localized()  : "has_join_ring".localized()
        _imageView.loadWebImage(model.image, name: model.fullName)
        memberId = model.id
        if model.status == "rejected" {
            _viewProfileBtn.backgroundColor = .clear
            _viewProfileBtn.setTitleColor(UIColor(hexString: "#E32A2A"), for: .normal)
            _viewProfileBtn.isUserInteractionEnabled = false
            _viewProfileBtn.isEnabled = false
            _viewProfileBtn.setTitle("rejected".localized())
        } else {
            _viewProfileBtn.backgroundColor = ColorBrand.brandPink
            _viewProfileBtn.setTitleColor(ColorBrand.white, for: .normal)
            _viewProfileBtn.isUserInteractionEnabled = true
            _viewProfileBtn.isEnabled = true
            _viewProfileBtn.setTitle("view_profile".localized())
        }
    }
    
    public func setupEventData(_ model: InvitedUserModel, isEventFull: Bool = false, isConfirmation: Bool = false, isNoAction: Bool = false, type: String = kEmptyString) {
        self.isEventFull = isEventFull
        self.isPlusOne = true//model.invitedBy != nil && model.user.adminStatusOnPlusOne == "accepted"
        _stautsBadge(model.promoterStatus, inviteStatus: model.inviteStatus, isConfirmation: isConfirmation)
        isFromEventDetail = true
        _plusOneView.isHidden = !isPlusOne
//        _user = model
        _userName.text = model.user?.fullName
        _imageView.loadWebImage(model.user?.image ?? kEmptyString, name: model.user?.fullName ?? kEmptyString)
        memberId = model.id
//        if isPlusOne {
//            _subTitleText.text = "invited by \(model.invitedBy?.firstName ?? kEmptyString) \(model.invitedBy?.lastName ?? kEmptyString)"
//        } else {
        _subTitleText.text = model.promoterStatus == "accepted" ? "has_join_event".localized()  : "added_in_event".localized()
//        }
        self.isEvent = true
        self.isPromoter =  true
        _viewProfileBtn.setTitle(isEvent ? "message".localized() : "view_profile".localized())
        if model.promoterStatus == "rejected" {
            _viewProfileBtn.backgroundColor = .clear
            _viewProfileBtn.setTitleColor(UIColor(hexString: "#E32A2A"), for: .normal)
            _viewProfileBtn.isUserInteractionEnabled = false
            _viewProfileBtn.isEnabled = false
            _viewProfileBtn.setTitle("rejected".localized())
        } else {
            _viewProfileBtn.backgroundColor = ColorBrand.brandPink
            _viewProfileBtn.setTitleColor(ColorBrand.white, for: .normal)
            _viewProfileBtn.isUserInteractionEnabled = true
            _viewProfileBtn.isEnabled = true
            _viewProfileBtn.setTitle(isEvent ? "message".localized() : "view_profile".localized())
        }
        _approveBtn.isHidden = isConfirmation ? model.promoterStatus != "pending" : true
        _viewProfileBtn.isHidden = model.promoterStatus == "rejected"
        _rejectedLable.isHidden = true
        _rejectBtn.isHidden = isConfirmation ? type == "invited" : model.promoterStatus != "accepted"
        if isNoAction {
            _approveBtn.isHidden = true
            _rejectBtn.isHidden = true
        }
    }
    
    public func setupUserData(_ model: UserDetailModel) {
        _plusOneView.isHidden = true
        _statusBgView.isHidden = true
        _user = model
        _approveBtn.isHidden = true
        _rejectBtn.isHidden = true
        isFromChat = true
        self.isEvent = true
        _viewProfileBtn.setTitle("message".localized())
        _userName.text = model.fullName
        _subTitleText.text = model.bio
        _imageView.loadWebImage(model.image, name: model.fullName)
        memberId = model.id
    }
    
    public func setupDataNotificationEvent(_ model: NotificationModel) {
        _plusOneView.isHidden = false
        _mainConstraintLeft.constant = 0
        _mainConstraintRight.constant = 0
        _mainConstrainttop.constant = 0
        _mainConstraintBottom.constant = 10
        _mainView.cornerRadius = 0
        _mainView.backgroundColor = .clear
        _statusBgView.isHidden = !isEvent
        _model = model
        _btnsView.isHidden = model.requestStatus == "rejected" || model.requestStatus == "accepted"
        _viewProfileBtn.setTitle("message".localized())
        _userName.text = model.title
        _subTitleText.text = model.requestStatus == "accepted" ? isPromoter ?  "added_their_ring".localized()  :"has_join_ring".localized() : model.descriptions
        _imageView.loadWebImage(model.image, name: model.title)
        if model.promoterStatus == "pending" {
            _approveBtn.isHidden = false
        } else {
            _approveBtn.isHidden = true
        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    private func _stautsBadge(_ promoterStatus: String, inviteStatus: String, isConfirmation: Bool) {
        if isConfirmation {
            if promoterStatus == "accepted", inviteStatus == "in" {
                _statusLabel.text = "confirmed".localized()
                _statusBgView.backgroundColor = ColorBrand.brandGreen
                _statusBgView.isHidden = false
            } else if promoterStatus == "accepted", inviteStatus == "out" {
                _statusLabel.text = "out".localized()
                _statusBgView.backgroundColor = UIColor(hexString: "#E32A2A")
                _statusBgView.isHidden = false
            } else if promoterStatus == "rejected" {
                _statusLabel.text = "out".localized()
                _statusBgView.backgroundColor = UIColor(hexString: "#E32A2A")
                _statusBgView.isHidden = false
            } else if promoterStatus == "pending", inviteStatus == "in" {
                _statusLabel.text = "pending".localized()
                _statusBgView.backgroundColor = ColorBrand.yellowColor
                _statusBgView.isHidden = false
            } else {
                _statusLabel.text = inviteStatus
                _statusBgView.backgroundColor = ColorBrand.yellowColor
                _statusBgView.isHidden = true
            }
        } else {
            if inviteStatus == "in" {
                _statusLabel.text = "confirmed".localized()
                _statusBgView.backgroundColor = ColorBrand.brandGreen
                _statusBgView.isHidden = false
            } else if inviteStatus == "out" {
                _statusLabel.text = "out".localized()
                _statusBgView.backgroundColor = UIColor(hexString: "#E32A2A")
                _statusBgView.isHidden = false
            } else {
                _statusLabel.text = "pending".localized()
                _statusBgView.isHidden = true
            }
        }
    }
    
    private func requestUpdateStatus(status: String) {
        status == "accepted" ? _approveBtn.showActivity() : _rejectBtn.showActivity()
        var params: [String: Any] = ["status": status]
        if isPromoter {
            params["promoterId"] = memberId
        } else {
            params["memberId"] = memberId
        }
        WhosinServices.promoterStatus(params: params, isPromoter: isPromoter) { [weak self] container, error in
            guard let self = self else { return }
            status == "accepted" ? _approveBtn.hideActivity() : _rejectBtn.hideActivity()
            self.parentBaseController?.hideHUD(error: error)
            guard let data = container else { return }
            self.parentBaseController?.showToast(data.message)
            if data.code == 1 { self.updateStatusCallback?(status) }
            NotificationCenter.default.post(name: .reloadEventNotification , object: nil)
            NotificationCenter.default.post(name: .reloadMyEventsNotifier , object: nil)
        }
    }
    
    private func _requestRejectStatus(status: String) {
        status == "accepted" ? _approveBtn.showActivity() : _rejectBtn.showActivity()
        let invitedId = isFromEventDetail ? memberId : isFromChat  ? memberId : _model?.typeId ?? kEmptyString
        WhosinServices.promoterEventInviteStatus(inviteId: invitedId, inviteStatus: status) { [weak self] container, error in
            guard let self = self else { return }
            status == "accepted" ? self._approveBtn.hideActivity() : self._rejectBtn.hideActivity()
            self.parentBaseController?.hideHUD(error: error)
            guard let data = container else { return }
            if data.code == 1 {
                self.updateStatusCallback?(status)
                NotificationCenter.default.post(name: .reloadEventNotification , object: nil)
                NotificationCenter.default.post(name: .reloadMyEventsNotifier , object: nil)
            }
        }
    }
    
    private func _requestPlusOneRejectStatus(status: String) {
        status == "accepted" ? _approveBtn.showActivity() : _rejectBtn.showActivity()
        let invitedId = isFromEventDetail ? memberId : isFromChat  ? memberId : _model?.typeId ?? kEmptyString
        WhosinServices.plusOnePromoterRequest(inviteId: invitedId, inviteStatus: status) { [weak self] container, error in
            guard let self = self else { return }
            status == "accepted" ? self._approveBtn.hideActivity() : self._rejectBtn.hideActivity()
            self.parentBaseController?.hideHUD(error: error)
            guard let data = container else { return }
            if data.code == 1 {
                self.updateStatusCallback?(status)
                NotificationCenter.default.post(name: .reloadEventNotification , object: nil)
                NotificationCenter.default.post(name: .reloadMyEventsNotifier , object: nil)
            }
        }
    }
    
    private func _requestVerifyStatus(status: String) {
        status == "accepted" ? _approveBtn.showActivity() : _rejectBtn.showActivity()
        WhosinServices.requestVerifyRingRequest(id: memberId, status: status) { [weak self] container, error in
            guard let self = self else { return }
            status == "accepted" ? self._approveBtn.hideActivity() : self._rejectBtn.hideActivity()
            self.parentBaseController?.hideHUD(error: error)
            guard let data = container else { return }
            if data.code == 1 {
                self.updateStatusCallback?(status)
                NotificationCenter.default.post(name: .reloadEventNotification , object: nil)
                NotificationCenter.default.post(name: .reloadMyEventsNotifier , object: nil)
            }
        }
    }
    
    @IBAction private func _handleVeiwProfileEvent(_ sender: UIButton) {
        if isEvent {
            guard let userId = isFromEventDetail ? _user?.userId ?? kEmptyString : isFromChat ? _user?.userId :_model?.userId else { return }
            guard let userDetail = APPSESSION.userDetail else { return }
            let chatModel = ChatModel()
            chatModel.image = isFromEventDetail ? _user?.image ?? kEmptyString : isFromChat ? _user?.image ?? kEmptyString : self._model?.image ?? kEmptyString
            chatModel.title = isFromEventDetail ? _user?.fullName  ?? kEmptyString :  isFromChat ? _user?.fullName ?? kEmptyString : self._model?.title ?? kEmptyString
            chatModel.chatType = "friend"
            chatModel.members.append(userId)
            chatModel.members.append(userDetail.id)
            let chatIds = [userId, Preferences.isSubAdmin ? userDetail.promoterId : userDetail.id].sorted()
            chatModel.chatId = chatIds.joined(separator: ",")
            openCallback?(chatModel)
        } 
    }
    
    @IBAction private func _handleRejectEvent(_ sender: CustomActivityButton) {
        self.parentBaseController?.confirmAlert(message: LANGMANAGER.localizedString(forKey: "reject_confirm_alert", arguments: ["value": _userName.text ?? "user"]), okHandler: { action in
//            if Preferences.isSubAdmin {
//                self._requestVerifyStatus(status: "rejected")
//            } else {
                if self.isEvent {
                    self.isPlusOne ? self._requestPlusOneRejectStatus(status: "rejected") : self._requestRejectStatus(status: "rejected")
                } else {
                    self.requestUpdateStatus(status: "rejected")
                }
//            }
        })
    }
    
    @IBAction private func _handleApproveEvent(_ sender: CustomActivityButton) {
//        if Preferences.isSubAdmin {
//            self._requestVerifyStatus(status: "accepted")
//        } else {
            if isEvent {
                if isEventFull {
                    parentBaseController?.alert(message: "event_full".localized())
                    return
                }
                self.isPlusOne ? self._requestPlusOneRejectStatus(status:  "accepted") : self._requestRejectStatus(status: "accepted")
            } else {
                requestUpdateStatus(status: "accepted")
            }
//        }
    }
}
