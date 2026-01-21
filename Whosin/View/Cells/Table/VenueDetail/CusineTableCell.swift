import UIKit

class CusineTableCell: UITableViewCell {

    @IBOutlet private  weak var _collectionView: CustomCollectionView!
    private let kCellIdentifier = String(describing: CuisineCollectionCell.self)

    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat {
        60
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: String(describing: CuisineCollectionCell.self), kCellClassKey: CuisineCollectionCell.self, kCellHeightKey: CuisineCollectionCell.height]]
    }
    
    private func setupUi() {
        _collectionView.layer.cornerRadius = 10
        _collectionView.clipsToBounds = true
        _collectionView.setup(cellPrototypes: _prototype,
                                   hasHeaderSection: false,
                                   enableRefresh: false,
                                   columns: 5,
                                   rows: 1,
                                    edgeInsets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0),
                                    spacing: CGSize(width: 5, height: 5),
                                   scrollDirection: .horizontal,
                                   emptyDataText: nil,
                                   emptyDataIconImage: nil,
                                   delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
        _loadData()
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        APPSETTING.cuisine.forEach { cuisineModel in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: cuisineModel.id,
                kCellObjectDataKey: cuisineModel,
                kCellClassKey: CuisineCollectionCell.self,
                kCellHeightKey: CuisineCollectionCell.height
            ])
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }

    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ model: VenueDetailModel) {
        setupUi()
    }

}

extension CusineTableCell: CustomCollectionViewDelegate, UICollectionViewDelegate {
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? CuisineCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? CommonSettingsModel else { return }
            cell.setUpdata(object)
        }
    }
       
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        let width = APPSETTING.cuisine[indexPath.row].title.widthOfString(usingFont: FontBrand.SFlightFont(size: 11))
        return CGSize(width: width + 26, height:CuisineCollectionCell.height)
    }
}
