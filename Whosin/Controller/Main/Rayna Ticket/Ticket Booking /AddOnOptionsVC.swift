import UIKit

final class AddOnOptionsVC: ChildViewController {
    
    // --------------------------------------
    // MARK: Outlets
    // --------------------------------------
    
    @IBOutlet private weak var _tableView: CustomNoKeyboardTableView!
    @IBOutlet private weak var _nextButton: CustomActivityButton!
    @IBOutlet weak var _priceView: UIView!
    @IBOutlet weak var _totalPriceLabel: CustomLabel!
    
    // --------------------------------------
    // MARK: Constants
    // --------------------------------------
    
    private static let kCellIdentifier = String(describing: AddOnOptionsTableCell.self)
    private static let kCellIdentifierLoading = String(describing: LoadingCell.self)
    private static let kCellIdentifierDesc = String(describing: CancellationDescTableCell.self)
    
    // --------------------------------------
    // MARK: Variables
    // --------------------------------------
    
    private var _groupedTourOptionsModel: [[TourOptionsModel]] = []
    private var _whosinOptionsModel: [TourOptionsModel] = []
    private var _juniperOptionModel: [ServiceModel] = []
    private var _jpHotelModel: JPHotelAvailibilityModel?
    
    private struct AddOnSection {
        let title: String
        let parentOptionId: String
        let options: [TourOptionsModel]
    }
    private var _addOnSections: [AddOnSection] = []
    
    public var ticketModel: TicketModel?
    public var _addOnOptions: [TourOptionsModel] = []
    public var params: [String: Any] = [:]
    
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
    
    private lazy var _prototypes: [[String: Any]] = [
        [
            kCellIdentifierKey: Self.kCellIdentifier,
            kCellNibNameKey: String(describing: AddOnOptionsTableCell.self),
            kCellClassKey: AddOnOptionsTableCell.self,
            kCellHeightKey: AddOnOptionsTableCell.height
        ],
        [
            kCellIdentifierKey: Self.kCellIdentifierLoading,
            kCellNibNameKey: Self.kCellIdentifierLoading,
            kCellClassKey: LoadingCell.self,
            kCellHeightKey: LoadingCell.height
        ]
    ]
    
    private func setupUI() {
        _tableView.setup(
            cellPrototypes: _prototypes,
            hasHeaderSection: true,
            hasFooterSection: false,
            isHeaderCollapsible: true,
            isDummyLoad: false,
            enableRefresh: false,
            emptyDataText: "no_tour_options".localized(),
            emptyDataIconImage: UIImage(named: "empty_event"),
            emptyDataDescription: nil,
            delegate: self)
        _tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        _tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
        _nextButton.isEnabled = false

        _requestWhosinAddOnAvailability()
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    private func _requestWhosinAddOnAvailability(_ date: Date? = nil) {

        BOOKINGMANAGER.bookingModel.tourDetails.forEach { option in
            _loadData(true)
            let selectedOptions = BOOKINGMANAGER.ticketModel?.optionData.first(where: { $0._id == option.optionId })
            let addonOptionsIds = selectedOptions?.addonOptionIds.toArray(ofType: String.self) ?? []
            
            let params: [String: Any] = [
                "optionId": option.optionId,
                "addonOptionIds": addonOptionsIds,
                "adults": option.adult,
                "childs": option.child,
                "date": option.tourDate
            ]
            
            WhosinServices.whosinAddOnAvailability(params: params) { [weak self] container, error in
                guard let self = self else { return }
                if let error = error, error.localizedDescription.localizedCaseInsensitiveContains("Session expired, please login again!") {
                    self.alert(message: "session_expired".localized()) { UIAlertAction in
                        APPSESSION.logout { [weak self] success, error in
                            guard let self = self else { return }
                            self.hideHUD(error: error)
                            self._loadData()
                            guard success else { return }
                            guard let window = APP.window else { return }
                            let navController = NavigationController(rootViewController: INIT_CONTROLLER_XIB(LoginVC.self))
                            navController.setNavigationBarHidden(true, animated: false)
                            window.setRootViewController(navController, options: UIWindow.TransitionOptions(direction:.fade, style: .easeInOut))
                        }
                    }
                    return
                }
                self.hideHUD(error: error)
                guard let data = container?.data else { return }
                self._addOnOptions = data
                let parentId = selectedOptions?._id ?? ""
                self._addOnSections.append(AddOnSection(title: selectedOptions?.optionName ?? "", parentOptionId: parentId, options: data))
                self._loadData()
            }
        }
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _loadData(_ isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        
        if isLoading {
            var cellData = [[String: Any]]()
            cellData.append([
                kCellIdentifierKey: Self.kCellIdentifierLoading,
                kCellTagKey: Self.kCellIdentifierLoading,
                kCellObjectDataKey: "loading",
                kCellClassKey: LoadingCell.self,
                kCellHeightKey: LoadingCell.height
            ])
            cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        } else {
            _addOnSections.forEach { section in
                var cellData = [[String: Any]]()
                section.options.forEach { model in
                    cellData.append([
                        kCellIdentifierKey: Self.kCellIdentifier,
                        kCellTagKey: section.parentOptionId,
                        kCellObjectDataKey: model,
                        kCellClassKey: AddOnOptionsTableCell.self,
                        kCellHeightKey: AddOnOptionsTableCell.height
                    ])
                }
                cellSectionData.append([
                    kSectionTitleKey: section.title,
                    kSectionDataKey: cellData,
                    kSectionCollapsedKey: true // Expanded by default
                ])
            }
        }
        
        _tableView.loadData(cellSectionData)
    }
    
    // check minimum pax validation
    private func isMinPax(_ adult: Int, child: Int, infant: Int, minPax: Int? = nil) -> Bool {
        let totalGuests = adult + child + infant
        return totalGuests < (minPax ?? ticketModel?.minPax ?? 0)
    }
    
    // --------------------------------------
    // MARK: Events
    // --------------------------------------
    
    @IBAction private func _handleCloseEvent(_ sender: UIButton) {
        dismissOrBack()
    }
    
    @IBAction private func _handleNextEvent(_ sender: UIButton) {
        var isValidate: Bool = true
        guard ticketModel?.allowAdult == true || ticketModel?.allowChild == true || ticketModel?.allowInfant == true else {
            alert(title: kAppName, message: "tour_option_not_allow_pax".localized())
            isValidate = false
            return
        }
        
        if BOOKINGMANAGER.bookingModel.tourDetails.isEmpty {
            alert(title: kAppName, message: "select_tour_options".localized())
            isValidate = false
            return
        }
        
        for model in BOOKINGMANAGER.bookingModel.tourDetails {
            if let option = BOOKINGMANAGER.optionsList.first(where: { BOOKINGMANAGER.matchesOption($0, optionId: model.optionId, transferId: model.transferId) }) {
                let name = Utils.stringIsNullOrEmpty(option.optionDetail?.optionName) ? option.optionName : option.optionDetail?.optionName ?? "option"

                if option.optionDetail?.isWithoutAdult == false && model.adult < 1 {
                    alert(message: LANGMANAGER.localizedString(forKey: "adult_required_alert", arguments: ["value": name]))
                    isValidate = false
                    break
                }
                
                if Utils.stringIsNullOrEmpty(model.tourDate) {
                    alert(message: LANGMANAGER.localizedString(forKey: "date_required_alert", arguments: ["value": name]))
                    isValidate = false
                    break
                }
                
                if option.isSlot && Utils.stringIsNullOrEmpty(model.timeSlotId) {
                    alert(message: LANGMANAGER.localizedString(forKey: "time_required_alert", arguments: ["value": name]))
                    isValidate = false
                    break
                }
                
                if model.adult < 1 && model.child < 1 && model.infant < 1 {
                    alert(message: LANGMANAGER.localizedString(forKey: "pax_required_alert", arguments: ["value": name]))
                    isValidate = false
                    break
                }
                
                if isMinPax(model.adult, child: model.child, infant: model.infant) {
                    alert(message: LANGMANAGER.localizedString(forKey: "min_pax_alert", arguments: ["value1": "\(ticketModel?.minPax ?? 0) \(option.unit)", "value3": "\(option.optionDetail?.optionName ?? "")", "value2": Utils.stringIsNullOrEmpty(option.unit) ? "passenger" : option.unit ]))
                    isValidate = false
                    break
                }
            } else if let option = _whosinOptionsModel.first(where: { $0._id == model.optionId }), ticketModel?.bookingType == "whosin" {
                let name = Utils.stringIsNullOrEmpty(option.optionDetail?.optionName) ? option.optionName : option.optionDetail?.optionName ?? "option"

                if option.optionDetail?.isWithoutAdult == false && model.adult < 1 {
                    alert(message: LANGMANAGER.localizedString(forKey: "adult_required_alert", arguments: ["value": name]))
                    isValidate = false
                    break
                }
                
                if Utils.stringIsNullOrEmpty(model.tourDate) {
                    alert(message: LANGMANAGER.localizedString(forKey: "date_required_alert", arguments: ["value": "\(option.optionDetail?.optionName ?? "")"]))
                    isValidate = false
                    break
                }
                
                if option.isSlot && Utils.stringIsNullOrEmpty(model.timeSlotId) {
                    alert(message: LANGMANAGER.localizedString(forKey: "time_required_alert", arguments: ["value": name]))
                    isValidate = false
                    break
                }
                
                if model.adult < 1 && model.child < 1 && model.infant < 1 {
                    alert(message: LANGMANAGER.localizedString(forKey: "pax_required_alert", arguments: ["value": name]))
                    isValidate = false
                    break
                }
                
                if isMinPax(model.adult, child: model.child, infant: model.infant) {
                    alert(message: LANGMANAGER.localizedString(forKey: "min_pax_alert", arguments: ["value1": "\(ticketModel?.minPax ?? 0) \(option.unit)", "value3": "\(option.optionDetail?.optionName ?? "")", "value2": Utils.stringIsNullOrEmpty(option.unit) ? "passenger" : option.unit ]))
                    isValidate = false
                    break
                }
            } else if let travel = BOOKINGMANAGER.ticketModel?.travelDeskTourData.first?.optionData.first(where: { "\($0.id)" == model.optionId}) {
                if Utils.stringIsNullOrEmpty(model.tourDate) {
                    alert(message: LANGMANAGER.localizedString(forKey: "date_required_alert", arguments: ["value": "\(travel.name)"]))
                    isValidate = false
                    break
                }
                
                if Utils.stringIsNullOrEmpty(model.timeSlotId) {
                    alert(message: LANGMANAGER.localizedString(forKey: "time_required_alert", arguments: ["value": "\(travel.name)"]))
                    isValidate = false
                    break
                }
                
                if model.adult < 1 && model.child < 1 && model.infant < 1 {
                    alert(message: LANGMANAGER.localizedString(forKey: "pax_required_alert", arguments: ["value": "\(travel.name)"]))
                    isValidate = false
                    break
                }
                
                if isMinPax(model.adult, child: model.child, infant: model.infant, minPax: travel.minNumOfPeople) {
                    alert(message: LANGMANAGER.localizedString(forKey: "min_pax_alert", arguments: ["value1": "\(ticketModel?.minPax ?? 0)", "value3": "\(travel.name)", "value2": Utils.stringIsNullOrEmpty(travel.unit) ? "passenger" : travel.unit ]))
                    isValidate = false
                    break
                }
                
            } else if let whosinTicket = BOOKINGMANAGER.ticketModel?.whosinModuleTourData.first?.optionData.first(where: { $0.optionId == model.optionId}) {
                if Utils.stringIsNullOrEmpty(model.tourDate) {
                    alert(message: LANGMANAGER.localizedString(forKey: "date_required_alert", arguments: ["value": whosinTicket.displayName]))
                    isValidate = false
                    break
                }
                
                if Utils.stringIsNullOrEmpty(model.timeSlotId) {
                    alert(message: LANGMANAGER.localizedString(forKey: "time_required_alert", arguments: ["value": whosinTicket.displayName]))
                    isValidate = false
                    break
                }
                
                if model.adult < 1 && model.child < 1 && model.infant < 1 {
                    alert(message: LANGMANAGER.localizedString(forKey: "pax_required_alert", arguments: ["value": whosinTicket.displayName]))
                    isValidate = false
                    break
                }
                
                if isMinPax(model.adult, child: model.child, infant: model.infant, minPax: Int(whosinTicket.minPaxString)) {
                    alert(message: LANGMANAGER.localizedString(forKey: "min_pax_alert", arguments: ["value1": "\(ticketModel?.minPax ?? 0)", "value3": "\(whosinTicket.displayName)", "value2": Utils.stringIsNullOrEmpty(whosinTicket.unit) ? "passenger" : whosinTicket.unit ]))
                    isValidate = false
                    break
                }
                
            } else if let bigbusTicket = BOOKINGMANAGER.ticketModel?.bigBusTourData.first?.options.first(where: { $0.id == model.optionId}) {
                if Utils.stringIsNullOrEmpty(model.tourDate) {
                    alert(message: LANGMANAGER.localizedString(forKey: "date_required_alert", arguments: ["value": bigbusTicket.title]))
                    isValidate = false
                    break
                }
                
                if bigbusTicket.pickupRequired {
                    if Utils.stringIsNullOrEmpty(model.pickup) {
                        alert(message: LANGMANAGER.localizedString(forKey: "pickup_alert", arguments: ["value": bigbusTicket.title]))
                        isValidate = false
                        break
                    }
                }
                
                if Utils.stringIsNullOrEmpty(model.timeSlot) {
                    alert(message: LANGMANAGER.localizedString(forKey: "time_required_alert", arguments: ["value": bigbusTicket.title]))
                    isValidate = false
                    break
                }
                
                if model.adult < 1 && model.child < 1 && model.infant < 1 {
                    alert(message: LANGMANAGER.localizedString(forKey: "pax_required_alert", arguments: ["value": bigbusTicket.title]))
                    isValidate = false
                    break
                }
                
                if isMinPax(model.adult, child: model.child, infant: model.infant, minPax: Int(bigbusTicket.restrictions?.minPaxCount ?? 0)) {
                    alert(message: LANGMANAGER.localizedString(forKey: "min_pax_alert", arguments: ["value1": "\(ticketModel?.minPax ?? 0)", "value3": "\(bigbusTicket.title)", "value2": Utils.stringIsNullOrEmpty(bigbusTicket.unit) ? "passenger" : bigbusTicket.unit ]))
                    isValidate = false
                    break
                }
            }
        }
        
        guard isValidate else { return }
        
        let vc = INIT_CONTROLLER_XIB(ParticipantDetailVC.self)
        vc.modalPresentationStyle = .overFullScreen
        navigationController?.pushViewController(vc, animated: true)
        
    }
}

extension AddOnOptionsVC: CustomNoKeyboardTableViewDelegate {
    
    // --------------------------------------
    // MARK: <CustomTableViewDelegate>
    // --------------------------------------
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? AddOnOptionsTableCell {
            if let object = cellDict?[kCellObjectDataKey] as? [TourOptionsModel] {
                cell.setupData(object, isSelected: false, discount: ticketModel?.discount ?? 0)
                cell.callback = { [weak self] in
                    guard let self = self else { return }
                    self._nextButton.isEnabled = !BOOKINGMANAGER.bookingModel.tourDetails.isEmpty
                    self._nextButton.backgroundColor = BOOKINGMANAGER.bookingModel.tourDetails.isEmpty ? UIColor(hexString: "#ADADAD") : ColorBrand.brandPink
                    self._tableView.reload()
                }
            } else if let object = cellDict?[kCellObjectDataKey] as? TourOptionsModel, let type = cellDict?[kCellTagKey] as? String, type == "whosin-ticket" {
                cell.setWhosinModule(object, isSelected: false, discount: ticketModel?.discount ?? 0)
            } else if let object = cellDict?[kCellObjectDataKey] as? TourOptionsModel, let parentId = cellDict?[kCellTagKey] as? String {
                cell.setupAddonData(object, parentOptionId: parentId, isSelected: false, discount: BOOKINGMANAGER.ticketModel?.discount ?? 0)
                cell.callback = { [weak self] in
                    guard let self = self else { return }
                    self._nextButton.isEnabled = !BOOKINGMANAGER.bookingModel.tourDetails.isEmpty
                    self._nextButton.backgroundColor = BOOKINGMANAGER.bookingModel.tourDetails.isEmpty ? UIColor(hexString: "#ADADAD") : ColorBrand.brandPink
                    self._tableView.reload()
                }
                let isLastCell = indexPath.row == _tableView.numberOfRows(inSection: indexPath.section) - 1
                cell._mainView.clipsToBounds = true
                if isLastCell {
                    cell._mainView.layer.cornerRadius = 10
                    cell._mainView.layer.maskedCorners = [
                        .layerMinXMaxYCorner,
                        .layerMaxXMaxYCorner
                    ]
                } else {
                    cell._mainView.layer.cornerRadius = 0
                    cell._mainView.layer.maskedCorners = []
                }
            } else if let object = cellDict?[kCellObjectDataKey] as? TourOptionModel {
                cell.setupData(object, isSelected: false, discount: BOOKINGMANAGER.ticketModel?.discount ?? 0)
            } else if let object = cellDict?[kCellObjectDataKey] as? BigBusOptionsModel {
                cell.setupData(object, isSelected: false, discount: BOOKINGMANAGER.ticketModel?.discount ?? 0)
            }
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
    }
    
}
