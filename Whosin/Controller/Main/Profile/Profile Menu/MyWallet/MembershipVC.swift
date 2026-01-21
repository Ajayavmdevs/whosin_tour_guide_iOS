import UIKit

class MembershipVC: ChildViewController {

    @IBOutlet private weak var _tableView: CustomTableView!
    private let kCellIdentifier = String(describing: MembershipTableCell.self)
    private var subscription: MembershipPackageModel?
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        _setupUi()
        _requestMySubscriptions()
        hideNavigationBar()
    }
    
    // --------------------------------------
    // MARK: Private
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
            emptyDataText: "There is no membership available",
            emptyDataIconImage: UIImage(named: "empty_offers"),
            emptyDataDescription: nil,
            delegate: self)
//        _loadData()
    }
    
    private func _requestMySubscriptions() {
        showHUD()
        WhosinServices.subscriptionDetail { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self.subscription = data
            _loadData()
        }
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
//        guard let subscriptionModel = APPSETTING.membershipPackage else { return }
//        subscriptionModel.forEach { model in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellObjectDataKey: subscription,
                kCellClassKey: MembershipTableCell.self,
                kCellHeightKey: MembershipTableCell.height
            ])
//        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: MembershipTableCell.self, kCellHeightKey: MembershipTableCell.height]]
    }
    
    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}

// --------------------------------------
// MARK: Custom TableView
// --------------------------------------

extension MembershipVC: CustomTableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? MembershipTableCell, let object = cellDict?[kCellObjectDataKey] as? MembershipPackageModel  else { return }
        cell.setupData(object)
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? MembershipPackageModel  else { return }
        let vc = INIT_CONTROLLER_XIB(BundlePlanDetailsVC.self)
        vc.subscription = object
        vc.modalPresentationStyle = .overFullScreen
        navigationController?.present(vc, animated: true)

    }
    
}
