import UIKit

class CircleListBottomList: ChildViewController {

    @IBOutlet weak var _tableView: CustomNoKeyboardTableView!
    private var kCellIdentifier = String(describing: UserCircleListTableCell.self)
    private var _circleList: [UserDetailModel] = []
    public var userId: String = kEmptyString
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // --------------------------------------
    // MARK: SetUp
    // --------------------------------------
    
    private func setupUI() {
        _tableView.setup(
            cellPrototypes: _prototypes,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            emptyDataText: "preview_empty".localized(),
            emptyDataIconImage: UIImage(named: "empty_event"),
            emptyDataDescription: nil,
            delegate: self)
        _requestCircleListByUserId()
    }
    
    // --------------------------------------
    // MARK: Services
    // --------------------------------------

    private func _requestCircleListByUserId() {
        WhosinServices.getCircleListByUserId(id: userId) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self._circleList = data
            self._loadData()
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        _circleList.forEach { circles in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: circles,
                kCellClassKey: UserCircleListTableCell.self,
                kCellHeightKey: UserCircleListTableCell.height
            ])
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: String(describing: UserCircleListTableCell.self), kCellClassKey: UserCircleListTableCell.self, kCellHeightKey: UserCircleListTableCell.height]]
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------

    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        dismissOrBack()
    }
    
}

extension CircleListBottomList: CustomNoKeyboardTableViewDelegate {
    
    // --------------------------------------
    // MARK: <CustomTableViewDelegate>
    // --------------------------------------
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? UserCircleListTableCell,
              let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
        cell.setupData(object, userId: userId)
    }

    
}
