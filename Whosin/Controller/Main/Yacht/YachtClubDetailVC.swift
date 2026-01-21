import UIKit
import RealmSwift
import Hero

class YachtClubDetailVC: ChildViewController {

    @IBOutlet private weak var _tableview: CustomTableView!
    @IBOutlet weak var _yachtInfoView: CustomVenueInfoView!
    @IBOutlet private weak var _backButton: UIButton!
    @IBOutlet private weak var _visualEffectView: UIVisualEffectView!
    private let kCellIdentifierVenueDetail = String(describing: YachtClubDetailsTableCell.self)
    private let kCellIdentifierRating = String(describing: RatingTableCell.self)
    private let kCellIdentifierDesc = String(describing: YachtDescTableCell.self)
    private let kLoadingCellIdentifier = String(describing: LoadingCell.self)
    private let kCellIdentifierExclusive = String(describing: VenueExclusiveDealsTableCell.self)
    private let kCellYachInfoCellIdentifire = String(describing: YachtInfoTableCell.self)
    private let kYachOfferCellIdentifire = String(describing: YachtOfferListTableCell.self)
    private let kTitleCell = String(describing: CommonTitleCell.self)
    
    public var yachtClubId: String = kEmptyString
    public var yachDetailModel: YachtClubModel?
    private var _dealsModel: [DealsModel] = []
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
        _loadData(isLoading: true)
        _requestYachtClubDetails()
        _requestDealsById()
    }
    
    // --------------------------------------
    // MARK: Services
    // --------------------------------------
        
    private func _requestYachtClubDetails() {
        WhosinServices.getyachtClubDetail(yachtClubId: yachtClubId) { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container?.data else { return }
            self.yachDetailModel = data
            self._loadData(isLoading: false)
        }
    }
    
    private func _requestDealsById() {
        WhosinServices.getDealsById(id: yachtClubId, type: "yacht") { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container?.data else { return }
            self._dealsModel = data
            self._loadData(isLoading: false)
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    override func setupUi() {
        //TABEL VIEW
        _tableview.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: true,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "There is no data available",
            emptyDataIconImage: UIImage(named: "empty_offers"),
            emptyDataDescription: nil,
            delegate: self)
        _tableview.proxyDelegate = self
        _visualEffectView.alpha = 0
    }
    
    private func _loadData(isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        guard let yachDetailModel = yachDetailModel else { return }
        
        cellData.append([
            kCellIdentifierKey: kCellIdentifierVenueDetail,
            kCellTagKey: kCellIdentifierVenueDetail,
            kCellObjectDataKey: yachDetailModel,
            kCellClassKey: YachtClubDetailsTableCell.self,
            kCellHeightKey: YachtClubDetailsTableCell.height
        ])
        
        cellData.append([
            kCellIdentifierKey: kCellIdentifierDesc,
            kCellTagKey: kCellIdentifierDesc,
            kCellObjectDataKey: yachDetailModel,
            kCellClassKey: YachtDescTableCell.self,
            kCellHeightKey: YachtDescTableCell.height
        ])
        
        if isLoading {
            cellData.append([
                kCellIdentifierKey: kLoadingCellIdentifier,
                kCellTagKey: kLoadingCellIdentifier,
                kCellObjectDataKey: yachDetailModel,
                kCellClassKey: LoadingCell.self,
                kCellHeightKey: LoadingCell.height
            ])
        } else {
            if !_dealsModel.isEmpty {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierExclusive,
                    kCellTagKey: kCellIdentifierExclusive,
                    kCellObjectDataKey: _dealsModel,
                    kCellClassKey: VenueExclusiveDealsTableCell.self,
                    kCellHeightKey: VenueExclusiveDealsTableCell.height
                ])
            }
            
            if yachDetailModel.isAllowRating {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierRating,
                    kCellTagKey: kCellIdentifierRating,
                    kCellObjectDataKey: yachDetailModel,
                    kCellClassKey: RatingTableCell.self,
                    kCellHeightKey: RatingTableCell.height
                ])
            }
            
            if !yachDetailModel.yachts.isEmpty {
                cellData.append([
                    kCellIdentifierKey: kCellYachInfoCellIdentifire,
                    kCellTagKey: kCellYachInfoCellIdentifire,
                    kCellObjectDataKey: yachDetailModel.yachts.toArrayDetached(ofType: YachtDetailModel.self),
                    kCellClassKey: YachtInfoTableCell.self,
                    kCellHeightKey: YachtInfoTableCell.height
                ])
            }
            if !yachDetailModel.offers.isEmpty {
                cellData.append([
                    kCellIdentifierKey: kTitleCell,
                    kCellTagKey: kTitleCell,
                    kCellObjectDataKey: true,
                    kCellClassKey: CommonTitleCell.self,
                    kCellHeightKey: CommonTitleCell.height
                ])
            }
            
            yachDetailModel.offers.forEach { model in
                let yacht = yachDetailModel.yachts.first(where: { $0.id == model.yachtId})
                cellData.append([
                    kCellIdentifierKey: kYachOfferCellIdentifire,
                    kCellTagKey: yacht,
                    kCellObjectDataKey: model,
                    kCellClassKey: YachtOfferListTableCell.self,
                    kCellHeightKey: YachtOfferListTableCell.height
                ])
                
            }
            //            cellData.append([
            //                kCellIdentifierKey: kCellIdentifierRating,
            //                kCellTagKey: kCellIdentifierRating,
            //                kCellObjectDataKey: yachDetailModel,
            //                kCellClassKey: RatingTableCell.self,
            //                kCellHeightKey: RatingTableCell.height
            //            ])
        }
        
        if cellData.count != .zero {
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        }
        
        _yachtInfoView.setupYachtData(yacht: yachDetailModel)
        _tableview.loadData(cellSectionData)
        
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierVenueDetail, kCellNibNameKey: kCellIdentifierVenueDetail, kCellClassKey: YachtClubDetailsTableCell.self, kCellHeightKey: YachtClubDetailsTableCell.height],
            [kCellIdentifierKey: kCellIdentifierRating, kCellNibNameKey: kCellIdentifierRating, kCellClassKey: RatingTableCell.self, kCellHeightKey: RatingTableCell.height],
            [kCellIdentifierKey: kCellIdentifierDesc, kCellNibNameKey: kCellIdentifierDesc, kCellClassKey: YachtDescTableCell.self, kCellHeightKey: YachtDescTableCell.height],
            [kCellIdentifierKey: kCellIdentifierExclusive, kCellNibNameKey: kCellIdentifierExclusive, kCellClassKey: VenueExclusiveDealsTableCell.self, kCellHeightKey: VenueExclusiveDealsTableCell.height],
            [kCellIdentifierKey: kYachOfferCellIdentifire, kCellNibNameKey: kYachOfferCellIdentifire, kCellClassKey: YachtOfferListTableCell.self, kCellHeightKey: YachtOfferListTableCell.height],
            [kCellIdentifierKey: kCellYachInfoCellIdentifire, kCellNibNameKey: kCellYachInfoCellIdentifire, kCellClassKey: YachtInfoTableCell.self, kCellHeightKey: YachtInfoTableCell.height],
            [kCellIdentifierKey: kTitleCell, kCellNibNameKey: kTitleCell, kCellClassKey: CommonTitleCell.self, kCellHeightKey: CommonTitleCell.height],
            [kCellIdentifierKey: kLoadingCellIdentifier, kCellNibNameKey: kLoadingCellIdentifier, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height]
        ]
        
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }

}

extension YachtClubDetailVC: CustomTableViewDelegate, UIScrollViewDelegate, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        let threshold: CGFloat = 20
        if yOffset > threshold {
            UIView.animate(withDuration: 0.50, animations: { [weak self] in
                guard let self = self else { return }
                self._visualEffectView.alpha = 1.0
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.50, animations: { [weak self] in
                guard let self = self else { return }
                self._visualEffectView.alpha = 0
            }, completion: nil)
        }
    }
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? CommonTitleCell {
            cell.setup("Special Deals", subTitle: "Check our special deals for yacht reservation")
        } else if let cell = cell as? YachtClubDetailsTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? YachtClubModel else { return }
            cell.setupData(object)
        } else if let cell = cell as? YachtDescTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? YachtClubModel else { return }
            cell.setupabout(object.about)
        } else if let cell = cell as? YachtInfoTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [YachtDetailModel] else { return }
            cell.setupData(object)
        } else if let cell = cell as? RatingTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? YachtClubModel else { return }
            cell.setupYachtData(object)
        } else if let cell = cell as? YachtOfferListTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? YachtOfferDetailModel, let yacht = cellDict?[kCellTagKey] as? YachtDetailModel else { return }
            cell.setupData(object, yacht: yacht)
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
        //        else if let cell = cell as? VenueExclusiveDealsTableCell {
        //            guard let object = cellDict?[kCellObjectDataKey] as? [DealsModel] else { return }
        //            cell._titleLabel.text = "Special Deals"
        //            cell._subtitleLabel.text = "Buy your voucher or send a gift to your friends"
        //            cell.setupData(object, isFromCategory: false)
        //        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if cell is YachtOfferListTableCell {
            if let object = cellDict?[kCellObjectDataKey] as? YachtOfferDetailModel {
                let vc = INIT_CONTROLLER_XIB(YachtOfferDetailVC.self)
                vc.offerId = object.id
                vc.yachDetailModel = object
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

extension YachtClubDetailVC: desableScrollWhenRatingDelegate {
    func enableScrollEffect() {
        DISPATCH_ASYNC_MAIN_AFTER(0.5) {
            self._tableview.isScrollEnabled = true
        }
    }
    
    func desableScrollEffect() {
        _tableview.isScrollEnabled = false
    }
}
