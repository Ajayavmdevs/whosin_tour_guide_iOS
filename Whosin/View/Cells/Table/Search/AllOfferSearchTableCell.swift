import UIKit

class AllOfferSearchTableCell: UITableViewCell {
    
    public var delegate: ShowCategoryDetailsDelegate?
    @IBOutlet weak var _titleLabel: UILabel!
    @IBOutlet weak var _collectionView: CustomNoKeyboardCollectionView!
    private let kCellIdentifierOffer = String(describing: OfferSearchCollectionCell.self)
    private var _offerModel: [OffersModel] = []
    
    
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { 385 }
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUi()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func setupUi() {
        let spacing = 10
        _collectionView.setup(cellPrototypes: _prototypes,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1.1,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: .zero, left: 10, bottom: .zero, right: 0),
                              spacing: CGSize(width: spacing, height: spacing),
                              scrollDirection: .horizontal,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
        _collectionView.reload()
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        _offerModel.forEach { offer in
            cellData.append([
                kCellIdentifierKey: kCellIdentifierOffer,
                kCellTagKey: kCellIdentifierOffer,
                kCellObjectDataKey: offer,
                kCellClassKey: OfferSearchCollectionCell.self,
                kCellHeightKey: OfferSearchCollectionCell.height
            ])
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifierOffer, kCellNibNameKey: String(describing: OfferSearchCollectionCell.self), kCellClassKey: OfferSearchCollectionCell.self, kCellHeightKey: OfferSearchCollectionCell.height]]
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ data: [OffersModel]) {
        _offerModel = data
        _loadData()
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction func _handleMoreEvent(_ sender: UIButton) {
        delegate?.didSelectCategory("offer")
    }
    
}

// --------------------------------------
// MARK: Custom Collection View
// --------------------------------------

extension AllOfferSearchTableCell: CustomNoKeyboardCollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? OfferSearchCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? OffersModel else { return }
            cell.setupData(object)
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? OffersModel else { return }
        
        APPSETTING.addSearchHistory(id: object.id, title: object.title, subtitle: object.descriptions, type: "offer", image: object.image, venueId: object.venue?.id ?? kEmptyString)
        
        let controller = INIT_CONTROLLER_XIB(OfferPackageDetailVC.self)
        controller.offerId = object.id
        controller.venueModel = object.venue
        controller.timingModel = object.venue?.timing.toArrayDetached(ofType: TimingModel.self)

        controller.modalPresentationStyle = .overFullScreen
        controller.vanueOpenCallBack = { venueId, venueModel in
            let vc = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
            vc.venueId = venueId
            vc.venueDetailModel = venueModel
            self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
        }
        controller.buyNowOpenCallBack = { offer, venue, timing in
            let vc = INIT_CONTROLLER_XIB(BuyPackgeVC.self)
            vc.isFromActivity = false
            vc.type = "offers"
            vc.timingModel = timing
            vc.offerModel = offer
            vc.venue = venue
            vc.setCallback {
                let controller = INIT_CONTROLLER_XIB(MyCartVC.self)
                controller.modalPresentationStyle = .overFullScreen
                self.parentViewController?.navigationController?.pushViewController(controller, animated: true)
            }
            self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
        }
        self.parentViewController?.presentAsPanModal(controller: controller)
    }
}

