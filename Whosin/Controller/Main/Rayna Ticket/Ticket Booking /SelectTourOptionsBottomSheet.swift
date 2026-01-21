import UIKit

final class SelectTourOptionsBottomSheet: ChildViewController {
    
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
    
    private static let kCellIdentifier = String(describing: TourOptionsTableCell.self)
    private static let kCellIdentifierLoading = String(describing: LoadingCell.self)
    private static let kCellIdentifierDesc = String(describing: CancellationDescTableCell.self)
    
    // --------------------------------------
    // MARK: Variables
    // --------------------------------------
    
    private var _groupedTourOptionsModel: [[TourOptionsModel]] = []
    private var _whosinOptionsModel: [TourOptionsModel] = []
    private var _juniperOptionModel: [ServiceModel] = []
    private var _jpHotelModel: JPHotelAvailibilityModel?
    
    public var ticketModel: TicketModel?
    public var params: [String: Any] = [:]
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if BOOKINGMANAGER.ticketModel == nil {
            _requestTicketDetail()
        }
        setupUI()
        // Ticket price update from booking manager callback
        BOOKINGMANAGER.onItemChange = { [weak self] in
            guard let self = self else { return }
            let totalAmount = BOOKINGMANAGER.getTotalAmount()
            let plainTitle = NSAttributedString(string: "next".localized(), attributes: [
                .font: self._nextButton.titleLabel?.font ?? UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.white
            ])
            if totalAmount > 0 {
                self._priceView.isHidden = false
                self._totalPriceLabel.textColor = ColorBrand.black
                self._totalPriceLabel.setPrice(totalAmount) // Changed here as requested
                self._nextButton.setAttributedTitle(plainTitle, for: .normal)
            } else {
                self._priceView.isHidden = true
                self._nextButton.setAttributedTitle(plainTitle, for: .normal)
            }
            self._nextButton.isEnabled = !BOOKINGMANAGER.bookingModel.tourDetails.isEmpty
            self._nextButton.backgroundColor = BOOKINGMANAGER.bookingModel.tourDetails.isEmpty ? UIColor(hexString: "#ADADAD") : ColorBrand.brandPink
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            BOOKINGMANAGER.clearManager()
        }
    }
    
    // --------------------------------------
    // MARK: SetUp
    // --------------------------------------
    
    private lazy var _prototypes: [[String: Any]] = [
        [
            kCellIdentifierKey: Self.kCellIdentifier,
            kCellNibNameKey: String(describing: TourOptionsTableCell.self),
            kCellClassKey: TourOptionsTableCell.self,
            kCellHeightKey: TourOptionsTableCell.height
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
            hasHeaderSection: false,
            hasFooterSection: false,
            isHeaderCollapsible: false,
            isDummyLoad: false,
            enableRefresh: false,
            emptyDataText: "no_tour_options".localized(),
            emptyDataIconImage: UIImage(named: "empty_event"),
            emptyDataDescription: nil,
            delegate: self)
        _tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        _loadData(true)
        _tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
        _nextButton.isEnabled = false
        switch ticketModel?.bookingType {
        case "rayna":
            _requestRaynaTourOptions()
        case "travel-desk", "whosin-ticket":
            _loadData()
        case "big-bus", "hero-balloon":
            _loadData()
        case "hotel":
            _requestJPHotelAvailibility()
        default:
            _requestWhosinTourOptions()
        }
        NotificationCenter.default.addObserver(forName: .reloadOptions, object: nil, queue: .main) { [weak self] notification in
            guard let self = self else { return }
            if let date = notification.userInfo?["date"] as? Date {
                switch self.ticketModel?.bookingType {
                case "rayna":
                    self._requestRaynaTourOptions(date)
                case "whosin":
                    self._requestWhosinTourOptions(date)
                default:
                    break
                }
            }
        }
        if let id = ticketModel?._id, let name = ticketModel?.title {
            LOGMANAGER.logTicketEvent(.viewTicket, id: id, name: name)
        }
    }
    
    // --------------------------------------
    // MARK: Services
    // --------------------------------------
    
    private func _requestTicketDetail() {
        guard let id = ticketModel?._id else { return }
        WhosinServices.getTicketDetail(id: id) { [weak self] container, _ in
            guard let self = self else {
                self?._loadData()
                return
            }
            guard let data = container?.data else { return }
            BOOKINGMANAGER.ticketModel = data
            switch data.bookingType {
            case "whosin":
                self._requestWhosinTourOptions()
            case "juniper":
                self._requestJuniperTourOptions()
            case "travel-desk", "whosin-ticket":
                self._loadData()
            default:
                self._requestRaynaTourOptions()
            }
        }
    }
    
    private func _requestWhosinTourOptions(_ date: Date? = nil) {
        if date != nil {
            showHUD()
        }
        let ticketId = ticketModel?._id ?? ""
        let dates = Utils.dateToString(date ?? Date(), format: kFormatDate)
        
        let params: [String: Any] = [
            "ticketId": ticketId,
            "adults": 1,
            "childs": 0,
            "infants": 0,
            "date": dates
        ]
        
        WhosinServices.whosinAvailability(params: params) { [weak self] container, error in
            guard let self = self else { return }
            if let error = error, error.localizedDescription.localizedCaseInsensitiveContains("Session expired, please login again!") {
                self.alert(message: "session_expired".localized()) { UIAlertAction in
                    APPSESSION.logout { [weak self] success, error in
                        guard let self = self else { return }
                        self.hideHUD(error: error)
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
            if error != nil { _loadData(false) }
            guard let data = container?.data else { return }
            self._whosinOptionsModel = data.sorted(by: { $0.order < $1.order })
            BOOKINGMANAGER.whosinOptionsList = data
            self._loadData()
        }
    }
    
    private func _requestJPHotelAvailibility() {
       
        WhosinServices.jpHotelAvailability(params: params) { [weak self] container, error in
            guard let self = self else { return }
            if let error = error, error.localizedDescription.localizedCaseInsensitiveContains("Session expired, please login again!") {
                self.alert(message: "session_expired".localized()) { UIAlertAction in
                    APPSESSION.logout { [weak self] success, error in
                        guard let self = self else { return }
                        self.hideHUD(error: error)
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
            if error != nil { _loadData(false) }
            guard let data = container?.data else { return }
            self._jpHotelModel = data
            self._loadData()
        }
    }
    
    private func _requestJuniperTourOptions() {
        let code = BOOKINGMANAGER.ticketModel?.code ?? ""
        
        let params: [String: Any] = [
            "serviceCode": code,
            "date": Utils.dateToString(BOOKINGMANAGER.date, format: kFormatDate),
            "childs": BOOKINGMANAGER.adults,
            "adults": BOOKINGMANAGER.childs,
            "infants": BOOKINGMANAGER.infants
        ]
        
        WhosinServices.juniperTicketAvailability(params: params) { [weak self] container, error in
            guard let self = self else { return }
            if let error = error, error.localizedDescription.localizedCaseInsensitiveContains("Session expired, please login again!") {
                self.alert(message: "session_expired".localized()) { UIAlertAction in
                    APPSESSION.logout { [weak self] success, error in
                        guard let self = self else { return }
                        self.hideHUD(error: error)
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
            if error != nil { _loadData(false) }
            guard let data = container?.data else { return }
            self._juniperOptionModel = data
            self._loadData()
        }
    }
    
    private func _requestRaynaTourOptions(_ date: Date? = nil) {
        if date != nil {
            showHUD()
        }
        let tourId = Utils.stringIsNullOrEmpty(BOOKINGMANAGER.ticketModel?.tourId) ? BOOKINGMANAGER.ticketModel?.tourData?.tourId ?? kEmptyString : BOOKINGMANAGER.ticketModel?.tourId ?? kEmptyString
        let contractId = Utils.stringIsNullOrEmpty(BOOKINGMANAGER.ticketModel?.contractId) ? BOOKINGMANAGER.ticketModel?.tourData?.contractId ?? kEmptyString : BOOKINGMANAGER.ticketModel?.contractId ?? kEmptyString
        let dates = Utils.dateToStringWithTimezone(date ?? Date(), format: kFormatDateLocal)
        
        let params: [String: Any] = [
            "tourId": tourId,
            "contractId": contractId,
            "date": Utils.dateToString(Utils.stringToDate(dates, format: kFormatDateLocal), format: kFormatDate),
            "noOfAdult": 1,
            "noOfChild": 0,
            "noOfInfant": 0
        ]
        
        WhosinServices.raynaTourOptions(params: params) { [weak self] container, error in
            guard let self = self else { return }
            if let error = error, error.localizedDescription.localizedCaseInsensitiveContains("Session expired, please login again!") {
                self.alert(message: "session_expired".localized()) { UIAlertAction in
                    APPSESSION.logout { [weak self] success, error in
                        guard let self = self else { return }
                        self.hideHUD(error: error)
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
            if error != nil { _loadData(false) }
            guard let data = container?.data else { return }
            self._groupedTourOptionsModel.removeAll()

            let groupedDict = Dictionary(grouping: data) { $0.tourOptionId }

            let optionsList = groupedDict
                .sorted { $0.key < $1.key }
                .map { $0.value.sorted { $0.order < $1.order } }

            self._groupedTourOptionsModel = optionsList

            BOOKINGMANAGER.optionsList = data
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
                kCellIdentifierKey: Self.kCellIdentifierLoading,
                kCellTagKey: Self.kCellIdentifierLoading,
                kCellObjectDataKey: "loading",
                kCellClassKey: LoadingCell.self,
                kCellHeightKey: LoadingCell.height
            ])
        } else {
            if !_groupedTourOptionsModel.isEmpty {
                _groupedTourOptionsModel.forEach { policies in
                    cellData.append([
                        kCellIdentifierKey: Self.kCellIdentifier,
                        kCellTagKey: Self.kCellIdentifier,
                        kCellObjectDataKey: policies,
                        kCellClassKey: TourOptionsTableCell.self,
                        kCellHeightKey: TourOptionsTableCell.height
                    ])
                }
            } else if !_whosinOptionsModel.isEmpty, ticketModel?.bookingType == "whosin" {
                _whosinOptionsModel.forEach { model in
                    cellData.append([
                        kCellIdentifierKey: Self.kCellIdentifier,
                        kCellTagKey: Self.kCellIdentifier,
                        kCellObjectDataKey: model,
                        kCellClassKey: TourOptionsTableCell.self,
                        kCellHeightKey: TourOptionsTableCell.height
                    ])
                }
            } else if let firstWhosinOptionData = ticketModel?.whosinModuleTourData.first?.optionData, !firstWhosinOptionData.isEmpty, ticketModel?.bookingType == "whosin-ticket" {
                firstWhosinOptionData.forEach { model in
                    cellData.append([
                        kCellIdentifierKey: Self.kCellIdentifier,
                        kCellTagKey: "whosin-ticket",
                        kCellObjectDataKey: model,
                        kCellClassKey: TourOptionsTableCell.self,
                        kCellHeightKey: TourOptionsTableCell.height
                    ])
                }
            } else if let firstTravelDeskOptionData = ticketModel?.travelDeskTourData.first?.optionData, !firstTravelDeskOptionData.isEmpty {
                firstTravelDeskOptionData.forEach { model in
                    cellData.append([
                        kCellIdentifierKey: Self.kCellIdentifier,
                        kCellTagKey: Self.kCellIdentifier,
                        kCellObjectDataKey: model,
                        kCellClassKey: TourOptionsTableCell.self,
                        kCellHeightKey: TourOptionsTableCell.height
                    ])
                }

            } else if let firstBigBusOptions = ticketModel?.bigBusTourData.first?.options, !firstBigBusOptions.isEmpty {
                firstBigBusOptions.forEach { model in
                    cellData.append([
                        kCellIdentifierKey: Self.kCellIdentifier,
                        kCellTagKey: Self.kCellIdentifier,
                        kCellObjectDataKey: model,
                        kCellClassKey: TourOptionsTableCell.self,
                        kCellHeightKey: TourOptionsTableCell.height
                    ])
                }
            } else if let jpHotelTourData = _jpHotelModel?.hotelOptions, !jpHotelTourData.isEmpty {
                jpHotelTourData.forEach { model in
                    cellData.append([
                        kCellIdentifierKey: Self.kCellIdentifier,
                        kCellTagKey: Self.kCellIdentifier,
                        kCellObjectDataKey: model,
                        kCellClassKey: TourOptionsTableCell.self,
                        kCellHeightKey: TourOptionsTableCell.height
                    ])
                }

            }
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
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
        BOOKINGMANAGER.clearManager()
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
                    let name = Utils.stringIsNullOrEmpty(option.optionDetail?.optionName) ? option.optionName : option.optionDetail?.optionName ?? "option"
                    alert(message: LANGMANAGER.localizedString(forKey: "date_required_alert", arguments: ["value": "\(name)"]))
                    isValidate = false
                    break
                }
                
                if option.isSlot && Utils.stringIsNullOrEmpty(model.timeSlotId) {
                    let name = Utils.stringIsNullOrEmpty(option.optionDetail?.optionName) ? option.optionName : option.optionDetail?.optionName ?? "option"
                    alert(message: LANGMANAGER.localizedString(forKey: "time_required_alert", arguments: ["value": name]))
                    isValidate = false
                    break
                }
                
                if model.adult < 1 && model.child < 1 && model.infant < 1 {
                    let name = Utils.stringIsNullOrEmpty(option.optionDetail?.optionName) ? option.optionName : option.optionDetail?.optionName ?? "option"
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
        
        switch ticketModel?.bookingType {
        case "whosin":
            _requestWhosinTourPolicy { [weak self] success in
                guard let self = self else { return }
                if success {
                    guard isValidate else { return }
                    let vc = INIT_CONTROLLER_XIB(ParticipantDetailVC.self)
                    vc.modalPresentationStyle = .overFullScreen
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    print("Failed to fetch policy.")
                }
            }
        case "rayna":
            _requestRaynaTourPolicy { [weak self] success in
                guard let self = self else { return }
                if success {
                    guard isValidate else { return }
                    let vc = INIT_CONTROLLER_XIB(ParticipantDetailVC.self)
                    vc.modalPresentationStyle = .overFullScreen
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    print("Failed to fetch policy.")
                }
            }
        case "travel-desk":
            _requestTravelPolicy { [weak self] success in
                guard let self = self else { return }
                if success {
                    guard isValidate else { return }
                    let vc = INIT_CONTROLLER_XIB(ParticipantDetailVC.self)
                    vc.modalPresentationStyle = .overFullScreen
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    print("Failed to fetch policy.")
                }
            }
        case "whosin-ticket":
            _requestWhosinTicketrules { [weak self] success in
                guard let self = self else { return }
                if success {
                    guard isValidate else { return }
                    let vc = INIT_CONTROLLER_XIB(ParticipantDetailVC.self)
                    vc.modalPresentationStyle = .overFullScreen
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    print("Failed to fetch policy.")
                }
            }
        case "big-bus", "hero-balloon":
            let vc = INIT_CONTROLLER_XIB(ParticipantDetailVC.self)
            vc.modalPresentationStyle = .overFullScreen
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
        
    }
    
    private func _requestRaynaTourPolicy(completion: @escaping (Bool) -> Void) {
        showHUD()
        BOOKINGMANAGER.bookingModel.cancellationPolicy.removeAll()
        
        let options = BOOKINGMANAGER.bookingModel.tourDetails
        var completedRequests = 0
        var hasErrorOccurred = false
        
        guard !options.isEmpty else {
            hideHUD()
            completion(true)
            return
        }
        
        for option in options {
            let currentOption = BOOKINGMANAGER.optionsList.first(where: { BOOKINGMANAGER.matchesOption($0, optionId: option.optionId, transferId: option.transferId) })
            let params: [String: Any] = [
                "tourId": option.tourId,
                "tourOptionId": option.optionId,
                "contractId": BOOKINGMANAGER.ticketModel?.tourData?.contractId ?? kEmptyString,
                "date": option.tourDate,
                "time": option.startTime,
                "transferId": option.transferId,
                "noOfAdult": option.adult,
                "noOfChild": option.child,
                "noOfInfant": option.infant
            ]
            
            WhosinServices.raynaTourPolicy(params: params) { [weak self] container, error in
                guard let self = self else { return }
                
                if let error = error {
                    if !hasErrorOccurred {
                        hasErrorOccurred = true
                        self.hideHUD()
                        if error.localizedDescription.localizedCaseInsensitiveContains("cannot book this tour") {
                            alert(message: "\(error.localizedDescription) for \(currentOption?.optionDetail?.optionName ?? "")")
                        } else {
                            alert(message: error.localizedDescription)
                        }
                        completion(false)
                    }
                    return
                }
                
                if let data = container?.data {
                    BOOKINGMANAGER.bookingModel.cancellationPolicy.append(contentsOf: data)
                }
                
                completedRequests += 1
                
                if completedRequests == options.count && !hasErrorOccurred {
                    self.hideHUD()
                    completion(true)
                }
            }
        }
    }
    
    private func _requestWhosinTourPolicy(completion: @escaping (Bool) -> Void) {
        showHUD()
        BOOKINGMANAGER.bookingModel.cancellationPolicy.removeAll()
        
        let options = BOOKINGMANAGER.bookingModel.tourDetails
        var completedRequests = 0
        var hasErrorOccurred = false
        
        guard !options.isEmpty else {
            hideHUD()
            completion(true)
            return
        }
        
        for option in options {
            let currentOption = BOOKINGMANAGER.ticketModel?.optionData.first(where: { $0._id == option.optionId })
            let params: [String: Any] = [
                "ticketId": option.tourId,
                "optionId": option.optionId,
                "adults": option.adult,
                "date": option.tourDate,
                "time": option.timeSlot,
                "childs": option.child,
            ]
            
            WhosinServices.whsoinBookingRules(params: params) { [weak self] container, error in
                guard let self = self else { return }
                
                if let error = error {
                    if !hasErrorOccurred {
                        hasErrorOccurred = true
                        self.hideHUD()
                        if error.localizedDescription.localizedCaseInsensitiveContains("cannot book this tour") {
                            alert(message: "\(error.localizedDescription) for \(currentOption?.title ?? "")")
                        } else {
                            alert(message: error.localizedDescription)
                        }
                        completion(false)
                    }
                    return
                }
                
                if let data = container?.data {
                    BOOKINGMANAGER.bookingModel.cancellationPolicy.append(contentsOf: data)
                }
                
                completedRequests += 1
                
                if completedRequests == options.count && !hasErrorOccurred {
                    self.hideHUD()
                    completion(true)
                }
            }
        }
    }
    
    private func _requestTravelPolicy(completion: @escaping (Bool) -> Void) {
        showHUD()
        BOOKINGMANAGER.bookingModel.cancellationPolicy.removeAll()
        
        let options = BOOKINGMANAGER.bookingModel.tourDetails
        var completedRequests = 0
        var hasErrorOccurred = false
        
        guard !options.isEmpty else {
            hideHUD()
            completion(true)
            return
        }
        
        for option in options {
            let params: [String: Any] = [
                "tourId": option.tourId,
                "optionId": option.optionId,
                "date": option.tourDate,
            ]
            
            WhosinServices.travelTourPolicy(params: params) { [weak self] container, error in
                guard let self = self else { return }
                
                if let error = error {
                    if !hasErrorOccurred {
                        hasErrorOccurred = true
                        self.hideHUD()
                        alert(message: error.localizedDescription)
                        completion(false)
                    }
                    return
                }
                
                if let data = container?.data {
                    BOOKINGMANAGER.bookingModel.cancellationPolicy.append(contentsOf: data)
                }
                
                completedRequests += 1
                
                if completedRequests == options.count && !hasErrorOccurred {
                    self.hideHUD()
                    completion(true)
                }
            }
        }
    }
    
    private func _requestWhosinTicketrules(completion: @escaping (Bool) -> Void) {
        showHUD()
        BOOKINGMANAGER.bookingModel.cancellationPolicy.removeAll()
        
        let options = BOOKINGMANAGER.bookingModel.tourDetails
        var completedRequests = 0
        var hasErrorOccurred = false

        guard !options.isEmpty else {
            hideHUD()
            completion(true)
            return
        }
        
        for option in options {
            let currentOption = BOOKINGMANAGER.ticketModel?.whosinModuleTourData.first?.optionData.first(where: { $0.optionId == option.optionId })
            let params: [String: Any] = [
                "tourId": option.tourId,
                "tourOptionId": option.optionId,
                "slotId": option.timeSlotId,
                "adults": option.adult,
                "date": option.tourDate,
                "time": option.timeSlot,
                "childs": option.child,
            ]

            WhosinServices.whsoinTicketAvailibility(params: params) { [weak self] container, error in
                guard let self = self else { return }
                if hasErrorOccurred { return }
                
                if let error = error {
                    hasErrorOccurred = true
                    self.hideHUD()
                    let errMsg = error.localizedDescription
                    if errMsg.localizedCaseInsensitiveContains("Please provide valid date") {
                        alert(message: "\(errMsg) for \(currentOption?.displayName ?? "")")
                    } else {
                        alert(message: errMsg)
                    }
                    completion(false)
                    return
                }

                WhosinServices.whsoinTicketRules(params: params) { [weak self] container, error in
                    guard let self = self else { return }
                    if hasErrorOccurred { return }
                    if let error = error {
                        hasErrorOccurred = true
                        self.hideHUD()
                        let errMsg = error.localizedDescription
                        if errMsg.localizedCaseInsensitiveContains("cannot book this tour") {
                            alert(message: "\(errMsg) for \(currentOption?.title ?? "")")
                        } else {
                            alert(message: errMsg)
                        }
                        completion(false)
                        return
                    }

                    if let data = container?.data {
                        BOOKINGMANAGER.bookingModel.cancellationPolicy.append(contentsOf: data)
                    }

                    completedRequests += 1
                    if completedRequests == options.count && !hasErrorOccurred {
                        self.hideHUD()
                        completion(true)
                    }
                }
            }
        }
    }
}

extension SelectTourOptionsBottomSheet: CustomNoKeyboardTableViewDelegate {
    
    // --------------------------------------
    // MARK: <CustomTableViewDelegate>
    // --------------------------------------
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? TourOptionsTableCell {
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
            } else if let object = cellDict?[kCellObjectDataKey] as? TourOptionsModel {
                cell.setupData(object, isSelected: false, discount: ticketModel?.discount ?? 0)
                cell.callback = { [weak self] in
                    guard let self = self else { return }
                    self._nextButton.isEnabled = !BOOKINGMANAGER.bookingModel.tourDetails.isEmpty
                    self._nextButton.backgroundColor = BOOKINGMANAGER.bookingModel.tourDetails.isEmpty ? UIColor(hexString: "#ADADAD") : ColorBrand.brandPink
                    self._tableView.reload()
                }
            } else if let object = cellDict?[kCellObjectDataKey] as? TourOptionModel {
                cell.setupData(object, isSelected: false, discount: ticketModel?.discount ?? 0)
            } else if let object = cellDict?[kCellObjectDataKey] as? BigBusOptionsModel {
                cell.setupData(object, isSelected: false, discount: ticketModel?.discount ?? 0)
            }
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
    }
    
}
