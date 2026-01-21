import UIKit

protocol ShowCategoryDetailsDelegate: AnyObject {
    func didSelectCategory(_ day: String)
}

class AllVenueSeachTableCell: UITableViewCell {
    
    @IBOutlet private weak var _heaightConstraint: NSLayoutConstraint!
    weak var delegate: ShowCategoryDetailsDelegate?
    @IBOutlet weak var _titleLabel: UILabel!
    @IBOutlet weak var _collectionView: CustomNoKeyboardCollectionView!
    private let kCellIdentifierVenue = String(describing: VenueSearchCollectionCell.self)
    private var _venueModel: [VenueDetailModel] = []
    
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
        let spacing = 10
        _collectionView.setup(cellPrototypes: _prototypes,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1.1,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: .zero, left: 10, bottom: .zero, right: 0),
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
        
        _venueModel.forEach { venue in
            cellData.append([
                kCellIdentifierKey: kCellIdentifierVenue,
                kCellTagKey: kCellIdentifierVenue,
                kCellObjectDataKey: venue,
                kCellClassKey: VenueSearchCollectionCell.self,
                kCellHeightKey: VenueSearchCollectionCell.height
            ])
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifierVenue, kCellNibNameKey: String(describing: VenueSearchCollectionCell.self), kCellClassKey: VenueSearchCollectionCell.self, kCellHeightKey: VenueSearchCollectionCell.height]]
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: [VenueDetailModel]) {
        _venueModel = data
        _loadData()
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction func _handleMoreEvent(_ sender: UIButton) {
        delegate?.didSelectCategory("venue")
    }
    
}

// --------------------------------------
// MARK: Custom Collection View
// --------------------------------------

extension AllVenueSeachTableCell: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? VenueSearchCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? VenueDetailModel else { return }
            cell.setupData(object)
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? VenueDetailModel else { return }
        
        APPSETTING.addSearchHistory(id: object.id, title: object.name, subtitle: object.about, type: "venue", image: object.cover)
        
        let controller = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
        controller.venueId = object.id
        controller.venueDetailModel = Utils.getModelFromId(model: APPSETTING.venueModel, id: object.id)
        self.parentViewController?.navigationController?.pushViewController(controller, animated: true)
        
        
    }
}

