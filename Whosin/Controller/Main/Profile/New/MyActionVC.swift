import UIKit

class MyActionVC: ProfileBaseMainVC {

    @IBOutlet private weak var _tableView: CustomNoKeyboardTableView!
    private var _eventList: [PromoterEventsModel] = []
    private var _plusOneEventList: [PromoterEventsModel] = []
    private var isLoadingMyEvent: Bool = false
    private var headerView : CMEventStatusHeaderView?
    private let kCellMyList = String(describing: CMEventListCell.self)
    private var _status: String = "Events I’m In"
    private var _callback: ((Bool) -> Void)?
    private var eventList: [PromoterEventsModel] {
        get {
            var list = _eventList
            if !Utils.stringIsNullOrEmpty(_status) {
                list = filterEventList(list)
            }
            return list
        }
        set {
            _eventList = newValue
            _loadData(eventList)
        }
    }
    
    private var _bucketDealsList: [DealsModel] = []
    private var _outingList: [OutingListModel] = []
    private var _bucketList: [BucketDetailModel] = []
    private let kCellIdentifierVenueDetail = String(describing: BucketTableCell.self)
    private let kEmptyCellIdentifier = String(describing: EmptyDataCell.self)
    private let KPlusOneEvenIdentifier = String(describing: UserPlusOneEventTableCell.self)
    private let kCellMyGroupCell = String(describing: MyPlusOneGroupTableViewCell.self)
    private let kCellLoadingCell = String(describing: LoadingCell.self)
    private var _eventHistory: [PromoterEventsModel] = []
    public var myGroupList: [UserDetailModel] = []
    private var _page : Int = 1
    private var isPaginating = false
    private var footerView: LoadingFooterView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
        isLoadingMyEvent = true
        setupUi()
        NotificationCenter.default.addObserver(self, selector: #selector(handleReloadMyEvent), name: .reloadMyEventsNotifier, object: nil)
        NotificationCenter.default.addObserver(self, selector:  #selector(handleReloadList), name: kReloadBucketList, object: nil)

    }
    
    override func _refresh(_ callback: @escaping (Bool) -> Void) {
        self._callback = callback
        if APPSESSION.userDetail?.isRingMember == false {
            _requestMyGroup()
            _requestPlusoneEventList()
        } else {
            _requestMyGroup()
            _requestEventList(false)
        }
    }

    override func setupUi() {
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: true,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "you_not_applied_any_event_yet".localized(),
            emptyDataIconImage: UIImage(named: "empty_explore"),
            emptyDataDescription: nil,
            delegate: self)
        footerView = LoadingFooterView(frame: CGRect(x: 0, y: 0, width: _tableView.bounds.width, height: 44))
        _tableView.tableFooterView = footerView

        if APPSESSION.userDetail?.isRingMember == true {
            _tableView.proxyDelegate = self
            _tableView.delegate = self
        }
        _tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        _loadingChat()
        if APPSESSION.userDetail?.isRingMember == false {
            _requestMyGroup()
            _requestPlusoneEventList()
        } else {
            _requestMyGroup()
            _requestPlusoneEventList()
            _requestEventList(true)
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
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestEventList(_ isReload: Bool = false) {
//        if isReload { showHUD() }
        WhosinServices.getEventList { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            self.isLoadingMyEvent = false
            guard let data = container?.data else {
                self._callback?(true)
                return
            }
            self._eventList = data
            self._loadData(eventList)
            self._callback?(true)
        }
    }

    private func _requestPlusoneEventList(_ isReload: Bool = false) {
//        if isReload { showHUD() }
        WhosinServices.eventPlusOneList { [weak self] container, error in
            guard let self = self else {
                
                return
            }
            self.hideHUD(error: error)
            guard let data = container?.data else {
                self._callback?(true)
                return
            }
            self._plusOneEventList = data
            self._callback?(true)
            self._normalUserLoadData()
        }
    }
    
    private func _requestEventHistoryList(_ isReload: Bool = false) {
        if isReload { showHUD() }
        WhosinServices.CMEventHistory(page: _page) { [weak self] container, error in
            guard let self = self else { return }
            self.footerView?.stopAnimating()
            self.hideHUD(error: error)
            self.isLoadingMyEvent = false
            guard let data = container?.data else {
                self._callback?(true)
                return
            }
            if self.isPaginating {
                self.isPaginating = false
                self._eventHistory.append(contentsOf: data)
            } else {
                self._eventHistory = data
            }
            self._loadData(self._eventHistory)
            self._callback?(true)
        }
    }
    
    private func _requestMyGroup() {
        WhosinServices.myPlusOneUserList { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else {
                return
            }
            self.myGroupList = data
            if APPSESSION.userDetail?.isRingMember == true {
                self._loadData(self.eventList)
            } else {
                self._normalUserLoadData()
            }
        }
    }
    
    private func _requestBucketList(_ shouldRefresh: Bool = false) {
//        if shouldRefresh { showHUD() }
        WhosinServices.requestMyBucketList { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else {
                self._callback?(true)
                return
            }
            self._bucketList = data.bucketList.toArrayDetached(ofType: BucketDetailModel.self)
            let outingList = data.outings.toArrayDetached(ofType: OutingListModel.self)
            self._outingList = outingList.filter({ $0.owner != nil })
            self._bucketDealsList = data.deals.toArrayDetached(ofType: DealsModel.self)
            self._callback?(true)
            self._normalUserLoadData()
        }
    }
    
    private func filterEventList(_ list: [PromoterEventsModel]) -> [PromoterEventsModel] {
        if _status == "Events I’m In" {
            return list.filter({ $0.invite?.inviteStatus == "in" && $0.invite?.promoterStatus == "accepted" })
        } else if _status == "Pending Events" {
            return list.filter({ ($0.invite?.inviteStatus == "in" && $0.invite?.promoterStatus == "pending") && !$0.isEventFull })
        } else if _status == "On My List" {
            return list.filter({ $0.isWishlisted == true })
        } else if _status == "Public Events" {
            return list.filter({ $0.type == "public" })
        } else {
            return []
        }
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
    
    private func groupEventsByVenue(_ model: [PromoterEventsModel]) -> [[PromoterEventsModel]] {
        return model.reduce(into: [[PromoterEventsModel]]()) { result, event in
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
    
    @objc func handleReloadMyEvent() {
        if APPSESSION.userDetail?.isRingMember == false {
            _requestMyGroup()
            _requestPlusoneEventList()
        } else {
            _requestMyGroup()
            _requestPlusoneEventList()
            _requestEventList(true)
        }
    }
    
    @objc private func handleReloadList() {
        if APPSESSION.userDetail?.isRingMember == false {
            _requestMyGroup()
            _requestPlusoneEventList()
        } else {
            _requestMyGroup()
            _requestPlusoneEventList()
            _requestEventList(true)
        }
    }
 
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellMyList, kCellNibNameKey: kCellMyList, kCellClassKey: CMEventListCell.self, kCellHeightKey: CMEventListCell.height],
            [kCellIdentifierKey: kCellIdentifierVenueDetail, kCellNibNameKey: kCellIdentifierVenueDetail, kCellClassKey: BucketTableCell.self, kCellHeightKey: BucketTableCell.height],
            [kCellIdentifierKey: String(describing: MyOutingTableCell.self), kCellNibNameKey: String(describing: MyOutingTableCell.self), kCellClassKey:  MyOutingTableCell.self, kCellHeightKey: MyOutingTableCell.height],
            [kCellIdentifierKey: kEmptyCellIdentifier, kCellNibNameKey: kEmptyCellIdentifier, kCellClassKey: EmptyDataCell.self, kCellHeightKey: EmptyDataCell.height],
            [kCellIdentifierKey: KPlusOneEvenIdentifier, kCellNibNameKey: KPlusOneEvenIdentifier, kCellClassKey: UserPlusOneEventTableCell.self, kCellHeightKey: UserPlusOneEventTableCell.height],
            [kCellIdentifierKey: kCellMyGroupCell, kCellNibNameKey: kCellMyGroupCell, kCellClassKey: MyPlusOneGroupTableViewCell.self, kCellHeightKey: MyPlusOneGroupTableViewCell.height],
            [kCellIdentifierKey: kCellLoadingCell, kCellNibNameKey: kCellLoadingCell, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height]
        ]
    }

    private func _loadData(_ model: [PromoterEventsModel]) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        if !myGroupList.isEmpty {
            cellData.append([
                kCellIdentifierKey: kCellMyGroupCell,
                kCellTagKey: kCellMyGroupCell,
                kCellObjectDataKey: myGroupList,
                kCellClassKey: MyPlusOneGroupTableViewCell.self,
                kCellHeightKey: MyPlusOneGroupTableViewCell.height
            ])
        }
        
        if !_plusOneEventList.isEmpty {
            cellData.append([
                kCellIdentifierKey: KPlusOneEvenIdentifier,
                kCellTagKey: KPlusOneEvenIdentifier,
                kCellObjectDataKey: _plusOneEventList,
                kCellClassKey: UserPlusOneEventTableCell.self,
                kCellHeightKey: UserPlusOneEventTableCell.height
            ])
        }
                 
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        cellData.removeAll()

        if isLoadingMyEvent {
            cellData.append([
                kCellIdentifierKey: kCellLoadingCell,
                kCellTagKey: kCellLoadingCell,
                kCellObjectDataKey: "loading",
                kCellClassKey: LoadingCell.self,
                kCellHeightKey: LoadingCell.height
            ])
        } else {
            let groupedEvents = groupEventsByVenue(model)
            for (index, eventByVenue) in groupedEvents.enumerated() {
                cellData.append([
                    kCellIdentifierKey: kCellMyList,
                    kCellTagKey: index == 0,
                    kCellObjectDataKey: eventByVenue,
                    kCellClassKey: CMEventListCell.self,
                    kCellHeightKey: CMEventListCell.height
                ])
            }
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    private func setSectionTitle() -> String {
        if _status == "Events I’m In" {
            return "Events I'm In"
        } else if _status == "Pending Events" {
            return "Pending (Waiting admin approval)"
        } else if _status == "On My List" {
            return "Event's On my list"
        } else if _status == "Public Events" {
            return "Public Event"
        }
        return kEmptyString
    }

    private func _normalUserLoadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()

        cellData.append([
            kCellIdentifierKey: kCellMyGroupCell,
            kCellTagKey: kCellMyGroupCell,
            kCellObjectDataKey: myGroupList,
            kCellClassKey: MyPlusOneGroupTableViewCell.self,
            kCellHeightKey: MyPlusOneGroupTableViewCell.height
        ])
        
        if APPSESSION.userDetail?.adminStatusOnPlusOne == "accepted" {
            if !_plusOneEventList.isEmpty {
                cellData.append([
                    kCellIdentifierKey: KPlusOneEvenIdentifier,
                    kCellTagKey: KPlusOneEvenIdentifier,
                    kCellObjectDataKey: _plusOneEventList,
                    kCellClassKey: UserPlusOneEventTableCell.self,
                    kCellHeightKey: UserPlusOneEventTableCell.height
                ])
            }
        }

        
//        cellData.append([
//            kCellIdentifierKey: String(describing: MyOutingTableCell.self),
//            kCellTagKey: String(describing: MyOutingTableCell.self),
//            kCellObjectDataKey: _outingList,
//            kCellClassKey: MyOutingTableCell.self,
//            kCellHeightKey: MyOutingTableCell.height
//        ])
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
//        cellData.removeAll()
//        
//        if _bucketList.isEmpty {
//            cellData.append([
//                kCellIdentifierKey: kEmptyCellIdentifier,
//                kCellTagKey: kEmptyCellIdentifier,
//                kCellObjectDataKey: ["type": "Invitations","title" : "Bucket list looking a bit empty? Toss in some vouchers and kickstart those adventures", "icon": "empty_bucket"],
//                kCellClassKey: EmptyDataCell.self,
//                kCellHeightKey: EmptyDataCell.height
//            ])
//        } else {
//            _bucketList.forEach { BucketDetailModel in
//                cellData.append([
//                    kCellIdentifierKey: kCellIdentifierVenueDetail,
//                    kCellTagKey: kCellIdentifierVenueDetail,
//                    kCellObjectDataKey: BucketDetailModel,
//                    kCellClassKey: BucketTableCell.self,
//                    kCellHeightKey: BucketTableCell.height
//                ])
//            }
//        }
//        
//        cellSectionData.append([kSectionTitleKey: "My Buckets" , kSectionRightInfoKey: "Create +",
//                           kSectionIdentifierKey: 1,
//         kSectionShowRightInforAsActionButtonKey: true,
//                       kSectionRightTextColorKey: UIColor.white,
//                        kSectionRightTextBgColor:  ColorBrand.brandGreen,
//                                 kSectionDataKey: cellData])
//        cellData.removeAll()
        _tableView.loadData(cellSectionData)
    }
    
}



// --------------------------------------
// MARK: TableView Delegate
// --------------------------------------

extension MyActionVC: CustomNoKeyboardTableViewDelegate, UITableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? CMEventListCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [PromoterEventsModel], let showTitle = cellDict?[kCellTagKey] as? Bool else { return }
            cell._promoterView.isHidden = true
            cell.setupData(object, cellTitle: setSectionTitle(), showtitle: showTitle)
        } else if let cell = cell as? BucketTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? BucketDetailModel else { return }
            cell.setupData(object)
        } else if let cell = cell as? MyOutingTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [OutingListModel] else { return }
            cell.setupData(object, "invitations".localized())
        } else if let cell = cell as? UserPlusOneEventTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [PromoterEventsModel] else { return }
            cell.setupData(object)
        } else if let cell = cell as? EmptyDataCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [String:Any] else { return }
            cell.setupData(object)
        } else if let cell = cell as? MyPlusOneGroupTableViewCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [UserDetailModel] else { return }
            cell.setupData(object, isNormal: true)
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if APPSESSION.userDetail?.isRingMember == true {
            if headerView == nil {
                headerView = CMEventStatusHeaderView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 56))
            }
            updateHeaderViewData()
            return headerView
        } else {
            return  nil
        }
    }
    
    private func updateHeaderViewData() {
        guard let headerView = headerView else { return }
        headerView.setData(_eventList)
        headerView.callback = { [weak self] status in
            guard let self = self else { return }
            self._status = status
            self._loadData(self.eventList)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if APPSESSION.userDetail?.isRingMember == true {
            return section == 0 ? 0.0 : 56.0
        } else {
            return 0.0
        }
    }
    
    func handleHeaderActionEvent(section: Int, identifier: Int) {
        if section == 1 {
            let presentedViewController = INIT_CONTROLLER_XIB(CreateBucketBottomSheet.self)
            presentAsPanModal(controller: presentedViewController)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScroll(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        didEndDecelerating(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        didEndDragging(scrollView, willDecelerate: decelerate)
    }
    
}
