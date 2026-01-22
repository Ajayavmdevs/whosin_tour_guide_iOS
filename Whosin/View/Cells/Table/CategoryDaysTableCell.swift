import UIKit

protocol CustomDaysHeaderViewDelegate: AnyObject {
    func didSelectDay(_ day: String)
    func removeAction(filter: String)
}

class CustomDaysHeaderView: UIView {
    weak var delegate: CustomDaysHeaderViewDelegate?
    
    private var collectionView: CustomCollectionView!
    private let kCellIdentifier = String(describing: DaysCollectionCell.self)
    private var daysArray: [String] = []
    private var selectedIndex: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUi()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUi()
    }

    
    private var prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: String(describing: DaysCollectionCell.self), kCellClassKey: DaysCollectionCell.self, kCellHeightKey: DaysCollectionCell.height]]
    }
    
    private func _loadData(isFromExplore: Bool) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()

        daysArray.forEach { day in
            var cellDict: [String: Any] = [
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellTitleKey: isFromExplore,
                kCellObjectDataKey: day,
                kCellClassKey: DaysCollectionCell.self,
                kCellHeightKey: DaysCollectionCell.height
            ]
            cellData.append(cellDict)
        }

        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        collectionView.loadData(cellSectionData)
    }

    private func setupUi() {
        self.backgroundColor = .clear

        let layout = UICollectionViewFlowLayout()
        collectionView = CustomCollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.bounds = bounds
        collectionView.backgroundColor = .clear
        collectionView.layer.cornerRadius = 10
        collectionView.clipsToBounds = true
        collectionView.setup(cellPrototypes: prototype,
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
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        addSubview(collectionView)
    }

    
    public func setupData(_ data: [String], selectedDay: String, isFromExplore: Bool) {
        daysArray = data
        _loadData(isFromExplore: isFromExplore)
        collectionView.reloadData()
        let lowercasedSelectedDay = selectedDay.lowercased()
        if let selectedIndex = daysArray.firstIndex(where: { $0.lowercased() == lowercasedSelectedDay }) {
            self.selectedIndex = selectedIndex
        } else {
            self.selectedIndex = 0
        }
    }
}

extension CustomDaysHeaderView: CustomCollectionViewDelegate, UICollectionViewDelegate, DaysCollectionCellDelegate {
    func closeButtonTapped(_ day: String) {
        delegate?.removeAction(filter: day)
    }
        
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? DaysCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? String, let isFromExplore = cellDict?[kCellTitleKey] as? Bool else { return }
            if selectedIndex == indexPath.row {
                cell._bgView.borderWidth = isFromExplore ? 0 : 0.7
                cell._bgView.borderColor = ColorBrand.brandgradientPink
            } else {
                cell._bgView.borderWidth = 0
            }
            cell.setUpdata(object)
            cell._closeBtn.isHidden = !isFromExplore
            cell.delegate = self
        }
    }

    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        if let isFromExplore = cellDict?[kCellTitleKey] as? Bool, isFromExplore {
            let currentDay = daysArray[indexPath.row]
            let currentDayWidth = currentDay.widthOfString(usingFont: FontBrand.SFsemiboldFont(size: 16))

            return CGSize(width: currentDayWidth + 50, height:DaysCollectionCell.height)
        } else {
            let currentDay = daysArray[indexPath.row]
            let currentDayWidth = currentDay.widthOfString(usingFont: FontBrand.SFsemiboldFont(size: 16))
            
            return CGSize(width: currentDayWidth + 26, height:DaysCollectionCell.height)
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        selectedIndex = indexPath.row
        delegate?.didSelectDay(daysArray[selectedIndex].lowercased())
        collectionView.reload()
    }
}
