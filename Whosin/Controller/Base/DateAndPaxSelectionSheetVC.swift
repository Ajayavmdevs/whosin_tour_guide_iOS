import UIKit
import PanModal
import FSCalendar
import SnapKit
import Foundation

class DateAndPaxSelectionSheetVC: BaseViewController {
    
    @IBOutlet weak private var _calendarContainerView: UIView!
    @IBOutlet private weak var _doneButton: UIButton!
    @IBOutlet weak var _dateCollectionView: CustomCollectionView!
    @IBOutlet weak var _endDateCollectionView: CustomCollectionView!
    @IBOutlet weak var _selectedDateView: UIView!
    @IBOutlet weak var _endSelectedDateView: UIView!
    @IBOutlet weak var _dayLabel: CustomLabel!
    @IBOutlet weak var _dateLabel: CustomLabel!
    @IBOutlet weak var _monthLabel: CustomLabel!
    @IBOutlet weak var _endDayLabel: CustomLabel!
    @IBOutlet weak var _endDateLabel: CustomLabel!
    @IBOutlet weak var _endMonthLabel: CustomLabel!
    @IBOutlet weak var _timeSlotTitle: UILabel!
    @IBOutlet weak var _slotView: UIView!
    @IBOutlet weak var _sapratorView: UIView!
    @IBOutlet weak var _tableView: CustomNoKeyboardTableView!
    
    private let kCellIdentifierDate = String(describing: CalenderDatesView.self)
    private let kCellIdentifierLoading = String(describing: LoadingCollectionCell.self)
    private let kCellIdentifierTableRoomSelection = String(describing: RoomsSelectionTableCell.self)
    public var ticketModel: TicketModel? = nil
    private var _startingDate: Date = Date()
    private var _endingDate: Date = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    private var _validDayList: [String] = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]
    
    public var _selectedDate: Date? {
        didSet {
            BOOKINGMANAGER.date = _selectedDate
        }
    }
    public var _selectedEndDate: Date? {
        didSet {
            BOOKINGMANAGER.endDate = _selectedEndDate
        }
    }
    public var allowTodaysBooking: Bool = true
    private var startDates: [Date] = []
    private var endDates: [Date] = []
    private var selectedIndex: Int? = 0
    private var selectedEndIndex: Int? = nil
    public var isSlots: Bool = false

    // MARK: - Hotel booking state
    public var hotelCode: String = ""
    public var bookingRequest = HotelBookingRequest(hotelCode: "", startDate: "", endDate: "", paxes: [])

    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _slotView.isHidden = false
        setupUi()
        setupDates()
        
        // Initialize hotel booking request model
        if bookingRequest.hotelCode.isEmpty {
            bookingRequest.hotelCode = ticketModel?.code ?? hotelCode
        }
        BOOKINGMANAGER.ticketModel = ticketModel
        // Set initial dates into the model
        bookingRequest.setDates(start: _selectedDate, end: _selectedEndDate)
        // Ensure at least one room exists
        if bookingRequest.paxes.isEmpty {
            bookingRequest.addRoom(defaultAge: 20)
        }
        // Sync initial counts to BOOKINGMANAGER
        let counts = bookingRequest.totalCounts()
        BOOKINGMANAGER.adults = counts.adults
        BOOKINGMANAGER.childs = counts.children
        BOOKINGMANAGER.infants = counts.infants
        _tableView.reloadData()
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
        //COLLECTION VIEW
        _endDateCollectionView.setup(
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
        _endDateCollectionView.showsVerticalScrollIndicator = false
        _endDateCollectionView.showsHorizontalScrollIndicator = false
        
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

    }
    
    // --------------------------------------
    // MARK: Private Accessor
    // --------------------------------------
    
    private var _prototype: [[String: Any]]? {
        return [
            [kCellIdentifierKey: kCellIdentifierTableRoomSelection, kCellNibNameKey: kCellIdentifierTableRoomSelection, kCellClassKey: RoomsSelectionTableCell.self, kCellHeightKey: RoomsSelectionTableCell.height]
        ]
    }

    
    private var _prototypes: [[String: Any]]? {
        return [[kCellIdentifierKey: kCellIdentifierDate, kCellNibNameKey: kCellIdentifierDate, kCellClassKey: CalenderDatesView.self, kCellHeightKey: CalenderDatesView.height],
                 [kCellIdentifierKey: kCellIdentifierLoading, kCellNibNameKey: kCellIdentifierLoading, kCellClassKey: LoadingCollectionCell.self, kCellHeightKey: LoadingCollectionCell.height]]
    }
    
    private var _isValidate: Bool = false
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func setupDates() {
        startDates = BOOKINGMANAGER.ticketModel?.dateRange(allowTodaysBooking, validDays: _validDayList, option: TourOptionsModel()) ?? []
        
        _selectedDate = startDates.first
        updateEndDates()   // filter end dates
        _loadStartCalenderData()
        _loadEndCalenderData()
        _validateDoneButton()
        
        if startDates.isEmpty {
            _dateCollectionView.isHidden = true
            _timeSlotTitle.isHidden = true
            _sapratorView.isHidden = true
            alert(message: "no_date_available_ticket_option".localized())
            return
        }
        _loadRoomsData()
    }
    
    private func updateEndDates() {
        if let start = _selectedDate {
            if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: start) {
                endDates = startDates.filter { $0 >= nextDay }
            } else {
                endDates = []
            }
        } else {
            endDates = startDates
        }
        _loadEndCalenderData()
    }

    
    private func _loadStartCalenderData() {
        var section = [[String: Any]]()
        var items = [[String: Any]]()
        startDates.prefix(4).forEach { date in
            items.append([
                kCellIdentifierKey: kCellIdentifierDate,
                kCellObjectDataKey: date,
                kCellClassKey: CalenderDatesView.self,
                kCellHeightKey: CalenderDatesView.height
            ])
        }
        if startDates.count > 3 {
            items.append([
                kCellIdentifierKey: kCellIdentifierDate,
                kCellObjectDataKey: true,
                kCellClassKey: CalenderDatesView.self,
                kCellHeightKey: CalenderDatesView.height
            ])
        }
        section.append([kSectionTitleKey: kEmptyString, kSectionDataKey: items])
        _dateCollectionView.loadData(section)
    }

    private func _loadEndCalenderData() {
        var section = [[String: Any]]()
        var items = [[String: Any]]()
        endDates.prefix(4).forEach { date in
            items.append([
                kCellIdentifierKey: kCellIdentifierDate,
                kCellObjectDataKey: date,
                kCellClassKey: CalenderDatesView.self,
                kCellHeightKey: CalenderDatesView.height
            ])
        }
        if endDates.count > 3 {
            items.append([
                kCellIdentifierKey: kCellIdentifierDate,
                kCellObjectDataKey: true,
                kCellClassKey: CalenderDatesView.self,
                kCellHeightKey: CalenderDatesView.height
            ])
        }
        section.append([kSectionTitleKey: kEmptyString, kSectionDataKey: items])
        _endDateCollectionView.loadData(section)
    }
    
    private func _loadRoomsData() {
        var section = [[String: Any]]()
        var items = [[String: Any]]()
        let roomCount = max(bookingRequest.paxes.count, 1)
        for idx in 0..<roomCount {
            items.append([
                kCellIdentifierKey: kCellIdentifierTableRoomSelection,
                kCellObjectDataKey: idx,
                kCellClassKey: RoomsSelectionTableCell.self,
                kCellHeightKey: RoomsSelectionTableCell.height
            ])
        }
        section.append([kSectionTitleKey: kEmptyString, kSectionDataKey: items])
        _tableView.loadData(section)
    }
    
    private func updateStartLabels(with date: Date) {
        _dayLabel.text = Utils.dateToStringWithTimezone(date, format: "E,")
        _dateLabel.text = Utils.dateToStringWithTimezone(date, format: "dd")
        _monthLabel.text = Utils.dateToStringWithTimezone(date, format: "MMM yyyy")
        
        bookingRequest.setDates(start: _selectedDate, end: _selectedEndDate)
    }

    private func updateEndLabels(with date: Date) {
        _endDayLabel.text = Utils.dateToStringWithTimezone(date, format: "E,")
        _endDateLabel.text = Utils.dateToStringWithTimezone(date, format: "dd")
        _endMonthLabel.text = Utils.dateToStringWithTimezone(date, format: "MMM yyyy")
        
        bookingRequest.setDates(start: _selectedDate, end: _selectedEndDate)
    }

    private func collectionView(for cell: UICollectionViewCell) -> UICollectionView? {
        var view: UIView? = cell
        while let v = view, !(v is UICollectionView) {
            view = v.superview
        }
        return view as? UICollectionView
    }

    private func enforceEndAfterStartIfNeeded() {
        if let start = _selectedDate, let end = _selectedEndDate, end < start {
            _selectedEndDate = start
            updateEndLabels(with: start)
        }
    }
    
    // --------------------------------------
    // MARK: Service
    // --------------------------------------
    
        
    // --------------------------------------
    // MARK: Updater
    // --------------------------------------
    
    private func _validateDoneButton() {
        let isValid: Bool
        if let start = _selectedDate, let end = _selectedEndDate {
            isValid = end >= start
        } else {
            isValid = false
        }
        _doneButton.backgroundColor = isValid ? ColorBrand.brandPink : UIColor.init(hexString: "#ADADAD")
        _doneButton.backgroundColor = isValid ? ColorBrand.brandPink : UIColor.init(hexString: "#ADADAD")
        _doneButton.borderColor = ColorBrand.clear
        _doneButton.borderWidth = 0
        _doneButton.isEnabled = isValid
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    @IBAction func handleAddMoreRoomEvent(_ sender: CustomButton) {
        bookingRequest.addRoom(defaultAge: 20)
        _loadRoomsData()
    }
    
    @IBAction private func _handleBackEvent(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func _handleChangeDateEvent(_ sender: CustomButton) {
        let controller = INIT_CONTROLLER_XIB(DateTimePickerVC.self)
        controller.date = nil
        controller.isCreateEvent = true
        controller.validDateRange = startDates
        controller.selectedOption = TourOptionDataModel()
        controller.operationdays = self._validDayList
        controller.allowTodaysBooking = true
        controller.didUpdateCallback = { [weak self] date, time in
            guard let self = self else { return }
            let dateString = Utils.dateToStringWithTimezone(date, format: kFormatDateLocal)
            self._selectedDate = Utils.stringToDate(dateString, format: kFormatDateLocal)
            if let selected = self._selectedDate {
                self.updateStartLabels(with: selected)
                self._selectedDateView.isHidden = false
                self._dateCollectionView.isHidden = true
                self.enforceEndAfterStartIfNeeded()
                self._dateCollectionView.reload()
                self.bookingRequest.setDates(start: self._selectedDate, end: self._selectedEndDate)
            }
            self.updateEndDates()
            self._validateDoneButton()
        }
        presentAsPanModal(controller: controller)
    }
    
    @IBAction private func _handleChangeEndDateEvent(_ sender: CustomButton) {
        let controller = INIT_CONTROLLER_XIB(DateTimePickerVC.self)
        controller.startDate = _selectedDate
        controller.isCreateEvent = true
        controller.validDateRange = endDates
        controller.selectedOption = TourOptionDataModel()
        controller.operationdays = self._validDayList
        controller.allowTodaysBooking = true
        controller.didUpdateCallback = { [weak self] date, time in
            guard let self = self else { return }
            let dateString = Utils.dateToStringWithTimezone(date, format: kFormatDateLocal)
            self._selectedDate = Utils.stringToDate(dateString, format: kFormatDateLocal)
            if let selected = self._selectedDate {
                self.updateEndLabels(with: selected)
                self._endSelectedDateView.isHidden = false
                self._endDateCollectionView.isHidden = true
                self.enforceEndAfterStartIfNeeded()
                self._dateCollectionView.reload()
                self._endDateCollectionView.reload()
                self.bookingRequest.setDates(start: self._selectedDate, end: self._selectedEndDate)
            }
            self._validateDoneButton()
        }
        presentAsPanModal(controller: controller)
    }
    
    @IBAction private func _handleDoneEvent(_ sender: UIButton) {
        if self._selectedDate == nil {
            alert(message: "please_select_date".localized())
            return
        }
        if self._selectedEndDate == nil {
            alert(message: "selectDateAndTime".localized())
            return
        }
        if let start = self._selectedDate, let end = self._selectedEndDate, end < start {
            alert(message: "endDateValidation".localized())
            return
        }
        if BOOKINGMANAGER.adults < 1 && BOOKINGMANAGER.ticketModel?.allowAdult == true {
            alert(message: "please_select_pax_qty".localized())
            return
        }
        
        if (BOOKINGMANAGER.childs + BOOKINGMANAGER.adults + BOOKINGMANAGER.infants) < 1 {
            alert(message: "please_select_pax_qty".localized())
            return
        }

        if bookingRequest.hotelCode.isEmpty {
            bookingRequest.hotelCode = BOOKINGMANAGER.ticketModel?.code ?? hotelCode
        }
        bookingRequest.setDates(start: _selectedDate, end: _selectedEndDate)
        
        let allRooms = bookingRequest.paxes
        for (roomIndex, room) in allRooms.enumerated() {
            let children = room.pax.filter { $0.age < 12 }
            for (childIndex, child) in children.enumerated() {
                if child.age <= 0 {
                    alert(message: LANGMANAGER.localizedString(forKey: "child_age_selection", arguments: ["value1": "\(childIndex + 1)", "value2": "\(roomIndex + 1)"]) )
                    return
                }
            }
        }

        // Persist selection in hotel booking manager
        HOTELBOOKINGMANAGER.saveDateAndPaxes(startDate: self._selectedDate, endDate: self._selectedEndDate,ticketId: ticketModel?._id ?? "", hotelCode: bookingRequest.hotelCode, roomPaxes: bookingRequest.paxes)
        
        if let data = try? JSONEncoder().encode(bookingRequest),
           let jsonString = String(data: data, encoding: .utf8) {
            print(jsonString)
            if let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                let vc = INIT_CONTROLLER_XIB(SelectHotelOptionVC.self)
                vc.ticketModel = self.ticketModel
                vc.params = dict
                vc.hidesBottomBarWhenPushed = true
                Utils.pushViewController(vc)
            }
        }
    }
}

extension DateAndPaxSelectionSheetVC: CustomCollectionViewDelegate {
    
    // --------------------------------------
    // MARK: <CustomCollectionViewDelegate>
    // --------------------------------------
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        if collectionView == _dateCollectionView || collectionView == _endDateCollectionView {
            return CGSize(width: collectionView.frame.width / 5 , height: CalenderDatesView.height)
        } else { return .zero }
    }
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        if let cell = cell as? CalenderDatesView {
            if let object = cellDict?[kCellObjectDataKey] as? Date {
                let cv = self.collectionView(for: cell)
                let matchesStart = _selectedDate.map { Calendar.current.isDate(object, inSameDayAs: $0) } ?? false
                let matchesEnd = _selectedEndDate.map { Calendar.current.isDate(object, inSameDayAs: $0) } ?? false
                let isSelected: Bool
                let isLast: Bool
                if cv === _dateCollectionView {
                    isSelected = matchesStart
                    isLast = indexPath.item == startDates.count
                } else if cv === _endDateCollectionView {
                    isSelected = matchesEnd
                    isLast = indexPath.item == endDates.count
                } else {
                    isSelected = false
                    isLast = false
                }
                cell.setup(object, isLast: isLast, isSelected: isSelected)
            } else {
                cell.setup(Date(), isLast: true, isSelected: false)
            }
        } else if let cell = cell as? LoadingCollectionCell {
            cell.setupUi()
        }
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cv = collectionView(for: cell) else { return }

        func presentPicker(validRange: [Date], completion: @escaping (Date) -> Void) {
            let controller = INIT_CONTROLLER_XIB(DateTimePickerVC.self)
            controller.date = nil
            controller.startDate = cv == _dateCollectionView ? nil : endDates.first
            controller.isCreateEvent = true
            controller.validDateRange = validRange
            controller.selectedOption = TourOptionDataModel()
            controller.operationdays = self._validDayList
            controller.allowTodaysBooking = true
            controller.didUpdateCallback = { [weak self] date, _ in
                guard let self = self else { return }
                let dateString = Utils.dateToStringWithTimezone(date, format: kFormatDateLocal)
                let picked = Utils.stringToDate(dateString, format: kFormatDateLocal) ?? date
                completion(picked)
                self._validateDoneButton()
            }
            presentAsPanModal(controller: controller)
        }

        if cv == _dateCollectionView {
            // Start date selection
            if indexPath.item == 4 {
                presentPicker(validRange: startDates) { [weak self] picked in
                    guard let self = self else { return }
                    self._selectedDate = picked
                    self.updateStartLabels(with: picked)
                    self._selectedDateView.isHidden = false
                    self._dateCollectionView.isHidden = true
                    self.enforceEndAfterStartIfNeeded()
                    self._dateCollectionView.reload()
                    self.updateEndDates()
                    self.bookingRequest.setDates(start: self._selectedDate, end: self._selectedEndDate)
                }
            } else {
                let picked = startDates[indexPath.row]
                _selectedDate = picked
                updateStartLabels(with: picked)
                updateEndDates()              // refresh end dates
                enforceEndAfterStartIfNeeded()
                _dateCollectionView.reload()
                _endDateCollectionView.reload()
                self.bookingRequest.setDates(start: self._selectedDate, end: self._selectedEndDate)
            }
        }
        else if cv == _endDateCollectionView {
            if indexPath.item == 4 {
                let validRange: [Date]
                if let start = _selectedDate {
                    validRange = endDates.filter { $0 >= start }
                } else {
                    validRange = endDates
                }
                presentPicker(validRange: validRange) { [weak self] picked in
                    guard let self = self else { return }
                    if self._selectedDate == nil {
                        self._selectedDate = picked
                        self.updateStartLabels(with: picked)
                        self._selectedDateView.isHidden = false
                    }
                    if let start = self._selectedDate, picked < start {
                        self.alert(message: "endDateValidation".localized())
                        return
                    }
                    self._selectedEndDate = picked
                    self.updateEndLabels(with: picked)
                    self._endSelectedDateView.isHidden = false
                    self._endDateCollectionView.isHidden = true
                    self._dateCollectionView.reload()
                    self._endDateCollectionView.reload()
                    self.bookingRequest.setDates(start: self._selectedDate, end: self._selectedEndDate)
                }
            } else {
                selectedEndIndex = indexPath.row
                let picked = endDates[indexPath.row]
                if let start = _selectedDate, picked < start {
                    alert(message: "endDateValidation".localized())
                    return
                }
                _selectedEndDate = picked
                updateEndLabels(with: picked)
                _endDateCollectionView.reload()
                self.bookingRequest.setDates(start: self._selectedDate, end: self._selectedEndDate)
            }
        }
        _validateDoneButton()
    }
}

extension DateAndPaxSelectionSheetVC: PanModalPresentable {
    
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var anchorModalToLongForm: Bool {
        return true
    }
    
    var springDamping: CGFloat {
        return 1.0
    }
    
    var panModalBackgroundColor: UIColor {
        return UIColor.black.withAlphaComponent(0.45)
    }
    
    var isHapticFeedbackEnabled: Bool {
        return true
    }
    
    var allowsTapToDismiss: Bool {
        return true
    }
    
    var allowsDragToDismiss: Bool {
        return true
    }
    
    public var showDragIndicator: Bool {
        return false
    }
    
    func panModalWillDismiss() {
    }
    
}

extension DateAndPaxSelectionSheetVC: CustomNoKeyboardTableViewDelegate {
    
    func setupCell(_ cell: UITableViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? RoomsSelectionTableCell else { return }
        let roomIndex = indexPath.row
        let roomTitle = LANGMANAGER.localizedString(forKey: "room", arguments: ["value": "\(roomIndex + 1)"])
        if roomIndex < bookingRequest.paxes.count {
            let paxList = bookingRequest.paxes[roomIndex].pax
            let adults = paxList.filter { $0.age >= 12 }.count
            let children = paxList.filter { $0.age < 12 }.count
            let childAges = bookingRequest.childAges(inRoom: roomIndex)
            cell.configure(roomTitle: roomTitle, adults: adults, children: children, childAges: childAges)
        } else {
            cell.configure(roomTitle: roomTitle, adults: 1, children: 0, childAges: [])
            if roomIndex >= bookingRequest.paxes.count {
                bookingRequest.addRoom(defaultAge: 20)
            }
        }
        
        cell.onChildAgeChanged = { [weak self] childIndex, age in
            guard let self = self else { return }
            bookingRequest.setChildAge(
                roomIndex: roomIndex,
                childIndex: childIndex,
                age: age
            )
        }

        cell.onCountsChanged = { [weak self] adults, children in
            guard let self = self else { return }
            if roomIndex >= self.bookingRequest.paxes.count {
                self.bookingRequest.addRoom(defaultAge: 20)
            }
            self.bookingRequest.setRoomCounts(index: roomIndex, adults: adults, children: children, preserveInfants: true)
            let totals = self.bookingRequest.totalCounts()
            BOOKINGMANAGER.adults = totals.adults
            BOOKINGMANAGER.childs = totals.children
            BOOKINGMANAGER.infants = totals.infants
        }

        cell.onRemoveItem = { [weak self] in
            guard let self = self else { return }
            guard indexPath.row < self.bookingRequest.paxes.count else { return }
            self.bookingRequest.paxes.remove(at: indexPath.row)
            let totals = self.bookingRequest.totalCounts()
            BOOKINGMANAGER.adults = totals.adults
            BOOKINGMANAGER.childs = totals.children
            BOOKINGMANAGER.infants = totals.infants
            self._loadRoomsData()
        }

        cell.onCollectionHeightChanged = { [weak self] height in
            guard let self = self else { return }
            print("Collection height changed: \(height)")
            self._tableView.reload()
        }
    }
    
    
}

