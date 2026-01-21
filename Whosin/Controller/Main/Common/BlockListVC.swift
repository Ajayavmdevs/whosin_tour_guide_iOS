import UIKit

class BlockListVC: ChildViewController {

    @IBOutlet weak var _tableView: CustomNoKeyboardTableView!
    private let kCellIdentifier = String(describing: BlockListTableCell.self)
    private let kCellIdentifierLoading = String(describing: LoadingCell.self)
    private var _blockData: [UserDetailModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _loadData(true)
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
            emptyDataText: "no_blocked_users".localized(),
            emptyDataIconImage: UIImage(named: "empty_follower"),
            emptyDataDescription: nil,
            delegate: self)
        _getBlockList()
    }
    
    private func _loadData(_ isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        if isLoading {
            cellData.append([
                kCellIdentifierKey: kCellIdentifierLoading,
                kCellTagKey: kCellIdentifierLoading,
                kCellObjectDataKey: kEmptyString,
                kCellClassKey: LoadingCell.self,
                kCellHeightKey: LoadingCell.height
            ])
        } else {
            _blockData.forEach { block in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: kCellIdentifier,
                    kCellObjectDataKey: block,
                    kCellClassKey: BlockListTableCell.self,
                    kCellHeightKey: BlockListTableCell.height
                ])
            }

        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    private var _prototype: [[String: Any]]? {
        return [
                [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: BlockListTableCell.self, kCellHeightKey: BlockListTableCell.height],
                [kCellIdentifierKey: kCellIdentifierLoading, kCellNibNameKey: kCellIdentifierLoading, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height]

        ]
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _getBlockList() {
        WhosinServices.getBlockList { [weak self] container, error in
            guard let self = self else{ return}
            self.hideHUD(error: error)
            if let data = container?.data {
                self._blockData = data
                self._loadData(false)
            } else {
                self._loadData(false)
            }
        }
    }

    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

// --------------------------------------
// MARK: Custom TableView
// --------------------------------------

extension BlockListVC: CustomNoKeyboardTableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? BlockListTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? UserDetailModel  else { return }
            cell.setupData(object)
            cell.delegate = self
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if cell is BlockListTableCell {
            guard let model = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
            guard let userDetail = APPSESSION.userDetail else { return }
            if model.id != userDetail.id {
                if model.isPromoter, userDetail.isRingMember {
                    let vc = INIT_CONTROLLER_XIB(PromoterPublicProfileVc.self)
                    vc.promoterId = model.id
                    vc.isFromPersonal = true
                    navigationController?.pushViewController(vc, animated: true)
                } else if model.isRingMember, userDetail.isPromoter {
                    let vc = INIT_CONTROLLER_XIB(ComplementaryPublicProfileVC.self)
                    vc.complimentryId = model.id
                    vc.isFromPersonal = true
                    navigationController?.pushViewController(vc, animated: true)
                } else {
                    let vc = INIT_CONTROLLER_XIB(UsersProfileVC.self)
                    vc.contactId = model.id
                    vc.modalPresentationStyle = .overFullScreen
                    navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}
extension BlockListVC: ReloadBlockList {
    func reload() {
        _getBlockList()
    }
}
