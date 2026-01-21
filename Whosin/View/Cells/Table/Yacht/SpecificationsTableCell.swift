import UIKit

class SpecificationsTableCell: UITableViewCell {
    
    @IBOutlet weak var _collectionView: CustomCollectionView!
    @IBOutlet weak var _heightConstraint: NSLayoutConstraint!
    
    private var _specifications: [SpecificationsModel] = []
    private let kCellIdentifier = String(describing: SpecificationsCollectionCell.self)
    
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
        setupUi()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func setupUi() {
        _collectionView.setup(cellPrototypes: _prototypes,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 3,
                              rows: 1,
                              scrollDirection: .vertical,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: SpecificationsCollectionCell.self, kCellHeightKey: SpecificationsCollectionCell.height]]
    }
    
    private func _loadData(_ model: [SpecificationsModel]) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        model.forEach { packages in
            cellData.append([
                kCellIdentifierKey: self.kCellIdentifier,
                kCellTagKey: packages.id,
                kCellObjectDataKey: packages.detached(),
                kCellClassKey: SpecificationsCollectionCell.self,
                kCellHeightKey: SpecificationsCollectionCell.height
            ])
        }
        let numberOfRows = Int(ceil(CGFloat(cellData.count) / 3))
        self._heightConstraint.constant =  CGFloat(numberOfRows) * SpecificationsCollectionCell.height
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        self._collectionView.loadData(cellSectionData)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ model: [SpecificationsModel]) {
        _loadData(model)
    }
    
    
}


extension SpecificationsTableCell: CustomCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? SpecificationsCollectionCell, let object = cellDict?[kCellObjectDataKey] as? SpecificationsModel else { return }
        cell.setupData(object)
    }
    
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.size.width - 40) / 3
        return CGSize(width: width, height: SpecificationsCollectionCell.height)
    }
    
}
