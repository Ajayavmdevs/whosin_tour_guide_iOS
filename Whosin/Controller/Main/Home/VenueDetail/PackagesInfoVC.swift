import UIKit

protocol ShowMembershipInfoDelegate {
    func ShowMembershipDetail()
}

class PackagesInfoVC: ChildViewController {

    @IBOutlet private weak var _getNowButtonView: GradientView!
    @IBOutlet private weak var _tableView: CustomTableView!
    @IBOutlet private weak var _titleText: UILabel!
    @IBOutlet private weak var _descTitle: UILabel!
    @IBOutlet private weak var _getMemberBtn: UIButton!
    public var delegate: ShowMembershipInfoDelegate?
    private let kCellIdentifierPackageDetail = String(describing: PackageDescTableCell.self)
    public var packageModel: [PackageModel] = []

    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    override func setupUi() {
        if APPSETTING.subscription?.userId == APPSESSION.userDetail?.id {
            _titleText.text = "Our Packages"
            _descTitle.isHidden = true
            _getNowButtonView.isHidden = true
        } else {
            _titleText.text = "GET YOUR MEMBERSHIP NOW!"
            _descTitle.isHidden = false
            _getNowButtonView.isHidden = false
        }
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "There is no data available",
            emptyDataIconImage: UIImage(named: "empty_offers"),
            emptyDataDescription: nil,
            delegate: self)
        _loadData()
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        packageModel.forEach { model in
            cellData.append([
                kCellIdentifierKey: kCellIdentifierPackageDetail,
                kCellTagKey: kCellIdentifierPackageDetail,
                kCellObjectDataKey: model,
                kCellClassKey: PackageDescTableCell.self,
                kCellHeightKey: PackageDescTableCell.height
            ])

        }
        
        if cellData.count != .zero {
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        }
        _tableView.loadData(cellSectionData)
    }
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierPackageDetail, kCellNibNameKey: kCellIdentifierPackageDetail, kCellClassKey: PackageDescTableCell.self, kCellHeightKey: PackageDescTableCell.height],
        ]
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        feedbackGenerator?.impactOccurred()
        dismiss(animated: true)
    }
    
    @IBAction func _handleGetMembership(_ sender: UIButton) {
        feedbackGenerator?.impactOccurred()
        dismiss(animated: true)
        delegate?.ShowMembershipDetail()
    }
}

extension PackagesInfoVC: CustomTableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? PackageDescTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? PackageModel else { return }
            cell.setupData(object)
        }
    }
    
}
