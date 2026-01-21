import UIKit
import RealmSwift

class MyEventCollectionCell: UITableViewCell {
    
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
        disableSelectEffect()
        DISPATCH_ASYNC_MAIN_AFTER(0.05) {
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
    
    private func _loadEventData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        cellData.removeAll()
        guard let invited = _eventList?.invitedUsers else { return }
        if invited.isEmpty {
            _collectionHieghtConstraint.constant = 0
        } else {
            invited.forEach({ users in
                if users.user != nil  {
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
    
    func setupData(_ model: OutingListModel) {
        _outingListModel = model
        _loadData()
        _eventTitle.isHidden = true
        if model.isOwner {
            _editButton.isHidden = false
            _badgeView.isHidden = true
            _createdUseNname.isHidden = true
            _createdUserImage.loadWebImage(model.owner?.image ?? kEmptyString, name: model.owner?.fullName ?? kEmptyString)
            invitedByTxt.text = "you_created".localized()
        } else {
            _createdUseNname.isHidden = false
            _editButton.isHidden = true
            _badgeView.isHidden = false
            _createdUseNname.text = model.owner?.fullName
            _createdUserImage.loadWebImage(model.owner?.image ?? kEmptyString, name: model.owner?.fullName ?? kEmptyString)
            invitedByTxt.text = "invited_you_to".localized()
        }
        _mainContainerView.borderColor =  model.borderColor
        _badgeView.backgroundColor =  model.borderColor
        _mainContainerView.borderWidth = 2
        _venueName.text = model.venue?.name
        _venueAddress.text = model.venue?.address
        _venueImage.loadWebImage(model.venue?.logo ?? "")
        _coverImage.loadWebImage(model.venue?.cover ?? "")
        _statusTxt.text = model.status
        _dateLabel.text = model.date
        _timeLabel.text = "\(model.startTime) - \(model.endTime)"
        _messageLabel.text = model.title
        _extraGuestLabel.text = "\(model.extraGuest)"
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
        _createdUserImage.loadWebImage(model.org?.logo ?? kEmptyString, name: model.org?.name ?? kEmptyString)
        invitedByTxt.text = "invited_you_to_his_event".localized()
        _messageLabel.text = model.descriptions
        _mainContainerView.borderColor =  model.borderColor
        _badgeView.backgroundColor =  model.borderColor
        _mainContainerView.borderWidth = 2
        _venueName.text = model.venueDetail?.name
        _venueAddress.text = model.venueDetail?.address
        _venueImage.loadWebImage(model.venueDetail?.logo ?? "")
        _coverImage.loadWebImage(model.venueDetail?.cover ?? "")
        _statusTxt.text = model.myInvitationStatus
        _dateLabel.text = model._eventDate
        let eventTime = Utils.stringToDate(model.eventTime, format: kStanderdDate)
        _timeLabel.text = Utils.dateToString(eventTime, format: kFormatDateTimeUS)
        layoutIfNeeded()
    }
    
    @IBAction  private func _handleEditEvent(_ sender: UIButton) {
        let controler = INIT_CONTROLLER_XIB(InviteBottomSheet.self)
        controler.outingModel = _outingListModel
        let navController = NavigationController(rootViewController: controler)
        navController.modalPresentationStyle = .custom
        parentBaseController?.present(navController, animated: true)
    }

    @IBAction private func _handleInvitedGuestListEvent(_ sender: UIButton) {
        let presentedViewController = INIT_CONTROLLER_XIB(EventGuestListBottomSheet.self)
        presentedViewController.eventId = _eventList?.id ?? kEmptyString
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

extension MyEventCollectionCell: CustomCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? SharedUsersCollectionCell else { return }
        if let object = cellDict?[kCellObjectDataKey] as? InvitationModel {
            cell.setupEventData(object, inviteStatus: object.inviteStatus)
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let model = cellDict?[kCellObjectDataKey] as? InvitationModel else { return }
        let vc = INIT_CONTROLLER_XIB(UsersProfileVC.self)
        vc.contactId = model.userId
        vc.modalPresentationStyle = .overFullScreen
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        CGSize(width: 40, height: SharedUsersCollectionCell.height)
    }
}
