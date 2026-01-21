import Foundation
import UIKit
import SnapKit

class CMEventStatusHeaderView: UIView {
    
    @IBOutlet weak var _backgroundView: UIView!
    @IBOutlet weak var _customHeaderView: UIView!
    @IBOutlet weak var _customCollectionView: CustomNoKeyboardCollectionView!
    private let kCellIdentifier = String(describing: EventStatusCollectionCell.self)
    private var statusArray: [(name: String, count: Int)] = []
    private var selectedIndex: Int = 0
    public var callback: ((_ filter: String) -> Void)?

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        return 56
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupUi()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _setupUi()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    private var prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: String(describing: EventStatusCollectionCell.self), kCellClassKey: EventStatusCollectionCell.self, kCellHeightKey: EventStatusCollectionCell.height]]
    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _setupUi() {
        Bundle.main.loadNibNamed("CMEventStatusHeaderView", owner: self, options: nil)
        addSubview(_backgroundView)
        _backgroundView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
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

    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()

        statusArray.forEach { day in
            var cellDict: [String: Any] = [
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: day,
                kCellClassKey: EventStatusCollectionCell.self,
                kCellHeightKey: EventStatusCollectionCell.height
            ]
            cellData.append(cellDict)
        }

        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _customCollectionView.loadData(cellSectionData)
    }
    
    public func setData(_ data: [PromoterEventsModel]) {
        statusArray = [("Events I’m In", data.filter({ $0.invite?.inviteStatus == "in" && $0.invite?.promoterStatus == "accepted" }).count),
                       ("Pending Events", data.filter({ ($0.invite?.inviteStatus == "in" && $0.invite?.promoterStatus == "pending") && !$0.isEventFull }).count),
                       ("On My List", data.filter({ $0.isWishlisted == true }).count)]
        _loadData()
    }
}


extension CMEventStatusHeaderView: CustomNoKeyboardCollectionViewDelegate, UICollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? EventStatusCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? (name: String, count: Int) else { return }
            let displayText = object.count > 0 ? "\(object.name) (\(object.count))" : object.name
            cell.setUpdata(displayText, isSelected: selectedIndex == indexPath.row)
        }
    }

    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        if let isFromExplore = cellDict?[kCellTitleKey] as? Bool, isFromExplore {
            let currentDay = statusArray[indexPath.row]
            let displayText = currentDay.count > 0 ? "\(currentDay.name) (\(currentDay.count))" : currentDay.name

            let currentDayWidth = displayText.widthOfString(usingFont: FontBrand.SFsemiboldFont(size: 16))

            return CGSize(width: currentDayWidth + 50, height:EventStatusCollectionCell.height)
        } else {
            let currentDay = statusArray[indexPath.row]
            let displayText = currentDay.count > 0 ? "\(currentDay.name) (\(currentDay.count))" : currentDay.name

            let currentDayWidth = displayText.widthOfString(usingFont: FontBrand.SFsemiboldFont(size: 16))
            
            return CGSize(width: currentDayWidth + 26, height:EventStatusCollectionCell.height)
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if selectedIndex == indexPath.row {
            selectedIndex = 0
            callback?("Events I’m In")
        } else {
            selectedIndex = indexPath.row
            callback?(statusArray[indexPath.row].name)
        }
        _customCollectionView.reload()
    }
}

