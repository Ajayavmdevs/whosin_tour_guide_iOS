import UIKit

class CancellationPolicyBottomSheet: ChildViewController {
    
    @IBOutlet weak var _tableView: CustomNoKeyboardTableView!
    private var kCellIdentifier = String(describing: CancellationPolicyTableCell.self)
    private var kCellIdentifierLoading = String(describing: LoadingCell.self)
    private var kCellIdentifierDesc = String(describing: CancellationDescTableCell.self)
    public var _raynaTourPolicyModel: [TourPolicyModel] = []
    public var params: [String: Any] = [:]
    public var optionId: String = kEmptyString
    public var tourOptionModel: TourOptionsModel?
    public var travelOptionModel: TourOptionModel?
    public var tourOptionDataModel: TourOptionDataModel?
    public var isFromBooking: Bool = false
    public var type: String = "rayna"
    public var _octoPolicy: String = "rayna"
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // --------------------------------------
    // MARK: SetUp
    // --------------------------------------
    
    private func setupUI() {
        _tableView.setup(
            cellPrototypes: _prototypes,
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            emptyDataText: "empty_pickup".localized(),
            emptyDataIconImage: UIImage(named: "empty_event"),
            emptyDataDescription: nil,
            delegate: self)
        _tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        if isFromBooking {
            if params.isEmpty {
                _loadData()
            } else {
                if type == "whosin" {
                    _loadData(true)
                    _requestWhosinTicketRules()
                } else if type == "whosin-ticket" {
                    _loadData(true)
                    _requestWhosinTourPolicy()
                } else if type == "travel-desk" {
                    _loadData(true)
                    _requestTravelTourPolicy()
                } else if type == "big-bus" || type == "hero-balloon" {
                    _loadData(true)
                    _requestOctoPolicy()
                }
            }
        } else {
            _loadData(true)
            if BOOKINGMANAGER.ticketModel?.bookingType == "whosin" {
                _requestWhosinTourPolicy()
            } else if BOOKINGMANAGER.ticketModel?.bookingType == "rayna" {
                _requestRaynaTourPolicy()
            } else if BOOKINGMANAGER.ticketModel?.bookingType == "travel-desk" {
                _requestTravelTourPolicy()
            } else if BOOKINGMANAGER.ticketModel?.bookingType == "whosin-ticket" {
                _requestWhosinTicketRules()
            } else if BOOKINGMANAGER.ticketModel?.bookingType == "big-bus" || BOOKINGMANAGER.ticketModel?.bookingType == "hero-balloon" {
                _loadData(true)
                _requestOctoPolicy()
            }
        }
    }
    
    // --------------------------------------
    // MARK: Services
    // --------------------------------------
    
    private func _requestRaynaTourPolicy() {
        let option = BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == "\(tourOptionModel?.tourOptionId ?? 0)" })
        let contractId = Utils.stringIsNullOrEmpty(BOOKINGMANAGER.ticketModel?.contractId) ? BOOKINGMANAGER.ticketModel?.tourData?.contractId ?? kEmptyString : BOOKINGMANAGER.ticketModel?.contractId ?? kEmptyString
        let params: [String : Any] = ["tourId": tourOptionModel?.tourId ?? kEmptyString,
                                      "tourOptionId": tourOptionModel?.tourOptionId ?? kEmptyString,
                                      "contractId": contractId,
                                      "date": Utils.stringIsNullOrEmpty(option?.tourDate) ? tourOptionModel?.inititalDate ?? "" : option?.tourDate ?? "",
                                      "time": option?.startTime ?? "00:00:00",
                                      "transferId": tourOptionModel?.transferId ?? kEmptyString,
                                      "noOfAdult": option?.adult ?? 1,
                                      "noOfChild": option?.child ?? 0,
                                      "noOfInfant": option?.infant ?? 0]
        WhosinServices.raynaTourPolicy(params: params) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self._raynaTourPolicyModel = data
            self._loadData()
        }
    }
    
    private func _requestTravelTourPolicy() {
        let option = BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == "\(travelOptionModel?.id ?? 0)" })
        var params: [String : Any] = ["tourId": travelOptionModel?.tourId ?? kEmptyString,
                                      "optionId": travelOptionModel?.id ?? kEmptyString,
                                      "date": Utils.stringIsNullOrEmpty(option?.tourDate) ? Utils.dateToString(Calendar.current.date(byAdding: .day, value: 1, to: Date()), format: kFormatDate) : option?.tourDate ?? "",
                                      "adults": option?.adult ?? 1,
                                      "childs": option?.child ?? 0,
                                      "infant": option?.infant ?? 0]
        if !self.params.isEmpty {
            params = self.params
        }
        WhosinServices.travelTourPolicy(params: params) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self._raynaTourPolicyModel = data
            self._loadData()
        }
    }
    
    private func _requestWhosinTourPolicy() {
        let option = BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == tourOptionModel?._id })
        var params: [String : Any] = ["ticketId": tourOptionModel?.customTicketId ?? kEmptyString,
                                      "optionId": tourOptionModel?._id ?? kEmptyString,
                                      "date": option?.tourDate ?? "",
                                      "time": option?.timeSlot ?? "00:00:00",
                                      "adults": option?.adult ?? 1,
                                      "childs": option?.child ?? 0,
                                      "infants": option?.infant ?? 0]
        if !self.params.isEmpty {
            params = self.params
        }
        WhosinServices.whsoinBookingRules(params: params) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self._raynaTourPolicyModel = data
            self._loadData()
        }
    }
    
    private func _requestOctoPolicy() {
        let option = BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == optionId })
        var params: [String : Any] = ["tourId": option?.tourId ?? "",
                                      "optionId": optionId,
                                      "date": Utils.stringIsNullOrEmpty(option?.tourDate) ? Utils.dateToString(Calendar.current.date(byAdding: .day, value: 1, to: Date()), format: kFormatDate) : option?.tourDate ?? ""]
        if !self.params.isEmpty {
            params = self.params
        }
        WhosinServices.octoPolicy(params: params) { [weak self] container, error in
            guard let self = self else {
                self?._loadData()
                return
            }
            if error != nil {
                self._loadData()
            }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self._octoPolicy = data
            self._loadData()
        }
    }
    
    private func _requestWhosinTicketRules() {
        let option = BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == tourOptionModel?.optionId })
        var params: [String : Any] = ["tourId": option?.tourId ?? kEmptyString,
                                      "tourOptionId": option?.optionId ?? kEmptyString,
                                      "slotId": option?.timeSlotId ?? "",
                                      "date": option?.tourDate ?? "",
                                      "time": option?.timeSlot ?? "00:00:00",
                                      "adults": option?.adult ?? 1,
                                      "childs": option?.child ?? 0,
                                      "infants": option?.infant ?? 0]
        if !self.params.isEmpty {
            params = self.params
        }
        WhosinServices.whsoinTicketRules(params: params) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container?.data else { return }
            self._raynaTourPolicyModel = data
            self._loadData()
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _loadData(_ isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        if isLoading {
            cellData.append([
                kCellIdentifierKey: kCellIdentifierLoading,
                kCellTagKey: kCellIdentifierLoading,
                kCellObjectDataKey: true,
                kCellClassKey: LoadingCell.self,
                kCellHeightKey: LoadingCell.height
            ])
        }
        
        if !_raynaTourPolicyModel.isEmpty && !isLoading{
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellTagKey: kCellIdentifier,
                kCellObjectDataKey: true,
                kCellClassKey: CancellationPolicyTableCell.self,
                kCellHeightKey: CancellationPolicyTableCell.height
            ])
            
            _raynaTourPolicyModel.forEach { policies in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellTagKey: kCellIdentifier,
                    kCellObjectDataKey: policies,
                    kCellClassKey: CancellationPolicyTableCell.self,
                    kCellHeightKey: CancellationPolicyTableCell.height
                ])
            }
        }
        
        if !Utils.stringIsNullOrEmpty(tourOptionModel?.optionDetail?.cancellationPolicyDescription) && !isLoading {
            cellData.append([
                kCellIdentifierKey: kCellIdentifierDesc,
                kCellTagKey: kCellIdentifierDesc,
                kCellObjectDataKey: tourOptionModel?.optionDetail?.cancellationPolicyDescription ?? kEmptyString,
                kCellClassKey: CancellationDescTableCell.self,
                kCellHeightKey: CancellationDescTableCell.height
            ])
        } else if !Utils.stringIsNullOrEmpty(tourOptionDataModel?.cancellationPolicyDescription) {
            cellData.append([
                kCellIdentifierKey: kCellIdentifierDesc,
                kCellTagKey: kCellIdentifierDesc,
                kCellObjectDataKey: tourOptionDataModel?.cancellationPolicyDescription ?? kEmptyString,
                kCellClassKey: CancellationDescTableCell.self,
                kCellHeightKey: CancellationDescTableCell.height
            ])
        }
        
        if !Utils.stringIsNullOrEmpty(_octoPolicy) {
            cellData.append([
                kCellIdentifierKey: kCellIdentifierDesc,
                kCellTagKey: kCellIdentifierDesc,
                kCellObjectDataKey: _octoPolicy,
                kCellClassKey: CancellationDescTableCell.self,
                kCellHeightKey: CancellationDescTableCell.height
            ])
            
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: String(describing: CancellationPolicyTableCell.self), kCellClassKey: CancellationPolicyTableCell.self, kCellHeightKey: CancellationPolicyTableCell.height],
                 [kCellIdentifierKey: kCellIdentifierDesc, kCellNibNameKey: String(describing: CancellationDescTableCell.self), kCellClassKey: CancellationDescTableCell.self, kCellHeightKey: CancellationDescTableCell.height],
                 [kCellIdentifierKey: kCellIdentifierLoading, kCellNibNameKey: kCellIdentifierLoading, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height]
        ]
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
    @IBAction func _handleCloseEvent(_ sender: UIButton) {
        dismissOrBack()
    }
    
}

extension CancellationPolicyBottomSheet: CustomNoKeyboardTableViewDelegate {
    
    // --------------------------------------
    // MARK: <CustomTableViewDelegate>
    // --------------------------------------
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? CancellationPolicyTableCell {
            if let object = cellDict?[kCellObjectDataKey] as? TourPolicyModel {
                cell.setupData(object)
                let lastRow = _raynaTourPolicyModel.count
                let isLastRow = indexPath.row == lastRow
                cell.setCorners(lastRow: isLastRow, firstRow: false)
            } else if let object = cellDict?[kCellObjectDataKey] as? Bool {
                cell.setupFirstCellData()
            }
        } else if let cell = cell as? CancellationDescTableCell {
            if let object = cellDict?[kCellObjectDataKey] as? String {
                cell._descLabel.text = Utils.convertHTMLToPlainText(from: object)
            }
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
    }
    
    
}
