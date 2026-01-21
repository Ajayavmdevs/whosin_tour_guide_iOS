import UIKit

class OutingListVC: ChildViewController {

    @IBOutlet weak var _tableView: CustomNoKeyboardTableView!
    private let kCellIdentifier = String(describing: OutingTableCell.self)
    public var type: OutingType = .all
    private var _outingList: [OutingListModel] = []
    
    public var outingList: [OutingListModel] {
        get { return _outingList }
        set {
            if type == .all {
                _outingList = newValue.filter { $0.status == "upcoming" }
            } else if type == .createdByMe {
                _outingList = newValue.filter{ $0.isOwner && $0.status == "upcoming" }
            } else if type == .history {
                _outingList = newValue.filter{ $0.status == "cancelled" || $0.status == "completed" }
            } else {
                _outingList = newValue.filter{ !$0.isOwner && $0.status == "upcoming"}
            }
            _loadData()
        }
    }
    
    // --------------------------------------
    // MARK: Life-Cycle
    // --------------------------------------

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUi()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }

    override func setupUi() {
        if type == .all {
            _tableView.setup(
                cellPrototypes: _prototype,
                hasHeaderSection: false,
                hasFooterSection: false,
                isHeaderCollapsible: false,
                isDummyLoad: false,
                enableRefresh: false,
                isShowRefreshing: false,
                emptyDataText: kEmptyString,
                emptyDataIconImage: UIImage(named: "empty_event"),
                emptyDataDescription: "looking a bit empty!, not a single outing hase been created by you and you have not been invited to any outing",
                delegate: self)
        } else if type == .createdByMe {
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
                emptyDataDescription: "looking a bit empty!, not a single outing hase been created by you...!",
                delegate: self)
        } else if type == .createdByMe {
            _tableView.setup(
                cellPrototypes: _prototype,
                hasHeaderSection: false,
                hasFooterSection: false,
                isHeaderCollapsible: false,
                isDummyLoad: false,
                enableRefresh: false,
                isShowRefreshing: false,
                emptyDataText: kEmptyString,
                emptyDataIconImage: UIImage(named: "empty_event"),
                emptyDataDescription: "looking a bit empty!, not a single outing hase been completed...!",
                delegate: self)
        } else {
            _tableView.setup(
                cellPrototypes: _prototype,
                hasHeaderSection: false,
                hasFooterSection: false,
                isHeaderCollapsible: false,
                isDummyLoad: false,
                enableRefresh: false,
                isShowRefreshing: false,
                emptyDataText: kEmptyString,
                emptyDataIconImage: UIImage(named: "empty_following"),
                emptyDataDescription: "looking a bit empty!, you have not been invited to any outing...!",
                delegate: self)
        }
        _tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 70, right: 0)
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        _outingList.forEach { model in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: model.id,
                kCellObjectDataKey: model,
                kCellClassKey: OutingTableCell.self,
                kCellHeightKey: OutingTableCell.height
            ])
        }
        if cellData.count != .zero {
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        }
        _tableView.loadData(cellSectionData)
    }
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: OutingTableCell.self, kCellHeightKey: OutingTableCell.height]]
    }
}

extension OutingListVC: CustomNoKeyboardTableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? OutingTableCell else { return }
        if let object = cellDict?[kCellObjectDataKey] as? OutingListModel {
            cell.setupData(object)
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if cell is OutingTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? OutingListModel else { return }
            let destinationViewController = INIT_CONTROLLER_XIB(OutingDetailVC.self)
            destinationViewController.outingId = object.id
//            let navigationController = UINavigationController(rootViewController: destinationViewController)
//            navigationController.modalPresentationStyle = .overFullScreen
            self.navigationController?.pushViewController(destinationViewController, animated: true) //present(navigationController, animated: true, completion: nil)
        }
    }
    
}
