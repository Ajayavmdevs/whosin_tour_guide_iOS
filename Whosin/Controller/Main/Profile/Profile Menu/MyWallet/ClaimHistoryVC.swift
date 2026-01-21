import UIKit

class ClaimHistoryVC: BaseViewController {

    @IBOutlet private weak var _tableView: CustomTableView!
    private let kCellIdentifier = String(describing: ClaimHistoryCell.self)
    private var _claimHistory: [ClaimHistoryModel] = []
    
    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        DISPATCH_ASYNC_MAIN_AFTER(0.5) {
            self.setupUi()
        }
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
            emptyDataText: kEmptyString,
            emptyDataIconImage: UIImage(named: "empty_claim"),
            emptyDataDescription: "empty_claim_history".localized(),
            delegate: self)
        _requestClaimHistory()
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestClaimHistory() {
        self.showHUD()
        WhosinServices.claimHistory { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD( error: error)
            guard let data = container?.data else { return }
            self._claimHistory = data
            self._loadData()
        }
    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: ClaimHistoryCell.self, kCellHeightKey: ClaimHistoryCell.height]]
    }

    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        _claimHistory.forEach { model in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: model.id,
                kCellObjectDataKey: model,
                kCellClassKey: ClaimHistoryCell.self,
                kCellHeightKey: ClaimHistoryCell.height
            ])
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }

    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

extension ClaimHistoryVC: CustomTableViewDelegate {
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? ClaimHistoryCell {
            guard let object = cellDict?[kCellObjectDataKey] as? ClaimHistoryModel else { return }
            cell.setupData(object)
        }
    }
    
    
}
