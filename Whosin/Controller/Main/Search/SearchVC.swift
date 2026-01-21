import UIKit
import RealmSwift
import Alamofire

//var searchFilter: [String: Any] = [:]

class SearchVC: NavigationBarViewController {

    @IBOutlet private weak var _addressHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var _addressView: UIView!
    @IBOutlet private weak var _addressLable: CustomLabel!
    @IBOutlet private weak var _filterViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var _customDaysView: CustomDaysHeaderView!
    @IBOutlet private weak var _searchBackBtn: UIButton!
    @IBOutlet private weak var _backButton: UIButton!
    @IBOutlet private weak var _searchBar: UISearchBar!
    @IBOutlet private weak var _tableView: CustomNoKeyboardTableView!
    @IBOutlet private weak var _searchResultTableView: CustomNoKeyboardTableView!
    @IBOutlet private weak var _headerCollectionView: CustomCollectionView!
    @IBOutlet private weak var _headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var _navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var _navigationHeaderView: UIView!
    @IBOutlet private weak var _badgeView: UIView!
    @IBOutlet private weak var _badgeCount: CustomLabel!
    private let kCellIdentifierStoryView = String(describing: LatestSearchTableCell.self)
    private let kCellIdentifierDeals = String(describing: DealRecommendedTableCell.self)
    private let kCellIdentifierCategories = String(describing: CategoryTableCell.self)
    private let kCellIdentifierCategoryOffers = String(describing: CategoryRecommendedTableCell.self)
    private let kCellIdentifierAds = String(describing: VenueRecommendedTableCell.self)
    private let kCellIdentifierHeader = String(describing: SearchHeaderCollectionCell.self)
    private let kCellIdentifierVenue = String(describing: VenueSearchTableCell.self)
    private let kCellIdentifierUser = String(describing: UserTableCell.self)
    private let kCellIdentifierOffers = String(describing: CommanOffersTableCell.self)
    private let kCellIdentifierTicketList = String(describing: ExploreTicketTableCell.self)
    private let kCellIdentifierEvent = String(describing: EventSearchTableCell.self)
    private let kCellIdentifierActivity = String(describing: ActivitySearchTableCell.self)
    private let kCellIdentifierTicket = String(describing: AllCustomTicketTableCell.self)
    private let kCellIdentifierAllVenue = String(describing: AllVenueSeachTableCell.self)
    private let kCellIdentifierAllOffers = String(describing: AllOfferSearchTableCell.self)
    private let kCellIdentifierAllUser = String(describing: AllUserSearchTableCell.self)
    private let kCellIdentifierAllEvent = String(describing: AllEventSearchTableCell.self)
    private let kCellIdentifierAllActivity = String(describing: AllActivitySearchTableCell.self)
    private let kCellIdentifierHistory = String(describing: SearchHistoryTableCell.self)
    private let kCellIdentifierSearchText = String(describing: SearchTextTableCell.self)
    private let kCellIdentifierRecommendedOffers = String(describing: LargeOfferComponentTableCell.self)
    private let kCellIdentifierRecommendedVenue = String(describing: LargeVenueComponentTableCell.self)

    private var _recommendedDetail: HomeModel?
    private var _tabs: [String] = []
    private var selectedIndex: Int = 0
    private var _selectedDay: String = kEmptyString
    private var _searchResult: [SearchResultModel] = []
    private var shouldAllowSearchBarToEndEditing: Bool = true
    private var _topMenuOptions: [CommonSettingsModel] = []
    private var _selectedLocation: [String: Any] = [:]
    private var filterOptions: SettingsModel?
    private var _dataRequest: DataRequest?
    private var searchActivityIndicator: UIActivityIndicatorView?
    private var currentSearchTask: DispatchWorkItem?
    private let searchQueue = DispatchQueue(label: "com.app.searchQueue", qos: .userInitiated)
    var suggestionManager: SearchSuggestionManager?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        _requestSearchFilter()
        setupUi()
//        _loadSearchHistoryData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pauseVideoWhenDisappear()
    }
    
    func pauseVideoWhenDisappear() {
        guard _tableView != nil, _searchResultTableView != nil else { return }
        _tableView.setContentOffset(_tableView.contentOffset, animated: false)
        _searchResultTableView.setContentOffset(_searchResultTableView.contentOffset, animated: false)

        DISPATCH_ASYNC_MAIN {
            self._tableView.visibleCells.forEach { cell in
                if cell is BannerAdsTableCell {
                    (cell as? BannerAdsTableCell)?.pause()
                }
            }
            self._searchResultTableView.visibleCells.forEach { cell in
                if cell is BannerAdsTableCell {
                    (cell as? BannerAdsTableCell)?.pause()
                }
            }
        }
    }
    
    override func setupUi() {
        hideNavigationBar()
        addActivityIndicatorToSearchBar()
        _searchBar.delegate = self
        _searchBar.setSearchFieldBackgroundImage(UIImage(named: "img_search_bg"), for: .normal)
        _searchBar.isUserInteractionEnabled = true
        _headerViewHeightConstraint.constant = 0
        _searchResultTableView.isHidden = true
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: true,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: kEmptyString,
            emptyDataIconImage: UIImage(named: "empty_search"),
            emptyDataDescription: "Find what you are looking for.",
            delegate: self)
        
        _searchResultTableView.setup(
            cellPrototypes: _searchTablePrototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: true,
            isShowRefreshing: true,
            emptyDataText: kEmptyString,
            emptyDataIconImage: UIImage(named: "empty_search"),
            emptyDataDescription: "Find what you are looking for.",
            delegate: self)
        _searchResultTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
        _requestRecommendedData()
        _requestGetFilterData()
        _headerCollectionView.setup(cellPrototypes: _headerPrototype,
                                   hasHeaderSection: false,
                                   enableRefresh: false,
                                   columns: 5,
                                   rows: 1,
                                   edgeInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0),
                                   scrollDirection: .horizontal,
                                   isDummyLoad: false,
                                   emptyDataText: nil,
                                   emptyDataIconImage: nil,
                                   delegate: self)
        _headerCollectionView.showsVerticalScrollIndicator = false
        _headerCollectionView.showsHorizontalScrollIndicator = false
        suggestionManager = SearchSuggestionManager(searchBar: _searchBar, in: self.view)
        suggestionManager?.onSuggestionSelected = { [weak self] selectedText in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self._searchBar.text = selectedText
                self.requestSearchOrFilter(text: selectedText)
            }
        }

    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestGetFilterData() {
        let selectOption = _topMenuOptions.map { $0.id }
        _customDaysView.isHidden = selectOption.isEmpty
        _filterViewHeightConstraint.constant = selectOption.isEmpty ? 0 : 60
        _customDaysView.delegate = self
        _customDaysView.setupData(_topMenuOptions.map { $0.title }, selectedDay: kEmptyString, isFromExplore: true)
        if _selectedLocation.isEmpty || (_selectedLocation["address"] as? String) == "Current location" {
            _addressView.isHidden = true
            _addressHeightConstraint.constant = 0
        } else {
            _addressLable.text = _selectedLocation["address"] as? String
            _addressView.isHidden = false
            _addressHeightConstraint.constant = 36
        }
    }
    
    private func _requestSearchFilter() {
        WhosinServices.requestSearchFilter { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD()
            guard let data = container?.data else { return }
            self.filterOptions = data
        }
    }
    
    private func _requestRecommendedData() {
        WhosinServices.searchRecommended { [weak self] container, error in
            guard let self = self else { return }
            self.searchActivityIndicator?.stopAnimating()
            self.hideHUD()
            self._searchResultTableView.isHidden = false
            guard let data = container?.data else { return }
            self._recommendedDetail = data
            self._loadRecommandationData()
        }
    }
    
    private func _requestSearch(_ text: String, showLoader: Bool = false) {
        _dataRequest?.cancel()
        selectedIndex = 0
        _selectedDay = "All"
        if showLoader {
            searchActivityIndicator?.startAnimating()
        }
        _dataRequest = WhosinServices.search(text, filters: _topMenuOptions, location: _selectedLocation) { [weak self] containers, error in
            guard let self = self else { return }
            self._tableView.endRefreshing()
            self._searchResultTableView.endRefreshing()
            self.searchActivityIndicator?.stopAnimating()
            self.hideHUD()
            guard let data = containers?.data, error?.localizedDescription != "Request explicitly cancelled." else {
                return
            }
            self._searchResult = data.filter { $0.type != "yacht" }
            let newTabs = self._searchResult.map { $0.type }
            var ticketTab: [String] = []
            var otherTabs: [String] = []
            for tab in newTabs.dropFirst() {
                if tab == "ticket" {
                    ticketTab.append(tab)
                } else {
                    otherTabs.append(tab)
                }
            }
            if newTabs.count > 1 {
                self._tabs = ["All"] + ticketTab + otherTabs
                self._loadCollectionData()
                self.hideShowTabbar(50)
            } else {
                self._selectedDay = newTabs.first ?? "All"
                self.hideShowTabbar(1)
            }
            self._loadSearchResultData()
        }
    }
    
    // --------------------------------------
    // MARK: Data
    // --------------------------------------
    
    private func _loadRecommandationData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        guard let model = _recommendedDetail else { return }
        if !model.categories.isEmpty {
            cellData.append([
                kCellIdentifierKey: kCellIdentifierCategories,
                kCellTagKey: kCellIdentifierCategories,
                kCellObjectDataKey: model.categories.toArrayDetached(ofType: CategoryDetailModel.self),
                kCellClassKey: CategoryTableCell.self,
                kCellHeightKey: CategoryTableCell.height
            ])
        }

        model.homeblocksModel.forEach { data in
            if !data.isVisibleForSearch(venue: model.venues.toArrayDetached(ofType: VenueDetailModel.self), offer: model.offers.toArrayDetached(ofType: OffersModel.self), activity: model.activities.toArrayDetached(ofType: ActivitiesModel.self), event: model.events.toArrayDetached(ofType: EventModel.self), suggestedUsers: data.suggestedUsers.toArrayDetached(ofType: UserDetailModel.self), ticket: model.tickets.toArrayDetached(ofType: TicketModel.self)) { return }
            cellData.append([
                kCellIdentifierKey: data.cellTypeForSearch.identifier,
                kCellTagKey: data.id,
                kCellAllowCacheKey: data.cellTypeForSearch.isNeedCacheCell,
                kCellObjectDataKey: data,
                kCellHeightKey: data.cellTypeForSearch.height
            ])
        }
        _tableView.fetchAndInsertBanner()
        cellSectionData.append([kSectionTitleKey: "", kSectionDataKey: cellData])
        _searchResultTableView.isHidden = true
        _tableView.loadData(cellSectionData)
    }
    
    private func _loadSearchHistoryData(isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        searchActivityIndicator?.stopAnimating()
        if !Preferences.searchText.isEmpty {
            cellData.append([
                kCellIdentifierKey: kCellIdentifierSearchText,
                kCellTagKey: kCellIdentifierSearchText,
                kCellObjectDataKey: Preferences.searchText,
                kCellClassKey: SearchTextTableCell.self,
                kCellHeightKey: SearchTextTableCell.height
            ])
            cellSectionData.append([kSectionTitleKey: "", kSectionDataKey: cellData])
        }
        
        cellData.removeAll()
        
        if !APPSETTING.searchHistory.isEmpty {
            APPSETTING.searchHistory.forEach { history in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierHistory,
                    kCellTagKey: kCellIdentifierHistory,
                    kCellObjectDataKey: history,
                    kCellClassKey: SearchHistoryTableCell.self,
                    kCellHeightKey: SearchHistoryTableCell.height
                ])
            }
            cellSectionData.append([
                kSectionTitleKey: "Recent Searches",
                kSectionRightInfoKey: "Clear all",
                kSectionIdentifierKey: 999,
                kSectionShowRightInforAsActionButtonKey: true,
                kSectionRightTextColorKey: UIColor.systemBlue,
                kSectionRightTextBgColor: UIColor.clear,
                kSectionDataKey: cellData
            ])
        }
        DISPATCH_ASYNC_MAIN {
            self._searchResultTableView.loadData(cellSectionData)
        }
    }
    
    private func addActivityIndicatorToSearchBar() {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        if #available(iOS 13.0, *), let searchTextField = _searchBar.searchTextField as? UIView {
            searchTextField.addSubview(indicator)
            NSLayoutConstraint.activate([
                indicator.centerYAnchor.constraint(equalTo: searchTextField.centerYAnchor),
                indicator.trailingAnchor.constraint(equalTo: searchTextField.trailingAnchor, constant: -30)
            ])
        } else {
            _searchBar.addSubview(indicator)
            NSLayoutConstraint.activate([
                indicator.centerYAnchor.constraint(equalTo: _searchBar.centerYAnchor),
                indicator.trailingAnchor.constraint(equalTo: _searchBar.trailingAnchor, constant: -30)
            ])
        }
        searchActivityIndicator = indicator
    }
    
    @objc func touchHappen(_ sender: UITapGestureRecognizer) {
        APPSETTING.removeAllSearchHistory()
        Preferences.searchText.removeAll()
        _loadSearchHistoryData()
    }

    private func _loadSearchResultData(isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        let finalResult = _selectedDay == "All" ? _searchResult : _searchResult.filter { $0.type == _selectedDay }
        finalResult.forEach { object in
            object.tickets?.forEach { ticket in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierTicketList,
                    kCellTagKey: kCellIdentifierTicketList,
                    kCellDifferenceContentKey: ticket._id,
                    kCellDifferenceIdentifierKey: ticket._id,
                    kCellObjectDataKey: ticket,
                    kCellClassKey: ExploreTicketTableCell.self,
                    kCellHeightKey: ExploreTicketTableCell.height
                ])
            }
            object.users?.forEach { user in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierUser,
                    kCellTagKey: kCellIdentifierUser,
                    kCellDifferenceContentKey: user.id,
                    kCellDifferenceIdentifierKey: user.id,
                    kCellObjectDataKey: user,
                    kCellClassKey: UserTableCell.self,
                    kCellHeightKey: UserTableCell.height
                ])
            }
            object.venues?.forEach { venue in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierVenue,
                    kCellTagKey: kCellIdentifierVenue,
                    kCellDifferenceContentKey: venue.id,
                    kCellDifferenceIdentifierKey: venue.id,
                    kCellObjectDataKey: venue,
                    kCellClassKey: VenueSearchTableCell.self,
                    kCellHeightKey: VenueSearchTableCell.height
                ])
            }
            object.events?.forEach { event in
                if event.venueDetail == nil {
                    event.venueDetail = APPSETTING.venueModel?.filter { $0.id == event.venue }.first
                }
                if !Utils.isVenueDetailEmpty(event.venueDetail) {
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifierEvent,
                        kCellTagKey: kCellIdentifierEvent,
                        kCellObjectDataKey: event,
                        kCellClassKey: EventSearchTableCell.self,
                        kCellHeightKey: EventSearchTableCell.height
                    ])
                }
            }
            object.activities?.forEach { activity in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierActivity,
                    kCellTagKey: kCellIdentifierActivity,
                    kCellObjectDataKey: activity,
                    kCellClassKey: ActivitySearchTableCell.self,
                    kCellHeightKey: ActivitySearchTableCell.height
                ])
            }
            object.offers?.forEach { offer in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierOffers,
                    kCellTagKey: kCellIdentifierOffers,
                    kCellObjectDataKey: offer,
                    kCellClassKey: CommanOffersTableCell.self,
                    kCellHeightKey: CommanOffersTableCell.height
                ])
            }
        }
        
        if finalResult.isEmpty || _selectedDay != "All" {
            let typesToProcess = _selectedDay == "All" ? _searchResult.map { $0.type } : [_selectedDay]
            if typesToProcess.count != 1 {
                typesToProcess.forEach { type in
                    if let object = _searchResult.first(where: { $0.type == type }) {
                        if type == "ticket", let tickets = object.tickets {
                            cellData.append([
                                kCellIdentifierKey: kCellIdentifierTicket,
                                kCellTagKey: kCellIdentifierTicket,
                                kCellObjectDataKey: tickets,
                                kCellTitleKey: object.type,
                                kCellClassKey: AllCustomTicketTableCell.self,
                                kCellHeightKey: AllCustomTicketTableCell.height
                            ])
                        } else if type == "venue", let venues = object.venues {
                            cellData.append([
                                kCellIdentifierKey: kCellIdentifierAllVenue,
                                kCellTagKey: kCellIdentifierAllVenue,
                                kCellObjectDataKey: venues,
                                kCellTitleKey: object.type,
                                kCellClassKey: AllVenueSeachTableCell.self,
                                kCellHeightKey: AllVenueSeachTableCell.height
                            ])
                        } else if type == "offer", let offers = object.offers {
                            cellData.append([
                                kCellIdentifierKey: kCellIdentifierAllOffers,
                                kCellTagKey: kCellIdentifierAllOffers,
                                kCellObjectDataKey: offers,
                                kCellTitleKey: object.type,
                                kCellClassKey: AllOfferSearchTableCell.self,
                                kCellHeightKey: AllOfferSearchTableCell.height
                            ])
                        } else if type == "user", let users = object.users {
                            cellData.append([
                                kCellIdentifierKey: kCellIdentifierAllUser,
                                kCellTagKey: kCellIdentifierAllUser,
                                kCellObjectDataKey: users,
                                kCellTitleKey: object.type,
                                kCellClassKey: AllUserSearchTableCell.self,
                                kCellHeightKey: AllUserSearchTableCell.height
                            ])
                        } else if type == "event", let events = object.events {
                            cellData.append([
                                kCellIdentifierKey: kCellIdentifierAllEvent,
                                kCellTagKey: kCellIdentifierAllEvent,
                                kCellObjectDataKey: events,
                                kCellTitleKey: object.type,
                                kCellClassKey: AllEventSearchTableCell.self,
                                kCellHeightKey: AllEventSearchTableCell.height
                            ])
                        } else if type == "activity", let activities = object.activities {
                            cellData.append([
                                kCellIdentifierKey: kCellIdentifierAllActivity,
                                kCellTagKey: kCellIdentifierAllActivity,
                                kCellObjectDataKey: activities,
                                kCellTitleKey: object.type,
                                kCellClassKey: AllActivitySearchTableCell.self,
                                kCellHeightKey: AllActivitySearchTableCell.height
                            ])
                        }
                    }
                }
            }
        }
        
        _searchResultTableView.fetchAndInsertBanner()
        cellSectionData.append([kSectionTitleKey: " ", kSectionDataKey: cellData])
        DISPATCH_ASYNC_MAIN {
            self._searchResultTableView.updateData(cellSectionData)
        }
    }
    
    private func _loadCollectionData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()

        _tabs.forEach { day in
            cellData.append([
                kCellIdentifierKey: kCellIdentifierHeader,
                kCellTagKey: kCellIdentifierHeader,
                kCellObjectDataKey: day,
                kCellClassKey: SearchHeaderCollectionCell.self,
                kCellHeightKey: SearchHeaderCollectionCell.height
            ])
        }

        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _headerCollectionView.loadData(cellSectionData)
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _searchTablePrototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierAllVenue, kCellNibNameKey: kCellIdentifierAllVenue, kCellClassKey: AllVenueSeachTableCell.self, kCellHeightKey: AllVenueSeachTableCell.height],
            [kCellIdentifierKey: kCellIdentifierAllOffers, kCellNibNameKey: kCellIdentifierAllOffers, kCellClassKey: AllOfferSearchTableCell.self, kCellHeightKey: AllOfferSearchTableCell.height],
            [kCellIdentifierKey: kCellIdentifierAllUser, kCellNibNameKey: kCellIdentifierAllUser, kCellClassKey: AllUserSearchTableCell.self, kCellHeightKey: AllUserSearchTableCell.height],
            [kCellIdentifierKey: kCellIdentifierAllEvent, kCellNibNameKey: kCellIdentifierAllEvent, kCellClassKey: AllEventSearchTableCell.self, kCellHeightKey: AllEventSearchTableCell.height],
            [kCellIdentifierKey: kCellIdentifierAllActivity, kCellNibNameKey: kCellIdentifierAllActivity, kCellClassKey: AllActivitySearchTableCell.self, kCellHeightKey: AllActivitySearchTableCell.height],
            [kCellIdentifierKey: kCellIdentifierVenue, kCellNibNameKey: kCellIdentifierVenue, kCellClassKey: VenueSearchTableCell.self, kCellHeightKey: VenueSearchTableCell.height],
            [kCellIdentifierKey: kCellIdentifierUser, kCellNibNameKey: kCellIdentifierUser, kCellClassKey: UserTableCell.self, kCellHeightKey: UserTableCell.height],
            [kCellIdentifierKey: kCellIdentifierOffers, kCellNibNameKey: kCellIdentifierOffers, kCellClassKey: CommanOffersTableCell.self, kCellHeightKey: CommanOffersTableCell.height],
            [kCellIdentifierKey: kCellIdentifierTicketList, kCellNibNameKey: kCellIdentifierTicketList, kCellClassKey: ExploreTicketTableCell.self, kCellHeightKey: ExploreTicketTableCell.height],
            [kCellIdentifierKey: kCellIdentifierEvent, kCellNibNameKey: kCellIdentifierEvent, kCellClassKey: EventSearchTableCell.self, kCellHeightKey: EventSearchTableCell.height],
            [kCellIdentifierKey: kCellIdentifierActivity, kCellNibNameKey: kCellIdentifierActivity, kCellClassKey: ActivitySearchTableCell.self, kCellHeightKey: ActivitySearchTableCell.height],
            [kCellIdentifierKey: kCellIdentifierTicket, kCellNibNameKey: kCellIdentifierTicket, kCellClassKey: AllCustomTicketTableCell.self, kCellHeightKey: AllCustomTicketTableCell.height],
            [kCellIdentifierKey: BannerAdsTableCell.identifier, kCellNibNameKey: BannerAdsTableCell.identifier, kCellClassKey: BannerAdsTableCell.self, kCellHeightKey: BannerAdsTableCell.height],
            [kCellIdentifierKey: kCellIdentifierHistory, kCellNibNameKey: kCellIdentifierHistory, kCellClassKey: SearchHistoryTableCell.self, kCellHeightKey: SearchHistoryTableCell.height],
            [kCellIdentifierKey: kCellIdentifierSearchText, kCellNibNameKey: kCellIdentifierSearchText, kCellClassKey: SearchTextTableCell.self, kCellHeightKey: SearchTextTableCell.height],
        ]
    }
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierStoryView, kCellNibNameKey: kCellIdentifierStoryView, kCellClassKey: LatestSearchTableCell.self, kCellHeightKey: LatestSearchTableCell.height],
            [kCellIdentifierKey: kCellIdentifierDeals, kCellNibNameKey: kCellIdentifierDeals, kCellClassKey: DealRecommendedTableCell.self, kCellHeightKey: DealRecommendedTableCell.height],
            [kCellIdentifierKey: kCellIdentifierCategories, kCellNibNameKey: kCellIdentifierCategories, kCellClassKey: CategoryTableCell.self, kCellHeightKey: CategoryTableCell.height],
            [kCellIdentifierKey: kCellIdentifierAds, kCellNibNameKey: kCellIdentifierAds, kCellClassKey: VenueRecommendedTableCell.self, kCellHeightKey: VenueRecommendedTableCell.height],
            [kCellIdentifierKey: kCellIdentifierHistory, kCellNibNameKey: kCellIdentifierHistory, kCellClassKey: SearchHistoryTableCell.self, kCellHeightKey: SearchHistoryTableCell.height],
            [kCellIdentifierKey: kCellIdentifierSearchText, kCellNibNameKey: kCellIdentifierSearchText, kCellClassKey: SearchTextTableCell.self, kCellHeightKey: SearchTextTableCell.height],
            HomeBlockCellType.venue.prototype, HomeBlockCellType.offer.prototype, HomeBlockCellType.activity.prototype, HomeBlockCellType.event.prototype, HomeBlockCellType.userSuggested.prototype, HomeBlockCellType.ticket.prototype,
            [kCellIdentifierKey: BannerAdsTableCell.identifier, kCellNibNameKey: BannerAdsTableCell.identifier, kCellClassKey: BannerAdsTableCell.self, kCellHeightKey: BannerAdsTableCell.height]
        ]
    }
    
    private var _headerPrototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifierHeader, kCellNibNameKey: kCellIdentifierHeader, kCellClassKey: SearchHeaderCollectionCell.self, kCellHeightKey: SearchHeaderCollectionCell.height]]
    }
    
    func _selectCategory(_ day: String) {
        _selectedDay = day
    }
    
    private func hideShowTabbar(_ height: CGFloat) {
        if height == _headerViewHeightConstraint.constant { return }
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.3, options: [.curveEaseInOut]) {
            self._searchResultTableView.isHidden = height == 0
            self._tableView.isHidden = height != 0
            self._headerViewHeightConstraint.constant = height
            self.view.layoutIfNeeded()
        }
    }
    
    private func _openDetailScreenForSearchHistory(type: String, object: SearchHistoryModel) {
        guard let userDetail = APPSESSION.userDetail else { return }
        if type == "user" {
            if object.isPromoter, userDetail.isRingMember {
                let vc = INIT_CONTROLLER_XIB(PromoterPublicProfileVc.self)
                vc.promoterId = object.id
                vc.isFromPersonal = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else if object.isRingMember, userDetail.isPromoter {
                let vc = INIT_CONTROLLER_XIB(ComplementaryPublicProfileVC.self)
                vc.complimentryId = object.id
                vc.isFromPersonal = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let controller = INIT_CONTROLLER_XIB(UsersProfileVC.self)
                controller.contactId = object.id
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    @IBAction func _handleRemoveLocation(_ sender: UIButton) {
        _addressLable.text = kEmptyString
        _selectedLocation.removeAll()
        _addressHeightConstraint.constant = 0
        _addressView.isHidden = true
        requestSearchOrFilter(text: _searchBar.text ?? kEmptyString)
    }
    
    @IBAction func _handleSearchBackEvent(_ sender: UIButton) {
        _dataRequest?.cancel()
            currentSearchTask?.cancel()
        searchActivityIndicator?.stopAnimating()
        suggestionManager?.hideDropdown()
        _searchResult.removeAll()
        _searchBar.text = ""
        _searchBar.setShowsCancelButton(false, animated: true)
        _tableView.isHidden = false
        _searchResultTableView.isHidden = true
        hideShowTabbar(0)
        _loadRecommandationData()
        _selectedLocation.removeAll()
        _topMenuOptions.removeAll()
        _badgeView.isHidden = _topMenuOptions.isEmpty
        _addressLable.text = kEmptyString
        _addressHeightConstraint.constant = 0
        _addressView.isHidden = true
        _requestGetFilterData()
        _searchBar.resignFirstResponder()
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.3, options: [.curveEaseInOut]) {
            self._searchBackBtn.isHidden = true
            self._navBarHeightConstraint.constant = 54
            self._navigationHeaderView.layer.opacity = 1
            self._navigationHeaderView.isHidden = false
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func _handleFilterEvent(_ sender: UIButton) {
        guard let filterOptions = filterOptions else { return }
        let vc = INIT_CONTROLLER_XIB(SearchFilterBottomSheet.self)
        vc.commanFilters = filterOptions
        vc.filters = _topMenuOptions
        vc.selectedLocaiton = _selectedLocation
        vc.filterCallback = { filters, location in
            self._topMenuOptions = filters
            self._selectedLocation = location
            self._badgeView.isHidden = self._topMenuOptions.isEmpty
            self._badgeCount.text = "\(self._topMenuOptions.count)"
            self._requestGetFilterData()
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.3, options: [.curveEaseInOut]) {
                self._navBarHeightConstraint.constant = 0
                self._navigationHeaderView.layer.opacity = 0
                self._navigationHeaderView.isHidden = true
                self._searchBackBtn.isHidden = false
                self.view.layoutIfNeeded()
            }
            self.requestSearchOrFilter(text: self._searchBar.text ?? kEmptyString)
        }
        self.present(vc, animated: true)
    }
    
    @IBAction func _handleBackEvent(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    private func requestSearchOrFilter(text: String) {
        currentSearchTask?.cancel()
        let trimmedText = text.trimmingCharacters(in: .whitespaces)
        if trimmedText.isEmpty && _topMenuOptions.isEmpty && (_selectedLocation.isEmpty || _selectedLocation["address"] as? String == "Current location") {
            _dataRequest?.cancel()
            searchActivityIndicator?.stopAnimating()
            hideShowTabbar(1)
            _searchResult = []
            _tabs = []
            _loadSearchHistoryData()
        } else {
            let searchTask = DispatchWorkItem { [weak self] in
                DispatchQueue.main.async {
                    guard let self = self, self._searchBar.text?.trimmingCharacters(in: .whitespaces) == trimmedText else { return }
                    self._requestSearch(trimmedText, showLoader: true)
                }
            }
            currentSearchTask = searchTask
            searchQueue.asyncAfter(deadline: .now() + 0.5, execute: searchTask)
        }
    }
}

extension SearchVC: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        guard _searchResult.isEmpty else { return }
        _searchBar.setShowsCancelButton(true, animated: true)
        if !shouldAllowSearchBarToEndEditing { hideShowTabbar(0) }
        if Utils.stringIsNullOrEmpty(searchBar.text) {
            searchActivityIndicator?.stopAnimating()
            _tableView.isHidden = true
            _searchResultTableView.isHidden = false
            _loadSearchHistoryData()
        } else {
            _tableView.isHidden = true
            hideShowTabbar(_tabs.count <= 2 ? 0 : 50)
        }
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.3, options: [.curveEaseInOut]) {
            self._navBarHeightConstraint.constant = 0
            self._navigationHeaderView.layer.opacity = 0
            self._navigationHeaderView.isHidden = true
            self._searchBackBtn.isHidden = false
            self.view.layoutIfNeeded()
        }
        _tableView.reload()
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        guard let rootVc = APP.window?.rootViewController else { return false }
        if let visibleVc = Utils.getVisibleViewController(from: rootVc), visibleVc is ContentViewVC {
            return false
        }
        if shouldAllowSearchBarToEndEditing {
            shouldAllowSearchBarToEndEditing = false
            DispatchQueue.main.async {
                if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
                    UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.3, options: [.curveEaseInOut]) {
                        self._searchBar.resignFirstResponder()
                        self.searchActivityIndicator?.stopAnimating()
                    } completion: { _ in
                        cancelButton.isEnabled = true
                    }
                } else {
                    self._searchBar.resignFirstResponder()
                    self.searchActivityIndicator?.stopAnimating()
                }
            }
            return true
        } else {
            DispatchQueue.main.async {
                if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
                    UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.3, options: [.curveEaseInOut]) {
                        self._searchBar.resignFirstResponder()
                        self.searchActivityIndicator?.stopAnimating()
                    } completion: { _ in
                        cancelButton.isEnabled = true
                    }
                }
            }
            return true
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        suggestionManager?.updateSearchText(searchText)
        searchActivityIndicator?.startAnimating()
        currentSearchTask?.cancel()
        _dataRequest?.cancel()
        DISPATCH_ASYNC_MAIN_AFTER(0.1) {
            self.requestSearchOrFilter(text: searchText)
        }
    }
        
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        currentSearchTask?.cancel()
        if let searchText = searchBar.text?.trimmingCharacters(in: .whitespaces), !searchText.isEmpty {
            Preferences.searchText.removeAll { $0 == searchText }
            Preferences.searchText.insert(searchText, at: 0)
            if Preferences.searchText.count > 10 {
                Preferences.searchText.removeLast()
            }
            requestSearchOrFilter(text: searchText)
        } else {
            _loadSearchHistoryData()
        }
        _searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        _dataRequest?.cancel()
            currentSearchTask?.cancel()
        searchActivityIndicator?.stopAnimating()
        suggestionManager?.hideDropdown()
        _searchResult.removeAll()
        _searchBar.text = ""
        _searchBar.setShowsCancelButton(false, animated: true)
        _tableView.isHidden = false
        _searchResultTableView.isHidden = true
        hideShowTabbar(0)
        _loadRecommandationData()
        _selectedLocation.removeAll()
        _topMenuOptions.removeAll()
        _badgeView.isHidden = _topMenuOptions.isEmpty
        _addressLable.text = kEmptyString
        _addressHeightConstraint.constant = 0
        _addressView.isHidden = true
        _requestGetFilterData()
        _searchBar.resignFirstResponder()
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.3, options: [.curveEaseInOut]) {
            self._searchBackBtn.isHidden = true
            self._navBarHeightConstraint.constant = 54
            self._navigationHeaderView.layer.opacity = 1
            self._navigationHeaderView.isHidden = false
            self.view.layoutIfNeeded()
        }
    }
}

extension SearchVC: CustomNoKeyboardTableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String: Any]?, indexPath: IndexPath) {
        cell.selectionStyle = .none
        if let cell = cell as? SearchTextTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [String] else { return }
            cell.setupData(object)
            cell.delegate = self
        } else if let cell = cell as? SuggestedFriendsTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? HomeBlockModel else { return }
            if object.type == "suggested-users" {
                cell.setupData(object.suggestedUsers.toArrayDetached(ofType: UserDetailModel.self), title: object.title)
            } else if object.type == "suggested-venues" {
                cell.setupData(venues: object.suggestedVenue.toArrayDetached(ofType: VenueDetailModel.self), title: object.title, isVenue: true)
            }
        } else if let cell = cell as? SearchHistoryTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? SearchHistoryModel else { return }
            cell._profileImageView.image = nil
            cell.setupData(object)
            cell.delegate = self
        } else if let cell = cell as? DealRecommendedTableCell {
            guard let title = cellDict?[kCellTitleKey] as? String,
                  let object = cellDict?[kCellObjectDataKey] as? List<DealsModel> else { return }
            cell._titleLabel.text = title
            cell.setupData(object.toArrayDetached(ofType: DealsModel.self))
        } else if let cell = cell as? CategoryRecommendedTableCell {
            guard let title = cellDict?[kCellTitleKey] as? String,
                  let object = cellDict?[kCellObjectDataKey] as? List<CategoryDetailModel> else { return }
            cell._titleLabel.text = title
            cell.setupData(object.toArrayDetached(ofType: CategoryDetailModel.self))
        } else if let cell = cell as? CustomTicketTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? HomeBlockModel else { return }
            cell.setupExploreData(object)
        } else if let cell = cell as? LargeOfferComponentTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? HomeBlockModel else { return }
            cell.setupData(object)
        } else if let cell = cell as? CategoryTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [CategoryDetailModel] else { return }
            cell.setupData(object)
        } else if let cell = cell as? LargeVenueComponentTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? HomeBlockModel else { return }
            cell.setupData(object)
        } else if let cell = cell as? ActivityComponantTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? HomeBlockModel else { return }
            cell.setupData(object)
        } else if let cell = cell as? EventsTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? HomeBlockModel else { return }
            cell.setupData(object)
        } else if let cell = cell as? VenueRecommendedTableCell {
            guard let title = cellDict?[kCellTitleKey] as? String,
                  let object = cellDict?[kCellObjectDataKey] as? List<VenueDetailModel> else { return }
            cell._titleLabel.text = title
            cell.setupData(object.toArrayDetached(ofType: VenueDetailModel.self))
        } else if let cell = cell as? VenueSearchTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? VenueDetailModel else { return }
            cell.setupData(object)
        } else if let cell = cell as? UserTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
            cell.setup(object)
        } else if let cell = cell as? CommanOffersTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? OffersModel else { return }
            cell.setup(object, type: .search)
        } else if let cell = cell as? EventSearchTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? EventModel else { return }
            cell.setupData(object)
        } else if let cell = cell as? ActivitySearchTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? ActivitiesModel else { return }
            cell.setupData(object)
        } else if let cell = cell as? AllVenueSeachTableCell {
            guard let title = cellDict?[kCellTitleKey] as? String,
                  let object = cellDict?[kCellObjectDataKey] as? [VenueDetailModel] else { return }
            cell.setupData(object)
            cell._titleLabel.text = title.capitalized
            cell.delegate = self
        } else if let cell = cell as? AllOfferSearchTableCell {
            guard let title = cellDict?[kCellTitleKey] as? String,
                  let object = cellDict?[kCellObjectDataKey] as? [OffersModel] else { return }
            cell.setupData(object)
            cell._titleLabel.text = title.capitalized
            cell.delegate = self
        } else if let cell = cell as? AllUserSearchTableCell {
            guard let title = cellDict?[kCellTitleKey] as? String,
                  let object = cellDict?[kCellObjectDataKey] as? [UserDetailModel] else { return }
            cell.setupData(object)
            cell._titleLabel.text = title.capitalized
            cell.delegate = self
        } else if let cell = cell as? AllEventSearchTableCell {
            guard let title = cellDict?[kCellTitleKey] as? String,
                  let object = cellDict?[kCellObjectDataKey] as? [EventModel] else { return }
            cell.setupData(object)
            cell._titleLabel.text = title.capitalized
            cell.delegate = self
        } else if let cell = cell as? AllActivitySearchTableCell {
            guard let title = cellDict?[kCellTitleKey] as? String,
                  let object = cellDict?[kCellObjectDataKey] as? [ActivitiesModel] else { return }
            cell.setupData(object)
            cell._titleLabel.text = title.capitalized
            cell.delegate = self
        } else if let cell = cell as? AllCustomTicketTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [TicketModel] else { return }
            cell.setupData(object)
            cell.delegate = self
        } else if let cell = cell as? ExploreTicketTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? TicketModel else { return }
            cell.setUpdata(object)
        } else if let cell = cell as? BannerAdsTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? PromotionalBannerItemModel else { return }
            cell.setupData(object)
            DISPATCH_ASYNC_MAIN_AFTER(0.2) {
                self.playPauseVideoIfVisible()
            }
        }
    }
    
    func playPauseVideoIfVisible() {
        let tables = [_tableView, _searchResultTableView]
        tables.forEach { tableView in
            tableView?.visibleCells.forEach { cell in
                if cell is BannerAdsTableCell, let indexPath = tableView?.indexPath(for: cell), let superview = tableView?.superview {
                    let cellRect = tableView!.rectForRow(at: indexPath)
                    let convertedRect = tableView!.convert(cellRect, to: superview)
                    let intersect = tableView!.frame.intersection(convertedRect)
                    let visibleHeight = intersect.height
                    let cellHeight = cellRect.height
                    let ratio = visibleHeight / cellHeight
                    if ratio <= 0.22 {
                        (cell as? BannerAdsTableCell)?.pause()
                    } else {
                        (cell as? BannerAdsTableCell)?.resume()
                    }
                }
            }
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 { return }
        DISPATCH_ASYNC_MAIN {
            self.suggestionManager?.hideDropdown()
            self.playPauseVideoIfVisible()
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String: Any]?, indexPath: IndexPath) {
        if cell is CommanOffersTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? OffersModel else { return }
            let controller = INIT_CONTROLLER_XIB(OfferPackageDetailVC.self)
            controller.offerId = object.id
            controller.venueModel = object.venue
            controller.timingModel = object.venue?.timing.toArrayDetached(ofType: TimingModel.self)
            APPSETTING.addSearchHistory(id: object.id, title: object.title, subtitle: object.descriptions, type: "offer", image: object.image, venueId: object.venue?.id ?? kEmptyString)
            controller.modalPresentationStyle = .overFullScreen
            controller.vanueOpenCallBack = { venueId, venueModel in
                let vc = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
                vc.venueId = venueId
                vc.venueDetailModel = venueModel
                self.navigationController?.pushViewController(vc, animated: true)
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
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
            presentAsPanModal(controller: controller)
        } else if cell is VenueSearchTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? VenueDetailModel else { return }
            let controller = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
            controller.venueId = object.id
            controller.venueDetailModel = object
            APPSETTING.addSearchHistory(id: object.id, title: object.name, subtitle: object.about, type: "venue", image: object.cover)
            self.navigationController?.pushViewController(controller, animated: true)
        } else if cell is EventSearchTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? EventModel else { return }
            let controller = INIT_CONTROLLER_XIB(EventDetailVC.self)
            controller.event = object
            APPSETTING.addSearchHistory(id: object.id, title: object.title, subtitle: object.descriptions, type: "event", image: object.image)
            self.navigationController?.pushViewController(controller, animated: true)
        } else if cell is ActivitySearchTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? ActivitiesModel else { return }
            let controller = INIT_CONTROLLER_XIB(ActivityInfoVC.self)
            controller.activityId = object.id
            controller.activityName = object.name
            APPSETTING.addSearchHistory(id: object.id, title: object.name, subtitle: object.descriptions, type: "activity", image: Utils.stringIsNullOrEmpty(object.cover) ? object.cover : kEmptyString)
            self.navigationController?.pushViewController(controller, animated: true)
        } else if cell is UserTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
            guard let userDetail = APPSESSION.userDetail else { return }
            if object.id != userDetail.id {
                if object.isPromoter, userDetail.isRingMember {
                    let vc = INIT_CONTROLLER_XIB(PromoterPublicProfileVc.self)
                    vc.promoterId = object.id
                    vc.isFromPersonal = true
                    self.navigationController?.pushViewController(vc, animated: true)
                } else if object.isRingMember, userDetail.isPromoter {
                    let vc = INIT_CONTROLLER_XIB(ComplementaryPublicProfileVC.self)
                    vc.complimentryId = object.id
                    vc.isFromPersonal = true
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let controller = INIT_CONTROLLER_XIB(UsersProfileVC.self)
                    controller.contactId = object.id
                    APPSETTING.addSearchHistory(id: object.id, title: object.fullName, subtitle: object.email, type: "user", image: object.image)
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
        } else if cell is SearchHistoryTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? SearchHistoryModel else { return }
            if object.type == "user" {
                _openDetailScreenForSearchHistory(type: object.type, object: object)
            } else if object.type == "venue" {
                let controller = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
                controller.venueId = object.id
                controller.venueDetailModel = Utils.getModelFromId(model: APPSETTING.venueModel, id: object.id)
                self.navigationController?.pushViewController(controller, animated: true)
            } else if object.type == "offer" {
                let controller = INIT_CONTROLLER_XIB(OfferPackageDetailVC.self)
                controller.offerId = object.id
                controller.modalPresentationStyle = .overFullScreen
                controller.vanueOpenCallBack = { venueId, venueModel in
                    let vc = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
                    vc.venueId = venueId
                    vc.venueDetailModel = venueModel
                    self.navigationController?.pushViewController(vc, animated: true)
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
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                presentAsPanModal(controller: controller)
            } else if object.type == "event" {
                let vc = INIT_CONTROLLER_XIB(EventDetailVC.self)
                vc.eventId = object.id
                self.navigationController?.pushViewController(vc, animated: true)
            } else if object.type == "activity" {
                let controller = INIT_CONTROLLER_XIB(ActivityInfoVC.self)
                controller.activityId = object.id
                controller.activityName = object.title
                self.navigationController?.pushViewController(controller, animated: true)
            } else if object.type == "ticket" {
                let vc = INIT_CONTROLLER_XIB(CustomTicketDetailVC.self)
                vc.ticketID = object.id
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
            }
        } else if cell is SearchTextTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? String else { return }
            _searchBar.text = object
            requestSearchOrFilter(text: object)
        } else if cell is ExploreTicketTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? TicketModel else { return }
            let firstImageURL = object.images.compactMap { $0 as String }
                .first { ["jpg", "jpeg", "png"].contains(URL(string: $0)?.pathExtension.lowercased() ?? "") } ?? kEmptyString
            APPSETTING.addSearchHistory(id: object._id, title: object.title, subtitle: object.descriptions, type: "ticket", image: firstImageURL)
            let vc = INIT_CONTROLLER_XIB(CustomTicketDetailVC.self)
            vc.ticketID = object._id
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func handleHeaderActionEvent(section: Int, identifier: Int) {
        if identifier == 999 {
            APPSETTING.removeAllSearchHistory()
            Preferences.searchText.removeAll()
            _loadSearchHistoryData()
        }
    }
    
    func refreshData() {
        requestSearchOrFilter(text: _searchBar.text ?? kEmptyString)
    }
}

extension SearchVC: CustomCollectionViewDelegate, UICollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String: Any]?, indexPath: IndexPath) {
        if let cell = cell as? SearchHeaderCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? String else { return }
            cell._selectedView.isHidden = selectedIndex != indexPath.row
            cell.setupData(data: object)
        }
    }
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String: Any]?, indexPath: IndexPath) -> CGSize {
        guard let object = cellDict?[kCellObjectDataKey] as? String else {
            return CGSize(width: 50, height: SearchHeaderCollectionCell.height)
        }
        let width = object.widthOfString(usingFont: FontBrand.SFsemiboldFont(size: 16))
        return CGSize(width: width + 30, height: SearchHeaderCollectionCell.height)
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String: Any]?, indexPath: IndexPath) {
        selectedIndex = indexPath.row
        _selectCategory(_tabs[selectedIndex].lowercased())
        _headerCollectionView.reload()
        _loadSearchResultData()
    }
}

extension SearchVC: ShowCategoryDetailsDelegate {
    func didSelectCategory(_ day: String) {
        if let selectedIndex = _tabs.firstIndex(of: day.lowercased()) {
            self.selectedIndex = selectedIndex
            _headerCollectionView.reload()
            _loadSearchResultData()
        }
    }
}

extension SearchVC: SearchHistoryTableCellDelegate {
    func searchHistoryCellDidTapClose(_ cell: SearchHistoryTableCell) {
        if let indexPath = _tableView.indexPath(for: cell) {
            let historyModel = APPSETTING.searchHistory[indexPath.row]
            APPSETTING.removeSearchHistory(historyModel)
            _loadSearchHistoryData()
        }
    }
}

extension SearchVC: SearchTextTapDelegate {
    func searchTextTapped(_ data: String) {
        _searchBar.text = data
        requestSearchOrFilter(text: data)
    }
}

extension SearchVC: PresentedViewControllerDelegate {
    func presentedViewControllerWillDismiss() {
        shouldAllowSearchBarToEndEditing = true
    }
}

extension SearchVC: CustomDaysHeaderViewDelegate {
    func removeAction(filter: String) {
        if let selectedIndex = _topMenuOptions.firstIndex(where: { $0.title == filter }) {
            _topMenuOptions.remove(at: selectedIndex)
            _badgeCount.text = "\(_topMenuOptions.count)"
            _badgeView.isHidden = _topMenuOptions.isEmpty
            _requestGetFilterData()
            requestSearchOrFilter(text: _searchBar.text ?? kEmptyString)
        }
    }
    
    func didSelectDay(_ day: String) {
    }
}
