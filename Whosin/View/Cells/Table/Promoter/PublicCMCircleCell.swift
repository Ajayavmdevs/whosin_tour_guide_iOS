import UIKit

class PublicCMCircleCell: UITableViewCell {

    @IBOutlet private weak var _collectionView: CustomCollectionView!
    private let kCellIdentifier = String(describing: PublicCMCircleCollectionCell.self)

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }

    override func awakeFromNib() {
        super.awakeFromNib()
       disableSelectEffect()
        _setupCollectionView()
    }

    private func _setupCollectionView() {
        _collectionView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 4,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18),
                              spacing: CGSize(width: 0, height: 0),
                              scrollDirection: .horizontal,
                              emptyDataText: "There is no circles available",
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }
    
    private func _loadData(_ circle: [UserDetailModel]) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        circle.forEach({ model in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: model,
                kCellClassKey: PublicCMCircleCollectionCell.self,
                kCellHeightKey: PublicCMCircleCollectionCell.height
            ])
        })
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: PublicCMCircleCollectionCell.self, kCellHeightKey: PublicCMCircleCollectionCell.height]]
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ model: [UserDetailModel]) {
        _loadData(model)
    }

}

extension PublicCMCircleCell: CustomCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? PublicCMCircleCollectionCell, let object = cellDict?[kCellObjectDataKey] as? UserDetailModel  else { return }
            cell.setup(object)
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        guard let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return CGSize() }
        let width = object.title.widthOfString(usingFont: FontBrand.SFsemiboldFont(size: 18)) + 65
        return CGSize(width: width > 120 ? width : 120, height: PublicCMCircleCollectionCell.height)
    }
    
}
