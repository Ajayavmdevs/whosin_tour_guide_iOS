import UIKit

class CMEventListVC: ProfileBaseMainVC, UITableViewDelegate {
    
    @IBOutlet weak var _tableView: CustomNoKeyboardTableView!
    private var _eventList: [PromoterEventsModel] = []
    private var isLoadingMyEvent: Bool = false
    private var headerView : CMEventFilterHeaderView?
    private let kCellMyList = String(describing: CMEventListCell.self)
    private let kCellMyGroupCell = String(describing: MyPlusOneGroupTableViewCell.self)
    private let kCellFeaturedCell = String(describing: FeaturedTicketViewCell.self)
    private let kCellFeaturedRoundCategoryCell = String(describing: ExploreCategoryTableCell.self)
    private let kCellFeaturedCategoryCell = String(describing: CategoryTableCell.self)
    private let kCellLoadingCell = String(describing: LoadingCell.self)
    private var filterType: String = "starting soon"
    private var filteredSearchText: String = kEmptyString
    private var isSearching = false
    public var myGroupList: [UserDetailModel] = []
    private var eventList: [PromoterEventsModel] {
        get {
            var list = _eventList
            if isSearching {
                list = searchEventList(list)
            }
            
            if !Utils.stringIsNullOrEmpty(filterType) {
                list = filterEventList(list)
            }
            return list
        }
        set {
            _eventList = newValue
            _loadData()
        }
    }
    private var _callback: ((Bool) -> Void)?
    private var categories: [String] = []
    public static var isHavePlusOneGroup: Bool = false
    private var isLoadingGroup: Bool = false
    private var featuredModel: HomeBlockModel?
    private var isLoadFeaturedTicket: Bool = true
    private var _blockModel: HomeModel?
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
        setupUi()
        NotificationCenter.default.addObserver(self, selector: #selector(handleReload), name: .reloadMyEventsNotifier, object: nil)
        NotificationCenter.default.addObserver(self, selector:  #selector(handleReload), name: kRelaodActivitInfo, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleReload), name: .changereloadNotificationUpdateState, object: nil)
        
    }
    
    //    override var customTableView: CustomNoKeyboardTableView? { _tableView }
    
    override func setupUi() {
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: true,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "empty_event_profile".localized(),
            emptyDataIconImage: UIImage(named: "empty_event"),
            emptyDataDescription: nil,
            delegate: self)
        _tableView.proxyDelegate = self
        _tableView.delegate = self
        _tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        isLoadingMyEvent = true
        isLoadingGroup = true
        _requestFeaturedTicketList()
        _loadingChat()
        _requestMyGroup()
        _requestEventList()
    }
    
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    override func _refresh(_ callback: @escaping (Bool) -> Void) {
        self._callback = callback
        handleReload()
    }
    
    private func _requestFeaturedTicketList(_ showLoader: Bool = false) {
        WhosinServices.featuredTickets(shouldRefresh: showLoader) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD()
            guard let data = container?.data else { return }
            self._blockModel = data
            let newTickets = data.tickets.toArrayDetached(ofType: TicketModel.self)
            let existingIDs = Set(APPSETTING.ticketList?.map(\._id) ?? [])
            APPSETTING.ticketList?.append(contentsOf: newTickets.filter { !existingIDs.contains($0._id) })
            let newCategories = data.ticketCategories.toArrayDetached(ofType: CategoryDetailModel.self)
            let existingID = Set(APPSETTING.ticketCategories?.map(\.id) ?? [])
            APPSETTING.ticketCategories?.append(contentsOf: newCategories.filter({ !existingID.contains($0.id)}))
            self._loadData()
        }
    }
    
    private func _requestEventList(_ isReload: Bool = false) {
        WhosinServices.getEventList { [weak self] container, error in
            guard let self = self else { return }
            self.isLoadingMyEvent = false
            self.hideHUD(error: error)
            guard let data = container?.data else {
                self.isLoadingMyEvent = false
                self._callback?(true)
                return
            }
            self._eventList = data
            self.categories = Array(Set(data.map { $0.category }.filter { !$0.isEmpty && $0 != "none" }))
            self.headerView?.setData(data: self.categories)
            self._loadData()
        }
    }
    
    private func _requestMyGroup() {
        WhosinServices.myPlusOneList { [weak self] container, error in
            guard let self = self else { return }
            self.isLoadingGroup = false
            self.hideHUD(error: error)
            guard let data = container?.data else {
                self.isLoadingGroup = false
                self._callback?(true)
                return
            }
            self.myGroupList = data
            CMEventListVC.isHavePlusOneGroup = !data.isEmpty
            self._loadData()
        }
    }
    
    @objc func handleReload() {
        _requestFeaturedTicketList()
        _requestEventList()
        _requestMyGroup()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellMyList, kCellNibNameKey: kCellMyList, kCellClassKey: CMEventListCell.self, kCellHeightKey: CMEventListCell.height],
            [kCellIdentifierKey: kCellLoadingCell, kCellNibNameKey: kCellLoadingCell, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height],
            [kCellIdentifierKey: kCellMyGroupCell, kCellNibNameKey: kCellMyGroupCell, kCellClassKey: MyPlusOneGroupTableViewCell.self, kCellHeightKey: MyPlusOneGroupTableViewCell.height],
            [kCellIdentifierKey: kCellFeaturedCategoryCell, kCellNibNameKey: kCellFeaturedCategoryCell, kCellClassKey: CategoryTableCell.self, kCellHeightKey: CategoryTableCell.height],
            [kCellIdentifierKey: kCellFeaturedRoundCategoryCell, kCellNibNameKey: kCellFeaturedRoundCategoryCell, kCellClassKey: ExploreCategoryTableCell.self, kCellHeightKey: ExploreCategoryTableCell.height],
            [kCellIdentifierKey: kCellFeaturedCell, kCellNibNameKey: kCellFeaturedCell, kCellClassKey: FeaturedTicketViewCell.self, kCellHeightKey: FeaturedTicketViewCell.height],
        ]
    }
    
    private func groupEventsByUserAndVenue() -> [String: [String: [PromoterEventsModel]]] {
        return Dictionary(grouping: eventList) { event in
            event.user?.id ?? kEmptyString
        }.mapValues { userEvents in
            Dictionary(grouping: userEvents) { event in
                if event.venueType == "venue" {
                    return event.venue?.id ?? kEmptyString
                } else if event.venueType == "custom" {
                    return event.customVenue?.name.lowercased() ?? kEmptyString
                }
                return kEmptyString
            }
        }
    }
    
    private func groupEventsByVenue() -> [[PromoterEventsModel]] {
        return eventList.reduce(into: [[PromoterEventsModel]]()) { result, event in
            if let index = result.firstIndex(where: {
                if event.venueType == "venue" {
                    return $0.first?.venue?.id == event.venue?.id
                } else if event.venueType == "custom" {
                    return $0.first?.customVenue?.name.lowercased() == event.customVenue?.name.lowercased()
                }
                return false
            }) {
                result[index].append(event)
            } else {
                result.append([event])
            }
        }
    }
    
    private func filterEventList(_ list: [PromoterEventsModel]) -> [PromoterEventsModel] {
        if filterType.lowercased() == "near me" {
            return list.sorted { $0.distance < $1.distance }
        } else if filterType.lowercased() == "starting soon" {
            return list.sorted {
                guard let firstDate = $0.startingSoon, let secondDate = $1.startingSoon else { return false }
                return firstDate < secondDate
            }
        } else {
            return list.filter { $0.category.lowercased() == filterType.lowercased() }
        }
    }
    
    private func searchEventList(_ list: [PromoterEventsModel]) -> [PromoterEventsModel] {
        list.filter { event in
            let venueMatch = (event.venueType == "venue" && event.venue?.name.lowercased().contains(filteredSearchText.lowercased().trimmingCharacters(in: .whitespaces)) ?? false) ||
            (event.venueType == "custom" && event.customVenue?.name.lowercased().contains(filteredSearchText.lowercased().trimmingCharacters(in: .whitespaces)) ?? false)
            let userMatch = event.user?.fullName.lowercased().contains(filteredSearchText.lowercased().trimmingCharacters(in: .whitespaces)) ?? false
            return venueMatch || userMatch
        }
    }
    
    private func _loadingChat() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        cellData.append([
            kCellIdentifierKey: kCellLoadingCell,
            kCellTagKey: self.kCellLoadingCell,
            kCellObjectDataKey: "loading",
            kCellClassKey: LoadingCell.self,
            kCellHeightKey: LoadingCell.height
        ])
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        self._tableView.loadData(cellSectionData)
    }
    
    private func _loadData(_ isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        self._callback?(true)
        cellData.append([
            kCellIdentifierKey: kCellMyGroupCell,
            kCellTagKey: kCellMyGroupCell,
            kCellObjectDataKey: myGroupList,
            kCellClassKey: MyPlusOneGroupTableViewCell.self,
            kCellHeightKey: MyPlusOneGroupTableViewCell.height
        ])
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        cellData.removeAll()
        
        if isLoadingMyEvent {
            cellData.append([
                kCellIdentifierKey: kCellLoadingCell,
                kCellTagKey: kCellLoadingCell,
                kCellObjectDataKey: "myGroupList",
                kCellClassKey: LoadingCell.self,
                kCellHeightKey: LoadingCell.height
            ])
        } else {
                        
            let eventList = groupEventsByVenue()
            let ticketList = _blockModel?.homeblocksModel.filter { $0.isVisible && $0.type == "ticket"} ?? []
            let categoryList = _blockModel?.homeblocksModel.filter { $0.isVisible && $0.type == "ticket-category" } ?? []
            
            let eventCells: [[String: Any]] = eventList.map { event in
                [
                    kCellIdentifierKey: kCellMyList,
                    kCellTagKey: false,
                    kCellObjectDataKey: event,
                    kCellClassKey: CMEventListCell.self,
                    kCellHeightKey: CMEventListCell.height
                ]
            }
            
            let ticketCells: [[String: Any]] = ticketList.map { ticket in
                [
                    kCellIdentifierKey: kCellFeaturedCell,
                    kCellTagKey: kCellFeaturedCell,
                    kCellObjectDataKey: ticket,
                    kCellClassKey: FeaturedTicketViewCell.self,
                    kCellHeightKey: FeaturedTicketViewCell.height
                ]
            }
            
            let categoryCells: [[String: Any]] = categoryList.map { category in
                if category.shape == "rectangular" {
                    return [
                        kCellIdentifierKey: kCellFeaturedCategoryCell,
                        kCellTagKey: kCellFeaturedCategoryCell,
                        kCellObjectDataKey: category,
                        kCellClassKey: CategoryTableCell.self,
                        kCellHeightKey: CategoryTableCell.height
                    ]
                } else {
                    return [
                        kCellIdentifierKey: kCellFeaturedRoundCategoryCell,
                        kCellTagKey: kCellFeaturedRoundCategoryCell,
                        kCellObjectDataKey: category,
                        kCellClassKey: ExploreCategoryTableCell.self,
                        kCellHeightKey: ExploreCategoryTableCell.height
                    ]
                }
            }
            
            let featuredCells = (ticketCells + categoryCells).shuffled()
            
            if !eventCells.isEmpty {
                var result: [[String: Any]] = []
                var featuredIndex = 0
                
                let totalEvents = eventCells.count
                var insertIndexes: [Int] = []
                
                if totalEvents < 4 {
                    if let index = (0..<totalEvents).randomElement(), !featuredCells.isEmpty {
                        insertIndexes = [index]
                    }
                } else {
                    var i = 0
                    while i < totalEvents && featuredIndex < featuredCells.count {
                        insertIndexes.append(i == 0 ? 0 : min(i, totalEvents))
                        i += 4
                        featuredIndex += 1
                    }
                }
                
                featuredIndex = 0
                var currentIndex = 0
                
                for i in 0..<eventCells.count {
                    if insertIndexes.contains(currentIndex), featuredIndex < featuredCells.count {
                        result.append(featuredCells[featuredIndex])
                        featuredIndex += 1
                        currentIndex += 1
                    }
                    
                    result.append(eventCells[i])
                    currentIndex += 1
                }
                
                while featuredIndex < featuredCells.count {
                    if let last = result.last,
                       let lastIdentifier = last[kCellIdentifierKey] as? String,
                       lastIdentifier != kCellFeaturedCell &&
                        lastIdentifier != kCellFeaturedCategoryCell &&
                        lastIdentifier != kCellFeaturedRoundCategoryCell {
                        result.append(featuredCells[featuredIndex])
                        featuredIndex += 1
                    } else {
                        break
                    }
                }
                
                cellData = result
            }
        }
        cellSectionData.append([
            kSectionTitleKey: kEmptyString,
            kSectionDataKey: cellData
        ])
        self._tableView.loadData(cellSectionData)
        
    }
    
    
}


// --------------------------------------
// MARK: TableView Delegate
// --------------------------------------

extension CMEventListVC: CustomNoKeyboardTableViewDelegate, UIScrollViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? CMEventListCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [PromoterEventsModel], let isHide = cellDict?[kCellTagKey] as? Bool else { return }
            cell._promoterView.isHidden = !isHide
            cell.setupData(object, cellTitle: "")
        } else if let cell = cell as? MyPlusOneGroupTableViewCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [UserDetailModel] else { return }
            cell.setupData(object)
        } else if let cell = cell as? FeaturedTicketViewCell {
            if let object = cellDict?[kCellObjectDataKey] as? HomeBlockModel {
                cell.setupData(object)
            }
        } else if let cell = cell as? CategoryTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? HomeBlockModel else { return }
            cell.setupData(object)
        } else if let cell = cell as? ExploreCategoryTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? HomeBlockModel else { return }
            cell.setupHomeData(object)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if headerView == nil {
            headerView = CMEventFilterHeaderView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 120))
            headerView?.setData(data: categories)
            headerView?.callback = { filter in
                self.filterType = filter
                self._loadData()
            }
            headerView?._searchBar.delegate = self
            return headerView
        } else {
            return headerView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 120.0 : 0.0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScroll(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating called")
        
        didEndDecelerating(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("scrollViewDidEndDragging called")
        
        didEndDragging(scrollView, willDecelerate: decelerate)
    }
    
}

extension CMEventListVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredSearchText = ""
        } else {
            isSearching = true
            filteredSearchText = searchText.lowercased().trimmingCharacters(in: .whitespaces)
        }
        _loadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        filteredSearchText = "starting soon"
        searchBar.text = ""
        _loadData()
        searchBar.resignFirstResponder()
    }
    
}
