import UIKit

class SeeAllListTableCell: UITableViewCell {

    @IBOutlet weak var _bannedStatus: CustomLabel!
    @IBOutlet weak var _btnsStack: UIStackView!
    @IBOutlet weak var _sapratorLine: UIView!
    @IBOutlet weak var _bgView: UIView!
    @IBOutlet weak var _chatBtn: UIButton!
    @IBOutlet weak var _menuBtn: UIButton!
    @IBOutlet weak var _descLabel: CustomLabel!
    @IBOutlet weak var _nameLbl: CustomLabel!
    @IBOutlet weak var _imageView: UIImageView!
    @IBOutlet weak var _viewMoreWidth: NSLayoutConstraint!
    @IBOutlet weak var _viewMoreBtn: UIButton!
    @IBOutlet weak var _circleAvtarView: UIView!
    @IBOutlet private var _circleImageViews: [UIImageView]!
    private var isFromVenue: Bool = false
    private var isFromCircle: Bool = false
    private var _venue: VenueDetailModel?
    private var _user: UserDetailModel?
    private var circleId: String = kEmptyString
    public var removeCallback: ((_ type: String) -> Void)?
    public var isFromPlusOne: Bool = false
    public var isFromNormalPlusOne: Bool = false
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height : CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupVenue(_ model: VenueDetailModel) {
        _venue = model
        isFromVenue = true
        _chatBtn.isHidden = true
        DISPATCH_ASYNC_MAIN_AFTER(0.2) {
            self._imageView.cornerRadius = 8
        }
        _imageView.loadWebImage(model.slogo, name: model.name)
        _descLabel.text = model.address
        _nameLbl.text = model.name
//        if Preferences.isSubAdmin {
//            _menuBtn.isHidden = true
//            _chatBtn.isHidden = true
//            _bannedStatus.isHidden = true
//        }
    }
    
    public func setupUser(_ model: UserDetailModel, isCircle: Bool = false, circleId: String = kEmptyString, showViewMore: Bool = false) {
        _btnsStack.isHidden = APPSESSION.userDetail?.id == model.id
        isFromCircle = isCircle
        self.circleId = circleId
        _imageView.loadWebImage(model.image, name: model.fullName)
        _bgView.backgroundColor = .clear
        _sapratorLine.isHidden = false
        _user = model
        isFromVenue = false
        _chatBtn.isHidden = false
        DISPATCH_ASYNC_MAIN_AFTER(0.2) {
            self._imageView.cornerRadius = 21
        }
        if showViewMore {
            _descLabel.text = kEmptyString
            setImagesViews(circles: model.circles.toArrayDetached(ofType: UserDetailModel.self))
        } else {
            _circleAvtarView.isHidden = true
            _descLabel.text = model.phone.isEmpty ? model.email : model.phone
        }
        _nameLbl.text = model.fullName
        if model.banStatus == "permanent" || model.banStatus == "temporary" {
            _chatBtn.isHidden = true
            _menuBtn.isHidden = true
            _bannedStatus.isHidden = false
            _bannedStatus.text = model.banStatus + " banned"
        } else {
            _chatBtn.isHidden = false
            _menuBtn.isHidden = false
            _bannedStatus.isHidden = true
        }
//        if Preferences.isSubAdmin {
//            _chatBtn.isHidden = true
//            _menuBtn.isHidden = true
//            _bannedStatus.isHidden = true
//        }
    }
    
    private func setImagesViews(circles: [UserDetailModel]) {
        _viewMoreWidth.constant = circles.isEmpty ? 0 : 60
        _circleAvtarView.isHidden = circles.isEmpty ? true : false
        
        for i in 0..<4 {
            if i < circles.count {
                _circleImageViews[i].isHidden = false
                _circleImageViews[i].loadWebImage(circles[i].avatar, name: circles[i].firstName)
            } else {
                _circleImageViews[i].isHidden = true
            }
        }
    }
    
    public func setupPlusOne(_ model: UserDetailModel, isCM: Bool = true) {
        _btnsStack.isHidden = APPSESSION.userDetail?.id == model.id
        isFromPlusOne = isCM
        isFromNormalPlusOne = !isCM
        _imageView.loadWebImage(model.image, name: model.fullName)
        _bgView.backgroundColor = .clear
        _sapratorLine.isHidden = false
        _user = model
        isFromVenue = false
        _chatBtn.isHidden = false
        DISPATCH_ASYNC_MAIN_AFTER(0.2) {
            self._imageView.cornerRadius = 21
        }
        _descLabel.text = model.phone.isEmpty ? model.email : model.phone
        _nameLbl.text = model.fullName
        if model.banStatus == "permanent" || model.banStatus == "temporary" {
            _chatBtn.isHidden = true
            _menuBtn.isHidden = true
            _bannedStatus.isHidden = false
            _bannedStatus.text = model.banStatus + " banned"
        } else {
            _chatBtn.isHidden = false
            _menuBtn.isHidden = false
            _bannedStatus.isHidden = true
        }
        setPlusStatus(model.plusOneStatus, adminStatus: model.adminStatusOnPlusOne, model: model)
//        if Preferences.isSubAdmin {
//            _chatBtn.isHidden = true
//            _menuBtn.isHidden = true
//            _bannedStatus.isHidden = true
//        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func setPlusStatus(_ status: String, adminStatus: String, model: UserDetailModel) {
        if status == "pending" {
            _descLabel.text = "pending".localized()
            _descLabel.textColor = ColorBrand.amberColor
            _chatBtn.isHidden = true
            _menuBtn.isHidden = true
        } else if status == "accepted" {
            if adminStatus == "pending" {
                _descLabel.text = "waiting_for_admin_approval".localized()
                _descLabel.textColor = ColorBrand.amberColor
                _chatBtn.isHidden = true
                _menuBtn.isHidden = true
            } else if adminStatus == "rejected" {
                _descLabel.text = "rejected".localized()
                _descLabel.textColor = .red
                _chatBtn.isHidden = true
                _menuBtn.isHidden = true
            } else {
                _descLabel.text = Utils.stringIsNullOrEmpty(model.phone) ? model.email : model.phone
                _descLabel.textColor = ColorBrand.white
                _chatBtn.isHidden = false
                _menuBtn.isHidden = false
            }
        } else if status == "rejected" {
            _descLabel.text = "rejected".localized()
            _descLabel.textColor = .red
            _chatBtn.isHidden = true
            _menuBtn.isHidden = true
        } else {
            _descLabel.text = kEmptyString
            _chatBtn.isHidden = true
            _menuBtn.isHidden = true
        }
    }
    
    private func _venueBottomSheet() {
        guard let _venue = _venue else { return }

        let alert = UIAlertController(title: _venue.name, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "remove_venue".localized(), style: .default, handler: { action in
            self.parentBaseController?.confirmAlert(message: LANGMANAGER.localizedString(forKey: "remove_venue_alert", arguments: ["value": _venue.name]), okHandler: { action in
                self._requestRemoveVenue(_venue.id)
            })
        }))

        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .destructive, handler: { _ in }))
        parentViewController?.present(alert, animated: true, completion:{
            alert.view.superview?.subviews[0].isUserInteractionEnabled = true
            alert.view.superview?.subviews[0].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
    }
    
    private func _userBottomSheet() {
        guard let user = _user else { return }

        let alert = UIAlertController(title: user.fullName, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "temporary_ban".localized(), style: .default, handler: { action in
            self.parentBaseController?.confirmAlert(message: "temporary_ban_alert".localized(), okHandler: { action in
                self._requestMemberBan(banId:self.isFromCircle ? user.id : user.userId, type: "temporary")
            })
        }))

        alert.addAction(UIAlertAction(title: "permanent_ban".localized(), style: .default, handler: { action in
            self.parentBaseController?.confirmAlert(message: "permanent_ban_alert".localized(), okHandler: { action in
                self._requestMemberBan(banId: self.isFromCircle ? user.id : user.userId, type: "permanent")
            })
        }))
        
        if isFromCircle {
            alert.addAction(UIAlertAction(title: "remove_from_circle".localized(), style: .default, handler: { action in
                self.parentBaseController?.confirmAlert(message: "remove_circle_alert".localized(), okHandler: { action in
                    self._requestRemoveFromCircle(self.circleId, memberIds: [user.id], name: user.fullName)
                })
            }))
        }
            
        alert.addAction(UIAlertAction(title: "remove_from_ring".localized(), style: .default, handler: { action in
            self.parentBaseController?.confirmAlert(message: "remove_from_ring_alert".localized(), okHandler: { action in
                self._requestRemoveFromRing(user.id, name: user.fullName)
            })
        }))
        
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .destructive, handler: { _ in }))
        parentViewController?.present(alert, animated: true, completion:{
            alert.view.superview?.subviews[0].isUserInteractionEnabled = true
            alert.view.superview?.subviews[0].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
    }
    
    private func _userPlusOneSheet(_ isCM: Bool = false) {
        guard let user = _user else { return }

        let alert = UIAlertController(title: user.fullName, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title:isCM ? "remove_from_group".localized() : "leave_plusone_group".localized(), style: .default, handler: { action in
            self.parentBaseController?.confirmAlert(message:isCM ? "remove_from_group_alert".localized() : "leave_plusone_group_alert".localized() , okHandler: { action in
                if isCM {
                    self._requestRemoveFromPlusOne(user.id, name: user.fullName)
                } else {
                    self._requestLeaveFromPlusOne(user.id, name: user.fullName)
                }
            })
        }))
                
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .destructive, handler: { _ in }))
        parentViewController?.present(alert, animated: true, completion:{
            alert.view.superview?.subviews[0].isUserInteractionEnabled = true
            alert.view.superview?.subviews[0].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
    }
    
    @objc func alertControllerBackgroundTapped() {
        self.parentViewController?.dismiss(animated: true, completion: nil)
    }

    // --------------------------------------
    // MARK: Services
    // --------------------------------------

    private func _requestRemoveVenue(_ id: String) {
        parentBaseController?.showHUD()
        WhosinServices.removeVenue(id: id) { [weak self] container, error in
            guard let self = self else { return }
            self.parentBaseController?.hideHUD()
            guard let data = container?.data else { return }
            self.parentBaseController?.showSuccessMessage("venue_removed".localized(), subtitle: kEmptyString)
            self.removeCallback?("venue")
        }
    }
    
    private func _requestMemberBan(banId: String, type: String) {
        parentBaseController?.showHUD()
        WhosinServices.memberBan(banId: banId, type: type) { [weak self] container, error in
            guard let self = self else { return }
            self.parentBaseController?.hideHUD()
            guard let data = container?.data else { return }
        }
    }

    private func _requestRemoveFromCircle(_ id: String, memberIds: [String], name: String) {
        parentBaseController?.showHUD()
        WhosinServices.removeFromCircle(id: id, memberIds: memberIds) { [weak self] container, error in
            guard let self = self else { return }
            self.parentBaseController?.hideHUD()
            guard let data = container?.data else { return }
            self.parentBaseController?.showSuccessMessage(LANGMANAGER.localizedString(forKey: "removed_from_circle", arguments: ["value": name]), subtitle: kEmptyString)
            NotificationCenter.default.post(name: .reloadPromoterProfileNotifier, object: nil)
            NotificationCenter.default.post(name: .reloadMyEventsNotifier, object: nil)
            self.removeCallback?("circle")
        }
    }
    
    private func _requestRemoveFromRing(_ id: String, name: String) {
        parentBaseController?.showHUD()
        WhosinServices.removeFromRing(id: id) { [weak self] container, error in
            guard let self = self else { return }
            self.parentBaseController?.hideHUD(error: error)
            guard let data = container else { return }
            if data.code == 1 {
                self.parentBaseController?.showToast(data.message)
                self.parentBaseController?.showSuccessMessage(LANGMANAGER.localizedString(forKey: "removed_from_ring", arguments: ["value": name]), subtitle: kEmptyString)
                NotificationCenter.default.post(name: .reloadPromoterProfileNotifier, object: nil)
//                NotificationCenter.default.post(name: .reloadMyEventsNotifier, object: nil)
            }
            self.removeCallback?("ring")
        }
    }
    
    private func _requestRemoveFromPlusOne(_ id: String, name: String) {
        parentBaseController?.showHUD()
        WhosinServices.removePlusOne(id: id) { [weak self] container, error in
            guard let self = self else { return }
            self.parentBaseController?.hideHUD(error: error)
            guard let data = container else { return }
            if data.code == 1 {
                self.parentBaseController?.showToast(data.message)
                self.parentBaseController?.showSuccessMessage(LANGMANAGER.localizedString(forKey: "removed_from_ring", arguments: ["value": name]), subtitle: kEmptyString)
                NotificationCenter.default.post(name: .reloadMyEventsNotifier, object: nil)
            }
            self.removeCallback?("group")
        }
    }

    private func _requestLeaveFromPlusOne(_ id: String, name: String) {
        parentBaseController?.showHUD()
        WhosinServices.leavePlusOne(id: id) { [weak self] container, error in
            guard let self = self else { return }
            self.parentBaseController?.hideHUD(error: error)
            guard let data = container else { return }
            if data.code == 1 {
                self.parentBaseController?.showToast(data.message)
                self.parentBaseController?.showSuccessMessage(LANGMANAGER.localizedString(forKey: "leaved_from_group", arguments: ["value": name]), subtitle: kEmptyString)
                NotificationCenter.default.post(name: .reloadMyEventsNotifier, object: nil)
            }
            self.removeCallback?("group")
        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleViewMoreEvent(_ sender: Any) {
        let vc = INIT_CONTROLLER_XIB(CircleListBottomList.self)
        vc.modalPresentationStyle = .overFullScreen
        vc.userId = _user?.userId ?? kEmptyString
        parentViewController?.present(vc, animated: true)
    }
    
    @IBAction private func _handleMenuEvent(_ sender: UIButton) {
        if isFromVenue {
            _venueBottomSheet()
        } else if isFromPlusOne || isFromNormalPlusOne {
            _userPlusOneSheet(isFromPlusOne)
        } else {
            _userBottomSheet()
        }
    }
    
    @IBAction private func _handleChatEvent(_ sender: UIButton) {
        guard let userId = isFromCircle ? _user?.id : _user?.userId else {return }
        guard let userDetail = APPSESSION.userDetail else { return }
        let chatModel = ChatModel()
        chatModel.image = self._user?.image ?? kEmptyString
        chatModel.title = self._user?.fullName ?? kEmptyString
        chatModel.chatType = "friend"
        chatModel.members.append(userId)
        chatModel.members.append(userDetail.id)
        let chatIds = [userId, Preferences.isSubAdmin ? userDetail.promoterId : userDetail.id].sorted()
        chatModel.chatId = chatIds.joined(separator: ",")
        let vc = INIT_CONTROLLER_XIB(ChatDetailVC.self)
        vc.hidesBottomBarWhenPushed = true
        vc.chatModel = chatModel
        self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
