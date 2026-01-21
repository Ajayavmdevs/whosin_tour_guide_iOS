import UIKit

class SuggestedFriendCollectionCell: UICollectionViewCell {

    @IBOutlet weak var _mainView: UIView!
    @IBOutlet weak var _userImage: UIImageView!
    @IBOutlet weak var _nameLabel: UILabel!
    @IBOutlet weak var _followBtn: CustomActivityButton!
    private var userModel: UserDetailModel?
    public var closeUserCallBack: ((_ id: String) -> Void)?

    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat { 160 }

    // --------------------------------------
    // MARK: Life-Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(_handleFollowStatusEvent(_:)), name: kReloadFollowStatus, object: nil)
    }
    
    @objc func _handleFollowStatusEvent(_ notification: Notification) {
        guard let model = notification.object as? UserDetailModel else { return }
        if model.id == userModel?.id {
            userModel?.follow = model.status
            updateButtonAppearance(model.status)
        }
    }

    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ model: UserDetailModel) {
        userModel = model
        _userImage.loadWebImage(model.image, name: model.fullName)
        _nameLabel.text = model.fullName
        updateButtonAppearance(model.follow)
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func _requestFollowUnFollow() {
        _followBtn.setTitle(kEmptyString)
        _followBtn.showActivity()
        guard let user = userModel else { return }
        WhosinServices.userFollow(id: user.id) { [weak self] container, error in
            guard let self = self else { return }
            self.parentBaseController?.showError(error)
            self._followBtn.hideActivity()
            guard let data = container?.data else { return }
            self.userModel?.follow = data.status
            self._showMessage(status: data.status, name: userModel?.fullName ?? kEmptyString)
            data.id = user.id
            NotificationCenter.default.post(name: kReloadFollowStatus, object: data, userInfo: nil)
            
        }
    }
    
    private func _requestRemove(_ id: String) {
        WhosinServices.removeSuggested(type: "user", typeId: id) { [weak self] container, error in
            guard let self = self else { return }
            self.parentBaseController?.showError(error)
        }
    }
    
    private func _requestChat() {
        guard let user = userModel else { return }
        guard let userDetail = APPSESSION.userDetail else { return }
        let chatModel = ChatModel()
        chatModel.image = user.image
        chatModel.title = user.fullName
        chatModel.chatType = "friend"
        chatModel.members.append(user.id)
        chatModel.members.append(userDetail.id)
        let chatIds = [user.id, userDetail.id].sorted()
        chatModel.chatId = chatIds.joined(separator: ",")
        let vc = INIT_CONTROLLER_XIB(ChatDetailVC.self)
        vc.chatModel = chatModel
        vc.hidesBottomBarWhenPushed = true
        self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func updateButtonAppearance(_ status: String) {
        _followBtn.borderColor = .white
        switch status {
        case "approved":
            _followBtn.setTitle("following".localized(), for: .normal)
            _followBtn.backgroundColor = .clear
            _followBtn.borderWidth = 1
        case "pending":
            _followBtn.setTitle("requested".localized(), for: .normal)
            _followBtn.backgroundColor = .clear
            _followBtn.borderWidth = 1
        case "cancelled":
            _followBtn.setTitle("follow".localized(), for: .normal)
            _followBtn.backgroundColor = ColorBrand.brandPink
            _followBtn.borderWidth = 0
        default:
            _followBtn.setTitle("follow".localized(), for: .normal)
            _followBtn.backgroundColor = ColorBrand.brandPink
            _followBtn.borderWidth = 0
        }

    }
    
    private func _showMessage(status: String, name: String) {
        _followBtn.borderColor = .white
        switch status {
        case "approved":
            _followBtn.setTitle("following".localized(), for: .normal)
            _followBtn.backgroundColor = .clear
            _followBtn.borderWidth = 1
            self.parentBaseController?.showSuccessMessage("thank_you".localized(), subtitle: LANGMANAGER.localizedString(forKey: "following_toast", arguments: ["value": name]) )
        case "pending":
            _followBtn.setTitle("requested".localized(), for: .normal)
            _followBtn.backgroundColor = .clear
            _followBtn.borderWidth = 1
            self.parentBaseController?.showSuccessMessage("thank_you".localized() , subtitle: LANGMANAGER.localizedString(forKey: "request_toast", arguments: ["value": name]))
        case "cancelled":
            _followBtn.setTitle("follow".localized(), for: .normal)
            _followBtn.backgroundColor = ColorBrand.brandPink
            _followBtn.borderWidth = 0
            self.parentBaseController?.showSuccessMessage("oh_snap".localized(), subtitle: LANGMANAGER.localizedString(forKey: "unfollow_toast", arguments: ["value": name]))
        default:
            _followBtn.setTitle("follow".localized(), for: .normal)
            _followBtn.backgroundColor = ColorBrand.brandPink
            _followBtn.borderWidth = 0
            self.parentBaseController?.showSuccessMessage("oh_snap".localized(), subtitle: LANGMANAGER.localizedString(forKey: "unfollow_toast", arguments: ["value": name]))
        }
    }

    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @IBAction private func _handleFollowEvent(_ sender: CustomActivityButton) {
            _requestFollowUnFollow()
    }
    
        
    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        guard let id = userModel?.id else { return }
        _requestRemove(id)
        closeUserCallBack?(id)
    }
    
}
