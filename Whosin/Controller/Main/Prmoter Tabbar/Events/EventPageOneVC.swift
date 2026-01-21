import UIKit

class EventPageOneVC: ChildViewController {

    @IBOutlet weak var _tableView: CustomNoKeyboardTableView!
    private let kCellIdentifiereComman = String(describing: PromoterEventInfoCell.self)
    public var eventModel: PromoterEventsModel?
    public var isEditEvent: Bool = false
    var getValCallback: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
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
            emptyDataText: "empty_promoter_detail".localized(),
            emptyDataIconImage: UIImage(named: "empty_explore"),
            emptyDataDescription: nil,
            delegate: self)
        _loadData()
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifiereComman, kCellNibNameKey: kCellIdentifiereComman, kCellClassKey: PromoterEventInfoCell.self, kCellHeightKey: PromoterEventInfoCell.height]
        ]
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        if Utils.stringIsNullOrEmpty(PromoterCreateEventVC.eventParams["type"] as? String) {
            PromoterCreateEventVC.eventParams["type"] = "private"
        }
        
        cellData.append([
            kCellIdentifierKey: kCellIdentifiereComman,
            kCellTagKey: kCellIdentifiereComman,
            kCellObjectDataKey: PromoterCreateEventVC.eventParams,
            kCellClassKey: PromoterEventInfoCell.self,
            kCellHeightKey: PromoterEventInfoCell.height
        ])
        
        if cellData.count != .zero {
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        }
        _tableView.loadData(cellSectionData)
    }
}

extension EventPageOneVC: CustomNoKeyboardTableViewDelegate {
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? PromoterEventInfoCell {
            guard let object = cellDict?[kCellObjectDataKey] as? [String:Any] else { return }
            cell._setupData(object, isEdit: isEditEvent, model: eventModel)
            cell.updateCallBack = { params in
                if Utils.stringIsNullOrEmpty(params["venueId"] as? String) {
                   PromoterCreateEventVC.eventParams["customVenue"] = params["customVenue"]
                    PromoterCreateEventVC.eventParams["latitude"] = params["latitude"]
                    PromoterCreateEventVC.eventParams["longitude"] = params["longitude"]
                } else {
                    PromoterCreateEventVC.eventParams["venueId"] = params["venueId"]
                    PromoterCreateEventVC.eventParams["offerId"] = params["offerId"]
                    PromoterCreateEventVC.eventParams["customVenue"] = params["customVenue"]
                    PromoterCreateEventVC.eventParams["image"] = params["image"]
                }
                PromoterCreateEventVC.eventParams["venueType"] = params["venueType"]
                PromoterCreateEventVC.eventParams["date"] = params["date"]
                PromoterCreateEventVC.eventParams["startTime"] = params["startTime"]
                PromoterCreateEventVC.eventParams["endTime"] = params["endTime"]
                PromoterCreateEventVC.eventParams["dressCode"] = params["dressCode"]
                PromoterCreateEventVC.eventParams["description"] = params["description"]
                self.getValCallback?()
                self._loadData()
            }
        }
    }
}
