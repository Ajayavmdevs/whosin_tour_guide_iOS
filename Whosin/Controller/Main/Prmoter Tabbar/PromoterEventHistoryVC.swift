import UIKit
import Alamofire
import IQKeyboardManagerSwift

class PromoterEventHistoryVC: ChildViewController {
    
    @IBOutlet weak var _userImg: UIImageView!
    @IBOutlet weak var _tableView: CustomTableView!
    @IBOutlet weak var _promoterName: CustomLabel!
    @IBOutlet weak var _visualEffectView: UIVisualEffectView!
    @IBOutlet weak var _eventHisSearchView: UIView!
    @IBOutlet weak var _eventHisSearchBar: UISearchBar!
    @IBOutlet weak var _searchHeight: NSLayoutConstraint!
    public var delegate: CloseTabbarDelegate?
    private var _dataRequest: DataRequest?
    private var _spinerView: UIView?
    private let kCellIdentifierMyEvents = String(describing: MyEventsTableCell.self)
    private let kEmptyCellIdentifier = String(describing: EmptyDataCell.self)
    private var _promoterModel: PromoterProfileModel? = APPSESSION.promoterProfile
    private var _eventHistory: [PromoterEventsModel] = []
    private var _page: Int = 1
    private var isPaginating = false
    private var footerView: LoadingFooterView?
    private var refreshControl = UIRefreshControl()


    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
//        showHUD()
        setupUi()
        NotificationCenter.default.addObserver(self, selector: #selector(handleReloadMyEvent(_:)), name: .reloadMyEventsNotifier, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
        IQKeyboardManager.shared.enable = true
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
        _eventHisSearchBar.searchTextField.backgroundColor = UIColor(white: 1, alpha: 0.08)
        _eventHisSearchBar.searchTextField.layer.cornerRadius = 18
        _eventHisSearchBar.searchTextField.layer.masksToBounds = true
        _eventHisSearchBar.searchTextField.textColor = .white
        _requestEventHistory()
    }
    
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
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
        
        _eventHisSearchView.isHidden = false
        _searchHeight.constant = 60
        _eventHisSearchBar.delegate = self
        _eventHisSearchBar.placeholder = "find_event".localized()
        
        if _eventHistory.isEmpty {
            cellData.append([
                kCellIdentifierKey: kEmptyCellIdentifier,
                kCellTagKey: "history",
                kCellObjectDataKey: ["title" : "empty_event_history_vc".localized(), "icon": "empty_history"],
                kCellClassKey: EmptyDataCell.self,
                kCellHeightKey: EmptyDataCell.height
            ])
        } else {
            let sortedEventHistory = _eventHistory.sorted {
                ($0.lastExpiredEvents ?? Date.distantPast) > ($1.lastExpiredEvents ?? Date.distantPast)
            }
            sortedEventHistory.forEach({ model in
                if model.status == "cancelled" || model.status == "completed" {
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifierMyEvents,
                        kCellTagKey: "history",
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
    
    private func _requestEventHistory(_ isLoadData: Bool = false, searchText: String = kEmptyString) {
        
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
        
        _dataRequest = WhosinServices.getEventsHistory(page: _page, search: searchText) { [weak self] container, error in
            guard let self = self else { return }
            if error?.localizedDescription == "Request explicitly cancelled." {
                return
            }
            self.refreshControl.endRefreshing()
            self.hideHUD(error: error)
            self._spinerView?.removeFromSuperview()
            self._spinerView = nil
            self._tableView.isHidden = false
            guard let data = container?.data else { return }
            self.isPaginating = data.isEmpty
            self.footerView?.stopAnimating()
            if self._page == 1 {
                self._eventHistory = data
            } else {
                self._eventHistory.append(contentsOf: data)
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
                self._requestEventHistory(true)
            }
        }
    }
    
    @objc func handleReloadMyEvent(_ notification: Notification) {
        self._page = 1
        _requestEventHistory(true)
    }
    
    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        delegate?.close()
    }
    
    @IBAction private func _handleShareEvent(_ sender: Any) {
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

extension PromoterEventHistoryVC: CustomTableViewDelegate, UIScrollViewDelegate, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let screenHeight = scrollView.frame.size.height

        let distanceToBottom = contentHeight - offsetY - screenHeight

        let paginationThreshold: CGFloat = 50.0

        if distanceToBottom < paginationThreshold && !isPaginating {
            performPagination()
        }
    }
    
    private func performPagination() {
        guard !isPaginating, _eventHistory.count % 10 == 0 else { return }
        isPaginating = true
        _page += 1
        footerView?.startAnimating()
        _requestEventHistory(true)
    }

    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? EmptyDataCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [String:Any] else { return }
            cell.setupData(object)
        } else if let cell = cell as? MyEventsTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? PromoterEventsModel, let type = cellDict?[kCellTagKey] as? String else { return}
            if type == "history" {
                cell.setupHistoryData(object)
                cell.callback = {
                    self._requestEventHistory(true)
                }
            } else {
                cell.setupData(object)
            }
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {

    }
}

extension PromoterEventHistoryVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        _page = 1
        _requestEventHistory(searchText: searchText)
    }
}
