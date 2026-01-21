import FSCalendar

class CalendarView: FSCalendar, FSCalendarDataSource {
        
    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------

    override init(frame: CGRect) {
        super.init(frame: frame)
        _customInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _customInit()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        _customInit()
    }

    // --------------------------------------
    // MARK: Private
    // --------------------------------------

    private func _customInit() {
        appearance.caseOptions = .weekdayUsesUpperCase
        appearance.titleFont = FontBrand.SFmediumFont(size: 14)
        appearance.subtitleFont = FontBrand.SFmediumFont(size: 14)
        appearance.weekdayFont = FontBrand.SFmediumFont(size: 14)
        appearance.headerTitleFont = FontBrand.SFmediumFont(size: 14)
        appearance.titleDefaultColor = ColorBrand.white
        appearance.titlePlaceholderColor = ColorBrand.brandGray
        appearance.headerTitleColor = ColorBrand.white
        appearance.weekdayTextColor = ColorBrand.white
        appearance.selectionColor = ColorBrand.brandgradientPink
        appearance.todaySelectionColor = ColorBrand.brandPink
        appearance.todayColor = ColorBrand.clear
        firstWeekday = 1
    }

    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func updateCalendarHeaderTitle() {
        guard let date = selectedDate else { return }
        
        DispatchQueue.main.async {
            self.calendarHeaderView.collectionView.reloadData()
            if let cell = (self.calendarHeaderView.collectionView.visibleCells as? [FSCalendarHeaderCell])?.last {
                let text = Utils.dateToString(Utils.dateOnlyWithTimeZone(date), format: kFormatMonthYearLong)
                cell.titleLabel.text = text
            }
        }
    }
}
