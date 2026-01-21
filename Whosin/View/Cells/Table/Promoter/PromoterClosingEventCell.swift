import UIKit

class PromoterClosingEventCell: UITableViewCell {

    @IBOutlet private weak var _closingTypesegement: UISegmentedControl!
    @IBOutlet weak var _selectManualTimeView: UIView!
    @IBOutlet weak var _selectTimeBtn: CustomButton!
    private var _selectedDate: Date? = nil
    private var _params: [String: Any] = [:]
    var updateClosingtype: ((_ type: String, _ date: String) -> Void)?
    private var selectedtyp: String = "auto" {
        didSet {
            _closingTypesegement.selectedSegmentIndex = (selectedtyp == "auto") ? 0 : 1
            _selectManualTimeView.isHidden = selectedtyp == "auto"
        }
    }
    let dateFormatter = DateFormatter()

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
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = TimeZone.current
    }
    
    // --------------------------------------
    // MARK: Public
    // --------------------------------------
    
    public func setupData(_ param: [String:Any]) {
        _params = param
        if let closetype = param["spotCloseType"] as? String {
            selectedtyp = closetype
        } else {
            selectedtyp = "auto"
            updateClosingtype?(selectedtyp, param["startTime"] as? String ?? kEmptyString)
        }
        if let closeTime = param["spotCloseAt"] as? String {
            _selectedDate = Utils.stringToDate(closeTime, format: kFormatDateTimeUS)
        } else {
            _selectedDate = Utils.stringToDate(param["startTime"] as? String, format: kFormatDateTimeUS)
        }
        _closingTypesegement.selectedSegmentIndex = (selectedtyp == "auto") ? 0 : 1
        let dateStr = _selectedDate != nil ? Utils.dateToString(_selectedDate, format: kFormatDateTimeUS): ""
        if !Utils.stringIsNullOrEmpty(dateStr) {
            self._selectTimeBtn.setTitle("selected_closing_time_is".localized() + "\(dateStr)")
        }
    }
    
    // --------------------------------------
    // MARK: Event
    // --------------------------------------
    
    @IBAction func _handleClosingTypeRequiredEvent(_ sender: UISegmentedControl) {
        selectedtyp = (sender.selectedSegmentIndex == 0) ? "auto" : "manual"
        let dateStr = _selectedDate != nil ? dateFormatter.string(from: _selectedDate ?? Date()) : (_params["startTime"] as? String ?? kEmptyString)
        updateClosingtype?(selectedtyp, dateStr)
    }
    
    @IBAction private func _handleSelectDateEvent(_ sender: CustomButton) {
        guard let startTimeString = _params["startTime"] as? String,
              let endTimeString = _params["endTime"] as? String else {
            print("Invalid date range in parameters")
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = TimeZone.current
        guard let startTime = dateFormatter.date(from: startTimeString),
              let endTime = dateFormatter.date(from: endTimeString) else {
            print("Failed to parse start or end time")
            return
        }

        let alertController = UIAlertController(title: "select_closing_time".localized(), message: nil, preferredStyle: .actionSheet)
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        datePicker.locale = Locale(identifier: "en_GB")
        datePicker.minimumDate = startTime
        datePicker.maximumDate = endTime
        datePicker.date = startTime

        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        
        alertController.view.addSubview(datePicker)
        
        let okAction = UIAlertAction(title: "ok".localized(), style: .default) { _ in
            self._selectedDate = datePicker.date
            let dateStr = dateFormatter.string(from: datePicker.date)
            self._selectTimeBtn.setTitle("selected_closing_time_is".localized() + "\(dateStr)")
            self.updateClosingtype?(self.selectedtyp, dateStr)
        }
        
        let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        alertController.view.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 20),
            datePicker.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 10),
            datePicker.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -10),
            datePicker.bottomAnchor.constraint(equalTo: alertController.view.bottomAnchor, constant: -100)
        ])
        
        parentViewController?.present(alertController, animated: true, completion: nil)
    }



}
