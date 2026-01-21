import UIKit
import IQKeyboardManagerSwift

class PromoterNotificationsVC: ChildViewController {
    
    @IBOutlet weak var _userImg: UIImageView!
    @IBOutlet weak var _tableView: CustomTableView!
    @IBOutlet weak var _promoterName: CustomLabel!
    @IBOutlet weak var _visualEffectView: UIVisualEffectView!
    private let kCellIdentifierEventRequest = String(describing: EventRequestTableCell.self)
    private let kCellIdentifierUserRequest = String(describing: PromoterUserRequestTableCell.self)
    private let kEmptyCellIdentifier = String(describing: EmptyDataCell.self)
    private let kCellIdentifierLoading = String(describing: LoadingCell.self)
    private var _notificationType: String = "users"
    private var _promoterModel: PromoterProfileModel? = APPSESSION.promoterProfile
    private var _page: Int = 1
    private var isPaginating = false
    private var footerView: LoadingFooterView?
    private var _userNotifications: [NotificationModel] = []
    private var _eventNotification: [NotificationModel] = []
    private var refreshControl = UIRefreshControl()
    private var isLoadingNotification: Bool = false
    var filteredNotifications: [NotificationModel] = []
    private var isSearching: Bool = false
    private var isApplyFilter: Bool = false
    private var _selectedFilter: String = "All"
    var searchTimer: Timer?
    private var promoterNotificationHeaderView = CustomNotificationHeaderView()
    public var delegate: CloseTabbarDelegate?
    private var _spinerView: UIView?
    private var statusUpdateActivityIndicator: UIActivityIndicatorView?

    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
        setupUi()
        NotificationCenter.default.addObserver(self, selector: #selector(handleReloadEventNotification(_:)), name: .reloadEventNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleReloadUserNotification(_:)), name: .reloadUsersNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePushReload), name: .changereloadNotificationUpdateState, object: nil)
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
        _requestUserNoftification()
        _requestEventNoftification()
    }
    
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierEventRequest, kCellNibNameKey: kCellIdentifierEventRequest, kCellClassKey: EventRequestTableCell.self, kCellHeightKey: EventRequestTableCell.height],
            [kCellIdentifierKey: kCellIdentifierUserRequest, kCellNibNameKey: kCellIdentifierUserRequest, kCellClassKey: PromoterUserRequestTableCell.self, kCellHeightKey: PromoterUserRequestTableCell.height],
            [kCellIdentifierKey: kEmptyCellIdentifier, kCellNibNameKey: kEmptyCellIdentifier, kCellClassKey: EmptyDataCell.self, kCellHeightKey: EmptyDataCell.height],
            [kCellIdentifierKey: kCellIdentifierLoading, kCellNibNameKey: kCellIdentifierLoading, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height],
        ]
    }
    
    private func showActivityIndicator() {
        if statusUpdateActivityIndicator == nil {
            statusUpdateActivityIndicator = UIActivityIndicatorView(style: .medium)
            statusUpdateActivityIndicator?.color = .gray
            statusUpdateActivityIndicator?.translatesAutoresizingMaskIntoConstraints = false
            _tableView.addSubview(statusUpdateActivityIndicator!)

            NSLayoutConstraint.activate([
                statusUpdateActivityIndicator!.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                statusUpdateActivityIndicator!.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 160)
            ])
        }
        statusUpdateActivityIndicator?.startAnimating()
    }

    private func hideActivityIndicator() {
        statusUpdateActivityIndicator?.stopAnimating()
        statusUpdateActivityIndicator?.removeFromSuperview()
        statusUpdateActivityIndicator = nil
    }
    
    private func appendEmptyNotificationCell(message: String) -> [String: Any] {
        return [
            kCellIdentifierKey: kEmptyCellIdentifier,
            kCellTagKey: kEmptyCellIdentifier,
            kCellObjectDataKey: ["title" : message, "icon": "empty_notification"],
            kCellClassKey: EmptyDataCell.self,
            kCellHeightKey: EmptyDataCell.height
        ]
    }

    private func appendNotificationCells(from notifications: [NotificationModel]) -> [[String: Any]] {
        return notifications.map { model in
            [
                kCellIdentifierKey: kCellIdentifierUserRequest,
                kCellTagKey: kCellIdentifierUserRequest,
                kCellObjectDataKey: model,
                kCellClassKey: PromoterUserRequestTableCell.self,
                kCellHeightKey: PromoterUserRequestTableCell.height
            ]
        }
    }

    private func _loadData(isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        _promoterName.text = _promoterModel?.profile?.fullName
        _userImg.loadWebImage(_promoterModel?.profile?.image  ?? kEmptyString, name: _promoterModel?.profile?.fullName ?? kEmptyString)
        if _notificationType == "users" {
            if isSearching {
                cellData.append(contentsOf: filteredNotifications.isEmpty ?
                                [appendEmptyNotificationCell(message: "empty_user_requests".localized())] :
                    appendNotificationCells(from: filteredNotifications))
            } else {
                cellData.append(contentsOf: _userNotifications.isEmpty ?
                                [appendEmptyNotificationCell(message: "empty_user_requests".localized())] :
                    appendNotificationCells(from: _userNotifications))
            }
        } else {
            if _eventNotification.isEmpty {
                cellData.append(appendEmptyNotificationCell(message: "empty_event_requests".localized()))
            } else {
                _eventNotification.forEach { model in
                    if model.event?.status != "cancelled" && model.event?.status != "completed" {
                        cellData.append([
                            kCellIdentifierKey: kCellIdentifierEventRequest,
                            kCellTagKey: kCellIdentifierEventRequest,
                            kCellObjectDataKey: model,
                            kCellClassKey: EventRequestTableCell.self,
                            kCellHeightKey: EventRequestTableCell.height
                        ])
                    }
                }
            }
        }

        cellSectionData.append([kSectionTitleKey: " ", kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestUserNoftification(_ isReload: Bool = false) {
        if !isReload {
            if _spinerView == nil {
                if let spinerView = getHudView() {
                    self._spinerView = spinerView
                    spinerView.frame = CGRect(x: (kScreenWidth / 2) - 25, y: 275, width: 50, height: 50)
                    self.view.addSubview(spinerView)
                    self._tableView.isHidden = true
                }
            }
        }

        WhosinServices.promoterUserNotification(page: _page) { [weak self] container, error in
            guard let self = self else { return }
            self.hideActivityIndicator()
            self.refreshControl.endRefreshing()
            self.hideHUD(error: error)
            self._spinerView?.removeFromSuperview()
            self._spinerView = nil
            self._tableView.isHidden = false
            guard error == nil, let data = container?.data else { return }
            let newNotifications = data.notification.toArrayDetached(ofType: NotificationModel.self)
            if self._page == 1 {
                self._userNotifications = newNotifications
            } else {
                self._userNotifications.append(contentsOf: newNotifications.filter { notification in
                    !self._userNotifications.contains(where: { $0.id == notification.id })
                })
            }
            self.isPaginating = newNotifications.isEmpty
            self.footerView?.stopAnimating()

            self._loadData()
        }
    }

    
    private func _requestEventNoftification(_ isReload: Bool = false) {
        isLoadingNotification = !isReload
        WhosinServices.promoterEventNotification(page: _page) { [weak self] container, error in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
            self.hideHUD(error: error)
            self.isLoadingNotification = false
            guard let data = container?.data else { return }
            self.isPaginating = data.notification.isEmpty
            self.footerView?.stopAnimating()
            if self._page == 1 {
                self._eventNotification = data.notification.toArrayDetached(ofType: NotificationModel.self)
            } else {
                self._eventNotification.append(contentsOf: data.notification)
                self.refreshControl.endRefreshing()
            }
            if isReload{
                _loadData()
            }
            _loadData()
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
                    self._notificationType == "users" ? self._requestUserNoftification(true) : self._requestEventNoftification(true)
            }
        }
    }
    
    @objc func handleReloadEventNotification(_ notification: Notification) {
            _requestEventNoftification(true)
    }
    
    @objc func handleReloadUserNotification(_ notification: Notification) {
        _requestUserNoftification(true)
    }
    
    @objc func handlePushReload() {
        _requestEventNoftification()
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

extension PromoterNotificationsVC: CustomTableViewDelegate, UIScrollViewDelegate, UITableViewDelegate {
    
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
        guard !isPaginating else { return }
            if _notificationType == "users" {
                let count = _userNotifications.count
                guard count % 20 == 0 else { return }
                isPaginating = true
                _page += 1
                footerView?.startAnimating()
                _requestUserNoftification(true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    self?.isPaginating = false
                }
            }
    }
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? EmptyDataCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [String:Any] else { return }
            cell.setupData(object)
        }  else if let cell = cell as? EventRequestTableCell {
            if let object = cellDict?[kCellObjectDataKey] as? NotificationModel {
                cell.setUpData(object, isNotification: true)
            } else if let object = cellDict?[kCellObjectDataKey] as? PromoterChatListModel {
                cell.setUpChatData(object, isPromoter: true)
            }
        } else if let cell = cell as? PromoterUserRequestTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? NotificationModel else { return }
            cell.setupData(object)
            cell.updateStatusCallback = { [weak self] status in
                guard let self = self else { return }
                self.showActivityIndicator()
                self._userNotifications[indexPath.row].requestStatus = status
                _page = (indexPath.row / 30) + 1
                self._requestUserNoftification(true)
            }
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? PromoterUserRequestTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? NotificationModel else { return}
            let vc = INIT_CONTROLLER_XIB(ComplementaryPublicProfileVC.self)
            vc.complimentryId = object.typeId
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)

        }
        if let cell = cell as? EventRequestTableCell {
            if let object = cellDict?[kCellObjectDataKey] as? NotificationModel {
                let vc = INIT_CONTROLLER_XIB(PromoterEventDetailVC.self)
                vc.id = object.event?.id ?? ""
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? _notificationType == "users" ? 100 : 40 : 0
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            promoterNotificationHeaderView = CustomNotificationHeaderView(frame: CGRect(x: 0, y: 0, width: _tableView.bounds.width, height:  _notificationType == "users" ? 100 : 40))
            promoterNotificationHeaderView.setupData(selectedType: _notificationType, filter: isApplyFilter)
            promoterNotificationHeaderView.delegate = self
            promoterNotificationHeaderView.searchBar.delegate = self
            promoterNotificationHeaderView.filterBtn.addTarget(self, action: #selector(handleFilterOption), for: .touchUpInside)
            return promoterNotificationHeaderView
    }
    
    @objc func handleFilterOption() {
        let actionSheet = UIAlertController(title: "filter".localized(), message: nil, preferredStyle: .actionSheet)
        let allAction = UIAlertAction(title: "all".localized(), style: .default) { _ in
            self.applyFilter("All")
        }
        let acceptedAction = UIAlertAction(title: "accepted".localized(), style: .default) { _ in
            self.applyFilter("Accepted")
        }
        let rejectedAction = UIAlertAction(title: "rejected".localized(), style: .default) { _ in
            self.applyFilter("Rejected")
        }
        let pendingAction = UIAlertAction(title: "pending".localized(), style: .default) { _ in
            self.applyFilter("Pending")
        }
        let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil)
        actionSheet.addAction(allAction)
        actionSheet.addAction(acceptedAction)
        actionSheet.addAction(rejectedAction)
        actionSheet.addAction(pendingAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }

    func applyFilter(_ option: String) {
        _selectedFilter = option
        switch option {
        case "All":
            isApplyFilter = false
            isSearching = false
            _loadData()
            
        default:
            filteredNotifications = _userNotifications
                .filter { notification in
                    notification.requestStatus.lowercased() == option.lowercased()
                }
            isLoadingNotification = false
            isSearching = true
            isApplyFilter = true
            _loadData(isLoading: false)
        }
    }

}

extension PromoterNotificationsVC: CustomHeaderViewDelegate {
    
    func notificationType(type: String) {
        _notificationType = type
        _loadData(isLoading: false)
    }
    
    func didSelectTab(at index: Int) {
        self._tableView.scrollToTop()
        refreshData(self)
        _loadData(isLoading: false)
    }
}

extension PromoterNotificationsVC: NotificationHeaderViewDelegate {
    func didSelectType(_ type: String) {
        _notificationType = type
        _loadData(isLoading: false)
    }
}

extension PromoterNotificationsVC: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        if isSearching {
            isSearching = false
            isLoadingNotification = false
            _loadData(isLoading: false)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTimer?.invalidate()
        if !searchText.isEmpty {
            isSearching = true
            isLoadingNotification = true
            _loadData(isLoading: true)
            searchTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(performSearchWithTimer), userInfo: searchText, repeats: false)
        } else {
            isSearching = false
            isLoadingNotification = false
            if _selectedFilter != "All" {
                filteredNotifications = _userNotifications
                    .filter { notification in
                        notification.requestStatus.lowercased() == _selectedFilter.lowercased()
                    } ?? []
            }
            isApplyFilter = true
            _loadData(isLoading: false)
        }
    }
    
    @objc private func performSearchWithTimer(timer: Timer) {
        guard let searchText = timer.userInfo as? String else { return }
        performSearch(with: searchText)
    }

    func performSearch(with searchText: String) {
        if searchText.isEmpty {
            isLoadingNotification = false
            if _selectedFilter != "All" {
                filteredNotifications = _userNotifications
                    .filter { notification in
                        notification.requestStatus.lowercased() == _selectedFilter.lowercased()
                    } ?? []
                isSearching = true
                isApplyFilter = true
            }
            _loadData(isLoading: false)
        } else {
            filterResults(for: searchText)
        }
    }
    
    private func filterResults(for query: String) {
        filteredNotifications = _userNotifications
            .filter { notification in
                let titleMatches = notification.title.lowercased().contains(query.lowercased())
                
                if _selectedFilter != "All" {
                    return titleMatches && notification.requestStatus.lowercased() == _selectedFilter.lowercased()
                } else {
                    return titleMatches
                }
            } ?? []
        isLoadingNotification = false
        isSearching = true
        _loadData(isLoading: false)
    }
}





