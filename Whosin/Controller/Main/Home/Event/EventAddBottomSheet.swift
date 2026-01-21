import UIKit
import MHLoadingButton

class EventAddBottomSheet: PanBaseViewController {
    
    @IBOutlet private weak var _countLabel: UILabel!
    @IBOutlet private weak var _collectionView: CustomCollectionView!
    @IBOutlet weak var _confirmBtn: CustomActivityButton!
    private let kCellIdentifierStory = String(describing: SharedUserNoMarginCell.self)
    public var offerId:String = kEmptyString
    public var eventId:String = kEmptyString
    public var activityId:String = kEmptyString
    private var stepperValue: Int = 0
    public var userIds: [String] = []
    public var eventModel: EventDetailModel?
    private var selectedContacts: [UserDetailModel] = [] {
        didSet {
            _collectionView.reload()
        }
    }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupUi()
    }
    
    // --------------------------------------
    // MARK: Service Method
    // --------------------------------------
    
    private func _reqestInvite(extraGuest: Int) {
        WhosinServices.inviteEventUser(eventId: eventId, userIds: userIds, extraGuest: extraGuest) { [weak self] container, error in
            guard let self = self else { return }
            if container?.code == 1 {
                self.view.makeToast(container?.message)
            }
            self._confirmBtn.hideActivity()
            DISPATCH_ASYNC_MAIN_AFTER(0.8) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // --------------------------------------
    // MARK: SetUp method
    // --------------------------------------
    
    public func _setupUi() {
        setupUi()
    }
    
    // --------------------------------------
    // MARK: Private method
    // --------------------------------------
    
    override func setupUi() {
        _countLabel.text = "0"
        hideNavigationBar()
        _collectionView.setup(cellPrototypes: _storyPrototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 5,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0),
                              spacing: CGSize(width: 0, height: 0),
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
        _requestContactList()
        _loadInvitedData()
    }
    
    private func _requestContactList() {
//        if WHOSINCONTACT.inviteContactList.isEmpty {
//            WHOSINCONTACT.sync { [weak self] error in
//                guard let self = self else { return }
//                self.didLoad = true
//                self.hideHUD(error: error)
//                self.selectedContacts = WHOSINCONTACT.contactList.filter { contact in return self.userIds.contains(contact.id) }
//                self._loadInvitedData()
//            }
//        } else {
            selectedContacts = WHOSINCONTACT.contactList.filter { contact in return self.userIds.contains(contact.id) }
            _loadInvitedData()
//        }
    }
    
    private var _storyPrototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifierStory, kCellNibNameKey: kCellIdentifierStory, kCellClassKey: SharedUserNoMarginCell.self, kCellHeightKey: SharedUserNoMarginCell.height]]
    }
    
    private func _loadInvitedData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        cellData.append([
            kCellIdentifierKey: kCellIdentifierStory,
            kCellTagKey: kCellIdentifierStory,
            kCellObjectDataKey: true,
            kCellClassKey: SharedUserNoMarginCell.self,
            kCellHeightKey: SharedUserNoMarginCell.height
        ])
        
        if !selectedContacts.isEmpty {
            selectedContacts.forEach { contact in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierStory,
                    kCellTagKey: kCellIdentifierStory,
                    kCellObjectDataKey: contact,
                    kCellClassKey: SharedUserNoMarginCell.self,
                    kCellHeightKey: SharedUserNoMarginCell.height
                ])
            }
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }
    
    private func updateLabel() {
        _countLabel.text = "\(stepperValue)"
    }
    
    private func _updateInviteStatus(inviteStatus: String) {
        WhosinServices.updateEventInviteStatus(eventId: eventId, inviteStatus: inviteStatus) { [weak self] container, error in
            guard let self = self else { return }
            self.view.makeToast(container?.message)
            NotificationCenter.default.post(name: kReloadEventDetail, object: nil, userInfo: nil)
        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    @IBAction private func _handleConfirmEvent(_ sender: UIButton) {
        _confirmBtn.showActivity()
        _updateInviteStatus(inviteStatus: "in")
        let guest = Int(_countLabel.text ?? "0") ?? 0
        _reqestInvite(extraGuest: guest)
    }
    
    @IBAction private func _handleMinusEvent(_ sender: UIButton) {
        if stepperValue != 0 { stepperValue -= 1 }
        updateLabel()
    }
    
    @IBAction private func _handlePlusEvent(_ sender: UIButton) {
        stepperValue += 1
        updateLabel()
    }
}


// --------------------------------------
// MARK: CustomCollectionViewDelegate
// --------------------------------------

extension EventAddBottomSheet: CustomCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? SharedUserNoMarginCell {
            if let object = cellDict?[kCellObjectDataKey] as? UserDetailModel {
                    cell.setupContactData(data: object)
            } else if let object = cellDict?[kCellObjectDataKey] as? Bool {
                cell.setupContactData(islastIndex: object)
            }
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        let index = indexPath.row
        if index == 0 {
            let presentedViewController = INIT_CONTROLLER_XIB(ContactShareBottomSheet.self)
            presentedViewController.eventModel = eventModel
            presentedViewController.isFromEventDetail = true
            presentedViewController.onShareButtonTapped = { [weak self] selectedContacts in
                self?.selectedContacts.removeAll()
                let sharedContactIds = selectedContacts.map { $0.id }
                self?.selectedContacts = selectedContacts
                self?.userIds = sharedContactIds
                self?._loadInvitedData()
                self?._collectionView.reload()
            }
            presentedViewController.sharedContactId = selectedContacts.map { $0.id }
            presentedViewController.isFromCreateBucket = true
            presentedViewController.modalPresentationStyle = .overFullScreen
            present(presentedViewController, animated: true)
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        CGSize(width: 60, height: SharedUserNoMarginCell.height)
    }
}
