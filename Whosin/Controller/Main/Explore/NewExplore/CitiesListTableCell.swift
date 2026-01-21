import UIKit

class CitiesListTableCell: UITableViewCell {

    @IBOutlet private weak var _collectionView: CustomNoKeyboardCollectionView!
    @IBOutlet weak var _titleText: CustomLabel!
    @IBOutlet weak var _subTitleText: CustomLabel!
    private let kCellIdentifier = String(describing: CategoriesCollectionCell.self)
    private var categoryModel: [CategoryDetailModel] = []
    private var cateforyId: String = kEmptyString

    
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
        UITableView.automaticDimension
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
                                   edgeInsets: UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14),
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

    public func setupData(_ data: HomeBlockModel) {
        categoryModel = data.cityList
        _titleText.text = data.title
        _subTitleText.text = data.descriptions
        _titleText.isHidden = !data.showTitle
        _subTitleText.isHidden = !data.showTitle
        _loadData()
    }

}

extension CitiesListTableCell: CustomNoKeyboardCollectionViewDelegate {
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? CategoriesCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? CategoryDetailModel else { return }
            cell.setupExploredata(object)
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: kScreenWidth * 0.35, height: 60)
    }

    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        guard let object = cellDict?[kCellObjectDataKey] as? CategoryDetailModel else { return }
        let controller = INIT_CONTROLLER_XIB(ExploreDetailVC.self)
        controller.isFromCities = true
        controller.selectedFilter = object.id
        controller.titleText = object.name
        controller.hidesBottomBarWhenPushed = false
        parentViewController?.navigationController?.pushViewController(controller, animated: true)
    }
    
}
