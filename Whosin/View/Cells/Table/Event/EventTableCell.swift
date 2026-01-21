import UIKit

class EventTableCell: UITableViewCell {

    @IBOutlet weak var _collectionHieghtConstraint: NSLayoutConstraint!
    @IBOutlet weak var _extraGuestView: UIView!
    @IBOutlet weak var _eventTitle: UILabel!
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
    private var _eventList: EventModel?

    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    static var height: CGFloat { UITableView.automaticDimension }

    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUi()
        DISPATCH_ASYNC_MAIN_AFTER(0.1) {
            self._mainContainerView.cornerRadius = 15
            self._badgeView.roundCorners(corners: [.bottomLeft, .topRight], radius: 10)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
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
    
    private func _loadEventData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        cellData.removeAll()
        guard let invited = _eventList?.invitedUsers else { return }
        if invited.isEmpty {
            _collectionHieghtConstraint.constant = 0
        } else {
            invited.forEach({ users in
                if let user = users.user  {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierStory,
                    kCellTagKey: users.id,
                    kCellObjectDataKey: users,
                    kCellClassKey: SharedUsersCollectionCell.self,
                    kCellHeightKey: SharedUsersCollectionCell.height
                ])
                }
            })
            _collectionHieghtConstraint.constant = SharedUsersCollectionCell.height + 10
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
            _userCollection.loadData(cellSectionData)
        }
        _userCollection.reload()
    }
    
    func setupEventData(_ model: EventModel) {
        _editButton.isHidden = true
        _whosinTitle.text = "invited_users".localized()
        _eventTitle.isHidden = false
        _extraGuestView.isHidden = true
        _eventTitle.text = model.title
        _eventList = model
        _extraGuestWithConstraint.constant = 0
        _loadEventData()
        _createdUseNname.text = model.org?.name
        if Utils.stringIsNullOrEmpty(model.org?.logo) && Utils.stringIsNullOrEmpty(model.org?.name) {
            _createdUserImage.image = UIImage(named: "icon_user_avatar_default")
        } else {
            _createdUserImage.loadWebImage(model.org?.logo ?? kEmptyString, name: model.org?.name ?? kEmptyString)
        }
        invitedByTxt.text = "invited_you_to_his_event".localized()
        _messageLabel.text = model.descriptions
        _mainContainerView.borderColor =  model.borderColor
        _badgeView.backgroundColor =  model.borderColor
        _mainContainerView.borderWidth = 2
        _venueName.text = model.venueDetail?.name
        _venueAddress.text = model.venueDetail?.address
        _venueImage.loadWebImage(model.venueDetail?.logo ?? "")
        _coverImage.loadWebImage(model.venueDetail?.cover ?? "")
        _statusTxt.text = model.myInviteStatus
        _dateLabel.text = model._eventDate
        _timeLabel.text = model.eventTimeSlot
        layoutIfNeeded()
    }
    
    @IBAction  private func _handleEditEvent(_ sender: UIButton) {
    }

    @IBAction private func _handleInvitedGuestListEvent(_ sender: UIButton) {
        let presentedViewController = INIT_CONTROLLER_XIB(EventGuestListBottomSheet.self)
        presentedViewController.eventId = _eventList?.id ?? kEmptyString
        presentedViewController.openChatCallBack = { chatModel in
            let vc = INIT_CONTROLLER_XIB(ChatDetailVC.self)
            vc.hidesBottomBarWhenPushed = true
            vc.chatModel = chatModel
            self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
        }
        parentViewController?.presentAsPanModal(controller: presentedViewController)
    }

}
         
            

extension EventTableCell: CustomCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? SharedUsersCollectionCell else { return }
        if let object = cellDict?[kCellObjectDataKey] as? InvitationModel {
            cell.setupEventData(object, inviteStatus: object.inviteStatus)
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        CGSize(width: 40, height: SharedUsersCollectionCell.height)
    }
}
