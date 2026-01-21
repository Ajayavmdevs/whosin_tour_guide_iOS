import UIKit

class EventsTableCell: UITableViewCell {

    @IBOutlet private weak var _titleLabel: UILabel!
    @IBOutlet private weak var _subtitleLabel: UILabel!
    @IBOutlet private weak var _collectionView: CustomNoKeyboardCollectionView!
    private let kCellIdentifier = String(describing: EventCollectionCell.self)
    private var _eventModel: [EventModel] = []
    private var _homeBlockModel: HomeBlockModel?
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat {
        500
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        guard let _homeBlockModel = _homeBlockModel else { return }
        _eventModel = Utils.getModelsFromIds(model: APPSETTING.events, ids: _homeBlockModel.events) ?? []
        _titleLabel.text = _homeBlockModel.title
        _subtitleLabel.text = _homeBlockModel.descriptions
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
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: EventCollectionCell.self, kCellHeightKey: EventCollectionCell.height]]
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
    }
    
    private func _loadData() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            var cellSectionData = [[String: Any]]()
            var cellData = [[String: Any]]()
            
            var id = 0
            self._eventModel = self._eventModel.filter({!Utils.isVenueDetailEmpty($0.venueDetail)})
            self._eventModel.forEach { event in
                cellData.append([
                    kCellIdentifierKey: self.kCellIdentifier,
                    kCellTagKey: id,
                    kCellObjectDataKey: event,
                    kCellClassKey: EventCollectionCell.self,
                    kCellHeightKey: EventCollectionCell.height
                ])
                id += 1
            }
            
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
            DispatchQueue.main.async {
                self._collectionView.loadData(cellSectionData)
            }
        }
    }
    
    public func setupData(_ model: HomeBlockModel) {
        _homeBlockModel = model
        _eventModel = model.eventList
//        _eventModel.append(contentsOf: model.eventList)
//        _eventModel.append(contentsOf: model.eventList)
        _titleLabel.text = model.title
        _subtitleLabel.text = model.descriptions
        _loadData()
    }
    
}

extension EventsTableCell: CustomNoKeyboardCollectionViewDelegate, UICollectionViewDelegate, UIScrollViewDelegate {

    func didEndDecelerating(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()

        visibleRect.origin = _collectionView.contentOffset
        visibleRect.size = _collectionView.bounds.size

        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
    
        guard let indexPath = _collectionView.indexPathForItem(at: visiblePoint) else { return }
        
        if let invisibleCell = _collectionView.cellForItem(at: IndexPath(item: indexPath.item - 1 , section: indexPath.section)) as? EventCollectionCell {
            invisibleCell._mainContainerView.borderWidth = 0
        }
        
        if let invisibleCell = _collectionView.cellForItem(at: IndexPath(item: indexPath.item + 1 , section: indexPath.section)) as? EventCollectionCell {
            invisibleCell._mainContainerView.borderWidth = 0
        }
        
        if let cell = _collectionView.cellForItem(at: indexPath) as? EventCollectionCell {
            cell._mainContainerView.borderWidth = 3
        }
        print("Index path is s: \(indexPath.row)")
    }
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? EventCollectionCell,let object = cellDict?[kCellObjectDataKey] as? EventModel else { return }
        cell.setUpdata(object)
        if indexPath.row == 0 {
            if _eventModel.count == 1 {
                cell._mainTrailing.constant = 0
            }
            cell._mainContainerView.borderWidth = 3
        }
        cell.prepareForReuse()
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 0.5, height: EventCollectionCell.height)
        guard let _homeBlockModel = _homeBlockModel else { return CGSize(width: collectionView.frame.width - 0.5, height: EventCollectionCell.height) }
        if _homeBlockModel.eventList.count == 1 {
            return CGSize(width: collectionView.frame.width - 0.5, height: EventCollectionCell.height)
        } else {
            return CGSize(width: collectionView.frame.width * 0.8, height: EventCollectionCell.height)
        }
    }

    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? EventModel else { return }
        let vc = INIT_CONTROLLER_XIB(EventDetailVC.self)
        vc.event = object
        parentViewController?.navigationController?.pushViewController(vc, animated: true)

    }
}
