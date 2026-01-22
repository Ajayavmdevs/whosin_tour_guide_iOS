import UIKit

class NotificationVC: ChildViewController {
    
    @IBOutlet private weak var _tableView: CustomNoKeyboardTableView!
    @IBOutlet weak var _visualEffectView: UIVisualEffectView!
    private let kCellIdentifier = String(describing: NotificationTableCell.self)
    private let kEmptyCellIdentifier = String(describing: EmptyDataCell.self)
    private let kCellIdentifierLoading = String(describing: LoadingCell.self)
    private var _notificationData: NotificationListModel?
    private var footerView: LoadingFooterView?
    private var _page : Int = 1
    private var isPaginating = false
    private var _eventNotification: NotificationListModel?
    private var isLoadingNotification: Bool = false
    private var refreshControl = UIRefreshControl()

    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _page = 1
        setupUi()
        _requestNotificationData()
        showHUD()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
        
    override func setupUi() {
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: kEmptyString,
            emptyDataIconImage: UIImage(named: "empty_notification"),
            emptyDataDescription: "no_active_notifications".localized(),
            delegate: self)
        _visualEffectView.alpha = 0.0
        footerView = LoadingFooterView(frame: CGRect(x: 0, y: 0, width: _tableView.bounds.width, height: 44))
        _tableView.tableFooterView = footerView
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        refreshControl.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        _tableView.refreshControl = refreshControl
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestNotificationData() {
        _tableView.startRefreshing()
        WhosinServices.notificationList(page: _page, limit: 30) { [weak self] container, error in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
            self.footerView?.stopAnimating()
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            if self.isPaginating {
                self.isPaginating = false
                self._notificationData?.notification.append(objectsIn: data.notification)
                self._notificationData?.category.append(objectsIn: data.category)
            } else {
                self._notificationData = data
            }
            self._loadData()
        }
    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        _notificationData?.notification.sort { $0.updatedAt > $1.updatedAt }
        _notificationData?.notification.forEach { notification in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: notification,
                kCellClassKey: NotificationTableCell.self,
                kCellHeightKey: NotificationTableCell.height
            ])
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: NotificationTableCell.self, kCellHeightKey: NotificationTableCell.height],
            [kCellIdentifierKey: kCellIdentifierLoading, kCellNibNameKey: kCellIdentifierLoading, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height],
            [kCellIdentifierKey: kEmptyCellIdentifier, kCellNibNameKey: kEmptyCellIdentifier, kCellClassKey: EmptyDataCell.self, kCellHeightKey: EmptyDataCell.height],
        ]
    }
    
    private func fetchData(completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            completion()
        }
    }
    
    @objc private func refreshData(_ sender: Any) {
        fetchData {
            DispatchQueue.main.async {
                    self._requestNotificationData()
            }
        }
    }
    
    private func _requestDeleteNotification(_ ids: [String], index: IndexPath) {
        showHUD()
        WhosinServices.notificationDelete(ids: ids) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container else { return}
            self.showToast(data.message)
            self._requestNotificationData()
        }
        
    }
    
    private func _requestDeleteNotification(_ ids: [String]) {
        showHUD()
        WhosinServices.notificationDelete(ids: ids) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container else { return}
            self.showToast(data.message)
            self._requestNotificationData()
        }
        
    }
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    private func _deleteNotificationEvent(id: String, index: IndexPath) {
        confirmAlert(message: "delete_notification_confirmation".localized(),okHandler: { okAction in
            self._requestDeleteNotification([id], index: index)
        }, noHandler:  { action in
        })
    }
    
    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}


extension NotificationVC: CustomNoKeyboardTableViewDelegate {
        
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, cellDict: [String : Any]?, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let object = cellDict?[kCellObjectDataKey] as? NotificationModel  else { return nil}
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            self._deleteNotificationEvent(id: object.id, index: indexPath)
            completionHandler(true)
        }
        deleteAction.image = UIImage(named: "icon_delete")
        deleteAction.backgroundColor = ColorBrand.brandgradientPink
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

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
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.size.height {
            if !isPaginating {
                performPagination()
            }
        }
    }
    
    private func performPagination() {
        if (_notificationData?.notification.count ?? 0) % 30 == 0 {
            isPaginating = true
            _page += 1
            footerView?.startAnimating()
            _requestNotificationData()
        }
    }
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? NotificationTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? NotificationModel  else { return }
            cell.setupData(object, listData: _notificationData)
        } else if let cell = cell as? EmptyDataCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [String:Any] else { return }
            cell.setupData(object)
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? NotificationModel else { return }
            if object.type == "link" {
                if let url = URL(string: object.typeId) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            } else if object.type == "ticket" {
                let vc = INIT_CONTROLLER_XIB(CustomTicketDetailVC.self)
                vc.ticketID = object.typeId
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else if object.type == "ticket-booking" {
                guard let window = APP.window  else { return }
                TabLaunchConfig.walletDefaultPageIndex = 0
                if let navController = window.rootViewController as? UINavigationController,
                   let tabBarController = navController.viewControllers.first as? MainTabBarVC,
                   tabBarController.selectedIndex == 4 {
                    return
                }
                let controller = INIT_CONTROLLER_XIB(MainTabBarVC.self)
                controller.selectedIndex = 4
                let navController = NavigationController(rootViewController: controller)
                navController.setNavigationBarHidden(true, animated: false)
                window.setRootViewController(navController, options: UIWindow.TransitionOptions(direction:.fade, style: .easeInOut))
            } else if object.type == "cancel-booking" {
                guard let window = APP.window  else { return }
                TabLaunchConfig.walletDefaultPageIndex = 1
                if let navController = window.rootViewController as? UINavigationController,
                   let tabBarController = navController.viewControllers.first as? MainTabBarVC,
                   tabBarController.selectedIndex == 4 {
                    return
                }
                let controller = INIT_CONTROLLER_XIB(MainTabBarVC.self)
                controller.selectedIndex = 4
                let navController = NavigationController(rootViewController: controller)
                navController.setNavigationBarHidden(true, animated: false)
                window.setRootViewController(navController, options: UIWindow.TransitionOptions(direction:.fade, style: .easeInOut))
            }
        }
    }
    
