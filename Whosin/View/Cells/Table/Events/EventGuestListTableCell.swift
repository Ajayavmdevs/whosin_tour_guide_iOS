import UIKit

class EventGuestListTableCell: UITableViewCell {

    @IBOutlet weak var _contactBtnView: ContactButtonView!
    @IBOutlet private weak var _userDetail: UILabel!
    @IBOutlet private weak var _statusImageView: UIImageView!
    @IBOutlet private weak var _userImage: UIImageView!
//    @IBOutlet weak var _folllowbtn: CustomActivityButton!
    @IBOutlet private weak var _userName: UILabel!
//    @IBOutlet private weak var _followOptionsStack: UIStackView!
    private var userModel: UserModel?
    private var userId: String = kEmptyString
    private var userImage: String = kEmptyString
    public var chatOpenCallBack: ((_ chatModel: ChatModel) -> Void)?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat {
        65.0
    }
    
    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
//        _folllowbtn.setTitle("Follow")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func prepareForReuse() {
        _userImage.image = nil
//        _folllowbtn.isHidden = true
//        _followOptionsStack.isHidden = true
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupInvitationData(_ data: InvitationModel?, userModel: UserDetailModel, isFromOuting: Bool = false) {
        let user = userModel
        userId = user.id

        _userImage.loadWebImage(user.image, name: user.firstName)
        userImage = user.image
        _userName.text = "\(user.firstName) \(user.lastName)"
        if user.firstName == kEmptyString {
//            _folllowbtn.isHidden = true
            _contactBtnView.isHidden = true
        }
        if isFromOuting {
            _userDetail.text = userModel.inviteStatus
            if userModel.inviteStatus == "pending" {
                _statusImageView.image = UIImage(named: "icon_statusPending")
                _userDetail.textColor = .yellow
            } else if userModel.inviteStatus == "out" {
                _statusImageView.image = UIImage(named: "icon_statusOut")
                _userDetail.textColor = .red
            } else if userModel.inviteStatus == "in" {
                _statusImageView.image = UIImage(named: "icon_statusIn")
                _userDetail.textColor = .green
            }
        } else {
            guard let data = data else { return }
            _userDetail.text = data.inviteStatus
            if data.inviteStatus == "pending" {
                _statusImageView.image = UIImage(named: "icon_statusPending")
                _userDetail.textColor = .yellow
            } else if data.inviteStatus == "out" {
                _statusImageView.image = UIImage(named: "icon_statusOut")
                _userDetail.textColor = .red
            } else if data.inviteStatus == "in" {
                _statusImageView.image = UIImage(named: "icon_statusIn")
                _userDetail.textColor = .green
            }
        }
        _contactBtnView.setupData(model: userModel)
        _contactBtnView.openChatCallBack = { model in
            self.chatOpenCallBack?(model)
        }
//        if user.follow == "approved" {
//            _folllowbtn.isHidden = true
//            _followOptionsStack.isHidden = false
//        } else if user.follow == "pending" {
//            _folllowbtn.isHidden = false
//            _folllowbtn.setTitle("Pending")
//            _followOptionsStack.isHidden = true
//        } else {
//            _folllowbtn.isHidden = false
//            _followOptionsStack.isHidden = true
//        }

        if user.id == APPSESSION.userDetail?.id {
            _contactBtnView.isHidden = true
//            _folllowbtn.isHidden = true
//            _followOptionsStack.isHidden = true
        }
    }
    
    public func setupShoutoutData(_ data: UserDetailModel) {
        userId = data.id
        _userImage.loadWebImage(data.image, name: data.firstName)
        userImage = data.image
        
        _userName.text = "\(data.firstName) \(data.lastName)"
        if data.firstName == kEmptyString {
            _contactBtnView.isHidden = true
        }
        _userDetail.isHidden = true
        
//        if data.follow == "approved" {
//            _folllowbtn.isHidden = true
//            _followOptionsStack.isHidden = false
//        } else if data.follow == "pending" {
//            _folllowbtn.isHidden = false
//            _folllowbtn.setTitle("Pending")
//            _followOptionsStack.isHidden = true
//        } else {
//            _folllowbtn.isHidden = false
//            _followOptionsStack.isHidden = true
//        }

    }
    
    public func setupMutualFriends(userModel: UserDetailModel) {
        userId = userModel.id
        _userImage.loadWebImage(userModel.image, name: userModel.firstName)
        userImage = userModel.image
        _userName.text = "\(userModel.firstName) \(userModel.lastName)"
        if userModel.firstName == kEmptyString {
            _contactBtnView.isHidden = true
        }
        _contactBtnView.isHidden = false
        _userDetail.isHidden = true
        _contactBtnView.setupData(model: userModel)
        _contactBtnView.openChatCallBack = { model in
            self.chatOpenCallBack?(model)
        }

//        _folllowbtn.isHidden = true
//        _followOptionsStack.isHidden = false
        if userModel.id == APPSESSION.userDetail?.id {
            _contactBtnView.isHidden = true
//            _folllowbtn.isHidden = true
//            _followOptionsStack.isHidden = true
        }
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
//    private func _requestBlockUser(blockId: String) {
//        WhosinServices.userBlock(id: blockId) { [weak self] container, error in
//            guard let self = self else { return }
//            self.parentBaseController?.showSuccessMessage("Oh Snap!", subtitle: "You have blocked \(self._userName.text ?? kEmptyString)")
//        }
//    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
//    private func _openActionSheet() {
//        let alert = UIAlertController(title: kAppName, message: nil, preferredStyle: .actionSheet)
//        alert.addAction(UIAlertAction(title: "Unfollow", style: .default, handler: {action in
//            DISPATCH_ASYNC_MAIN { self._requestFollowUnfollow() }
//        }))
//
//        alert.addAction(UIAlertAction(title: "Block", style: .destructive, handler: {action in
//            DISPATCH_ASYNC_MAIN {
//                let alertController = UIAlertController(title: kAppName, message: "Are you sure you want to block \(self._userName.text ?? kEmptyString)?", preferredStyle: .alert)
//
//                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//                alertController.addAction(cancelAction)
//
//                let yesAction = UIAlertAction(title: "Yes", style: .destructive) { (_) in
//                    self._requestBlockUser(blockId: self.userId)
//                }
//                alertController.addAction(yesAction)
//
//                self.parentViewController?.present(alertController, animated: true, completion: nil)
//            }
//        }))
//
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in }))
//        parentViewController?.present(alert, animated: true)
//
//    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------

//    @IBAction private func _handleChatEvent(_ sender: UIButton) {
//        _requestCreateChat()
//    }
    
//    @IBAction private func _handleMoreEvent(_ sender: UIButton) {
//        _openActionSheet()
//    }
    
//    @IBAction func _handleFollowEvent(_ sender: CustomActivityButton) {
//        _requestFollowUnfollow()
//    }

}
