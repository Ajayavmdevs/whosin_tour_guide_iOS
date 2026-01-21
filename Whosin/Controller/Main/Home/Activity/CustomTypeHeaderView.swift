import UIKit

protocol CustomTypeHeaderViewDelegate: AnyObject {
    func didSelectType(_ id: String)
}

class CustomTypeHeaderView: UIView {
    weak var delegate: CustomTypeHeaderViewDelegate?
    
    private var collectionView: CustomCollectionView!
    private let kCellIdentifier = String(describing: DaysCollectionCell.self)
    private var typeArray: [ActivityTypeModel] = []
    private var selectedIndex: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUi()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: String(describing: DaysCollectionCell.self), kCellClassKey: DaysCollectionCell.self, kCellHeightKey: DaysCollectionCell.height]]
    }
    
        private func _loadData() {
            var cellSectionData = [[String: Any]]()
            var cellData = [[String: Any]]()
    
            typeArray.forEach { day in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: kCellIdentifier,
                    kCellObjectDataKey: day,
                    kCellClassKey: DaysCollectionCell.self,
                    kCellHeightKey: DaysCollectionCell.height
                ])
            }
    
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
            collectionView.loadData(cellSectionData)
        }
    
    private func setupUi() {
        let layout = UICollectionViewFlowLayout()
        collectionView = CustomCollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.layer.cornerRadius = 10
        collectionView.clipsToBounds = true
        collectionView.setup(cellPrototypes: prototype,
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
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        addSubview(collectionView)
    }

    
    public func setupData(_ data: [ActivityTypeModel], selectedTypeId: String) {
        typeArray = data
        _loadData()
        collectionView.reloadData()
        if let selectedIndex = typeArray.firstIndex(where: { $0.id == selectedTypeId }) {
            self.selectedIndex = selectedIndex
        } else {
            self.selectedIndex = 0
        }
    }
}

extension CustomTypeHeaderView: CustomCollectionViewDelegate, UICollectionViewDelegate {
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? DaysCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? ActivityTypeModel else { return }
            cell._closeBtn.isHidden = true
            if selectedIndex == indexPath.row {
                cell._bgView.backgroundColor = ColorBrand.brandGreen
            } else {
                cell._bgView.backgroundColor = UIColor.init(hex: "#3F3E42")
            }
            cell.setUpdata(object.title)
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        let currentDay = typeArray[indexPath.row].title
        let currentDayWidth = currentDay.widthOfString(usingFont: FontBrand.SFsemiboldFont(size: 16))
        return CGSize(width: currentDayWidth + 26, height:DaysCollectionCell.height)
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        selectedIndex = indexPath.row
        delegate?.didSelectType(typeArray[selectedIndex].id)
        collectionView.reload()
    }
}
