import UIKit

class ProfileFilterTableCell: UITableViewCell {

    @IBOutlet weak var _backgroundView: UIView!
    @IBOutlet weak var _customHeaderView: UIView!
    @IBOutlet weak var _customCollectionView: CustomNoKeyboardCollectionView!
    @IBOutlet weak var _searchBar: UISearchBar!
    private let kCellIdentifier = String(describing: FilterCollectionCell.self)
    private var daysArray: [String] = []
    private var selectedIndex: Int?
    public var callback: ((_ filter: String) -> Void)?

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        return 120
    }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        _setupUi()
    }

    private var prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: String(describing: FilterCollectionCell.self), kCellClassKey: FilterCollectionCell.self, kCellHeightKey: FilterCollectionCell.height]]
    }

    private func _setupUi() {
        _customCollectionView.bounds = bounds
        _customCollectionView.backgroundColor = .clear
        _customCollectionView.layer.cornerRadius = 10
        _customCollectionView.clipsToBounds = true
        _customCollectionView.setup(cellPrototypes: prototype,
                             hasHeaderSection: false,
                             enableRefresh: false,
                             columns: 5,
                             rows: 1,
                             edgeInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10),
                             spacing: CGSize(width: 3, height: 3),
                             scrollDirection: .horizontal,
                             emptyDataText: nil,
                             emptyDataIconImage: nil,
                             delegate: self)
        _customCollectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        _customCollectionView.showsVerticalScrollIndicator = false
        _customCollectionView.showsHorizontalScrollIndicator = false
        _searchBar.placeholder = "search_favorite_events".localized()
        _searchBar.searchTextField.backgroundColor = UIColor(white: 1, alpha: 0.08)
        _searchBar.searchTextField.layer.cornerRadius = 18
        _searchBar.searchTextField.layer.masksToBounds = true
        _searchBar.searchTextField.textColor = .white


    }

    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()

        daysArray.forEach { day in
            var cellDict: [String: Any] = [
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: day,
                kCellClassKey: FilterCollectionCell.self,
                kCellHeightKey: FilterCollectionCell.height
            ]
            cellData.append(cellDict)
        }

        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _customCollectionView.loadData(cellSectionData)
    }
    
    public func setData() {
        daysArray = APPSETTING.categories?.map { $0.title } ?? []
        daysArray.insert("starting_soon".localized(), at: 0)
        daysArray.insert("near_me".localized(), at: 0)
        _loadData()
    }

}

extension ProfileFilterTableCell: CustomNoKeyboardCollectionViewDelegate, UICollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? FilterCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? String else { return }
            if selectedIndex == indexPath.row {
                cell._bgView.borderWidth = 0
                cell._bgView.borderColor = ColorBrand.brandgradientPink
            } else {
                cell._bgView.borderWidth = 0
            }
            cell.setUpdata(object, isSelected: selectedIndex == indexPath.row)
        }
    }

    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        if let isFromExplore = cellDict?[kCellTitleKey] as? Bool, isFromExplore {
            let currentDay = daysArray[indexPath.row]
            let currentDayWidth = currentDay.widthOfString(usingFont: FontBrand.SFsemiboldFont(size: 16))

            return CGSize(width: currentDayWidth + 50, height:FilterCollectionCell.height)
        } else {
            let currentDay = daysArray[indexPath.row]
            let currentDayWidth = currentDay.widthOfString(usingFont: FontBrand.SFsemiboldFont(size: 16))
            
            return CGSize(width: currentDayWidth + 26, height:FilterCollectionCell.height)
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        selectedIndex = indexPath.row
        callback?(daysArray[indexPath.row])
        _customCollectionView.reload()
    }
}
