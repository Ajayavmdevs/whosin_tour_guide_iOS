import UIKit

class CMEventListCell: UITableViewCell {
    
    @IBOutlet weak var _titleView: UIView!
    @IBOutlet weak var _titleLabel: CustomLabel!
    @IBOutlet weak var _collectionView: CustomNoKeyboardCollectionView!
    @IBOutlet weak var _emptyView: UIView!
    private let kCellIdentifier = String(describing: CMEventListCollectionCell.self)
    private var _inEventsModel: [PromoterEventsModel] = []
    @IBOutlet weak var _promoterView: UIView!
    @IBOutlet weak var _promoterimage: UIImageView!
    @IBOutlet weak var _promoterName: CustomLabel!
    @IBOutlet weak var _promoterDisc: CustomLabel!
    
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
        _promoterimage.loadWebImage(_inEventsModel.first?.user?.image ?? kEmptyString, name: _inEventsModel.first?.user?.fullName ?? kEmptyString)
        _promoterName.text = _inEventsModel.first?.user?.fullName
        _inEventsModel.forEach({ model in
            if _titleLabel.text == "Event History" {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: kCellIdentifier,
                    kCellObjectDataKey: model,
                    kCellClassKey: CMEventListCollectionCell.self,
                    kCellHeightKey: CMEventListCollectionCell.height
                ])
            } else {
                if model.status != "cancelled" && model.status != "completed" {
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifier,
                        kCellTagKey: kCellIdentifier,
                        kCellObjectDataKey: model,
                        kCellClassKey: CMEventListCollectionCell.self,
                        kCellHeightKey: CMEventListCollectionCell.height
                    ])
                }
            }
        })
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
        
    }
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: String(describing: CMEventListCollectionCell.self), kCellNibNameKey: String(describing: CMEventListCollectionCell.self), kCellClassKey: CMEventListCollectionCell.self, kCellHeightKey: CMEventListCollectionCell.height]]
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: [PromoterEventsModel], cellTitle: String, showtitle: Bool = false) {
        _titleView.isHidden = !showtitle
        _titleLabel.text = cellTitle
        _inEventsModel = data
        _emptyView.isHidden = !data.isEmpty
        _collectionView.isHidden = data.isEmpty
        _loadData()
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------

}

extension CMEventListCell: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? CMEventListCollectionCell, let object = cellDict?[kCellObjectDataKey] as? PromoterEventsModel {
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
            return CGSize(width: collectionView.frame.width - 28, height: CMEventListCollectionCell.height)
        } else {
            return CGSize(width: kScreenWidth * 0.9, height: CMEventListCollectionCell.height)
        }
    }
    
}
