import UIKit
import ObjectMapper

class EditTicketCartVC: ChildViewController {
    
    // --------------------------------------
    // MARK: Outlets
    // --------------------------------------
    
    @IBOutlet private weak var _tableView: CustomNoKeyboardTableView!
    @IBOutlet private weak var _nextButton: CustomActivityButton!
    @IBOutlet weak var _priceView: UIView!
    @IBOutlet weak var _totalPriceLabel: CustomLabel!
    
    // --------------------------------------
    // MARK: Variables
    // --------------------------------------
    
    private var kCellIdentifier = String(describing: TourOptionsTableCell.self)
    private var kCellIdentifierLoading = String(describing: LoadingCell.self)
    private var kCellIdentifierDesc = String(describing: CancellationDescTableCell.self)
    private var _groupedTourOptionsModel: [[TourOptionsModel]] = []
    private var _whosinOptionsModel: [TourOptionsModel] = []
    private var _juniperOptionModel: [ServiceModel] = []
    
    public var ticketModel: TicketModel?
    public var bookingModel: BookingModel?
    public var detail: TourOptionDetailModel?
    public var octoSlot:  OctoAvailibilityModel?
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _loadData(true)
        _requestTicketDetail()
        if let model = bookingModel {
            if let jsonString = model.toJSONString(),
               let bookingModel = Mapper<BookingModel>().map(JSONString: jsonString) {
                BOOKINGMANAGER.bookingModel = bookingModel
            }
            let totalAmount = BOOKINGMANAGER.getTotalAmount()
            if totalAmount > 0 {
                let plainTitle = NSAttributedString(string: "update".localized(), attributes: [
                    .font: self._nextButton.titleLabel?.font ?? UIFont.systemFont(ofSize: 16),
                    .foregroundColor: UIColor.white
                ])
                self._priceView.isHidden = false
                self._totalPriceLabel.attributedText = "\(Utils.getCurrentCurrencySymbol())\(totalAmount.formattedDecimal())".withCurrencyFont()
                self._nextButton.setAttributedTitle(plainTitle, for: .normal)
            } else {
                let plainTitle = NSAttributedString(string: "update".localized(), attributes: [
                    .font: self._nextButton.titleLabel?.font ?? UIFont.systemFont(ofSize: 16),
                    .foregroundColor: UIColor.white
                ])
                self._priceView.isHidden = true
                self._nextButton.setAttributedTitle(plainTitle, for: .normal)
            }
            self._nextButton.isEnabled = !BOOKINGMANAGER.bookingModel.tourDetails.isEmpty
            self._nextButton.backgroundColor = BOOKINGMANAGER.bookingModel.tourDetails.isEmpty ? UIColor(hexString: "#ADADAD") : ColorBrand.brandPink
        }
        setupUI()
        // Ticket price update from booking manager callback
        BOOKINGMANAGER.onItemChange = {
            let totalAmount = BOOKINGMANAGER.getTotalAmount(for: self.detail?.optionId)
            if totalAmount > 0 {
                let plainTitle = NSAttributedString(string: "update".localized(), attributes: [
                    .font: self._nextButton.titleLabel?.font ?? UIFont.systemFont(ofSize: 16),
                    .foregroundColor: UIColor.white
                ])
                self._priceView.isHidden = false
                self._totalPriceLabel.attributedText = "\(Utils.getCurrentCurrencySymbol())\(totalAmount.formattedDecimal())".withCurrencyFont(14, true, color: .black)
                self._nextButton.setAttributedTitle(plainTitle, for: .normal)
            } else {
                let plainTitle = NSAttributedString(string: "update".localized(), attributes: [
                    .font: self._nextButton.titleLabel?.font ?? UIFont.systemFont(ofSize: 16),
                    .foregroundColor: UIColor.white
                ])
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
        _tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
//        _nextButton.isEnabled = false
        NotificationCenter.default.addObserver(forName: .reloadOptions, object: nil, queue: .main) { notification in
            if let date = notification.userInfo?["date"] as? Date {
                if self.ticketModel?.bookingType == "rayna" {
                    self._requestRaynaTourOptions(date)
                } else if self.ticketModel?.bookingType == "whosin" {
                    self._requestWhosinTourOptions(date)
                }
            }
        }
    }
    
    // --------------------------------------
    // MARK: Services
    // --------------------------------------
    
    private func _requestTicketDetail() {
        guard let id = bookingModel?.customTicketId else { return }
        WhosinServices.getTicketDetail(id: id) { [weak self] container, error in
            guard let self = self else {
                self?._loadData()
                return
            }
            self.hideHUD()
            guard let data = container?.data else { return }
            self.ticketModel = data
            BOOKINGMANAGER.ticketModel = data
            if data.bookingType == "whosin" {
                self._requestWhosinTourOptions()
            } else if data.bookingType == "juniper" {
                self._requestJuniperTourOptions()
            } else if ticketModel?.bookingType == "travel-desk" {
                self._loadData()
            } else if ticketModel?.bookingType == "whosin-ticket" {
                _loadData()
            } else if ticketModel?.bookingType == "big-bus" || ticketModel?.bookingType == "hero-balloon" {
                _requestOctoAvailibility()
            } else {
                self._requestRaynaTourOptions()
            }
        }
    }
    
    private func _requestWhosinTourOptions(_ updatedDate: Date? = nil) {
        if updatedDate != nil {
            showHUD()
        }
        let ticketId = ticketModel?._id ?? ""
        var date: Date = Date()
        if let updatedDate = updatedDate {
            date = updatedDate
        } else if let initDate = Utils.stringToDate(detail?.tourDate, format: kStanderdDate) {
            date = initDate
        } else if let initDate = Utils.stringToDate(detail?.tourDate, format: kFormatDate) {
            date = initDate
        }

        let params: [String: Any] = [
            "ticketId": ticketId,
            "adults": detail?.adult ?? 1,
            "childs": detail?.child ?? 0,
            "infants": detail?.infant ?? 0,
            "date": Utils.dateToString(date, format: kFormatDate)
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
            guard let data = container?.data else { return }
            self._whosinOptionsModel = data
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
            guard let data = container?.data else { return }
            self._juniperOptionModel = data
            self._loadData()
        }
    }
    
    private func _requestRaynaTourOptions(_ updatedDate: Date? = nil) {
        if updatedDate != nil {
            showHUD()
        }
        let tourId = Utils.stringIsNullOrEmpty(BOOKINGMANAGER.ticketModel?.tourId) ? BOOKINGMANAGER.ticketModel?.tourData?.tourId ?? kEmptyString : BOOKINGMANAGER.ticketModel?.tourId ?? kEmptyString
        let contractId = Utils.stringIsNullOrEmpty(BOOKINGMANAGER.ticketModel?.contractId) ? BOOKINGMANAGER.ticketModel?.tourData?.contractId ?? kEmptyString : BOOKINGMANAGER.ticketModel?.contractId ?? kEmptyString
        var date: Date = Date()
        if let updatedDate = updatedDate {
            date = updatedDate
        } else if let initDate = Utils.stringToDate(detail?.tourDate, format: kStanderdDate) {
            date = initDate
        } else if let initDate = Utils.stringToDate(detail?.tourDate, format: kFormatDate) {
            date = initDate
        }

        let params: [String: Any] = [
            "tourId": tourId,
            "contractId": contractId,
            "date": Utils.dateToString(date, format: kFormatDate),
            "noOfAdult": detail?.adult ?? 1,
            "noOfChild": detail?.child ?? 0,
            "noOfInfant": detail?.infant ?? 0
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
            guard let data = container?.data else { return }
            self._groupedTourOptionsModel.removeAll()
            let groupedDict = Dictionary(grouping: data) { $0.tourOptionId } // groupping by optionId
            
            let sortedKeys = groupedDict.keys
            let optionsList = sortedKeys.compactMap { groupedDict[$0] }
            self._groupedTourOptionsModel = optionsList.map { group in
                group.sorted { $0.adultPrice < $1.adultPrice }
            }.sorted {
                ($0.first?.adultPrice ?? 0) < ($1.first?.adultPrice ?? 0)
            }
            
            BOOKINGMANAGER.optionsList = data
            self._loadData()
        }
    }
    
    private func _requestOctoAvailibility() {
         let option = BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == detail?.optionId })
         var unitsArray: [[String: Any]] = []

         func addUnit(for type: String, unitid: String?, qty: Int?) {
             guard let qty = qty, qty > 0, let unitid = unitid, !Utils.stringIsNullOrEmpty(unitid) else { return }
             unitsArray.append([
                 "id": unitid,
                 "quantity": qty
             ])
         }

         addUnit(for: "adult", unitid: detail?.adultId, qty: detail?.adult)
         addUnit(for: "child", unitid: detail?.childId, qty: detail?.child)
         addUnit(for: "infant", unitid: detail?.infantId, qty: detail?.infant)

         let params: [String: Any] = [
             "tourId": ticketModel?.code ?? "",
             "optionId": detail?.optionId ?? "",
             "fromDate": detail?.tourDate ?? Utils.dateToString(Date(), format: kFormatDate),
             "toDate": detail?.tourDate ?? Utils.dateToString(Date(), format: kFormatDate),
             "units": unitsArray,
             "pickupRequested": detail?.pickup.isEmpty ?? false,
             "pickupPointId": detail?.hotelId ?? ""
         ]

         WhosinServices.bigBusAvailability(params: params) { [weak self] container, error in
             guard let self = self else { return }
             self.hideHUD(error: error)
             guard let data = container?.data else { return }
             self.octoSlot = data.first
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
                kCellObjectDataKey: "loading",
                kCellClassKey: LoadingCell.self,
                kCellHeightKey: LoadingCell.height
            ])
        } else {
            if !self._groupedTourOptionsModel.isEmpty {
                self._groupedTourOptionsModel.forEach { model in
                    let shouldAdd = model.contains { detail?.optionId == "\($0.tourOptionId)" }
                    if shouldAdd {
                        cellData.append([
                            kCellIdentifierKey: kCellIdentifier,
                            kCellTagKey: kCellIdentifier,
                            kCellObjectDataKey: model,
                            kCellClassKey: TourOptionsTableCell.self,
                            kCellHeightKey: TourOptionsTableCell.height
                        ])
                    }
                }
            }
            else if _whosinOptionsModel.isEmpty == false, ticketModel?.bookingType == "whosin" {
                _whosinOptionsModel.forEach { model in
                    if detail?.optionId == model._id {
                        cellData.append([
                            kCellIdentifierKey: kCellIdentifier,
                            kCellTagKey: kCellIdentifier,
                            kCellObjectDataKey: model,
                            kCellClassKey: TourOptionsTableCell.self,
                            kCellHeightKey: TourOptionsTableCell.height
                        ])
                    }
                }
            }
            else if ticketModel?.travelDeskTourData.first?.optionData.isEmpty == false, ticketModel?.bookingType == "travel-desk" {
                ticketModel?.travelDeskTourData.first?.optionData.forEach { model in
                    if detail?.optionId == "\(model.id)"  {
                        cellData.append([
                            kCellIdentifierKey: kCellIdentifier,
                            kCellTagKey: kCellIdentifier,
                            kCellObjectDataKey: model,
                            kCellClassKey: TourOptionsTableCell.self,
                            kCellHeightKey: TourOptionsTableCell.height
                        ])
                    }
                }
            }
            else if ticketModel?.whosinModuleTourData.first?.optionData.isEmpty == false {
                ticketModel?.whosinModuleTourData.first?.optionData.forEach { model in
                    if detail?.optionId == "\(model.optionId)"  {
                        cellData.append([
                            kCellIdentifierKey: kCellIdentifier,
                            kCellTagKey: kCellIdentifier,
                            kCellObjectDataKey: model,
                            kCellClassKey: TourOptionsTableCell.self,
                            kCellHeightKey: TourOptionsTableCell.height
                        ])
                    }
                }
            }
            else if ticketModel?.bigBusTourData.first?.options.isEmpty == false {
                ticketModel?.bigBusTourData.first?.options.forEach { model in
                    if detail?.optionId == model.id {
                        cellData.append([
                            kCellIdentifierKey: kCellIdentifier,
                            kCellTagKey: octoSlot,
                            kCellObjectDataKey: model,
                            kCellClassKey: TourOptionsTableCell.self,
                            kCellHeightKey: TourOptionsTableCell.height
                        ])
                    }
                }
            }
        }
        
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _tableView.loadData(cellSectionData)
    }
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: String(describing: TourOptionsTableCell.self), kCellClassKey: TourOptionsTableCell.self, kCellHeightKey: TourOptionsTableCell.height], [kCellIdentifierKey: kCellIdentifierLoading, kCellNibNameKey: kCellIdentifierLoading, kCellClassKey: LoadingCell.self, kCellHeightKey: LoadingCell.height]]
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
        
        BOOKINGMANAGER.bookingModel.tourDetails.forEach { model in
            if let  option = BOOKINGMANAGER.optionsList.first(where: { BOOKINGMANAGER.matchesOption($0, optionId: model.optionId, transferId: model.transferId) }) {
                let name = Utils.stringIsNullOrEmpty(option.optionDetail?.optionName) ? option.optionName : option.optionDetail?.optionName ?? "option"

                if option.optionDetail?.isWithoutAdult == false && model.adult < 1 {
                    alert(message: LANGMANAGER.localizedString(forKey: "adult_required_alert", arguments: ["value": name]))
                    isValidate = false
                    return
                }
                
                if Utils.stringIsNullOrEmpty(model.tourDate) {
                    alert(message: LANGMANAGER.localizedString(forKey: "date_required_alert", arguments: ["value" : name]))
                    isValidate = false
                    return
                }
                
                if option.isSlot && Utils.stringIsNullOrEmpty(model.timeSlotId) {
                    alert(message: LANGMANAGER.localizedString(forKey: "time_required_alert", arguments: ["value": name]))
                    isValidate = false
                    return
                }
                
                if model.adult < 1 && model.child < 1 && model.infant < 1 {
                    alert(message: LANGMANAGER.localizedString(forKey: "pax_required_alert", arguments: ["value": name]))
                    isValidate = false
                    return
                }
                
                if isMinPax(model.adult, child: model.child, infant: model.infant) {
                    alert(message: LANGMANAGER.localizedString(forKey: "min_pax_alert", arguments: ["value1": "\(ticketModel?.minPax ?? 0))", "value2": option.unit, "value3": option.optionDetail?.optionName ?? ""]))
                    
                    isValidate = false
                    return
                }
            } else if let option = _whosinOptionsModel.first(where: { $0._id == model.optionId }), ticketModel?.bookingType == "whosin" {
                let name = Utils.stringIsNullOrEmpty(option.optionDetail?.optionName) ? option.optionName : option.optionDetail?.optionName ?? "option"

                if option.optionDetail?.isWithoutAdult == false && model.adult < 1 {
                    alert(message: LANGMANAGER.localizedString(forKey: "adult_required_alert", arguments: ["value": name]))
                    isValidate = false
                    return
                }
                
                if Utils.stringIsNullOrEmpty(model.tourDate) {
                    alert(message: LANGMANAGER.localizedString(forKey: "date_required_alert", arguments: ["value" : name]))
                    isValidate = false
                    return
                }
                
                if option.isSlot && Utils.stringIsNullOrEmpty(model.timeSlotId) {
                    alert(message: LANGMANAGER.localizedString(forKey: "time_required_alert", arguments: ["value": name]))
                    isValidate = false
                    return
                }
                
                if model.adult < 1 && model.child < 1 && model.infant < 1 {
                    alert(message: LANGMANAGER.localizedString(forKey: "pax_required_alert", arguments: ["value": name]))
                    isValidate = false
                    return
                }
                
                if isMinPax(model.adult, child: model.child, infant: model.infant) {
                    alert(message: LANGMANAGER.localizedString(forKey: "min_pax_alert", arguments: ["value1": "\(ticketModel?.minPax ?? 0))", "value2": option.unit, "value3": option.optionDetail?.optionName ?? ""]))

                    isValidate = false
                    return
                }

            } else if let whosinTicket = BOOKINGMANAGER.ticketModel?.whosinModuleTourData.first?.optionData.first(where: { $0.optionId == model.optionId}) {
                
                if Utils.stringIsNullOrEmpty(model.tourDate) {
                    alert(message: LANGMANAGER.localizedString(forKey: "date_required_alert", arguments: ["value" : whosinTicket.displayName]))
                    isValidate = false
                    return
                }
                
                if Utils.stringIsNullOrEmpty(model.timeSlotId) {
                    alert(message: LANGMANAGER.localizedString(forKey: "time_required_alert", arguments: ["value": whosinTicket.displayName]))
                    isValidate = false
                    return
                }
                
                if model.adult < 1 && model.child < 1 && model.infant < 1 {
                    alert(message: LANGMANAGER.localizedString(forKey: "pax_required_alert", arguments: ["value": whosinTicket.displayName]))
                    isValidate = false
                    return

                }
                
                if isMinPax(model.adult, child: model.child, infant: model.infant, minPax: Int(whosinTicket.minPaxString)) {
                    alert(message: LANGMANAGER.localizedString(forKey: "min_pax_alert", arguments: ["value1": "\(whosinTicket.minPaxString)", "value2": whosinTicket.unit, "value3": whosinTicket.displayName]))

                    isValidate = false
                    return
                }
                
                
            } else if let travel = BOOKINGMANAGER.ticketModel?.travelDeskTourData.first?.optionData.first(where: { "\($0.id)" == model.optionId}) {
                if model.adult < 1 && model.child < 1 && model.infant < 1 {
                    alert(message: LANGMANAGER.localizedString(forKey: "pax_required_alert", arguments: ["value": travel.name]))
                    isValidate = false
                    return

                }
                
                if isMinPax(model.adult, child: model.child, infant: model.infant, minPax: travel.minNumOfPeople) {
                    alert(message: LANGMANAGER.localizedString(forKey: "min_pax_alert", arguments: ["value1": "\(travel.minNumOfPeople ?? 0)", "value2": travel.unit, "value3": travel.name]))

                    isValidate = false
                    return
                }

            } else if let bigbusTicket = BOOKINGMANAGER.ticketModel?.bigBusTourData.first?.options.first(where: { $0.id == model.optionId}) {
                if Utils.stringIsNullOrEmpty(model.tourDate) {
                    alert(message: LANGMANAGER.localizedString(forKey: "date_required_alert", arguments: ["value" : bigbusTicket.title]))
                    isValidate = false
                    return
                }
                
                if bigbusTicket.pickupRequired {
                    if Utils.stringIsNullOrEmpty(model.pickup) {
                        alert(message: LANGMANAGER.localizedString(forKey: "pickup_alert", arguments: ["value": bigbusTicket.title]))
                        isValidate = false
                        return
                    }
                }
                
                if Utils.stringIsNullOrEmpty(model.timeSlot) {
                    alert(message: LANGMANAGER.localizedString(forKey: "time_required_alert", arguments: ["value": bigbusTicket.title]))
                    isValidate = false
                    return
                }
                
                if model.adult < 1 && model.child < 1 && model.infant < 1 {
                    alert(message: LANGMANAGER.localizedString(forKey: "pax_required_alert", arguments: ["value": bigbusTicket.title]))
                    isValidate = false
                    return

                }
                
                if isMinPax(model.adult, child: model.child, infant: model.infant, minPax: Int(bigbusTicket.restrictions?.minPaxCount ?? 0)) {
                    alert(message: LANGMANAGER.localizedString(forKey: "min_pax_alert", arguments: ["value1": "\(bigbusTicket.restrictions?.minPaxCount ?? 0)", "value2": bigbusTicket.unit, "value3": bigbusTicket.title]))
                    isValidate = false
                    return
                }
                
            }
            
        }
        
        guard isValidate else { return }
        
        if ticketModel?.bookingType == "whosin" {
            _requestWhosinTourPolicy { success in
                if success {
                    guard success else { return }
                    guard isValidate else { return }
                    let priceCalculation = BOOKINGMANAGER.calculateTourTotals(promo: nil)
                    BOOKINGMANAGER.bookingModel.amount = priceCalculation.priceWithPromo.formatted()
                    BOOKINGMANAGER.bookingModel.sourcePlatform = "iOS"
                    BOOKINGMANAGER.bookingModel.totalAmount = priceCalculation.totalAmount.formatted()
                    BOOKINGMANAGER.bookingModel.discount = priceCalculation.discountPrice.formatted()
                    BOOKINGMANAGER.bookingModel.customTicketId = BOOKINGMANAGER.ticketModel?._id ?? ""
                    BOOKINGMANAGER.bookingModel.currency = "aed"
                    BOOKINGMANAGER.bookingModel.bookingType = BOOKINGMANAGER.ticketModel?.bookingType ?? "rayna"
                    BOOKINGMANAGER.bookingModel.cartId = self.bookingModel?._id ?? ""
                    if let jsonString = BOOKINGMANAGER.bookingModel.toJSONString(),
                       let data = jsonString.data(using: .utf8),
                       let jsonDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print("Ticket booking params===========",jsonDict.toJSONString)
                        self._requestUpdateCart(params: jsonDict)
                    } else {
                        print("Failed to fetch policy.")
                    }
                }
            }
        } else if ticketModel?.bookingType == "rayna" {
            _requestRaynaTourPolicy { success in
                if success {
                    guard success else { return }
                    guard isValidate else { return }
                    let priceCalculation = BOOKINGMANAGER.calculateTourTotals(promo: nil)
                    BOOKINGMANAGER.bookingModel.amount = priceCalculation.priceWithPromo.formatted()
                    BOOKINGMANAGER.bookingModel.sourcePlatform = "iOS"
                    BOOKINGMANAGER.bookingModel.totalAmount = priceCalculation.totalAmount.formatted()
                    BOOKINGMANAGER.bookingModel.discount = priceCalculation.discountPrice.formatted()
                    BOOKINGMANAGER.bookingModel.customTicketId = BOOKINGMANAGER.ticketModel?._id ?? ""
                    BOOKINGMANAGER.bookingModel.currency = "aed"
                    BOOKINGMANAGER.bookingModel.bookingType = BOOKINGMANAGER.ticketModel?.bookingType ?? "rayna"
                    BOOKINGMANAGER.bookingModel.cartId = self.bookingModel?._id ?? ""
                    if let jsonString = BOOKINGMANAGER.bookingModel.toJSONString(),
                       let data = jsonString.data(using: .utf8),
                       let jsonDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print("Ticket booking params===========",jsonDict.toJSONString)
                        self._requestUpdateCart(params: jsonDict)
                    } else {
                        print("Failed to fetch policy.")
                    }
                }
            }
        } else if ticketModel?.bookingType == "travel-desk" {
            _requestTravelPolicy { success in
                if success {
                    guard success else { return }
                    guard isValidate else { return }
                    let priceCalculation = BOOKINGMANAGER.calculateTourTotals(promo: nil)
                    BOOKINGMANAGER.bookingModel.amount = priceCalculation.priceWithPromo.formatted()
                    BOOKINGMANAGER.bookingModel.sourcePlatform = "iOS"
                    BOOKINGMANAGER.bookingModel.totalAmount = priceCalculation.totalAmount.formatted()
                    BOOKINGMANAGER.bookingModel.discount = priceCalculation.discountPrice.formatted()
                    BOOKINGMANAGER.bookingModel.customTicketId = BOOKINGMANAGER.ticketModel?._id ?? ""
                    BOOKINGMANAGER.bookingModel.currency = "aed"
                    BOOKINGMANAGER.bookingModel.bookingType = BOOKINGMANAGER.ticketModel?.bookingType ?? "rayna"
                    BOOKINGMANAGER.bookingModel.cartId = self.bookingModel?._id ?? ""
                    if let jsonString = BOOKINGMANAGER.bookingModel.toJSONString(),
                       let data = jsonString.data(using: .utf8),
                       var jsonDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if BOOKINGMANAGER.ticketModel?.bookingType == "travel-desk" {
                            if var cancellationArray = jsonDict["cancellationPolicy"] as? [[String: Any]] {
                                cancellationArray = cancellationArray.map { item in
                                    return [
                                        "tourId": item["tourId"] ?? 0,
                                        "optionId": item["optionId"] ?? 0,
                                        "fromDate": item["fromDate"] ?? "",
                                        "toDate": item["toDate"] ?? "",
                                        "percentage": item["percentage"] ?? 0
                                    ]
                                }
                                jsonDict["cancellationPolicy"] = cancellationArray
                            }
                        }
                        print("Ticket booking params===========",jsonDict.toJSONString)
                        self._requestUpdateCart(params: jsonDict)
                    }
                }
            }
        } else if ticketModel?.bookingType == "whosin-ticket" {
            _requestWhosinTicketrules { success in
                if success {
                    guard success else { return }
                    guard isValidate else { return }
                    let priceCalculation = BOOKINGMANAGER.calculateTourTotals(promo: nil)
                    BOOKINGMANAGER.bookingModel.amount = priceCalculation.priceWithPromo.formatted()
                    BOOKINGMANAGER.bookingModel.sourcePlatform = "iOS"
                    BOOKINGMANAGER.bookingModel.totalAmount = priceCalculation.totalAmount.formatted()
                    BOOKINGMANAGER.bookingModel.discount = priceCalculation.discountPrice.formatted()
                    BOOKINGMANAGER.bookingModel.customTicketId = BOOKINGMANAGER.ticketModel?._id ?? ""
                    BOOKINGMANAGER.bookingModel.currency = "aed"
                    BOOKINGMANAGER.bookingModel.bookingType = BOOKINGMANAGER.ticketModel?.bookingType ?? "rayna"
                    BOOKINGMANAGER.bookingModel.cartId = self.bookingModel?._id ?? ""
                    if let jsonString = BOOKINGMANAGER.bookingModel.toJSONString(),
                       let data = jsonString.data(using: .utf8),
                       let jsonDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print("Ticket booking params===========",jsonDict.toJSONString)
                        self._requestUpdateCart(params: BOOKINGMANAGER.bookingModel.toJSON())
                    } else {
                        print("Failed to fetch policy.")
                    }
                }
            }
        } else if ticketModel?.bookingType == "big-bus" || ticketModel?.bookingType == "hero-balloon" {
            let priceCalculation = BOOKINGMANAGER.calculateTourTotals(promo: nil)
            BOOKINGMANAGER.bookingModel.amount = priceCalculation.priceWithPromo.formatted()
            BOOKINGMANAGER.bookingModel.sourcePlatform = "iOS"
            BOOKINGMANAGER.bookingModel.totalAmount = priceCalculation.totalAmount.formatted()
            BOOKINGMANAGER.bookingModel.discount = priceCalculation.discountPrice.formatted()
            BOOKINGMANAGER.bookingModel.customTicketId = BOOKINGMANAGER.ticketModel?._id ?? ""
            BOOKINGMANAGER.bookingModel.currency = "aed"
            BOOKINGMANAGER.bookingModel.bookingType = BOOKINGMANAGER.ticketModel?.bookingType ?? "rayna"
            BOOKINGMANAGER.bookingModel.cartId = self.bookingModel?._id ?? ""
            if let jsonString = BOOKINGMANAGER.bookingModel.toJSONString(),
               let data = jsonString.data(using: .utf8),
               let jsonDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print("Ticket booking params===========",jsonDict.toJSONString)
                self._requestUpdateCart(params: jsonDict)
            } else {
                print("Failed to fetch policy.")
            }
        }
        
    }
    
    private func _requestUpdateCart(params: [String: Any]) {
        showHUD()
        WhosinServices.updateCart(params: params) { [weak self] container, error in
            guard let self = self else { return }
            self.hideHUD(error: error)
            guard let data = container else { return }
            if data.code == 1 {
                NotificationCenter.default.post(name: Notification.Name("addtoCartCount"), object: nil)
                self.showSuccessMessage("updated_successfully".localized(), subtitle: "cart_updated_successfully".localized())
                self.navigationController?.popViewController(animated: true)
            }
            
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
        
        options.forEach { option in
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
        
        options.forEach { option in
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
        
        options.forEach { option in
            let currentOption = BOOKINGMANAGER.ticketModel?.travelDeskTourData.first(where: { tour in
                tour.optionData.contains(where: { "\($0.id)" == option.optionId })
            })
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
                        if error.localizedDescription.localizedCaseInsensitiveContains("cannot book this tour") {
                            alert(message: "\(error.localizedDescription)")
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

}

extension EditTicketCartVC: CustomNoKeyboardTableViewDelegate {
    
    // --------------------------------------
    // MARK: <CustomTableViewDelegate>
    // --------------------------------------
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? TourOptionsTableCell {
            if let object = cellDict?[kCellObjectDataKey] as? [TourOptionsModel] {
                cell.setupData(object, isSelected: false, discount: ticketModel?.discount ?? 0, isCart: true)
                cell.callback = {
                    self._nextButton.isEnabled = !BOOKINGMANAGER.bookingModel.tourDetails.isEmpty
                    self._nextButton.backgroundColor = BOOKINGMANAGER.bookingModel.tourDetails.isEmpty ? UIColor(hexString: "#ADADAD") : ColorBrand.brandPink
                    self._tableView.reload()
                }
            } else if let object = cellDict?[kCellObjectDataKey] as? TourOptionsModel, ticketModel?.bookingType == "whosin-ticket" {
                cell.setWhosinModule(object, isSelected: false, discount: ticketModel?.discount ?? 0, isCart: true)
                cell.callback = {
                    self._nextButton.isEnabled = !BOOKINGMANAGER.bookingModel.tourDetails.isEmpty
                    self._nextButton.backgroundColor = BOOKINGMANAGER.bookingModel.tourDetails.isEmpty ? UIColor(hexString: "#ADADAD") : ColorBrand.brandPink
                    self._tableView.reload()
                }
            } else if let object = cellDict?[kCellObjectDataKey] as? TourOptionsModel {
                cell.setupData(object, isSelected: false, discount: ticketModel?.discount ?? 0, isCart: true)
                cell.callback = {
                    self._nextButton.isEnabled = !BOOKINGMANAGER.bookingModel.tourDetails.isEmpty
                    self._nextButton.backgroundColor = BOOKINGMANAGER.bookingModel.tourDetails.isEmpty ? UIColor(hexString: "#ADADAD") : ColorBrand.brandPink
                    self._tableView.reload()
                }
            } else if let object = cellDict?[kCellObjectDataKey] as? TourOptionModel {
                cell.setupData(object, isSelected: false, discount: ticketModel?.discount ?? 0, isCart: true)
                cell.callback = {
                    self._nextButton.isEnabled = !BOOKINGMANAGER.bookingModel.tourDetails.isEmpty
                    self._nextButton.backgroundColor = BOOKINGMANAGER.bookingModel.tourDetails.isEmpty ? UIColor(hexString: "#ADADAD") : ColorBrand.brandPink
                    self._tableView.reload()
                }
            } else if let object = cellDict?[kCellObjectDataKey] as? BigBusOptionsModel, let model = cellDict?[kCellTagKey] as? OctoAvailibilityModel {
                cell.setupData(object, isSelected: false, discount: ticketModel?.discount ?? 0, isCart: true, slotModel: model)
                cell.callback = {
                    self._nextButton.isEnabled = !BOOKINGMANAGER.bookingModel.tourDetails.isEmpty
                    self._nextButton.backgroundColor = BOOKINGMANAGER.bookingModel.tourDetails.isEmpty ? UIColor(hexString: "#ADADAD") : ColorBrand.brandPink
                    self._tableView.reload()
                }
            }
        } else if let cell = cell as? LoadingCell {
            cell.setupUi()
        }
    }
    
}
