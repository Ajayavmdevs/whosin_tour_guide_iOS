import UIKit

class CustomTourOptionTableCell: UITableViewCell {

    @IBOutlet weak var _subTitleTextLabel: UILabel!
    @IBOutlet weak var _collectionView: CustomNoKeyboardCollectionView!
    private let kCellIdentifier = String(describing: TourOptionsCollectionCell.self)
    private var optionListModel: [TourOptionDataModel] = []
    private var ticketModel: TicketModel?

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
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: TourOptionsCollectionCell.self, kCellHeightKey: TourOptionsCollectionCell.height]]
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
                    kCellTagKey: ticketModel,
                    kCellObjectDataKey: model,
                    kCellClassKey: TourOptionsCollectionCell.self,
                    kCellHeightKey: TourOptionsCollectionCell.height
                ])
            }
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }

    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ data: [TourOptionDataModel], ticketModel: TicketModel) {
        optionListModel = data
        self.ticketModel = ticketModel
        _loadData()
    }

    // --------------------------------------
    // MARK: Event
    // --------------------------------------
}

// --------------------------------------
// MARK: CollectionView Delegate
// --------------------------------------

extension CustomTourOptionTableCell: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String: Any]?, indexPath: IndexPath) {
        guard let cell = cell as? TourOptionsCollectionCell, let object = cellDict?[kCellObjectDataKey] as? TourOptionDataModel, let ticket = cellDict?[kCellTagKey] as? TicketModel else { return }
        cell.setupData(ticket, option: object)
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String: Any]?, indexPath: IndexPath) -> CGSize {
        guard  let ticket = cellDict?[kCellTagKey] as? TicketModel, let object = cellDict?[kCellObjectDataKey] as? TourOptionDataModel else { return .zero}
        let isAllowAllType = ticket.allowChild && ticket.allowInfant
        let isHaveTag = object.transferName.lowercased() == "without transfers" || Utils.stringIsNullOrEmpty(object.transferName)
        if optionListModel.count > 1 {
            return CGSize(width: kScreenWidth * 0.90, height: (isAllowAllType && !isHaveTag) ? TourOptionsCollectionCell.height : TourOptionsCollectionCell.heightForNotAllowPax)
        }
        return CGSize(width: optionListModel.count == 1 ? kScreenWidth - 28 : kScreenWidth * 0.90, height: (isAllowAllType && !isHaveTag) ? TourOptionsCollectionCell.height : TourOptionsCollectionCell.heightForNotAllowPax)
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? TourOptionDataModel, let ticket = cellDict?[kCellTagKey] as? TicketModel else { return }
    }
    
}
