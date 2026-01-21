import UIKit

class SeeAllDetailVC: ChildViewController {
    
    @IBOutlet weak var _tableView: CustomTableView!
    @IBOutlet weak var _visualEffectView: UIVisualEffectView!
    @IBOutlet private weak var _headerTitleTxt: CustomLabel!
    @IBOutlet weak var _usersCount: CustomLabel!
    @IBOutlet weak var _searchBar: UISearchBar!
    @IBOutlet weak var _searchView: UIView!
    private let kCellIdentifierVenue = String(describing: SeeAllListTableCell.self)
    private let kCellIdentifierMyCircle = String(describing: MyCircleListTableCell.self)
    private let kCellIdentifierMyEvent =  String(describing: ComplementaryMyEventTableCell.self)
    private var venueListModel: [VenueDetailModel] = []
    public var usersListModel: [UserDetailModel] = []
    public var filteredUserListModel: [UserDetailModel] = []
    public var eventListModel: [PromoterEventsModel] = []
    public var detailType: String = "venue"
    public var viewTitle: String = "Event I'm IN"
    private var isSearching = false
    private var refreshControl = UIRefreshControl()
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
        NotificationCenter.default.addObserver(self, selector: #selector(handleReloadProfile(_:)), name: .reloadPromoterProfileNotifier, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleReloadEvent(_:)), name: .reloadMyEventsNotifier, object: nil)
    }
    
    override func setupUi() {
        _visualEffectView.alpha = 0
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "Oops! Looks a bit empty? Let's toss and kickstart those adventures!",
            emptyDataIconImage: UIImage(named: "empty_event"),
            emptyDataDescription: nil,
            delegate: self)
        _tableView.proxyDelegate = self
        configureView(for: detailType, viewTitle: viewTitle)
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        refreshControl.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        _tableView.refreshControl = refreshControl
        _searchBar.searchTextField.backgroundColor = UIColor(white: 1, alpha: 0.08)
        _searchBar.searchTextField.layer.cornerRadius = 18
        _searchBar.searchTextField.layer.masksToBounds = true
        _searchBar.searchTextField.textColor = .white

    }
    
    
    func configureView(for detailType: String, viewTitle: String? = nil, reload: Bool = true) {
        switch detailType {
        case "venues":
            _headerTitleTxt.text = "my_venues".localized()
            _requestMyVenues(reload)

        case "rings":
            _headerTitleTxt.text = "my_rings".localized()
            _searchBar.delegate = self
            _searchView.isHidden = false
                _requestRingMember(reload)
        case "circles":
            _headerTitleTxt.text = "my_circles".localized()
            _loadData()
        case "event", "filterEvent":
            _headerTitleTxt.text = viewTitle ?? "event".localized()
            if detailType == "filterEvent", eventListModel.isEmpty {
                _requestEventList(reload)
            } else {
                _loadData()
            }

        case "plusOne":
            _headerTitleTxt.text = "my_group".localized()
            _loadData()
            _requestMyGroup(reload)
        case "normalPlusOne":
            _headerTitleTxt.text = "my_plus_one".localized()
            _loadData()
            _requestMyPlusOne(reload)

        default:
            break
        }
    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierVenue, kCellNibNameKey: kCellIdentifierVenue, kCellClassKey: SeeAllListTableCell.self, kCellHeightKey: SeeAllListTableCell.height],
            [kCellIdentifierKey: kCellIdentifierMyCircle, kCellNibNameKey: kCellIdentifierMyCircle, kCellClassKey: MyCircleListTableCell.self, kCellHeightKey: MyCircleListTableCell.height],
            [kCellIdentifierKey: kCellIdentifierMyEvent, kCellNibNameKey: kCellIdentifierMyEvent, kCellClassKey: ComplementaryMyEventTableCell.self, kCellHeightKey: ComplementaryMyEventTableCell.height]
        ]
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        refreshControl.endRefreshing()
        switch detailType {
        case "venues":
            cellData = loadVenueCells(with: venueListModel)
        case "rings":
            let listModel = isSearching ? filteredUserListModel : usersListModel
            cellData = loadUserCells(with: listModel)
        case "circles":
            cellData = loadCircleCells(with: usersListModel)

        case "event":
            cellData = loadEventCells(with: eventListModel)

        case "filterEvent":
            cellData = loadFilteredEventCells(with: eventListModel)

        case "plusOne", "normalPlusOne":
            cellData = loadUserCells(with: usersListModel)

        default:
            break
        }

        if !cellData.isEmpty {
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        }

        _tableView.loadData(cellSectionData)
    }
    
    private func fetchData(completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion()
        }
    }
    
    @objc private func refreshData(_ sender: Any) {
        fetchData {
            DispatchQueue.main.async {
                self.configureView(for: self.detailType, viewTitle: self.viewTitle, reload: false)
            }
        }
    }
    
    // MARK: - Helper Methods

    private func loadVenueCells(with models: [VenueDetailModel]) -> [[String: Any]] {
        return models.map { model in
            [
                kCellIdentifierKey: kCellIdentifierVenue,
                kCellTagKey: kCellIdentifierVenue,
                kCellObjectDataKey: model,
                kCellClassKey: SeeAllListTableCell.self,
                kCellHeightKey: SeeAllListTableCell.height
            ]
        }
    }

    private func loadUserCells(with models: [UserDetailModel]) -> [[String: Any]] {
        return models.map { model in
            [
                kCellIdentifierKey: kCellIdentifierVenue,
                kCellTagKey: kCellIdentifierVenue,
                kCellObjectDataKey: model,
                kCellClassKey: SeeAllListTableCell.self,
                kCellHeightKey: SeeAllListTableCell.height
            ]
        }
    }

    private func loadCircleCells(with models: [UserDetailModel]) -> [[String: Any]] {
        return models.map { model in
            [
                kCellIdentifierKey: kCellIdentifierMyCircle,
                kCellTagKey: kCellIdentifierMyCircle,
                kCellObjectDataKey: model,
                kCellClassKey: MyCircleListTableCell.self,
                kCellHeightKey: MyCircleListTableCell.height
            ]
        }
    }

    private func loadEventCells(with models: [PromoterEventsModel]) -> [[String: Any]] {
        return models.map { model in
            [
                kCellIdentifierKey: kCellIdentifierMyEvent,
                kCellTagKey: kCellIdentifierMyEvent,
                kCellObjectDataKey: model,
                kCellClassKey: ComplementaryMyEventTableCell.self,
                kCellHeightKey: ComplementaryMyEventTableCell.height
            ]
        }
    }
    
    private func loadFilteredEventCells(with models: [PromoterEventsModel]) -> [[String: Any]] {
        return models.compactMap { model in
            let isActiveEvent = model.status != "cancelled" && model.status != "completed"

            let shouldInclude: Bool = {
                switch viewTitle {
                case "Events Im In":
                    return model.invite?.promoterStatus == "accepted" && model.invite?.inviteStatus == "in" && isActiveEvent
                case "Specially for me":
                    return model.type == "private" && isActiveEvent
                case "My List":
                    return model.isWishlisted && isActiveEvent
                case "Im Interested":
                    return model.invite?.promoterStatus == "pending" && model.invite?.inviteStatus == "in" && isActiveEvent
                default:
                    return false
                }
            }()

            return shouldInclude ? [
                kCellIdentifierKey: kCellIdentifierMyEvent,
                kCellTagKey: kCellIdentifierMyEvent,
                kCellObjectDataKey: model,
                kCellClassKey: ComplementaryMyEventTableCell.self,
                kCellHeightKey: ComplementaryMyEventTableCell.height
            ] : nil
        }
    }

    
    private func _requestMyVenues(_ isReload: Bool = false) {
        if isReload { showHUD() }
        WhosinServices.getMyVenuesList { [weak self] container, error in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self.venueListModel = data
            self._loadData()
        }
    }
    
    private func _requestRingMember(_ isReload: Bool = false) {
        if isReload { showHUD() }
        WhosinServices.getMyRingMemberList { [weak self] container, error in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self.usersListModel = data
            self._loadData()
        }
    }
    
    private func _requestMyGroup(_ isReload: Bool = false) {
        if isReload { showHUD() }
        WhosinServices.myPlusOneList { [weak self] container, error in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
            self.hideHUD(error: error)
            guard let data = container?.data else { return}
            self.usersListModel = data
            self._loadData()
        }
    }
    
    private func _requestMyPlusOne(_ isReload: Bool = false) {
        if isReload { showHUD() }
        WhosinServices.myPlusOneUserList { [weak self] container, error in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
            self.hideHUD(error: error)
            guard let data = container?.data else { return}
            self.usersListModel = data
            self._loadData()
        }
    }
    
    private func _requestEventList(_ isReload: Bool = false) {
        if isReload { showHUD() }
        WhosinServices.getEventList { [weak self] container, error in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
            self.hideHUD(error: error)
            guard let data = container?.data else { return}
            self.eventListModel = data
            self._loadData()
        }
    }
    
    @objc func handleReloadProfile(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let circle = userInfo["circleModel"] as? UserDetailModel, let isDelete = userInfo["isDelete"] as? Bool {
            if let index = usersListModel.firstIndex(where: { $0.id == circle.id }) {
                if isDelete {
                    usersListModel.remove(at: index)
                } else {
                    usersListModel[index].avatar = circle.avatar
                    usersListModel[index].title = circle.title
                    usersListModel[index].descriptions = circle.descriptions
                }
                _loadData()
                detailType == "circles"
            }
        }
    }
    
    @objc func handleReloadEvent(_ notification: Notification) {
        _requestEventList(true)
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
    @IBAction func _handleBackEvent(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}

// --------------------------------------
// MARK: Search Delegate
// --------------------------------------

extension SeeAllDetailVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            _loadData()
        } else {
            isSearching = true
            filteredUserListModel = usersListModel.filter({ $0.firstName.localizedCaseInsensitiveContains(searchText) || $0.lastName.localizedCaseInsensitiveContains(searchText) || $0.phone.localizedCaseInsensitiveContains(searchText) })
            _loadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}

// --------------------------------------
// MARK: TableView Delegate
// --------------------------------------

extension SeeAllDetailVC: CustomTableViewDelegate, UIScrollViewDelegate, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        let threshold: CGFloat = 30
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
    }
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? SeeAllListTableCell {
            if let object = cellDict?[kCellObjectDataKey] as? VenueDetailModel {
                cell._imageView.cornerRadius = 10
                cell.setupVenue(object)
            } else if let object = cellDict?[kCellObjectDataKey] as? UserDetailModel {
                cell._imageView.cornerRadius = cell._imageView.frame.height / 2
                if detailType == "plusOne" || detailType == "normalPlusOne" {
                    cell.setupPlusOne(object, isCM: detailType == "plusOne")
                } else {
                    cell.setupUser(object, showViewMore: detailType == "rings")
                }
            }
            cell.removeCallback = { type in
                if type == "venue" {
                    self._requestMyVenues()
                } else if type == "ring" {
                    self._requestRingMember()
                } else if type == "group" {
                    if self.detailType == "plusOne" {
                        self._requestMyGroup()
                    } else {
                        self._requestMyPlusOne()
                    }
                }
            }
        } else if let cell = cell as? MyCircleListTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
            cell.setupData(object)
        } else if let cell = cell as? ComplementaryMyEventTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? PromoterEventsModel else { return }
            cell.setupData(object)
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? MyCircleListTableCell {
//            guard !Preferences.isSubAdmin else { return }
            guard let object = cellDict?[kCellObjectDataKey] as? UserDetailModel else { return }
            let vc = INIT_CONTROLLER_XIB(MyCircleDetailVC.self)
            vc.circleModel = object
            navigationController?.pushViewController(vc, animated: true)
        } else if let cell = cell as? SeeAllListTableCell {
            if detailType == "plusOne" || detailType == "normalPlusOne", let object = cellDict?[kCellObjectDataKey] as? UserDetailModel {
                let vc = INIT_CONTROLLER_XIB(UsersProfileVC.self)
                vc.contactId = detailType == "normalPlusOne" ? object.userId : object.id
                navigationController?.pushViewController(vc, animated: true)
            } else {
                if let object = cellDict?[kCellObjectDataKey] as? VenueDetailModel {
                    let vc = INIT_CONTROLLER_XIB(VenueDetailsVC.self)
                    vc.venueId = object.id
                    vc.venueDetailModel = object
                    navigationController?.pushViewController(vc, animated: true)
                } else if let object = cellDict?[kCellObjectDataKey] as? UserDetailModel {
                    let vc = INIT_CONTROLLER_XIB(ComplementaryPublicProfileVC.self)
                    vc.complimentryId = object.userId
                    navigationController?.pushViewController(vc, animated: true)
                }
            }
        } else if let cell = cell as? ComplementaryMyEventTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? PromoterEventsModel else { return }
            let vc = INIT_CONTROLLER_XIB(PromoterEventDetailVC.self)
            vc.isComplementary = true
            vc.eventModel = object
            vc.id = object.id
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
