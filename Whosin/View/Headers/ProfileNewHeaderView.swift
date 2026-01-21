import Foundation
import UIKit
import ExpandableLabel
import GSKStretchyHeaderView

class ProfileNewHeaderView: UIView {
    
    @IBOutlet var _userProfileImage: UIImageView!
    @IBOutlet weak var _followersLabel: UILabel!
    @IBOutlet weak var _followingLabel: UILabel!
    @IBOutlet weak var _userBioLabel: ExpandableLabel!
    private let kCellIdentifier = String(describing: SuggestedFriendCollectionCell.self)
    public var heightView: CGFloat = 0.0


    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    class var maximumHeight: CGFloat {
        return 250
    }

    class var minimumHeight: CGFloat {
        guard let statusBarHeight = APP.window?.windowScene?.statusBarManager?.statusBarFrame.height else {
            return kNavigationBarDefaultHeight
        }
        return statusBarHeight + kNavigationBarHeight
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(_handleFollowStatusEvent(_:)), name: kReloadFollowStatus, object: nil)
        _setupUi()
    }
    
    @objc func _handleFollowStatusEvent(_ notification: Notification) {
        guard let model = notification.object as? UserDetailModel else { return }
        getProfileData()
    }
    
    public class func initFromNib() -> ProfileNewHeaderView {
        UINib(nibName: "ProfileNewHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! ProfileNewHeaderView
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func _setupUi() {
        _userBioLabel.isHidden = Utils.stringIsNullOrEmpty(APPSESSION.userDetail?.bio)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        _userBioLabel.isUserInteractionEnabled = true
        _userBioLabel.addGestureRecognizer(tapGesture)
        _userBioLabel.delegate = self
        _userBioLabel.shouldCollapse = true
        _userBioLabel.numberOfLines = 2
        _userBioLabel.ellipsis = NSAttributedString(string: "...")
        _userBioLabel.collapsedAttributedLink = NSAttributedString(string: "more".localized(), attributes: [NSAttributedString.Key.foregroundColor: ColorBrand.brandPink])
        _userBioLabel.setLessLinkWith(lessLink: "less".localized(), attributes: [NSAttributedString.Key.foregroundColor: ColorBrand.brandPink], position: .left)
        _userProfileImage.loadWebImage(APPSESSION.userDetail?.image ?? kEmptyString, name: APPSESSION.userDetail?.fullName ?? kEmptyString)
        _followersLabel.text = "\(APPSESSION.userDetail?.follower ?? 0)"
        _followingLabel.text = "\(APPSESSION.userDetail?.following ?? 0)"
        let tap = UITapGestureRecognizer(target: self, action: #selector(openProfile(_:)))
        _userProfileImage.addGestureRecognizer(tap)
        getProfileData()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    @objc func handleUserFollowState(_ notification: Notification) {
        getProfileData()
    }

    func getProfileData() {
        APPSESSION.getProfile { success, error in
            if success {
                self._userBioLabel.text = APPSESSION.userDetail?.bio
                self._userProfileImage.loadWebImage(APPSESSION.userDetail?.image ?? kEmptyString, name: APPSESSION.userDetail?.fullName ?? kEmptyString)
                self._followersLabel.text = "\(APPSESSION.userDetail?.follower ?? 0)"
                self._followingLabel.text = "\(APPSESSION.userDetail?.following ?? 0)"
            }
        }
    }

    @objc private func labelTapped() {
        _userBioLabel.collapsed.toggle()
        _userBioLabel.superview?.setNeedsLayout()
        _userBioLabel.superview?.layoutIfNeeded()
        let isExpanded = !_userBioLabel.collapsed
    }
    
    private func updatedHeaderHeight() -> CGFloat {
        self.layoutIfNeeded()
        let bioLabelHeight = _userBioLabel.bounds.height - 5
        return bioLabelHeight
    }

    @objc func openProfile(_ g: UITapGestureRecognizer) -> Void {
        let vc = INIT_CONTROLLER_XIB(ProfileImageViewVC.self)
        vc.profileImg = APPSESSION.userDetail?.image ?? kEmptyString
        vc.userName = APPSESSION.userDetail?.firstName ?? kEmptyString
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func _handleFollowerListEvent(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(FollowListVC.self)
        vc.modalPresentationStyle = .fullScreen
        vc.isFollowerList = true
        vc.followId = APPSESSION.userDetail?.id ?? kEmptyString
        self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func _handleFollowingListEvent(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(FollowListVC.self)
        vc.modalPresentationStyle = .fullScreen
        vc.isFollowerList = false
        vc.followId = APPSESSION.userDetail?.id ?? kEmptyString
        self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
              
    @IBAction private func _handleShareEvent(_ sender: UIButton) {
        _generateDynamicLinks()
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
        
    private func  _generateDynamicLinks() {
        guard let controller = parentViewController else { return }
        guard let user = APPSESSION.userDetail else {
            return
        }
        let shareMessage = "\(user.fullName) \n\n\(user.bio) \n\n\("https://explore.whosin.me/u/\(user.id)")"
        let items = [shareMessage]
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityController.setValue(kAppName, forKey: "subject")
        activityController.popoverPresentationController?.sourceView = controller.view
        activityController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToTwitter]
        controller.present(activityController, animated: true, completion: nil)
    }
}


extension ProfileNewHeaderView:  ExpandableLabelDelegate {
    
    func willExpandLabel(_ label: ExpandableLabel) {
    }
    
    func didExpandLabel(_ label: ExpandableLabel) {
        _userBioLabel.superview?.setNeedsLayout()
        _userBioLabel.superview?.layoutIfNeeded()
    }
    
    func willCollapseLabel(_ label: ExpandableLabel) {
    }
    
    func didCollapseLabel(_ label: ExpandableLabel) {
        _userBioLabel.superview?.setNeedsLayout()
        _userBioLabel.superview?.layoutIfNeeded()
    }
}

extension ProfileNewHeaderView: ReloadProfileDelegate {
    func didRequestReload() {
        getProfileData()
    }
}

// --------------------------------------
// MARK: CollectionView Delegate
// --------------------------------------

