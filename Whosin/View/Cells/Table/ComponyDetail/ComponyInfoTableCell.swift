import UIKit

class ComponyInfoTableCell: UITableViewCell {

    @IBOutlet private weak var _collectionView: CustomCollectionView!
    private let kCellIdentifier = String(describing: ComponyInfoCollectionCell.self)
    private var _dealsModel: [DealsModel] = []
    private var _venueDetailModel: VenueDetailModel?

    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat {
        174
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUi()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: ComponyInfoCollectionCell.self, kCellHeightKey: ComponyInfoCollectionCell.height]]
    }
    
    private func setupUi() {
        disableSelectEffect()
        _collectionView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1,
                              rows: 1,
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        _dealsModel.forEach { dealsModel in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: dealsModel.id,
                kCellObjectDataKey: dealsModel,
                kCellClassKey: ComponyInfoCollectionCell.self,
                kCellHeightKey: ComponyInfoCollectionCell.height
            ])
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }
    
    public func setupData(_ data: [DealsModel], venueModel: VenueDetailModel? = nil) {
        _dealsModel = data
        _venueDetailModel = venueModel
        _loadData()
    }

}

extension ComponyInfoTableCell: CustomCollectionViewDelegate {
        
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
            guard let cell = cell as? ComponyInfoCollectionCell ,let object = cellDict?[kCellObjectDataKey] as? DealsModel else { return }
                cell.setUpdata(object)
        if _venueDetailModel != nil {
            cell._imageiView.loadWebImage(_venueDetailModel?.cover ?? kEmptyString)
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: kScreenWidth * 0.70, height: ComponyInfoCollectionCell.height)
    }

}

