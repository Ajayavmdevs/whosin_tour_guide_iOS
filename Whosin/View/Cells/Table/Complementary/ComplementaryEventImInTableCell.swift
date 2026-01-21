import UIKit

class ComplementaryEventImInTableCell: UITableViewCell {
    
    @IBOutlet weak var _cellTitle: CustomLabel!
    @IBOutlet weak var _seeAllBtn: CustomButton!
    @IBOutlet weak var _collectionView: CustomNoKeyboardCollectionView!
    @IBOutlet weak var _emptyView: UIView!
    private let kCellIdentifier = String(describing: CMEventInCollectionCell.self)
    private var _inEventsModel: [PromoterEventsModel] = []
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        _setupCollectionView()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
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
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        _inEventsModel.forEach({ model in
            if model.status != "cancelled" && model.status != "completed" {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: kCellIdentifier,
                    kCellObjectDataKey: model,
                    kCellClassKey: CMEventInCollectionCell.self,
                    kCellHeightKey: CMEventInCollectionCell.height
                ])
            }
        })
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
        
    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: String(describing: CMEventInCollectionCell.self), kCellNibNameKey: String(describing: CMEventInCollectionCell.self), kCellClassKey: CMEventInCollectionCell.self, kCellHeightKey: CMEventInCollectionCell.height]]
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: [PromoterEventsModel], cellTitle: String) {
        _cellTitle.text = cellTitle
        _inEventsModel = data
        _emptyView.isHidden = !data.isEmpty
        _collectionView.isHidden = data.isEmpty
        _seeAllBtn.isHidden = data.isEmpty
        _loadData()
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleSeeAllEvent(_ sender: CustomButton) {
        let vc = INIT_CONTROLLER_XIB(SeeAllDetailVC.self)
        vc.eventListModel = _inEventsModel
        vc.viewTitle = _cellTitle.text ?? "Event I'm IN"
        vc.detailType = "event"
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ComplementaryEventImInTableCell: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? CMEventInCollectionCell, let object = cellDict?[kCellObjectDataKey] as? PromoterEventsModel {
            cell.setupData(object, isIn: true)
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? PromoterEventsModel else { return}
        let vc = INIT_CONTROLLER_XIB(PromoterEventDetailVC.self)
        vc.eventModel = object
        vc.id = object.id
        vc.isComplementary = true
        vc.hidesBottomBarWhenPushed = true
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        if _inEventsModel.count == 1 {
            return CGSize(width: collectionView.frame.width - 28, height: CMEventInCollectionCell.height)
        } else {
            return CGSize(width: kScreenWidth * 0.8, height: CMEventInCollectionCell.height)
        }
    }
    
}
