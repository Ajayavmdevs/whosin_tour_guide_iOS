
import UIKit

class OutingWhosinCell: UITableViewCell {

    @IBOutlet weak var _chatBtnView: UIView!
    @IBOutlet weak var _deleteBtn: CustomActivityButton!
    @IBOutlet weak var _deleteView: UIView!
    @IBOutlet weak var _outView: UIView!
    @IBOutlet weak var _cancelledTxt: UILabel!
    @IBOutlet weak var _cancelledView: UIView!
    @IBOutlet weak var _cancelInvitationBtn: CustomActivityButton!
    @IBOutlet weak var _imInBtn: CustomActivityButton!
    @IBOutlet weak var _imOutBtn: CustomActivityButton!
    @IBOutlet weak var _imInView: UIView!
    @IBOutlet weak var _inOutStack: UIStackView!
    @IBOutlet weak var _cancelBtn: CustomActivityButton!
    @IBOutlet weak var _extraGuestLabel: UILabel!
    @IBOutlet weak var _userCollection: CustomCollectionView!
    private let kCellIdentifierStory = String(describing: SharedUsersCollectionCell.self)
    private var _outingListModel: OutingListModel?
    var callback: (() -> Void)?

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
    }
    
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


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
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
            DISPATCH_ASYNC_MAIN_AFTER(0.1) {
                if status == "in" {
                    self._cancelBtn.isHidden = true
                    self._imInView.isHidden = true
                    self._outView.isHidden = false
                    self._imOutBtn.setTitle("cancel".localized())
                    self._deleteView.isHidden = true
                } else {
                    self._cancelBtn.isHidden = true
                    self._inOutStack.isHidden = false
                    self._imInView.isHidden = false
                    self._outView.isHidden = true
                    self._imInBtn.setTitle("im_in".localized())
                    self._deleteView.isHidden = false
                    self._deleteBtn.setTitle("delete_permanently".localized())
                }
                NotificationCenter.default.post(name:kReloadBucketList, object: nil, userInfo: nil)
            }

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
            self.parentViewController?.showToast(data.message)
            DISPATCH_ASYNC_MAIN_AFTER(0.5) {
                self.parentViewController?.navigationController?.popViewController(animated: true)
                NotificationCenter.default.post(name:kReloadBucketList, object: nil, userInfo: nil)
            }
        }
    }
    
    private func _requestCancelInvitaion(params: [String: Any]) {
        _cancelInvitationBtn.showActivity()
        WhosinServices.requestUpdateOuting(params: params) { [weak self] container, error in
            guard let self = self else { return }
            self._cancelInvitationBtn.hideActivity()
            guard let data = container else { return }
            self.parentViewController?.showToast(data.message)
            DISPATCH_ASYNC_MAIN_AFTER(1) {
                self._cancelledView.isHidden = false
                self._cancelBtn.isHidden = true
                self._inOutStack.isHidden = true
                self._cancelledTxt.text = "cancelled".localized()
                self._cancelledTxt.textColor = ColorBrand.brandBorderRed
                NotificationCenter.default.post(name:kReloadBucketList, object: nil, userInfo: nil)
            }

        }
    }
    
    private func _requestDelete() {
        parentBaseController?.confirmAlert(message: "Are_you_sure_delete_invitation".localized(), okHandler: { [weak self] action in
            guard let id = self?._outingListModel?.id else { return }
            WhosinServices.requestDeleteOuting(outingId: id) { [weak self] container, error in
                guard let self = self else { return }
                if let error = error {
                    self.parentBaseController?.showError(error)
                }
                guard let data = container?.data else  { return }
                NotificationCenter.default.post(name:kReloadBucketList, object: nil, userInfo: nil)
                DISPATCH_ASYNC_MAIN_AFTER(0.3) {
                    self.callback?()
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
        let endDate = "\(model.date) \(model.endTime)"
        if Utils.isDateExpired(dateString: endDate , format: kFormatDateTimeLocal) {
            _chatBtnView.isHidden = true
        } else {
            _chatBtnView.isHidden = false
        }

        if let user = model.invitedUser.filter({ $0.userId == APPSESSION.userDetail?.id ?? kEmptyString }).first {
           if user.inviteStatus == "in" {
               _cancelledView.isHidden = true
                _imInView.isHidden = true
               _imOutBtn.isHidden = false
               _deleteView.isHidden = true
                _imOutBtn.setTitle("cancel".localized())
            } else if user.inviteStatus == "pending" {
                self._cancelledView.isHidden = true
                _imInView.isHidden = false
                _deleteView.isHidden = true
            } else {
                self._cancelledView.isHidden = true
                _inOutStack.isHidden = false
                _outView.isHidden = true
                _deleteView.isHidden = false
                _deleteBtn.setTitle("delete_permanently".localized())
            }
        }
        if model.status == "cancelled" {
            _cancelledView.isHidden = false
            _cancelBtn.isHidden = true
            _inOutStack.isHidden = true
            _cancelledTxt.textColor = ColorBrand.brandBorderRed
        } else if model.status == "upcoming" {
            if let userDetail = APPSESSION.userDetail, model.userId == userDetail.id {
                _cancelBtn.isHidden = false
                _cancelledView.isHidden = true
                _inOutStack.isHidden = true
            } else {
                _cancelBtn.isHidden = true
                _cancelledView.isHidden = true
                _inOutStack.isHidden = false
            }
        } else {
            _cancelledView.isHidden = false
            _cancelBtn.isHidden = true
            _inOutStack.isHidden = true
            _cancelledTxt.text = "completed".localized()
            _cancelledTxt.textColor = ColorBrand.brandGreen
        }
        _extraGuestLabel.text = "\(model.extraGuest)"
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
        let alert = UIAlertController(title: kAppName, message: "delete_outing_permanently".localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "yes".localized(), style: .default, handler: {action in
            DISPATCH_ASYNC_MAIN { self.deleteInvitation() }
        }))
        alert.addAction(UIAlertAction(title: "no".localized(), style: .cancel, handler: { _ in }))
        parentViewController?.present(alert, animated: true)
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
    @IBAction private func _handleCancelInvitaion(_ sender: UIButton) {
        _openCancelInvitationActionSheet()
    }
    
    @IBAction private func _handleInEvent(_ sender: UIButton) {
        _requestUpdateStatus(status: "in")
    }
    
    @IBAction private func _handleOutEvent(_ sender: UIButton) {
        _requestUpdateStatus(status: "out")
    }
    
    @IBAction func _handleDeletePermanantEvent(_ sender: CustomActivityButton) {
        _deleteAlert()
    }
    
    @IBAction func _handleGroupChatEvent(_ sender: CustomActivityButton) {
        guard let outing = _outingListModel else { return }
        let _tmpChatModel = ChatModel()
        _tmpChatModel.chatId = outing.id
        _tmpChatModel.title = outing.chatName
        _tmpChatModel.image = outing.venue?.cover ?? kEmptyString
        _tmpChatModel.chatType = "outing"
        let users = outing.invitedUser.map({ $0.id })
        _tmpChatModel.members.append(objectsIn: users)
        if !_tmpChatModel.members.contains(where: {$0 == outing.userId}) {
            _tmpChatModel.members.append(outing.userId)
        }
        if let userDetail = APPSESSION.userDetail {
            if !_tmpChatModel.members.contains(where: { $0 == userDetail.id }) {
                _tmpChatModel.members.append(userDetail.id)
            }
        }
        let vc = INIT_CONTROLLER_XIB(ChatDetailVC.self)
        vc.chatType = .outing
        vc.chatModel = _tmpChatModel
        vc.outingmodel = _outingListModel
        vc.hidesBottomBarWhenPushed = true
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction private func _handleSeeAllUserEvent(_ sender: UIButton) {
        if _outingListModel?._invitedUser.isEmpty == false {
            let presentedViewController = INIT_CONTROLLER_XIB(EventGuestListBottomSheet.self)
            presentedViewController.isFromOuting = true
            presentedViewController._userList = _outingListModel?._invitedUser
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

extension OutingWhosinCell: CustomCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? SharedUsersCollectionCell,let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
        cell.setupData(object, inviteStatus: false)
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        CGSize(width: 40, height: SharedUsersCollectionCell.height)
    }
}


extension OutingWhosinCell: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomBottomSheet(presentedViewController: presented, presenting: presenting)
    }
}
