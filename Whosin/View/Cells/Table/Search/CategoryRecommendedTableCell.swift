import UIKit
import AudioToolbox


class CategoryRecommendedTableCell: UITableViewCell {
    
    @IBOutlet weak var _titleLabel: UILabel!
    @IBOutlet  weak var _collectionView: CustomNoKeyboardCollectionView!
    private let kCellIdentifier = String(describing: CategoriesCollectionCell.self)
    private var _categoryModel: [CategoryDetailModel] = []
    
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        210
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
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: CategoriesCollectionCell.self, kCellHeightKey: CategoriesCollectionCell.height]]
    }
    
    private func setupUi() {
        _collectionView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 2.1,
                              rows: 2,
                              edgeInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0),
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
        
        _categoryModel.forEach { categoryModel in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: categoryModel.id,
                kCellObjectDataKey: categoryModel,
                kCellClassKey: CategoriesCollectionCell.self,
                kCellHeightKey: CategoriesCollectionCell.height
            ])
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: [CategoryDetailModel]) {
        _categoryModel = data
        _loadData()
    }
    
}

// --------------------------------------
// MARK: Custom Collection View
// --------------------------------------

extension CategoryRecommendedTableCell: CustomNoKeyboardCollectionViewDelegate {
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? CategoriesCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? CategoryDetailModel else { return }
            cell.setUpdata(object)
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        guard let object = cellDict?[kCellObjectDataKey] as? CategoryDetailModel else { return }
        
        let controller = INIT_CONTROLLER_XIB(CategoryDetailVC.self)
        controller.categoryDetailModel = object
        controller.titleStr = object.title
        controller.hidesBottomBarWhenPushed = false
        parentViewController?.navigationController?.pushViewController(controller, animated: true)
        
    }

    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: kScreenWidth * 0.45, height: CategoriesCollectionCell.height)
    }

}
