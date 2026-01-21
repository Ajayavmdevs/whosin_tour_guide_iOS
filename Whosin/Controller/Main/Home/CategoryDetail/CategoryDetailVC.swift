import UIKit
import RealmSwift
import Hero
import StripeCore

class CategoryDetailVC: ChildViewController {
    
    @IBOutlet weak var _title: UILabel!
    @IBOutlet weak var _backButton: UIButton!
    @IBOutlet weak var _visualEffectView: UIVisualEffectView!
    @IBOutlet var _bgView: GradientView!
    @IBOutlet private weak var _tableview: CustomTableView!
    private let kCellIdentifierVenueOffers = String(describing: CommanOffersTableCell.self)
    private let kCellIdentifierExclusive = String(describing: DealRecommendedTableCell.self)
    private let kCellIdentifierHeader = String(describing: CategoryHeaderTableCell.self)
    private let kLoadingCellIdentifier = String(describing: LoadingCell.self)
    private let kEmptyCellIdentifier = String(describing: EmptyDataCell.self)
    public var categoryId: String = kEmptyString
    private var daysArray: [String] = ["All","Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
    private var _selectedDay: String = kEmptyString
    private var _page : Int = 1
    private var isPaginating = false
    public var categoryDetailModel: CategoryDetailModel?
    private var _categoryOffersModel: [OffersModel] = []
    var titleStr: String?
    private var topColor: String?
    private var footerView: LoadingFooterView?
    private var _emptyData = [[String:Any]]()
    private var hasDataFirstTime: Bool = false
    private var headerView : CustomDaysHeaderView?
    private var isEmptyDataShow: Bool = false
    
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(handleSubscriptionState(_:)), name: .changeSubscriptionState, object: nil)
        self.categoryId = categoryDetailModel?.id ?? categoryId
        topColor = categoryDetailModel?.color?.startColor
        setupUi()
    }
    
    // --------------------------------------
    // MARK: Services
    // --------------------------------------
    
    private func _firstRequestCategoryOffers() {
        WhosinServices.getCategoryOffers(categoryId: categoryId, day: _selectedDay, page: _page) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            self.footerView?.stopAnimating()
            self._categoryOffersModel.removeAll()
            guard let data = container?.data else {
                self._loadDataOffers(isLoading: false)
                return
            }
            if data.count >= 30 {
                self.isPaginating = false
            }
            self._categoryOffersModel.append(contentsOf: data)
            if self._categoryOffersModel.isEmpty {
                self.hasDataFirstTime = false
            } else {
                self.hasDataFirstTime = true
            }
            self.isEmptyDataShow = true
            self._loadDataOffers(isLoading: false)
        }
    }

    private func _requestCategoryOffers() {
        WhosinServices.getCategoryOffers(categoryId: categoryId, day: _selectedDay, page: _page) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            self.footerView?.stopAnimating()
            guard let data = container?.data else {
                self._loadDataOffers(isLoading: false)
                return
            }
            if data.count >= 30 {
                self.isPaginating = false
            }
            if self._page == 1, self._categoryOffersModel.count < 30 {
                self._categoryOffersModel.removeAll()
            }
            self._categoryOffersModel.append(contentsOf: data)
            self._loadDataOffers(isLoading: false)
        }
    }
    
    private func _requestCategoryDetails() {
        showHUD()
        WhosinServices.getCategoryDetail(categoryId: categoryId) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            if let data = container?.data {
                self.categoryDetailModel = data
                self._title.text = data.title
                if let tmpColor = self.topColor {
                    self._bgView.startColor = UIColor(hex: tmpColor) ?? ColorBrand.brandPink
                } else {
                    self._bgView.startColor = UIColor(hex: data.color?.startColor ?? "") ?? ColorBrand.brandPink
                }
                self._bgView.endColor = .clear
            }
            else {
                self._title.text = container?.data?.title ?? kEmptyString
                if let tmpColor = self.topColor {
                    self._bgView.startColor = UIColor(hex: tmpColor) ?? ColorBrand.brandPink
                } else {
                    self._bgView.startColor = UIColor(hex: container?.data?.color?.startColor ?? "") ?? ColorBrand.brandPink
                }
                self._bgView.endColor = .clear
            }
            self._loadDataOffers(isLoading: true)
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    override func setupUi() {
        //TABEL VIEW
        _tableview.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataDescription: nil,
            delegate: self)
        _tableview.proxyDelegate = self
        _tableview.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 75, right: 0)
        footerView = LoadingFooterView(frame: CGRect(x: 0, y: 0, width: _tableview.bounds.width, height: 44))
        _tableview.tableFooterView = footerView
        _visualEffectView.alpha = 0
        _title.text = titleStr
        _selectedDay = "all"
        let img = UIImage(named: "icon_backArrow")?.withRenderingMode(.alwaysTemplate)
        _backButton.setImage(img, for: .normal)
        _backButton.tintColor = .white
        _emptyData.append(["title" : LANGMANAGER.localizedString(forKey: "siesta_message", arguments: ["value": titleStr ?? ""]), "icon": "empty_offers"])
        isEmptyDataShow = false
        _requestCategoryDetails()
        _firstRequestCategoryOffers()

    }
    
    private func _loadDataOffers(isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        guard let categoryDetailModel = categoryDetailModel else { return }
        
        if !categoryDetailModel.bannersModel.isEmpty {
            cellData.append([
                kCellIdentifierKey: kCellIdentifierHeader,
                kCellTagKey: kCellIdentifierHeader,
                kCellObjectDataKey: categoryDetailModel.detached(),
                kCellClassKey: CategoryHeaderTableCell.self,
                kCellHeightKey: CategoryHeaderTableCell.height
            ])
        }
        
        if !categoryDetailModel.dealsModel.isEmpty {
            cellData.append([
                kCellIdentifierKey: kCellIdentifierExclusive,
                kCellTagKey: kCellIdentifierExclusive,
                kCellObjectDataKey: categoryDetailModel.dealsModel.toArrayDetached(ofType: DealsModel.self),
                kCellClassKey: DealRecommendedTableCell.self,
                kCellHeightKey: DealRecommendedTableCell.height
            ])
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        cellData.removeAll()
        
        if !_categoryOffersModel.isEmpty {
            _categoryOffersModel.forEach { offersModel in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierVenueOffers,
                    kCellDifferenceIdentifierKey: offersModel.id,
                    kCellDifferenceContentKey : offersModel,
                    kCellTagKey: offersModel.id,
                    kCellObjectDataKey: offersModel,
                    kCellClassKey: CommanOffersTableCell.self,
                    kCellHeightKey: CommanOffersTableCell.height
                ])
            }
        } else {
            if isEmptyDataShow {
                _emptyData.forEach { emptyData in
                    cellData.append([
                        kCellIdentifierKey: kEmptyCellIdentifier,
                        kCellTagKey: kEmptyCellIdentifier,
                        kCellObjectDataKey: emptyData,
                        kCellClassKey: EmptyDataCell.self,
                        kCellHeightKey: EmptyDataCell.height
                    ])
                }
            }
        }

        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionReloadKey: true, kSectionDataKey: cellData])
        cellData.removeAll()
        _tableview.loadData(cellSectionData)
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierVenueOffers, kCellNibNameKey: kCellIdentifierVenueOffers, kCellClassKey: CommanOffersTableCell.self, kCellHeightKey: CommanOffersTableCell.height],
            [kCellIdentifierKey: kCellIdentifierExclusive, kCellNibNameKey: kCellIdentifierExclusive, kCellClassKey: DealRecommendedTableCell.self, kCellHeightKey: DealRecommendedTableCell.height],
            [kCellIdentifierKey: kCellIdentifierHeader, kCellNibNameKey: kCellIdentifierHeader, kCellClassKey: CategoryHeaderTableCell.self, kCellHeightKey: CategoryHeaderTableCell.height],
            [kCellIdentifierKey: kLoadingCellIdentifier, kCellNibNameKey: kLoadingCellIdentifier, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height],
            [kCellIdentifierKey: kEmptyCellIdentifier, kCellNibNameKey: kEmptyCellIdentifier, kCellClassKey: EmptyDataCell.self, kCellHeightKey: EmptyDataCell.height]
        ]
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @objc func handleSubscriptionState(_ notification: Notification) {
      //  _tableview.reload()
    }
    
    @IBAction private func _handleBackEvent(_ sender: UIButton) {
        if self.isVCPresented {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }

    }
    
    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        if self.isVCPresented {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}

extension CategoryDetailVC: CustomTableViewDelegate, UIScrollViewDelegate, UITableViewDelegate {
    
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
        let scrollOffsetThreshold = scrollViewContentHeight - scrollView.bounds.height
        if scrollView.contentOffset.y > scrollOffsetThreshold && !isPaginating {
            performPagination()
        }
    }
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? EmptyDataCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [String:Any] else { return }
            cell.setupData(object)
        } else if let cell = cell as? CategoryHeaderTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? CategoryDetailModel else { return }
            var banners = object.bannersModel.toArrayDetached(ofType: BannerModel.self)
            banners.sort{ $0.image < $1.image }
            cell.setupData(banners)
        } else if let cell = cell as? DealRecommendedTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [DealsModel] else { return }
            cell._titleBgView.isHidden = true
            cell.setupData(object)
        } else if let cell = cell as? CommanOffersTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? OffersModel else { return }
            cell.setup(object, type: .category)
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? CommanOffersTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? OffersModel else { return }
            let vc = INIT_CONTROLLER_XIB(OfferPackageDetailVC.self)
            vc.modalPresentationStyle = .overFullScreen
            vc.offerId = object.id
            vc.venueModel = object.venue
            vc.timingModel = object.venue?.timing.toArrayDetached(ofType: TimingModel.self)
            vc.vanueOpenCallBack = { venueId, venueModel in
                let vc = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
                vc.venueId = venueId
                vc.venueDetailModel = venueModel
                self.navigationController?.pushViewController(vc, animated: true)
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
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
            presentAsPanModal(controller: vc)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            if hasDataFirstTime {
                return 60
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if headerView == nil {
            headerView = CustomDaysHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 60))
            headerView?.delegate = self
            headerView?.setupData(daysArray, selectedDay: _selectedDay, isFromExplore: false)
            
            let blurEffect = UIBlurEffect(style: .regular)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = headerView!.bounds
            blurView.backgroundColor = .clear
//            headerView?.addSubview(blurView)
            headerView?.insertSubview(blurView, at: 0)
        }
        return headerView
    }
    
    private func performPagination() {
        guard !isPaginating else { return }
        isPaginating = true
        _page += 1
        footerView?.startAnimating()
        _requestCategoryOffers()
    }
    
}

extension CategoryDetailVC: CustomDaysHeaderViewDelegate {
    func removeAction(filter: String) {
    }
    
    func didSelectDay(_ day: String) {
        _selectedDay = day
        _page = 1
        _categoryOffersModel.removeAll()
        _requestCategoryOffers()
    }
}

