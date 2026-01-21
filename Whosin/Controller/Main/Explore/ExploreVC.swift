import UIKit
import Alamofire

class ExploreVC: NavigationBarViewController {
    
    @IBOutlet weak var _customDaysView: CustomDaysHeaderView!
    @IBOutlet weak var _titleView: UIView!
    @IBOutlet weak var _searchBar: UISearchBar!
    @IBOutlet weak var _tableView: CustomTableView!
    @IBOutlet weak var _visualEffectView: UIVisualEffectView!
    private let kCellIdentifierOffers = String(describing: CommanOffersTableCell.self)
    private let kCellIdentifierEvent = String(describing: EventSearchTableCell.self)
    private let kCellIdentifierActivity = String(describing: ActivitySearchTableCell.self)
    private let kCellIdentifiersuggested = String(describing: SuggestedFriendsTableCell.self)
    private let kEmptyCellIdentifier = String(describing: EmptyDataCell.self)
    private var _exploreData: [ExploreModel] = []
    private var _beforeDate : String = kEmptyString
    private var isPaginating = false
    private var _topMenuOptions: [CommonSettingsModel] = []
    private var _selectOption: [String]?
    private var footerView: LoadingFooterView?
    private var _filteredData: [ExploreModel] = []
    private var _suggestedVenue: [VenueDetailModel] = []
    private var suggestedUsers: [UserDetailModel] = []
    public var isSearching = false
    private var searchTimer: Timer?
    private let _stackView = UIStackView()
    private var _emptyData = [[String:Any]]()
    private var _dataRequest: DataRequest?
    private let searchActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
        setupSearchActivityIndicator()
    }
    
    private func setupSearchActivityIndicator() {
        searchActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        _searchBar.addSubview(searchActivityIndicator)
        
        NSLayoutConstraint.activate([
            searchActivityIndicator.centerYAnchor.constraint(equalTo: _searchBar.centerYAnchor),
            searchActivityIndicator.trailingAnchor.constraint(equalTo: _searchBar.trailingAnchor, constant: -40)
        ])
    }
    
    override func setupUi() {
        hideNavigationBar()
        showHUD()
        _stackView.axis = .vertical
        _stackView.spacing = 0
        _stackView.distribution = .fillProportionally
        _searchBar.delegate = self
        _searchBar.setSearchFieldBackgroundImage(UIImage(named: "img_search_bg"), for: .normal)
        _searchBar.isUserInteractionEnabled = true
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: true,
            emptyDataText: kEmptyString,
            emptyDataIconImage: UIImage(named: "empty_explore"),
            emptyDataDescription: "empty_explore_page".localized(),
            delegate: self,
            adSize: .large)
        _tableView.proxyDelegate = self
        _visualEffectView.alpha = 0.0
        footerView = LoadingFooterView(frame: CGRect(x: 0, y: 0, width: _tableView.bounds.width, height: 44))
        _tableView.tableFooterView = footerView
        _requestGetFilterData()
        _requestSuggestedFriend(APPSESSION.userDetail?.id ?? kEmptyString)
        _requestSuggestedVenue()
        emptyData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func doneButtonTapped() {
        view.endEditing(true)
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestExplore(_ searchTxt: String = kEmptyString) {
        if let request = _dataRequest {
            if !request.isCancelled || !request.isFinished || !request.isSuspended {
                request.cancel()
            }
        }
        _tableView.startRefreshing()
        self.isRequesting = true
        guard let model = _selectOption else { return }
        _dataRequest = WhosinServices.explore(dateBefore: _beforeDate, limit: 30, id: model, search: searchTxt) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            self.footerView?.stopAnimating()
            self.searchActivityIndicator.stopAnimating()
            self.isRequesting = false
            self._tableView.endRefreshing()
            guard let data = container?.data else { return }
            if Utils.stringIsNullOrEmpty(self._beforeDate) {
                let contentOffset = CGPoint(x: 0, y: 0)
                self._tableView.setContentOffset(contentOffset, animated: true)
                if self.isSearching {
                    self._filteredData = data
                } else {
                    self._exploreData = data
                }
            } else {
                if self.isSearching {
                    self._filteredData.append(contentsOf: data)
                } else {
                    self._exploreData.append(contentsOf: data)
                }
            }
            self._loadData()
        }
    }
    
    private func _requestSuggestedVenue() {
        WhosinServices.getSuggestedVenueDetail(venueId: kEmptyString) { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container?.data else { return }
            self._suggestedVenue = data
            
            let headerView2 = SuggestedView.initFromNib()
            headerView2.setupData(venues: _suggestedVenue, title: "Suggested venue", isVenue: true)
            headerView2.removeVenueCallBack = { id in
                if let index = self._suggestedVenue.firstIndex(where: { $0.id == id }) {
                    self._suggestedVenue.remove(at: index)
                }
            }
            
            if !_suggestedVenue.isEmpty {
                _stackView.addArrangedSubview(headerView2)
            }
            
            _stackView.frame.size.height = _stackView.frame.height + (SuggestedVenueCollectionCell.height + 45)
            _tableView.tableHeaderView = _stackView
        }
    }
    
    private func _requestSuggestedFriend(_ id: String) {
        WhosinServices.getSuggestedUserById(userId: kEmptyString) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self.suggestedUsers = data
            let headerView1 = SuggestedView.initFromNib()
            headerView1.setupData(suggestedUsers, title: "suggested_friends".localized(), isVenue: false)
            headerView1.removeUserCallBack = { id in
                if let index = self.suggestedUsers.firstIndex(where: { $0.id == id }) {
                    self.suggestedUsers.remove(at: index)
                }
            }
            
            if !suggestedUsers.isEmpty {
                _stackView.addArrangedSubview(headerView1)
            }
            _stackView.frame.size.height = _stackView.frame.height + (SuggestedFriendCollectionCell.height + 45)
            _tableView.tableHeaderView = _stackView
        }
    }
    
    private func _requestGetFilterData() {
        _selectOption = self._topMenuOptions.map({ $0.id })
        _customDaysView.isHidden = _selectOption?.isEmpty == true
        _customDaysView.delegate = self
        _customDaysView.setupData(_topMenuOptions.map({$0.title}), selectedDay: kEmptyString, isFromExplore: true)
        DISPATCH_ASYNC_MAIN {
            self._requestExplore()
        }
    }
    
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        
        //        if !suggestedUsers.isEmpty {
        //            cellData.append([
        //                kCellIdentifierKey: kCellIdentifiersuggested,
        //                kCellTagKey: kCellIdentifiersuggested,
        //                kCellObjectDataKey: suggestedUsers,
        //                kCellTitleKey: false,
        //                kCellClassKey: SuggestedFriendsTableCell.self,
        //                kCellHeightKey: SuggestedFriendsTableCell.height
        //            ])
        //        }
        
        //        if !_suggestedVenue.isEmpty {
        //                cellData.append([
        //                    kCellIdentifierKey: kCellIdentifiersuggested,
        //                    kCellTagKey: kCellIdentifiersuggested,
        //                    kCellObjectDataKey: _suggestedVenue,
        //                    kCellTitleKey: true,
        //                    kCellClassKey: SuggestedFriendsTableCell.self,
        //                    kCellHeightKey: SuggestedFriendsTableCell.height
        //                ])
        //        }
        
        if isSearching {
            if _filteredData.isEmpty {
                cellData.append([
                    kCellIdentifierKey: kEmptyCellIdentifier,
                    kCellTagKey: _emptyData.first,
                    kCellObjectDataKey: _emptyData.first,
                    kCellClassKey: EmptyDataCell.self,
                    kCellHeightKey: EmptyDataCell.height
                ])
            } else {
                _filteredData.forEach { explore in
                    if explore.type == "offer" {
                        cellData.append([
                            kCellIdentifierKey: kCellIdentifierOffers,
                            kCellTagKey: kCellIdentifierOffers,
                            kCellObjectDataKey: explore.offers,
                            kCellTitleKey: explore.createdAt,
                            kCellClassKey: CommanOffersTableCell.self,
                            kCellHeightKey: CommanOffersTableCell.height
                        ])
                    } else if explore.type == "event" {
                        if !Utils.isVenueDetailEmpty(explore.events?.venueDetail) {
                            cellData.append([
                                kCellIdentifierKey: kCellIdentifierEvent,
                                kCellTagKey: kCellIdentifierEvent,
                                kCellObjectDataKey: explore.events,
                                kCellTitleKey: explore.createdAt,
                                kCellClassKey: EventSearchTableCell.self,
                                kCellHeightKey: EventSearchTableCell.height
                            ])
                        }
                    } else if explore.type == "activity" {
                        cellData.append([
                            kCellIdentifierKey: kCellIdentifierActivity,
                            kCellTagKey: kCellIdentifierActivity,
                            kCellObjectDataKey: explore.activity,
                            kCellTitleKey: explore.createdAt,
                            kCellClassKey: ActivitySearchTableCell.self,
                            kCellHeightKey: ActivitySearchTableCell.height
                        ])
                    }
                }
            }
            
        } else {
            if _exploreData.isEmpty {
                cellData.append([
                    kCellIdentifierKey: kEmptyCellIdentifier,
                    kCellTagKey: _emptyData.first,
                    kCellObjectDataKey: _emptyData.first,
                    kCellClassKey: EmptyDataCell.self,
                    kCellHeightKey: EmptyDataCell.height
                ])
            } else {
                _exploreData.forEach { explore in
                    if explore.type == "offer" {
                        cellData.append([
                            kCellIdentifierKey: kCellIdentifierOffers,
                            kCellTagKey: kCellIdentifierOffers,
                            kCellObjectDataKey: explore.offers,
                            kCellTitleKey: explore.createdAt,
                            kCellClassKey: CommanOffersTableCell.self,
                            kCellHeightKey: CommanOffersTableCell.height
                        ])
                    } else if explore.type == "event" {
                        if !Utils.isVenueDetailEmpty(explore.events?.venueDetail) {
                            cellData.append([
                                kCellIdentifierKey: kCellIdentifierEvent,
                                kCellTagKey: kCellIdentifierEvent,
                                kCellObjectDataKey: explore.events,
                                kCellTitleKey: explore.createdAt,
                                kCellClassKey: EventSearchTableCell.self,
                                kCellHeightKey: EventSearchTableCell.height
                            ])
                        }
                    } else if explore.type == "activity" {
                        cellData.append([
                            kCellIdentifierKey: kCellIdentifierActivity,
                            kCellTagKey: kCellIdentifierActivity,
                            kCellObjectDataKey: explore.activity,
                            kCellTitleKey: explore.createdAt,
                            kCellClassKey: ActivitySearchTableCell.self,
                            kCellHeightKey: ActivitySearchTableCell.height
                        ])
                    }
                }
            }
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    private func emptyData() {
        _emptyData.append(["type": "invitations".localized(),"title" : "empty_explore_page".localized(), "icon": "empty_explore"])
    }

    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierOffers, kCellNibNameKey: kCellIdentifierOffers, kCellClassKey: CommanOffersTableCell.self, kCellHeightKey: CommanOffersTableCell.height],
            [kCellIdentifierKey: kCellIdentifierEvent, kCellNibNameKey: kCellIdentifierEvent, kCellClassKey: EventSearchTableCell.self, kCellHeightKey: EventSearchTableCell.height],
            [kCellIdentifierKey: kCellIdentifierActivity, kCellNibNameKey: kCellIdentifierActivity, kCellClassKey: ActivitySearchTableCell.self, kCellHeightKey: ActivitySearchTableCell.height],
            [kCellIdentifierKey: kEmptyCellIdentifier, kCellNibNameKey: kEmptyCellIdentifier, kCellClassKey: EmptyDataCell.self, kCellHeightKey: EmptyDataCell.height],
            [kCellIdentifierKey: kCellIdentifiersuggested, kCellNibNameKey: kCellIdentifiersuggested, kCellClassKey: SuggestedFriendsTableCell.self, kCellHeightKey: SuggestedFriendsTableCell.height]
        ]
    }
    
    @IBAction private func _handleFilterEvent(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(ExploreFilterBottomSheet.self)
        vc.selectedFilter = _topMenuOptions
        vc.filterCallback = { options in
            self._topMenuOptions.removeAll()
            self._topMenuOptions.append(contentsOf: options)
            self._requestGetFilterData()
        }
        presentAsPanModal(controller: vc)
    }
    
}

extension ExploreVC: CustomTableViewDelegate, UIScrollViewDelegate, UITableViewDelegate  {
    
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
        if scrollView.contentOffset.y > scrollOffsetThreshold && !isRequesting {
            performPagination()
        }
    }
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        cell.selectionStyle = .none
        if let cell = cell as? CommanOffersTableCell {
            guard let title = cellDict?[kCellTitleKey] as? String,
                  let object = cellDict?[kCellObjectDataKey] as? OffersModel else { return }
            cell.setup(object, type: .explore)
            cell._offerDuarationStack.isHidden = false
            let time = Utils.stringToDate(title, format: kStanderdDate)
            cell._createDate.text = time?.timeAgoSince
        } else if let cell = cell as? EventSearchTableCell {
            guard let title = cellDict?[kCellTitleKey] as? String,
                  let object = cellDict?[kCellObjectDataKey] as? EventModel else { return }
            cell.setupData(object)
            cell._createdDateView.isHidden = false
            let time = Utils.stringToDate(title, format: kStanderdDate)
            cell._createdDate.text = time?.timeAgoSince
        } else if let cell = cell as? ActivitySearchTableCell {
            guard let title = cellDict?[kCellTitleKey] as? String,
                  let object = cellDict?[kCellObjectDataKey] as? ActivitiesModel else { return }
            cell.setupData(object)
            cell._createdDateView.isHidden = false
            let time = Utils.stringToDate(title, format: kStanderdDate)
            cell._createdDate.text = time?.timeAgoSince
        } else if let cell = cell as? SuggestedFriendsTableCell {
            if let title = cellDict?[kCellTitleKey] as? Bool, title {
                guard let object = cellDict?[kCellObjectDataKey] as? [VenueDetailModel] else { return }
                cell.setupData(venues: object, title: "Suggested venue", isVenue: true )
                cell.removeVenueCallBack = { id in
                    if let index = self._suggestedVenue.firstIndex(where: { $0.id == id }) {
                        self._suggestedVenue.remove(at: index)
                    }
                }
            } else {
                guard let object = cellDict?[kCellObjectDataKey] as? [UserDetailModel] else { return }
                cell.setupData(object, title: "Suggested friends", isVenue: false)
                cell.removeUserCallBack = { id in
                    if let index = self.suggestedUsers.firstIndex(where: { $0.id == id }) {
                        self.suggestedUsers.remove(at: index)
                    }
                }
            }
        } else if let cell = cell as? EmptyDataCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [String:Any] else { return }
            cell.setupData(object)
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if cell is CommanOffersTableCell {
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
        } else if cell is EventSearchTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? EventModel else { return }
            let vc = INIT_CONTROLLER_XIB(EventDetailVC.self)
            vc.event = object
            self.navigationController?.pushViewController(vc, animated: true)
        } else if cell is ActivitySearchTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? ActivitiesModel else { return }
            let controller = INIT_CONTROLLER_XIB(ActivityInfoVC.self)
            controller.activityId = object.id
            controller.activityName = object.name
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    private func performPagination() {
        _beforeDate = _exploreData.last?.createdAt ?? kEmptyString
        if _exploreData.count > 0 {
            if _exploreData.count % 30 == 0 {
                footerView?.startAnimating()
                _requestExplore()
            }
        }
    }
    
    func refreshData() {
        _beforeDate = kEmptyString
        _exploreData.removeAll()
        _requestExplore()
    }
}

extension ExploreVC: CustomDaysHeaderViewDelegate {
    func removeAction(filter: String) {
        if let selectedIndex = _topMenuOptions.firstIndex(where: { $0.title == filter }) {
            _topMenuOptions.remove(at: selectedIndex)
            _requestGetFilterData()
        }
    }
    
    
    func didSelectDay(_ day: String) {
    }
}

extension ExploreVC: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        hideShowSearchBar(false)
        if isSearching {
            isSearching = false
            _loadData()
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTimer?.invalidate()
        if !searchText.isEmpty {
            isSearching = true
            searchActivityIndicator.startAnimating()
            searchTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(performSearchWithTimer), userInfo: searchText, repeats: false)
        } else {
            isSearching = false
            searchActivityIndicator.stopAnimating()
            _loadData()
        }
    }
    
    @objc private func performSearchWithTimer(timer: Timer) {
        guard let searchText = timer.userInfo as? String else { return }
        performSearch(with: searchText)
    }

    func performSearch(with searchText: String) {
        if searchText.isEmpty {
            _loadData()
        } else {
            _beforeDate = ""
            _requestExplore(searchText)
        }
    }
    
    private func hideShowSearchBar(_ isShow: Bool = false) {
        //        UIView.animate(withDuration: 0.3) {
        //            self._searchBar.alpha = isShow ? 1 : 0
        //            self._titleView.alpha =  isShow ? 0 : 1
        //        } completion: { _ in
        //            self._searchBar.isHidden = !isShow
        //            self._titleView.isHidden = isShow
        //        }
        //        _titleView.isHidden = isShow
        //        _searchBar.isHidden = !isShow
    }
}

