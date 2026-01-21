import UIKit

class GiftsVC: ChildViewController {

    @IBOutlet private weak var _tableView: CustomTableView!
    private let kLoadingCellIdentifier = String(describing: LoadingCell.self)
    private let kCellIdentifierActivity = String(describing: MyActivityTableCell.self)
    private var _vouchersList: [VouchersListModel] = []

    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        _setupUi()
        _loadData(isLoading: true)
        NotificationCenter.default.addObserver(self, selector: #selector(_handleReloadEvent(_:)), name: Notification.Name("reloadMyWallet"), object: nil)
    }
    
    @objc private func _handleReloadEvent(_ sender: Notification) {
        _requestVoucherList()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _requestVoucherList()
    }

    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestVoucherList() {
        WhosinServices.giftsList { [weak self] container, error in
            guard let self = self else { return }
            self.showError(error)
            if error != nil {
                self._loadData(isLoading: false)
            }
            guard let data = container?.data else { return }
            self._vouchersList = data.sorted { voucher1, voucher2 in
                return voucher1._createdAt > voucher2._createdAt
            }
            self._loadData(isLoading: false)
        }
    }

    // --------------------------------------
    // MARK: private
    // --------------------------------------

    private func _setupUi() {
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: kEmptyString,
            emptyDataIconImage: UIImage(named: "empty_gifts"),
            emptyDataDescription: "You haven't received any gifts.But you can always treat yourself to our offers.",
            delegate: self)
    }
    
    private func _loadData(isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        if isLoading {
            cellData.append([
                kCellIdentifierKey: kLoadingCellIdentifier,
                kCellTagKey: kLoadingCellIdentifier,
                kCellObjectDataKey: _vouchersList,
                kCellClassKey: LoadingCell.self,
                kCellHeightKey: LoadingCell.height
            ])
        } else {
            _vouchersList.forEach { vouchersList in
            }
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kLoadingCellIdentifier, kCellNibNameKey: kLoadingCellIdentifier, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height],
            [kCellIdentifierKey: kCellIdentifierActivity, kCellNibNameKey: kCellIdentifierActivity, kCellClassKey: MyActivityTableCell.self, kCellHeightKey: MyActivityTableCell.height]

        ]
    }

}

// --------------------------------------
// MARK: Custom TableView
// --------------------------------------

extension GiftsVC: CustomTableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
    }
}
