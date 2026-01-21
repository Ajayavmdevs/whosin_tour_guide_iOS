import UIKit

class ComplementaryMyListTableCell: UITableViewCell {

    @IBOutlet weak var _collectionView: CustomNoKeyboardCollectionView!
    @IBOutlet weak var _emptyView: UIView!
    private let kCellIdentifier = String(describing: ComplementaryEventImInCollecionCell.self)
    private var _myWishlistModel: [PromoterEventsModel] = []
    
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
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

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
        
        _myWishlistModel.forEach({ model in
            if model.status != "cancelled" && model.status != "completed" {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: kCellIdentifier,
                    kCellObjectDataKey: model,
                    kCellClassKey: ComplementaryEventImInCollecionCell.self,
                    kCellHeightKey: 300.0
                ])
            }
        })
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
        
    }

    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: String(describing: ComplementaryEventImInCollecionCell.self), kCellNibNameKey: String(describing: ComplementaryEventImInCollecionCell.self), kCellClassKey: ComplementaryEventImInCollecionCell.self, kCellHeightKey: ComplementaryEventImInCollecionCell.height]]
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ data: [PromoterEventsModel]) {
        _myWishlistModel = data
        _emptyView.isHidden = !data.isEmpty
        _collectionView.isHidden = data.isEmpty
        _loadData()
    }
    
}

extension ComplementaryMyListTableCell: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? ComplementaryEventImInCollecionCell, let object = cellDict?[kCellObjectDataKey] as? PromoterEventsModel {
            cell.setupData(object, isWishList: true)
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
        if _myWishlistModel.count == 1 {
            return CGSize(width: collectionView.frame.width - 28, height: 250.0)
        } else {
            return CGSize(width: kScreenWidth * 0.9, height: 250.0)
        }
    }
    
}

