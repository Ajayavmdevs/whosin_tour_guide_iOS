import UIKit

class WhosinTourDataTableCell: UITableViewCell {

    @IBOutlet weak var _subTitleTextLabel: UILabel!
    @IBOutlet weak var _collectionView: CustomNoKeyboardCollectionView!
    private let kCellIdentifier = String(describing: WhosinTicketCollectionCell.self)
    private var optionListModel: [TourOptionsModel] = []
    private var travelDeskModel: TravelDeskTourModel?

    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUi()
        disableSelectEffect()
    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: WhosinTicketCollectionCell.self, kCellHeightKey: WhosinTicketCollectionCell.height]]
    }
    
    private func setupUi() {
        _collectionView.register(UINib(nibName: kCellIdentifier, bundle: nil), forCellWithReuseIdentifier: kCellIdentifier)
        _collectionView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            enableRefresh: false,
            columns: 1.01,
            rows: 1,
            edgeInsets: UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 8),
            scrollDirection: .horizontal,
            emptyDataText: nil,
            emptyDataIconImage: nil,
            delegate: self
        )
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }

    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        if !optionListModel.isEmpty {
            optionListModel.forEach { model in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: kCellIdentifier,
                    kCellObjectDataKey: model,
                    kCellClassKey: WhosinTicketCollectionCell.self,
                    kCellHeightKey: WhosinTicketCollectionCell.height
                ])
            }
        } else if travelDeskModel?.optionData.isEmpty == false {
            travelDeskModel?.optionData.forEach { model in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: kCellIdentifier,
                    kCellObjectDataKey: model,
                    kCellClassKey: WhosinTicketCollectionCell.self,
                    kCellHeightKey: WhosinTicketCollectionCell.height
                ])
            }
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }

    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ data: [TourOptionsModel]) {
        optionListModel = data
        _loadData()
    }

    public func setupData(_ data: TravelDeskTourModel) {
        travelDeskModel = data
        _loadData()
    }
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
}

// --------------------------------------
// MARK: CollectionView Delegate
// --------------------------------------

extension WhosinTourDataTableCell: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String: Any]?, indexPath: IndexPath) {
        if let cell = cell as? WhosinTicketCollectionCell, let object = cellDict?[kCellObjectDataKey] as? TourOptionsModel {
            cell.setupData(option: object)
        } else if let cell = cell as? WhosinTicketCollectionCell, let object = cellDict?[kCellObjectDataKey] as? TourOptionModel {
            cell.setupData(option: object)
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String: Any]?, indexPath: IndexPath) -> CGSize {
        let width: CGFloat = optionListModel.count == 1 ? kScreenWidth - 28 : kScreenWidth * 0.90
        return CGSize(width: width, height: WhosinTicketCollectionCell.height)
    }
  
    
}
