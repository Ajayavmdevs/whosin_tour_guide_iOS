import UIKit

class SocialEventFilterCell: UITableViewCell {

    @IBOutlet weak var _collectionView: CustomCollectionView!
    private var _filters: [String] = ["event_imIn".localized(), "specially_for_me".localized(), "my_list".localized(), "im_intrested".localized()]
    private let kCellIdentifier = String(describing: SociaEventFilterTagCell.self)

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { 40 }

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        _setupCollectionView()
    }
    
    private func _setupCollectionView() {
        _collectionView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 4,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24),
                              spacing: CGSize(width: 5, height: 5),
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }

    private func _loadData(_ model: PromoterProfileModel) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        var count: Int = 0
        var events: [PromoterEventsModel] = []
        _filters.forEach({ value in
            if value == "event_imIn".localized() {
                count = model.inEvents.count
                events = model.inEvents.toArrayDetached(ofType: PromoterEventsModel.self)
            } else if value == "specially_for_me".localized() {
                count = model.speciallyForMe.count
                events = model.speciallyForMe.toArrayDetached(ofType: PromoterEventsModel.self)
            } else if value == "my_list".localized() {
                count = model.wishlistEvents.count
                events = model.wishlistEvents.toArrayDetached(ofType: PromoterEventsModel.self)
            } else if value == "im_intrested".localized() {
                count = model.ImInterested.count
                events = model.ImInterested.toArrayDetached(ofType: PromoterEventsModel.self)
            }
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: count,
                kCellItemsKey: events,
                kCellObjectDataKey: value,
                kCellClassKey: SociaEventFilterTagCell.self,
                kCellHeightKey: SociaEventFilterTagCell.height
            ])
        })
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
        
    }

    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: String(describing: SociaEventFilterTagCell.self), kCellNibNameKey: String(describing: SociaEventFilterTagCell.self), kCellClassKey: SociaEventFilterTagCell.self, kCellHeightKey: SociaEventFilterTagCell.height]]
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ model: PromoterProfileModel) {
        _loadData(model)
    }

}

extension SocialEventFilterCell: CustomCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? SociaEventFilterTagCell, let object = cellDict?[kCellObjectDataKey] as? String, let count = cellDict?[kCellTagKey] as? Int else { return }
        cell.setupFilter(object, count)
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        if let object = cellDict?[kCellObjectDataKey] as? String {
            let width = object.size(withAttributes: [NSAttributedString.Key.font: FontBrand.SFboldFont(size: 14)]).width + 28
            return CGSize(width: width < 40 ? 50 : width , height: 40.0)
        }
        return CGSize(width: 0, height: 0)
    }
}
