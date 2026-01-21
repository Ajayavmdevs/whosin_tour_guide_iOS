import UIKit

class ComplementaryRingTableCell: UITableViewCell {
    
    @IBOutlet weak var _collectionView: CustomNoKeyboardCollectionView!
    @IBOutlet weak var _emptyView: UIView!
    private let kCellIdentifier = String(describing: ComplementaryRingCollectionCell.self)
    private var _ringDetail: [UserDetailModel] = []
    
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
                              spacing: CGSize(width: 5, height: 5),
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

        var id = 0
        _ringDetail.forEach({ model in
            if id < 10 {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: kCellIdentifier,
                    kCellObjectDataKey: model,
                    kCellClassKey: ComplementaryRingCollectionCell.self,
                    kCellHeightKey: ComplementaryRingCollectionCell.height
                ])
                id = id + 1
            }
        })

        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)

    }

    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: String(describing: ComplementaryRingCollectionCell.self), kCellNibNameKey: String(describing: ComplementaryRingCollectionCell.self), kCellClassKey: ComplementaryRingCollectionCell.self, kCellHeightKey: ComplementaryRingCollectionCell.height]]
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: [UserDetailModel]) {
        _ringDetail = data
        _emptyView.isHidden = !data.isEmpty
        _collectionView.isHidden = data.isEmpty
        _loadData()
    }
    
}


extension ComplementaryRingTableCell: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? ComplementaryRingCollectionCell, let object = cellDict?[kCellObjectDataKey] as? UserDetailModel {
            cell.setupData(object)
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        if _ringDetail.count == 1 {
            return CGSize(width: collectionView.frame.width - 28, height: ComplementaryRingCollectionCell.height)
        } else {
            return CGSize(width: kScreenWidth * 0.9, height: ComplementaryRingCollectionCell.height)
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? ComplementaryRingCollectionCell, let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
        let vc = INIT_CONTROLLER_XIB(PromoterPublicProfileVc.self)
        vc.promoterId = object.userId
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
}
