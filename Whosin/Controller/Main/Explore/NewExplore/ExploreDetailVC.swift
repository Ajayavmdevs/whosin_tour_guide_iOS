import UIKit

class ExploreDetailVC: BaseViewController {

    @IBOutlet private weak var _tableView: CustomTableView!
    @IBOutlet private weak var collectionView: CustomCollectionView!
    @IBOutlet weak var _visualEffectView: UIVisualEffectView!
    @IBOutlet weak var _titleLabel: CustomLabel!
    @IBOutlet weak var _collecitonHeight: NSLayoutConstraint!
    private let kCellIdentifierSingleVideo = String(describing: SingleVideoTableCell.self)
    private let kCellIdentifierTicket = String(describing: ExploreTicketTableCell.self)
    private let kCellIdentifierHeader = String(describing: SearchHeaderCollectionCell.self)
    private let kEmptyCellIdentifier = String(describing: EmptyDataCell.self)
    private let kCellIdentifier = String(describing: DaysCollectionCell.self)
    private var _visibleVideoCell: SingleVideoTableCell?
    private var footerView: LoadingFooterView?
    private var _ticketList: [TicketModel] = []
    private var _emptyData = [[String:Any]]()
    private var _topMenuOptions: [CommonSettingsModel] = []
    private var _tabs:[String] = []
    private var selectedIndexs: [Int] = []
    private var selectedIds: [String] = []
    private var _page : Int = 1
    private var isPaginating = false
    public var isFromCities: Bool = false
    public var selectedFilter: String = kEmptyString
    public var titleText: String = kEmptyString


    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        _titleLabel.text = titleText
        setupUi()
        NotificationCenter.default.addObserver(self, selector: #selector(enterBackGround), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enterForGround), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("Home VC Disapper")
        self.pauseVideoWhenDisappear()
    }
    
    func pauseVideoWhenDisappear() {
        if self._tableView == nil { return }
        self._tableView.setContentOffset(_tableView.contentOffset, animated: false)
        DISPATCH_ASYNC_MAIN {
            self._tableView.visibleCells.forEach { cell in
                if cell is SingleVideoTableCell {
                    (cell as? SingleVideoTableCell)?.pauseVideo()
                }
            }
        }
    }


    override func setupUi() {
        hideNavigationBar()
        showHUD()
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
        collectionView.backgroundColor = .clear
        collectionView.clipsToBounds = true
        collectionView.setup(cellPrototypes: prototype,
                             hasHeaderSection: false,
                             enableRefresh: false,
                             columns: 5,
                             rows: 1,
                             edgeInsets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10),
                             spacing: CGSize(width: 3, height: 3),
                             scrollDirection: .horizontal,
                             emptyDataText: nil,
                             emptyDataIconImage: nil,
                             delegate: self)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false

        _tableView.proxyDelegate = self
        _visualEffectView.alpha = 0.0
        footerView = LoadingFooterView(frame: CGRect(x: 0, y: 0, width: _tableView.bounds.width, height: 44))
        _tableView.tableFooterView = footerView
        if isFromCities {
            _tabs = APPSETTING.exploreCategories?.map({ $0.title }) ?? []
        } else {
            _tabs = APPSETTING.cityList?.map({ $0.name }) ?? []
        }
        _requestSearch()
        emptyData()
    }
    
    private var prototype: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: String(describing: DaysCollectionCell.self), kCellClassKey: DaysCollectionCell.self, kCellHeightKey: DaysCollectionCell.height]]
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------

    private func _requestSearch(_ showLoader: Bool = true) {
        if showLoader { showHUD() }
        WhosinServices.raynaTicketList(page: _page, cities: isFromCities ? [selectedFilter] : selectedIds, categories: isFromCities ? selectedIds : [selectedFilter]) { [weak self] containers, error in
            guard let self = self else { return }
            self._tableView.endRefreshing()
            self.hideHUD()
            guard let data = containers?.data else { return }
            self.isPaginating = data.isEmpty
            self.footerView?.stopAnimating()
            if _page == 1 {
                self._ticketList = data
            }else {
                self._ticketList.append(contentsOf: data)
            }
            _loadDataTabs()
            self._loadData()
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _loadDataTabs() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()

        _tabs.forEach { day in
            var cellDict: [String: Any] = [
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellTitleKey: false,
                kCellObjectDataKey: day,
                kCellClassKey: DaysCollectionCell.self,
                kCellHeightKey: DaysCollectionCell.height
            ]
            cellData.append(cellDict)
        }
        _collecitonHeight.constant = cellData.count == 0 ? 0 : 60
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        collectionView.loadData(cellSectionData)
    }

    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
            
            if _ticketList.isEmpty {
                cellData.append([
                    kCellIdentifierKey: kEmptyCellIdentifier,
                    kCellTagKey: _emptyData.first!,
                    kCellObjectDataKey: _emptyData.first!,
                    kCellClassKey: EmptyDataCell.self,
                    kCellHeightKey: EmptyDataCell.height
                ])
            } else {
                _ticketList.forEach { model in
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifierTicket,
                        kCellTagKey: kCellIdentifierTicket,
                        kCellAllowCacheKey: false,
                        kCellObjectDataKey: model,
                        kCellClassKey: ExploreTicketTableCell.self,
                        kCellHeightKey: ExploreTicketTableCell.height
                    ])
                }
            }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    @objc private func enterBackGround() {
        _visibleVideoCell?.pauseVideo()
    }
    
    @objc private func enterForGround() {
        _visibleVideoCell?.resumeVideo()
    }
    
    private func emptyData() {
        _emptyData.append(["type": "invitations".localized(),"title" : "empty_explore_page".localized(), "icon": "empty_explore"])
    }
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kEmptyCellIdentifier, kCellNibNameKey: kEmptyCellIdentifier, kCellClassKey: EmptyDataCell.self, kCellHeightKey: EmptyDataCell.height],
            [kCellIdentifierKey: kCellIdentifierSingleVideo, kCellNibNameKey: kCellIdentifierSingleVideo, kCellClassKey: SingleVideoTableCell.self, kCellHeightKey: SingleVideoTableCell.height],
            [kCellIdentifierKey: kCellIdentifierTicket, kCellNibNameKey: kCellIdentifierTicket, kCellClassKey: ExploreTicketTableCell.self, kCellHeightKey: ExploreTicketTableCell.height],
        ]
    }

    @IBAction func _handleBackEvent(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}

extension ExploreDetailVC: CustomTableViewDelegate, UIScrollViewDelegate, UITableViewDelegate  {
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
        
        DISPATCH_ASYNC_MAIN {
            self.playPauseVideoIfVisible()
        }

        let scrollViewContentHeight = scrollView.contentSize.height
        let scrollOffsetThreshold = scrollViewContentHeight - scrollView.bounds.height
        if scrollView.contentOffset.y > scrollOffsetThreshold && !isRequesting {
            performPagination()
        }
    }

    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        cell.selectionStyle = .none
        if let cell = cell as? EmptyDataCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [String:Any] else { return }
            cell.setupData(object)
        } else if let cell = cell as? ExploreTicketTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? TicketModel else { return }
            cell.setUpdata(object)
        } 
    }
    
    func refreshData() {
        _requestSearch()
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? ExploreTicketTableCell, let object = cellDict?[kCellObjectDataKey] as? TicketModel else { return }
        let vc = INIT_CONTROLLER_XIB(CustomTicketDetailVC.self)
        vc.ticketID = object._id
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    private func performPagination() {
        guard !isPaginating else { return }
        if _ticketList.count > 0 {
            if _ticketList.count % 10 == 0 {
                isPaginating = true
                _page += 1
                footerView?.startAnimating()
                _requestSearch(false)
            }
        }
    }
    
    func playPauseVideoIfVisible() {
        self._tableView.visibleCells.forEach { cell in
            if cell is SingleVideoTableCell {
                guard let indexPath = self._tableView.indexPath(for: cell) else { return }
                let cellRect = self._tableView.rectForRow(at: indexPath)
                if let superview = self._tableView.superview {
                    let convertedRect = self._tableView.convert(cellRect, to:superview)
                    let intersect = self._tableView.frame.intersection(convertedRect)
                    let visibleHeight = intersect.height
                    let cellHeight = cellRect.height
                    let ratio = visibleHeight / cellHeight
                    if ratio <= 0.22 {
                        (cell as? SingleVideoTableCell)?.pauseVideo()
                    } else {
                        if (cell as? SingleVideoTableCell)?._replyView.isHidden == true {
                            (cell as? SingleVideoTableCell)?.resumeVideo()
                        }
                    }
                }
            }
        }
    }
}


extension ExploreDetailVC: CustomCollectionViewDelegate, UICollectionViewDelegate, DaysCollectionCellDelegate {
    func closeButtonTapped(_ day: String) {
    }
        
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? DaysCollectionCell {
            guard let object = cellDict?[kCellObjectDataKey] as? String, let isFromExplore = cellDict?[kCellTitleKey] as? Bool else { return }
            if selectedIndexs.contains(indexPath.row) {
                cell._bgView.backgroundColor = ColorBrand.brandPink
            } else {
                cell._bgView.backgroundColor = ColorBrand.white.withAlphaComponent(0.13)
            }
            cell.setUpdata(object)
            cell._closeBtn.isHidden = true
            cell.delegate = self
        }
    }

    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        if let isFromExplore = cellDict?[kCellTitleKey] as? Bool, isFromExplore {
            let currentDay = _tabs[indexPath.row]
            let currentDayWidth = currentDay.widthOfString(usingFont: FontBrand.SFsemiboldFont(size: 16))

            return CGSize(width: currentDayWidth + 50, height:DaysCollectionCell.height)
        } else {
            let currentDay = _tabs[indexPath.row]
            let currentDayWidth = currentDay.widthOfString(usingFont: FontBrand.SFsemiboldFont(size: 16))
            
            return CGSize(width: currentDayWidth + 26, height:DaysCollectionCell.height)
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? String else { return }
        if isFromCities {
            guard let category = APPSETTING.exploreCategories,
                  let matchedCategory = category.first(where: { $0.title.lowercased() == object.lowercased() }) else { return }
            if let selectedIndex = selectedIds.firstIndex(of: matchedCategory.id) {
                selectedIds.remove(at: selectedIndex)
                self.selectedIndexs.remove(at: selectedIndex)
            } else {
                selectedIds.append(matchedCategory.id)
                selectedIndexs.append(indexPath.row)
            }
        } else {
            guard let cityList = APPSETTING.cityList,
                  let matchedCity = cityList.first(where: { $0.name.lowercased() == object.lowercased() }) else { return }
            if let selectedIndex = selectedIds.firstIndex(of: matchedCity.id) {
                selectedIds.remove(at: selectedIndex)
                selectedIndexs.remove(at: selectedIndex)
            } else {
                selectedIds.append(matchedCity.id)
                selectedIndexs.append(indexPath.row)
            }
        }
        _requestSearch()
        collectionView.reload()
    }
}

