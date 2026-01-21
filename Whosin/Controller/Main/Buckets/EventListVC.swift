import UIKit

class EventListVC: ChildViewController {

    @IBOutlet private weak var _tableView: CustomNoKeyboardTableView!
    private let kCellIdentifier = String(describing: EventTableCell.self)
    public var type: EventType = .upcoming
    public var _eventList: [EventModel] = []
    
    // --------------------------------------
    // MARK: Life-Cycle
    // --------------------------------------
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if type == .upcoming {
            _requesUpcomingList()
        } else if type == .history {
            _requestHistoryList()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func setupUi() {
        NotificationCenter.default.addObserver(self, selector:  #selector(handleReload), name: kReloadEventDetail, object: nil)
        _tableView.setup(
            cellPrototypes: _prototype,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: true,
            isShowRefreshing: true,
            emptyDataText: kEmptyString,
            emptyDataIconImage: type == .upcoming ? UIImage(named: "empty_event") : UIImage(named: "empty_history"),
            emptyDataDescription: type == .upcoming ? "upcoming events looking a bit empty?!" : "events history looking a bit empty?!",
            delegate: self)

        _tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 70, right: 0)
        
    } 
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    @objc func handleReload() {
        if type == .upcoming {
            _requesUpcomingList()
        } else if type == .history {
            _requestHistoryList()
        }
    }

    private func _requesUpcomingList() {
        _eventList.removeAll()
        showHUD()
        WhosinServices.requestUpcomingEvent { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            self._tableView.endRefreshing()
            guard let data = container?.data else { return }
            self._eventList = data
            self._loadData()
        }
    }
    
    private func _requestHistoryList() {
        _eventList.removeAll()
        showHUD()
        WhosinServices.requestEventHistory { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            self._tableView.endRefreshing()
            guard let data = container?.data else { return }
            self._eventList = data
            self._loadData()
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        if !_eventList.isEmpty {
            _eventList.forEach { model in
                if !Utils.isVenueDetailEmpty(model.venueDetail) {
                    cellData.append([
                        kCellIdentifierKey: kCellIdentifier,
                        kCellTagKey: model.id,
                        kCellObjectDataKey: model,
                        kCellClassKey: EventTableCell.self,
                        kCellHeightKey: EventTableCell.height
                    ])
                }
            }
        }
        if cellData.count != .zero {
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        }
        _tableView.loadData(cellSectionData)
    }
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: kCellIdentifier, kCellClassKey: EventTableCell.self, kCellHeightKey: EventTableCell.height]]
    }
}

extension EventListVC: CustomNoKeyboardTableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? EventTableCell else { return }
        if let object = cellDict?[kCellObjectDataKey] as? EventModel {
            cell.setupEventData(object)
        }
    }

    func refreshData() {
        if type == .upcoming {
            _requesUpcomingList()
        } else if type == .history {
            _requestHistoryList()
        }
    }

}
