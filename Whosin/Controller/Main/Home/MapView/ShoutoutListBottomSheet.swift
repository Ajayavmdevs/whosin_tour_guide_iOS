import UIKit

class ShoutoutListBottomSheet: PanBaseViewController {
    
    @IBOutlet weak var _tableView: CustomTableView!
    private let kCellIdentifier = String(describing: EventGuestListTableCell.self)
    var userModel: [UserDetailModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }
    
    override func setupUi() {
        _tableView.setup(
            cellPrototypes: _prototypes,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "There is no shoutout available",
            emptyDataIconImage: UIImage(named: "empty_event"),
            emptyDataDescription: nil,
            delegate: self)
        _loadData()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        userModel.forEach { users in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: users,
                kCellClassKey: EventGuestListTableCell.self,
                kCellHeightKey: EventGuestListTableCell.height
            ])
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
        
    }
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: String(describing: EventGuestListTableCell.self), kCellClassKey: EventGuestListTableCell.self, kCellHeightKey: EventGuestListTableCell.height] ]
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        dismiss(animated: true)
    }
}


extension ShoutoutListBottomSheet: CustomTableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        let cell = cell as? EventGuestListTableCell
        guard let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
        cell?.setupShoutoutData(object)
    }
}
