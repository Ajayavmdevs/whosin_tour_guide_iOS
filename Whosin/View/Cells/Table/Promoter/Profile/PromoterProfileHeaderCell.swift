import UIKit
import Lightbox

class PromoterProfileHeaderCell: UITableViewCell {
    
    @IBOutlet weak var _publicChatBtn: CustomActivityButton!
    @IBOutlet weak var _bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var _btnsStackView: UIStackView!
    @IBOutlet weak var _publicCompBtns: UIStackView!
    @IBOutlet weak var _switchProfileBtn: CustomActivityButton!
    @IBOutlet weak var _galaryView: CustomGallaryView!
    @IBOutlet private weak var _bioLbl: CustomLabel!
    @IBOutlet private weak var _nameLbl: CustomLabel!
    @IBOutlet private weak var _promoterImage: UIImageView!
    @IBOutlet weak var _editProfileBtn: CustomActivityButton!
    @IBOutlet weak var _addToRingBtn: CustomActivityButton!
    @IBOutlet weak var _createEventBtn: CustomActivityButton!
    @IBOutlet weak var _promoterView: UIView!
    @IBOutlet weak var _promoterText: CustomLabel!
    private var promoterModel: PromoterProfileModel?
    @IBOutlet weak var _publicAddRingBtn: CustomActivityButton!
    @IBOutlet weak var _addToCircleBtn: CustomActivityButton!
    public var isFromPersonal: Bool = false
    private var _isPublic: Bool = false
    private var _isComplemenatary: Bool = false
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
    class var identifier : String { String(describing: PromoterProfileHeaderCell.self) }
    
    class var protocole: [String: Any] {
        [kCellIdentifierKey: identifier, kCellNibNameKey: identifier, kCellClassKey: PromoterProfileHeaderCell.self, kCellHeightKey: height]
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        _promoterImage.isUserInteractionEnabled = true
        _promoterImage.addGestureRecognizer(tapGesture)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ model:  PromoterProfileModel, isComplemenatary: Bool = false, isPublic: Bool = false, isSubAdmin: Bool = false) {
        promoterModel = model
        _switchProfileBtn.isHidden = isPublic
        self._isPublic = isPublic
        self._isComplemenatary = isComplemenatary
        guard let profile = model.profile else { return }
        if profile.images.isEmpty {
            _galaryView.setupHeader([""])
        } else {
            _galaryView.setupHeader(profile.images.toArray(ofType: String.self))
        }
        _bioLbl.text = profile.bio
        _nameLbl.text = profile.fullName
        _promoterImage.loadWebImage(profile.image, name: profile.fullName)
        _promoterView.backgroundColor = isComplemenatary ? UIColor(hexString: "#FF7A00") : UIColor(hexString: "#DD00F0")
        _promoterText.text = isComplemenatary ? "complimentary".localized() : "promoter".localized()
        if isFromPersonal {
            _switchProfileBtn.isHidden = false
        }
//        _bottomConstraint.constant = isSubAdmin ? 0 : 15
        _setupButtonOption()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    @objc func imageTapped(sender: UITapGestureRecognizer) {
        var images: [LightboxImage] = []
        if sender.state == .ended, let image = _promoterImage.image {
            images.append(LightboxImage(image: image))
        } else if sender.state == .ended {
            images.append(LightboxImage(imageURL: URL(string: promoterModel?.profile?.image ?? kEmptyString)!))
        }
        let controller = LightboxController(images: images)
        controller.dynamicBackground = true
        parentBaseController?.present(controller, animated: true, completion: nil)
    }
    
    private func _setupButtonOption(_ isSubAdmin: Bool = false) {
        if isSubAdmin {
            _btnsStackView.isHidden = true
            _publicCompBtns.isHidden = true
            _createEventBtn.isHidden = true
            _switchProfileBtn.isHidden = true
        } else {
            _addToRingBtn.isHidden = self._isComplemenatary
            _createEventBtn.isHidden = self._isComplemenatary
            if !self._isComplemenatary  {
                if _isPublic {
                    updateButtonAppearance(promoterModel?.profile?.follow ?? "none")
                    updateButtonForJoinRing(promoterModel?.profile?.ringMember ?? "none",isCM: self._isComplemenatary)
                    _addToRingBtn.setTitle("chat".localized())
                } else {
                    _addToRingBtn.setTitle("add_to_ring".localized())
                    _editProfileBtn.setTitle("edit_profile".localized())
                    _createEventBtn.setTitle(_isPublic ? "join_to_ring".localized() : "create_event".localized())
                }
            } else {
                if _isPublic {
                    _publicCompBtns.isHidden = false
                    updateButtonForCMJoinRing(promoterModel?.profile?.myRingStatus ?? "none", promoterStatus: promoterModel?.profile?.ringPromoterStatus ?? "none")
                    _editProfileBtn.isHidden = true
                } else {
                    _editProfileBtn.setTitle(_isPublic ? "follow".localized() : "edit_profile".localized())
                }
            }
        }
    }
    
    // --------------------------------------
    // MARK: Services
    // --------------------------------------
    
    private func _requestJoinMyRing() {
        _createEventBtn.setTitle(kEmptyString)
        _createEventBtn.showActivity()
        guard let id = promoterModel?.profile?.userId else { return }
        WhosinServices.joinMyRingRequest(id: id) { [weak self] container, error in
            guard let self = self else { return }
            self._createEventBtn.hideActivity()
            self.parentBaseController?.showError(error)
            guard let data = container else { return }
            if data.code == 1 {
                self._createEventBtn.setTitle("request_sent".localized())
                self.parentBaseController?.showSuccessMessage("thank_you".localized(), subtitle: "joining_my_ring".localized())
            }
        }
    }
    
    private func _requestLeaveMyRing() {
        _createEventBtn.setTitle(kEmptyString)
        _createEventBtn.showActivity()
        guard let id = promoterModel?.profile?.userId else { return }
        WhosinServices.leaveMyRingRequest(id: id) { [weak self] container, error in
            guard let self = self else { return }
            self._createEventBtn.hideActivity()
            self.parentBaseController?.showError(error)
            guard let data = container else { return }
            if data.code == 1 {
                self._createEventBtn.setTitle("join_to_ring".localized())
                self.parentBaseController?.showSuccessMessage("oh_snap".localized(), subtitle: "leaving_ring".localized() )
                NotificationCenter.default.post(name:kRelaodActivitInfo, object: nil, userInfo: nil)
                NotificationCenter.default.post(name:.reloadMyEventsNotifier, object: nil, userInfo: nil)
            }
        }
    }
    
    private func _requestFollow() {
        _editProfileBtn.setTitle(kEmptyString)
        _editProfileBtn.showActivity()
        guard let model = promoterModel?.profile else { return }
        WhosinServices.userFollow(id: model.userId) { [weak self] container, error in
            guard let self = self else { return }
            self.parentBaseController?.showError(error)
            self._editProfileBtn.hideActivity()
            guard let data = container?.data else { return }
            self.updateButtonAppearance(data.status)
            self._showMessage(status: data.status, name: model.fullName)
            data.id = model.id
            NotificationCenter.default.post(name: kReloadFollowStatus, object: data, userInfo: nil)
        }
    }
    
    private func _requestaddtoRing() {
        _publicAddRingBtn.setTitle(kEmptyString)
        _publicAddRingBtn.showActivity()
        guard let id = promoterModel?.profile?.userId else { return }
        WhosinServices.addToRingUser(id: id) { [weak self] container, error in
            guard let self = self else { return }
            self._publicAddRingBtn.hideActivity()
            self.parentBaseController?.showError(error)
            guard let data = container else { return }
            NotificationCenter.default.post(name: kRelaodActivitInfo, object: data, userInfo: nil)
//            if data.code == 1 {
//                _publicAddRingBtn.setTitle("waiting for approval")
//                promoterModel?.profile?.myRingStatus = "pending"
//            }
        }
    }
    
    private func updateButtonAppearance(_ status: String) {
        switch status {
        case "approved", "Followed!" :
            self._editProfileBtn.setTitle("following".localized())
        case "pending", "Requested" :
            self._editProfileBtn.setTitle("requested".localized())
        case "cancelled", "Unfollowed!" :
            self._editProfileBtn.setTitle("follow".localized())
        default:
            self._editProfileBtn.setTitle("follow".localized())
        }
    }
    
    private func updateButtonForJoinRing(_ status: String, isCM: Bool = false) {
        switch status {
        case "accepted" :
            self._createEventBtn.setTitle(isCM ? "remove_from_ring".localized() : "leave_ring".localized())
            _publicAddRingBtn.setTitle(isCM ? "remove_from_ring".localized() :"leave_ring".localized())
        case "pending" :
            self._createEventBtn.setTitle(APPSESSION.userDetail?.isRingMember == true ? "waiting_for_approval".localized() : "apply_to_join_ring".localized())
            _publicAddRingBtn.setTitle("waiting_for_approval".localized())
        case "none", "rejected" :
            self._createEventBtn.setTitle(isCM ? "add_to_my_ring".localized() :"join_to_ring".localized())
            _publicAddRingBtn.setTitle(isCM ? "add_to_my_ring".localized() :"join_to_ring".localized())
        default:
            self._createEventBtn.setTitle(isCM ? "add_to_my_ring".localized() :"join_to_ring".localized())
            _publicAddRingBtn.setTitle(isCM ? "add_to_my_ring".localized() :"join_to_ring".localized())
        }
    }
    
    private func updateButtonForCMJoinRing(_ status: String, promoterStatus: String) {
        switch (status, promoterStatus) {
        case ("accepted", "pending"):
            _publicAddRingBtn.setTitle("waiting_for_approval".localized())
            _publicChatBtn.isHidden = true
        case ("accepted", "rejected"):
            _publicAddRingBtn.setTitle("add_to_my_ring".localized())
            _publicChatBtn.isHidden = true
        case ("accepted", "accepted"):
            _publicAddRingBtn.setTitle("remove_from_ring".localized())
            _publicChatBtn.isHidden = false
            _addToCircleBtn.isHidden = false
        case ("pending", "accepted"):
            _publicAddRingBtn.setTitle("waiting_for_approval".localized())
            _publicChatBtn.isHidden = true
        case ("pending", _):
            _publicAddRingBtn.setTitle("waiting_for_approval".localized())
            _publicChatBtn.isHidden = true
        case ("none", _), ("rejected", _):
            _publicAddRingBtn.setTitle("add_to_my_ring".localized())
            _publicChatBtn.isHidden = true
        case (_ ,"none"), (_ ,"rejected"):
            _publicAddRingBtn.setTitle("add_to_my_ring".localized())
            _publicChatBtn.isHidden = true
        default:
            _publicAddRingBtn.setTitle("add_to_my_ring".localized())
            _publicChatBtn.isHidden = true
        }
    }

    
    private func _showMessage(status: String, name: String) {
        switch status {
        case "approved", "Followed!" :
            self.parentBaseController?.showSuccessMessage("thank_you".localized(), subtitle: LANGMANAGER.localizedString(forKey: "following_toast", arguments: ["value": name]) )
        case "pending", "Requested" :
            self.parentBaseController?.showSuccessMessage("thank_you".localized() , subtitle: LANGMANAGER.localizedString(forKey: "have_requested_follow", arguments: ["value": name]))
        case "cancelled", "Unfollowed!" :
            self.parentBaseController?.showSuccessMessage("oh_snap".localized(), subtitle: LANGMANAGER.localizedString(forKey: "unfollow_toast", arguments: ["value": name]))
        default:
            self.parentBaseController?.showSuccessMessage("oh_snap".localized(), subtitle: LANGMANAGER.localizedString(forKey: "unfollow_toast", arguments: ["value": name]))
        }
    }
    
    private func _requestRemoveFromRing() {
        guard let id = promoterModel?.profile?.userId else { return }
        parentBaseController?.showHUD()
        WhosinServices.removeFromRing(id: id) { [weak self] container, error in
            guard let self = self else { return }
            self.parentBaseController?.hideHUD(error: error)
            guard let data = container else { return }
            if data.code == 1 {
                self.parentBaseController?.showToast(data.message)
                NotificationCenter.default.post(name: .reloadPromoterProfileNotifier, object: nil)
                promoterModel?.profile?.myRingStatus = "none"
                _publicAddRingBtn.setTitle("add_to_my_ring".localized())
            }
        }
    }
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
    
    @IBAction private func _handleEditProfile(_ sender: CustomActivityButton) {
        if _isPublic {
            _requestFollow()
        } else {
            let vc = INIT_CONTROLLER_XIB(PromoterApplicationVC.self)
            vc.isEdit = true
            vc.isComlementry = _isComplemenatary
            vc.detailModel = promoterModel?.profile
            self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction private func _handleAddToRing(_ sender: CustomActivityButton) {
        if _isPublic {
            _openChat()
        } else {
            let vc = INIT_CONTROLLER_XIB(ContactShareBottomSheet.self)
            vc.isMultiSelect = false
            vc.isFromCreateBucket = true
            vc.isFromRing = true
            vc.sharedContactId = promoterModel?.rings?.ringList.toArrayDetached(ofType: UserDetailModel.self).map({ $0.userId }) ?? []
            self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction private func _handleCreatEvent(_ sender: CustomActivityButton) {
        if _isPublic {
            if APPSESSION.userDetail?.isRingMember == true {
                if promoterModel?.profile?.ringMember == "rejected" || promoterModel?.profile?.ringMember == "none"  {
                    _requestJoinMyRing()
                } else if promoterModel?.profile?.ringMember == "pending" {
                    
                } else {
                    parentBaseController?.confirmAlert(message: "leave_ring_requiest_alert".localized(), okHandler: { action in
                        self._requestLeaveMyRing()
                    })
                }
            } else {
                let vc = INIT_CONTROLLER_XIB(PromoterApplicationVC.self)
                vc.isComlementry = true
                vc.referredById = promoterModel?.profile?.userId ?? kEmptyString
                self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            let vc = INIT_CONTROLLER_XIB(CreateEventVC.self)
            vc.promoterModel = self.promoterModel
            vc.hidesBottomBarWhenPushed = true
            self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction private func _handleSwitchToPersional(_ sender: CustomActivityButton) {
        if isFromPersonal {
            guard let controller = self.parentViewController?.navigationController?.viewControllers.first(where: {$0.isKind(of: UsersProfileVC.self)}) else {
                let vc = INIT_CONTROLLER_XIB(UsersProfileVC.self)
                vc.contactId = promoterModel?.profile?.userId ?? ""
                vc.isSwitchProfile = true
                self.parentViewController?.navigationController?.pushViewController(vc, animated: false)
                return
            }
            self.parentViewController?.navigationController?.popViewController(animated: false)
        } else {
            NotificationCenter.default.post(name: .switchToPersonalProfile, object: nil)
            self.parentViewController?.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction private func _handlePublicAddToRingEvent(_ sender: CustomActivityButton) {
        if promoterModel?.profile?.myRingStatus == "none" || promoterModel?.profile?.myRingStatus == "rejected" {
            _requestaddtoRing()
        } else if  promoterModel?.profile?.myRingStatus == "accepted" {
            parentBaseController?.confirmAlert(message: "remove_ring_requiest_alert".localized(), okHandler: { action in
                self._requestRemoveFromRing()
            })
        } else if promoterModel?.profile?.myRingStatus == "pending" {
            
        }
    }
    
    @IBAction private func _handleChatEvent(_ sender: CustomActivityButton) {
        _openChat()
    }
    
    @IBAction func _handleAddToCircleEvent(_ sender: UIButton) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        let vc = INIT_CONTROLLER_XIB(AddToCircleBottomSheet.self)
        vc.modalPresentationStyle = .overFullScreen
        vc.profileId = promoterModel?.profile?.userId ?? kEmptyString
        vc.alreadyInCircleList = promoterModel?.rings?.ringList.first(where: { $0.userId == APPSESSION.userDetail?.id })?.circles.toArrayDetached(ofType: UserDetailModel.self) ?? []
        parentViewController?.present(vc, animated: true)
    }
    
    private func _openChat() {
        guard let userDetail = APPSESSION.userDetail else { return }
        guard let user = promoterModel?.profile else { return }
        let chatModel = ChatModel()
        chatModel.image = user.image
        chatModel.title = user.fullName
        chatModel.members.append(user.userId)
        chatModel.members.append(userDetail.id)
        let chatIds = [user.userId, Preferences.isSubAdmin ? userDetail.promoterId : userDetail.id].sorted()
        chatModel.chatId = chatIds.joined(separator: ",")
        chatModel.chatType = "friend"
        DISPATCH_ASYNC_MAIN_AFTER(0.01) {
            let vc = INIT_CONTROLLER_XIB(ChatDetailVC.self)
            vc.chatModel = chatModel
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
    
}

extension PromoterProfileHeaderCell: ReloadProfileDelegate {
    func didRequestReload() {
        _nameLbl.text = APPSESSION.userDetail?.fullName
        _promoterImage.loadWebImage(APPSESSION.userDetail?.image ?? kEmptyString, name: APPSESSION.userDetail?.fullName ?? kEmptyString)
    }
}
