import UIKit

class AllEventSearchTableCell: UITableViewCell {

    weak var delegate: ShowCategoryDetailsDelegate?
    @IBOutlet weak var _titleLabel: UILabel!
    @IBOutlet private weak var _collectionView: CustomNoKeyboardCollectionView!
    private let kCellIdentifierEvent = String(describing: EventSearchCollectionCell.self)
    private var _eventModel: [EventModel] = []


    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        UITableView.automaticDimension
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUi()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func setupUi() {
        let spacing = 0
        _collectionView.setup(cellPrototypes: _prototypes,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1.1,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: .zero, left: 0, bottom: .zero, right: 0),
                              spacing: CGSize(width: spacing, height: spacing),
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
        _collectionView.reload()
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        _eventModel.forEach { event in
            if !Utils.isVenueDetailEmpty(event.venueDetail) {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierEvent,
                    kCellTagKey: kCellIdentifierEvent,
                    kCellObjectDataKey: event,
                    kCellClassKey: EventSearchCollectionCell.self,
                    kCellHeightKey: EventSearchCollectionCell.height
                ])
            }
        }

        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifierEvent, kCellNibNameKey: String(describing: EventSearchCollectionCell.self), kCellClassKey: EventSearchCollectionCell.self, kCellHeightKey: EventSearchCollectionCell.height]]
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ data: [EventModel]) {
        _eventModel = data
        _loadData()
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------

    @IBAction private func _handleMoreEvent(_ sender: UIButton) {
        delegate?.didSelectCategory("event")
    }
    
}

// --------------------------------------
// MARK: Custom Collection View
// --------------------------------------

extension AllEventSearchTableCell: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? EventSearchCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? EventModel else { return }
            cell.setupData(object)
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? EventModel else { return }
        
        APPSETTING.addSearchHistory(id: object.id, title: object.title, subtitle: object.descriptions, type: "event", image: object.image)
        let controller = INIT_CONTROLLER_XIB(EventDetailVC.self)
        controller.event = object
        self.parentViewController?.navigationController?.pushViewController(controller, animated: true)

    }
}

