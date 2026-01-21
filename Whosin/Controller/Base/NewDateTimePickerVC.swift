
import UIKit
import FSCalendar
import SnapKit
import PanModal

class NewDateTimePickerVC: PanBaseViewController {
    var didUpdateCallback: ((_ date: Date, _ time: Any) -> Void)?
    @IBOutlet private weak var _mainContainerView: UIView!
    @IBOutlet weak private var _calendarContainerView: UIView!
    @IBOutlet private weak var _collectionView: CustomCollectionView!
    @IBOutlet private weak var _doneButton: UIButton!
    @IBOutlet weak var _dateCollectionView: CustomCollectionView!
    @IBOutlet weak var _selectedDateView: UIView!
    @IBOutlet weak var _dayLabel: CustomLabel!
    @IBOutlet weak var _dateLabel: CustomLabel!
    @IBOutlet weak var _monthLabel: CustomLabel!
    @IBOutlet weak var _emptyDataImage: UIImageView!
    @IBOutlet weak var _emptyDataLabel: UILabel!
    @IBOutlet weak var _departureTime: CustomLabel!
    @IBOutlet weak var _departureTimeView: UIView!
    @IBOutlet weak var _timeSlotTitle: UILabel!
    @IBOutlet weak var _slotView: UIView!
    @IBOutlet weak var _emptyDataStack: UIStackView!
    @IBOutlet weak var _sapratorView: UIView!
    
    private let kCellIdentifier = String(describing: OptionTimeSlotCollectionCell.self)
    private let kCellIdentifierDate = String(describing: CalenderDatesView.self)
    private let kCellIdentifierLoading = String(describing: LoadingCollectionCell.self)
    private var _startingDate: Date = Date()
    private var _endingDate: Date = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    private var _validDayList: [String] = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]
    
    public var _selectedDate: Date?
    public var allowTodaysBooking: Bool = true
    private var dates: [Date] = []
    private var selectedIndex: Int? = 0
    private var _timeSlots : [TourTimeSlotModel] = []
    private var _travelSlot : [TravelDeskAvailibilityModel] = []
    private var _bigBusSlot : [OctoAvailibilityModel] = []
    public var selectedFilter : TourTimeSlotModel? = nil
    public var selectedTravel : TravelDeskAvailibilityModel? = nil
    public var selectedBigbus : OctoAvailibilityModel? = nil
    public var _selectedTourOptionModel: TourOptionsModel?
    public var _selectedTravelOptionModel: TourOptionModel?
    public var _selectedBigBusOptionModel: BigBusOptionsModel?
    public var _selectedPickup: PickupListModel?
    public var isSlots: Bool = false
    public var contactCallback: (() -> Void)?

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _departureTimeView.isHidden = true
        _departureTime.text = _selectedTourOptionModel?.departureTime ?? ""
        _slotView.isHidden = false
        if BOOKINGMANAGER.ticketModel?.bookingType == "whosin" {
            _isValidate = _selectedTourOptionModel?.availabilityTimeSlot.isEmpty == true
            isSlots = !(_selectedTourOptionModel?.availabilityTimeSlot.isEmpty ?? false) == true
            if !isSlots {
                let slot = TourTimeSlotModel()
                slot.timeSlotId = "0"
                slot.tourOptionId = 0
                slot.timeSlot = _selectedTourOptionModel?.availabilityTime ?? kEmptyString
                selectedFilter = slot
                _timeSlots = [slot]
            } else {
                _timeSlots = _selectedTourOptionModel?.availabilityTimeSlot.toArrayDetached(ofType: TourTimeSlotModel.self).filter({ $0.totalSeats != 0 }) ?? []
            }
            _validDayList = dayMapping.compactMap { (key, short) in
                (_selectedTourOptionModel?.operationdays?[key] as? Int == 1) ? short : nil
            }
        } else if BOOKINGMANAGER.ticketModel?.bookingType == "whosin-ticket" {
            _isValidate = !isSlots
            if !isSlots {
                let slot = TourTimeSlotModel()
                slot.timeSlotId = _selectedTourOptionModel?.tourIdString ?? ""
                slot.tourOptionId = 0
                slot.timeSlot = _selectedTourOptionModel?.slotText ?? kEmptyString
                selectedFilter = slot
                _timeSlots = [slot]
            }
            _validDayList = dayMapping.compactMap { (key, short) in
                (_selectedTourOptionModel?.optionDetail?.operationdays?[key] as? Int == 1) ? short : nil
            }
        } else if BOOKINGMANAGER.ticketModel?.bookingType == "rayna" {
            _isValidate = !isSlots
            if !isSlots {
                let slot = TourTimeSlotModel()
                slot.timeSlotId = _selectedTourOptionModel?.optionDetail?._id ?? ""
                slot.tourOptionId = _selectedTourOptionModel?.tourOptionId ?? 0
                slot.timeSlot = _selectedTourOptionModel?.slotText ?? kEmptyString
                selectedFilter = slot
                _timeSlots = [slot]
            }
            _validDayList = dayMapping.compactMap { (key, short) in
                (_selectedTourOptionModel?.optionDetail?.operationdays?[key] as? Int == 1) ? short : nil
            }
        } else if BOOKINGMANAGER.ticketModel?.bookingType == "travel-desk" {
            isSlots = true
            _isValidate = !isSlots
            if !isSlots {
                let slot = TourTimeSlotModel()
                slot.timeSlotId = _selectedTourOptionModel?.optionDetail?._id ?? ""
                slot.tourOptionId = _selectedTourOptionModel?.tourOptionId ?? 0
                slot.timeSlot = _selectedTourOptionModel?.slotText ?? kEmptyString
                selectedFilter = slot
                _timeSlots = [slot]
            }
            _validDayList = dayMapping.compactMap { (key, short) in
                (_selectedTourOptionModel?.optionDetail?.operationdays?[key] as? Int == 1) ? short : nil
            }
        } else if BOOKINGMANAGER.ticketModel?.bookingType == "big-bus" || BOOKINGMANAGER.ticketModel?.bookingType == "hero-balloon" {
            isSlots = true
            _isValidate = !isSlots
        }
        setupUi()
        setupDates()
    }
    
    let dayMapping: [(key: String, short: String)] = [
        ("sunday", "sun"),
        ("monday", "mon"),
        ("tuesday", "tue"),
        ("wednesday", "wed"),
        ("thursday", "thu"),
        ("friday", "fri"),
        ("saturday", "sat")
    ]
    
    override func setupUi() {
        _mainContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        //COLLECTION VIEW
        let spacing = kCollectionViewDefaultSpacing
        _dateCollectionView.setup(
            cellPrototypes: _prototypes,
            hasHeaderSection: false,
            enableRefresh: false,
            columns: 5,
            rows: 1,
            edgeInsets: UIEdgeInsets(top: spacing, left: .zero, bottom: spacing, right: .zero),
            spacing: .zero,
            scrollDirection: .horizontal,
            isDummyLoad: true,
            delegate: self
        )
        _dateCollectionView.showsVerticalScrollIndicator = false
        _dateCollectionView.showsHorizontalScrollIndicator = false
        
        _collectionView.setup(
            cellPrototypes: _prototypes,
            hasHeaderSection: false,
            enableRefresh: false,
            columns: 1,
            rows: 1,
            edgeInsets: UIEdgeInsets(top: spacing, left: .zero, bottom: spacing, right: .zero),
            spacing: .zero,
            scrollDirection: .vertical,
            isDummyLoad: true,
            delegate: self
        )
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
        _loadTimeData(true)
        _validateDoneButton()
    }
    
    // --------------------------------------
    // MARK: Private Accessor
    // --------------------------------------
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: String(describing: OptionTimeSlotCollectionCell.self), kCellClassKey: OptionTimeSlotCollectionCell.self, kCellHeightKey: TimeCalenderCell.height],
                 [kCellIdentifierKey: kCellIdentifierDate, kCellNibNameKey: kCellIdentifierDate, kCellClassKey: CalenderDatesView.self, kCellHeightKey: CalenderDatesView.height],
                 [kCellIdentifierKey: kCellIdentifierLoading, kCellNibNameKey: kCellIdentifierLoading, kCellClassKey: LoadingCollectionCell.self, kCellHeightKey: LoadingCollectionCell.height]]
    }
    
    private var _isValidate: Bool = false
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func setupDates() {
        if let option = _selectedTourOptionModel {
            dates = BOOKINGMANAGER.ticketModel?.dateRange(allowTodaysBooking, validDays: _validDayList, option: option, isWhosin: BOOKINGMANAGER.ticketModel?.bookingType == "whosin") ?? []
        } else if let option = _selectedTravelOptionModel?.pricingPeriods.first {
            dates = BOOKINGMANAGER.ticketModel?.dateRange(from: option.dateStart, to: option.dateEnd, isTodayBooking: true, validDays: _validDayList) ?? []
        } else if let option = _selectedBigBusOptionModel {
            dates = BOOKINGMANAGER.ticketModel?.dateRange(true, validDays: _validDayList, option: option) ?? []
        }
        _selectedDate = dates.first
        _loadCalenderData()
        if dates.isEmpty {
            _dateCollectionView.isHidden = true
            _timeSlotTitle.isHidden = true
            _sapratorView.isHidden = true
            _emptyDataLabel.text = "no_date_available_ticket_option".localized()
//            alert(message: "no_date_available_ticket_option".localized())
            _timeSlots.removeAll()
            _travelSlot.removeAll()
            _isValidate = false
            _validateDoneButton()
            _loadTimeData()
            return
        } else {
            _dateCollectionView.isHidden = false
            _timeSlotTitle.isHidden = false
            _sapratorView.isHidden = false
            _validateDoneButton()
            _emptyDataLabel.text = "no_date_available_ticket_option".localized()
            _requestTimeSlot()
        }
    }
    
    private func _loadCalenderData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        dates.prefix(4).forEach { model in
            cellData.append([
                kCellIdentifierKey: kCellIdentifierDate,
                kCellObjectDataKey: model,
                kCellClassKey: CalenderDatesView.self,
                kCellHeightKey: CalenderDatesView.height
            ])
        }
        
        if dates.count > 3 {
            cellData.append([
                kCellIdentifierKey: kCellIdentifierDate,
                kCellObjectDataKey: true,
                kCellClassKey: CalenderDatesView.self,
                kCellHeightKey: CalenderDatesView.height
            ])
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _dateCollectionView.loadData(cellSectionData)
        
    }
    
    private func _loadTimeData(_ isLoading: Bool = false) {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        if isLoading {
            _emptyDataImage.isHidden = true
            _emptyDataStack.isHidden = true
            _emptyDataLabel.isHidden = true
            _collectionView.isHidden = false
            cellData.append([
                kCellIdentifierKey: kCellIdentifierLoading,
                kCellObjectDataKey: kCellIdentifierLoading,
                kCellClassKey: LoadingCollectionCell.self,
                kCellHeightKey: LoadingCollectionCell.height
            ])
        } else if _timeSlots.isEmpty && !_travelSlot.isEmpty {
            _emptyDataImage.isHidden = !_travelSlot.isEmpty
            _emptyDataStack.isHidden = !_travelSlot.isEmpty
            _emptyDataLabel.isHidden = !_travelSlot.isEmpty
            _collectionView.isHidden = _travelSlot.isEmpty
            _travelSlot.forEach { model in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellObjectDataKey: model,
                    kCellClassKey: OptionTimeSlotCollectionCell.self,
                    kCellHeightKey: OptionTimeSlotCollectionCell.height
                ])
                
            }
        } else if _timeSlots.isEmpty && _travelSlot.isEmpty && !_bigBusSlot.isEmpty {
            _emptyDataImage.isHidden = !_bigBusSlot.isEmpty
            _emptyDataStack.isHidden = !_bigBusSlot.isEmpty
            _emptyDataLabel.isHidden = !_bigBusSlot.isEmpty
            _collectionView.isHidden = _bigBusSlot.isEmpty
            _bigBusSlot.forEach { model in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellObjectDataKey: model,
                    kCellClassKey: OptionTimeSlotCollectionCell.self,
                    kCellHeightKey: OptionTimeSlotCollectionCell.height
                ])
                
            }
        } else {
            _emptyDataImage.isHidden = !_timeSlots.isEmpty
            _emptyDataLabel.isHidden = !_timeSlots.isEmpty
            _emptyDataStack.isHidden = !_timeSlots.isEmpty
            _collectionView.isHidden = _timeSlots.isEmpty
            _timeSlots.forEach { model in
                cellData.append([
                    kCellIdentifierKey: kCellIdentifier,
                    kCellObjectDataKey: model,
                    kCellClassKey: OptionTimeSlotCollectionCell.self,
                    kCellHeightKey: OptionTimeSlotCollectionCell.height
                ])
                
            }
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
    }
    
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
    private func _requestTimeSlot() {
        guard isSlots else {
            _loadTimeData()
            return
        }
        if BOOKINGMANAGER.ticketModel?.bookingType == "rayna" {
            _loadTimeData(true)
            let option = BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == "\(_selectedTourOptionModel?.tourOptionId ?? 0)"})
            let contractId = Utils.stringIsNullOrEmpty(BOOKINGMANAGER.ticketModel?.contractId) ? BOOKINGMANAGER.ticketModel?.tourData?.contractId ?? kEmptyString : BOOKINGMANAGER.ticketModel?.contractId ?? kEmptyString
            
            let params: [String: Any] = [
                "tourId": _selectedTourOptionModel?.tourId ?? "",
                "tourOptionId": _selectedTourOptionModel?.tourOptionId ?? "",
                "contractId": contractId,
                "date": Utils.dateToString(_selectedDate, format: kFormatDate),
                "transferId": _selectedTourOptionModel?.transferId ?? "",
                "noOfAdult": option?.adult ?? "1",
                "noOfChild": option?.child ?? "0",
                "noOfInfant": option?.infant ?? "0"
            ]
            self._timeSlots.removeAll()
            WhosinServices.raynaTourTimeSlots(params: params) { [weak self] container, error in
                guard let self = self else { return }
                if error != nil {
                    _loadTimeData()
                }
                self.hideHUD(error: error)
                guard let data = container?.data else { return }
                let filterdData = data.filter({ $0.available != 0 })
                self._timeSlots = filterdData
                self._loadTimeData()
            }
        } else if BOOKINGMANAGER.ticketModel?.bookingType == "whosin" {
            self._timeSlots = _selectedTourOptionModel?.availabilityTimeSlot.toArrayDetached(ofType: TourTimeSlotModel.self).filter({ $0.totalSeats != 0}) ?? []
            self._loadTimeData()
        } else if BOOKINGMANAGER.ticketModel?.bookingType == "travel-desk" {
            _loadTimeData(true)
            let params: [String: Any] = [
                "tourOptionId": "\(_selectedTravelOptionModel?.id ?? 0)",
                "startDate": Utils.dateToString(_selectedDate, format: kFormatDate),
                "endDate": Utils.dateToString(_selectedDate, format: kFormatDate),
            ]
            self._timeSlots.removeAll()
            WhosinServices.travelDeskAvailability(params: params) { [weak self] container, error in
                guard let self = self else { return }
                if error != nil {
                    _loadTimeData()
                }
                self.hideHUD(error: error)
                guard let data = container?.data else { return }
                //                let filterdData = data.filter({ $0.available != 0 })
                self._travelSlot = data.filter({ $0.availability?.left != 0 })
                self._loadTimeData()
            }
        } else if BOOKINGMANAGER.ticketModel?.bookingType == "whosin-ticket" {
            _loadTimeData(true)
            let option = BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == _selectedTourOptionModel?.optionId })
            
            let params: [String: Any] = [
                "tourId": "\(_selectedTourOptionModel?.tourIdString ?? "")",
                "tourOptionId": _selectedTourOptionModel?.optionId ?? "",
                "adults": option?.adult ?? 0,
                "childs": option?.child ?? 0,
                "date": Utils.dateToString(_selectedDate, format: kFormatDate),
            ]
            self._timeSlots.removeAll()
            WhosinServices.whosinSlots(params: params) { [weak self] container, error in
                guard let self = self else { return }
                if error != nil {
                    _loadTimeData()
                }
                self.hideHUD(error: error)
                guard let data = container?.data else { return }
                self._timeSlots = data
                self._loadTimeData()
            }
        } else if BOOKINGMANAGER.ticketModel?.bookingType == "big-bus" || BOOKINGMANAGER.ticketModel?.bookingType == "hero-balloon" {
            _loadTimeData(true)
            let option = BOOKINGMANAGER.bookingModel.tourDetails.first(where: { $0.optionId == _selectedBigBusOptionModel?.id })
            let optionUnits = _selectedBigBusOptionModel?.units.toArray(ofType: BigBusUnitModel.self) ?? []
            var unitsArray: [[String: Any]] = []
            func addUnit(for type: String, quantity: Int?) {
                guard let qty = quantity, qty > 0 else { return }
                if let unit = optionUnits.first(where: { $0.type.lowercased() == type.lowercased() }) {
                    unitsArray.append([
                        "id": unit.id,
                        "quantity": qty
                    ])
                }
            }
            addUnit(for: "adult", quantity: option?.adult ?? 0)
            addUnit(for: "child", quantity: option?.child ?? 0)
            addUnit(for: "infant", quantity: option?.infant ?? 0)
            
            let params: [String: Any] = [
                "tourId": BOOKINGMANAGER.ticketModel?.code ?? "",
                "optionId": _selectedBigBusOptionModel?.id ?? "",
                "fromDate": Utils.dateToString(_selectedDate, format: kFormatDate),
                "toDate": Utils.dateToString(_selectedDate, format: kFormatDate),
                "units": unitsArray,
                "pickupRequested": _selectedBigBusOptionModel?.pickupRequired == true,
                "pickupPointId": _selectedPickup?.pickupId ?? "",
            ]
            self._bigBusSlot.removeAll()
            WhosinServices.bigBusAvailability(params: params) { [weak self] container, error in
                guard let self = self else { return }
                if error != nil {
                    _loadTimeData()
                }
                self.hideHUD(error: error)
                guard let data = container?.data else { return }
                self._bigBusSlot = data
                self._loadTimeData()
            }
        }
    }
    
    // --------------------------------------
    // MARK: Updater
    // --------------------------------------
    
    private func _validateDoneButton() {
        let isValid = _isValidate
        _doneButton.backgroundColor = isValid ? ColorBrand.brandGreen : ColorBrand.brandgradientBlue
        _doneButton.backgroundColor = isValid ? ColorBrand.brandGreen : ColorBrand.clear
        _doneButton.borderColor = isValid ? ColorBrand.clear : ColorBrand.white
        _doneButton.borderWidth = 1
        _doneButton.isEnabled = isValid
    }
    
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction func _handleChangeDateEvent(_ sender: CustomButton) {
        let controller = INIT_CONTROLLER_XIB(DateTimePickerVC.self)
        controller.date = nil
        controller.isCreateEvent = true
        controller.validDateRange = dates
        controller.selectedOption = _selectedTourOptionModel?.optionDetail
        controller.operationdays = self._validDayList
        controller.allowTodaysBooking = _selectedTourOptionModel?.allowTodaysBooking ?? true
        controller.didUpdateCallback = { [weak self] date, time in
            guard let self = self else { return }
            let dates = Utils.dateToStringWithTimezone(date, format: kFormatDateLocal)
            self._selectedDate = Utils.stringToDate(dates, format: kFormatDateLocal)
            self._dayLabel.text = Utils.dateToStringWithTimezone(date, format: "E,")
            self._dateLabel.text = Utils.dateToStringWithTimezone(date, format: "dd")
            self._monthLabel.text = Utils.dateToStringWithTimezone(date, format: "MMM yyyy")
            self._selectedDateView.isHidden = false
            self._dateCollectionView.isHidden = true
            if BOOKINGMANAGER.ticketModel?.bookingType == "travel-desk" {
                self._isValidate = self.isSlots ? self.selectedTravel != nil && self._selectedDate != nil : true
            } else {
                self._isValidate = self.isSlots ? self.selectedFilter != nil && self._selectedDate != nil : true
            }
            self._loadTimeData(true)
            self._requestTimeSlot()
            self._validateDoneButton()
        }
        presentAsPanModal(controller: controller)
    }
    
    @IBAction private func _handleDoneEvent(_ sender: UIButton) {
        guard _isValidate else { return }
        if let _selectedDate = self._selectedDate {
            dismiss(animated: true) {
                if BOOKINGMANAGER.ticketModel?.bookingType == "travel-desk" {
                    self.didUpdateCallback?(_selectedDate, self.selectedTravel ?? TravelDeskAvailibilityModel())
                } else if BOOKINGMANAGER.ticketModel?.bookingType == "big-bus" || BOOKINGMANAGER.ticketModel?.bookingType == "hero-balloon"{
                    self.didUpdateCallback?(_selectedDate, self.selectedBigbus ?? OctoAvailibilityModel())
                } else {
                    self.didUpdateCallback?(_selectedDate, self.selectedFilter ?? TourTimeSlotModel())
                }
            }
        } else {
            dismissOrBack(true)
        }
    }
    
    @IBAction private func _handleContactusEvent(_ sender: CustomButton) {
        self.dismiss(animated: true) {
            self.contactCallback?()
        }
    }

}

extension NewDateTimePickerVC: CustomCollectionViewDelegate {
    
    // --------------------------------------
    // MARK: <CustomCollectionViewDelegate>
    // --------------------------------------
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        if collectionView == _dateCollectionView {
            return CGSize(width: collectionView.frame.width / 5 , height: CalenderDatesView.height)
        } else if collectionView == _collectionView {
            return CGSize(width: collectionView.frame.width, height: OptionTimeSlotCollectionCell.height)
        } else { return .zero }
    }
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? OptionTimeSlotCollectionCell {
            if let object = cellDict?[kCellObjectDataKey] as? TourTimeSlotModel {
                cell.setupData(object, object == selectedFilter)
            } else if let object = cellDict?[kCellObjectDataKey] as? TravelDeskAvailibilityModel {
                cell.setupData(object, object == selectedTravel)
            } else if let object = cellDict?[kCellObjectDataKey] as? OctoAvailibilityModel {
                cell.setupData(object, object == selectedBigbus)
            }
        } else if let cell = cell as? CalenderDatesView {
            if let object = cellDict?[kCellObjectDataKey] as? Date {
                cell.setup(object, isLast: indexPath.item == dates.count, isSelected: selectedIndex == indexPath.row)
            } else {
                cell.setup(Date(), isLast: true, isSelected: false)
            }
        } else if let cell = cell as? LoadingCollectionCell {
            cell.setupUi()
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? CalenderDatesView {
            if indexPath.item == 4 {
                let controller = INIT_CONTROLLER_XIB(DateTimePickerVC.self)
                controller.date = nil
                controller.validDateRange = dates
                controller.isCreateEvent = true
                controller.operationdays = self._validDayList
                controller.selectedOption = _selectedTourOptionModel?.optionDetail
                controller.allowTodaysBooking = _selectedTourOptionModel?.allowTodaysBooking ?? true
                controller.didUpdateCallback = { [weak self] date, time in
                    guard let self = self else { return }
                    let dates = Utils.dateToStringWithTimezone(date, format: kFormatDateLocal)
                    self._selectedDate = Utils.stringToDate(dates, format: kFormatDateLocal)
                    self._dayLabel.text = Utils.dateToStringWithTimezone(date, format: "E,")
                    self._dateLabel.text = Utils.dateToStringWithTimezone(date, format: "dd")
                    self._monthLabel.text = Utils.dateToStringWithTimezone(date, format: "MMM yyyy")
                    self._selectedDateView.isHidden = false
                    self._dateCollectionView.isHidden = true
                    if BOOKINGMANAGER.ticketModel?.bookingType == "travel-desk" {
                        self._isValidate = self.isSlots ? self.selectedTravel != nil && self._selectedDate != nil : true
                    } else {
                        self._isValidate = self.isSlots ? self.selectedFilter != nil && self._selectedDate != nil : true
                    }
                    if self.isSlots {
                        _loadTimeData(true)
                        _requestTimeSlot()
                    }
                    self._validateDoneButton()
                }
                presentAsPanModal(controller: controller)
            } else {
                selectedIndex = indexPath.row
                _selectedDate = dates[indexPath.row]
                _dateCollectionView.reload()
                if self.isSlots {
                    _loadTimeData(true)
                    _requestTimeSlot()
                }
            }
        } else if let cell = cell as? OptionTimeSlotCollectionCell {
            if let object = cellDict?[kCellObjectDataKey] as? TourTimeSlotModel {
                selectedFilter = object
            } else if let object = cellDict?[kCellObjectDataKey] as? TravelDeskAvailibilityModel {
                selectedTravel = object
            } else if let object = cellDict?[kCellObjectDataKey] as? OctoAvailibilityModel {
                selectedBigbus = object
            }
            _collectionView.reload()
        }
        if BOOKINGMANAGER.ticketModel?.bookingType == "travel-desk" {
            _isValidate = self.isSlots ? selectedTravel != nil && _selectedDate != nil : true
        } else if BOOKINGMANAGER.ticketModel?.bookingType == "big-bus" || BOOKINGMANAGER.ticketModel?.bookingType == "hero-balloon" {
            _isValidate = self.isSlots ? selectedBigbus != nil && _selectedDate != nil : true
        } else {
            _isValidate = self.isSlots ? selectedFilter != nil && _selectedDate != nil : true
        }
        _validateDoneButton()
    }
}

