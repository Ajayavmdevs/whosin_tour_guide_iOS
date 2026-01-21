import UIKit
import PanModal
import FSCalendar
import SnapKit

class DatePickerVC: BaseViewController {
    
    var date: Date?
    var time: Date?
    var didUpdateCallback: ((_ date: Date?) -> Void)?
    
    @IBOutlet private weak var _mainContainerView: UIView!
    @IBOutlet weak private var _calendarContainerView: UIView!
    @IBOutlet private weak var _doneButton: UIButton!
    
    private var _calendarView = CalendarView()
    private var _endingDate: Date = Date()
    
    private var _validDayList: [String] = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]
    
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
        _updateDate(date: nil)
    }
    
    override func setupUi() {
        _mainContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        //CALENDAR VIEW
        _calendarContainerView.addSubview(_calendarView)
        _calendarView.snp.makeConstraints { make in make.edges.equalToSuperview() }
        _calendarView.select(nil)
        _calendarView.delegate = self
        _calendarView.dataSource = self
        _calendarView.scope = .month
        _calendarView.updateCalendarHeaderTitle()
        
    }
    
    // --------------------------------------
    // MARK: Private Accessor
    // --------------------------------------


    
    // --------------------------------------
    // MARK: Private
    // --------------------------------------
    
    
    // --------------------------------------
    // MARK: Updater
    // --------------------------------------
    
    private func _updateDate(date: Date?) {
        self.date = date
        _updateTime(date: nil)
    }
    
    private func _updateTime(date: Date?) {
        time = date
        _validateDoneButton()
    }
    
    
    private func _validateDoneButton() {
        _doneButton.backgroundColor = ColorBrand.brandPink
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction private func _handleDoneEvent(_ sender: UIButton) {
        didUpdateCallback?(date)
        dismiss(animated: true)
    }
}

extension DatePickerVC: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        return  ColorBrand.white//isValidDay(date: date) ? ColorBrand.white : ColorBrand.brandGray
    }
    
    // --------------------------------------
    // MARK: <FSCalendarDataSource>
    // --------------------------------------
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        _endingDate
    }
    
    // --------------------------------------
    // MARK: <FSCalendarDelegate>
    // --------------------------------------
    
//    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
//        return _isValidDay(date: date)
//    }

    func calendar(_: FSCalendar, boundingRectWillChange bounds: CGRect, animated _: Bool) {
        view.layoutIfNeeded()
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        var dateSelected = date.addingTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT(for: date)))
        if TimeZone.current.isDaylightSavingTime(for: date) {
            dateSelected = dateSelected.addingTimeInterval(TimeInterval(3600))
        }
        var selected: Date = Calendar.current.date(byAdding: .day, value: 1, to: date) ?? Date()
        _updateDate(date: selected)
    }

    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        DISPATCH_ASYNC_MAIN_AFTER(0.1) { [weak self] in
            if calendar.visibleCells().compactMap({ calendar.date(for: $0) }).contains(self?.date) { self?._calendarView.updateCalendarHeaderTitle() }
        }
    }
}

extension DatePickerVC: PanModalPresentable {
        
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
