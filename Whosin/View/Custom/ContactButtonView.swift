import Foundation
import UIKit
import SnapKit


class ContactButtonView: UIView {
    
    @IBOutlet weak var _optionBtn: UIButton!
    @IBOutlet weak var _chatBtn: UIButton!
    @IBOutlet weak var _chatOptionStack: UIStackView!
    @IBOutlet weak var _followBtn: CustomActivityButton!
    @IBOutlet weak var _bgView: UIView!
    private var userModel: UserDetailModel?
    public var openChatCallBack: ((_ chatModel: ChatModel) -> Void)?
    public var callBack: ((_ status: String) -> Void)?
    var isinvite: Bool = false
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat {
        return 75
    }
    
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
    
    @objc func _handleFollowStatusEvent(_ notification: Notification) {
        guard let model = notification.object as? UserDetailModel else { return }
        print("user : ", userModel?.id , " event : ", model.id)
        if model.id == userModel?.id {
            userModel?.follow = model.status
            updateButtonAppearance(model.status)
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func _setupUi() {
        if let view = Bundle.main.loadNibNamed("ContactButtonView", owner: self, options: nil)?.first as? UIView {
            addSubview(view)
            view.snp.makeConstraints { make in
                make.height.equalTo(ContactButtonView.height)
                make.leading.trailing.top.bottom.equalToSuperview()
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(_handleFollowStatusEvent(_:)), name: kReloadFollowStatus, object: nil)
    }
    
    public func setupData(model: UserDetailModel) {
        userModel = model
        updateButtonAppearance(model.follow)
    }
    
    @IBAction func _handleFollowEvent(_ sender: CustomActivityButton) {
        _requestFollowUnFollow()
    }
    
    @IBAction private func _handleChatEvent(_ sender: UIButton) {
        guard let userDetail = APPSESSION.userDetail else { return }
        guard let model = userModel else { return }
        let chatModel = ChatModel()
        chatModel.image = model.image
        chatModel.title = model.fullName
        chatModel.chatType = "friend"
        chatModel.members.append(model.id)
        chatModel.members.append(userDetail.id)
        let chatIds = [model.id, Preferences.isSubAdmin ? userDetail.promoterId : userDetail.id].sorted()
        chatModel.chatId = chatIds.joined(separator: ",")
        if let pv = parentViewController?.navigationController {
            let vc = INIT_CONTROLLER_XIB(ChatDetailVC.self)
            vc.chatModel = chatModel
            vc.hidesBottomBarWhenPushed = true
            self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
        } else {
            openChatCallBack?(chatModel)
        }
    }
    
    @IBAction private func _handleOptionsButtonEvent(_ sender: UIButton) {
        _openActionSheet()
    }

    // --------------------------------------
    // MARK: Service
    // --------------------------------------

    private func _requestFollowUnFollow() {
        _followBtn.setTitle(kEmptyString)
        _followBtn.showActivity()
        guard let model = userModel else { return }
        WhosinServices.userFollow(id: model.id) { [weak self] container, error in
            guard let self = self else { return }
            self.parentBaseController?.showError(error)
            self._followBtn.hideActivity()
            guard let data = container?.data else { return }
            self.updateButtonAppearance(data.status)
            self.callBack?(data.status)
            self._showMessage(status: data.status, name: model.fullName)
            data.id = model.id
            NotificationCenter.default.post(name: kReloadFollowStatus, object: data, userInfo: nil)
        }
    }
    
    private func updateButtonAppearance(_ status: String) {
        switch status {
        case "approved", "Followed!" :
            self._followBtn.setTitle("following".localized())
            self._followBtn.isHidden = true
            self._chatOptionStack.isHidden = isinvite
        case "pending", "Requested" :
            self._followBtn.setTitle("requested".localized())
            self._followBtn.isHidden = false
            self._chatOptionStack.isHidden = true
        case "cancelled", "Unfollowed!" :
            self._followBtn.setTitle("follow".localized())
            self._chatOptionStack.isHidden = true
            self._followBtn.isHidden = false
        default:
            self._followBtn.setTitle("follow".localized())
            self._chatOptionStack.isHidden = true
            self._followBtn.isHidden = false
        }
    }

    
    private func _showMessage(status: String, name: String) {
        switch status {
        case "approved", "Followed!" :
            self.parentBaseController?.showSuccessMessage("thank_you".localized(), subtitle: LANGMANAGER.localizedString(forKey: "following_toast", arguments: ["value": name]) )
        case "pending", "Requested" :
            self.parentBaseController?.showSuccessMessage("thank_you".localized() , subtitle: LANGMANAGER.localizedString(forKey: "request_toast", arguments: ["value": name]))
        case "cancelled", "Unfollowed!" :
            self.parentBaseController?.showSuccessMessage("oh_snap".localized(), subtitle: LANGMANAGER.localizedString(forKey: "unfollow_venue", arguments: ["value": name]))
        default:
            self.parentBaseController?.showSuccessMessage("oh_snap".localized(), subtitle: LANGMANAGER.localizedString(forKey: "unfollow_venue", arguments: ["value": name]))
        }
    }

    private func _requestBlockUser(blockId: String, name: String) {
        WhosinServices.userBlock(id: blockId) { [weak self] container, error in
            guard let self = self else { return }
            self.parentBaseController?.showError(error)
            NotificationCenter.default.post(name: kReloadContacts, object: nil, userInfo: nil)
            if !Preferences.blockedUsers.contains(blockId) {
                Preferences.blockedUsers.append(blockId)
            }
            self.parentBaseController?.showSuccessMessage("oh_snap".localized(), subtitle: "You have blocked \(name)")
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func _openActionSheet() {
        guard let model = userModel else { return }
        let alert = UIAlertController(title: kAppName, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Unfollow", style: .default, handler: {action in
            DISPATCH_ASYNC_MAIN { self._requestFollowUnFollow() }
        }))
        alert.addAction(UIAlertAction(title: "Block", style: .destructive, handler: {action in
            DISPATCH_ASYNC_MAIN {
                self.parentBaseController?.showCustomAlert(title: kAppName, message: "Are you sure you want to block \(model.fullName) ?", yesButtonTitle: "ok".localized(), noButtonTitle: "cancel".localized(), okHandler: { UIAlertAction in
                    self._requestBlockUser(blockId: model.id, name: model.fullName)
                }, noHandler:  { UIAlertAction in
                })
            }
        }))
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: { _ in }))
        parentViewController?.present(alert, animated: true)
    }

    
}

