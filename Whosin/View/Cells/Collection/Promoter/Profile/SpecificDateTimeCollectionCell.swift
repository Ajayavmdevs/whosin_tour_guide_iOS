import UIKit
protocol SpecificDateTimeCollectionCellDelegate: AnyObject {
    func didTapDeleteButton(at indexPath: IndexPath)
}

class SpecificDateTimeCollectionCell: UICollectionViewCell {

    @IBOutlet weak var _stackBgView: UIStackView!
    @IBOutlet weak var _deleteView: UIView!
    @IBOutlet weak var _selectDate: CustomActivityButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var _selectTime: CustomActivityButton!
    weak var delegate: SpecificDateTimeCollectionCellDelegate?
    var indexPath: IndexPath?
    public var callback: ((_ model: RepeatDateAndTimeModel?) -> Void)?
    private var dateModel: RepeatDateAndTimeModel?
    private var repeatStartDate: Date?
    private var repeatendDate: Date?
    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { 72 }
    
    // --------------------------------------
    // MARK: Life-Cycle
    // --------------------------------------

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func setupData(model: RepeatDateAndTimeModel, startDate: String, endDate: String) {
        repeatStartDate = Utils.stringToDate(startDate, format: kFormatDate)
        repeatendDate = Utils.stringToDate(endDate, format: kFormatDate)
        if let date = Utils.stringToDate(model.date, format: kFormatDate) {
            self._selectDate.setTitle(Utils.dateToString(date, format: kFormatEventDate))
        } else {
            self._selectDate.setTitle("select_date".localized())
        }
        if !Utils.stringIsNullOrEmpty(model.startTime), !Utils.stringIsNullOrEmpty(model.endTime) {
            let time = "from".localized() + (model.startTime) + " -" +  "till".localized() + (model.endTime)
            self._selectTime.setTitle(time)
        } else {
            self._selectTime.setTitle("select_start_and_end_time".localized())
        }
        dateModel = model
    }

    @IBAction func _handleDeleteEvent(_ sender: UIButton) {
        guard let indexPath = indexPath else { return }
        delegate?.didTapDeleteButton(at: indexPath)
    }

    @IBAction func _handleDatePickerEvent(_ sender: Any) {
        let controller = INIT_CONTROLLER_XIB(DateTimePickerVC.self)
        controller.selectedDate = repeatStartDate
        controller.startDate = repeatStartDate
        controller.endDate = repeatendDate
        controller.isCreateEvent = true
        controller.didUpdateCallback = { [weak self] date, time in
            guard let self = self else { return }
            let dates = Utils.dateToStringWithTimezone(date, format: kFormatDateLocal)
            let apiDate = Utils.dateToStringWithTimezone(date, format: kFormatDate)
            dateModel?.date = apiDate
            self.callback?(self.dateModel)
            self._selectDate.setTitle(Utils.dateToString(Utils.stringToDate(dates, format: kFormatDateLocal), format: kFormatEventDate))
        }
        self.parentViewController?.presentAsPanModal(controller: controller)
    }
    
    @IBAction func _handleTimePickerEvent(_ sender: CustomActivityButton) {
        var currentDate: Date? = nil
        if let date = dateModel?.date {
            currentDate = Utils.stringToDate(date, format: kFormatDate)
            var currentDay = Utils.dateToStringWithTimezone(currentDate, format: kFormatDateDayShort).lowercased()
            let now = Date()
            let calendar = Calendar.current
            if let currentDate = currentDate, calendar.isDate(currentDate, inSameDayAs: now) {
                showTimePicker(title: "select_start_time".localized(), minTime: now, isStartDate: true) { fromDate in
                    self.showTimePicker(title: "select_end_time", minTime: fromDate) { tillDate in
                        let time = "from".localized() + fromDate.time12HourWithAMPM + " - " + "till".localized() + tillDate.time12HourWithAMPM
                        self.dateModel?.startTime = fromDate.timeOnly
                        self.dateModel?.endTime = tillDate.timeOnly
                        self.callback?(self.dateModel)
                        self._selectTime.setTitle(time)
                    }
                }
            } else {
                showTimePicker(title: "select_start_time".localized()) { fromDate in
                    self.showTimePicker(title: "select_end_time".localized(), minTime: fromDate) { tillDate in
                        let time = "from".localized() + fromDate.time12HourWithAMPM + " - " + "till".localized() + tillDate.time12HourWithAMPM
                        self.dateModel?.startTime = fromDate.timeOnly
                        self.dateModel?.endTime = tillDate.timeOnly
                        self.callback?(self.dateModel)
                        self._selectTime.setTitle(time)
                    }
                }
            }
        } else {
            parentBaseController?.alert(message: "please_select_date_first".localized())
            return
        }
    }
    
    private func showTimePicker(title: String, minTime: Date? = nil, isStartDate: Bool = false, completion: @escaping (Date) -> Void) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        
        datePicker.calendar.timeZone = .current
        datePicker.calendar.locale = .current
        datePicker.timeZone = .current
        datePicker.locale = Locale(identifier: "en_GB")
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        
        if let minDate = minTime {
            if isStartDate {
                datePicker.date = minDate
                datePicker.minimumDate = minDate
            } else {
                datePicker.date = minDate.addingTimeInterval(1 * 60 * 60)
                datePicker.minimumDate = Calendar.current.date(byAdding: .day, value: -1, to: minDate.addingTimeInterval(1 * 60 * 60))
            }
        }
        
        alertController.view.addSubview(datePicker)
        
        let okAction = UIAlertAction(title: "ok".localized(), style: .default) { _ in
            var selectedDate = datePicker.date
            
            if let minDate = minTime, !isStartDate {
                if selectedDate < minDate {
                    selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate)!
                }
            }
            
            completion(selectedDate)
        }
        
        let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        alertController.view.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        datePicker.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 20).isActive = true
        datePicker.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 10).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -10).isActive = true
        datePicker.bottomAnchor.constraint(equalTo: alertController.view.bottomAnchor, constant: -100).isActive = true
        
        parentViewController?.present(alertController, animated: true, completion: nil)
    }
}
