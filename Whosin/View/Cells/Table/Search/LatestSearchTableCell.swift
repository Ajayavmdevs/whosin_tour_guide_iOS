import UIKit

class LatestSearchTableCell: UITableViewCell {
    
    @IBOutlet private weak var _collectionView: CustomCollectionView!
    private let kCellIdentifier = String(describing: SearchStroyCollectionCell.self)
    private let kCellIdentifierDeals = String(describing: BucketDealCollectionCell.self)
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat {
        120
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        _setupUi()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
        _collectionView.setup(cellPrototypes: _prototypes,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 5,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0),
                              spacing: CGSize(width: 15, height: 15),
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }
    
    private var _prototypes: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: SearchStroyCollectionCell.self, kCellHeightKey: SearchStroyCollectionCell.height]
        ]
    }
    
    private func _loadData() {
        
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        cellData.append([
            kCellIdentifierKey: kCellIdentifier,
            kCellTagKey: kCellIdentifier,
            kCellObjectDataKey: 1,
            kCellClassKey: SearchStroyCollectionCell.self,
            kCellHeightKey: SearchStroyCollectionCell.height
        ])
        
        cellData.append([
            kCellIdentifierKey: kCellIdentifier,
            kCellTagKey: kCellIdentifier,
            kCellObjectDataKey: 1,
            kCellClassKey: SearchStroyCollectionCell.self,
            kCellHeightKey: SearchStroyCollectionCell.height
        ])
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ storyId: String) {
        _loadData()
    }
    
}

extension LatestSearchTableCell: CustomCollectionViewDelegate {
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? SearchStroyCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? String else { return }
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70, height: 80)
    }
}
