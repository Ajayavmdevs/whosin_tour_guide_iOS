import UIKit
import ObjectMapper

class SavedInDraftTableCell: UITableViewCell {
    
    @IBOutlet weak var _collectionView: CustomNoKeyboardCollectionView!
    private let kCellIdentifier = String(describing: SavedInDraftCollectionCell.self)
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height : CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        _setupCollectionView()
    }
    
    private func _setupCollectionView() {
        _collectionView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14),
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
        
        Preferences.saveEventDraft.forEach({ model in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: model,
                kCellClassKey: SavedInDraftCollectionCell.self,
            ])
        })
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
        
    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: String(describing: SavedInDraftCollectionCell.self), kCellNibNameKey: String(describing: SavedInDraftCollectionCell.self), kCellClassKey: SavedInDraftCollectionCell.self, kCellHeightKey: SavedInDraftCollectionCell.height]]
    }
    
    public func setup() {
        _loadData()
    }
    
}


extension SavedInDraftTableCell: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? SavedInDraftCollectionCell, let object = cellDict?[kCellObjectDataKey] as? [String: Any] {
            guard let model = Mapper<PromoterEventsModel>().map(JSONString: object.toJSONString) else { return }
            cell.setup(model: model)
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as?  [String: Any] else { return}
        let vc = INIT_CONTROLLER_XIB(CreateEventVC.self)
        vc.params = object
        vc.isEditEvent = false
        vc.isDraft = true
        vc.hidesBottomBarWhenPushed = true
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }    
}
