import UIKit

class DealRecommendedTableCell: UITableViewCell {
    
    @IBOutlet weak var _titleBgView: UIView!
    @IBOutlet private weak var _collectionView: CustomNoKeyboardCollectionView!
    @IBOutlet weak var _titleLabel: UILabel!
    private let kCellIdentifierDeals = String(describing: HomeBlockDealsCollectionView.self)
    private var _dealsModel: [DealsModel] = []
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        UITableView.automaticDimension
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
    
    private func setupUi() {
        _collectionView.setup(cellPrototypes: _collectionPrototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 0),
                              spacing: CGSize(width: 15, height: 15),
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
        _collectionView.contentInset = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        _dealsModel.forEach { deals in
            cellData.append([
                kCellIdentifierKey: kCellIdentifierDeals,
                kCellTagKey: kCellIdentifierDeals,
                kCellObjectDataKey: deals,
                kCellClassKey: HomeBlockDealsCollectionView.self,
                kCellHeightKey: HomeBlockDealsCollectionView.height
            ])
            
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }
    
    private var _collectionPrototype: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifierDeals, kCellNibNameKey: String(describing: HomeBlockDealsCollectionView.self), kCellClassKey: HomeBlockDealsCollectionView.self, kCellHeightKey: HomeBlockDealsCollectionView.height] ]
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: [DealsModel]) {
        _dealsModel = data
        _loadData()
    }
    
    
}

// --------------------------------------
// MARK: Custom Collection View
// --------------------------------------

extension DealRecommendedTableCell: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? HomeBlockDealsCollectionView ,let object = cellDict?[kCellObjectDataKey] as? DealsModel else { return }
        cell.setUpdata(object)
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? DealsModel else { return }
        let vc = INIT_CONTROLLER_XIB(DealsDetailVC.self)
        vc.dealsModel = object
        self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        if _dealsModel.count == 1 {
            return CGSize(width: collectionView.frame.width - 28, height: 400)
        } else {
            return CGSize(width: collectionView.frame.width * 0.8, height: 400)
        }
    }
    
}
