
import UIKit

class MyReviewsListVC: ChildViewController {
    
    
    @IBOutlet weak var _tableView: CustomNoKeyboardTableView!
    private let kCellIdentifier = String(describing: MyReviewsTableViewCell.self)
    private let kCellIdentifierLoading = String(describing: LoadingCell.self)
    private var _reviewList: [RatingModel] = []
    
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
            emptyDataText: "no_reviews".localized(),
            emptyDataIconImage: UIImage(named: "empty_follower"),
            emptyDataDescription: nil,
            delegate: self)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: kRelaodActivitInfo, object: nil)
        _getReviewList()
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
            _reviewList.forEach { block in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: kCellIdentifier,
                    kCellObjectDataKey: block,
                    kCellClassKey: MyReviewsTableViewCell.self,
                    kCellHeightKey: MyReviewsTableViewCell.height
                ])
            }

        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    private var _prototype: [[String: Any]]? {
        return [
                [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: MyReviewsTableViewCell.self, kCellHeightKey: MyReviewsTableViewCell.height],
                [kCellIdentifierKey: kCellIdentifierLoading, kCellNibNameKey: kCellIdentifierLoading, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height]

        ]
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _getReviewList() {
        WhosinServices.getReviewList { [weak self] container, error in
            guard let self = self else{ return}
            self.hideHUD(error: error)
            if let data = container?.data {
                self._reviewList = data
                self._loadData(false)
            } else {
                self._loadData(false)
            }
        }
    }

    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @objc func reloadData() {
        _getReviewList()
    }

    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}



// --------------------------------------
// MARK: Custom TableView
// --------------------------------------

extension MyReviewsListVC: CustomNoKeyboardTableViewDelegate {
    
    func refreshData() {
        _getReviewList()
    }
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? MyReviewsTableViewCell {
            guard let object = cellDict?[kCellObjectDataKey] as? RatingModel  else { return }
            cell.setUpdata(model:object)
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if cell is MyReviewsTableViewCell {
            guard let model = cellDict?[kCellObjectDataKey] as? RatingModel else { return }
            switch model.type {
            case "ticket":
                let vc = INIT_CONTROLLER_XIB(CustomTicketDetailVC.self)
                vc.ticketID = model.itemId
                navigationController?.pushViewController(vc, animated: true)
            default:
                return
            }
        }
    }
}
