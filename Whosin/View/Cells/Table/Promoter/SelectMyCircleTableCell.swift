import UIKit

class SelectMyCircleTableCell: UITableViewCell {
    
    @IBOutlet private weak var _selectAllBtn: CustomButton!
    @IBOutlet private weak var _collectionView: CustomCollectionView!
    private let kCellIdentifierShareWith = String(describing: MyVenuesCollectionCell.self)
    private var myCircleList: [UserDetailModel] = []
    public var selectedIdsCallback: ((_ ids: [String]) -> Void)?
    private var _selectedIDs: [String] = []
    public var selectAllCallback:((_ isSelectAll: Bool)-> Void)?
    private var isSelectAllCircle: Bool = false

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        _setupCollectionView()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupCollectionView() {
        let spacing = 10
        _collectionView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 3,
                              rows: 2,
                              edgeInsets: UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18),
                              spacing: CGSize(width: spacing, height: spacing),
                              scrollDirection: .horizontal,
                              emptyDataText: "There is no circles available",
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        if _selectedIDs.count == myCircleList.count, _selectedIDs.count > 0 || isSelectAllCircle {
            _selectAllBtn.setTitle("deselect_all".localized())
        } else {
            _selectAllBtn.setTitle("select_all".localized())
        }
        myCircleList.forEach({ model in
            cellData.append([
                kCellIdentifierKey: kCellIdentifierShareWith,
                kCellTagKey: kCellIdentifierShareWith,
                kCellObjectDataKey: model,
                kCellClassKey: MyVenuesCollectionCell.self,
                kCellHeightKey: MyVenuesCollectionCell.height
            ])
        })
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: String(describing: MyVenuesCollectionCell.self), kCellNibNameKey: String(describing: MyVenuesCollectionCell.self), kCellClassKey: MyVenuesCollectionCell.self, kCellHeightKey: MyVenuesCollectionCell.height]]
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ model: [UserDetailModel], selectedId: [String], isSelectAll: Bool = false) {
        self._selectedIDs = selectedId
        myCircleList = model
        isSelectAllCircle = isSelectAll
        _loadData()
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleSelectAllEvent(_ sender: CustomButton) {
        if _selectedIDs.count == myCircleList.count {
            _selectedIDs.removeAll()
        } else {
            _selectedIDs = myCircleList.map({ $0.id })
        }
        selectedIdsCallback?(_selectedIDs)
        isSelectAllCircle.toggle()
        selectAllCallback?(isSelectAllCircle)
        _loadData()
    }
}

extension SelectMyCircleTableCell: CustomCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? MyVenuesCollectionCell, let object = cellDict?[kCellObjectDataKey] as? UserDetailModel {
            cell.setupCircle(object, isSelected: _selectedIDs.contains(where: { $0 == object.id }))
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? MyVenuesCollectionCell, let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
        cell.venueImg.layer.cornerRadius = cell.venueImg.frame.height / 2
        if let index = _selectedIDs.firstIndex(of: object.id) {
            _selectedIDs.remove(at: index)
        } else {
            _selectedIDs.append(object.id)
        }
        selectedIdsCallback?(_selectedIDs)
        _loadData()
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: (kScreenWidth - 48) / 3.5, height: 130)
    }
    
}

