import UIKit

class PromoterUserRequestTableCell: UITableViewCell {
    
    @IBOutlet weak var _bannerView: CustomGallaryView!
    @IBOutlet weak var _rejectedLable: CustomLabel!
    @IBOutlet weak var _btnsView: UIView!
    @IBOutlet weak var _viewProfileBtn: CustomButton!
    @IBOutlet private weak var _approveBtn: CustomActivityButton!
    @IBOutlet private weak var _rejectBtn: CustomActivityButton!
    @IBOutlet private weak var _subTitleText: UILabel!
    @IBOutlet private weak var _userName: UILabel!
    @IBOutlet weak var _joinedTime: UILabel!
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
    // MARK: setup
    // --------------------------------------
    
    public func setupData(_ model: NotificationModel, isEvent: Bool = false, isPromoter: Bool = false, isEventFull: Bool = false,isConfirmation: Bool = false) {
        self.isEventFull = isEventFull
        _bannerView.setupHeader(model.images.toArray(ofType: String.self), pageControl: false)
        _bannerView.isHidden = model.images.isEmpty
        _model = model
        _btnsView.isHidden = model.requestStatus == "rejected" || model.requestStatus == "accepted"
        self.isEvent = isEvent
        self.isPromoter =  isPromoter
        _approveBtn.isHidden = isEvent
        _viewProfileBtn.setTitle(isEvent ? "message".localized() : "view_profile".localized())
        _userName.text = model.title
        _joinedTime.text =  isPromoter ?  kEmptyString  : Utils.dateToString(model.updatedAt, format: kFormatDateWithHourMinuteAM) 
        _subTitleText.text = model.requestStatus == "accepted" ? isPromoter ?  "added_their_ring".localized()  :"has_join_ring".localized() : model.descriptions
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
    
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
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
            self._btnsView.isHidden = true
            self.parentBaseController?.showToast(data.message)
            if data.code == 1 { self.updateStatusCallback?(status) }
        }
    }
    
    private func _requestRejectStatus(status: String) {
        status == "accepted" ? _approveBtn.showActivity() : _rejectBtn.showActivity()
        WhosinServices.promoterEventInviteStatus(inviteId: isFromEventDetail ? memberId : isFromChat  ? memberId : _model?.typeId ?? kEmptyString, inviteStatus: status) { [weak self] container, error in
            guard let self = self else { return }
            status == "accepted" ? self._approveBtn.hideActivity() : self._rejectBtn.hideActivity()
            self.parentBaseController?.hideHUD(error: error)
            guard let data = container else { return }
            if data.code == 1 {
                self._btnsView.isHidden = true
                self.updateStatusCallback?(status)
                NotificationCenter.default.post(name: .reloadEventNotification , object: nil)
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
            }
        }
    }
    
    private func _openAddToCircleBottomShhet() {
        let vc = INIT_CONTROLLER_XIB(AddToCircleBottomSheet.self)
        vc.modalPresentationStyle = .overFullScreen
        vc.profileId = self.memberId
        vc.isApprove = true
        vc.isPromoter = self.isPromoter
        self.parentViewController?.present(vc, animated: true)
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
        } else {
            if isPromoter {
                let vc = INIT_CONTROLLER_XIB(PromoterPublicProfileVc.self)
                vc.promoterId = memberId
                parentViewController?.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = INIT_CONTROLLER_XIB(ComplementaryPublicProfileVC.self)
                vc.complimentryId = memberId
                parentViewController?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction private func _handleRejectEvent(_ sender: CustomActivityButton) {
        self.parentBaseController?.confirmAlert(message: LANGMANAGER.localizedString(forKey: "reject_confirm_alert", arguments: ["value": _userName.text ?? "user"]) , okHandler: { action in
//            if Preferences.isSubAdmin {
//                self._requestVerifyStatus(status: "rejected")
//            } else {
                if self.isEvent {
                    self._requestRejectStatus(status: "rejected")
                } else {
                    self.requestUpdateStatus(status: "rejected")
                }
//            }
        })
    }
    
    @IBAction private func _handleApproveEvent(_ sender: CustomActivityButton) {
//        self.parentBaseController?.confirmAlert(message: "Are you sure want to Accept \(_userName.text ?? "user") ?", okHandler: { action in
//            if Preferences.isSubAdmin {
//                self._requestVerifyStatus(status: "accepted")
//            } else {
//                if self.isEvent {
//                    if self.isEventFull {
//                        self.parentBaseController?.alert(message: "Event is Full.")
//                        return
//                    }
//                    self._requestRejectStatus(status: "accepted")
//                } else {
//                    self.requestUpdateStatus(status: "accepted")
//                }
//            }
//        })
        
        
        let alertController = UIAlertController(title: kAppName, message: LANGMANAGER.localizedString(forKey: "accept_confirm_alert", arguments: ["value":_userName.text ?? "user" ]), preferredStyle: .alert)

        let approveAndAddAction = UIAlertAction(title: "approve_and_add_to_circle".localized(), style: .default) { [weak self] _ in
            guard let self = self else { return }
//            self.requestUpdateStatus(status: "accepted", isAddToCircle: true)
            self._openAddToCircleBottomShhet()
        }

        let approveOnlyAction = UIAlertAction(title: "approve_only".localized(), style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.requestUpdateStatus(status: "accepted")
        }

        let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil)

        alertController.addAction(approveAndAddAction)
        alertController.addAction(approveOnlyAction)
        alertController.addAction(cancelAction)

        parentViewController?.present(alertController, animated: true, completion: nil)

    }
}
