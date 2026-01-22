
import UIKit
import PanModal
import FSCalendar
import SnapKit

struct TimePeriod {
    var date: String = kEmptyString
    var startTime: String = kEmptyString
    var endTime: String = kEmptyString
    
    static func ==(lhs: TimePeriod, rhs: TimePeriod) -> Bool {
        return lhs.startTime == rhs.startTime && lhs.endTime == rhs.endTime
    }
}

class DateTimePickerVC: BaseViewController {
    var selectedDate: Date? = nil
    var selectedTimeSlot: String = kEmptyString
    var date: Date? = nil
    var venueModel: VenueDetailModel?
    var startDate: Date? = nil
    var endDate: Date? = nil
    var didUpdateCallback: ((_ date: Date, _ time: TimePeriod) -> Void)?
    @IBOutlet private weak var _mainContainerView: UIView!
    @IBOutlet weak private var _calendarContainerView: UIView!
    @IBOutlet weak private var _dateLabel: UILabel!
    @IBOutlet private weak var _collectionView: CustomCollectionView!
    @IBOutlet private weak var _doneButton: UIButton!
    @IBOutlet weak var _timeVieww: UIView!
    
    private let kCellIdentifier = String(describing: TimeCalenderCell.self)
    private var _calendarView = CalendarView()
    private var _startingDate: Date = Date()
    private var _endingDate: Date = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    private var _validDayList: [String] = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]
    
    private var _timePeriodList: [TimePeriod] = []
    public var _selectedPeriod: TimePeriod?
    public var isCreateEvent: Bool = false
    public var allowTodaysBooking: Bool = true
    public var operationdays: [String] = []
    public var validDateRange: [Date] = []
    public var selectedOption: TourOptionDataModel?

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    func generateTimeSlots(startDate: Date, endDate: Date, timeSlotInMinutes: Int, selectedDate: String) -> [TimePeriod] {
        var timeSlots: [TimePeriod] = []
        var currentDate = startDate
        
        let calendar = Calendar.current
        while currentDate < endDate {
            guard let endTime = calendar.date(byAdding: .minute, value: timeSlotInMinutes, to: currentDate) else {
                break
            }
            if endDate >= endTime {
                let date = "\(selectedDate) \(Utils.dateToString(currentDate, format: kFormatDateTimeUS))"
                if !Utils.isDateExpired(dateString: date, format: "yyyy-MM-dd HH:mm") {
                    timeSlots.append(TimePeriod(startTime: Utils.dateToString(currentDate, format: kFormatDateTimeUS), endTime: Utils.dateToString(endTime, format: kFormatDateTimeUS)))
                }
            } else {
                let date = "\(selectedDate) \(Utils.dateToString(currentDate, format: kFormatDateTimeUS))"
                if !Utils.isDateExpired(dateString: date, format: "yyyy-MM-dd HH:mm") {
                    timeSlots.append(TimePeriod(startTime: Utils.dateToString(currentDate, format: kFormatDateTimeUS), endTime: Utils.dateToString(endDate, format: kFormatDateTimeUS)))
                }
            }
            
            currentDate = endTime
        }
        return timeSlots
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _venueModel = venueModel {
            _validDayList = _venueModel.timing.toArrayDetached(ofType: TimingModel.self).map{ $0.day }
            print("Valid days : \(_validDayList)")
        } else {
            _timePeriodList.append(TimePeriod(startTime: "01:00", endTime: "02:30"))
            _timePeriodList.append(TimePeriod(startTime: "02:30", endTime: "04:00"))
            _timePeriodList.append(TimePeriod(startTime: "05:00", endTime: "07:30"))
            _timePeriodList.append(TimePeriod(startTime: "07:30", endTime: "09:00"))
            _timePeriodList.append(TimePeriod(startTime: "09:00", endTime: "11:30"))
            _timePeriodList.append(TimePeriod(startTime: "04:00", endTime: "05:30"))
            _timePeriodList.append(TimePeriod(startTime: "05:30", endTime: "07:00"))
            _timePeriodList.append(TimePeriod(startTime: "07:00", endTime: "08:30"))
            _timePeriodList.append(TimePeriod(startTime: "08:30", endTime: "10:00"))
            _timePeriodList.append(TimePeriod(startTime: "10:00", endTime: "11:30"))
            _timePeriodList.append(TimePeriod(startTime: "11:30", endTime: "13:00"))
            _timePeriodList.append(TimePeriod(startTime: "13:00", endTime: "14:30"))
            _timePeriodList.append(TimePeriod(startTime: "14:30", endTime: "16:00"))
            _timePeriodList.append(TimePeriod(startTime: "16:00", endTime: "17:30"))
            _timePeriodList.append(TimePeriod(startTime: "17:30", endTime: "19:00"))
            _timePeriodList.append(TimePeriod(startTime: "19:00", endTime: "20:30"))
            _timePeriodList.append(TimePeriod(startTime: "20:30", endTime: "22:00"))
            _timePeriodList.append(TimePeriod(startTime: "22:00", endTime: "23:30"))
        }
        if !operationdays.isEmpty && operationdays.count != 0 {
            _validDayList = operationdays
        }
        _configDateAndTime()
        setupUi()
        _updateDate(date: selectedDate)
    }
    
    private func _configDateAndTime() {
        if let start = startDate,let end = endDate {
            _startingDate = start
            _endingDate = end
        }
        if let start = startDate {
            _startingDate = start
        }
        if let _venueModel = venueModel {
            _startingDate = Date()
            if let endDate = Utils.getYearDate(startDate: Date()) {
                _endingDate = endDate
            }
        }
        
    }
    
    override func setupUi() {
        _mainContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        //CALENDAR VIEW
        _calendarContainerView.addSubview(_calendarView)
        _calendarView.snp.makeConstraints { make in make.edges.equalToSuperview() }
        if selectedDate != nil {
            _calendarView.select(selectedDate)
        }
        _calendarView.delegate = self
        _calendarView.dataSource = self
        _calendarView.scope = .month
        _calendarView.updateCalendarHeaderTitle()
        
        //COLLECTION VIEW
        let spacing = kCollectionViewDefaultSpacing
        let margin = kCollectionViewDefaultMargin
        _collectionView.setup(cellPrototypes: _prototypes,
                              hasHeaderSection: false,
                              enableRefresh: false,
                              columns: 1,
                              rows: 1,
                              edgeInsets: UIEdgeInsets(top: spacing, left: .zero, bottom: spacing, right: .zero),
                              spacing: CGSize(width: margin, height: margin),
                              scrollDirection: .horizontal,
                              isDummyLoad: true,
                              emptyDataText: nil,
                              emptyDataIconImage: nil,
                              delegate: self)
        _collectionView.showsVerticalScrollIndicator = false
        _collectionView.showsHorizontalScrollIndicator = false
        _loadTimeData()
        _validateDoneButton()
    }
    
    // --------------------------------------
    // MARK: Private Accessor
    // --------------------------------------
    
    private var _prototypes: [[String: Any]]? {
        return [ [kCellIdentifierKey: kCellIdentifier, kCellNibNameKey: String(describing: TimeCalenderCell.self), kCellClassKey: TimeCalenderCell.self, kCellHeightKey: TimeCalenderCell.height] ]
    }
    
    private var _isValidate: Bool {
        if date == nil { return false }
        if !isCreateEvent {
            if _selectedPeriod == nil { return false }
        }
        
        return true
    }
    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    private func _loadTimeData() {
        var cellSectionData = [[String: Any]]()
        var cellData = [[String: Any]]()
        _timePeriodList.forEach { model in
            cellData.append([
                kCellIdentifierKey: kCellIdentifier,
                kCellObjectDataKey: model,
                kCellClassKey: TimeCalenderCell.self,
                kCellHeightKey: TimeCalenderCell.height
            ])
        }
        cellSectionData.append([kSectionTitleKey: kEmptyString, kSectionDataKey: cellData])
        _collectionView.loadData(cellSectionData)
        
    }
    
    private func _isValidDay(date: Date) -> Bool {
        var currentDate = date.addingTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT(for: date)))
        if TimeZone.current.isDaylightSavingTime(for: date) {
            currentDate = currentDate.addingTimeInterval(TimeInterval(3600))
        }
        
        if BOOKINGMANAGER.ticketModel != nil && !validDateRange.isEmpty {
            if (BOOKINGMANAGER.ticketModel?.bookingEndDate != nil && BOOKINGMANAGER.ticketModel?.bookingStartDate != nil) || BOOKINGMANAGER.ticketModel?.bookingDates.isEmpty == false || selectedOption?.bookingDates.isEmpty == false || BOOKINGMANAGER.ticketModel?.bookingType == "whosin" || BOOKINGMANAGER.ticketModel?.bookingType == "travel-desk" {
                return validDateRange.contains { Calendar.current.isDate($0, inSameDayAs: date) }
            }
        }
        
        if !allowTodaysBooking {
            let today = Date().addingTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT(for: Date())))
            if Calendar.current.isDate(currentDate, inSameDayAs: today) {
                currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            }
        }
        
        var currentDay = Utils.dateToStringWithTimezone(currentDate, format: kFormatDateDayShort).lowercased()
        let isValidDate = Utils.dateOnly(currentDate)?.isBetween(_startingDate, and: _endingDate) ?? true
        if _validDayList.contains(currentDay) && isValidDate {
            return true
        }
        
        currentDay = Utils.dateToStringWithTimezone(currentDate, format: kFormatDateDayLong).lowercased()
        return _validDayList.contains(currentDay) && isValidDate
    }
    
    // --------------------------------------
    // MARK: Updater
    // --------------------------------------
    
    private func _updateDate(date: Date?) {
        _dateLabel.superview?.isHidden = date == nil
        _dateLabel.text = Utils.dateToStringWithTimezone(date, format: kFormatEventDate)
        self.date = date
        if isCreateEvent {
            _selectedPeriod = TimePeriod(startTime: "00:00", endTime: "23:00")
            _timeVieww.isHidden = true
            _validateDoneButton()
        }
    }
    
    private func _updateTime() {
        _validateDoneButton()
        _loadTimeData()
    }
    
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
    
    @IBAction private func _handleDoneEvent(_ sender: UIButton) {
        guard let _selectedPeriod = _selectedPeriod else { return }
        guard let _date = date else { return }
        dismiss(animated: true) {
            self.didUpdateCallback?(_date, _selectedPeriod)
        }
    }
}

extension DateTimePickerVC: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        if !allowTodaysBooking && Calendar.current.isDateInToday(date) {
            return ColorBrand.brandGray
        }
        return _isValidDay(date: date) ? ColorBrand.white : ColorBrand.brandGray
    }
    
    // --------------------------------------
    // MARK: <FSCalendarDataSource>
    // --------------------------------------
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        allowTodaysBooking ? _startingDate : Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        _endingDate
    }
    
    // --------------------------------------
    // MARK: <FSCalendarDelegate>
    // --------------------------------------
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return _isValidDay(date: date)
    }
    
    func calendar(_: FSCalendar, boundingRectWillChange bounds: CGRect, animated _: Bool) {
        view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        var dateSelected = date.addingTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT(for: date)))
        if TimeZone.current.isDaylightSavingTime(for: date) {
            dateSelected = dateSelected.addingTimeInterval(TimeInterval(3600))
        }
        if let _venueModel = venueModel {
            let startDateStr = Utils.dateToString(dateSelected, format: kFormatDate)
            let selectedSlot = _venueModel.timing.toArrayDetached(ofType: TimingModel.self).first(where: {$0.day.lowercased() == dateSelected.day.lowercased()})
            let startDateTimeStr = startDateStr + " \(selectedSlot?.openingTime ?? kEmptyString)"
            let startDateTime = Utils.stringToDate(startDateTimeStr, format: kFormatDateTimeLocal)
            let endDateTimeStr = startDateStr + " \(selectedSlot?.closingTime ?? kEmptyString)"
            let endDateTime = Utils.stringToDate(endDateTimeStr, format: kFormatDateTimeLocal)
            
            guard let startDate = Utils.timeOnlyCalender(startDateTime) else {return}
            guard let endDate = Utils.timeOnlyCalender(endDateTime) else { return }
            guard let adjustEndDate = Utils.adjustEndTime(startDate: startDate, endTime: endDate) else { return }
            
            if isCreateEvent {
                _selectedPeriod = TimePeriod(startTime: selectedSlot?.openingTime ?? kEmptyString, endTime: selectedSlot?.closingTime ?? kEmptyString)
                _timeVieww.isHidden = true
                _updateDate(date: date)
                _validateDoneButton()
            } else {
                _timePeriodList.removeAll()
                let slots = generateTimeSlots(startDate: startDate, endDate: adjustEndDate, timeSlotInMinutes: 90, selectedDate: startDateStr)
                _timePeriodList.append(contentsOf: slots)
                _collectionView.clearAndReload()
                DISPATCH_ASYNC_MAIN_AFTER(0.1) {
                    self._loadTimeData()
                }
                _updateDate(date: date)
            }
        } else {
            if isCreateEvent {
                _selectedPeriod = TimePeriod(startTime: "00:00", endTime: "23:00")
                _timeVieww.isHidden = true
                _updateDate(date: date)
                _validateDoneButton()
            } else {
                DISPATCH_ASYNC_MAIN_AFTER(0.1) {
                    self._loadTimeData()
                }
                _updateDate(date: date)
            }
            
        }
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        DISPATCH_ASYNC_MAIN_AFTER(0.1) { [weak self] in
            if calendar.visibleCells().compactMap({ calendar.date(for: $0) }).contains(self?.date) { self?._calendarView.updateCalendarHeaderTitle() }
        }
    }
}

extension DateTimePickerVC: CustomCollectionViewDelegate {
    
    // --------------------------------------
    // MARK: <CustomCollectionViewDelegate>
    // --------------------------------------
    
    func cellSize(_ collectionView: UICollectionView, cellDict: [String : Any]?, indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: TimeCalenderCell.height)
    }
    
    func setupCollectionCell(_ cell: UICollectionViewCell, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let cell = cell as? TimeCalenderCell,
              let object = cellDict?[kCellObjectDataKey] as? TimePeriod else { return }
        var isSelected = "\(object.startTime) - \(object.endTime)" == selectedTimeSlot
        if let _selectedPeriod = _selectedPeriod {
            isSelected = _selectedPeriod == object
        }
        cell.setup(date: object, isSelected: isSelected, isEnable: true)
    }
    
    func didSelectCell(_ cell: UICollectionViewCell, sectionTitle: String?, cellDict: [String : Any]?, indexPath: IndexPath) {
        guard let object = cellDict?[kCellObjectDataKey] as? TimePeriod else { return }
        _selectedPeriod = object
        _updateTime()
    }
}

extension DateTimePickerVC: PanModalPresentable {
    
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
        return UIColor.black.withAlphaComponent(0.3)
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
