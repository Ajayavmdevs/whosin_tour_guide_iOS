import UIKit
import PanModal

protocol DidSelectPackageDelegate: AnyObject {
    func didSelectPackage(_ package: PackageModel)
    func didSelectSenfGift(_ package: PackageModel)

}

class BottomSheetVC: PanBaseViewController {
        
    @IBOutlet private weak var _containerView: UIView!
    @IBOutlet private weak var _tableView: CustomTableView!
    @IBOutlet private weak var _tableViewHeight: NSLayoutConstraint!
    public var packages: [PackageModel] = []
    public var itemModel: [VoucherItems] = []
    private let kCellIdentifier = String(describing: PackageSelectTableCell.self)
    public var delegate: DidSelectPackageDelegate?
    public var isFromSendGift: Bool = false
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
        _loadData()
    }
    
    override func setupUi() {
        _tableView.setup(
            cellPrototypes: _prototypes,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            emptyDataText: nil,
            emptyDataIconImage: nil,
            emptyDataDescription: nil,
            delegate: self)
        _tableView.contentInset = .zero
    }
    
    // --------------------------------------
    // MARK: Data
    // --------------------------------------
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        packages.forEach { option in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: option.id,
                kCellObjectDataKey: option,
                kCellClassKey: PackageSelectTableCell.self,
                kCellHeightKey: PackageSelectTableCell.height
            ])
        }
                
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: String(describing: PackageSelectTableCell.self), kCellClassKey: PackageSelectTableCell.self, kCellHeightKey: PackageSelectTableCell.height] ]
    }
    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

extension BottomSheetVC: CustomTableViewDelegate {
    
    // --------------------------------------
    // MARK: <CustomTableViewDelegate>
    // --------------------------------------
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? PackageSelectTableCell,
              let object = cellDict?[kCellObjectDataKey] as? PackageModel else { return }
        cell.setupData(object, item: itemModel.first(where: { $0.packageId == object.id}) ?? VoucherItems())
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? PackageModel else { return }
        dismiss(animated: true) {
            if self.isFromSendGift {
                self.delegate?.didSelectSenfGift(object)
            } else {
                self.delegate?.didSelectPackage(object)
            }
        }
    }
}
