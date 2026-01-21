import UIKit

class OutingCollectionCell: UICollectionViewCell {

    @IBOutlet weak var _createdDate: UILabel!
    @IBOutlet weak var _extraGuestView: UIView!
    @IBOutlet weak var _whosinTitle: UILabel!
    @IBOutlet weak var _extraGuestWithConstraint: NSLayoutConstraint!
    @IBOutlet weak var invitedByTxt: UILabel!
    @IBOutlet weak var _mainContainerView: UIView!
    @IBOutlet weak var _statusTxt: UILabel!
    @IBOutlet weak var _badgeView: UIView!
    @IBOutlet weak var _editButton: UIButton!
    @IBOutlet weak var _createdUserImage: UIImageView!
    @IBOutlet weak var _createdUseNname: UILabel!
    @IBOutlet weak var _coverImage: UIImageView!
    @IBOutlet weak var _venueImage: UIImageView!
    @IBOutlet weak var _venueName: UILabel!
    @IBOutlet weak var _venueAddress: UILabel!
    @IBOutlet weak var _dateLabel: UILabel!
    @IBOutlet weak var _timeLabel: UILabel!
    @IBOutlet weak var _messageLabel: UILabel!
    @IBOutlet weak var _extraGuestLabel: UILabel!
    @IBOutlet weak var _userCollection: CustomCollectionView!
    private let kCellIdentifierStory = String(describing: SharedUsersCollectionCell.self)
    private var _outingListModel: OutingListModel?

    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    static var height: CGFloat { 330 }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUi()
        DISPATCH_ASYNC_MAIN_AFTER(0.2) {
            self._mainContainerView.cornerRadius = 15
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
        
        if let invitedUser = _outingListModel?._invitedUser {
            invitedUser.forEach({ users in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierStory,
                    kCellTagKey: users.id,
                    kCellObjectDataKey: users,
                    kCellClassKey: SharedUsersCollectionCell.self,
                    kCellHeightKey: SharedUsersCollectionCell.height
                ])
            })
        } else {
            _userCollection.isHidden = true
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _userCollection.loadData(cellSectionData)
        _userCollection.reload()
    }
    
    
    func setupData(_ model: OutingListModel) {
        _outingListModel = model
        _loadData()
        if APPSESSION.userDetail?.id == model.userId {
            _createdUseNname.isHidden = true
            if let image = model.owner?.image, let name = model.owner?.fullName {
                _createdUserImage.loadWebImage(image, name: name)
            } else {
                _createdUserImage.image = UIImage(named: "icon_user_avatar_default")
            }
            invitedByTxt.text = "you_created".localized()
            if model.status == "cancelled" || model.status == "completed" {
                _editButton.isHidden = true
            } else {
                _editButton.isHidden = false
            }
        } else {
            _createdUseNname.isHidden = false
            _editButton.isHidden = true
            _createdUseNname.text = model.owner?.fullName
            if let image = model.owner?.image, let name = model.owner?.fullName {
                _createdUserImage.loadWebImage(image, name: name)
            } else {
                _createdUserImage.image = UIImage(named: "icon_user_avatar_default")
            }
            invitedByTxt.text = "invited_you_to".localized()
        }
        _mainContainerView.borderColor =  model.borderColor
        _badgeView.backgroundColor =  model.borderColor
        _mainContainerView.borderWidth = 2
        _venueName.text = model.venue?.name
        _venueAddress.text = model.venue?.address
        _venueImage.loadWebImage(model.venue?.logo ?? kEmptyString, name: model.venue?.name ?? kEmptyString)
        _coverImage.loadWebImage(model.venue?.cover ?? kEmptyString)
        _statusTxt.text = model.status
        _dateLabel.text = model._date
        _timeLabel.text = model._timeSlot
        _createdDate.text = model.createdDate
        _messageLabel.text = model.title
        _extraGuestLabel.text = "\(model.extraGuest)"
    }
    
    @IBAction private func _handleEditEvent(_ sender: UIButton) {
    }

    @IBAction private func _handleSeeAllUserEvent(_ sender: UIButton) {
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

extension OutingCollectionCell: CustomCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? SharedUsersCollectionCell else { return }
        if let object = cellDict?[kCellObjectDataKey] as? UserDetailModel {
            cell.setupData(object, inviteStatus: false)
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let model = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
        guard let userDetail = APPSESSION.userDetail else { return }

    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        CGSize(width: 40, height: SharedUsersCollectionCell.height)
    }
}
