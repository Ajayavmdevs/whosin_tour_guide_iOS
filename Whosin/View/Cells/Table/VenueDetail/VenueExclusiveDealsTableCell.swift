import UIKit

class VenueExclusiveDealsTableCell: UITableViewCell {

    @IBOutlet private weak var _titleView: UIView!
    @IBOutlet private weak var _titleLabel: UILabel!
    @IBOutlet private weak var _subtitleLabel: UILabel!
    @IBOutlet private weak var _collectionView: CustomCollectionView!
    private let kCellIdentifier = String(describing: VenueExclusiveDealsCollectionCell.self)
    private var _venueDetailModel: VenueDetailModel?
    private var _dealsModel: [DealsModel] = []
    private var isOneRecord: Bool = false

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
        disableSelectEffect()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: VenueExclusiveDealsCollectionCell.self, kCellHeightKey: VenueExclusiveDealsCollectionCell.height]]
    }
    
    private func setupUi() {
        _collectionView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: isOneRecord ? 1 : 1.3,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0),
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
        
        _dealsModel.forEach { dealsModel in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: dealsModel.id,
                kCellObjectDataKey: dealsModel,
                kCellClassKey: VenueExclusiveDealsCollectionCell.self,
                kCellHeightKey: VenueExclusiveDealsCollectionCell.height
            ])
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }
    
    public func setupData(_ data: [DealsModel], isFromCategory: Bool, venueModel: VenueDetailModel? = nil) {
        isOneRecord = data.count == 1
        _titleView.isHidden = isFromCategory
        _dealsModel = data
        _venueDetailModel = venueModel
        setupUi()
        _loadData()
    }
    
}

extension VenueExclusiveDealsTableCell: CustomCollectionViewDelegate {
        
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? VenueExclusiveDealsCollectionCell ,let object = cellDict?[kCellObjectDataKey] as? DealsModel else { return }
        cell.setUpdata(object)
        if _venueDetailModel != nil {
            cell._imageiView.loadWebImage(_venueDetailModel?.cover ?? kEmptyString)
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? DealsModel else { return }
        let vc = INIT_CONTROLLER_XIB(DealsDetailVC.self)
        vc.dealsModel = object
        self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }

}
