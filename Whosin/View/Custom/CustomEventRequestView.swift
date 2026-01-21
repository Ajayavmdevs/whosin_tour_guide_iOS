import UIKit
import SnapKit
import CountdownLabel

class CustomEventRequestView: UIView {
    
    @IBOutlet weak var _customUserList: CustomUserListView!
    @IBOutlet weak var _secUserApproveView: UIView!
    @IBOutlet weak var _firstUserApproveView: UIView!
    @IBOutlet weak var _secUsrApprove: CustomActivityButton!
    @IBOutlet weak var _firstUsrApprove: CustomActivityButton!
    @IBOutlet weak var _msgCount: UIButton!
    @IBOutlet weak var _seeAllView: UIView!
    @IBOutlet weak var _availbleSeats: CustomLabel!
    @IBOutlet weak var _venueTime: CustomLabel!
    @IBOutlet weak var _venueName: CustomLabel!
    @IBOutlet weak var _venueImage: UIImageView!
    @IBOutlet weak var _groupChatBtnView: UIView!
    @IBOutlet weak var _user1Name: CustomLabel!
    @IBOutlet weak var _user1Img: UIImageView!
    @IBOutlet weak var _user2Img: UIImageView!
    @IBOutlet weak var _user2Name: CustomLabel!
    @IBOutlet weak var _user2View: UIView!
    @IBOutlet weak var _user1View: UIView!
    @IBOutlet weak var _user1Desc: CustomLabel!
    @IBOutlet weak var _user2Desc: CustomLabel!
    @IBOutlet weak var _saparator2: UIView!
    @IBOutlet weak var _saparator1: UIView!
    @IBOutlet weak var _firstUserRejectBtn: CustomActivityButton!
    @IBOutlet weak var _secUserRejectBtn: CustomActivityButton!
    @IBOutlet weak var _seeAllBtn: CustomButton!
    @IBOutlet weak var _promoterInfoView: UIView!
    @IBOutlet weak var _promoterImage: UIImageView!
    @IBOutlet weak var _promoterName: CustomLabel!
    @IBOutlet weak var _groupChatButton: CustomActivityButton!
    private var _notification: NotificationModel?
    private var _chatListModel: PromoterChatListModel?
    private var _notificationUsers: [NotificationModel] = []
    private var _chatUsers: [UserDetailModel] = []
    private var isNotification:Bool = false
    private var isPromoter: Bool = false
    private var isplusOne: Bool = false

    
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
        if var view = Bundle.main.loadNibNamed("CustomEventRequestView", owner: self, options: nil)?.first as? UIView {
            addSubview(view)
            view.snp.makeConstraints { make in
                make.leading.trailing.top.bottom.equalToSuperview()
            }
        }
    }
    

    public func setUpData(_ model: NotificationModel, isNotification: Bool) {
        self.isNotification = isNotification
        _notification = model
        _notificationUsers = model.list.toArrayDetached(ofType: NotificationModel.self).filter({ $0.inviteStatus == "in" && $0.promoterStatus != "rejected" })
        configureButtons(users: _notificationUsers)
        configureEventDetails(model: model)
        configureUserViews(users: _notificationUsers)
    }
    
    public func setUpChatData(_ model: PromoterChatListModel, isPromoter: Bool = false) {
        self.isNotification = false
        self.isPromoter = isPromoter
        _chatListModel = model
        _chatUsers = model.inUsers
        configureButtons(users: _chatUsers)
        configureChatDetails(model: model)
        configureUserViews(users: _chatUsers, isChat: true)
    }

    private func configureEventDetails(model: NotificationModel) {
        _venueImage.loadWebImage((model.event?.venueType == "venue" ? model.event?.venue?.slogo ?? kEmptyString : model.event?.customVenue?.image) ?? kEmptyString, name: model.event?.venueType == "venue" ? model.event?.venue?.name ?? kEmptyString : model.event?.customVenue?.name ?? kEmptyString)
        _venueName.text = model.event?.venueType == "venue" ? model.event?.venue?.name : model.event?.customVenue?.name
        _venueTime.text = "\(Utils.dateToString(Utils.stringToDate(model.event?.date ?? kEmptyString, format: kFormatDate), format: kFormatEventDate))  |  \(model.event?.startTime  ?? kEmptyString) - \(model.event?.endTime  ?? kEmptyString)"
        _availbleSeats.text = "\(model.event?.maxInvitee  ?? 0) " + "seats".localized()
        if model.event?.status == "in-progress" || model.event?.status == "completed" {
            _saparator1.isHidden = true
            _saparator2.isHidden = true
            _user1View.isHidden = true
            _user2View.isHidden = true
            _seeAllView.isHidden = true
        }
        _groupChatBtnView.isHidden = true
        _seeAllView.isHidden = isNotification ? _notificationUsers.count < 2 : true
    }
    
    private func configureChatDetails(model: PromoterChatListModel) {
        _venueImage.loadWebImage(model.venueImage, name: model.venueName)
        _venueName.text = model.venueName
        let date = Utils.stringToDate(model.date, format: "yyyy-MM-dd")
        _venueTime.text = "\(Utils.dateToString(date, format: kFormatEventDate)) | \(model.startTime) - \(model.endTime)"
        _availbleSeats.text = "\(model.maxInvitee) " + "seats".localized()
        _availbleSeats.isHidden = model.maxInvitee == 0
        _msgCount.isHidden = true
        _msgCount.setTitle("\(model.totalMessages)")
        _groupChatBtnView.isHidden = false
        _promoterInfoView.isHidden = isPromoter
        _groupChatButton.setTitle(isPromoter ? "group_chat".localized() : "view_event_message".localized() , for: .normal)
        _promoterImage.loadWebImage(model.owner?.image ?? kEmptyString, name: model.owner?.fullName ?? kEmptyString)
        _promoterName.text = model.owner?.fullName
        _seeAllView.isHidden = true
    }
    
    private func configureUserViews(users: [Any], isChat: Bool = false) {
        _saparator1.isHidden = isNotification ? users.count < 2 : true
        _user1View.isHidden = isNotification ? users.count < 1 : true
        _saparator2.isHidden = isNotification ? users.count < 2 : true
        _user2View.isHidden = isNotification ? users.count < 2 : true
        if isNotification {
            _customUserList.isHidden = true
            if users.count >= 1 {
                if let firstUser = users[0] as? NotificationModel {
                    _user1Name.text = firstUser.title
                    _user1Img.loadWebImage(firstUser.image, name: firstUser.title)
                    _user1Desc.text = firstUser.descriptions
                } else if let firstUser = users[0] as? UserDetailModel {
                    _user1Name.text = firstUser.fullName
                    _user1Img.loadWebImage(firstUser.image, name: firstUser.fullName)
                    _user1Desc.text = firstUser.descriptions
                }
                _user1View.isHidden = false
                _saparator1.isHidden = false
            }
            
            if users.count >= 2 {
                if let secondUser = users[1] as? NotificationModel {
                    _user2Name.text = secondUser.title
                    _user2Img.loadWebImage(secondUser.image, name: secondUser.title)
                    _user2Desc.text = secondUser.descriptions
                } else if let secondUser = users[1] as? UserDetailModel {
                    _user2Name.text = secondUser.fullName
                    _user2Img.loadWebImage(secondUser.image, name: secondUser.fullName)
                    _user2Desc.text = secondUser.descriptions
                }
                _user2View.isHidden = false
                _saparator2.isHidden = false
            }
        } else {
            guard let list = users as? [UserDetailModel] else { return }
            _customUserList.isHidden = list.isEmpty
            _customUserList._seeAllBtn.isHidden = false
            _customUserList.setupData(list, title: "users".localized(),counts: "(\(list.count))", isshowCount: true, titleFont: FontBrand.SFboldFont(size: 13))
            _customUserList.openSeeAll = {
                self._handleSeeAllEvent(CustomButton(CGRect()))
            }
        }
    }
    
    private func configureButtons(users: [Any]) {
        _firstUsrApprove.backgroundColor = ColorBrand.brandGreen
        _firstUsrApprove.setTitleColor(.white, for: .normal)
        _secUsrApprove.backgroundColor = ColorBrand.brandGreen
        _secUsrApprove.setTitleColor(.white, for: .normal)
        _firstUserRejectBtn.setTitle("reject".localized(), for: .normal)
        _secUserRejectBtn.setTitle("reject".localized(), for: .normal)
        
        if let firstUser = users.first as? NotificationModel, firstUser.promoterStatus == "pending" {
            _firstUserApproveView.isHidden = false
        } else if let firstUser = users.first as? UserDetailModel, firstUser.promoterStatus == "pending" {
            _firstUserApproveView.isHidden = false
        } else {
            _firstUserApproveView.isHidden = true
        }
        
        guard users.count >= 2 else { return }
        if let secondUser = users[1] as? NotificationModel, secondUser.promoterStatus == "pending" {
            _secUserApproveView.isHidden = false
        } else if let secondUser = users[1] as? UserDetailModel, secondUser.promoterStatus == "pending" {
            _secUserApproveView.isHidden = false
        } else {
            _secUserApproveView.isHidden = true
        }
    }
    
    private func _requestUpdateStatus(status: String, id: String) {
        let params: [String: Any] = ["memberId": id,"status": status]
        WhosinServices.promoterStatus(params: params) { [weak self] container, error in
            guard let self = self else { return }
            self._firstUserRejectBtn.hideActivity()
            self._secUserRejectBtn.hideActivity()
            self.parentBaseController?.hideHUD(error: error)
            guard let data = container else { return }
            self._firstUserRejectBtn.setTitle("reject".localized(), for: .normal)
            self._secUserRejectBtn.setTitle("reject".localized(), for: .normal)
        }
    }
    
    private func _requestRejectStatus(status: String, id: String, buttonType: Int) {
        WhosinServices.promoterEventInviteStatus(inviteId: id, inviteStatus: status) { [weak self] container, error in
            guard let self = self else { return }
            if buttonType == 1 {
                self._firstUserRejectBtn.hideActivity()
                self._firstUsrApprove.hideActivity()
            } else if buttonType == 2 {
                self._secUserRejectBtn.hideActivity()
                self._secUsrApprove.hideActivity()
            }
            self.parentBaseController?.hideHUD(error: error)
            guard let data = container else { return }
            if data.code == 1 {
                NotificationCenter.default.post(name: .reloadMyEventsNotifier , object: nil)
                NotificationCenter.default.post(name: .reloadEventNotification , object: nil)
            }
        }
    }
    
    private func _requestPlusOneRejectStatus(status: String, id: String, buttonType: Int) {
        WhosinServices.plusOnePromoterRequest(inviteId: id, inviteStatus: status) { [weak self] container, error in
            guard let self = self else { return }
            if buttonType == 1 {
                self._firstUserRejectBtn.hideActivity()
                self._firstUsrApprove.hideActivity()
            } else if buttonType == 2 {
                self._secUserRejectBtn.hideActivity()
                self._secUsrApprove.hideActivity()
            }
            self.parentBaseController?.hideHUD(error: error)
            guard let data = container else { return }
            if data.code == 1 {
                NotificationCenter.default.post(name: .reloadMyEventsNotifier , object: nil)
                NotificationCenter.default.post(name: .reloadEventNotification , object: nil)
            }
        }
    }
    
    private func _requestCreateGroupChat(_ data: PromoterChatListModel) {
        let chatModel = ChatModel()
        chatModel.image = data.owner?.image ?? kEmptyString
        chatModel.title = data.owner?.fullName ?? kEmptyString
        chatModel.chatId = data.id
        chatModel.chatType = ChatType.promoterEvent.rawValue
        let members = _chatUsers.map({ $0.userId })
        chatModel.members.append(objectsIn: members)
        if let userDetail = data.owner {
            if !chatModel.members.contains(where: { $0 == userDetail.id }) {
                chatModel.members.append(userDetail.id)
            }
        }
        DISPATCH_ASYNC_MAIN_AFTER(0.01) {
            let vc = INIT_CONTROLLER_XIB(ChatDetailVC.self)
            vc.chatModel = chatModel
            vc.isPromoter = self.isPromoter
            vc.venueName = data.venueName
            vc.venueImage = data.venueImage
            vc.isComplementry = !self.isPromoter
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
    
    private func _requestCreateChat(image: String, id: String, name: String) {
        guard let userDetail = APPSESSION.userDetail else { return }
        let chatModel = ChatModel()
        chatModel.image = image
        chatModel.title = name
        chatModel.members.append(id)
        chatModel.members.append(userDetail.id)
        let chatIds = [id, Preferences.isSubAdmin ? userDetail.promoterId : userDetail.id].sorted()
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
    

    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
    @IBAction private func _handleFirstUserMessage(_ sender: CustomButton) {
        if isNotification {
            _requestCreateChat(image: _notificationUsers[0].image, id: _notificationUsers[0].userId, name: _notificationUsers[0].title)
        } else {
            _requestCreateChat(image: _chatUsers[0].image, id: _chatUsers[0].userId, name: _chatUsers[0].fullName)
        }
    }
    
    @IBAction private func _handleSecUserMessage(_ sender: CustomButton) {
        if isNotification {
            _requestCreateChat(image: _notificationUsers[1].image, id: _notificationUsers[1].userId, name: _notificationUsers[1].title)
        } else {
            _requestCreateChat(image: _chatUsers[1].image, id: _chatUsers[1].userId, name: _chatUsers[1].fullName)
        }
    }
    
    @IBAction private func _handleRejectFirstUser(_ sender: CustomActivityButton) {
        self.parentBaseController?.confirmAlert(message: LANGMANAGER.localizedString(forKey: "reject_confirm_alert", arguments: ["value": isNotification ? _notificationUsers[0].title : _chatUsers[0].fullName]), okHandler: { action in
            self._firstUserRejectBtn.showActivity()
            if self.isNotification {
                if self.isplusOne {
                    self._requestPlusOneRejectStatus(status: "rejected", id: self._notificationUsers[0].typeId, buttonType: 1)
                } else {
                    self._requestRejectStatus(status: "rejected", id: self._notificationUsers[0].typeId, buttonType: 1)
                }
            } else {
                if self.isplusOne {
                    self._requestPlusOneRejectStatus(status: "rejected", id: self._chatUsers[0].id, buttonType: 1)
                } else {
                    self._requestRejectStatus(status: "rejected", id: self._chatUsers[0].id, buttonType: 1)
                }
            }
        })
    }
    
    @IBAction private func _handleSecondUser(_ sender: CustomActivityButton) {
        self.parentBaseController?.confirmAlert(message: "are_you_sure_remove".localized() + "\(isNotification ? _notificationUsers[1].title : _chatUsers[1].fullName) ?", okHandler: { action in
            self._secUserRejectBtn.showActivity()
            if self.isNotification {
                self._requestRejectStatus(status: "rejected", id: self._notificationUsers[1].typeId, buttonType: 2)
            } else {
                self._requestRejectStatus(status: "rejected", id: self._chatUsers[1].id, buttonType: 2)
            }
        })
    }
    
    @IBAction private func _handleSeeAllEvent(_ sender: CustomButton) {
        let vc = INIT_CONTROLLER_XIB(SeeAllUsersBottomSheet.self)
        vc.userType = "invited"
        vc.event = _notification?.event
        if isNotification {
            vc.notificationModel = _notification
        } else {
            vc.chatListModel = _chatListModel
        }

        vc.openChat = { model in
            let vc = INIT_CONTROLLER_XIB(ChatDetailVC.self)
            vc.hidesBottomBarWhenPushed = true
            vc.chatModel = model
            self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
        }
        parentViewController?.presentAsPanModal(controller: vc)
    }
    
    @IBAction private func _acceptFirstUserEvent(_ sender: CustomActivityButton) {
        if isNotification {
            if _notification?.list.toArrayDetached(ofType: NotificationModel.self).filter({ $0.promoterStatus == "accepted" }).count ?? 0 > _notification?.event?.maxInvitee ?? 0, _notification?.event?.isConfirmationRequired == true {
                parentBaseController?.alert(message: "event_full".localized())
                return
            }
        } else {
            if _chatListModel?.users.toArrayDetached(ofType: UserDetailModel.self).filter({ $0.promoterStatus == "accepted" }).count ?? 0 >= _chatListModel?.maxInvitee ?? 0 {
                parentBaseController?.alert(message: "event_full".localized())
                return
            }
        }
        self._firstUsrApprove.showActivity()
        if self.isNotification {
            self._requestRejectStatus(status: "accepted", id: self._notificationUsers[0].typeId, buttonType: 1)
        } else {
            self._requestRejectStatus(status: "accepted", id: self._chatUsers[0].id, buttonType: 1)
        }
    }
    
    @IBAction private func _acceptSecUserEvent(_ sender: CustomActivityButton) {
        if isNotification {
            if _notification?.list.toArrayDetached(ofType: NotificationModel.self).filter({ $0.promoterStatus == "accepted" }).count ?? 0 >= _notification?.event?.maxInvitee ?? 0, _notification?.event?.isConfirmationRequired == true {
                parentBaseController?.alert(message: "event_full".localized())
                return
            }
        } else {
            if _chatListModel?.users.toArrayDetached(ofType: UserDetailModel.self).filter({ $0.promoterStatus == "accepted" }).count ?? 0 >= _chatListModel?.maxInvitee ?? 0 {
                parentBaseController?.alert(message: "event_full".localized())
                return
            }
        }
        self._secUsrApprove.showActivity()
        if self.isNotification {
            self._requestRejectStatus(status: "accepted", id: self._notificationUsers[1].typeId, buttonType: 2)
        } else {
            self._requestRejectStatus(status: "accepted", id: self._chatUsers[1].id, buttonType: 2)
        }
    }
    
    @IBAction private func _handleGroupChat(_ sender: CustomActivityButton) {
        guard let chatModel = _chatListModel else { return }
        _requestCreateGroupChat(chatModel)
    }

    
}


