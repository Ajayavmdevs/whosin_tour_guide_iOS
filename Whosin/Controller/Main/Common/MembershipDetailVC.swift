import UIKit

class MembershipDetailVC: ChildViewController {

    @IBOutlet private weak var _tableView: CustomTableView!
    private let kCellIdentifier = String(describing: MembershipTableCell.self)
    private var _selectedIndex: Int = 0

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        _setupUi()
    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func _setupUi() {
        hideNavigationBar()
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "There is no membership available",
            emptyDataIconImage: UIImage(named: "empty_following"),
            emptyDataDescription: nil,
            delegate: self)
        _tableView.proxyDelegate = self
        DISPATCH_ASYNC_MAIN_AFTER(0.5) {
            self._loadData()
        }
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        if _selectedIndex == 0 {
            APPSETTING.membershipPackage?.filter{$0.isPopular}.forEach { membershipPackageModel in
                 cellData.append([
                     kCellIdentifierKey: kCellIdentifier,
                     kCellTagKey: membershipPackageModel.id,
                     kCellObjectDataKey: membershipPackageModel,
                     kCellClassKey: MembershipTableCell.self,
                     kCellHeightKey: MembershipTableCell.height
                 ])
             }
        } else {
            APPSETTING.membershipPackage?.filter{ !$0.isPopular }.forEach { membershipPackageModel in
                 cellData.append([
                     kCellIdentifierKey: kCellIdentifier,
                     kCellTagKey: membershipPackageModel.id,
                     kCellObjectDataKey: membershipPackageModel,
                     kCellClassKey: MembershipTableCell.self,
                     kCellHeightKey: MembershipTableCell.height
                 ])
             }
        }
                
        APPSETTING.membershipPackage?.forEach { membershipPackageModel in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: membershipPackageModel.id,
                kCellObjectDataKey: membershipPackageModel,
                kCellClassKey: MembershipTableCell.self,
                kCellHeightKey: MembershipTableCell.height
            ])
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }

    private var _prototype: [[String: Any]]? {
        return [
                [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: MembershipTableCell.self, kCellHeightKey: MembershipTableCell.height]
        ]
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    @IBAction private func _handleCloseEvent(_ sender: Any) {
        dismiss(animated: true)
    }
    
}

// --------------------------------------
// MARK: Custom TableView
// --------------------------------------

extension MembershipDetailVC: CustomTableViewDelegate, UITableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? MembershipTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? MembershipPackageModel  else { return }
            cell.setupData(object)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 40: 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = MembershipPlanHeaderView(frame: CGRect(x: -1, y: 0, width: tableView.bounds.width + 2, height: 40))
        headerView.delegate = self
        headerView.setupData(_selectedIndex)
        return headerView
    }
}


extension MembershipDetailVC: MembershipPlanHeaderViewDelegate {
    func didSelectTab(at index: Int) {
        _selectedIndex = index
        _loadData()
    }
}
