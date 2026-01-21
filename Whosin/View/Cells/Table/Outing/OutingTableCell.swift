import UIKit

class OutingTableCell: UITableViewCell {
    
    @IBOutlet private weak var _deleteBtnView: UIView!
    @IBOutlet private weak var _deleteBtn: CustomActivityButton!
    @IBOutlet private weak var _outingStatus: UILabel!
    @IBOutlet private weak var _cancelInvitationBtn: CustomActivityButton!
    @IBOutlet private weak var _createdDate: UILabel!
    @IBOutlet weak var _imInBtn: CustomActivityButton!
    @IBOutlet private weak var _imOutBtn: CustomActivityButton!
    @IBOutlet private weak var _imOutView: UIView!
    @IBOutlet private weak var _imInView: UIView!
    @IBOutlet private weak var _inOutStack: UIStackView!
    @IBOutlet private weak var _cancelBtn: UIView!
    @IBOutlet private weak var _invitedByTxt: UILabel!
    @IBOutlet private weak var _mainContainerView: UIView!
    @IBOutlet private weak var _statusTxt: UILabel!
    @IBOutlet private weak var _badgeView: UIView!
    @IBOutlet private weak var _editButton: UIButton!
    @IBOutlet private weak var _createdUserImage: UIImageView!
    @IBOutlet private weak var _createdUseNname: UILabel!
    @IBOutlet private weak var _coverImage: UIImageView!
    @IBOutlet private weak var _venueImage: UIImageView!
    @IBOutlet private weak var _venueName: UILabel!
    @IBOutlet private weak var _venueAddress: UILabel!
    @IBOutlet private weak var _dateLabel: UILabel!
    @IBOutlet private weak var _timeLabel: UILabel!
    @IBOutlet private weak var _messageLabel: UILabel!
    @IBOutlet private weak var _extraGuestLabel: UILabel!
    @IBOutlet private weak var _userCollection: CustomNoKeyboardCollectionView!
    private let kCellIdentifierStory = String(describing: SharedUsersCollectionCell.self)
    private var _outingListModel: OutingListModel?

    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    static var height: CGFloat { UITableView.automaticDimension }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        setupUi()
        DISPATCH_ASYNC_MAIN_AFTER(0.01) {
            self._mainContainerView.cornerRadius = 10
            self._badgeView.roundCorners(corners: [.bottomLeft, .topRight], radius: 10)
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func setupUi() {
        _userCollection.setup(cellPrototypes: _storyPrototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 5,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _userCollection.showsVerticalScrollIndicator = false
        _userCollection.showsHorizontalScrollIndicator = false
    }
    
    private var _storyPrototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifierStory, kCellNibNameKey: kCellIdentifierStory, kCellClassKey: SharedUsersCollectionCell.self, kCellHeightKey: SharedUsersCollectionCell.height]]
    }

    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        cellData.removeAll()
        
        _outingListModel?.invitedUser.forEach({ users in
            cellData.append([
                kCellIdentifierKey: kCellIdentifierStory,
                kCellTagKey: users.id,
                kCellObjectDataKey: users,
                kCellClassKey: SharedUsersCollectionCell.self,
                kCellHeightKey: SharedUsersCollectionCell.height
            ])
        })
                
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _userCollection.loadData(cellSectionData)
        _userCollection.reload()
    }
    
    // --------------------------------------
    // MARK: service
    // --------------------------------------

    private func _requestUpdateStatus(status: String) {
        let params: [String: Any] = ["inviteStatus": status , "outingId": _outingListModel?.id ?? "" ]
        if status == "in" {
            _imInBtn.setTitle(kEmptyString)
            _imInBtn.showActivity()
        } else {
            _imOutBtn.setTitle(kEmptyString)
            _imOutBtn.showActivity()
        }
        WhosinServices.requestInOut(params: params) { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container else { return }
            self.parentViewController?.showToast(data.message)
            self._imInBtn.hideActivity()
            self._imOutBtn.hideActivity()
            if status == "in" {
                self._deleteBtnView.isHidden = true
                self._cancelBtn.isHidden = true
                self._imInView.isHidden = true
                self._imOutView.isHidden = false
                self._imOutBtn.setTitle("cancel".localized())
            } else {
                self._cancelBtn.isHidden = true
                self._inOutStack.isHidden = false
                self._imInView.isHidden = false
                self._imOutView.isHidden = true
                self._imInBtn.setTitle("im_in".localized())
                self._deleteBtnView.isHidden = false
                self._deleteBtn.setTitle("delete_permanently".localized())
            }
            NotificationCenter.default.post(name: kReloadBucketList, object: nil, userInfo: nil)
        }
    }
    
    private func deleteInvitation() {
        guard let id = _outingListModel?.invitedId else { return }
        _deleteBtn.setTitle(kEmptyString)
        _deleteBtn.showActivity()
        WhosinServices.deleteInviteStatus(inviteId: id) { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container else { return }
            self._deleteBtn.hideActivity()
            self._deleteBtn.setTitle("delete_permanently".localized())
            self.parentViewController?.showToast(data.message)
            NotificationCenter.default.post(name:kReloadBucketList, object: nil, userInfo: nil)
        }
    }
    
    private func _manageStatus() {

        if let user = _outingListModel?.invitedUser.filter({ $0.userId == APPSESSION.userDetail?.id }).first {
            if user.inviteStatus == "out" {
                _inOutStack.isHidden = false
                _cancelBtn.isHidden = true
                _imInView.isHidden = false
                _imOutView.isHidden = true
                _deleteBtnView.isHidden = false
                self._deleteBtn.setTitle("delete_permanently".localized())
            } else if user.inviteStatus == "in" {
                _inOutStack.isHidden = false
                _cancelBtn.isHidden = true
                _imInView.isHidden = true
                _imOutView.isHidden = false
                _deleteBtnView.isHidden = true
                _imOutBtn.setTitle("cancel".localized())
            } else if user.inviteStatus == "pending" {
                _inOutStack.isHidden = false
                _cancelBtn.isHidden = true
                _imInView.isHidden = false
                _imOutView.isHidden = false
                _deleteBtnView.isHidden = true
                _imOutBtn.setTitle("im_out".localized())
            }
        }
    }
    
    private func _manageEventStatus(_ isOwner: Bool) {
        if let status = _outingListModel?.status {
            if status == "upcoming" {
                _cancelInvitationBtn.isHidden = false
                _cancelBtn.backgroundColor = .clear
                _cancelBtn.isHidden = !isOwner
                _inOutStack.isHidden = isOwner
                _editButton.isHidden = !isOwner
            } else if status == "cancelled" {
                _cancelBtn.isHidden = false
                _cancelBtn.backgroundColor = .clear
                _outingStatus.text = "cancelled".localized()
                _cancelInvitationBtn.isHidden = true
                _outingStatus.textColor = ColorBrand.brandBorderRed
                _inOutStack.isHidden = true
                _editButton.isHidden = true
            } else if status == "completed" {
                _cancelBtn.isHidden = false
                _cancelBtn.backgroundColor = .clear
                _cancelInvitationBtn.isHidden = true
                _outingStatus.text = "completed".localized()
                _outingStatus.textColor = ColorBrand.brandGreen
                _inOutStack.isHidden = true
                _editButton.isHidden = true
            }
        }
    }
    
    private func _requestCancelInvitaion(params: [String: Any]) {
        _cancelInvitationBtn.showActivity()
        WhosinServices.requestUpdateOuting(params: params) { [weak self] container, error in
            guard let self = self else { return }
            self._cancelInvitationBtn.hideActivity()
            self.parentBaseController?.showError(error)
            guard let data = container else { return }
            self.parentViewController?.showToast(data.message)
            DISPATCH_ASYNC_MAIN_AFTER(0.5) {
                self._inOutStack.isHidden = true
                self._cancelBtn.isHidden = false
                self._cancelBtn.backgroundColor = .clear
                self._cancelInvitationBtn.isHidden = true
            }

        }
    }
    
    private func _requestDelete() {
        parentBaseController?.confirmAlert(message: LANGMANAGER.localizedString(forKey: "delete_circle_alert", arguments: ["value": _outingListModel?.title ?? kEmptyString]), okHandler: { [weak self] action in
            guard let id = self?._outingListModel?.id else { return }
            WhosinServices.requestDeleteOuting(outingId: id) { [weak self] container, error in
                guard let self = self else { return }
                if let error = error {
                    self.parentBaseController?.showError(error)
                }
                guard let data = container?.data else  { return }
                NotificationCenter.default.post(name:kReloadBucketList, object: nil, userInfo: nil)
                DISPATCH_ASYNC_MAIN_AFTER(0.3) {
                }
            }
        })
        
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ model: OutingListModel) {
        _outingListModel = model
        _loadData()
        _extraGuestLabel.text = "\(model.extraGuest)"
        _editButton.isHidden = !model.isOwner
        if model.status == "cancelled" || model.status == "completed" {
            _badgeView.isHidden = false
        } else {
            _badgeView.isHidden = model.isOwner
        }
        _invitedByTxt.isHidden = model.isOwner
        _invitedByTxt.text = "invited_you_to".localized()
        if let user = model.owner {
            _createdUseNname.text = model.isOwner ? "you_created".localized() : user.firstName
            _createdUserImage.loadWebImage(user.image, name: user.fullName)
            _statusTxt.text = user.inviteStatus
        }
        _statusTxt.text = model.status
        self._mainContainerView.borderColor = model.borderColor
        self._mainContainerView.borderWidth = 2
        self._badgeView.backgroundColor = model.borderColor
    
        if let venue = model.venue {
            _venueName.text = venue.name
            _venueAddress.text = venue.address
            _venueImage.loadWebImage(venue.logo)
            _coverImage.loadWebImage(venue.cover)
        }
        _dateLabel.text = model._date
        _timeLabel.text = Utils.formatTimeRange(start: model.startTime, end: model.endTime)
        let create = Utils.stringToDate(model.createdAt, format: kStanderdDate)
        _createdDate.text = "created_date".localized() + "\(Utils.dateToString(create, format: kFormatEventDate))"
        _messageLabel.text = model.title
        _extraGuestLabel.text = "\(model.extraGuest)"
        _manageStatus()
        _manageEventStatus(model.isOwner)
    }
    
    private func transferOwnership() {
        let vc = INIT_CONTROLLER_XIB(TransferOwnershipBottomSheet.self)
        vc.isFromOuting = true
        vc.sharedWith = _outingListModel?.invitedUser.toArrayDetached(ofType: UserDetailModel.self) ?? []
        vc.outingId = _outingListModel?.id ?? kEmptyString
        parentViewController?.presentAsPanModal(controller: vc)
    }
    
    private func _openCancelInvitationActionSheet() {
        let alert = UIAlertController(title: kAppName, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "change_ownership".localized(), style: .default, handler: {action in
            DISPATCH_ASYNC_MAIN { self.transferOwnership() }
        }))
        alert.addAction(UIAlertAction(title: "cancel_invitation".localized(), style: .default, handler: {action in
            self._requestCancelInvitaion(params: ["status": "cancelled" , "outingId": self._outingListModel?.id ?? "" ])
        }))
        alert.addAction(UIAlertAction(title: "delete_invitation".localized(), style: .default, handler: {action in
            self._requestDelete()
        }))

        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: { _ in }))
        parentViewController?.present(alert, animated: true)
    }
    
    private func _deleteAlert() {
        self.parentBaseController?.showCustomAlert(title: kAppName, message: "delete_outing_permanently".localized(), yesButtonTitle: "yes".localized(), noButtonTitle: "cancel".localized(), okHandler: { UIAlertAction in
            DISPATCH_ASYNC_MAIN { self.deleteInvitation() }
        }, noHandler:  { UIAlertAction in
        })
    }
    
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
    @IBAction private func _handleEditEvent(_ sender: UIButton) {
        let controler = INIT_CONTROLLER_XIB(InviteBottomSheet.self)
        controler.outingModel = _outingListModel
        controler._selectedOffer = _outingListModel?.offer
        let navController = NavigationController(rootViewController: controler)
        navController.modalPresentationStyle = .custom
        parentBaseController?.present(navController, animated: true)
    }
    
    @IBAction private func _handleCancelInvitationEvent(_ sender: UIButton) {
        _openCancelInvitationActionSheet()
    }
    
    @IBAction private func _handleInEvent(_ sender: UIButton) {
        _requestUpdateStatus(status: "in")
    }
    
    @IBAction private func _handleOutStatusEvent(_ sender: Any) {
        _requestUpdateStatus(status: "out")
    }
    
    @IBAction private func _handleDeleteEvent(_ sender: CustomActivityButton) {
        _deleteAlert()
    }
    
    @IBAction private func _handleSeeAllUserEvent(_ sender: UIButton) {
        if _outingListModel?._invitedUser.isEmpty == false {
            let presentedViewController = INIT_CONTROLLER_XIB(EventGuestListBottomSheet.self)
            presentedViewController.isFromOuting = true
            presentedViewController._userList = _outingListModel?._invitedUser
            presentedViewController.userOpenCallBack = { userId in
                let vc = INIT_CONTROLLER_XIB(UsersProfileVC.self)
                vc.contactId = userId
                self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
            }
            presentedViewController.openChatCallBack = { chatModel in
                let vc = INIT_CONTROLLER_XIB(ChatDetailVC.self)
                vc.hidesBottomBarWhenPushed = true
                vc.chatModel = chatModel
                self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
            }
            parentViewController?.presentAsPanModal(controller: presentedViewController)
        }
    }
    
}

extension OutingTableCell: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? SharedUsersCollectionCell,let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
        cell.setupData(object, inviteStatus: false)
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
        guard let userDetail = APPSESSION.userDetail else { return }
        if object.id != userDetail.id {
            if object.isPromoter, userDetail.isRingMember {
                let vc = INIT_CONTROLLER_XIB(PromoterPublicProfileVc.self)
                vc.promoterId = object.id
                vc.isFromPersonal = true
                parentViewController?.navigationController?.pushViewController(vc, animated: true)
            } else if object.isRingMember, userDetail.isPromoter {
                let vc = INIT_CONTROLLER_XIB(ComplementaryPublicProfileVC.self)
                vc.complimentryId = object.id
                vc.isFromPersonal = true
                parentViewController?.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = INIT_CONTROLLER_XIB(UsersProfileVC.self)
                vc.contactId = object.id
                parentViewController?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        CGSize(width: 40, height: SharedUsersCollectionCell.height)
    }
}
