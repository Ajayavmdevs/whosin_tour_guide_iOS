protocol userInfoDelegate: AnyObject {
    func bioReload(isRequest: Bool)
}

import UIKit
import ExpandableLabel

class UserInfoTableCell: UITableViewCell {

    @IBOutlet weak var _premiumeView: UIView!
    @IBOutlet weak var _deleteBtn: CustomActivityButton!
    @IBOutlet weak var _confirmBtn: CustomActivityButton!
    @IBOutlet weak var _requestTxt: UILabel!
    @IBOutlet weak var _requestView: UIView!
    weak var delegate: userInfoDelegate?
    @IBOutlet weak var _vipimageView: UIImageView!
    @IBOutlet private weak var _userImage: UIImageView!
    @IBOutlet private weak var _userName: UILabel!
    @IBOutlet private weak var _followers: UILabel!
    @IBOutlet private weak var _following: UILabel!
    @IBOutlet private weak var _bioText: ExpandableLabel!
    @IBOutlet private var _imageViews: [UIImageView]!
    @IBOutlet private weak var _followedByText: UILabel!
    @IBOutlet private weak var _mutualStack: UIStackView!
//    @IBOutlet weak var _followButton: CustomActivityButton!
    @IBOutlet weak var _customFollowBtn: CustomFollowButton!
    private var _follow: String = kEmptyString
    private var _userId: String = kEmptyString
    private var _userData: UserDetailModel?
    private var _mutualFriends: [UserDetailModel] = []
    public var followStateCallBack: ((_ follow: String) -> Void)?
    
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
        _premiumeView.cornerRadius = _premiumeView.frame.height / 2
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        _bioText.isUserInteractionEnabled = true
        _bioText.addGestureRecognizer(tapGesture)
        _bioText.delegate = self
        _bioText.shouldCollapse = true
        _bioText.numberOfLines = 2
        _bioText.ellipsis = NSAttributedString(string: "...")
        _bioText.collapsedAttributedLink = NSAttributedString(string: "more".localized(), attributes: [NSAttributedString.Key.foregroundColor: ColorBrand.brandPink])
        _bioText.setLessLinkWith(lessLink: "less".localized(), attributes: [NSAttributedString.Key.foregroundColor: ColorBrand.brandPink], position: .left)
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self._openMutualFreindsList))
        self._mutualStack.addGestureRecognizer(gesture)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(openProfile(_:)))
        _userImage.addGestureRecognizer(tap)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _acceptRejectEvent(_ status: String) {
        WhosinServices.acceptRejectReques(id: _userId, status: status) { [weak self] container, error in
            guard let self = self else { return }
            self.parentBaseController?.showError(error)
            self._confirmBtn.hideActivity()
            self._deleteBtn.hideActivity()
            guard let data = container else { return }
            self._requestView.isHidden = true
            self.superview?.layoutIfNeeded()
            self.superview?.layoutSubviews()
            self.superview?.setNeedsLayout()
            self.delegate?.bioReload(isRequest: true)
        }
    }
    
    private func _requestBlockUser(blockId: String) {
        WhosinServices.userBlock(id: blockId) { [weak self] container, error in
            guard let self = self else { return }
            self.parentBaseController?.showSuccessMessage("oh_snap".localized(), subtitle: "You have blocked \(self._userData?.fullName ?? kEmptyString)")
            if !Preferences.blockedUsers.contains(blockId) {
                Preferences.blockedUsers.append(blockId)
            }
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ data: UserDetailModel) {
        _requestView.isHidden = !data.isRequestPending
        _requestTxt.text = LANGMANAGER.localizedString(forKey: "want_to_follow_you", arguments: ["value": data.fullName])
        _userId = data.id
        _userData = data
        _mutualFriends = data.mutualFriends.toArrayDetached(ofType: UserDetailModel.self).filter{$0.isValid()}
        setImagesViews()
        _userImage.loadWebImage(data.image, name: data.firstName)
        _userName.text = data.fullName
        _followers.text = String(data.follower)
        _following.text = String(data.following)
        _follow = data.follow
        if data.isVip {
            _vipimageView.isHidden = false
            _premiumeView.isHidden = true
        } else if data.isMembershipActive {
            _vipimageView.isHidden = true
            _premiumeView.isHidden = false
        } else {
            _vipimageView.isHidden = true
            _premiumeView.isHidden = true
        }
//        _vipimageView.isHidden = !data.isVip
        _customFollowBtn.setupData(data, isFillColor: false, font: FontBrand.SFmediumFont(size: 16)) { isFollowing in
            self.followStateCallBack?(isFollowing)
        }
//        if _follow == "approved" {
//            _followButton.setTitle("Following")
//        } else if _follow == "pending" {
//            _followButton.setTitle("Pending")
//        } else {
//            _followButton.setTitle("Follow")
//        }
        _bioText.isHidden = Utils.stringIsNullOrEmpty(data.bio)
        _bioText.text = data.bio
    }
    
//    private func _openActionSheet() {
//        let alert = UIAlertController(title: kAppName, message: nil, preferredStyle: .actionSheet)
//        if _follow == "approved" {
//        alert.addAction(UIAlertAction(title: "Unfollow", style: .default, handler: {action in
//            DISPATCH_ASYNC_MAIN { self._handleFollowEvent() }
//        }))
//        } else if _follow == "pending" {
//        } else {
//            alert.addAction(UIAlertAction(title: "Follow", style: .default, handler: {action in
//                DISPATCH_ASYNC_MAIN { self._handleFollowEvent() }
//            }))
//        }
//
//        alert.addAction(UIAlertAction(title: "Block", style: .destructive, handler: {action in
//            DISPATCH_ASYNC_MAIN {
//                let alertController = UIAlertController(title: kAppName, message: "Are you sure you want to block \(self._userData?.fullName ?? kEmptyString)?", preferredStyle: .alert)
//                
//                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//                alertController.addAction(cancelAction)
//                
//                let yesAction = UIAlertAction(title: "Yes", style: .destructive) { (_) in
//                    self._requestBlockUser(blockId: self._userId)
//                }
//                alertController.addAction(yesAction)
//                
//                self.parentViewController?.present(alertController, animated: true, completion: nil)
//            }
//        }))
//        
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in }))
//        self.parentViewController?.present(alert, animated: true)
//    }
    
    private func setImagesViews() {
        var followdbytxt: [String] = []
        for i in 0..<4 {
            if i < _mutualFriends.count {
                _imageViews[i].loadWebImage(_mutualFriends[i].image, name: _mutualFriends[i].fullName)
                followdbytxt.append(_mutualFriends[i].firstName)
            } else {
                _imageViews[i].isHidden = true
            }
        }
        
        if _mutualFriends.count > 4 {
            _followedByText.text = "followed_by".localized() + followdbytxt.joined(separator: ", ") + " and \(_mutualFriends.count - 4) others"
        } else {
            _followedByText.text = "followed_by".localized() + followdbytxt.joined(separator: ", ")
        }
        
        _mutualStack.isHidden = _mutualFriends.count == 0
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @objc private func labelTapped() {
        _bioText.collapsed.toggle()
        _bioText.superview?.setNeedsLayout()
        _bioText.superview?.layoutIfNeeded()
        delegate?.bioReload(isRequest: false)
    }
    
    @IBAction func _handleFollowerListEvent(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(FollowListVC.self)
        vc.isFollowerList = true
        vc.followId = _userId
        self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func _handleFollowingListEvent(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(FollowListVC.self)
        vc.isFollowerList = false
        vc.followId = _userId
        self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func _handleConfirmEvent(_ sender: CustomActivityButton) {
        sender.showActivity()
        _acceptRejectEvent("approved")
    }
    
    @IBAction func _handleDeleteEvent(_ sender: CustomActivityButton) {
        sender.showActivity()
        _acceptRejectEvent("rejected")
    }
    
    //    @IBAction func _handleFollowEvent(_ sender: UIButton) {
////        self._handleFollowEvent()
//    }
    
    @IBAction func _handleMessageEvent(_ sender: UIButton) {
        guard let _userModel = _userData else { return }
        guard let userDetail = APPSESSION.userDetail else { return }
        let chatModel = ChatModel()
        chatModel.image = _userModel.image
        chatModel.title = _userModel.fullName
        chatModel.chatType = "friend"
        chatModel.members.append(_userModel.id)
        chatModel.members.append(userDetail.id)
        let chatIds = [_userModel.id, Preferences.isSubAdmin ? userDetail.promoterId : userDetail.id].sorted()
        chatModel.chatId = chatIds.joined(separator: ",")
        let vc = INIT_CONTROLLER_XIB(ChatDetailVC.self)
        vc.chatModel = chatModel
        vc.hidesBottomBarWhenPushed = true
        self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func _openMutualFreindsList(sender : UITapGestureRecognizer) {
        let presentedViewController = INIT_CONTROLLER_XIB(EventGuestListBottomSheet.self)
        presentedViewController.isMutualFriend = true
        presentedViewController._userList = _mutualFriends
        presentedViewController.openChatCallBack = { chatModel in
            let vc = INIT_CONTROLLER_XIB(ChatDetailVC.self)
            vc.hidesBottomBarWhenPushed = true
            vc.chatModel = chatModel
            self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
        }
        parentViewController?.presentAsPanModal(controller: presentedViewController)
    }
    
    @objc func openProfile(_ g: UITapGestureRecognizer) -> Void {
        let vc = INIT_CONTROLLER_XIB(ProfileImageViewVC.self)
        vc.profileImg = _userData?.image ?? kEmptyString
        vc.userName = _userData?.firstName ?? kEmptyString
        self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func _handleShareEvent(_ sender: UIButton) {
        _generateDynamicLinks()
    }
    
    private func  _generateDynamicLinks() {
        guard let user = _userData else { return }
        let vc = INIT_CONTROLLER_XIB(ShareBottomSheet.self)
        vc.userDetailModel = user
        vc.isUser = true
        vc.modalPresentationStyle = .overFullScreen
        parentViewController?.present(vc, animated: true)
//        guard let user = userDetail else { return }
//        let shareMessage = "\(user.fullName) \n\n\(user.bio) \n\n\("https://explore.whosin.me/u/\(user.id)")"
//        let items = [shareMessage]
//        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
//        activityController.setValue(kAppName, forKey: "subject")
//        activityController.popoverPresentationController?.sourceView = self.view
//        activityController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToTwitter]
//        present(activityController, animated: true, completion: nil)
    }
    
}

extension UserInfoTableCell:  ExpandableLabelDelegate {
    
    func willExpandLabel(_ label: ExpandableLabel) { }
    
    func didExpandLabel(_ label: ExpandableLabel) {
        _bioText.superview?.setNeedsLayout()
        _bioText.superview?.layoutIfNeeded()
    }
    
    func willCollapseLabel(_ label: ExpandableLabel) {
        
    }
    
    func didCollapseLabel(_ label: ExpandableLabel) {
        _bioText.superview?.setNeedsLayout()
        _bioText.superview?.layoutIfNeeded()
    }
}
