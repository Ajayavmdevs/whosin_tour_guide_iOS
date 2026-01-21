import UIKit

protocol CustomSearchHeaderViewDelegate: AnyObject {
    func didSelectCategory(_ day: String)
}

class CustomSearchHeaderView: UIView {
    weak var delegate: CustomSearchHeaderViewDelegate?
    
    private var collectionView: CustomCollectionView!
    private let kCellIdentifier = String(describing: SearchHeaderCollectionCell.self)
    private var daysArray: [String] = []
    private var selectedIndex: Int = 0
    private var bottomLineLayer: CALayer! // Add this property

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUi()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: String(describing: SearchHeaderCollectionCell.self), kCellClassKey: SearchHeaderCollectionCell.self, kCellHeightKey: SearchHeaderCollectionCell.height]]
    }
    
        private func _loadData() {
            var cellSectionData = [[String: Any]]()
            var cellData = [[String: Any]]()
    
            daysArray.forEach { day in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: kCellIdentifier,
                    kCellObjectDataKey: day,
                    kCellClassKey: SearchHeaderCollectionCell.self,
                    kCellHeightKey: SearchHeaderCollectionCell.height
                ])
            }
    
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
            collectionView.loadData(cellSectionData)
        }
    
    private func setupUi() {
        bottomLineLayer = CALayer()
        bottomLineLayer.backgroundColor = ColorBrand.brandGray.cgColor
        bottomLineLayer.frame = CGRect(x: 0, y: bounds.height - 1, width: bounds.width, height: 1)
        layer.addSublayer(bottomLineLayer)

        let layout = UICollectionViewFlowLayout()
        collectionView = CustomCollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.frame = bounds.insetBy(dx: 10, dy: 10)
        collectionView.backgroundColor = .clear
        collectionView.layer.cornerRadius = 10
        collectionView.clipsToBounds = true
        collectionView.setup(cellPrototypes: prototype,
                             hasHeaderSection: false,
                             enableRefresh: false,
                             columns: 5,
                             rows: 1,
                             edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
                             spacing: CGSize(width: 5, height: 5),
                             scrollDirection: .horizontal,
                             emptyDataText: nil,
                             emptyDataIconImage: nil,
                             delegate: self)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        addSubview(collectionView)
    }


    
    public func setupData(_ data: [String], selectedDay: String) {
        daysArray = data
        _loadData()
        collectionView.reloadData()
        let lowercasedSelectedDay = selectedDay.lowercased()
        if let selectedIndex = daysArray.firstIndex(where: { $0.lowercased() == lowercasedSelectedDay }) {
            self.selectedIndex = selectedIndex
        } else {
            self.selectedIndex = 0
        }

    }
}

extension CustomSearchHeaderView: CustomCollectionViewDelegate, UICollectionViewDelegate {
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? SearchHeaderCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? String else { return }
            if selectedIndex == indexPath.row {
                cell._selectedView.isHidden = false
            } else {
                cell._selectedView.isHidden = true
            }
            cell.setupData(data: object)
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        var maxWidth: CGFloat = 0.0
        for day in daysArray {
            let width = day.widthOfString(usingFont: FontBrand.SFsemiboldFont(size: 16))
            if width > maxWidth {
                maxWidth = width
            }
        }
        return CGSize(width: maxWidth + 15, height:SearchHeaderCollectionCell.height)
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        selectedIndex = indexPath.row
        delegate?.didSelectCategory(daysArray[selectedIndex].lowercased())
        collectionView.reload()
    }
}

