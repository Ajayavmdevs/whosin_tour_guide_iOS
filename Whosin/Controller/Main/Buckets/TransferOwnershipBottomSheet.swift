import UIKit

class TransferOwnershipBottomSheet: PanBaseViewController {

    @IBOutlet private weak var _tableView: CustomTableView!
    private let kCellIdentifier = String(describing: ContactsTableCell.self)
    var sharedWith: [UserDetailModel] = []
    var bucketId: String = kEmptyString
    var outingId: String = kEmptyString
    public var sharedContactId: [String] = []
    public var isFromOuting: Bool = false
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupUi()
        _loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // --------------------------------------
    // MARK: SetUp method
    // --------------------------------------
    
    public func _setupUi() {
        _tableView.setup(
            cellPrototypes: _prototypes,
            hasHeaderSection: true,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            emptyDataText: "There is no data available",
            emptyDataIconImage: UIImage(named: "empty_follower"),
            emptyDataDescription: kEmptyString,
            delegate: self)
        _tableView.showsVerticalScrollIndicator = false
        _tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 50, right: 0)
    }
    
    // --------------------------------------
    // MARK: Private method
    // --------------------------------------
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: String(describing: ContactsTableCell.self), kCellClassKey: ContactsTableCell.self, kCellHeightKey: ContactsTableCell.height] ]
    }
    
    private func _loadData() {
        
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        sharedWith.forEach { contact in
            if APPSESSION.userDetail?.id != contact.id {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: contact.id,
                    kCellObjectDataKey: contact,
                    kCellStatusKey: false,
                    kCellClassKey: ContactsTableCell.self,
                    kCellHeightKey: ContactsTableCell.height
                ])
            }
        }
        cellSectionData.append([kSectionTitleKey: isFromOuting ? "Outing Members" : "Members in Bucket", kSectionDataKey: cellData])
        
        
        _tableView.loadData(cellSectionData)
    }
    
    // --------------------------------------
    // MARK: Service method
    // --------------------------------------
    
    private func _requestChangeOwner(id: String, ownerId: String) {
        WhosinServices.changeOwnerOfBucket(id: id, ownerId: ownerId) { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container else { return }
            NotificationCenter.default.post(name: kReloadBucketList, object: nil, userInfo: nil)
            self.dismiss(animated: true) {
                self.showSuccessMessage(data.message, subtitle: "")
            }
        }
    }
    
    private func _requestChangeOwnerForOuting(ownerId: String, outingId: String) {
        WhosinServices.changeOutingOwner(newOwnerId: ownerId, outingId: outingId) { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container else { return }
            NotificationCenter.default.post(name: kReloadBucketList, object: nil, userInfo: nil)
            self.dismiss(animated: true) {
                self.showSuccessMessage(data.message, subtitle: "")
            }
        }
    }
    
    // --------------------------------------
    // MARK: IBActions Event
    // --------------------------------------
    
    @IBAction private func _handleTransferEvent(_ sender: UIButton) {
        if isFromOuting {
            _requestChangeOwnerForOuting(ownerId: sharedContactId.first ?? kEmptyString, outingId: outingId)
        } else {
            _requestChangeOwner(id: bucketId, ownerId: sharedContactId.first ?? kEmptyString)
        }
    }
    
    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}

// --------------------------------------
// MARK: CustomCollectionViewDelegate
// --------------------------------------

extension TransferOwnershipBottomSheet: CustomTableViewDelegate {
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? ContactsTableCell,
              let model = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
                let isShared = sharedContactId.contains(model.id)
                cell.setupData(model, isSheet: true, isSelected: isShared)
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let contactId = cellDict?[kCellTagKey] as? String else { return }
        sharedContactId.removeAll()
        sharedContactId.append(contactId)
        _tableView.reload()
    }
}
