import UIKit

class CompletePromoterProfileVC: ChildViewController {
    
    @IBOutlet weak var _tableView: CustomTableView!
    private let kCellIdentifierHeader = String(describing: CompleteProfileHeaderCell.self)
    private let kCellIdentifierPrefrence = String(describing: SelectPrefrenceCell.self)
    private let kCellIdentifierWeekend = String(describing: SelectAvailbleTimingCell.self)
    public static var params: [String: Any] = [:]
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }
    
    override func setupUi() {
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: nil,
            emptyDataIconImage: nil,
            delegate: self)
        _loadData()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierHeader, kCellNibNameKey: kCellIdentifierHeader, kCellClassKey: CompleteProfileHeaderCell.self, kCellHeightKey: CompleteProfileHeaderCell.height],
            [kCellIdentifierKey: kCellIdentifierPrefrence, kCellNibNameKey: kCellIdentifierPrefrence, kCellClassKey: SelectPrefrenceCell.self, kCellHeightKey: SelectPrefrenceCell.height],
            [kCellIdentifierKey: kCellIdentifierWeekend, kCellNibNameKey: kCellIdentifierWeekend, kCellClassKey: SelectAvailbleTimingCell.self, kCellHeightKey: SelectAvailbleTimingCell.height]
        ]
    }
    
    private func _loadData(isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        cellData.append([
            kCellIdentifierKey: kCellIdentifierHeader,
            kCellTagKey: kCellIdentifierHeader,
            kCellObjectDataKey: "Intro",
            kCellClassKey: CompleteProfileHeaderCell.self,
            kCellHeightKey: CompleteProfileHeaderCell.height
        ])
        
        cellData.append([
            kCellIdentifierKey: kCellIdentifierPrefrence,
            kCellTagKey: kCellIdentifierPrefrence,
            kCellObjectDataKey: "Prefrence",
            kCellClassKey: SelectPrefrenceCell.self,
            kCellHeightKey: SelectPrefrenceCell.height
        ])
        
        cellData.append([
            kCellIdentifierKey: kCellIdentifierWeekend,
            kCellTagKey: kCellIdentifierWeekend,
            kCellObjectDataKey: "Timing",
            kCellClassKey: SelectAvailbleTimingCell.self,
            kCellHeightKey: SelectAvailbleTimingCell.height
        ])
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
        
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @objc private func handleDataChange() {
        _tableView.reload()
    }
    
}

extension CompletePromoterProfileVC: CustomTableViewDelegate, UIScrollViewDelegate, UITableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? SelectPrefrenceCell {
            cell.setupData()
        } else if let cell = cell as? SelectAvailbleTimingCell {
            cell.setupData {
                self._tableView.reload()
            }
        }
    }
}
