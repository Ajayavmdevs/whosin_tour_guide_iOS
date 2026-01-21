import UIKit

class EventPageFiveVC: ChildViewController {

    @IBOutlet weak var _tableView: CustomNoKeyboardTableView!
    private let kCellIdentifiereAllowExtraGuest = String(describing: PlushOneFeatureCell.self)
    private let kCellIdentifiereSpecification = String(describing: PlusOneSpecificationTableCell.self)

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
            [kCellIdentifierKey: kCellIdentifiereAllowExtraGuest, kCellNibNameKey: kCellIdentifiereAllowExtraGuest, kCellClassKey: PlushOneFeatureCell.self, kCellHeightKey: PlushOneFeatureCell.height],
            [kCellIdentifierKey: kCellIdentifiereSpecification, kCellNibNameKey: kCellIdentifiereSpecification, kCellClassKey: PlusOneSpecificationTableCell.self, kCellHeightKey: PlusOneSpecificationTableCell.height]
        ]
    }
    
    private func _loadData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        
        cellData.append([
            kCellIdentifierKey: kCellIdentifiereAllowExtraGuest,
            kCellObjectDataKey: PromoterCreateEventVC.eventParams,
            kCellClassKey: PlushOneFeatureCell.self,
            kCellHeightKey: PlushOneFeatureCell.height
        ])
        
        if PromoterCreateEventVC.eventParams["extraGuestType"] as? String == "specific", PromoterCreateEventVC.eventParams["plusOneAccepted"] as? Bool == true {
            cellData.append([
                kCellIdentifierKey: kCellIdentifiereSpecification,
                kCellObjectDataKey: PromoterCreateEventVC.eventParams,
                kCellClassKey: PlusOneSpecificationTableCell.self,
                kCellHeightKey: PlusOneSpecificationTableCell.height
            ])
        }
        
        if cellData.count != .zero {
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        }
        _tableView.loadData(cellSectionData)
        
    }
}

extension EventPageFiveVC: CustomNoKeyboardTableViewDelegate {
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? PlushOneFeatureCell {
            guard let params = cellDict?[kCellObjectDataKey] as? [String: Any] else { return }
            cell.setupData(params)
            if let isAllow = params["plusOneAccepted"] as? Bool {
                PromoterCreateEventVC.eventParams["plusOneAccepted"] = isAllow
            } else {
                PromoterCreateEventVC.eventParams["plusOneAccepted"] = false
            }
            cell.updateCallback = { data in
                PromoterCreateEventVC.eventParams["plusOneAccepted"] = data.isAllowed
                if data.isAllowed {
                    PromoterCreateEventVC.eventParams["extraGuestType"] = data.guestType
                    PromoterCreateEventVC.eventParams["extraGuestGender"] = data.gender
                    PromoterCreateEventVC.eventParams["plusOneQty"] = data.totalGuests
                    PromoterCreateEventVC.eventParams["extraGuestMaleSeats"] = data.maleGuests
                    PromoterCreateEventVC.eventParams["extraGuestFemaleSeats"] = data.femaleGuests
                    PromoterCreateEventVC.eventParams["extraSeatPreference"] = data.seatAllocationType
                }
                self._loadData()
            }
        } else if let cell = cell as? PlusOneSpecificationTableCell {
            guard let params = cellDict?[kCellObjectDataKey] as? [String: Any] else { return }
            cell.setupData(params)
            cell.dataUpdated = { data in
                PromoterCreateEventVC.eventParams["extraGuestAge"] = "\(data.minAge)-\(data.maxAge)"
                PromoterCreateEventVC.eventParams["extraGuestDressCode"] = data.dressCode
                PromoterCreateEventVC.eventParams["extraGuestNationality"] = data.nationality
                self._loadData()
            }
        }
    }
}
