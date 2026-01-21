import UIKit
import Hero

class CustomVenueComponetCell: UITableViewCell {
    
    @IBOutlet private weak var _collectionView: CustomNoKeyboardCollectionView!
    private let kCellIdentifier = String(describing: CustomVenueCollectionCell.self)
    private var homeBlockModel: HomeBlockModel?
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUi()
        disableSelectEffect()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        410
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self._loadData()
    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: String(describing: CustomVenueCollectionCell.self), kCellClassKey: CustomVenueCollectionCell.self, kCellHeightKey: CustomVenueCollectionCell.height]]
    }
    
    private func setupUi() {
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
        
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            guard let self = self else { return }
            var cellSectionData = [[String: Any]]()
            var cellData = [[String: Any]]()
            
            if self.homeBlockModel?.type == "custom-venue" {
                self.homeBlockModel?.customVenuesList.forEach { venueModel in
                        cellData.append([
                            kCellIdentifierKey: self.kCellIdentifier,
                            kCellTagKey: venueModel.id,
                            kCellObjectDataKey: venueModel,
                            kCellClassKey: CustomVenueCollectionCell.self,
                            kCellHeightKey: CustomVenueCollectionCell.height
                        ])
                    

                }
            } else if self.homeBlockModel?.type == "custom-offer" {
                self.homeBlockModel?.customOffersList.forEach { offer in
                        cellData.append([
                            kCellIdentifierKey: self.kCellIdentifier,
                            kCellTagKey: offer.id,
                            kCellObjectDataKey: offer,
                            kCellClassKey: CustomVenueCollectionCell.self,
                            kCellHeightKey: CustomVenueCollectionCell.height
                        ])
                    
                }
            }
            
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
            DispatchQueue.main.async {
                self._collectionView.loadData(cellSectionData)
            }
        }
        
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: HomeBlockModel) {
        homeBlockModel = data
        self._loadData()
    }
    
    private func _viewDetails(heroId: String, isOffers: Bool, customVenueModel: CustomVenuesModel) {
        let controller = INIT_CONTROLLER_XIB(OffersDetailVC.self)
        controller.heroId = heroId
        controller.modalPresentationStyle = .overFullScreen
        controller.hero.isEnabled = true
        controller.hero.modalAnimationType = .none
        controller.customVenueModel = customVenueModel
        controller.callback = {
            if let venueModel = customVenueModel.venueModel == nil ? customVenueModel.offerModel?.venue : customVenueModel.venueModel {
                let vc = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
                vc.venueDetailModel = venueModel
                vc.venueId = venueModel.id
                self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        parentViewController?.present(controller, animated: true)
    }
    
}

extension CustomVenueComponetCell: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? CustomVenueCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? CustomVenuesModel else { return }
            if homeBlockModel?.type == "custom-venue" {
                cell.setUpdata(object)
            } else if homeBlockModel?.type == "custom-offer" {
                cell.setUpOffersdata(object)
            }
        }
       
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        if homeBlockModel?.type == "custom-venue" {
            if homeBlockModel?.customVenuesList.count == 1 {
                return CGSize(width: collectionView.frame.width - 28, height: CustomVenueCollectionCell.height)
            } else {
                let cSize = CGSize(width: kScreenWidth * 0.90 , height: CustomVenueCollectionCell.height)
                return cSize
            }
        } else if homeBlockModel?.type == "custom-offer" {
            if homeBlockModel?.customOffersList.count == 1 {
                return CGSize(width: collectionView.frame.width - 28, height: CustomVenueCollectionCell.height)
            } else {
                let cSize = CGSize(width: kScreenWidth * 0.90 , height: CustomVenueCollectionCell.height)
                return cSize
            }
        } else {
            let cSize = CGSize(width: kScreenWidth * 0.90 , height: CustomVenueCollectionCell.height)
            return cSize
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if cell is CustomVenueCollectionCell {
            guard let tag = cellDict?[kCellTagKey] as? String else { return }
            guard let object = cellDict?[kCellObjectDataKey] as? CustomVenuesModel else { return }
            _viewDetails(heroId: tag, isOffers: object.offerId != nil ,customVenueModel: object)
        }
    }
}
