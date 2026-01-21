import UIKit

class ReportedUsersListVC: ChildViewController {

    @IBOutlet weak var _tableView: CustomNoKeyboardTableView!
    private let kCellIdentifier = String(describing: ReportedUsersTableCell.self)
    private var _reportedUserList: [ReportedUserListModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "no_reported_users".localized(),
            emptyDataIconImage: UIImage(named: "empty_follower"),
            emptyDataDescription: nil,
            delegate: self)
        _requestReportedUserList()
    }
    
    private func _requestReportedUserList() {
        showHUD()
        WhosinServices.reportedUserList { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self._reportedUserList = data
            self._loadData()
        }
    }
    
    private func _requestRemoveReportedUser(id: String, userId: String) {
        WhosinServices.removeReportedUser(id: id) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container else { return }
            Preferences.blockedUsers.removeAll(where: { $0 == userId})
            self._requestReportedUserList()
        }
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        _reportedUserList.forEach { block in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: block,
                kCellClassKey: ReportedUsersTableCell.self,
                kCellHeightKey: ReportedUsersTableCell.height
            ])
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    private var _prototype: [[String: Any]]? {
        return [
                [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: ReportedUsersTableCell.self, kCellHeightKey: ReportedUsersTableCell.height]
        ]
    }

    @IBAction func _handleBackEvent(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}

// --------------------------------------
// MARK: Custom TableView
// --------------------------------------

extension ReportedUsersListVC: CustomNoKeyboardTableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? ReportedUsersTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? ReportedUserListModel  else { return }
            cell.setupData(object)
            cell.callback = { [weak self] id in
                self?.confirmAlert(message: "delete_report_confirmation".localized(), okHandler: { action in
                    self?._requestRemoveReportedUser(id: id, userId: object.userId)
                })
            }
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? ReportedUserListModel  else { return }
        let vc = INIT_CONTROLLER_XIB(ReportDetailVC.self)
        vc.reportId = object.id
        navigationController?.pushViewController(vc, animated: true)
    }

}
