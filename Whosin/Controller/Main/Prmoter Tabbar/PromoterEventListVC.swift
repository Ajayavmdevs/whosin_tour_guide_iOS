import UIKit
import Alamofire
import IQKeyboardManagerSwift

class PromoterEventListVC: ChildViewController {

    @IBOutlet weak var _userImg: UIImageView!
    @IBOutlet weak var _promoterName: CustomLabel!
    @IBOutlet weak var _visualEffectView: UIVisualEffectView!
    @IBOutlet weak var _tableView: CustomTableView!
    private let kCellIdentifierMyEvents = String(describing: MyEventsTableCell.self)
    private let kEmptyCellIdentifier = String(describing: EmptyDataCell.self)
    private var _promoterModel: PromoterProfileModel? = APPSESSION.promoterProfile
    private var _myEventsList: [PromoterEventsModel] = []
    private var _page: Int = 1
    private var isPaginating = false
    private var footerView: LoadingFooterView?
    private var refreshControl = UIRefreshControl()
    private var filterType: Int = 0
    @IBOutlet weak var _eventSearchView: UIView!
    @IBOutlet weak var _eventSearchBar: UISearchBar!
    @IBOutlet weak var _searchHeight: NSLayoutConstraint!
    @IBOutlet weak var _tabView: UIView!
    public var delegate: CloseTabbarDelegate?
    private var _dataRequest: DataRequest?
    private var _spinerView: UIView?

    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
        setupUi()
        NotificationCenter.default.addObserver(self, selector: #selector(handleReloadMyEvent(_:)), name: .reloadMyEventsNotifier, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePushReload), name: .changereloadNotificationUpdateState, object: nil)
    }
    
    override func setupUi() {
        _visualEffectView.alpha = 1
        _promoterName.alpha = 1
        _userImg.alpha = 1
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "empty_promoter_detail".localized(),
            emptyDataIconImage: UIImage(named: "empty_explore"),
            emptyDataDescription: nil,
            delegate: self)
        _tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        footerView = LoadingFooterView(frame: CGRect(x: 0, y: 0, width: _tableView.bounds.width, height: 44))
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        refreshControl.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        _tableView.refreshControl = refreshControl
        _tableView.tableFooterView = footerView
        _tableView.proxyDelegate = self
        _eventSearchBar.delegate = self
        _eventSearchBar.searchTextField.backgroundColor = UIColor(white: 1, alpha: 0.08)
        _eventSearchBar.searchTextField.layer.cornerRadius = 18
        _eventSearchBar.searchTextField.layer.masksToBounds = true
        _eventSearchBar.searchTextField.textColor = .white

        setupTabs()
        _requestMyEvents()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
        IQKeyboardManager.shared.enable = true
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func setupTabs() {
        let headerView = CustomHeaderView(buttonTitles: ["Last Added", "Starting Soon"])
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.setUpSelected(filterType)
        headerView.delegate = self

        _tabView.addSubview(headerView)

        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: _tabView.leadingAnchor),
            headerView.trailingAnchor.constraint(lessThanOrEqualTo: _tabView.trailingAnchor),
            headerView.centerYAnchor.constraint(equalTo: _tabView.centerYAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierMyEvents, kCellNibNameKey: kCellIdentifierMyEvents, kCellClassKey: MyEventsTableCell.self, kCellHeightKey: MyEventsTableCell.height],
            [kCellIdentifierKey: kEmptyCellIdentifier, kCellNibNameKey: kEmptyCellIdentifier, kCellClassKey: EmptyDataCell.self, kCellHeightKey: EmptyDataCell.height]
        ]
    }
    
    private func _loadData(isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        _promoterName.text = _promoterModel?.profile?.fullName
        _userImg.loadWebImage(_promoterModel?.profile?.image  ?? kEmptyString, name: _promoterModel?.profile?.fullName ?? kEmptyString)
        
        if _myEventsList.isEmpty {
            cellData.append([
                kCellIdentifierKey: kEmptyCellIdentifier,
                kCellTagKey: kEmptyCellIdentifier,
                kCellObjectDataKey: ["title" : "empty_event_list".localized(), "icon": "empty_event"],
                kCellClassKey: EmptyDataCell.self,
                kCellHeightKey: EmptyDataCell.height
            ])
        } else {
            _myEventsList.forEach({ model in
                if model.status != "cancelled" && model.status != "completed" {
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifierMyEvents,
                        kCellTagKey: kCellIdentifierMyEvents,
                        kCellObjectDataKey: model,
                        kCellClassKey: MyEventsTableCell.self,
                        kCellHeightKey: MyEventsTableCell.height
                    ])
                }
            })
        }
        cellSectionData.append([kSectionTitleKey: " ", kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
        
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestMyEvents(_ isLoadData: Bool = false, searchText: String = kEmptyString, sortBy: String = kEmptyString) {
        
        if let request = _dataRequest {
            if !request.isCancelled || !request.isFinished || !request.isSuspended {
                request.cancel()
            }
        }
        if !isLoadData {
            if _spinerView == nil {
                if let spinerView = getHudView() {
                    self._spinerView = spinerView
                    spinerView.frame =  CGRect(x: (kScreenWidth/2)-25, y: 275, width: 50, height: 50)
                    self.view.addSubview(spinerView)
                    self._tableView.isHidden = true
                }
            }
        }
        _dataRequest = WhosinServices.getMyEventsListNew(page: _page, search: searchText, sortBy: sortBy) { [weak self] container, error in
            guard let self = self else { return }
            if error?.localizedDescription == "Request explicitly cancelled." {
                return
            }
            self.hideHUD(error: error)
            self.refreshControl.endRefreshing()
            self._spinerView?.removeFromSuperview()
            self._spinerView = nil
            self._tableView.isHidden = false
            guard let data = container?.data else { return }
            self.isPaginating = data.events.isEmpty
            self.footerView?.stopAnimating()
            if self._page == 1 {
                self._myEventsList = data.events.toArrayDetached(ofType: PromoterEventsModel.self)
            } else {
                self._myEventsList.append(contentsOf: data.events.toArrayDetached(ofType: PromoterEventsModel.self))
            }
            self._loadData()
        }
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
    private func fetchData(completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion()
        }
    }
    
    @objc private func refreshData(_ sender: Any) {
        fetchData {
            DispatchQueue.main.async {
                    self._page = 1
                    self._requestMyEvents(true)
                }
            }
        }
    
    @objc func handleReloadMyEvent(_ notification: Notification) {
        self._page = 1
        _requestMyEvents(true)
    }
    
    @objc func handlePushReload() {
        _requestMyEvents(true)
    }
    
    @IBAction func _handleCloseEvent(_ sender: Any) {
        delegate?.close()
    }
    
    @IBAction func _handleShareEvent(_ sender: Any) {
        _generateDynamicLinks()
    }
    
    private func  _generateDynamicLinks() {
        guard let controller = parent else { return }
        guard let user = _promoterModel?.profile else {
            return
        }
        let shareMessage = "\(user.fullName) \n\n\(user.bio) \n\n\("https://explore.whosin.me/u/\(user.userId)")"
        let items = [shareMessage]
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityController.setValue(kAppName, forKey: "subject")
        activityController.popoverPresentationController?.sourceView = controller.view
        activityController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToTwitter]
        controller.present(activityController, animated: true, completion: nil)
    }
}


// --------------------------------------
// MARK: Delegate methods
// --------------------------------------

extension PromoterEventListVC: CustomTableViewDelegate, UIScrollViewDelegate, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let distanceToBottom = scrollView.contentSize.height - offsetY - scrollView.frame.size.height
        if distanceToBottom < 50 && !isPaginating { performPagination() }
    }

    private func performPagination() {
        guard !isPaginating, _myEventsList.count % 10 == 0 else { return }
        isPaginating = true
        _page += 1
        footerView?.startAnimating()
        _requestMyEvents(true)
    }
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? EmptyDataCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [String:Any] else { return }
            cell.setupData(object)
        } else if let cell = cell as? MyEventsTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? PromoterEventsModel, let type = cellDict?[kCellTagKey] as? String else { return}
                cell.setupData(object)
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? MyEventsTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? PromoterEventsModel else { return}
            let vc = INIT_CONTROLLER_XIB(PromoterEventDetailVC.self)
            vc.eventModel = object
            vc.id = object.id
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension PromoterEventListVC: CustomPromoterEventDelegate {
    func didTapButton(at index: Int) {
        filterType = index
        _page = 1
        _requestMyEvents(searchText: _eventSearchBar.text ?? kEmptyString, sortBy: filterType == 1 ? "startingSoon" : kEmptyString)
        _tableView.scrollToTop()
    }
}

extension PromoterEventListVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        _page = 1
        _requestMyEvents(searchText: searchText)
    }
}
