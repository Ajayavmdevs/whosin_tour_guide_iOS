import UIKit

class CMEventHistoryVC: ProfileBaseMainVC {

    @IBOutlet private weak var _tableView: CustomNoKeyboardTableView!
    private var isLoadingMyEvent: Bool = false
    private let kCellMyList = String(describing: CMEventListCell.self)
    private let kLoadingCell = String(describing: LoadingCell.self)
    private var _eventHistory: [PromoterEventsModel] = []
    private var _page : Int = 1
    private var isPaginating = false
    private var footerView: LoadingFooterView?
    private var _callback: ((Bool) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
        setupUi()
        _requestEventHistoryList(true)
    }

    override func _refresh(_ callback: @escaping (Bool) -> Void) {
        self._callback = callback
        _requestEventHistoryList()
    }
    
    // --------------------------------------
    // MARK: Setup
    // --------------------------------------


    override func setupUi() {
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: true,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            isShowRefreshing: false,
            emptyDataText: "empty_event_history".localized(),
            emptyDataIconImage: UIImage(named: "empty_explore"),
            emptyDataDescription: nil,
            delegate: self)
        _loadingChat()
        footerView = LoadingFooterView(frame: CGRect(x: 0, y: 0, width: _tableView.bounds.width, height: 44))
        _tableView.tableFooterView = footerView
        _tableView.delegate = self
        _tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
    }
    
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellMyList, kCellNibNameKey: kCellMyList, kCellClassKey: CMEventListCell.self, kCellHeightKey: CMEventListCell.height],
            [kCellIdentifierKey: kLoadingCell, kCellNibNameKey: kLoadingCell, kLoadingCell: LoadingCell.self, kCellHeightKey: LoadingCell.height]]
    }
    
    private func _loadingChat() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        cellData.append([
            kCellIdentifierKey: kLoadingCell,
            kCellTagKey: self.kLoadingCell,
            kCellObjectDataKey: "loading",
            kCellClassKey: LoadingCell.self,
            kCellHeightKey: LoadingCell.height
        ])
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        _eventHistory.enumerated().forEach { index, eventByVenue in
            cellData.append([
                kCellIdentifierKey: kCellMyList,
                kCellTagKey: index == 0,
                kCellObjectDataKey: eventByVenue,
                kCellClassKey: CMEventListCell.self,
                kCellHeightKey: CMEventListCell.height
            ])
        }


        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------

    private func _requestEventHistoryList(_ isReload: Bool = false) {
//        if isReload { showHUD() }
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
            self._loadData()
            self._callback?(true)
        }
    }
}


// --------------------------------------
// MARK: TableView Delegate
// --------------------------------------

extension CMEventHistoryVC: CustomNoKeyboardTableViewDelegate, UITableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? CMEventListCell {
            guard let object = cellDict?[kCellObjectDataKey] as? PromoterEventsModel, let showTitle = cellDict?[kCellTagKey] as? Bool else { return }
            cell._promoterView.isHidden = true
            cell.setupData([object], cellTitle: "event_history".localized(), showtitle: showTitle)
        } else if let cell = cell as? EmptyDataCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [String:Any] else { return }
            cell.setupData(object)
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//            return  nil
//    }
//    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//            return 0.0
//    }

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScroll(scrollView)
        
        let scrollViewContentHeight = scrollView.contentSize.height
        let scrollOffsetThreshold = scrollViewContentHeight - scrollView.bounds.height
        if scrollView.contentOffset.y > scrollOffsetThreshold && !isRequesting {
            performPagination()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        didEndDecelerating(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        didEndDragging(scrollView, willDecelerate: decelerate)
    }

    private func performPagination() {
        guard !isPaginating else { return }
        if !_eventHistory.isEmpty && _eventHistory.count % 20 == 0 {
            isPaginating = true
            _page += 1
            footerView?.startAnimating()
            _requestEventHistoryList()
        }
    }
    
}
