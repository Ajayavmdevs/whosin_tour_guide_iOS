import UIKit

class ActivityDetailVC: ChildViewController {
    
    @IBOutlet private var _maincontainerView: GradientView!
    @IBOutlet private weak var _tableView: CustomTableView!
    @IBOutlet private weak var _title: UILabel!
    @IBOutlet private weak var _visualEffect: UIVisualEffectView!
    private var _activityModel: [ActivitiesModel] = []
    private var _bannerModel: [BannerModel] = []
    private let kCellIdentifierActivity = String(describing: CategoryHeaderTableCell.self)
    private let kCellIdentifierActivityList = String(describing: ActivityOfferTableCell.self)
    private let kEmptyCellIdentifier = String(describing: EmptyDataCell.self)
    private let kLoadingCellIdentifire = String(describing: LoadingCell.self)
    public var _selectedTypeId: String = kEmptyString
    private var _page : Int = 1
    private var isPaginating = false
    var headerView: CustomTypeHeaderView?
    private var _emptyData = [[String:Any]]()
    private var footerView: LoadingFooterView?

    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _requestBannerList()
        setupUi()
    }
    
    override func setupUi() {
        hideNavigationBar()
        _title.text = "our_activities".localized()
        footerView = LoadingFooterView(frame: CGRect(x: 0, y: 0, width: _tableView.bounds.width, height: 44))
        _tableView.tableFooterView = footerView
        _selectedTypeId = APPSETTING.activityTypes.first?.id ?? kEmptyString
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: true,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "There is no activity detail available",
            emptyDataIconImage: UIImage(named: "empty_event"),
            emptyDataDescription: kEmptyString,
            delegate: self)
        _visualEffect.alpha = 0
        _tableView.proxyDelegate = self
        _loadData(isLoading: true)
        _activityModel.removeAll()
        _emptyData.append(["title" : "upcoming activity looking a bit empty?!", "icon": "empty_event"])
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestBannerList() {
        WhosinServices.activityBannerList { [weak self] container, error in
            guard let self = self else { return }
            guard let data = container?.data else { return }
            self._bannerModel = data
            self._loadData(isLoading: true)
            self._requestActivityList()
        }
    }
    
    private func _requestActivityList() {
        WhosinServices.activityList(type: _selectedTypeId, page: _page) { [weak self] container, error in
            guard let self = self else { return }
            self.footerView?.stopAnimating()
            guard let data = container?.data else { return }
            if data.count >= 10 {
                self.isPaginating = false
            }
            self._activityModel.append(contentsOf: data)
            DISPATCH_ASYNC_MAIN {
                self._loadData(isLoading: false)
                self.isPaginating = false
            }
        }
        
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _loadData(isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
            cellData.append([
                kCellIdentifierKey: kCellIdentifierActivity,
                kCellTagKey: kCellIdentifierActivity,
                kCellObjectDataKey: _bannerModel,
                kCellClassKey: CategoryHeaderTableCell.self,
                kCellHeightKey: CategoryHeaderTableCell.height
            ])
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        cellData.removeAll()
        
        if isLoading {
            cellData.append([
                kCellIdentifierKey: kLoadingCellIdentifire,
                kCellTagKey: kLoadingCellIdentifire,
                kCellObjectDataKey: _activityModel,
                kCellClassKey: LoadingCell.self,
                kCellHeightKey: LoadingCell.height
            ])
        } else {
            if !_activityModel.isEmpty {
                _activityModel.forEach { activitiesModel in
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifierActivityList,
                        kCellTagKey: activitiesModel.id,
                        kCellObjectDataKey: activitiesModel,
                        kCellClassKey: ActivityOfferTableCell.self,
                        kCellHeightKey: ActivityOfferTableCell.height
                    ])
                }
            } else {
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
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierActivity, kCellNibNameKey: kCellIdentifierActivity, kCellClassKey: CategoryHeaderTableCell.self, kCellHeightKey: CategoryHeaderTableCell.height],
            [kCellIdentifierKey: kCellIdentifierActivityList, kCellNibNameKey: kCellIdentifierActivityList, kCellClassKey: ActivityOfferTableCell.self, kCellHeightKey: ActivityOfferTableCell.height],
            [kCellIdentifierKey: kLoadingCellIdentifire, kCellNibNameKey: kLoadingCellIdentifire, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height],
            [kCellIdentifierKey: kEmptyCellIdentifier, kCellNibNameKey: kEmptyCellIdentifier, kCellClassKey: EmptyDataCell.self, kCellHeightKey: EmptyDataCell.height]]
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

// --------------------------------------
// MARK: CustomTabbleView Delegate 
// --------------------------------------

extension ActivityDetailVC: CustomTableViewDelegate, UITableViewDelegate, UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        let threshold: CGFloat = 20
        if yOffset > threshold {
            UIView.animate(withDuration: 0.50, animations: { [weak self] in
                guard let self = self else { return }
                self._visualEffect.alpha = 1.0
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.50, animations: { [weak self] in
                guard let self = self else { return }
                self._visualEffect.alpha = 0.0
            }, completion: nil)
        }
        
        let scrollViewContentHeight = scrollView.contentSize.height
        let scrollOffsetThreshold = scrollViewContentHeight - scrollView.bounds.height * 0.8
        
        if scrollView.contentOffset.y > scrollOffsetThreshold && !isPaginating {
            performPagination()
        }
    }
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? CategoryHeaderTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [BannerModel] else { return }
            cell.setupData(object)
        } else if let cell = cell as? ActivityOfferTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? ActivitiesModel else { return }
            cell.setupData(object)
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        } else if let cell = cell as? EmptyDataCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [String: Any] else { return }
            cell.setupData(object)
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? ActivityOfferTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? ActivitiesModel else { return }
            let vc = INIT_CONTROLLER_XIB(ActivityInfoVC.self)
            vc.activityId = object.id
            vc.activityName = object.name
            navigationController?.pushViewController(vc, animated: true)        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 60: 0
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if headerView == nil {
            headerView = CustomTypeHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 60))
            headerView?.delegate = self
            headerView?.setupData(APPSETTING.activityTypes, selectedTypeId: _selectedTypeId)
            headerView?.backgroundColor = ColorBrand.BrandgradientLightBlack
        }
        return headerView
    }
    
    private func performPagination() {
        guard !isPaginating else { return }
        isPaginating = true
        footerView?.startAnimating()
        _page += 1
        _requestActivityList()
    }
}

extension ActivityDetailVC: CustomTypeHeaderViewDelegate {
    func didSelectType(_ id: String) {
        _selectedTypeId = id
        _page = 1
        _activityModel.removeAll()
        _tableView.reload()
        _requestActivityList()
    }
}
