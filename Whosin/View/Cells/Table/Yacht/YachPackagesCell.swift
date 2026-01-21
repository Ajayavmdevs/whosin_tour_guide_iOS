import UIKit

class YachPackagesCell: UITableViewCell {

    @IBOutlet weak var _titleView: UILabel!
//    @IBOutlet weak var _addOnView: CustomYachtAdonview!
//    @IBOutlet weak var _packageView: CustomYachPackgeview!
    @IBOutlet private weak var _collectionView: CustomCollectionView!
    @IBOutlet private weak var _collectionViewHieghtConstraint: NSLayoutConstraint!
    private let kCellIdentifier = String(describing: YachtPackageCollectionCell.self)
    private var selectedIndex: Int?
    public var isHourly: Bool = false
    private static var _selectedPackage: YachtPackgeModel?
    private static var _selectedAddOns: AddOnsModel?

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
    static var selectedPackage: YachtPackgeModel? {
        get {
            return _selectedPackage
        }
        set(newValue) {
            _selectedPackage = newValue
        }
    }
    
    static var selectedAddOns: AddOnsModel? {
        get {
            return _selectedAddOns
        }
        set(newValue) {
            _selectedAddOns = newValue
        }
    }

    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        setupUI()
    }

    private func setupUI() {
        _collectionView.setup(cellPrototypes: _prototypes,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1,
                              rows: 5,
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: YachtPackageCollectionCell.self, kCellHeightKey: YachtPackageCollectionCell.height]]
    }

    private func _loadData(_ model: [AddOnsModel]) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        model.forEach { packages in
            cellData.append([
                kCellIdentifierKey: self.kCellIdentifier,
                kCellTagKey: packages.id,
                kCellObjectDataKey: packages.detached(),
                kCellClassKey: YachtPackageCollectionCell.self,
                kCellHeightKey: YachtPackageCollectionCell.height
            ])
        }
                self._collectionViewHieghtConstraint.constant =  CGFloat(cellData.count) * YachtPackageCollectionCell.height

            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
//            DISPATCH_ASYNC_MAIN {
                self._collectionView.loadData(cellSectionData)
//            }
//        }
    }
    
    private func _loadDataPackage(_ model: [YachtPackgeModel]) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
//
//        DISPATCH_ASYNC_BG {
            model.forEach { packages in
                cellData.append([
                    kCellIdentifierKey: self.kCellIdentifier,
                    kCellTagKey: packages.id,
                    kCellObjectDataKey: packages.detached(),
                    kCellClassKey: YachtPackageCollectionCell.self,
                    kCellHeightKey: YachtPackageCollectionCell.height
                ])
            }
            self._collectionViewHieghtConstraint.constant = CGFloat(cellData.count) * YachtPackageCollectionCell.height
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
//            DISPATCH_ASYNC_MAIN {
                self._collectionView.loadData(cellSectionData)
//            }
//        }
    }
    // --------------------------------------
    // MARK: public
    // --------------------------------------

    public func setupPackage(_ model: [YachtPackgeModel], type: String) {
        _titleView.text = "available_packages".localized()
        isHourly = type == "hourly"
        _loadDataPackage(model)
    }
    
    
    public func setupAddon(_ model: [AddOnsModel]) {
        _titleView.text = "select_get_extra_addOnce".localized()
        _loadData(model)

    }
}

extension YachPackagesCell: CustomCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? YachtPackageCollectionCell else { return }
        if let object = cellDict?[kCellObjectDataKey] as? AddOnsModel {
            if selectedIndex == indexPath.row {
                cell.select(true)
            } else {
                cell.unselect(true)
            }
            cell.setupAddOns(model: object)
        } else if let object = cellDict?[kCellObjectDataKey] as? YachtPackgeModel {
            if selectedIndex == indexPath.row {
                cell.select(false)
            } else {
                cell.unselect(false)
            }
            cell.setupPackage(model: object, isHourly: isHourly)

        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        selectedIndex = selectedIndex == indexPath.row ? nil : indexPath.row
        if let object = cellDict?[kCellObjectDataKey] as? YachtPackgeModel {
            YachPackagesCell._selectedPackage = object
        } else if let object = cellDict?[kCellObjectDataKey] as? AddOnsModel {
            YachPackagesCell._selectedAddOns = object
        }
        _collectionView.reload()
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: YachtPackageCollectionCell.height)
    }
    
}
