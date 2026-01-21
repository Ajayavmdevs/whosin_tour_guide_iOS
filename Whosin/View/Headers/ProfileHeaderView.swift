import Foundation
import UIKit
import ExpandableLabel
import GSKStretchyHeaderView

protocol ProfileTableHeaderViewDelegate: AnyObject {
    func didSelectTab(at index: Int)
    func profileHeaderdidSelectTab(index: Int, newHeight: CGFloat, isExpanded: Bool)
}

class ProfileHeaderView: UIView {
    
    @IBOutlet weak var _promoterView: UIView!
    @IBOutlet weak var _switchToPromoter: CustomButton!
    @IBOutlet weak var _premiumeView: UIView!
    @IBOutlet weak var _suggestedView: UIView!
    @IBOutlet weak var _bioView: UIView!
    @IBOutlet weak var _vipImageView: UIImageView!
    @IBOutlet weak var segment: CustomSegmentControll!
    @IBOutlet weak var _userName: UILabel!
    @IBOutlet var _userProfileImage: UIImageView!
    @IBOutlet weak var _followersLabel: UILabel!
    @IBOutlet weak var _followingLabel: UILabel!
    @IBOutlet weak var _userBioLabel: ExpandableLabel!
    @IBOutlet weak var _customMenuView: UIView!
    @IBOutlet weak var _searchBar: UISearchBar!
    @IBOutlet weak var editProfilebtn: UIButton!
    @IBOutlet weak var _eventBadgeView: UIView!
    @IBOutlet weak var _bucketBadgeView: UIView!
    @IBOutlet private weak var _eventConstraint: NSLayoutConstraint!
    @IBOutlet weak var _collectionView: CustomNoKeyboardCollectionView!
    @IBOutlet weak var _collectionHeight: NSLayoutConstraint!
    @IBOutlet weak var _suggestTitleHeight: NSLayoutConstraint!
    weak var delegate: ProfileTableHeaderViewDelegate?
    private var selectedIndex: Int = 0
    public var suggestedUsers: [UserDetailModel] = [] {
        didSet {
            _loadData()
        }
    }
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
        setupUi()
        _setupUi()
    }
    
    @objc func _handleFollowStatusEvent(_ notification: Notification) {
        guard let model = notification.object as? UserDetailModel else { return }
        getProfileData()
    }
    
    public class func initFromNib() -> ProfileHeaderView {
        UINib(nibName: "ProfileHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! ProfileHeaderView
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func _setupUi() {
        if APPSESSION.userDetail?.isPromoter == true {
            _promoterView.isHidden = false
        } else if APPSESSION.userDetail?.isRingMember == true {
            _promoterView.isHidden = false
        } else {
            _promoterView.isHidden = true
        }
        _searchBar.searchTextField.backgroundColor = UIColor(white: 1, alpha: 0.08)
        _searchBar.searchTextField.layer.cornerRadius = 18
        _searchBar.searchTextField.layer.masksToBounds = true
        _searchBar.searchTextField.textColor = .white
//        _promoterView.isHidden = APPSESSION.userDetail?.isPromoter == false || APPSESSION.userDetail?.isRingMember == false
        segment.setupSegments(["feed".localized(),"invitations".localized(),"my_event".localized(),"friends".localized()])
        segment.delegate = self
        if APPSESSION.userDetail?.isPromoter == true {
            _switchToPromoter.setTitle("switch_to_promoter".localized(), for: .normal)
        } else if APPSESSION.userDetail?.isRingMember == true {
            _switchToPromoter.setTitle("switch_to_complimentary".localized(), for: .normal)
        }
        _userBioLabel.text = APPSESSION.userDetail?.bio
        _bioView.isHidden = Utils.stringIsNullOrEmpty(APPSESSION.userDetail?.bio)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        _premiumeView.cornerRadius = _premiumeView.frame.height / 2
        _userBioLabel.isUserInteractionEnabled = true
        _userBioLabel.addGestureRecognizer(tapGesture)
        _userBioLabel.delegate = self
        _userBioLabel.shouldCollapse = true
        _userBioLabel.numberOfLines = 2
        _userBioLabel.ellipsis = NSAttributedString(string: "...")
        _userBioLabel.collapsedAttributedLink = NSAttributedString(string: "more".localized(), attributes: [NSAttributedString.Key.foregroundColor: ColorBrand.brandPink])
        _userBioLabel.setLessLinkWith(lessLink: "less".localized(), attributes: [NSAttributedString.Key.foregroundColor: ColorBrand.brandPink], position: .left)
        _userName.text = APPSESSION.userDetail?.fullName
        _userProfileImage.loadWebImage(APPSESSION.userDetail?.image ?? kEmptyString, name: APPSESSION.userDetail?.fullName ?? kEmptyString)
        _followersLabel.text = "\(APPSESSION.userDetail?.follower ?? 0)"
        _followingLabel.text = "\(APPSESSION.userDetail?.following ?? 0)"
        if APPSESSION.userDetail?.isVip == true {
            _vipImageView.isHidden = false
            _premiumeView.isHidden = true
        } else if APPSESSION.userDetail?.isMembershipActive == true {
            _premiumeView.isHidden = false
            _vipImageView.isHidden = true
        } else {
            _premiumeView.isHidden = true
            _vipImageView.isHidden = true
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(openProfile(_:)))
        _userProfileImage.addGestureRecognizer(tap)
        let eventX: CGFloat = kScreenWidth / CGFloat(segment.numberOfSegments)
        _eventConstraint.constant = (eventX - 20)
        getProfileData()
        _loadData()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: SuggestedFriendCollectionCell.self, kCellHeightKey: SuggestedFriendCollectionCell.height]]
    }
    
    private func setupUi() {
        _collectionView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
                              spacing: CGSize(width: 2, height: 2),
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        self._collectionView.contentInset = UIEdgeInsets(top: 0, left: 11, bottom: 0, right: 11)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        _suggestedView.isHidden = suggestedUsers.count == 0
        self._collectionHeight.constant = suggestedUsers.count == 0 ? 0 : 160
        self._suggestTitleHeight.constant = suggestedUsers.count == 0 ? 0 : 20

        if !suggestedUsers.isEmpty {
            suggestedUsers.forEach { users in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: kCellIdentifier,
                    kCellObjectDataKey: users,
                    kCellClassKey: SuggestedFriendsTableCell.self,
                    kCellHeightKey: SuggestedFriendsTableCell.height
                ])
            }
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        self._collectionView.loadData(cellSectionData)
    }
    
    @objc func handleUserFollowState(_ notification: Notification) {
        getProfileData()
    }

    func showEventBadgeValue(isHide: Bool = false) {
        _eventBadgeView.isHidden = isHide
    }

    func showBucketBadgeValue(isHide: Bool = false) {
        _bucketBadgeView.isHidden = isHide
    }

    func getProfileData() {
        APPSESSION.getProfile { success, error in
            if success {
                self._userBioLabel.text = APPSESSION.userDetail?.bio
                self._userName.text = APPSESSION.userDetail?.fullName
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
        delegate?.profileHeaderdidSelectTab(index: selectedIndex, newHeight: updatedHeaderHeight(), isExpanded: isExpanded)
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
    
    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
    }
              
    @IBAction private func _editProfile(_ sender: Any) {
        let vc = INIT_CONTROLLER_XIB(EditProfileVC.self)
        vc.delegate = self
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction private func _handleShareEvent(_ sender: UIButton) {
        _generateDynamicLinks()
    }
    
    @IBAction private func _handleSwitchToPromoter(_ sender: CustomButton) {
        if APPSESSION.userDetail?.isPromoter == true {
            NotificationCenter.default.post(name: .switchToPromoterProfile, object: nil)
        } else if APPSESSION.userDetail?.isRingMember == true {
            NotificationCenter.default.post(name: .switchToComplementaryProfile, object: nil)
        }
        parentViewController?.dismiss(animated: true, completion: nil)
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


extension ProfileHeaderView:  ExpandableLabelDelegate {
    
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

extension ProfileHeaderView: ReloadProfileDelegate {
    func didRequestReload() {
        getProfileData()
    }
}


extension ProfileHeaderView :CustomSegmentControlDelegate {
    func didSelectSegment(at index: Int) {
        self._searchBar.superview?.isHidden = !(index == 3)
        selectedIndex = index
        let isExpanded = !_userBioLabel.collapsed
        delegate?.profileHeaderdidSelectTab(index: index, newHeight: updatedHeaderHeight(), isExpanded: isExpanded)
    }
    
}

// --------------------------------------
// MARK: CollectionView Delegate
// --------------------------------------

extension ProfileHeaderView: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? SuggestedFriendCollectionCell, let object = cellDict?[kCellObjectDataKey] as? UserDetailModel {
            cell.setupData(object)
            cell._mainView.addGradientBorderWithColor(cornerRadius: 8, 1.5, [ColorBrand.brandPink.cgColor, ColorBrand.brandgradientBlue.cgColor])
            cell.closeUserCallBack = { id in
                if let index = self.suggestedUsers.firstIndex(where: { $0.id == id}) {
                    self.suggestedUsers.remove(at: index)
                    self._loadData()
                }
            }
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        if cell is SuggestedFriendCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? UserDetailModel, let userDetail = APPSESSION.userDetail, object.id != userDetail.id else { return }
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
                vc.userDetail = object
                vc.followStateCallBack = { id, isFollow in
                    if let index = self.suggestedUsers.firstIndex(where: { $0.id == id}) {
                        self.suggestedUsers[index].follow = isFollow
                        self._loadData()
                    }
                }
                parentBaseController?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
            return  CGSize(width: 150, height: SuggestedFriendCollectionCell.height)
    }
}
