import UIKit

class VenueRecommendedTableCell: UITableViewCell {
    
    @IBOutlet weak var _titleLabel: UILabel!
    @IBOutlet weak var _collectionView: CustomNoKeyboardCollectionView!
    private let kCellIdentifier = String(describing: LargeVenueCollectionCell.self)
    private var _venueDetail: [VenueDetailModel] = []
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { 255 }
    
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
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: LargeVenueCollectionCell.self, kCellHeightKey: 200.0]]
    }
    
    private func setupUi() {
        _collectionView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 3,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0),
                              spacing: CGSize(width: 10, height: 10),
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
        
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        _venueDetail.forEach { venue in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: venue.id,
                kCellObjectDataKey: venue,
                kCellClassKey: LargeVenueCollectionCell.self,
                kCellHeightKey: 200.0,
                kCellClickEffectKey:true
            ])
        }
                
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }
    
    private func _openVenueDetail(_ venueId: String, venueDetail: VenueDetailModel) {
        let vc = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
        vc.venueId = venueId
        vc.venueDetailModel = venueDetail
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }

    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: [VenueDetailModel]) {
        _venueDetail = data
        _loadData()
    }
    
}

// --------------------------------------
// MARK: Custom Collection View
// --------------------------------------

extension VenueRecommendedTableCell: CustomNoKeyboardCollectionViewDelegate {
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        let cell = cell as? LargeVenueCollectionCell
        guard let object = cellDict?[kCellObjectDataKey] as? VenueDetailModel else { return }
        cell?.setUpdata(object)
        cell?.prepareForReuse()
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if cellDict?[kCellObjectDataKey] is VenueDetailModel {
            guard let object = cellDict?[kCellObjectDataKey] as? VenueDetailModel else { return }
            _openVenueDetail(object.id, venueDetail: object)
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        let width =  kScreenWidth * 0.70
        return CGSize(width: width, height: 200.0)
    }
    
}
