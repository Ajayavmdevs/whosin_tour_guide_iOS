import UIKit
import AudioToolbox
import Hero

class CategoryTableCell: UITableViewCell {

    @IBOutlet private weak var _titleLabel: UILabel!
    @IBOutlet private weak var _collectionView: CustomNoKeyboardCollectionView!
    private let kCellIdentifier = String(describing: CategoriesCollectionCell.self)
    private var categoryModel: [CategoryDetailModel] = []
    private var cateforyId: String = kEmptyString
    private var _homeBlock: HomeBlockModel?


    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        setupUi()
    }
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat {
        143
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self._loadData()
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
                                   columns: 3,
                                   rows: 1,
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
        
        categoryModel.forEach { categoryModel in
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
        _titleLabel.text = "categories".localized()
        categoryModel = data
        _loadData()
    }
    
    public func setupData(_ block: HomeBlockModel) {
        _homeBlock = block
        categoryModel = block.ticketCategoryList
        _titleLabel.text = block.title
        _loadData()
    }
    
    public func setupExploreData(_ block: HomeBlockModel) {
        _homeBlock = block
        categoryModel = block.categoryList
        _titleLabel.text = block.title
        _loadData()
    }

}

extension CategoryTableCell: CustomNoKeyboardCollectionViewDelegate {
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? CategoriesCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? CategoryDetailModel else { return }
            cell.setUpdata(object, isboldText: _homeBlock != nil)
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: kScreenWidth * 0.45, height: CategoriesCollectionCell.height)
    }

    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        guard let object = cellDict?[kCellObjectDataKey] as? CategoryDetailModel else { return }
        if _homeBlock != nil {
            guard let object = cellDict?[kCellObjectDataKey] as? CategoryDetailModel else { return }
            let controller = INIT_CONTROLLER_XIB(ExploreDetailVC.self)
            controller.isFromCities = false
            controller.selectedFilter = object.id
            controller.titleText = object.title
            controller.hidesBottomBarWhenPushed = false
            parentViewController?.navigationController?.pushViewController(controller, animated: true)
        } else {
            let controller = INIT_CONTROLLER_XIB(CategoryDetailVC.self)
            controller.categoryDetailModel = object
            controller.titleStr = object.title
            controller.hidesBottomBarWhenPushed = false
            parentViewController?.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
}
