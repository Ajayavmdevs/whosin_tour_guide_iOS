import UIKit

class LargeVenueComponentTableCell: UITableViewCell {
    
    @IBOutlet private weak var _collectionView: CustomNoKeyboardCollectionView!
    @IBOutlet private weak var _titleLbl: UILabel!
    @IBOutlet private weak var _subTitleLbl: UILabel!
    private let kCellIdentifier = String(describing: LargeVenueCollectionCell.self)
    private var homeBlockModel: HomeBlockModel?
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { 358 }
    
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
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: LargeVenueCollectionCell.self, kCellHeightKey: LargeVenueCollectionCell.height],
                [kCellIdentifierKey: String(describing: LargeOffersCollectionCell.self), kCellNibNameKey: String(describing: LargeOffersCollectionCell.self), kCellClassKey: LargeOffersCollectionCell.self, kCellHeightKey: LargeOffersCollectionCell.height]]
    }
    
    private func setupUi() {
        _collectionView.setup(cellPrototypes: _prototype,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
                              spacing: CGSize(width: 10, height: 10),
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        self._collectionView.contentInset = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
    }
    
    private func _loadData() {
        guard let _homeBlock = self.homeBlockModel else { return }
        if self._collectionView.numberOfSections > 0 && self._collectionView.numberOfItems(inSection: 0) > 0 {
            let indexPath = IndexPath(item: 0, section: 0)
            self._collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
        }
        
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            guard let self = self else { return }
            
            var cellSectionData = [[String: Any]]()
            var cellData = [[String: Any]]()
            if _homeBlock.cellTypeForSearch == .venue {
                _homeBlock.venueList.forEach { venueModel in
                        cellData.append([
                            kCellIdentifierKey: self.kCellIdentifier,
                            kCellTagKey: venueModel.id,
                            kCellObjectDataKey: venueModel,
                            kCellClassKey: LargeVenueCollectionCell.self,
                            kCellHeightKey: LargeVenueCollectionCell.height,
                            kCellClickEffectKey:true
                        ])
                }
            }
            
            if _homeBlock.cellType == .venue {
                _homeBlock.venueList.forEach { venueModel in
                    if Utils.isVenueDetailEmpty(venueModel) {
                        cellData.append([
                            kCellIdentifierKey: self.kCellIdentifier,
                            kCellTagKey: venueModel.id,
                            kCellObjectDataKey: venueModel,
                            kCellClassKey: LargeVenueCollectionCell.self,
                            kCellHeightKey: LargeVenueCollectionCell.height,
                            kCellClickEffectKey:true
                        ])
                    }
                }
            } else {
                _homeBlock.offerList.forEach { offersModel in
                    if !Utils.isVenueDetailEmpty(offersModel.venue) {
                        cellData.append([
                            kCellIdentifierKey: String(describing: LargeOffersCollectionCell.self),
                            kCellTagKey: offersModel.id,
                            kCellObjectDataKey: offersModel,
                            kCellClassKey: LargeOffersCollectionCell.self,
                            kCellHeightKey: LargeOffersCollectionCell.height
                        ])
                    }
                }
            }
            
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
            DispatchQueue.main.async {
                self._collectionView.loadData(cellSectionData)
            }
        }
        
    }
    
    private func _openVenueDetail(_ venueId: String, venueDetail: VenueDetailModel?, animationId: String) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        let vc = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
        vc.venueId = venueId
        vc.venueDetailModel = venueDetail
        vc.hidesBottomBarWhenPushed = false
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: HomeBlockModel) {
        homeBlockModel = nil
        homeBlockModel = data
        _loadData()
        _titleLbl.text = data.title
        _subTitleLbl.text = data.descriptions
    }
    
}

extension LargeVenueComponentTableCell: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? LargeVenueCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? VenueDetailModel else { return }
            cell.setUpdata(object)
        }
        else if let cell = cell as? LargeOffersCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? OffersModel else { return }
            cell.setUpdata(object)
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        parentBaseController?.feedbackGenerator?.impactOccurred()
        if let cell = cell as? LargeVenueCollectionCell {
            if cellDict?[kCellObjectDataKey] is VenueDetailModel {
                guard let object = cellDict?[kCellObjectDataKey] as? VenueDetailModel, let homeBlock = homeBlockModel else { return }
                let heroId = object.id  + "_open_detail_from_large_venue_cell" + homeBlock.id + Utils.randomString(length: 10)
                cell._mainContainerView.hero.id = heroId
                cell._mainContainerView.hero.modifiers = HeroAnimationModifier.stories
                _openVenueDetail(object.id, venueDetail: object, animationId: heroId)
            }
        }
        else if let cell = cell as? LargeOffersCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? OffersModel, let homeBlock = homeBlockModel else { return }
            let heroId = object.id + "_open_detail_from_large_offer_cell" + homeBlock.id + Utils.randomString(length: 10)
            cell._mainContainerView.hero.id = heroId
            cell._mainContainerView.hero.modifiers = HeroAnimationModifier.stories
            let venueId = object.venue?.id ?? object.venueId
            _openVenueDetail(venueId, venueDetail: object.venue, animationId: heroId)
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        guard let _homeBlock = homeBlockModel else { return .zero }
        if _homeBlock.cellTypeForSearch == .venue {
            return CGSize(width: _homeBlock.venues.count == 1 ? kScreenWidth - 28 : kScreenWidth * 0.90, height: LargeVenueCollectionCell.height)
        }
        if _homeBlock.cellType == .venue {
            return CGSize(width: _homeBlock.venues.count == 1 ? kScreenWidth - 28 : kScreenWidth * 0.90, height: LargeVenueCollectionCell.height)
        }
        else {
            return CGSize(width: _homeBlock.offers.count == 1 ? kScreenWidth - 28 : kScreenWidth * 0.90, height: LargeOffersCollectionCell.height)
        }
    }
    
}

