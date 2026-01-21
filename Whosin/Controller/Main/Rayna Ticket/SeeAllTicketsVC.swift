import UIKit
import Alamofire

class SeeAllTicketsVC: ChildViewController {

    // --------------------------------------
    // MARK: Outlets
    // --------------------------------------
    
    @IBOutlet private weak var _visualEffectView: UIVisualEffectView!
    @IBOutlet private weak var _titleText: CustomLabel!
    @IBOutlet private weak var _tableView: CustomNoKeyboardTableView!
    @IBOutlet private weak var _searchBar: UISearchBar!

    // --------------------------------------
    // MARK: Variables
    // --------------------------------------

    private let kLoadingCellIdentifire = String(describing: LoadingCell.self)
    private let kCellIdentifire = String(describing: ExploreTicketTableCell.self)
    public var ticketList: [TicketModel] = []
    public var titleText: String = "Tickets"
    private var _searchticketList: [TicketModel] = []
    private var isSearching = false
    private var searchTimer: Timer?
    private var _dataRequest: DataRequest?
    private var _searchText: String = kEmptyString
    private var searchActivityIndicator: UIActivityIndicatorView?
    private var currentPage: Int = 1
    private var isFetchingMore: Bool = false
    public var isHotelSearch: Bool = false

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
        _titleText.text = titleText
        addActivityIndicatorToSearchBar()
    }
    
    // --------------------------------------
    // MARK: Services
    // --------------------------------------

    private func _requestSearch(_ text: String, page: Int = 1, showLoader: Bool = false) {
        if let request = _dataRequest {
            if !request.isCancelled || !request.isFinished || !request.isSuspended {
                request.cancel()
            }
        }

        if page == 1 {
            self._tableView.startRefreshing()
        } else {
            isFetchingMore = true
        }

        _dataRequest = WhosinServices.raynaSearch(search: text, page: page, type: isHotelSearch ? "juniper-hotel" : "ticket") { [weak self] containers, error in
            guard let self = self else { return }
            if page == 1 {
                self._tableView.endRefreshing()
                self.searchActivityIndicator?.stopAnimating()
            } else {
                self.isFetchingMore = false
            }
            self.hideHUD()
            guard let data = containers?.data else { return }
            if page == 1 {
                self._searchticketList = data 
            } else {
                self._searchticketList.append(contentsOf: data)
            }
            self._loadData()
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    override func setupUi() {
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "no_ticket_available".localized(),
            emptyDataIconImage: UIImage(named: "empty_offers"),
            emptyDataDescription: "no_ticket_detail".localized(),
            delegate: self)
        _searchBar.delegate = self
        _searchBar.searchTextField.backgroundColor = UIColor(white: 1, alpha: 0.08)
        _searchBar.searchTextField.layer.cornerRadius = 17
        _searchBar.searchTextField.layer.masksToBounds = true
        _searchBar.searchTextField.textColor = .white
        _searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "search_tickets".localized(),
            attributes: [.foregroundColor: UIColor(white: 1, alpha: 0.4)]
        )

        _tableView.proxyDelegate = self
        _loadData()
    }
    
    private func addActivityIndicatorToSearchBar() {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true

        if #available(iOS 13.0, *), let searchTextField = _searchBar.searchTextField as? UIView {
            searchTextField.addSubview(indicator)
            
            NSLayoutConstraint.activate([
                indicator.centerYAnchor.constraint(equalTo: searchTextField.centerYAnchor),
                indicator.trailingAnchor.constraint(equalTo: searchTextField.trailingAnchor, constant: -30)
            ])
        } else {
            _searchBar.addSubview(indicator)

            NSLayoutConstraint.activate([
                indicator.centerYAnchor.constraint(equalTo: _searchBar.centerYAnchor),
                indicator.trailingAnchor.constraint(equalTo: _searchBar.trailingAnchor, constant: -30)
            ])
        }

        searchActivityIndicator = indicator
    }
    
    private func _loadData(isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        if isSearching {
            _searchticketList.forEach { ticket in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifire,
                    kCellTagKey: kCellIdentifire,
                    kCellObjectDataKey: ticket,
                    kCellClassKey: ExploreTicketTableCell.self,
                    kCellHeightKey: ExploreTicketTableCell.height
                ])
            }
        } else {
            ticketList.forEach { ticket in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifire,
                    kCellTagKey: kCellIdentifire,
                    kCellObjectDataKey: ticket,
                    kCellClassKey: ExploreTicketTableCell.self,
                    kCellHeightKey: ExploreTicketTableCell.height
                ])
            }
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
        
    }
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kLoadingCellIdentifire, kCellNibNameKey: kLoadingCellIdentifire, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height],
            [kCellIdentifierKey: kCellIdentifire, kCellNibNameKey: kCellIdentifire, kCellClassKey: ExploreTicketTableCell.self, kCellHeightKey: ExploreTicketTableCell.height]
        ]
    }

    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleBackEvent(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    
}


extension SeeAllTicketsVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            _searchText = kEmptyString
            currentPage = 1
            _loadData()
        } else {
            isSearching = true
            searchActivityIndicator?.startAnimating()
            _searchText = searchText
            currentPage = 1
            _requestSearch(searchText, page: currentPage, showLoader: true)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}
// --------------------------------------
// MARK: TableView Delegates
// --------------------------------------

extension SeeAllTicketsVC: CustomNoKeyboardTableViewDelegate, UIScrollViewDelegate, UITableViewDelegate {
    
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
        
        let scrollViewContentHeight = scrollView.contentSize.height
        let scrollOffsetThreshold = scrollViewContentHeight - scrollView.bounds.height * 0.8

        if yOffset > scrollOffsetThreshold, !isFetchingMore, isSearching {
            if _searchticketList.count % 20 == 0 {
                currentPage += 1
                _requestSearch(_searchText, page: currentPage)
            }
        }
    }
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? LoadingCell {
            cell.setupUi()
        } else if let cell = cell as? ExploreTicketTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? TicketModel else { return }
            cell.setUpdata(object)
        }
    }
    
    func didSelectTableCell(_ cell: UITableViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? ExploreTicketTableCell {
            guard let object = cellDict?[kCellObjectDataKey] as? TicketModel else { return }
            let vc = INIT_CONTROLLER_XIB(CustomTicketDetailVC.self)
            vc.ticketID = object._id
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
          
