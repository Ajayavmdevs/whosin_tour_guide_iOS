import UIKit
import CollectionViewPagingLayout

class CustomComponentTableCell: UITableViewCell {
    
    @IBOutlet private weak var _collectionView: CustomNoKeyboardCollectionView!
    @IBOutlet private weak var _titleLbl: UILabel!
    @IBOutlet private weak var _subTitleLbl: UILabel!
    private let kCellIdentifier = String(describing: VenueEventsCollectionCell.self)
    private var homeBlockModel: HomeBlockModel?
    
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { 544 }
    
    
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        guard let homeBlockModel = homeBlockModel else { return }
        _loadData()
        _titleLbl.text = homeBlockModel.title
        _subTitleLbl.text = homeBlockModel.descriptions
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: VenueEventsCollectionCell.self, kCellHeightKey: VenueEventsCollectionCell.height]]
    }
    
    private func setupUi() {
        _collectionView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14),
                              spacing: CGSize(width: 0, height: 0),
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
        _collectionView.proxyDelegate = self
    }

    
    private func _loadData() {
        
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            guard let self = self else { return }
            var cellSectionData = [[String: Any]]()
            var cellData = [[String: Any]]()
            self.homeBlockModel?.customComponents.forEach { venueModel in
                cellData.append([
                    kCellIdentifierKey: self.kCellIdentifier,
                    kCellTagKey: venueModel.id,
                    kCellObjectDataKey: venueModel,
                    kCellClassKey: VenueEventsCollectionCell.self,
                    kCellHeightKey: VenueEventsCollectionCell.height
                ])
            }
            
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
            DispatchQueue.main.async {
                self._collectionView.loadData(cellSectionData)
                let layout = CollectionViewPagingLayout()
                layout.numberOfVisibleItems = 2
                self._collectionView.collectionViewLayout = layout
                self._collectionView.isPagingEnabled = true
                self._collectionView.clipsToBounds = false
                layout.collectionView?.clipsToBounds = false
            }
        }
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: HomeBlockModel) {
        homeBlockModel = data
        _loadData()
        _titleLbl.text = data.title
        _subTitleLbl.text = data.descriptions
    }
    
}

extension CustomComponentTableCell: CustomNoKeyboardCollectionViewDelegate,UICollectionViewDelegate, UIScrollViewDelegate {
        
    func didEndDecelerating(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()
        visibleRect.origin = _collectionView.contentOffset
        visibleRect.size = _collectionView.bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPath = _collectionView.indexPathForItem(at: visiblePoint) else { return }
        if let invisibleCell = _collectionView.cellForItem(at: IndexPath(item: indexPath.item - 1 , section: indexPath.section)) as? VenueEventsCollectionCell {
            invisibleCell._mainContainerView.borderWidth = 0
        }
        if let invisibleCell = _collectionView.cellForItem(at: IndexPath(item: indexPath.item + 1 , section: indexPath.section)) as? VenueEventsCollectionCell {
            invisibleCell._mainContainerView.borderWidth = 0
        }
        if let cell = _collectionView.cellForItem(at: indexPath) as? VenueEventsCollectionCell {
            cell._mainContainerView.borderWidth = 3
        }
    }

    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? VenueEventsCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? CustomComponentModel else { return }
            cell.setUpdata(object)
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        if homeBlockModel?.customComponents.count == 1 {
            return CGSize(width: collectionView.frame.width - 28, height: VenueEventsCollectionCell.height)
        } else {
            return CGSize(width: collectionView.frame.width * 0.8, height: VenueEventsCollectionCell.height)
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? CustomComponentModel else { return }
        parentBaseController?.feedbackGenerator?.impactOccurred()
        if !Utils.stringIsNullOrEmpty(object.ticketId) {
            let vc = INIT_CONTROLLER_XIB(CustomTicketDetailVC.self)
            vc.ticketID = object.ticketId
            vc.hidesBottomBarWhenPushed = false
            parentViewController?.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
            vc.venueId = object.venueId
            vc.venueDetailModel = Utils.getModelFromId(model: APPSETTING.venueModel, id: object.venueId)
            vc.hidesBottomBarWhenPushed = false
            parentViewController?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
