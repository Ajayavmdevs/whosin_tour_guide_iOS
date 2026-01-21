import UIKit
import Alamofire

class NewExploreVC: NavigationBarViewController {

    @IBOutlet weak var _customDaysView: CustomDaysHeaderView!
    @IBOutlet weak var _titleView: UIView!
    @IBOutlet weak var _tableView: CustomNoKeyboardTableView!
    @IBOutlet weak var _visualEffectView: UIVisualEffectView!
    @IBOutlet weak var _headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var _backBtn: UIButton!
    @IBOutlet weak var _searchTableView: CustomNoKeyboardTableView!
    @IBOutlet weak var _expandableSearchView: ExpandableSearchView!
    @IBOutlet weak var _tableTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var _dayViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var searchViewHeightConstraint: NSLayoutConstraint!
    private let kCellIdentifierCategories = String(describing: ExploreCategoryTableCell.self)
    private let kCellIdentifierCategoriesrectange = String(describing: CategoryTableCell.self)
    private let kCellIdentifierCities = String(describing: CitiesListTableCell.self)
    private let kCellIdentifierSingleVideo = String(describing: SingleVideoTableCell.self)
    private let kCellIdentifierTicket = String(describing: ExploreCustomTicketTableCell.self)
    private let kCellIdentifierBanner = String(describing: ExploreBannerTableCell.self)
    private let kEmptyCellIdentifier = String(describing: EmptyDataCell.self)
    private let kEmptyCellIdentiferSearchList = String(describing: ExploreTicketTableCell.self)
    private let kLoadingCell = String(describing: LoadingCell.self)
    private var _topMenuOptions: [CategoryDetailModel] = []
    private var _selectOption: [String]?
    private var cities: [String] = []
    private var categories: [String] = []
    private var footerView: LoadingFooterView?
    public var isSearching = false
    private let _stackView = UIStackView()
    private var _emptyData = [[String:Any]]()
    private var _dataRequest: DataRequest?
    private var _visibleVideoCell: SingleVideoTableCell?
    private var exploreModel: HomeModel?
    private var _page : Int = 1
    private var isFetchingMore: Bool = false
    private var _ticketList: [TicketModel] = []
    private var shouldAllowSearchBarToEndEditing: Bool = true
    private var _searchText: String = kEmptyString
    private var currentSearchTask: DispatchWorkItem?
    private let searchQueue = DispatchQueue(label: "com.app.searchQueue", qos: .userInitiated)
    private var latestSearchToken: Int = 0


    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
        NotificationCenter.default.addObserver(self, selector: #selector(enterBackGround), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enterForGround), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleReloadOnLike(_:)), name: .reloadOnLike, object: nil)
    }
    
    @objc private func handleReloadOnLike(_ notification: Notification) {
        if let data = notification.object as? [String: Any], let id = data["id"] as? String, let flag = data["flag"] as? Bool {
            if isSearching {
                _requestSearch(_searchText)
            } else {
                APPSETTING.ticketList?.first(where: { $0._id == id })?.isFavourite = flag
                _loadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.pauseVideoWhenDisappear()
    }
    
    func pauseVideoWhenDisappear() {
        if self._tableView == nil { return }
        self._tableView.setContentOffset(_tableView.contentOffset, animated: false)
        DispatchQueue.main.async {
            self._tableView.visibleCells.forEach { cell in
                if let videoCell = cell as? SingleVideoTableCell {
                    videoCell.pauseVideo()
                } else if let bannerCell = cell as? BannerAdsTableCell {
                    bannerCell.pause()
                }
            }
        }
    }
    
    override func setupUi() {
        hideNavigationBar()

        _expandableSearchView.ondidChange = { [weak self] text in
            guard let self = self else { return }
            _searchText = text
            pauseAllVisibleVideos()
            currentSearchTask?.cancel()
            _dataRequest?.cancel()
            currentSearchTask?.cancel()
            hideShowTabbar(0)
            DispatchQueue.main.async {
                if self._selectOption?.isEmpty == true && Utils.stringIsNullOrEmpty(self._searchText) {
                    self._ticketList.removeAll()
                    self._loadSearchData()
                } else if Utils.stringIsNullOrEmpty(self._searchText) {
                    self.hideShowTabbar(0)
                    self.latestSearchToken += 1
                    self._requestSearch(self._searchText, showLoader: true, searchToken: self.latestSearchToken)
                }
            }
        }
        
        _expandableSearchView.onSearchPressed = { [weak self] searchText in
            guard let self = self else { return }
            self._searchText = searchText
            self._requestSearch(self._searchText, showLoader: true, searchToken: self.latestSearchToken)
        }
        
        _expandableSearchView.onHeightChanged = { [weak self] newHeight in
            var _newHeight = newHeight
            if _newHeight < 50 {
                _newHeight = 30
            }
            self?.searchViewHeightConstraint.constant = _newHeight
            UIView.animate(withDuration: 0.25) {
                self?.view.layoutIfNeeded()
            }
        }

        showHUD()
        _stackView.axis = .vertical
        _stackView.spacing = 0
        _stackView.distribution = .fillProportionally
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
            delegate: self)
        _searchTableView.setup(
            cellPrototypes: _searchPrototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: true,
            dummyLoadCount: 3,
            enableRefresh: true,
            emptyDataText: kEmptyString,
            emptyDataIconImage: UIImage(named: "empty_explore"),
            emptyDataDescription: "search_experiences".localized(),
            delegate: self)
        _tableView.proxyDelegate = self
        _visualEffectView.alpha = 0.0
        footerView = LoadingFooterView(frame: CGRect(x: 0, y: 0, width: _tableView.bounds.width, height: 44))
        _tableView.tableFooterView = footerView
        _searchTableView.tableFooterView = footerView
        _requestGetFilterData()
        _requestNewExplore(false)
        emptyData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // --------------------------------------
    // MARK: Service
    // --------------------------------------

    private func _requestNewExplore(_ showLoader: Bool = true) {
        WhosinServices.newExplore(shouldRefresh: showLoader) { [weak self] container, error in
            guard let self = self else { return }
            self._tableView.endRefreshing()
            self._searchTableView.endRefreshing()
            self.hideHUD()
            guard let data = container?.data else { return }
            self.exploreModel = data
            APPSETTING.ticketList?.append(contentsOf: data.tickets.toArrayDetached(ofType: TicketModel.self))
            APPSETTING.cityList = data.cities.toArrayDetached(ofType: CategoryDetailModel.self)
            APPSETTING.exploreCategories = data.categories.toArrayDetached(ofType: CategoryDetailModel.self)
            APPSETTING.customComponent = data.customComponents.toArrayDetached(ofType: ExploreBannerModel.self)
            APPSETTING.exploreBanners = data.banners.toArrayDetached(ofType: ExploreBannerModel.self)
            var videoUrls: [URL] = []
            let comVideoUrl = data.customComponents.filter({ URL(string: $0.media) != nil && $0.mediaType == "video" }).map({ URL(string: $0.media)!})
            videoUrls.append(contentsOf: comVideoUrl)
            videoUrls.forEach { url in
                Utils.downloadVideo(url)
            }
            self._loadData()
        }
    }
    
    private func _requestSearch(_ text: String, page: Int = 1, showLoader: Bool = false, searchToken: Int? = nil) {
        let currentToken = searchToken ?? latestSearchToken
        _dataRequest?.cancel()
        self._searchTableView.clearAndReload()
        self.showHUD(self._searchTableView)
        self._searchTableView._loadDummyData(cellPrototypes: _searchPrototype ?? [], dummyLoadCount: 10)
        _dataRequest = WhosinServices.raynaTicketList(search: text, page: page, cities: cities, categories: categories) { [weak self] containers, error in
            guard let self = self else { return }
            self._tableView.endRefreshing()
            self._searchTableView.endRefreshing()
            self.hideHUD(self._searchTableView)
            guard self.latestSearchToken == currentToken else { return }
            let data = containers?.data ?? []
            if page == 1 {
                self._ticketList = data
                self.isSearching = true
            } else if !data.isEmpty {
                self._ticketList.append(contentsOf: data)
            }
            self._loadSearchData()
        }
    }
    
    private func _requestGetFilterData() {
        _selectOption = self._topMenuOptions.map({ $0.id })
        cities = self._topMenuOptions.filter { $0.name.isEmpty == false }.map { $0.id }
        categories = self._topMenuOptions.filter { $0.title.isEmpty == false }.map { $0.id }
        _tableTopConstraint.constant = _selectOption?.isEmpty == true ? 54 : 108
        _dayViewHeightConstraints.constant = _selectOption?.isEmpty == true ? 0 : 60
        _customDaysView.isHidden = _selectOption?.isEmpty == true
        _customDaysView.delegate = self
        _customDaysView.setupData(
            _topMenuOptions.map { option in
                return option.title.isEmpty ? option.name : option.title
            },
            selectedDay: kEmptyString,
            isFromExplore: true
        )
        DispatchQueue.main.async {
            if self._selectOption?.isEmpty == true && Utils.stringIsNullOrEmpty(self._searchText) {
                self._ticketList.removeAll()
                self._loadSearchData()
            } else {
                self.hideShowTabbar(0)
                self.latestSearchToken += 1
                self._requestSearch(self._searchText, showLoader: true, searchToken: self.latestSearchToken)
            }
        }
    }

    // --------------------------------------
    // MARK: Private Table Data Loader
    // --------------------------------------

    private func _loadSearchData(_ isLoading: Bool = false) {
        pauseAllVisibleVideos()
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
            _ticketList.forEach { model in
                cellData.append([
                    kCellIdentifierKey: kEmptyCellIdentiferSearchList,
                    kCellTagKey: kEmptyCellIdentiferSearchList,
                    kCellDifferenceContentKey: model._id,
                    kCellDifferenceIdentifierKey: model._id,
                    kCellObjectDataKey: model,
                    kCellClassKey: ExploreTicketTableCell.self,
                    kCellHeightKey: ExploreTicketTableCell.height
                ])
            }
        _searchTableView.fetchAndInsertBanner()
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        DISPATCH_ASYNC_MAIN {
            self._searchTableView.loadData(cellSectionData)
        }
        
    }
    
    private func _loadData() {
        _ticketList.removeAll()
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        if exploreModel?.homeblocksModel.isEmpty == true {
            cellData.append([
                kCellIdentifierKey: kEmptyCellIdentifier,
                kCellTagKey: _emptyData.first,
                kCellObjectDataKey: _emptyData.first,
                kCellClassKey: EmptyDataCell.self,
                kCellHeightKey: EmptyDataCell.height
            ])
        } else {
            exploreModel?.homeblocksModel.forEach { data in
                if !data.isVisibleExplore { return }
                cellData.append([
                    kCellIdentifierKey: data.cellTypeForExplore.identifier,
                    kCellTagKey: data.id,
                    kCellAllowCacheKey: data.cellTypeForExplore.isNeedCacheCell,
                    kCellObjectDataKey: data,
                    kCellHeightKey: data.cellTypeForExplore.height
                ])
            }
        }
        _tableView.fetchAndInsertBanner()
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    // --------------------------------------
    // MARK: Helpers & Empty View
    // --------------------------------------

    @objc private func enterBackGround() {
        pauseAllVisibleVideos()
    }
    
    @objc private func enterForGround() {
        _visibleVideoCell?.resumeVideo()
    }
    
    private func emptyData() {
        _emptyData.append(["type": "invitations".localized(),"title" : "search_experiences".localized(), "icon": "empty_explore"])
    }
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kEmptyCellIdentifier, kCellNibNameKey: kEmptyCellIdentifier, kCellClassKey: EmptyDataCell.self, kCellHeightKey: EmptyDataCell.height],
            [kCellIdentifierKey: kCellIdentifierCategories, kCellNibNameKey: kCellIdentifierCategories, kCellClassKey: ExploreCategoryTableCell.self, kCellHeightKey: ExploreCategoryTableCell.height],
            [kCellIdentifierKey: kCellIdentifierCities, kCellNibNameKey: kCellIdentifierCities, kCellClassKey: CitiesListTableCell.self, kCellHeightKey: CitiesListTableCell.height],
            [kCellIdentifierKey: kCellIdentifierSingleVideo, kCellNibNameKey: kCellIdentifierSingleVideo, kCellClassKey: SingleVideoTableCell.self, kCellHeightKey: SingleVideoTableCell.height],
            [kCellIdentifierKey: kCellIdentifierTicket, kCellNibNameKey: kCellIdentifierTicket, kCellClassKey: ExploreCustomTicketTableCell.self, kCellHeightKey: ExploreCustomTicketTableCell.height],
            [kCellIdentifierKey: kCellIdentifierBanner, kCellNibNameKey: kCellIdentifierBanner, kCellClassKey: ExploreBannerTableCell.self, kCellHeightKey: ExploreBannerTableCell.height],
            [kCellIdentifierKey: kLoadingCell, kCellNibNameKey: kLoadingCell, kLoadingCell: LoadingCell.self, kCellHeightKey: LoadingCell.height],
            [kCellIdentifierKey: kCellIdentifierCategoriesrectange, kCellNibNameKey: kCellIdentifierCategoriesrectange, kLoadingCell: CategoryTableCell.self, kCellHeightKey: CategoryTableCell.height],
            [kCellIdentifierKey: BannerAdsTableCell.identifier, kCellNibNameKey: BannerAdsTableCell.identifier, kLoadingCell: BannerAdsTableCell.self, kCellHeightKey: BannerAdsTableCell.height], HomeBlockCellType.contactUs.prototype
        ]
    }
    
    private var _searchPrototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kEmptyCellIdentiferSearchList, kCellNibNameKey: kEmptyCellIdentiferSearchList, kCellClassKey: ExploreTicketTableCell.self, kCellHeightKey: ExploreTicketTableCell.height],
            [kCellIdentifierKey: BannerAdsTableCell.identifier, kCellNibNameKey: BannerAdsTableCell.identifier, kLoadingCell: BannerAdsTableCell.self, kCellHeightKey: BannerAdsTableCell.height]
        ]
    }
    
    @IBAction private func _handleFilterEvent(_ sender: UIButton) {
        let vc = INIT_CONTROLLER_XIB(NewExploreFilterBottomSheet.self)
        vc.selectedFilter = _topMenuOptions
        vc.filterCallback = { options in
            self._topMenuOptions.removeAll()
            self._topMenuOptions.append(contentsOf: options)
            self._requestGetFilterData()
        }
        presentAsPanModal(controller: vc)
    }
    
    @IBAction func _handleSearchBackEvent(_ sender: Any) {
        _searchText = kEmptyString
        _expandableSearchView.clear()
        _ticketList.removeAll()
        _topMenuOptions.removeAll()
        hideShowTabbar(36)
        _customDaysView.isHidden = true
        _requestGetFilterData()
    }
    
    private func resetSearch() {
        pauseAllVisibleVideos()
        if !cities.isEmpty || !categories.isEmpty {
            latestSearchToken += 1
            _requestSearch(_searchText, showLoader: true, searchToken: latestSearchToken)
        } else {
            currentSearchTask?.cancel()
            isSearching = false
            _page = 1
            _dataRequest?.cancel()
            if Utils.stringIsNullOrEmpty(_searchText), cities.isEmpty, categories.isEmpty {
                _ticketList.removeAll()
            }
            DispatchQueue.main.async {
                self._loadSearchData()
            }
        }
    }
    
    private func performSearch(with searchText: String) {
        guard !searchText.isEmpty || !cities.isEmpty || !categories.isEmpty else {
            resetSearch()
            return
        }
        pauseAllVisibleVideos()
        _page = 1
        _searchText = searchText
        isSearching = true

        _dataRequest?.cancel()
        latestSearchToken += 1
        _requestSearch(searchText, page: _page, showLoader: true, searchToken: latestSearchToken)
    }
    
    private func hideShowTabbar(_ height: CGFloat) {
        if height == self._headerViewHeightConstraint.constant { return }
        UIView.animate(withDuration: 0.6, delay: 0.05, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.3, options: [.curveEaseInOut]) {
            self._backBtn.isHidden = height != 0
            self._searchTableView.isHidden = height != 0
            self._tableView.isHidden = height == 0
            self._headerViewHeightConstraint.constant = height
            height == 0 ? self._loadSearchData() : self._loadData()
        }
    }
}

extension NewExploreVC: CustomNoKeyboardTableViewDelegate, UIScrollViewDelegate, UITableViewDelegate  {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        let threshold: CGFloat = 20
        if yOffset > threshold {
            UIView.animate(withDuration: 0.50, animations: { [weak self] in
                self?._visualEffectView.alpha = 1.0
            })
        } else {
            UIView.animate(withDuration: 0.50, animations: { [weak self] in
                self?._visualEffectView.alpha = 0.0
            })
        }
        if !isSearching {
            DispatchQueue.main.async { self.playPauseVideoIfVisible() }
        }
        let scrollViewContentHeight = scrollView.contentSize.height
        let scrollOffsetThreshold = scrollViewContentHeight - scrollView.bounds.height
        if scrollView.contentOffset.y > scrollOffsetThreshold && !isFetchingMore {
            performPagination()
        }
    }
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        cell.selectionStyle = .none
        if let cell = cell as? EmptyDataCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [String:Any] else { return }
            cell.setupData(object)
        } else if let cell = cell as? ExploreCategoryTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? HomeBlockModel else { return }
            cell.setupData(object)
        } else if let cell = cell as? CitiesListTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? HomeBlockModel else { return }
            cell.setupData(object)
        } else if let cell = cell as? ExploreCustomTicketTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? HomeBlockModel else { return }
            cell.setupData(object)
        } else if let cell = cell as? SingleVideoTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? HomeBlockModel else { return }
            cell.setupData(object)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.playPauseVideoIfVisible()
            }
        } else if let cell = cell as? ExploreBannerTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? HomeBlockModel else { return }
            cell.setup(object)
        } else if let cell = cell as? ExploreTicketTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? TicketModel else {
                cell.clearData()
                return
            }
            cell.setUpdata(object)
        } else if let cell = cell as? CategoryTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? HomeBlockModel else { return }
            cell.setupExploreData(object)
        } else if let cell = cell as? BannerAdsTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? PromotionalBannerItemModel else { return }
            cell.setupData(object)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.playPauseVideoIfVisible()
            }
        } else if let cell = cell as? ConnectUSTableViewCell {
            guard let object = cellDict?[kCellObjectDataKey] as? HomeBlockModel, let model = object.contactUsBlock.first else { return }
            cell.setup(model,screen: .exploreBlock)
        }

    }

    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? ExploreTicketTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? TicketModel else { return }
            let vc = INIT_CONTROLLER_XIB(CustomTicketDetailVC.self)
            vc.ticketID = object._id
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    private func performPagination() {
        if !isFetchingMore && !_ticketList.isEmpty {
            if _ticketList.count % 10 == 0 {
                _page += 1
                footerView?.startAnimating()
                _requestSearch(_searchText, page: _page, searchToken: latestSearchToken)
            } else {
                footerView?.stopAnimating()
            }
        }
    }
    
    func refreshData() {
        guard _topMenuOptions.isEmpty && !isSearching else {
            _tableView.endRefreshing()
            return
        }
        _searchText = kEmptyString
        _ticketList.removeAll()
        _requestNewExplore(true)
    }
    
    func playPauseVideoIfVisible() {
        _tableView.visibleCells.forEach { cell in
            if let cell = cell as? SingleVideoTableCell {
                guard let indexPath = _tableView.indexPath(for: cell) else { return }
                let cellRect = _tableView.rectForRow(at: indexPath)
                if let superview = _tableView.superview {
                    let convertedRect = _tableView.convert(cellRect, to:superview)
                    let intersect = _tableView.frame.intersection(convertedRect)
                    let visibleHeight = intersect.height
                    let cellHeight = cellRect.height
                    let ratio = visibleHeight / cellHeight
                    if ratio <= 0.8 {
                        cell.pauseVideo()
                    } else if cell._videoModel?.mediaType == "video" {
                        cell.resumeVideo()
                    }
                }
            }
            else if let cell = cell as? BannerAdsTableCell {
                guard let indexPath = _tableView.indexPath(for: cell) else { return }
                let cellRect = _tableView.rectForRow(at: indexPath)
                if let superview = _tableView.superview {
                    let convertedRect = _tableView.convert(cellRect, to:superview)
                    let intersect = _tableView.frame.intersection(convertedRect)
                    let visibleHeight = intersect.height
                    let cellHeight = cellRect.height
                    let ratio = visibleHeight / cellHeight
                    if ratio <= 0.8 { cell.pause() }
                    else { cell.resume() }
                }
            }
        }
    }

    func pauseAllVisibleVideos() {
        _tableView.visibleCells.forEach { cell in
            if let videoCell = cell as? SingleVideoTableCell {
                videoCell.pauseVideo()
            } else if let cell = cell as? BannerAdsTableCell {
                cell.pause()
            }
        }
        _visibleVideoCell = nil
    }
}

extension NewExploreVC: CustomDaysHeaderViewDelegate {
    func removeAction(filter: String) {
        if let selectedIndex = _topMenuOptions.firstIndex(where: { $0.title == filter || $0.name == filter }) {
            _topMenuOptions.remove(at: selectedIndex)
            _requestGetFilterData()
            if _topMenuOptions.isEmpty && Utils.stringIsNullOrEmpty(_searchText) {
                resetSearch()
            }
        }
    }
    
    func didSelectDay(_ day: String) { }
}

