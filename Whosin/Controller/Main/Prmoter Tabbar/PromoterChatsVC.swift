import UIKit
import IQKeyboardManagerSwift

class PromoterChatsVC: ChildViewController {

    @IBOutlet weak var _userImg: UIImageView!
    @IBOutlet weak var _tableView: CustomTableView!
    @IBOutlet weak var _promoterName: CustomLabel!
    @IBOutlet weak var _visualEffectView:
    UIVisualEffectView!
    private let kCellIdentifierEventRequest = String(describing: EventRequestTableCell.self)
    private let kEmptyCellIdentifier = String(describing: EmptyDataCell.self)
    private let kCellIdentifierLoading = String(describing: LoadingCell.self)
    private var _promoterModel: PromoterProfileModel? = APPSESSION.promoterProfile
    private var footerView: LoadingFooterView?
    private var _chatList: [PromoterChatListModel] = []
    private var refreshControl = UIRefreshControl()
    private var isLoadingChat: Bool = false
    private var isLoadingNotification: Bool = false
    private var tabView = CustomPromoterHeaderView()
    var filteredNotifications: [NotificationModel] = []
    private var isSearching: Bool = false
    private var shouldAllowSearchBarToEndEditing: Bool = true
    private var isApplyFilter: Bool = false
    private var _selectedFilter: String = "All"
    var searchTimer: Timer?
    private var promoterNotificationHeaderView = CustomNotificationHeaderView()
    private var filterType: Int = 0
    public var delegate: CloseTabbarDelegate?
    private var _spinerView: UIView?

    
    // --------------------------------------
    // MARK: Life cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
        setupUi()
        NotificationCenter.default.addObserver(self, selector: #selector(handleReloadEventNotification(_:)), name: .reloadEventNotification, object: nil)
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
            emptyDataText: "empty_event_chat".localized(),
            emptyDataIconImage: UIImage(named: "empty_chat"),
            emptyDataDescription: nil,
            delegate: self)
        _tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        footerView = LoadingFooterView(frame: CGRect(x: 0, y: 0, width: _tableView.bounds.width, height: 44))
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        refreshControl.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        _tableView.refreshControl = refreshControl
        _tableView.tableFooterView = footerView
        _tableView.proxyDelegate = self
        _requestChatList()
    }
    
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierEventRequest, kCellNibNameKey: kCellIdentifierEventRequest, kCellClassKey: EventRequestTableCell.self, kCellHeightKey: EventRequestTableCell.height],
            [kCellIdentifierKey: kEmptyCellIdentifier, kCellNibNameKey: kEmptyCellIdentifier, kCellClassKey: EmptyDataCell.self, kCellHeightKey: EmptyDataCell.height],
            [kCellIdentifierKey: kCellIdentifierLoading, kCellNibNameKey: kCellIdentifierLoading, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height],
        ]
    }
    
    private func _loadData(isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        _promoterName.text = _promoterModel?.profile?.fullName
        _userImg.loadWebImage(_promoterModel?.profile?.image  ?? kEmptyString, name: _promoterModel?.profile?.fullName ?? kEmptyString)

        if _chatList.isEmpty {
            cellData.append([
                kCellIdentifierKey: kEmptyCellIdentifier,
                kCellTagKey: kEmptyCellIdentifier,
                kCellObjectDataKey: ["title" : "chat_list_looking_a_bit_empty".localized(), "icon": "empty_chat"],
                kCellClassKey: EmptyDataCell.self,
                kCellHeightKey: EmptyDataCell.height
            ])
        } else {
            _chatList.forEach({ model in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifierEventRequest,
                    kCellTagKey: kCellIdentifierEventRequest,
                    kCellObjectDataKey: model,
                    kCellClassKey: EventRequestTableCell.self,
                    kCellHeightKey: EventRequestTableCell.height
                ])
            })
        }
        
        cellSectionData.append([kSectionTitleKey: " ", kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
        
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestChatList(_ isReload: Bool = false) {
        if !isReload {
            if _spinerView == nil {
                if let spinerView = getHudView() {
                    self._spinerView = spinerView
                    spinerView.frame =  CGRect(x: (kScreenWidth/2)-25, y: 275, width: 50, height: 50)
                    self.view.addSubview(spinerView)
                    self._tableView.isHidden = true
                }
            }
        }

        WhosinServices.chatList() { [weak self] container, error in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
            self.hideHUD(error: error)
            self._spinerView?.removeFromSuperview()
            self._spinerView = nil
            self._tableView.isHidden = false
            guard let data = container?.data else { return }
            self._chatList = data
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
                    self._requestChatList(true)
                }
            }
        }
    
    @objc func handleReloadEventNotification(_ notification: Notification) {
            _requestChatList(true)
    }
    
    @objc func handlePushReload() {
        _requestChatList(true)
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

extension PromoterChatsVC: CustomTableViewDelegate, UIScrollViewDelegate, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        let threshold: CGFloat = 100
        let scrollViewContentHeight = scrollView.contentSize.height
        let scrollOffsetThreshold = scrollViewContentHeight - scrollView.bounds.height * 0.8
    }
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? EmptyDataCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [String:Any] else { return }
            cell.setupData(object)
        } else if let cell = cell as? EventRequestTableCell {
            if let object = cellDict?[kCellObjectDataKey] as? NotificationModel {
                cell.setUpData(object, isNotification: true)
            } else if let object = cellDict?[kCellObjectDataKey] as? PromoterChatListModel {
                cell.setUpChatData(object, isPromoter: true)
            }
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? EventRequestTableCell {
            if let object = cellDict?[kCellObjectDataKey] as? PromoterChatListModel {
                let vc = INIT_CONTROLLER_XIB(PromoterEventDetailVC.self)
                vc.id = object.id
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
