import UIKit
import CollectionViewPagingLayout

class ActivityComponantTableCell: UITableViewCell {
    @IBOutlet weak var _titleLabel: UILabel!
    @IBOutlet weak var _subTitleLabel: UILabel!
    @IBOutlet weak var _collectionView: CustomNoKeyboardCollectionView!
    private let kCellIdentifier = String(describing: ActivityComponantCollectionCell.self)
    private var _homeBlockModel: HomeBlockModel?

    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat { 370 }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        guard let _homeBlockModel = _homeBlockModel else { return }
        _titleLabel.text = _homeBlockModel.title
        _subTitleLabel.text = _homeBlockModel.descriptions
        _loadData()

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
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: ActivityComponantCollectionCell.self, kCellHeightKey: ActivityComponantCollectionCell.height]]
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
        
        let layout = CollectionViewPagingLayout()
        layout.numberOfVisibleItems = 3
        _collectionView.collectionViewLayout = layout
        _collectionView.isPagingEnabled = true
    }
    
    private func _loadData() {
        guard let _homeBlockModel = _homeBlockModel else { return }
//        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//            guard let self = self else { return }
            var cellSectionData = [[String: Any]]()
            var cellData = [[String: Any]]()
            _homeBlockModel.activityList.forEach { activitieModel in
                cellData.append([
                    kCellIdentifierKey: self.kCellIdentifier,
                    kCellTagKey: activitieModel.id,
                    kCellObjectDataKey: activitieModel,
                    kCellClassKey: ActivityComponantCollectionCell.self,
                    kCellHeightKey: ActivityComponantCollectionCell.height
                ])
            }
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
//            DispatchQueue.main.async {
                self._collectionView.loadData(cellSectionData)
//            }
//        }
    }
    
    public func setupData(_ model: HomeBlockModel) {
        _homeBlockModel = model
        _titleLabel.text = model.title
        _subTitleLabel.text = model.descriptions
        _loadData()
    }

    @IBAction private func _handleSeeAllEvent(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(ActivityDetailVC.self)
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ActivityComponantTableCell: CustomNoKeyboardCollectionViewDelegate, UICollectionViewDelegate, UIScrollViewDelegate {

    
    func didEndDecelerating(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()

        visibleRect.origin = _collectionView.contentOffset
        visibleRect.size = _collectionView.bounds.size

        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
    
        guard let indexPath = _collectionView.indexPathForItem(at: visiblePoint) else { return }
        
        if let invisibleCell = _collectionView.cellForItem(at: IndexPath(item: indexPath.item - 1 , section: indexPath.section)) as? ActivityComponantCollectionCell {
            invisibleCell._mainContainerView.borderWidth = 0
        }
        
        if let invisibleCell = _collectionView.cellForItem(at: IndexPath(item: indexPath.item + 1 , section: indexPath.section)) as? ActivityComponantCollectionCell {
            invisibleCell._mainContainerView.borderWidth = 0
        }
        
        if let cell = _collectionView.cellForItem(at: indexPath) as? ActivityComponantCollectionCell {
            cell._mainContainerView.borderWidth = 3
        }
    }
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? ActivityComponantCollectionCell,let object = cellDict?[kCellObjectDataKey] as? ActivitiesModel else { return }
        cell.setUpdata(object)
        if indexPath.row == 0 {
            cell._mainContainerView.borderWidth = 3
        }
        
        if _homeBlockModel?.activityList.count == 1 {
            cell._mainTrailing.constant = 14
        } else {
            cell._mainTrailing.constant = 50
        }
        
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? ActivitiesModel else { return }
        let controller = INIT_CONTROLLER_XIB(ActivityInfoVC.self)
        controller.activityId = object.id
        controller.activityName = object.name
        parentViewController?.navigationController?.pushViewController(controller, animated: true)
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        guard let _homeBlockModel = _homeBlockModel else { return CGSize(width: collectionView.frame.width - 20, height: ActivityComponantCollectionCell.height) }
        if _homeBlockModel.activities.count == 1 {
            return CGSize(width: collectionView.frame.width - 28, height: ActivityComponantCollectionCell.height)
        } else {
            return CGSize(width: collectionView.frame.width * 0.8, height: ActivityComponantCollectionCell.height)
        }
    }

}
