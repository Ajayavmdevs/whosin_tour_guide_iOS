import UIKit
import IQKeyboardManagerSwift
import RealmSwift
import Hero
import StripePaymentSheet

class VenueDetailsVC: ChildViewController {
    
    @IBOutlet weak var _veneuInfoView: CustomVenueInfoView!
    @IBOutlet weak var _backBtnWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var _closeBtn: UIButton!
    @IBOutlet weak var _backButton: UIButton!
    @IBOutlet private weak var _tableview: CustomTableView!
    @IBOutlet private weak var _visualEffectView: UIVisualEffectView!
    private let kCellIdentifierVenueDetail = String(describing: VenueDetailsTableCell.self)
    private let kCellIdentifierRating = String(describing: RatingTableCell.self)
    private let kCellIdentifierVenueOffers = String(describing: CommanOffersTableCell.self)
    private let kCellIdentifierVenueSpecialOffers = String(describing: VenueSpecialOffersTabelCell.self)
    private let kCellIdentifierVenueDesc = String(describing: VenueDescTableCell.self)
    private let kCellIdentifierExclusive = String(describing: VenueExclusiveDealsTableCell.self)
    private let kLoadingCellIdentifire = String(describing: LoadingCell.self)
    public var venueId: String = kEmptyString
    private var _page : Int = 1
    private var isPaginating = false
    public var offerId: String = kEmptyString
    public var venueDetailModel: VenueDetailModel?
    private var _offersModel: [OffersModel] = []
    private var _dealsModel: [DealsModel] = []
    private var _logoHeroId: String = kEmptyString
    private var footerView: LoadingFooterView?
    public var followStateCallBack: ((_ id: String, _ follow: Bool) -> Void)?

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _backButton.isHidden = false
        _closeBtn.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(handleSubscriptionState(_:)), name: .changeSubscriptionState, object: nil)
        NotificationCenter.default.addObserver(self, selector:  #selector(handleReload), name: kRelaodActivitInfo, object: nil)
        setupUi()
        _requestVenueDetails()
        _requestVenueOffers()
        _requestDealsById()
        _loadData(isLoading: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // --------------------------------------
    // MARK: Services
    // --------------------------------------
    
    private func _requestVenueOffers() {
        WhosinServices.getVenueOffers(venueId: venueId, day: "all", page: _page) { [weak self] container, error in
            guard let self = self else {
                self?._loadData(isLoading: false)
                return
            }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self.isPaginating = data.isEmpty
            self.footerView?.stopAnimating()
            self._offersModel.append(contentsOf: data)
            self._loadData(isLoading: false)
        }
    }
    
    private func _requestVenueDetails() {
        
        WhosinServices.getVenueDetail(venueId: venueId) { [weak self] container, error in
            guard let self = self else { return }
            self.showError(error)
            guard let data = container?.data else { return }
            self.venueDetailModel = data
            self._veneuInfoView.setupData(venue: data)
            self._loadData(isLoading: false)
        }
    }
    
    
    private func _requestDealsById() {
        WhosinServices.getDealsById(id: venueId, type: "venue") { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self._dealsModel = data
            self._loadData(isLoading: false)
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    override func setupUi() {
        _tableview.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "empty_venue".localized(),
            emptyDataIconImage: UIImage(named: "empty_offers"),
            emptyDataDescription: "empty_venue".localized(),
            delegate: self)
        _tableview.proxyDelegate = self
        _visualEffectView.alpha = 0
        _tableview.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 70, right: 0)
        _veneuInfoView.setupData(venue: venueDetailModel ?? VenueDetailModel())
        let img = UIImage(named: "icon_backArrow")?.withRenderingMode(.alwaysTemplate)
        _backButton.setImage(img, for: .normal)
        _backButton.tintColor = .white
        footerView = LoadingFooterView(frame: CGRect(x: 0, y: 0, width: _tableview.bounds.width, height: 44))
        _tableview.tableFooterView = footerView

    }
    
    private func _loadData(isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        guard let venueDetailModel = venueDetailModel else {
            cellData.append([
                kCellIdentifierKey: kLoadingCellIdentifire,
                kCellTagKey: kLoadingCellIdentifire,
                kCellObjectDataKey: kEmptyString,
                kCellClassKey: LoadingCell.self,
                kCellHeightKey: LoadingCell.height
            ])
            
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
            _tableview.loadData(cellSectionData)
            return
            
        }
        cellData.append([
            kCellIdentifierKey: kCellIdentifierVenueDetail,
            kCellTagKey: kCellIdentifierVenueDetail,
            kCellObjectDataKey: venueDetailModel,
            kCellClassKey: VenueDetailsTableCell.self,
            kCellHeightKey: VenueDetailsTableCell.height
        ])
        
        if isLoading {
            cellData.append([
                kCellIdentifierKey: kLoadingCellIdentifire,
                kCellTagKey: kLoadingCellIdentifire,
                kCellObjectDataKey: venueDetailModel,
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
            
            cellData.append([
                kCellIdentifierKey: kCellIdentifierVenueDesc,
                kCellTagKey: kCellIdentifierVenueDesc,
                kCellObjectDataKey: venueDetailModel,
                kCellClassKey: VenueDescTableCell.self,
                kCellHeightKey: VenueDescTableCell.height
            ])
            
            if venueDetailModel.isAllowRatting {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierRating,
                    kCellTagKey: kCellIdentifierRating,
                    kCellObjectDataKey: venueDetailModel,
                    kCellClassKey: RatingTableCell.self,
                    kCellHeightKey: RatingTableCell.height
                ])
            }
            
            if !venueDetailModel.specialOffers.isEmpty {
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierVenueSpecialOffers,
                    kCellTagKey: kCellIdentifierVenueSpecialOffers,
                    kCellObjectDataKey: venueDetailModel,
                    kCellClassKey: VenueSpecialOffersTabelCell.self,
                    kCellHeightKey: VenueSpecialOffersTabelCell.height
                ])
            }
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        cellData.removeAll()
        
        if !_offersModel.isEmpty {
            _offersModel.forEach { offersModel in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierVenueOffers,
                    kCellTagKey: offersModel.id,
                    kCellObjectDataKey: offersModel,
                    kCellClassKey: CommanOffersTableCell.self,
                    kCellHeightKey: CommanOffersTableCell.height
                ])
            }
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableview.loadData(cellSectionData)
        
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierVenueDetail, kCellNibNameKey: kCellIdentifierVenueDetail, kCellClassKey: VenueDetailsTableCell.self, kCellHeightKey: VenueDetailsTableCell.height],
            [kCellIdentifierKey: kCellIdentifierRating, kCellNibNameKey: kCellIdentifierRating, kCellClassKey: RatingTableCell.self, kCellHeightKey: RatingTableCell.height],
            [kCellIdentifierKey: kCellIdentifierVenueOffers, kCellNibNameKey: kCellIdentifierVenueOffers, kCellClassKey: CommanOffersTableCell.self, kCellHeightKey: CommanOffersTableCell.height],
            [kCellIdentifierKey: kCellIdentifierVenueDesc, kCellNibNameKey: kCellIdentifierVenueDesc, kCellClassKey: VenueDescTableCell.self, kCellHeightKey: VenueDescTableCell.height],
            [kCellIdentifierKey: kCellIdentifierExclusive, kCellNibNameKey: kCellIdentifierExclusive, kCellClassKey: VenueExclusiveDealsTableCell.self, kCellHeightKey: VenueExclusiveDealsTableCell.height],
            [kCellIdentifierKey: kCellIdentifierVenueSpecialOffers, kCellNibNameKey: kCellIdentifierVenueSpecialOffers, kCellClassKey: VenueSpecialOffersTabelCell.self, kCellHeightKey: VenueSpecialOffersTabelCell.height],
            [kCellIdentifierKey: kLoadingCellIdentifire, kCellNibNameKey: kLoadingCellIdentifire, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height]
        ]
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @objc func _imageBgTap(sender : UITapGestureRecognizer) {
        
        guard let venues = HomeRepository.getStoryArrayByVenueId(self.venueId) else { return }
        let controller = INIT_CONTROLLER_XIB(ContentViewVC.self)
        controller.modalPresentationStyle = .overFullScreen
        controller.pages = venues
        controller.currentIndex = 0
        controller.hero.isEnabled = true
        controller.hero.modalAnimationType = .none
        controller.view.hero.id = _logoHeroId
        controller.view.hero.modifiers = HeroAnimationModifier.stories
        self.present(controller, animated: true)
    }
    
    @objc func handleReload() {
        _requestVenueDetails()
    }
    
    @objc func handleSubscriptionState(_ notification: Notification) {
        _tableview.reload()
    }
    
    @IBAction private func _handleBackNavigateEvennt(_ sender: UIButton) {
        self._dismissVC()
    }
    
    @IBAction private func backButtonAction() {
        self._dismissVC()
    }

    private func _dismissVC() {
        if self.isVCPresented {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

}

extension VenueDetailsVC: CustomTableViewDelegate, UIScrollViewDelegate, UITableViewDelegate {
    
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
                self._visualEffectView.alpha = 0.0
            }, completion: nil)
        }
        let scrollViewContentHeight = scrollView.contentSize.height
        let scrollOffsetThreshold = scrollViewContentHeight - scrollView.bounds.height * 0.8
        if scrollView.contentOffset.y > scrollOffsetThreshold && !isPaginating {
            performPagination()
        }

    }
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? VenueDetailsTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? VenueDetailModel else { return }
            cell.setupData(object) { [weak self] in
                self?._dismissVC()
            }
            cell.followStateCallBack = { isFollow in
                self.followStateCallBack?(object.id, isFollow)
            }
        } else if let cell = cell as? VenueDescTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? VenueDetailModel else { return }
            cell.setupData(object)
        } else if let cell = cell as? VenueExclusiveDealsTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [DealsModel] else { return }
            cell.setupData(object, isFromCategory: false, venueModel: venueDetailModel)
        }else if let cell = cell as? RatingTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? VenueDetailModel else { return }
            cell.delegate = self
            cell.setupData(object)
        } else if let cell = cell as? VenueSpecialOffersTabelCell {
            guard let object = cellDict?[kCellObjectDataKey] as? VenueDetailModel else { return }
            cell.setupData(object)
        } else if let cell = cell as? CommanOffersTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? OffersModel else { return }
            object.venue = venueDetailModel
            cell.setup(object, type: .venue)
            cell._mainContainerView.backgroundColor = offerId == object.id ? UIColor(hex: "#473E66") : UIColor(hex: "#222222")
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if cell is CommanOffersTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? OffersModel else { return }
            if let pv = presentingViewController as? OfferPackageDetailVC, pv.offerId == object.id {
                _dismissVC()
                return
            }
            let vc = INIT_CONTROLLER_XIB(OfferPackageDetailVC.self)
            vc.modalPresentationStyle = .overFullScreen
            vc.offerId = object.id
            vc.venueModel = venueDetailModel
            vc.timingModel = venueDetailModel?.timing.toArrayDetached(ofType: TimingModel.self)
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
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
            presentAsPanModal(controller: vc)
        }
    }
    
    private func performPagination() {
        guard !isPaginating else { return }
        isPaginating = true
        _page += 1
        footerView?.startAnimating()
        _requestVenueOffers()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.isPaginating = false
        }
    }
    
}

extension VenueDetailsVC: desableScrollWhenRatingDelegate {
    func enableScrollEffect() {
        DISPATCH_ASYNC_MAIN_AFTER(0.5) {
            self._tableview.isScrollEnabled = true
        }
    }
    
    func desableScrollEffect() {
        _tableview.isScrollEnabled = false
    }
}
