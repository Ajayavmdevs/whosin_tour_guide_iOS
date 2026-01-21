import UIKit
import SnapKit
import CountdownLabel

class CustomPlusOneRequestView: UIView {
    
    @IBOutlet weak var _venueTime: CustomLabel!
    @IBOutlet weak var _venueName: CustomLabel!
    @IBOutlet weak var _venueImage: UIImageView!
    @IBOutlet weak var _tableView: CustomNoKeyboardTableView!
    @IBOutlet weak var _mainViewConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var _statusBgView: UIView!
    @IBOutlet weak var _statusLabel: CustomLabel!
    @IBOutlet weak var _btnsView: UIView!
    @IBOutlet private weak var _approveBtn: CustomActivityButton!
    @IBOutlet private weak var _rejectBtn: CustomActivityButton!
    @IBOutlet weak var _rejectedLable: CustomLabel!
    @IBOutlet weak var _sapratorLine: UIView!
    @IBOutlet weak var _tableBgView: UIView!
    @IBOutlet weak var _viewProfileBtn: CustomButton!
    private let kCellIdentifiere = String(describing: PlusUserTableCell.self)
    @IBOutlet weak var _userUpdatedTime: CustomLabel!
    @IBOutlet weak var _userDateTimeStack: UIStackView!
    private var _notification: NotificationModel?
    private var _usersModel: [UserDetailModel] = []
    private var isNotification:Bool = false
    private var isPromoter: Bool = false
    private var isEvent:Bool = false
    private var _model: NotificationModel?
    private var _user: UserDetailModel?
    public var updateStatusCallback:(( _ status: String) -> Void)?
    public var openCallback:((_ model: ChatModel) -> Void)?
    public var openProfile: ((_ id: String, _ isRingMember: Bool)-> Void)?
    private var isEventFull: Bool = false
    private var isFromChat: Bool = false
    private var isFromEventDetail: Bool = false
    private var isPlusOne: Bool = false
    private var isConfirmation: Bool = false
    private var memberId:String = kEmptyString
    private var _logsList: [LogsModel] = []


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
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifiere, kCellNibNameKey: kCellIdentifiere, kCellClassKey: PlusUserTableCell.self, kCellHeightKey: PlusUserTableCell.height]
        ]
    }
    
    private func _setupUi() {
        if var view = Bundle.main.loadNibNamed("CustomPlusOneRequestView", owner: self, options: nil)?.first as? UIView {
            addSubview(view)
            view.snp.makeConstraints { make in
                make.leading.trailing.top.bottom.equalToSuperview()
            }
        }
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "empty_promoter_detail".localized(),
            emptyDataIconImage: UIImage(named: "empty_explore"),
            emptyDataDescription: nil,
            delegate: self)
        _tableView.isScrollEnabled = false
//        _tableView.isUserInteractionEnabled = false

    }
    
    private func _loadData(_ usersModel: [InvitedUserModel]) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        usersModel.forEach({ model in
            model.user = model.getUser(SeeAllUsersBottomSheet.allUsersList)
            cellData.append([
                kCellIdentifierKey: kCellIdentifiere,
                kCellTagKey: kCellIdentifiere,
                kCellObjectDataKey: model,
                kCellClassKey: PlusUserTableCell.self,
                kCellHeightKey: PlusUserTableCell.height
            ])
        })
        
        if usersModel.count == 0 {
            _mainViewConstraintHeight.constant = 0
            _tableBgView.isHidden = true
            _sapratorLine.isHidden = true
        } else {
            _tableBgView.isHidden = false
            _sapratorLine.isHidden = false
            _mainViewConstraintHeight.constant = 70 * CGFloat(usersModel.count)
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    

    public func setUpData(_ model: NotificationModel, isEvent: Bool = false, isPromoter: Bool = false, isEventFull: Bool = false,isConfirmation: Bool = false) {
        self.isEventFull = isEventFull
        _statusBgView.isHidden = !isEvent
        _stautsBadge(model.promoterStatus, inviteStatus: model.inviteStatus, isConfirmation: isConfirmation)
        _notification = model
        _btnsView.isHidden = model.requestStatus == "rejected" || model.requestStatus == "accepted"
        self.isEvent = isEvent
        self.isPromoter =  isPromoter
        _approveBtn.isHidden = isEvent
        _viewProfileBtn.setTitle(isEvent ? "message".localized() : "view_profile".localized())
        _venueName.text = model.title
        _venueTime.text = model.requestStatus == "accepted" ? isPromoter ?  "added_their_ring".localized()  :"has_join_ring".localized() : model.descriptions
        _venueImage.loadWebImage(model.image, name: model.title)
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

    public func setupEventData(_ model: InvitedUserModel, isEventFull: Bool = false, isConfirmation: Bool = false, isNoAction: Bool = false, type: String = kEmptyString) {
        self.isEventFull = isEventFull
        self.isConfirmation = isConfirmation
        self.isPlusOne = false
        _stautsBadge(model.promoterStatus, inviteStatus: model.inviteStatus, isConfirmation: isConfirmation)
        _loadData(model.plusOneInvite.toArrayDetached(ofType: InvitedUserModel.self))
        isFromEventDetail = true
        _user = model.user
        _venueName.text = model.user?.fullName
        _venueImage.loadWebImage(model.user?.image ?? kEmptyString, name: model.user?.fullName ?? kEmptyString)
        memberId = model.id
        _venueTime.text = model.promoterStatus == "accepted" ? "has_join_event".localized()  : "added_in_event".localized()
        let updatedDateTime = Utils.dateToString(model.logs.first?.dateTime, format: kFormatDateWithHourMinuteAM)
        _userUpdatedTime.isHidden = Utils.stringIsNullOrEmpty(updatedDateTime)
        _userDateTimeStack.isHidden = model.logs.toArrayDetached(ofType: LogsModel.self).isEmpty
        _userUpdatedTime.text = updatedDateTime
        _logsList = model.logs.toArrayDetached(ofType: LogsModel.self)
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
            _btnsView.isHidden = true
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
            }
        }
    }

    
    // --------------------------------------
    // MARK: Events
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
    
    @IBAction private func _handleVeiwProfileEvent(_ sender: UIButton) {
        if isEvent {
            guard let userId = isFromEventDetail ? _user?.id ?? kEmptyString : isFromChat ? _user?.userId :_model?.userId else { return }
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
        self.parentBaseController?.confirmAlert(message: LANGMANAGER.localizedString(forKey: "reject_confirm_alert", arguments: ["value": _venueName.text ?? "user"]), okHandler: { action in
                 self._requestRejectStatus(status: "rejected")
        })
    }
    
    @IBAction private func _handleApproveEvent(_ sender: CustomActivityButton) {
        self.parentBaseController?.confirmAlert(message: LANGMANAGER.localizedString(forKey: "accept_confirm_alert", arguments: ["value": _venueName.text ?? "user"]), okHandler: { action in
            if self.isEventFull {
                self.parentBaseController?.alert(message: "event_full".localized())
                return
            }
            self._requestRejectStatus(status: "accepted")
        })
    }
    
    @IBAction private func _handleSeeAllLogsEvent(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(LogBottomSheet.self)
        vc.modalPresentationStyle = .overFullScreen
        vc.logsList = self._logsList
        parentViewController?.present(vc, animated: true)
        
    }
    
}

extension CustomPlusOneRequestView: CustomNoKeyboardTableViewDelegate {
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? PlusUserTableCell {
            if let object = cellDict?[kCellObjectDataKey] as? InvitedUserModel {
                cell.setupEventData(object, isConfirmation: isConfirmation)
            }
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? InvitedUserModel else { return }
        openProfile?(object.user?.id ?? kEmptyString, object.user?.isRingMember ?? false)
    }
}


