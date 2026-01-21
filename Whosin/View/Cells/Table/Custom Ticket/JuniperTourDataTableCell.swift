import UIKit

class JuniperTourDataTableCell: UITableViewCell {

    @IBOutlet weak var _subTitleTextLabel: UILabel!
    @IBOutlet weak var _collectionView: CustomNoKeyboardCollectionView!
    private let kCellIdentifier = String(describing: JuniperTicketCollectionCell.self)
    private var optionListModel: [ServiceOptionModel] = []
    private var serviceModel: ServiceModel?

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
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: JuniperTicketCollectionCell.self, kCellHeightKey: JuniperTicketCollectionCell.height]]
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
                    kCellTagKey: serviceModel,
                    kCellObjectDataKey: model,
                    kCellClassKey: JuniperTicketCollectionCell.self,
                    kCellHeightKey: JuniperTicketCollectionCell.height
                ])
            }
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }

    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ data: [ServiceModel]) {
        optionListModel = data.first?.serviceOptions.toArrayDetached(ofType: ServiceOptionModel.self) ?? []
        self.serviceModel = data.first
        _loadData()
    }

    // --------------------------------------
    // MARK: Event
    // --------------------------------------
}

// --------------------------------------
// MARK: CollectionView Delegate
// --------------------------------------

extension JuniperTourDataTableCell: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String: Any]?, indexPath: IndexPath) {
        guard let cell = cell as? JuniperTicketCollectionCell, let object = cellDict?[kCellObjectDataKey] as? ServiceOptionModel, let ticket = cellDict?[kCellTagKey] as? ServiceModel else { return }
        cell.setupData(ticket, option: object)
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String: Any]?, indexPath: IndexPath) -> CGSize {
        let width: CGFloat = optionListModel.count == 1 ? kScreenWidth - 28 : kScreenWidth * 0.90
        return CGSize(width: width, height: JuniperTicketCollectionCell.height)
    }
  
    
}
