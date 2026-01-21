import UIKit
import CollectionViewPagingLayout

class ExlusiveDealsTableCell: UITableViewCell {

    @IBOutlet private weak var _titleLabel: UILabel!
    @IBOutlet private weak var _subtitleLabel: UILabel!
    @IBOutlet private weak var _collectionView: CustomNoKeyboardCollectionView!
    private let kCellIdentifier = String(describing: HomeBlockDealsCollectionView.self)
    private var _homeBlock: HomeBlockModel? = nil

    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat {
        620
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        guard let _homeBlock = _homeBlock else { return }
        _titleLabel.text = _homeBlock.title
        _subtitleLabel.text = _homeBlock.descriptions
//        _loadData()
    }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
        setupUi()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: HomeBlockDealsCollectionView.self, kCellHeightKey: HomeBlockDealsCollectionView.height]]
    }
    
    private func setupUi() {
        _collectionView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
                              spacing: CGSize(width: 0, height: 0),
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
        _collectionView.proxyDelegate = self
        
//        let layout = CollectionViewPagingLayout()
//        layout.numberOfVisibleItems = 3
//        _collectionView.collectionViewLayout = layout
//        _collectionView.isPagingEnabled = true
    }
    
    private func _loadData() {
//        if let dealsModel = _homeBlock?.deals.toArrayDetached(ofType: DealsModel.self) {
//            var cellSectionData = [[String: Any]]()
//            var cellData = [[String: Any]]()
//            var id = 0
//            dealsModel.forEach { arr in
//                let venueModel = Utils.getModelFromId(model: APPSETTING.venueModel, id: arr.venueId)
//                if !Utils.isVenueDetailEmpty(venueModel) {
//                    cellData.append([
//                        kCellIdentifierKey: kCellIdentifier,
//                        kCellTagKey: id,
//                        kCellObjectDataKey: arr,
//                        kCellClassKey: ExclusiveDealsCollectionCell.self,
//                        kCellHeightKey: ExclusiveDealsCollectionCell.height
//                    ])
//                    id += 1
//                }
//            }
//            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
//            self._collectionView.loadData(cellSectionData)
//        }
        
        if var deals = _homeBlock?.dealsList {
//            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//                guard let self = self else { return }
                var cellSectionData = [[String: Any]]()
                var cellData = [[String: Any]]()
                var id = 0
                deals.forEach { deal in
                    cellData.append([
                        kCellIdentifierKey: self.kCellIdentifier,
                        kCellTagKey: id,
                        kCellObjectDataKey: deal,
                        kCellClassKey: HomeBlockDealsCollectionView.self,
                        kCellHeightKey: HomeBlockDealsCollectionView.height
                    ])
                    id += 1
                    
                }
                cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
//                DispatchQueue.main.async {
                    self._collectionView.loadData(cellSectionData)
//                }
//            }
        }
    }
    
    public func setupData(_ model: HomeBlockModel) {
        _homeBlock = model
        _titleLabel.text = model.title
        _subtitleLabel.text = model.descriptions
        _loadData()
    }
    
}

extension ExlusiveDealsTableCell: CustomNoKeyboardCollectionViewDelegate, UICollectionViewDelegate, UIScrollViewDelegate {

    
    func didEndDecelerating(_ scrollView: UIScrollView) {
//        var visibleRect = CGRect()
//        visibleRect.origin = _collectionView.contentOffset
//        visibleRect.size = _collectionView.bounds.size
//
//        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
//    
//        guard let indexPath = _collectionView.indexPathForItem(at: visiblePoint) else { return }
//        
//        if let invisibleCell = _collectionView.cellForItem(at: IndexPath(item: indexPath.item - 1 , section: indexPath.section)) as? HomeBlockDealsCollectionView {
//            invisibleCell._mainContainer.borderWidth = 0
//        }
//        
//        if let invisibleCell = _collectionView.cellForItem(at: IndexPath(item: indexPath.item + 1 , section: indexPath.section)) as? HomeBlockDealsCollectionView {
//            invisibleCell._mainContainer.borderWidth = 0
//        }
//        
//        if let cell = _collectionView.cellForItem(at: indexPath) as? HomeBlockDealsCollectionView {
//            cell._mainContainer.borderWidth = 3
//        }
    }
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? HomeBlockDealsCollectionView,let object = cellDict?[kCellObjectDataKey] as? DealsModel else { return }
        cell.setUpdata(object)
//        if indexPath.row == 0 {
//            cell._mainContainer.borderWidth = 3
//        }
        
        if _homeBlock?.dealsList.count == 1 {
            cell._mainTrailing.constant = 0
        } else {
            cell._mainTrailing.constant = 14
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? DealsModel else { return }
        let model = Utils.getModelFromId(model: APPSETTING.venueModel, id: object.venueId)
        parentBaseController?.feedbackGenerator?.impactOccurred()
        let vc = INIT_CONTROLLER_XIB(DealsDetailVC.self)
        object.venueModel = model
        vc.dealsModel = object
        self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 0.5, height: HomeBlockDealsCollectionView.height)
//        if _homeBlock?.dealsList.count == 1 {
//            return CGSize(width: collectionView.frame.width - 28, height: ExclusiveDealsCollectionCell.height)
//        } else {
//            return CGSize(width: collectionView.frame.width * 0.8, height: ExclusiveDealsCollectionCell.height)
//        }
    }

}
