import UIKit
import WebKit

protocol dismissDelegate {
    func dismiss()
}

class BundlePlanDetailsVC: ChildViewController {
    
    @IBOutlet weak var _discountText: UILabel!
    @IBOutlet weak var _subTitle: UILabel!
    @IBOutlet weak var _tableView: CustomNoKeyboardTableView!
    @IBOutlet weak var _planName: UILabel!
    @IBOutlet weak var _validTilllDate: UILabel!
    public var subscription: MembershipPackageModel?
    private let kCellIdentifier = String(String(describing: FeaturesTableCell.self))
    public var delegate: dismissDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        hideNavigationBar()
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "Somthing wrong..!",
            emptyDataIconImage: UIImage(named: "empty_offers"),
            emptyDataDescription: nil,
            delegate: self)
        _loadData()
    }
    
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: FeaturesTableCell.self, kCellHeightKey: FeaturesTableCell.height]]
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        _validTilllDate.text = "validity".localized() + "\(subscription?.validTill ?? kEmptyString)"
        _planName.text = subscription?.title ?? kEmptyString
        _subTitle.text = subscription?.descriptions
//        _discountText.text = subscription?.discountText
        guard let feature = subscription?.feature else { return }
        feature.forEach({ model in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: model,
                kCellClassKey: FeaturesTableCell.self,
                kCellHeightKey: FeaturesTableCell.height
            ])
        })
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }

    @IBAction func _handleBackEvent(_ sender: UIButton) {
        dismissAllPresentedControllers(animated: true)
    }
    
    @IBAction func _handleCancelBundleEvent(_ sender: UIButton) {
    }
    
}

extension BundlePlanDetailsVC: CustomNoKeyboardTableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? FeaturesTableCell, let object = cellDict?[kCellObjectDataKey] as? CommonSettingsModel else { return}
        cell.setup(object.icon, title: object.feature)
    }
}
