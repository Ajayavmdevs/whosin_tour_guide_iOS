import UIKit
import RealmSwift
import Alamofire

var searchFilter: [String: Any] = [:]

class NewSearchVC: NavigationBarViewController {

    @IBOutlet private weak var _searchBackBtn: UIButton!
    @IBOutlet private weak var _backButton: UIButton!
    @IBOutlet private weak var _tableView: CustomNoKeyboardTableView!
    @IBOutlet private weak var _searchResultTableView: CustomNoKeyboardTableView!
    @IBOutlet private weak var _navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var _navigationHeaderView: UIView!
    @IBOutlet weak var _expandableSearchView: ExpandableSearchView!
    @IBOutlet weak var searchViewHeightConstraint: NSLayoutConstraint!
    private let kCellIdentifierStoryView = String(describing: LatestSearchTableCell.self)
    private let kCellIdentifierCategories = String(describing: CategoryTableCell.self)
    private let kCellIdentifierHeader = String(describing: SearchHeaderCollectionCell.self)
    private let kCellIdentifierTicketList = String(describing: ExploreTicketTableCell.self)
    private let kCellIdentifierTicket = String(describing: AllCustomTicketTableCell.self)
    private let kCellIdentifierHistory = String(describing: SearchHistoryTableCell.self)
    private let kCellIdentifierSearchText = String(describing: SearchTextTableCell.self)

    private var _recommendedDetail: HomeModel?
    private var _searchResult: [SearchResultModel] = []
    private var shouldAllowSearchBarToEndEditing: Bool = true
    private var _dataRequest: DataRequest?
    private var searchActivityIndicator: UIActivityIndicatorView?
    private var currentSearchTask: DispatchWorkItem?
    private let searchQueue = DispatchQueue(label: "com.app.searchQueue", qos: .userInitiated)
    private var searchText: String = kEmptyString

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
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
        _expandableSearchView.ondidChange = { [weak self] text in
            guard let self = self else { return }
            self.searchText = text
            if !shouldAllowSearchBarToEndEditing { hideShowTabbar(0) }
            if Utils.stringIsNullOrEmpty(text) {
                searchActivityIndicator?.stopAnimating()
                _tableView.isHidden = true
                self._searchResult = []
                _searchResultTableView.isHidden = false
                _loadSearchHistoryData()
            } else {
                _tableView.isHidden = true
                hideShowTabbar(50)
                if self._searchResult.count > 0 { return }
                self._searchResultTableView.clear()
            }
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.3, options: [.curveEaseInOut]) {
                self._navBarHeightConstraint.constant = 0
                self._navigationHeaderView.layer.opacity = 0
                self._navigationHeaderView.isHidden = true
                self._searchBackBtn.isHidden = false
                self.view.layoutIfNeeded()
            } completion: { _ in
                self._searchResultTableView.isHidden = false
                DISPATCH_ASYNC_MAIN {
                    if Utils.stringIsNullOrEmpty(text) {
                        self._loadSearchHistoryData()
                    }
                }
            }
            _tableView.reload()
        }
        
        _expandableSearchView.onSearchPressed = { [weak self] searchText in
            guard let self = self else { return }
            Preferences.searchText.removeAll { $0 == searchText }
            Preferences.searchText.insert(searchText, at: 0)
            if Preferences.searchText.count > 10 {
                Preferences.searchText.removeLast()
            }
            self.requestSearchOrFilter(text: searchText)
        }
        _expandableSearchView.onHeightChanged = { [weak self] newHeight in
            var _newHeight = newHeight
            if _newHeight < 50 {
                _newHeight = 36
            }
            self?.searchViewHeightConstraint.constant = _newHeight
            UIView.animate(withDuration: 0.25) {
                self?.view.layoutIfNeeded()
            }
        }
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
            emptyDataDescription: "empty_search",
            delegate: self)
        _requestRecommendedData()
        _searchResultTableView.setup(
            cellPrototypes: _searchTablePrototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: true,
            dummyLoadCount: 0,
            enableRefresh: true,
            isShowRefreshing: true,
            emptyDataText: kEmptyString,
            emptyDataIconImage: UIImage(named: "empty_search"),
            emptyDataDescription: "Find what you are looking for.",
            delegate: self)
        _searchResultTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)

    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
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
        self._searchResultTableView.clearAndReload()
        self.showHUD(self._searchResultTableView)
        self._searchResultTableView._loadDummyData(cellPrototypes: _searchTablePrototype ?? [], dummyLoadCount: 10)
        self.showHUD(self._searchResultTableView)
        _dataRequest = WhosinServices.search(text) { [weak self] containers, error in
            guard let self = self else { return }
            self._tableView.endRefreshing()
            self._searchResultTableView.endRefreshing()
            self.hideHUD(self._searchResultTableView)
            guard let data = containers?.data, error?.localizedDescription != "Request explicitly cancelled." else {
                return
            }
            self._searchResult = data.filter { $0.type == "ticket" }
            let newTabs = self._searchResult.map { $0.type }
            self.hideShowTabbar(1)
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
                kSectionTitleKey: "recent_searches".localized(),
                kSectionRightInfoKey: "clear_all".localized(),
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
    
    @objc func touchHappen(_ sender: UITapGestureRecognizer) {
        APPSETTING.removeAllSearchHistory()
        Preferences.searchText.removeAll()
        _loadSearchHistoryData()
    }

    private func _loadSearchResultData(isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        _searchResult.forEach { object in
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
        }
                
        _searchResultTableView.fetchAndInsertBanner()
        cellSectionData.append([kSectionTitleKey: " ", kSectionDataKey: cellData])
        DISPATCH_ASYNC_MAIN {
            self._searchResultTableView.updateData(cellSectionData)
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _searchTablePrototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierTicketList, kCellNibNameKey: kCellIdentifierTicketList, kCellClassKey: ExploreTicketTableCell.self, kCellHeightKey: ExploreTicketTableCell.height],
            [kCellIdentifierKey: BannerAdsTableCell.identifier, kCellNibNameKey: BannerAdsTableCell.identifier, kCellClassKey: BannerAdsTableCell.self, kCellHeightKey: BannerAdsTableCell.height],
            [kCellIdentifierKey: kCellIdentifierHistory, kCellNibNameKey: kCellIdentifierHistory, kCellClassKey: SearchHistoryTableCell.self, kCellHeightKey: SearchHistoryTableCell.height],
            [kCellIdentifierKey: kCellIdentifierSearchText, kCellNibNameKey: kCellIdentifierSearchText, kCellClassKey: SearchTextTableCell.self, kCellHeightKey: SearchTextTableCell.height],
        ]
    }
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierStoryView, kCellNibNameKey: kCellIdentifierStoryView, kCellClassKey: LatestSearchTableCell.self, kCellHeightKey: LatestSearchTableCell.height],
            [kCellIdentifierKey: kCellIdentifierCategories, kCellNibNameKey: kCellIdentifierCategories, kCellClassKey: CategoryTableCell.self, kCellHeightKey: CategoryTableCell.height],
            [kCellIdentifierKey: kCellIdentifierHistory, kCellNibNameKey: kCellIdentifierHistory, kCellClassKey: SearchHistoryTableCell.self, kCellHeightKey: SearchHistoryTableCell.height],
            [kCellIdentifierKey: kCellIdentifierSearchText, kCellNibNameKey: kCellIdentifierSearchText, kCellClassKey: SearchTextTableCell.self, kCellHeightKey: SearchTextTableCell.height],HomeBlockCellType.ticket.prototype,
            [kCellIdentifierKey: BannerAdsTableCell.identifier, kCellNibNameKey: BannerAdsTableCell.identifier, kCellClassKey: BannerAdsTableCell.self, kCellHeightKey: BannerAdsTableCell.height]
        ]
    }
    
    private var _headerPrototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifierHeader, kCellNibNameKey: kCellIdentifierHeader, kCellClassKey: SearchHeaderCollectionCell.self, kCellHeightKey: SearchHeaderCollectionCell.height]]
    }
    
    private func hideShowTabbar(_ height: CGFloat) {
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.3, options: [.curveEaseInOut]) {
            self._searchResultTableView.isHidden = height == 0
            self._tableView.isHidden = height != 0
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func _handleSearchBackEvent(_ sender: UIButton) {
        _expandableSearchView.clear()
        _dataRequest?.cancel()
        currentSearchTask?.cancel()
        _searchResult.removeAll()
        _tableView.isHidden = false
        _searchResultTableView.isHidden = true
        hideShowTabbar(0)
        _loadRecommandationData()
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.3, options: [.curveEaseInOut]) {
            self._searchBackBtn.isHidden = true
            self._navBarHeightConstraint.constant = 54
            self._navigationHeaderView.layer.opacity = 1
            self._navigationHeaderView.isHidden = false
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func _handleBackEvent(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    private func requestSearchOrFilter(text: String) {
        currentSearchTask?.cancel()
        let trimmedText = text.trimmingCharacters(in: .whitespaces)
        let searchTask = DispatchWorkItem { [weak self] in
            DispatchQueue.main.async {
                guard let self = self, text.trimmingCharacters(in: .whitespaces) == trimmedText else { return }
                self._requestSearch(trimmedText, showLoader: true)
            }
        }
        currentSearchTask = searchTask
        searchQueue.asyncAfter(deadline: .now() + 0.5, execute: searchTask)
    }
}


extension NewSearchVC: CustomNoKeyboardTableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String: Any]?, indexPath: IndexPath) {
        cell.selectionStyle = .none
        if let cell = cell as? SearchTextTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [String] else { return }
            cell.setupData(object)
            cell.delegate = self
        }  else if let cell = cell as? SearchHistoryTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? SearchHistoryModel else { return }
            cell._profileImageView.image = nil
            cell.delegate = self
            cell.setupData(object)
        } else if let cell = cell as? CustomTicketTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? HomeBlockModel else { return }
            cell.setupExploreData(object)
        } else if let cell = cell as? CategoryTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [CategoryDetailModel] else { return }
            cell.setupData(object)
        } else if let cell = cell as? AllCustomTicketTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [TicketModel] else { return }
            cell.setupData(object)
//            cell.delegate = self 
        } else if let cell = cell as? ExploreTicketTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? TicketModel else {
                cell.clearData()
                return
            }
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
            self.playPauseVideoIfVisible()
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String: Any]?, indexPath: IndexPath) {
        if cell is SearchHistoryTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? SearchHistoryModel else { return }
            if object.type == "ticket" {
                let vc = INIT_CONTROLLER_XIB(CustomTicketDetailVC.self)
                vc.ticketID = object.id
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
            }
        } else if cell is SearchTextTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? String else { return }
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
        requestSearchOrFilter(text: searchText)
    }
}

extension NewSearchVC: CustomCollectionViewDelegate, UICollectionViewDelegate {
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String: Any]?, indexPath: IndexPath) {
        if let cell = cell as? SearchHeaderCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? String else { return }
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
        _loadSearchResultData()
    }
}

extension NewSearchVC: SearchHistoryTableCellDelegate {
    func searchHistoryCellDidTapClose(_ cell: SearchHistoryTableCell) {
        if let indexPath = _searchResultTableView.indexPath(for: cell) {
            let historyModel = APPSETTING.searchHistory[indexPath.row]
            APPSETTING.removeSearchHistory(historyModel)
            _loadSearchHistoryData()
        }
    }
}

extension NewSearchVC: SearchTextTapDelegate {
    func searchTextTapped(_ data: String) {
        searchText = data
        _expandableSearchView.set(data)
        requestSearchOrFilter(text: data)
    }
}

extension NewSearchVC: PresentedViewControllerDelegate {
    func presentedViewControllerWillDismiss() {
        shouldAllowSearchBarToEndEditing = true
    }
}

