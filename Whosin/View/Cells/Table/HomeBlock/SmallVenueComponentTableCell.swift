import UIKit

class SmallVenueComponentTableCell: UITableViewCell {

    @IBOutlet weak var _titleTextLabel: UILabel!
    @IBOutlet weak var _subTitleTextLabel: UILabel!
    @IBOutlet weak var _bgView: UIView!
    @IBOutlet weak var _collectionView: CustomNoKeyboardCollectionView!
    private let kCellIdentifier = String(describing: SmallVenueCollectionCell.self)
    private var venueModel: [VenueDetailModel] = []
    private var _homeBlock: HomeBlockModel?

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUi()
        disableSelectEffect()
    }
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------

    class var height: CGFloat { 425 }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        guard let _homeBlock = _homeBlock else { return }
        _titleTextLabel.text = _homeBlock.title
        
        if !_homeBlock.venues.isEmpty {
            DispatchQueue.global(qos: .userInitiated).async {[weak self] in
                guard let self = self else { return }
                self.venueModel = _homeBlock.venueList //Utils.getModelsFromIds(model: APPSETTING.venueModel, ids: _homeBlock.venues) ?? []
                var cellSectionData = [[String: Any]]()
                var cellData = [[String: Any]]()
                self.venueModel.forEach { venueModel in
                    cellData.append([
                        kCellIdentifierKey: self.kCellIdentifier,
                        kCellTagKey: venueModel.id,
                        kCellObjectDataKey: venueModel,
                        kCellClassKey: SmallVenueCollectionCell.self,
                        kCellHeightKey: SmallVenueCollectionCell.height
                    ])
                }
                cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
                DispatchQueue.main.async {
                    self._collectionView.loadData(cellSectionData)
                }
            }

        }    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: SmallVenueCollectionCell.self, kCellHeightKey: SmallVenueCollectionCell.height]]
    }
    
    private func setupUi() {
        _collectionView.setup(cellPrototypes: _prototype,
                                   hasHeaderSection: false,
                                   enableRefresh: false,
                                   columns: 1.01,
                                   edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10),
                                   scrollDirection: .horizontal,
                                   emptyDataText: nil,
                                   emptyDataIconImage: nil,
                                   delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
        _collectionView.proxyDelegate = self
        
        _bgView.hero.id = "small_venue_component_details_vc"
        _bgView.hero.modifiers = HeroAnimationModifier.stories
        
        DISPATCH_ASYNC_MAIN_AFTER(0.02) {
            self._bgView.roundCorners(corners: [.bottomLeft , .topLeft], radius: 10)
        }
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        venueModel.forEach { venueModel in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: venueModel.id,
                kCellObjectDataKey: venueModel,
                kCellClassKey: SmallVenueCollectionCell.self,
                kCellHeightKey: SmallVenueCollectionCell.height
            ])
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ data: HomeBlockModel) {
        _homeBlock = data
        _titleTextLabel.text = data.title
        
        if !data.venues.isEmpty {
            DispatchQueue.global(qos: .userInitiated).async {[weak self] in
                guard let self = self else { return }
               // self.venueModel = Utils.getModelsFromIds(model: APPSETTING.venueModel, ids: data.venues) ?? []
                self.venueModel = data.venueList
                var cellSectionData = [[String: Any]]()
                var cellData = [[String: Any]]()
                self.venueModel.forEach { venueModel in
                    cellData.append([
                        kCellIdentifierKey: self.kCellIdentifier,
                        kCellTagKey: venueModel.id,
                        kCellObjectDataKey: venueModel,
                        kCellClassKey: SmallVenueCollectionCell.self,
                        kCellHeightKey: SmallVenueCollectionCell.height
                    ])
                }
                cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
                DispatchQueue.main.async {
                    self._collectionView.loadData(cellSectionData)
                }
            }

        }
    }

    @IBAction private func seeAllButtonEvent(_ sender: UIButton){
        parentBaseController?.feedbackGenerator?.impactOccurred()
        let vc = INIT_CONTROLLER_XIB(SmallVenueComponentDetailVC.self)
        vc.venueListModel = venueModel
        vc.titleStr = _titleTextLabel.text
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
}

extension SmallVenueComponentTableCell: CustomNoKeyboardCollectionViewDelegate, UICollectionViewDelegate {
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? SmallVenueCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? VenueDetailModel else { return }
            cell.setUpdata(object)
        }
    }
        
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let currentPageHorizontal = ceil(targetContentOffset.pointee.x / _collectionView.frame.width)
        let newX = _collectionView.cellSize.width * CGFloat(currentPageHorizontal)
        DISPATCH_ASYNC_MAIN_AFTER(0.01) {
            self._collectionView.setContentOffset(CGPoint(x: newX, y: targetContentOffset.pointee.y), animated: true)
        }
    }
    
}
