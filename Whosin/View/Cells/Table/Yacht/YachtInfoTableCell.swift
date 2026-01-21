import UIKit

class YachtInfoTableCell: UITableViewCell {

    @IBOutlet private weak var _collectionView: CustomCollectionView!
    private let kCellIdentifier = String(describing: YachtInfoCollectionCell.self)
    private var _yachtsModel: [YachtDetailModel] = []
    private var _yachClubModel: YachtClubModel?

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
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: YachtInfoCollectionCell.self, kCellHeightKey: YachtInfoCollectionCell.height]]
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
        _collectionView.contentInset = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        _yachtsModel.forEach { model in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: model.id,
                kCellObjectDataKey: model,
                kCellClassKey: YachtInfoCollectionCell.self,
                kCellHeightKey: YachtInfoCollectionCell.height
            ])
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }
    
    public func setupData(_ data: [YachtDetailModel], venueModel: YachtClubModel? = nil) {
        _yachtsModel = data
        _yachClubModel = venueModel
        _loadData()
    }

}

extension YachtInfoTableCell: CustomCollectionViewDelegate {
        
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
            guard let cell = cell as? YachtInfoCollectionCell ,let object = cellDict?[kCellObjectDataKey] as? YachtDetailModel else { return }
                cell.setUpdata(object)
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: kScreenWidth * 0.75, height: YachtInfoCollectionCell.height)
    }

}

