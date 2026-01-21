import UIKit

class PromoterEventRepeatCell: UITableViewCell {

    @IBOutlet private weak var _dayView: UIView!
    @IBOutlet private weak var _selectedDay: CustomButton!
    @IBOutlet private weak var _dateView: UIView!
    @IBOutlet private weak var _selecteDate: CustomButton!
    @IBOutlet private weak var _eventRepeatText: CustomLabel!

    private var _selectedDate: Date? = nil
    private var _selectedEndDate: Date? = nil
    public var repeatCallBack: ((_ params: [String: Any]) -> Void)?
    private var params: [String: Any] = [:]
    private var repeatParams: [String: Any] = [:]

    // --------------------------------------
    // MARK: Class
    // --------------------------------------
    
    class var height: CGFloat { UITableView.automaticDimension }

    // --------------------------------------
    // MARK: Life Cycle
    // --------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableSelectEffect()
    }
    
    
    private func update() {
        self.repeatCallBack?(repeatParams)
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------

    public func setupData(_ params: [String: Any]) {
        self.params = params
        if let type = params["repeat"] as? String {
            repeatParams["repeat"] = type
            _dateView.isHidden = type == "none"
            _dayView.isHidden = type != "weekly"
            _eventRepeatText.text = Utils.stringIsNullOrEmpty(type) ? "None" : type.capitalizedSentence
        } else {
            repeatParams["repeat"] = "none"
            _eventRepeatText.text = "None"
            _dateView.isHidden = true
            _dayView.isHidden = true
        }
        if let date = params["repeatStartDate"] as? String, let endDate = params["repeatEndDate"] as? String {
            _selectedDate = Utils.stringToDate(date, format: kFormatDate)
            _selectedEndDate = Utils.stringToDate(endDate, format: kFormatDate)
            repeatParams["repeatStartDate"] = date
            repeatParams["repeatEndDate"] = endDate
            if Utils.stringIsNullOrEmpty(date), Utils.stringIsNullOrEmpty(endDate) {
                self._selecteDate.setTitle("select_date_range".localized())
            } else {
                self._selecteDate.setTitle("\(Utils.dateToString(_selectedDate, format: kFormatDateReview)) To \(Utils.dateToString(_selectedEndDate, format: kFormatDateReview))")
            }
        } else {
            self._selecteDate.setTitle("select_date_range".localized())
        }
        if let days = params["repeatDays"] as? [String] {
            repeatParams["repeatDays"] = days
            _selectedDay.setTitle(formatDays(days.joined(separator: ",")))
        } else {
            _selectedDay.setTitle("select_days".localized())
        }
     
    }
    
    func formatDays(_ daysString: String) -> String {
        guard !daysString.isEmpty else { return "Select Days" }
        
        let fullDayNames = [
            "sun": "Sunday", "mon": "Monday", "tue": "Tuesday",
            "wed": "Wednesday", "thu": "Thursday", "fri": "Friday",
            "sat": "Saturday"
        ]
        
        let daysArray = daysString.lowercased().split(separator: ",").compactMap { fullDayNames[String($0)] ?? String($0).capitalized }
        
        if daysArray.count >= 7 {
            return "All days"
        } else if Set(daysArray) == Set(["Saturday", "Sunday"]) {
            return "Weekend"
        } else if Set(daysArray) == Set(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]) {
            return "Week days"
        }
        
        return daysArray.joined(separator: ", ")
    }

    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction func _handleEventRepeatEvent(_ sender: CustomButton) {
        let alertController = UIAlertController(title: "repeat_event".localized(), message: nil, preferredStyle: .actionSheet)
        let options = ["none", "Daily", "Weekly", "Specific Dates"]
        
        for option in options {
            let action = UIAlertAction(title: option, style: .default) { action in
                self._eventRepeatText.text = option
                self.repeatParams["repeat"] = option
                self._selecteDate.setTitle("select_date_range".localized(), for: .normal)
                self._dateView.isHidden = (option == "None")
                self._dayView.isHidden = (option != "Weekly")
                self.update()
            }
            
            if option == self._eventRepeatText.text {
                action.setValue(true, forKey: "checked")
            }
            
            alertController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        parentViewController?.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func _handleDaySelection(_ sender: CustomButton) {
        let vc = INIT_CONTROLLER_XIB(DaysBottomSheet.self)
        vc.delegate = self
        let days = repeatParams["repeatDays"] as? [String]
        vc.selectedDays = days ?? []
        parentViewController?.presentAsPanModal(controller: vc)
    }
    
    @IBAction private func _hanldeSelectDateEvent(_ sender: CustomButton) {
        let eventDate = Utils.stringToDate(params["date"] as? String, format: kFormatDate)
        showTimePicker(title: "select_start_date".localized(), minTime: eventDate) { start in
            let startDate = Calendar.current.date(byAdding: .day, value: 1, to: start)!
            self.showTimePicker(title: "select_end_date".localized(), minTime: startDate) { end in
                self.repeatParams["repeatStartDate"] =  Utils.dateToString(start, format: kFormatDate)
                self.repeatParams["repeatEndDate"] =  Utils.dateToString(end, format: kFormatDate)
                self._selecteDate.setTitle("\(Utils.dateToString(start, format: kFormatDateReview)) To \(Utils.dateToString(end, format: kFormatDateReview))")
                self.update()
            }
        }
    }
    
    private func showTimePicker(title: String, minTime: Date? = nil, completion: @escaping (Date) -> Void) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        
        datePicker.calendar.timeZone = .current
        datePicker.calendar.locale = .current
        datePicker.timeZone = .current
        datePicker.locale = Locale(identifier: "en_GB")
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        
        if let minDate = minTime {
                datePicker.date = minDate
                datePicker.minimumDate = minDate
        }
        
        alertController.view.addSubview(datePicker)
        
        let okAction = UIAlertAction(title: "done".localized(), style: .default) { _ in
            var selectedDate = datePicker.date
            
            if let minDate = minTime {
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

extension PromoterEventRepeatCell: SelectDaysDelegate {
    func selectDay(_ days: [String]) {
        repeatParams["repeatDays"] = days
        _selectedDay.setTitle(formatDays(days.joined(separator: ",")))
        self.update()
    }
}
