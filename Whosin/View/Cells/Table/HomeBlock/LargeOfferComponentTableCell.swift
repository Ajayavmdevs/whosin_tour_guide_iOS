

import UIKit
import StripeCore

class LargeOfferComponentTableCell: UITableViewCell {

    @IBOutlet weak var _collectionView: CustomNoKeyboardCollectionView!
    @IBOutlet private weak var _titleLbl: UILabel!
    @IBOutlet private weak var _subTitleLbl: UILabel!
    private let kCellIdentifier = String(describing: HomeOffersCollectionCell.self)
    private var homeBlockModel: HomeBlockModel?

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat {
        UITableView.automaticDimension
    }

    override func prepareForReuse() {
        super.prepareForReuse()
//        guard let homeBlockModel = homeBlockModel else { return }
//        _loadData()
//        _titleLbl.text = homeBlockModel.title
//        _subTitleLbl.text = homeBlockModel.descriptions
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
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: HomeOffersCollectionCell.self, kCellHeightKey: HomeOffersCollectionCell.height]]
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
            self.homeBlockModel?.offerList.forEach { offersModel in
                    cellData.append([
                        kCellIdentifierKey: self.kCellIdentifier,
                        kCellTagKey: offersModel.id,
                        kCellObjectDataKey: offersModel,
                        kCellClassKey: LargeOffersCollectionCell.self,
                        kCellHeightKey: LargeOffersCollectionCell.height
                    ])
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
        _loadData()
        _titleLbl.text = data.title
        _subTitleLbl.text = data.descriptions
    }

}

extension LargeOfferComponentTableCell: CustomNoKeyboardCollectionViewDelegate {
        
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        let cell = cell as? HomeOffersCollectionCell
        guard let object = cellDict?[kCellObjectDataKey] as? OffersModel else { return }
        cell?.setupData(object)
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? OffersModel else { return }
        guard let venueId = object.venue?.id else { return }
        let cell = cell as? HomeOffersCollectionCell
        parentBaseController?.feedbackGenerator?.impactOccurred()
        let randomstring = Utils.randomString(length: 20, id: venueId + object.id)
        cell?._mainContainerView.hero.id = venueId + "_open_detail_from_large_offer_cell" + object.id + randomstring
        let vc = INIT_CONTROLLER_XIB(OfferPackageDetailVC.self)
        vc.offerId = object.id
        vc.venueModel = object.venue
        vc.timingModel = object.venue?.timing.toArrayDetached(ofType: TimingModel.self)
        vc.modalPresentationStyle = .overFullScreen
        vc.vanueOpenCallBack = { venueId, venueModel in
            let vc = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
            vc.venueId = venueId
            vc.venueDetailModel = venueModel
            self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
        }
        vc.buyNowOpenCallBack = { offer, venue, timing in
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

        parentViewController?.navigationController?.presentAsPanModal(controller: vc)
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        if homeBlockModel?.offers.count == 1 {
            return CGSize(width: collectionView.frame.width - 28, height: HomeOffersCollectionCell.height)
        } else {
            return CGSize(width: kScreenWidth * 0.9, height: HomeOffersCollectionCell.height)
        }
    }

}
